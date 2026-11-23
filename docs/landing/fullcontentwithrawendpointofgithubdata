<p align="center">
  <a href="https://icpay.cloud/icfalcon" target="_blank" rel="noopener noreferrer">
    <img src="https://icpay.cloud/images/logo/icfalcon/icfalcon.png" alt="IcFalcon Framework" width="300" />
  </a>
</p>

<h1 align="center">IcFalcon — The Motoko Framework for Internet Computer dApps</h1>

<p align="center">
  <strong>Production-ready Motoko backend, modern Next.js frontend with Internet Identity, and a global developer CLI.</strong><br />
  Enforced 4-tier layered architecture · FalconORM relational engine · Custodial finance primitives · Autonomous AI agent skills.
</p>

<p align="center">
  <a href="https://www.npmjs.com/package/icfalcon"><img src="https://img.shields.io/npm/v/icfalcon?color=0070f3&label=icfalcon" alt="npm version" /></a>
  <a href="https://www.npmjs.com/package/create-icfalcon"><img src="https://img.shields.io/npm/v/create-icfalcon?color=22c55e&label=create-icfalcon" alt="create-icfalcon" /></a>
  <a href="https://github.com/prasangaramanpokharel/icfalcon/releases"><img src="https://img.shields.io/github/v/release/prasangaramanpokharel/icfalcon?color=a855f7&label=github%20release" alt="GitHub release" /></a>
  <a href="https://github.com/prasangaramanpokharel/icfalcon/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License" /></a>
  <a href="https://mops.one/core"><img src="https://img.shields.io/badge/mops-mo%3Acore%402.6.1-orange" alt="mo:core" /></a>
  <a href="https://github.com/dfinity/motoko/releases/tag/1.6.0"><img src="https://img.shields.io/badge/motoko-1.6.0-cyan" alt="Motoko compiler" /></a>
</p>

<p align="center">
  <a href="https://icpay.cloud/icfalcon">Official Website</a> ·
  <a href="https://github.com/prasangaramanpokharel/icfalcon#readme">GitHub Repo</a> ·
  <a href="https://github.com/prasangaramanpokharel/icfalcon/releases">Releases</a> ·
  <a href="https://github.com/prasangapokharel/icp-hub">icp-hub Packages</a> ·
  <a href="https://raw.githubusercontent.com/prasangaramanpokharel/icfalcon/main/docs/landing/fullcontentwithrawendpointofgithubdata.md">Raw GitHub Endpoint</a>
</p>

---

> ### 📡 Raw Endpoint API
> This comprehensive document is available via direct raw GitHub fetch for external apps, landing pages, documentation aggregators, and developer tools:
> ```bash
> curl -fsSL https://raw.githubusercontent.com/prasangaramanpokharel/icfalcon/main/docs/landing/fullcontentwithrawendpointofgithubdata.md
> ```

---

## Table of Contents

