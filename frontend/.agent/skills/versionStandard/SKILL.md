---
name: versionStandard
description: "Frontend dependency versioning, @icp-sdk pairing, and package.json compatibility standard for IcFalcon Next.js applications."
---

# Frontend Version Standard (`versionStandard`)

Authoritative standard for managing dependencies, version pairing rules, and upgrade runbooks inside `frontend/package.json`.

---

## Purpose

Frontend Internet Computer applications depend on seamless interoperability between `@icp-sdk/core`, `@icp-sdk/auth`, Next.js 15, and React 19. Deprecated packages (e.g. `@dfinity/agent`, `@dfinity/auth-client`) introduce peer-dependency conflicts, runtime exceptions, and security vulnerabilities. This standard defines the exact version tiers, pairing invariants, and verification workflows required for zero-drift frontend stability.

---

## When to use

- Adding, bumping, or auditing dependencies in `frontend/package.json`
- Initializing or configuring `AuthClient` with Internet Identity
- Resolving npm `ERESOLVE` peer-dependency collisions during package installs
- Verifying Next.js 15 App Router and React 19 compatibility
- Running pre-deployment build verification (`npm run build`)

---

## 1. Authoritative Package Matrix

| Package | Pinned Version | Layer | Role & Invariant |
|---|---|---|---|
| **`@icp-sdk/core`** | `^6.1.1` | SDK Core | HttpAgent, Principal, Candid IDL, bls12381 cryptography. Replaces `@dfinity/agent`, `@dfinity/candid`, `@dfinity/principal`. |
| **`@icp-sdk/auth`** | `^11.2.0` | Auth | Internet Identity client and delegation storage. **Strict peer dependency on `@icp-sdk/core` ^6.x**. |
| **`@icp-sdk/signer`** | `^6.1.1` | Signer | Multi-wallet signer standard (window, popup, transport). |
| **`next`** | `^15.5.29` | Framework | Next.js App Router with static HTML export (`output: "export"`). |
| **`react` & `react-dom`** | `^19.3.1` | UI Library | React 19 concurrent runtime and React Server Component primitives. |
| **`@types/react`** | `^19.3.0` | Types | Strict TypeScript definitions matching React 19 runtime. |
| **`@tailwindcss/postcss`** | `^4.3.5` | Styling | Tailwind CSS v4 CSS-first compiler plugin. |
| **`tailwindcss`** | `^4.3.5` | Styling | Tailwind CSS v4 utility runtime. |
| **`@base-ui/react`** | `^1.9.0` | Primitives | Accessible headless UI components powering shadcn blocks. |
| **`typescript`** | `^5.9.3` | Language | Strict typechecking and ES module resolution. |

---

## 2. Critical Pairing Invariants

### Invariant 1: `@icp-sdk/auth` v11 Requires `@icp-sdk/core` v6
Never install `@icp-sdk/auth` v11 alongside `@icp-sdk/core` v5. Npm will throw `ERESOLVE could not resolve conflicting peer dependency`.
```json
// CORRECT (frontend/package.json)
{
  "dependencies": {
    "@icp-sdk/auth": "^11.2.0",
    "@icp-sdk/core": "^6.1.1"
  }
}
```

### Invariant 2: `identityProvider` is Strictly an Object in Auth v11
In `@icp-sdk/auth` v11+, the `identityProvider` option of `AuthClient.create()` / `new AuthClient()` requires an object with `authorizeUrl` and `canisterId`. Passing a bare string throws runtime error:
`TypeError: identityProvider names authorizeUrl and canisterId together, or neither: nothing about the canister is derived from the URL`.

```typescript
// ❌ Deprecated (Auth v8/v9 syntax — throws TypeError at runtime)
const authClient = new AuthClient({
  identityProvider: "https://identity.ic0.app",
})

// ✅ Correct (Auth v11+ syntax)
const authClient = new AuthClient({
  identityProvider: {
    authorizeUrl: process.env.NEXT_PUBLIC_II_URL ?? "https://identity.ic0.app",
    canisterId: process.env.NEXT_PUBLIC_II_CANISTER_ID ?? "rdmx6-jaaaa-aaaaa-aaadq-cai",
  },
})
```

### Invariant 3: Zero Legacy `@dfinity/*` Imports
All legacy `@dfinity` modules must be migrated to `@icp-sdk`:
```typescript
// ❌ Deprecated imports
import { HttpAgent, Actor } from "@dfinity/agent"
import { Principal } from "@dfinity/principal"
import { AuthClient } from "@dfinity/auth-client"

// ✅ Modern imports
import { HttpAgent, Actor } from "@icp-sdk/core/agent"
import { Principal } from "@icp-sdk/core/principal"
import { AuthClient } from "@icp-sdk/auth/client"
```

---

## 3. Dependency Upgrade Runbook

When updating or auditing frontend dependencies, execute this sequence:

```bash
# 1. Check latest published versions
npm view @icp-sdk/core version
npm view @icp-sdk/auth version
npm view next version

# 2. Update frontend/package.json
# Ensure @icp-sdk/core and @icp-sdk/auth match the supported version matrix

# 3. Clean lockfile and reinstall
cd frontend
rm -rf package-lock.json node_modules/@icp-sdk
npm install

# 4. Verify static production build
npm run build

# 5. Run IcFalcon framework preflight check
falcon p:check --local
```

---

## 4. Invariant Checklist for AI Agents

- [ ] All `@icp-sdk/*` imports use submodule paths (`@icp-sdk/core/agent`, `@icp-sdk/auth/client`).
- [ ] No `@dfinity/*` packages present in `frontend/package.json`.
- [ ] `AuthClient` configuration specifies `{ authorizeUrl, canisterId }`.
- [ ] Next.js config maintains `output: "export"` for canister asset compatibility.
- [ ] `npm run build` succeeds with zero TypeScript or PostCSS errors.

---

## Related

| Skill | Path |
|---|---|
| Frontend Router | [`../../SKILLS.md`](../../SKILLS.md) |
| Root Version Standard | [`../../../../.agent/skills/versionStandard/SKILL.md`](../../../../.agent/skills/versionStandard/SKILL.md) |
| Root Frontend Standard | [`../../../../.agent/skills/frontendStandard/SKILL.md`](../../../../.agent/skills/frontendStandard/SKILL.md) |
| Root @icp-sdk Standard | [`../../../../.agent/skills/icpsdkStandard/SKILL.md`](../../../../.agent/skills/icpsdkStandard/SKILL.md) |
| Lib Standard | [`../libStandard/SKILL.md`](../libStandard/SKILL.md) |
| Hooks Standard | [`../hooksStandard/SKILL.md`](../hooksStandard/SKILL.md) |
| Shadcn Standard | [`../shadcnStandard/SKILL.md`](../shadcnStandard/SKILL.md) |
