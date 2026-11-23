---
name: icpsdkStandard
description: >-
  Complete guide and reference for @icp-sdk ecosystem (@icp-sdk/core, @icp-sdk/auth,
  @icp-sdk/signer) in IcFalcon frontend — agent, actors, candid, principal, auth, and signers.
---

# ICP SDK Standard

Official guide for the modern `@icp-sdk` package ecosystem across the IcFalcon frontend.

Replaces legacy `@dfinity/*` packages (`@dfinity/agent`, `@dfinity/auth-client`, `@dfinity/candid`, `@dfinity/identity`, `@dfinity/principal`).

---

## Package Ecosystem

| Package | Purpose | Primary Submodules |
|---|---|---|
| `@icp-sdk/core` | Core protocol interactions (agent, candid, identity, principal) | `/agent`, `/candid`, `/identity`, `/principal` |
| `@icp-sdk/auth` | Internet Identity, Passkeys, and OpenID browser authentication | `/client` (`AuthClient`, `OpenIdProvider`) |
| `@icp-sdk/signer` | ICRC-25 compliant wallet & signer integrations | `/agent` (`SignerAgent`), `/web`, `/extension` |

> **Important**: Never import from the root of `@icp-sdk/core` or `@icp-sdk/auth`. Always use submodules (e.g. `@icp-sdk/core/agent`, `@icp-sdk/auth/client`).

---

## Submodule Map

### 1. `@icp-sdk/core/agent`
- **`Actor`**: `Actor.createActor<T>(idlFactory, { agent, canisterId })`
- **`HttpAgent`**: `HttpAgent.create({ host, identity })`
- **`Identity`**: Type definition for authenticated and anonymous identities

### 2. `@icp-sdk/core/candid`
- **`IDL`**: Candid type constructors (`IDL.Service`, `IDL.Func`, `IDL.Record`, `IDL.Variant`, `IDL.Text`, `IDL.Nat`, etc.)

### 3. `@icp-sdk/core/principal`
- **`Principal`**: `Principal.fromText(str)`, `Principal.anonymous()`, `toText()`

### 4. `@icp-sdk/core/identity`
- **Keys & Delegations**: `Ed25519KeyIdentity`, `ECDSAKeyIdentity`, `DelegationIdentity`, `AttributesIdentity`

### 5. `@icp-sdk/auth/client`
- **`AuthClient`**: `new AuthClient(options)`, `signIn(options)`, `signOut()`, `getIdentity()`, `isAuthenticated()`, `requestAttributes({ keys, nonce })`
- **`OpenIdProvider`**: Type `'google' | 'apple' | 'microsoft'` for federated web3 login
- **`scopedKeys`**: Helper for one-click OpenID attributes

### 6. `@icp-sdk/signer`
- **`Signer`**: Standardized interface for ICRC-25 wallets (OISY, Plug, NFID)
- **`SignerAgent`**: Drop-in `HttpAgent` replacement routing canister calls through user signers
- **Transports**: `PostMessageTransport` (window), `UrlTransport` (redirects), `BrowserExtensionTransport` (injected extensions)

---

## Implementation in IcFalcon

### 1. Actor Factory (`services/client.ts`)

```typescript
import { Actor, HttpAgent } from "@icp-sdk/core/agent"
import type { Identity } from "@icp-sdk/core/agent"
import { idlFactory } from "@/services/idl"
import { canisterId, host } from "@/services/icp"

export type Outcome<T> = { ok: true; data: T } | { ok: false; error: string }

const actorCache = new Map<string, AppActor>()

export function clearActorCache(): void {
  actorCache.clear()
}

export async function createActor(identity?: Identity): Promise<AppActor> {
  const agent = await HttpAgent.create({ host, identity })
  if (host.includes("127.0.0.1") || host.includes("localhost")) {
    await agent.fetchRootKey()
  }
  return Actor.createActor<AppActor>(idlFactory, { agent, canisterId })
}

export async function call<T>(
  identity: Identity | undefined,
  errorLabel: string,
  run: (actor: AppActor) => Promise<T>,
): Promise<Outcome<T>> {
  try {
    const actor = await createActor(identity)
    const data = await run(actor)
    return { ok: true, data }
  } catch (error) {
    const message = error instanceof Error ? error.message : errorLabel
    return { ok: false, error: message }
  }
}
```