1. [Executive Summary & The ICP Dilemma](#1-executive-summary--the-icp-dilemma)
2. [Quickstart — Zero to Deployed in 60 Seconds](#2-quickstart--zero-to-deployed-in-60-seconds)
3. [The 4-Tier Backend Architecture](#3-the-4-tier-backend-architecture)
4. [FalconORM — 3NF Relational Engine for Motoko](#4-falconorm--3nf-relational-engine-for-motoko)
5. [The Money Layer — Custodial Wallets & ICRC Transfers](#5-the-money-layer--custodial-wallets--icrc-transfers)
6. [Production Authentication Standard (`@icp-sdk/auth/client`)](#6-production-authentication-standard-icp-sdkauthclient)
7. [Falcon Universe — Multi-Canister Event Mesh](#7-falcon-universe--multi-canister-event-mesh)
8. [Autonomous AI Agent Skills System (`.agent/skills/`)](#8-autonomous-ai-agent-skills-system-agentskills)
9. [The `falcon` Ops CLI Reference](#9-the-falcon-ops-cli-reference)
10. [Automated Framework Updater (`falcon update`)](#10-automated-framework-updater-falcon-update)
11. [Project Directory Layout](#11-project-directory-layout)
12. [Real-World Scaffolding & Verification Walkthrough](#12-real-world-scaffolding--verification-walkthrough)

---

## 1. Executive Summary & The ICP Dilemma

The Internet Computer (ICP) offers unparalleled compute: canisters run at web speed, serve HTTP directly from blockchain state, execute with zero-gas fees for end users (reverse-gas model), and hold orthogonal persistent memory.

However, building production-grade canisters has historically suffered from **four critical friction points**:

| The Friction Point | How Traditional ICP Apps Struggle | The IcFalcon Solution |
|---|---|---|
| **No Architectural Standard** | Canister logic is dumped into monolithic `main.mo` files or ad-hoc modules with no separation between Candid parsing, business validation, and storage. | **Enforced 4-Tier Architecture**: Strict `api → service → repository → storage` layering with zero cyclical dependencies and guaranteed isolation. |
| **Fragmented Tooling** | Developers must constantly juggle `dfx`, `mops`, `npm`, replica ports, identity pem files, and custom shell scripts. | **Global `falcon` CLI**: Single executable wrapping scaffolding, compiling, testing, cycles management, and multi-network deployments. |
| **Frontend-Canister Mismatch** | Complex manual actor setup, broken `@dfinity/*` legacy packages, runtime `TypeError` on auth options, and mobile popup blocks. | **Modern `@icp-sdk` Stack**: Next.js 15 App Router, shadcn/ui components, target-scoped delegations, and auto-resumed mobile redirect authentication. |
| **Missing Financial Primitives** | Building token transfer or custodial wallet features requires hazardous raw ledger outcalls, risking balance traps or double-spends. | **Hardened Finance Standard**: Battle-tested subaccount derivation, two-phase safe transfer flows (`proposeTransfer` → human confirm → `executeTransfer`), and atomic dual-entry ledgers. |

### Framework, Not Just Boilerplate

Unlike minimal starter templates that abandon developers after cloning, **IcFalcon** functions like Rails or Django for the Internet Computer:
- Scaffolds complete full-stack feature slices (`falcon m:f <Name>`) spanning backend API, service, repository, storage, Candid IDL, and Next.js frontend UI panels.
- Integrates **FalconORM** to run normalized 3NF queries with auto-synchronized indices.
- Provides 64 comprehensive AI agent skills (`.agent/skills/`) so coding agents (Cursor, Claude Code, Gemini CLI, Antigravity) never hallucinate invalid APIs.

---

## 2. Quickstart — Zero to Deployed in 60 Seconds

### Installation

Initialize a new production project with one command:

```bash
npm create icfalcon@latest my-app
```

*Or run directly with npx:*

```bash
npx create-icfalcon my-app
```

*Or use the official curl installer:*

```bash
curl -fsSL https://icpay.app/flc/install.sh | bash
```

### What Happens Automatically

```text
______    ___    _       _____   _____   _   _ 
|  ___|  / _ \  | |     /  __ \ |  _  | | \ | |
| |_    / /_\ \ | |     | /  \/ | | | | |  \| |
|  _|   |  _  | | |     | |     | | | | | . ` |
| |     | | | | | |____ | \__/\ \ \_/ / | |\  |
\_|     \_| |_/ \_____/  \____/  \___/  \_| \_/
Designed by Icpay Official

  ⠋ Checking prerequisites
  ✓ Checking prerequisites (git, node, dfx, mops)
  ⠋ Downloading template
  ✓ Downloading template
  ⠋ Installing falcon CLI
  ✓ Installing falcon CLI to ~/.local/bin/falcon
  ⠋ Initializing local environment
  ✓ Starting local replica (port 4943)
  ✓ Deploying canister: app
  ✓ Wiring Candid interfaces to frontend
  ✓ Starting Next.js development server

  🎉 Success! Created my-app at /path/to/my-app
  Local Dev Server: http://localhost:3000
```

Once inside your project directory:

```bash
cd my-app
falcon f:dev          # Start Next.js development server
falcon b:test --local # Run backend unit tests
falcon a:c:m          # Audit Motoko code against mo:core 2.x standards
```

---

## 3. The 4-Tier Backend Architecture

IcFalcon enforces a unidirectional, 4-tier layer pattern inside `backend/src/`. This guarantees modularity, easy unit testing with mocks, and zero data leakage.

```
┌────────────────────────────────────────────────────────┐
│                   Next.js Frontend                     │
│    (@icp-sdk/core/agent · @icp-sdk/auth/client)        │
└───────────────────────────┬────────────────────────────┘
                            │ Candid RPC Calls
                            ▼
┌────────────────────────────────────────────────────────┐
│  Tier 1: API Layer (backend/src/api/v1/)               │
│  - Candid endpoint definitions & mixins                │
│  - Caller authentication: { caller } destructured      │
│  - Rejects Principal.isAnonymous(caller)               │
│  - Input validation & early error returns              │
└───────────────────────────┬────────────────────────────┘
                            │ Validated Parameters
                            ▼
┌────────────────────────────────────────────────────────┐
│  Tier 2: Service Layer (backend/src/services/)         │
│  - Pure business logic & state transitions             │
│  - External ledger calls (ICRC-1/2 token transfers)    │
│  - Two-phase safe authorization                        │
│  - Cross-canister asynchronous boundaries              │
└───────────────────────────┬────────────────────────────┘
                            │ Domain Operations
                            ▼
┌────────────────────────────────────────────────────────┐
│  Tier 3: Repository Layer (backend/src/repositories/)  │
│  - Entity access abstraction & FalconORM models        │
│  - Secondary index synchronization                     │
│  - Query filtering, sorting, pagination                │
└───────────────────────────┬────────────────────────────┘
                            │ Direct Read/Write
                            ▼
┌────────────────────────────────────────────────────────┐
│  Tier 4: Storage Layer (backend/src/storage/)          │
│  - Enhanced Orthogonal Persistence (EOP)               │
│  - Motoko stable variables & stable data structures    │
│  - Safe canister upgrade migrations                    │
└────────────────────────────────────────────────────────┘
```

### Layer Rules & Invariants

1. **`api` only talks to `services`**: API endpoints must never touch repositories or storage directly.
2. **`services` orchestrate logic**: Services handle business rules, calculate fees, call repositories, and perform ledger transactions.
3. **`repositories` mediate data**: Repositories query and persist domain models through the storage layer.
4. **`storage` owns stable state**: Storage holds the persistent data collections and migration primitives.

### Example: Tier 1 API Endpoint (`backend/src/api/v1/Order.mo`)

```motoko
import Types "../../types";
import OrderService "../../services/OrderService";
import MiddlewareAuth "../../middleware/Auth";

mixin (
  service : OrderService.OrderService,
  mwConfig : MiddlewareAuth.Config,
) {
  // Public update endpoint with caller destructuring
  public shared ({ caller }) func createOrder(
    productId : Text,
    quantity : Nat,
  ) : async Types.ApiResult<Types.OrderView> {
    // 1. Authenticate caller (never anonymous)
    let effectiveCaller = MiddlewareAuth.effectiveCaller(mwConfig, caller);
    if (Principal.isAnonymous(effectiveCaller)) {
      return #err({ code = 401; message = "Unauthorized: Anonymous callers rejected" });
    };

    // 2. Delegate directly to service
    await OrderService.create(service, effectiveCaller, productId, quantity);
  };
};
```

---

## 4. FalconORM — 3NF Relational Engine for Motoko

Managing relational data on the Internet Computer with raw arrays or `Map` collections leads to slow linear scans ($O(N)$), index desynchronization, and memory bloat. **FalconORM** introduces a complete 3NF relational engine directly inside Motoko.

### Features
- **Normalized Models**: Strict primary keys and strongly-typed attribute fields.
- **Auto-Synchronized Secondary Indices**: Indices on foreign keys, statuses, and timestamps are updated atomically on insert, update, and delete.
- **Fluent Query Builder**: Chained filtering, pagination, sorting, and counting.
- **Safe Relational Navigation**: `belongsTo` and `hasMany` relationships with zero boilerplate.

### Example: FalconORM Model Definition (`backend/pkg/orm/`)

```motoko
import ORM "mo:orm";

// 1. Define Model Schema
public type Order = {
  id : Text;
  userId : Principal;
  productId : Text;
  status : {#pending; #completed; #cancelled};
  amount : Nat;
  createdAt : Int;
};

// 2. Query Builder with Auto-Synchronized Indices
let orders = OrderModel.query()
  .where(#userId(userPrincipal))
  .where(#status(#pending))
  .orderBy(#createdAt, #desc)
  .limit(20)
  .offset(0)
  .execute();
```

---

## 5. The Money Layer — Custodial Wallets & ICRC Transfers

IcFalcon includes the battle-tested financial architecture from **ICPay**, providing safe token operations right out of the box.

### Subaccount Derivation
Every user receives a unique, deterministic 32-byte subaccount derived directly from their Principal:

$$\text{Subaccount} = \text{SHA224}(\text{Principal}) \mathbin{\Vert} \text{Checksum}$$

```motoko
import Subaccount "mo:subaccount";

// Deterministic custodial deposit address
let depositSubaccount = Subaccount.fromPrincipal(userPrincipal);
```

### The Two-Phase Safe Transfer Protocol
To prevent catastrophic balance traps, double-spending, and re-entrancy attacks during canister upgrades or network delays, IcFalcon implements a **two-phase human-confirmed transfer flow**:

```
[User UI]                  [Main Canister]                [ICRC-1 Ledger]
    │                             │                              │
    │  1. proposeTransfer(params) │                              │
    ├────────────────────────────>│  (Validates balance:         │
    │                             │   amount + fee <= balance)   │
    │  2. Returns Preview + Fee   │  (Generates transferId &     │
    │<────────────────────────────┤   reserves balance lock)     │
    │                             │                              │
    │  [Human Reviews Preview]    │                              │
    │                             │                              │
    │  3. executeTransfer(id)     │                              │
    ├────────────────────────────>│  4. icrc1_transfer(...)      │
    │                             ├─────────────────────────────>│
    │                             │  5. BlockIndex or Error      │
    │  6. Confirmed & Tx Logged   │<─────────────────────────────┤
    │<────────────────────────────┤                              │
```

---

## 6. Production Authentication Standard (`@icp-sdk/auth/client`)

IcFalcon uses the latest `@icp-sdk/auth` (v11+) package. It eliminates all legacy `@dfinity/*` dependencies and guarantees rock-solid multi-provider authentication.

### Supported Authentication Providers
- **Internet Identity & Passkeys**: One-click authentication with TouchID, FaceID, or hardware security keys (YubiKey).
- **Federated Web3 OpenID**: Seamless onboarding with Google, Apple, and Microsoft accounts via `OpenIdProvider`.
- **Dual-Transport Architecture**: Automatic detection between Desktop Popup (`window`) and Mobile Redirect (`redirect`), ensuring iOS Safari and Android Chrome never drop sessions.

### Invariant: Strict `identityProvider` Object Signature
Modern `@icp-sdk/auth/client` requires both `authorizeUrl` and `canisterId` passed in an object:

```typescript
// ✅ Correct Auth v11 Signature
const authClient = new AuthClient({
  identityProvider: {
    authorizeUrl: "https://identity.ic0.app",
    canisterId: "rdmx6-jaaaa-aaaaa-aaadq-cai",
  },
  agentOptions: { host: "https://icp-api.io" },
  windowOpenerFeatures: "toolbar=0,location=0,menubar=0,width=500,height=700",
})
```

### Self-Healing Session Hydration
When a user opens the application, IcFalcon probes the backend canister with `openBackendSession(identity)`. If the stored delegation has expired or was signed against a different network, it automatically triggers `discardRejectedSession()` to prevent ghost states:

```typescript
// Self-healing session restoration
try {
  const client = await createAuthClient()
  if (client.isAuthenticated()) {
    const id = await client.getIdentity()
    await openBackendSession(id) // Validates caller against canister
    setIdentity(id)
  }
} catch {
  await discardRejectedSession() // Safely sign out if delegation expired
}
```

---

## 7. Falcon Universe — Multi-Canister Event Mesh

When your application scales beyond a single canister's storage or execution boundaries, **Falcon Universe** acts as **"Kafka for Motoko"**: an asynchronous, event-driven multi-canister mesh.

### Core Primitives
- **Transactional Outbox Pattern**: State mutations and outgoing event messages commit atomically inside the same canister update call.
- **Idempotent Inboxes**: Message deduplication keys prevent repeated processing during network retries.
- **Decoupled Micro-Canisters**: Easily partition billing, user profile maps, order books, and heavy compute workloads into specialized canisters.

Scaffold a standalone micro-canister wired into Falcon Universe in seconds:

```bash
falcon m:c Vault
falcon b:deploy --canister vault --local
```

---

## 8. Autonomous AI Agent Skills System (`.agent/skills/`)

IcFalcon is architected for the era of AI-native software engineering. The repository contains **64 specialized, validated AI skills** structured with YAML frontmatter and comprehensive architectural instructions.

When coding agents (Cursor, Claude Code, Gemini CLI, Antigravity) work on an IcFalcon codebase, they read [`.agent/SKILLS.md`](.agent/SKILLS.md) to instantly adhere to all standards:

```text
.agent/skills/
├── codingStandard/                 # Motoko 1.6 & mo:core 2.6.1 rules (no deprecated mo:base)
├── layeringStandard/               # Strict 4-tier separation: api → services → repositories → storage
├── errorHandlingStandard/          # Types.ApiResult<T>, early returns, M0033 shared return types
├── endpointsStandard/              # Thin Candid mixins, caller destructuring
├── ormStandard/                    # FalconORM schema definitions, queries, and relations
├── deployStandard/                 # Local auto-start, environment synchronization, cycles QR codes
├── icpayControllerStandard/        # Canister controller permissions on mainnet
├── financeStandard/
│   ├── walletStandard/             # Subaccount derivation, custodial balances
│   ├── transferStandard/           # Two-phase safe transfers, idempotency locks
│   ├── transactionStandard/        # Atomic TxStore history index
│   └── swapStandard/               # ICRC-2 AMM liquidity, slippage protection
└── motokoStandard/
    ├── writingMotokoStandard/      # Compiler rules, reserved keyword collisions (#dbg vs #debug)
    ├── internetIdentityAuthStandard/# Network consistency constraint, self-healing sessions
    └── httpOutcallsStandard/       # On-chain HTTPS requests with cycle cost estimation
```

Validate and enforce skill compliance at any time:

```bash
falcon sk:validate          # Validates all 64 skills, links, and schemas
falcon audit code:motoko    # Audits all Motoko files for layering & mo:core compliance
```

---

## 9. The `falcon` Ops CLI Reference

Every operation in IcFalcon is unified under the global `falcon` executable.

| Command | Short Alias | Action |
|---|---|---|
| `falcon setup:init` | `falcon s:init` | Complete setup: start replica, install packages, deploy, start Next.js dev server |
| `falcon setup:update` | `falcon update`, `up` | Safe framework updater: syncs framework packages, agent skills, and linters |
| `falcon replica:start` | `falcon r:start` | Starts local Internet Computer replica in the background |
| `falcon replica:stop` | `falcon r:stop` | Stops running local replica |
| `falcon backend:test` | `falcon b:test` | Runs all Motoko backend unit tests (`--local`) |
| `falcon backend:build` | `falcon b:build` | Compiles Motoko canisters with `moc 1.6.0` |
| `falcon backend:deploy` | `falcon b:deploy` | Deploys canister to target environment (requires confirmation on mainnet) |
| `falcon backend:logs` | `falcon b:logs` | Streams live canister execution logs |
| `falcon make:feature <Name>` | `falcon m:f <Name>` | Scaffolds full 4-tier module (API, Service, Repo, Storage, IDL, UI panel) |
| `falcon make:canister <Name>`| `falcon m:c <Name>` | Scaffolds independent micro-canister wired to Falcon Universe mesh |
| `falcon add pkg <name>` | `falcon a:p <name>` | Installs Motoko package from `icp-hub` registry |
| `falcon cycles:balance` | `falcon y:bal` | Checks identity and canister cycles balance |
| `falcon cycles:fund` | `falcon y:fund` | Generates interactive terminal QR code to fund identity with ICP for cycles |
| `falcon cycles:topup` | `falcon y:topup` | Tops up canister with cycles |
| `falcon audit code:motoko` | `falcon a:c:m` | Validates Motoko code against `mo:core 2.x` standard (`--fix` to auto-clean) |
| `falcon skills:validate` | `falcon sk:validate` | Validates all 64 agent skills, YAML headers, and internal references |
| `falcon prod:check` | `falcon p:check` | Comprehensive production audit: skills + code audit + canister build + Next.js build |

---

## 10. Automated Framework Updater (`falcon update`)

Existing IcFalcon users can update their framework and tooling with a single command:

```bash
falcon update
# or the short alias:
falcon up
```

### Protection Guarantee
The framework updater strictly separates framework tooling from user code:
- **`backend/src/` (Your Business Logic)**: 100% UNTOUCHED. Canister services, APIs, and models are preserved.
- **`frontend/` (Your UI & Pages)**: 100% UNTOUCHED. Custom pages and styling are preserved.
- **Canister State & `.env`**: 100% UNTOUCHED. Identities and live canister persistent storage are preserved.
- **`ops/`, `.agent/skills/`, and `backend/pkg/`**: Updated to the latest releases directly from GitHub.
- **Toolchain**: Automatically pins `mo:core = "2.6.1"` and `moc = "1.6.0"` in `backend/mops.toml`.

---

## 11. Project Directory Layout

```text
.
├── .agent/                         # AI Agent Knowledge System
│   ├── SKILLS.md                   # Hierarchical router for coding agents
│   └── skills/                     # 64 verified engineering standards
├── backend/                        # Motoko Canister Backend
│   ├── mops.toml                   # Pinned dependencies (mo:core 2.6.1, moc 1.6.0)
│   ├── pkg/                        # Standard Hub packages (ORM, logger, saga, dao, slug, etc.)
│   ├── src/                        # 4-Tier User Code (Untouched by updates)
│   │   ├── api/v1/                 # Public Candid mixins & caller validation
│   │   ├── services/               # Pure business logic & ledger integration
│   │   ├── repositories/           # FalconORM models & index queries
│   │   ├── storage/                # Orthogonal persistent stable memory
│   │   ├── middleware/             # Authentication & rate-limiting guards
│   │   ├── validators/             # Domain parameter validation
│   │   ├── main.mo                 # Main canister actor composition
│   │   └── types.mo                # Shared domain records & ApiResult variants
│   └── testing/                    # Comprehensive Motoko unit tests
├── frontend/                       # Next.js 15 Full-Stack UI
│   ├── app/                        # App Router
│   │   ├── (app)/page.tsx          # Main dashboard & wallet view
│   │   ├── (auth)/login/page.tsx   # Production auth view (Passkeys, Google, Apple, Microsoft)
│   │   └── layout.tsx              # Root layout with Tooltip & AuthProvider
│   ├── components/                 # shadcn/ui components & feature panels
│   ├── lib/auth/                   # Auth configuration, transport, & mobile redirect logic
│   ├── services/                   # @icp-sdk actor client & authentication service
│   └── public/brand/               # Official brand assets & logo
├── ops/                            # Ops CLI Runner, Templates & Scripts
│   ├── falcon                      # Unified CLI executable
│   ├── install.sh                  # Global symlink installer
│   ├── scripts/                    # Automated workflows (update, audit, deploy, test)
│   └── templates/                  # Scaffolding templates for modules & micro-canisters
├── falcon.yaml                     # Command & alias configuration
└── package.json                    # Root npm package metadata
```

---

## 12. Real-World Scaffolding & Verification Walkthrough

### Step 1: Scaffold a New Feature
Run `falcon m:f Invoice`:

```bash
falcon m:f Invoice
```

This instantly creates:
- `backend/src/api/v1/Invoice.mo`
- `backend/src/services/InvoiceService.mo`
- `backend/src/repositories/InvoiceRepository.mo`
- `backend/src/storage/InvoiceStorage.mo`
- `backend/src/validators/InvoiceValidator.mo`
- `frontend/services/invoice/invoice.ts`
- `frontend/components/invoice/invoice-panel.tsx`
- Automatically wires Candid types into `main.mo`!

### Step 2: Audit and Verify Code
Run the full production validation pipeline:

```bash
falcon p:check --local
```

### Terminal Output:

```text
______    ___    _       _____   _____   _   _ 
|  ___|  / _ \  | |     /  __ \ |  _  | | \ | |
| |_    / /_\ \ | |     | /  \/ | | | | |  \| |
|  _|   |  _  | | |     | |     | | | | | . ` |
| |     | | | | | |____ | \__/\ \ \_/ / | |\  |
\_|     \_| |_/ \_____/  \____/  \___/  \_| \_/

▸ prod:check (local)
==> validate-skills (.agent/skills)
skills checked: 64
errors: 0
warnings: 0
ok: validate-skills passed

==> Motoko Code Validator (IcFalcon Standard)
Auditing 35 Motoko file(s)...
✓ backend/src/api/v1/Auth.mo
✓ backend/src/api/v1/Feature.mo
✓ backend/src/api/v1/Invoice.mo
✓ backend/src/api/v1/Wallet.mo
✓ backend/src/services/InvoiceService.mo
✓ backend/src/repositories/InvoiceRepository.mo
✓ backend/src/storage/InvoiceStorage.mo
...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Files audited:  36
Warnings:       0
Errors:         0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
motoko-validator PASSED successfully!

==> Building with icp-cli (app)
Building canisters: app
Canisters built successfully

> build
> next build
 ✓ Compiled successfully
 ✓ Linting and checking validity of types
 ✓ Generating static pages (5/5)
 ✓ Exporting static output to out/

┌─────────────────────────────────────┐
│  ✓  Production check PASSED (100%)  │
└─────────────────────────────────────┘
```

---

## Official Links & Resources

- **Official Website**: [https://icpay.cloud/icfalcon](https://icpay.cloud/icfalcon)
- **GitHub Repository**: [https://github.com/prasangaramanpokharel/icfalcon](https://github.com/prasangaramanpokharel/icfalcon)
- **NPM Package (CLI)**: [https://www.npmjs.com/package/icfalcon](https://www.npmjs.com/package/icfalcon)
- **NPM Package (Scaffolder)**: [https://www.npmjs.com/package/create-icfalcon](https://www.npmjs.com/package/create-icfalcon)
- **Package Registry**: [https://github.com/prasangapokharel/icp-hub](https://github.com/prasangapokharel/icp-hub)
- **Raw GitHub Markdown Endpoint**: [https://raw.githubusercontent.com/prasangaramanpokharel/icfalcon/main/docs/landing/fullcontentwithrawendpointofgithubdata.md](https://raw.githubusercontent.com/prasangaramanpokharel/icfalcon/main/docs/landing/fullcontentwithrawendpointofgithubdata.md)

---

<p align="center">
  <sub>Designed with precision by <a href="https://icpay.cloud">Icpay Official</a> · Released under the MIT License</sub>
</p>
