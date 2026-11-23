---
name: versionStandard
description: "Versioning, dependency pinning, and compatibility standard for IcFalcon — managing latest @icp-sdk/core, @icp-sdk/auth, Next.js, React, and Motoko toolchain packages without version drift."
---

# Version Standard (`versionStandard`)

Standard for managing dependencies, version pairing rules, and upgrade runbooks across the IcFalcon full-stack framework.

---

## Purpose

Internet Computer tooling and client libraries evolve rapidly. Deprecated packages (e.g. legacy `@dfinity/*` or `mo:base`) introduce subtle runtime errors, security vulnerabilities, and peer-dependency collisions. This standard establishes authoritative version tiers, pairing invariants, and verification runbooks to guarantee 100% build reproducibility and type safety.

---

## When to use

- Adding, upgrading, or auditing packages in `frontend/package.json`
- Configuring `@icp-sdk/core` and `@icp-sdk/auth` client initialization
- Resolving peer-dependency conflicts or upgrade breaking changes
- Verifying Motoko compiler (`moc`) and `mo:core` version compatibility
- Running pre-deployment dependency health checks

---

## 1. Official Version Matrix

### Frontend Tiers (`frontend/package.json`)

| Package | Pinned Version | Role / Compatibility Rule |
|---|---|---|
| **`@icp-sdk/core`** | `^6.1.1` | **Foundation SDK**. Replaces legacy `@dfinity/agent`, `@dfinity/candid`, `@dfinity/principal`. |
| **`@icp-sdk/auth`** | `^11.2.0` | **Authentication Client**. Replaces `@dfinity/auth-client`. **Must pair with `@icp-sdk/core` ^6.x**. |
| **`@icp-sdk/signer`** | `^6.1.1` | **Multi-Wallet Transport**. Standardized signer interface (web, extension, URL). |
| **`next`** | `^15.5.29` | App Router, static export (`output: "export"`), Turbopack support. |
| **`react` & `react-dom`** | `^19.3.1` | React 19 concurrent features and Server Components. |
| **`tailwindcss`** | `^4.3.5` | Modern CSS-first Tailwind engine via `@tailwindcss/postcss`. |
| **`@base-ui/react`** | `^1.9.0` | Unstyled headless accessibility primitives. |
| **`typescript`** | `^5.9.3` | Strict type checking and module resolution. |

### Backend Tiers (`backend/mops.toml` & `dfx.json`)

| Tool / Package | Version | Invariant |
|---|---|---|
| **`moc` (Compiler)** | `1.6.0` | Enhanced Orthogonal Persistence (EOP) enabled by default. |
| **`mo:core`** | `^2.6.1` | Official pure standard library. Strict ban on deprecated `mo:base`. |
| **`mops`** | `^1.0.0` | Package manager for Motoko packages. |
| **`dfx`** | `0.23+` | Replica runner, Wasm compilation, and snapshot manager. |

---

## 2. Critical Version Pairing Invariants

### Invariant 1: `@icp-sdk/auth` v11 Requires `@icp-sdk/core` v6
Never mix `@icp-sdk/auth` 11.x with `@icp-sdk/core` 5.x. Doing so triggers npm `ERESOLVE` peer-dependency failures:
```json
// CORRECT (frontend/package.json)
{
  "@icp-sdk/auth": "^11.2.0",
  "@icp-sdk/core": "^6.1.1"
}
```

### Invariant 2: `identityProvider` is an Object in Auth v11
In `@icp-sdk/auth` v11+, `identityProvider` is no longer accepted as a bare URL string. It must be provided as an object containing both `authorizeUrl` and `canisterId`:

```typescript
// ❌ Deprecated (Auth v8/v9 syntax — throws TypeError at runtime)
const authClient = new AuthClient({ identityProvider: "https://identity.ic0.app" })

// ✅ Modern (Auth v11+ syntax)
const authClient = new AuthClient({
  identityProvider: {
    authorizeUrl: process.env.NEXT_PUBLIC_II_URL ?? "https://identity.ic0.app",
    canisterId: process.env.NEXT_PUBLIC_II_CANISTER_ID ?? "rdmx6-jaaaa-aaaaa-aaadq-cai",
  },
})
```

### Invariant 3: Zero Legacy `@dfinity/*` Packages
Legacy `@dfinity/*` packages (`@dfinity/agent`, `@dfinity/auth-client`, `@dfinity/candid`, `@dfinity/principal`) are completely banned in IcFalcon. All imports must target `@icp-sdk/*`:

```typescript
// ❌ Legacy
import { HttpAgent } from "@dfinity/agent";
import { Principal } from "@dfinity/principal";

// ✅ Modern
import { HttpAgent } from "@icp-sdk/core/agent";
import { Principal } from "@icp-sdk/core/principal";
import { AuthClient } from "@icp-sdk/auth/client";
```

---

## 3. Version Upgrade & Verification Runbook

Follow these steps when bumping package versions:

### Step 1: Update `frontend/package.json`
Verify latest versions on npm:
```bash
npm view @icp-sdk/core version
npm view @icp-sdk/auth version
```

Update `package.json` dependencies to match paired releases.

### Step 2: Clean Re-Installation
Avoid peer-dependency lockfile conflicts:
```bash
cd frontend
rm -rf package-lock.json node_modules/@icp-sdk
npm install
```

### Step 3: Run Full Preflight Verification
Confirm zero TypeScript compilation errors, zero Motoko audit warnings, and successful Next.js static export:
```bash
falcon p:check --local
```

---

## 4. Golden Rules for AI Agents

1. **Check Compatibility Before Installing**: When adding any frontend library, verify compatibility with React 19 and Next.js 15.
2. **Never Downgrade to `@dfinity/*`**: If an AI prompt mentions `@dfinity/agent` or `@dfinity/auth-client`, immediately translate it to `@icp-sdk/core` and `@icp-sdk/auth`.
3. **Respect Lockfiles**: Always commit updated `package-lock.json` and `backend/icp.pkg` after running dependency upgrades.
4. **No Unpinned Major Bumps**: Never use wildcard `*` or unverified alpha/beta versions in production dependencies.

---

## Related

| Skill | Path |
|---|---|
| Frontend Version Standard | [`frontend/.agent/skills/versionStandard/SKILL.md`](../../../frontend/.agent/skills/versionStandard/SKILL.md) |
| Frontend Standard | [`frontendStandard/SKILL.md`](../frontendStandard/SKILL.md) |
| @icp-sdk Reference | [`icpsdkStandard/SKILL.md`](../icpsdkStandard/SKILL.md) |
| CLI Commands | [`commandStandard/SKILL.md`](../commandStandard/SKILL.md) |
| Motoko Coding Standard | [`codingStandard/SKILL.md`](../codingStandard/SKILL.md) |
| Package Ecosystem | [`packageStandard/SKILL.md`](../packageStandard/SKILL.md) |