### 2. Candid IDL Definition (`services/idl.ts`)

```typescript
import { IDL } from "@icp-sdk/core/candid"

export const idlFactory = ({ IDL: idl }: { IDL: typeof IDL }) => {
  const ApiError = idl.Record({ code: idl.Nat32, message: idl.Text })
  const ApiResult = (T: any) => idl.Variant({ ok: T, err: ApiError })
  
  return idl.Service({
    ping: idl.Func([], [idl.Text], ["query"]),
    me: idl.Func([], [ApiResult(idl.Record({ username: idl.Text, role: idl.Text }))], ["query"]),
  })
}
```

---

## Production Authentication Architecture (`@icp-sdk/auth/client`)

Based on the production ICPay authentication standard:
- **Multi-Provider Support**: Internet Identity, Passkeys, and OpenID (`Google`, `Apple`, `Microsoft`) via `OpenIdProvider`.
- **Dual-Transport Architecture**: Desktop Popup (`window`) and Mobile Redirect (`redirect`) with state resumption.
- **Self-Healing Session Binding**: Validates delegation against backend canister on load (`openBackendSession`), auto-purging invalid/wrong-network sessions (`discardRejectedSession`).
- **Resilience**: `PopupBlockedError` detection, delegation TTL (8 days), and clear actor cache on sign-out.

### 1. Core Auth Service (`services/auth/auth.ts`)
Full implementation: [`references/auth.ts`](references/auth.ts)

```typescript
import type { Identity } from "@icp-sdk/core/agent"
import { AuthClient, type OpenIdProvider } from "@icp-sdk/auth/client"
import { getIdentityProvider, getDerivationOrigin, getHost } from "@/services/icp"
import { clearActorCache, createActor } from "@/services/client"
import { DELEGATION_TTL, POPUP_FEATURES, II_BACKEND_CANISTER_ID } from "@/lib/auth/config"
import {
  prefersRedirectTransport,
  markRedirectPending,
  clearRedirectPending,
  hasRedirectPending,
  isInternetIdentityReturn,
  clearInternetIdentityReturnHash,
} from "@/lib/auth/transport"

export type LoginOptions = {
  openIdProvider?: OpenIdProvider
  transport?: "window" | "redirect"
}

export async function login(options?: LoginOptions): Promise<Identity | null> {
  const redirect = options?.transport === "redirect" || prefersRedirectTransport()
  if (redirect) markRedirectPending()
  const authClient = createClient(options)
  try {
    return await authClient.signIn({ maxTimeToLive: DELEGATION_TTL })
  } catch (e) {
    if (redirect) clearRedirectPending()
    if (e instanceof Error && (e.message.includes("popup") || e.message.includes("blocked"))) {
      throw new PopupBlockedError()
    }
    throw e
  }
}

export async function resumeRedirectSignIn(): Promise<Identity | null> {
  if (!hasRedirectPending() && !isInternetIdentityReturn()) return null
  try {
    const authClient = new AuthClient(clientOptions({ transport: "redirect" }))
    const identity = await authClient.signIn({ maxTimeToLive: DELEGATION_TTL })
    clearRedirectPending()
    clearInternetIdentityReturnHash()
    return identity
  } catch (e) {
    clearRedirectPending()
    return null
  }
}

export async function openBackendSession(id: Identity): Promise<void> {
  const actor = await createActor(id)
  if (typeof (actor as any).me === "function") await (actor as any).me()
}

export async function logout(): Promise<void> {
  clearActorCache()
  const authClient = await createAuthClient()
  await authClient.signOut()
}
```

### 2. React Context & Provider (`components/auth/auth-provider.tsx`)
Full implementation: [`references/auth-provider.tsx`](references/auth-provider.tsx)

