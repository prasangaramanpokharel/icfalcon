---
name: deployStandard
description: >-
  Authoritative full-stack deployment guide for IcFalcon backend canisters and Next.js frontend.
  Covers local auto-start, environment synchronization, cycles funding with terminal QR codes, and mainnet shipping.
---

# Deploy Standard

Comprehensive, step-by-step deployment standard for IcFalcon backend Motoko canisters and Next.js frontend across local and mainnet environments.

## Purpose

Provide deterministic, error-free deployment runbooks for AI agents and developers, ensuring zero-failure local deploys, automatic frontend environment synchronization, and clean mainnet cycle funding.

## When to use

- Deploying backend canisters locally or to mainnet (`falcon b:deploy`, `falcon b:deploy --local`)
- Running or building the Next.js frontend (`falcon f:dev`, `falcon f:build`, `falcon f:prod`)
- Recovering from replica downtime or cycle exhaustion (`falcon y:fund`)
- Synchronizing Candid declarations and canister IDs across the full stack

## Related

- Safety restrictions: [`restrictionStandard`](../restrictionStandard/SKILL.md)
- Command reference: [`commandStandard`](../commandStandard/SKILL.md)
- Frontend engineering: [`frontendStandard`](../frontendStandard/SKILL.md)
- Production deploy details: [`guideStandard/productionDeployStandard`](../guideStandard/productionDeployStandard/SKILL.md)
- Cycle cost reference: [`cycleCostStandard`](../cycleCostStandard/SKILL.md)

---

## 1. Local Deployment (Backend + Frontend)

### Level 1A: Backend Local Deploy (One-Shot)

Run:
```bash
falcon b:deploy --local
```

#### What Happens Automatically:
1. **Network Auto-Check:** Verifies if the local `icp` test network (port `8000`) is running.
2. **Auto-Start:** If stopped or stale, it kills lingering processes, starts `icp network start -d`, and waits until healthy.
3. **Canister Compilation:** Builds `app` canister using `icp-cli` and `moc`.
4. **Installation:** Deploys canister with `--wasm-memory-persistence keep` to preserve state.
5. **Full-Stack Env Sync:** Automatically extracts the canister ID (e.g. `4caro-...`) and writes `frontend/.env.local`:
   ```ini
   NEXT_PUBLIC_CANISTER_ID=<canister_id>
   NEXT_PUBLIC_IC_HOST=http://127.0.0.1:8000
   NEXT_PUBLIC_II_URL=https://identity.ic0.app
   ```

#### Verification:
```bash
falcon c:status --local    # Check canister operational status
falcon c:ping --local      # Returns "healthy"
falcon c:id --local        # Prints active local canister ID
```

---

### Level 1B: Frontend Local Development & Preview

#### Option 1: Live Dev Server (Hot Reloading)
```bash
falcon f:dev
```
- Starts Next.js on `http://localhost:3000`.
- Automatically connects to local backend canister via `@icp-sdk/core` and `frontend/.env.local`.

#### Option 2: Production Static Export Preview
```bash
# 1. Compile Next.js 15 static export
falcon f:build

# 2. Serve static export (frontend/out/)
falcon f:prod
```

---

## 2. Mainnet Production Deployment (Full Stack)

Mainnet deployment requires affirmative confirmations and valid cycles. Follow these sequential steps:

### Step 1: Pre-Flight Verification
Always verify code quality, skill structure, and compilation before pushing to mainnet:
```bash
falcon p:check --local
```
*Ensures skills validate, 35 Motoko files pass linter, canister builds, and Next.js static export succeeds.*

### Step 2: Check Identity & Cycles
```bash
falcon whoami              # Verify active deployer identity
falcon y:bal               # Check cycles balance
```

### Step 3: Cycles Funding Triage (If Cycles < 1T)
If the identity needs cycles or deployment reports `out of cycles`:
```bash
falcon y:fund [amount_in_icp]
```
*(Default suggested amount is 0.50 ICP, yielding ~5 Trillion cycles).*

#### The Minimal Terminal Prompt:
```text
==================================================================
CYCLES FUNDING REQUIRED
==================================================================

Identity:        default
Required:        ~5.00 T Cycles
Suggested:       0.50 ICP

Account ID (Recommended):
  <64_character_hex_account_id>

Principal ID:
  <principal_id>

Scan QR Code:
  [High-contrast UTF-8 QR code]
==================================================================

I have sent [y/N]: 
```
- **Type `y` or `yes`:** The CLI automatically mints cycles and resumes deployment (`falcon b:deploy`).
- **Type `n`:** Cancels safely without dangling state.

### Step 4: Backend Production Deploy
```bash
falcon b:deploy
```
- Connects to Internet Computer mainnet.
- Compiles with `icp-cli` and installs via `--mode=upgrade` (never `--clean` or `reinstall`).
- Outputs the permanent mainnet canister ID and Candid UI link.

### Step 5: Frontend Production Build & Hosting
```bash
# 1. Update frontend production env
# frontend/.env.production
NEXT_PUBLIC_CANISTER_ID=<mainnet_canister_id>
NEXT_PUBLIC_IC_HOST=https://icp-api.io
NEXT_PUBLIC_II_URL=https://identity.ic0.app

# 2. Build production static bundle
falcon f:build

# 3. Ship assets to asset canister or static host (Vercel, Fleek, Cloudflare Pages)
```

---

## 3. Environment & Deployment Matrix

| Command | Target | Port / Host | What It Does |
|---|---|---|---|
| `falcon r:start --local` | Local | `8000` | Starts native `icp` test network in background |
| `falcon r:stop --local` | Local | - | Stops background test network |
| `falcon b:deploy --local` | Local | `8000` | Auto-starts network, builds & deploys backend, syncs `frontend/.env.local` |
| `falcon f:dev` | Local | `3000` | Next.js development server with hot-reload |
| `falcon f:build` | Both | - | Next.js 15 static export to `frontend/out/` |
| `falcon f:prod` | Local | `3000` | Local HTTP preview of `frontend/out/` |
| `falcon b:deploy` | Mainnet | `icp-api.io` | Mainnet backend upgrade deploy |
| `falcon y:fund` | Mainnet | - | Displays Account ID & terminal QR code for cycle top-up |
| `falcon p:check --local` | Local | - | Full CI test: skills + Motoko lint + build + frontend export |

---

## 4. AI Troubleshooting & Error Recovery

1. **"The local network for this project is not running":**
   - Solution: Run `falcon b:deploy --local`. It will auto-detect the stopped network and start it automatically.
2. **"Failed to create canister ... Canister is out of cycles":**
   - Solution: Run `falcon y:fund`. Transfer the indicated ICP, scan the QR code, and type `y` to auto-deploy.
3. **"Frontend cannot reach backend":**
   - Solution: Re-run `falcon b:deploy --local` to refresh `frontend/.env.local`, then restart `falcon f:dev`.
4. **"Caller is not a controller":**
   - Solution: Check active identity with `falcon whoami` and verify controllers via [`icpayControllerStandard`](../icpayControllerStandard/SKILL.md).
