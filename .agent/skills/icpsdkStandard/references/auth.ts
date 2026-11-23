import type { Identity } from "@icp-sdk/core/agent"
import { AuthClient, type OpenIdProvider } from "@icp-sdk/auth/client"
import { getIdentityProvider, getDerivationOrigin, getHost } from "@/services/icp"
import { clearActorCache, createActor } from "@/services/client"
import {
  DELEGATION_TTL,
  POPUP_FEATURES,
  II_BACKEND_CANISTER_ID,
} from "@/lib/auth/config"
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

let clientPromise: Promise<AuthClient> | null = null
let readyClient: AuthClient | null = null

function wantsRedirectTransport(options?: LoginOptions): boolean {
  if (options?.transport === "window") return false
  if (options?.transport === "redirect") return true
  return prefersRedirectTransport()
}

function clientOptions(options?: LoginOptions) {
  const redirect = wantsRedirectTransport(options)
  const host = getHost()
  return {
    identityProvider: {
      authorizeUrl: getIdentityProvider(),
      canisterId: II_BACKEND_CANISTER_ID,
    },
    agentOptions: { host },
    derivationOrigin: getDerivationOrigin(),
    windowOpenerFeatures: POPUP_FEATURES,
    transport: redirect ? ("redirect" as const) : ("window" as const),
    ...(options?.openIdProvider ? { openIdProvider: options.openIdProvider } : {}),
  }
}

function signInOptions() {
  return {
    maxTimeToLive: DELEGATION_TTL,
  }
}

function ensureDefaultClient(): AuthClient {
  readyClient ??= new AuthClient(clientOptions())
  clientPromise ??= Promise.resolve(readyClient)
  return readyClient
}

function createClient(options?: LoginOptions): AuthClient {
  if (!options?.openIdProvider && !wantsRedirectTransport(options)) {
    return ensureDefaultClient()
  }
  return new AuthClient(clientOptions(options))
}

export async function createAuthClient(): Promise<AuthClient> {
  return ensureDefaultClient()
}

export class PopupBlockedError extends Error {
  constructor() {
    super("Popup blocked. Allow popups for this site, then try again.")
    this.name = "PopupBlockedError"
  }
}

async function signInWithAttributes(
  authClient: AuthClient,
): Promise<Identity | null> {
  return await authClient.signIn(signInOptions())
}

export async function resumeRedirectSignIn(): Promise<Identity | null> {
  if (!hasRedirectPending() && !isInternetIdentityReturn()) return null
  try {
    const options: LoginOptions = { transport: "redirect" }
    const identity = await signInWithAttributes(
      new AuthClient(clientOptions(options)),
    )
    clearRedirectPending()
    clearInternetIdentityReturnHash()
    return identity
  } catch (e) {
    clearRedirectPending()
    console.error("II redirect resume error:", e)
    return null
  }
}

export async function login(options?: LoginOptions): Promise<Identity | null> {
  const redirect = wantsRedirectTransport(options)
  if (redirect) {
    markRedirectPending()
  }
  const authClient = createClient(options)
  try {
    return await signInWithAttributes(authClient)
  } catch (e) {
    if (redirect) clearRedirectPending()
    if (
      e instanceof Error &&
      (e.message.includes("popup") || e.message.includes("blocked"))
    ) {
      throw new PopupBlockedError()
    }
    throw e
  }
}

export async function logout(): Promise<void> {
  clearActorCache()
  const authClient = await createAuthClient()
  await authClient.signOut()
}

export async function openBackendSession(id: Identity): Promise<void> {
  const actor = await createActor(id)
  try {
    if (typeof (actor as any).me === "function") {
      await (actor as any).me()
    } else if (typeof (actor as any).ping === "function") {
      await (actor as any).ping()
    }
  } catch (err) {
    throw err
  }
}

export async function discardRejectedSession(): Promise<void> {
  clearActorCache()
  try {
    const authClient = await createAuthClient()
    await authClient.signOut()
  } catch {
    // Best-effort sign-out
  }
}