```typescript
"use client"

import { createContext, useContext, useEffect, useState, useCallback, useMemo, type ReactNode } from "react"
import type { Identity } from "@icp-sdk/core/agent"
import {
  login as iiLogin,
  logout as iiLogout,
  createAuthClient,
  openBackendSession,
  discardRejectedSession,
  resumeRedirectSignIn,
  type LoginOptions,
} from "@/services/auth/auth"

export type AuthContextType = {
  identity: Identity | undefined
  principal: string
  isAuthenticated: boolean
  isLoading: boolean
  ready: boolean
  login: (options?: LoginOptions | unknown) => Promise<void>
  acceptIdentity: (identity: Identity) => Promise<void>
  logout: () => Promise<void>
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [identity, setIdentity] = useState<Identity | undefined>(undefined)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    async function init() {
      try {
        const redirected = await resumeRedirectSignIn()
        if (redirected) {
          await openBackendSession(redirected)
          setIdentity(redirected)
          return
        }
        const client = await createAuthClient()
        if (client.isAuthenticated()) {
          const id = await client.getIdentity()
          await openBackendSession(id)
          setIdentity(id)
        }
      } catch {
        await discardRejectedSession()
      } finally {
        setIsLoading(false)
      }
    }
    init()
  }, [])

  const login = useCallback(async (options?: LoginOptions | unknown) => {
    const opts = options && typeof options === "object" && ("openIdProvider" in options || "transport" in options)
      ? (options as LoginOptions)
      : undefined
    const id = await iiLogin(opts)
    if (id) {
      await openBackendSession(id)
      setIdentity(id)
    }
  }, [])

  return (
    <AuthContext.Provider
      value={{
        identity,
        principal: identity && !identity.getPrincipal().isAnonymous() ? identity.getPrincipal().toText() : "",
        isAuthenticated: !!identity && !identity.getPrincipal().isAnonymous(),
        isLoading,
        ready: !isLoading,
        login,
        acceptIdentity: async (id) => { await openBackendSession(id); setIdentity(id); },
        logout: async () => { await iiLogout(); setIdentity(undefined); },
      }}
    >
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
```

---

## Asset Signer Integration (`@icp-sdk/signer`)

For interactive multi-wallet approval (e.g. OISY, NFID):

```typescript
import { Signer } from "@icp-sdk/signer"
import { PostMessageTransport } from "@icp-sdk/signer/web"
import { SignerAgent } from "@icp-sdk/signer/agent"

const transport = new PostMessageTransport({ url: "https://oisy.com/sign" })
const signer = new Signer({ transport })
const accounts = await signer.getAccounts()

const agent = await SignerAgent.create({
  signer,
  account: accounts[0].owner,
})
```

---

## Architectural Rules

1. **Submodule Imports Only**: Always import from `@icp-sdk/core/*` or `@icp-sdk/auth/*`. Never import root packages.
2. **Actor Encapsulation**: Never create `HttpAgent` in UI components — isolate inside `services/client.ts`.
3. **Session Self-Healing**: Always invoke `openBackendSession(id)` on session restore. If rejected, call `discardRejectedSession()` to prevent ghost sessions.
4. **Mobile Transport Resumption**: On mobile browsers, popups are blocked by default; always check `prefersRedirectTransport()` and resume delegations via `resumeRedirectSignIn()`.
5. **Pure Lib Layer**: Files in `lib/` must never import `@icp-sdk/*` or React.
6. **No Deprecated Packages**: Strictly avoid `@dfinity/*` imports.

---

## Reference Implementations

| Role | File Path |
|---|---|
| Core Auth Service | [`references/auth.ts`](references/auth.ts) |
| React Provider & Hook | [`references/auth-provider.tsx`](references/auth-provider.tsx) |
| Transport Utilities | [`references/transport.ts`](references/transport.ts) |
| Auth Constants & Config | [`references/config.ts`](references/config.ts) |

---

## Related

| Topic | Path |
|---|---|
| Frontend standard | [`frontendStandard/SKILL.md`](../frontendStandard/SKILL.md) |
| API endpoints | [`endpointsStandard/SKILL.md`](../endpointsStandard/SKILL.md) |
| Internet Identity auth | [`motokoStandard/internetIdentityAuthStandard/SKILL.md`](../motokoStandard/internetIdentityAuthStandard/SKILL.md) |
| Layering rules | [`layeringStandard/SKILL.md`](../layeringStandard/SKILL.md) |
