# Changelog

All notable changes to IcFalcon are documented here.

## [0.3.4] - 2026-11-23

### Added
- **Production `@icp-sdk/auth` Standard (ICPay Pattern)**: Fully integrated the battle-tested ICPay authentication architecture into `.agent/skills/icpsdkStandard/` and `frontend/services/auth/auth.ts`.
- **Multi-Provider & Federated Web3 Login**: Support for Internet Identity, Passkeys (FaceID, TouchID, YubiKey), and OpenID providers (`Google`, `Apple`, `Microsoft`) via `OpenIdProvider`.
- **Dual-Transport Architecture**: Desktop Popup (`window`) and Mobile Redirect (`redirect`) transports with automatic state resumption via `resumeRedirectSignIn()`.
- **Self-Healing Session Binding**: Probes backend canister on load (`openBackendSession`), auto-purging invalid, expired, or wrong-network delegations (`discardRejectedSession`).
- **Dedicated `/login` Auth Route**: Implemented `frontend/app/(auth)/login/page.tsx` featuring IcFalcon branding, Passkeys, federated OpenID grid, and mobile redirect fallback.
- **Enhanced Framework Updater**: Upgraded `falcon update` (`falcon up`) with automatic GitHub bundle extraction for standalone and private user projects, protecting `backend/src/` and user state.

### Fixed
- **`identityProvider` Object Signature**: Standardized `{ authorizeUrl, canisterId }` object signature across `frontend/services/auth/auth.ts`, `ops/docs/frontend.md`, and `versionStandard`, eliminating runtime `TypeError`.
- **Audio Feedback**: Added zero-asset Web Audio API login chime in `frontend/lib/ui/successChime.ts`.

## [0.3.3] - 2026-11-23

### Added
- **AI-Guaranteed `mo:core` Standard Rules**: Documented authoritative `mo:core` (2.x) API lookup table in `.agent/skills/codingStandard/SKILL.md` (methods for strings, arrays, iterators, and converters).
- **Automated AI Linter Checks**: Enhanced `falcon audit code:motoko` (`validate-code.sh`) to automatically detect and flag deprecated/removed `mo:base` methods (`Array.append`, `Array.subArray`, `Text.toLowercase`, `Text.toUppercase`, `Text.substring`, `Array.fromIter`, and `#debug` keyword collisions).
- **Language Guardrail Documentation**: Formulated explicit AI warning sections for Motoko reserved words (`#debug`, `func object`), `var` record mutability (`M0179`), and async return shareability (`M0033`).
- **Cleaned Package Whitespace**: Auto-fixed all trailing whitespace across all 137 Motoko backend files.

## [0.3.2] - 2026-11-23

### Fixed
- **`mo:core@2.6.1` Package Alignment**: Conducted comprehensive audit of all packages under `backend/pkg/` against `backend/.mops/core@2.6.1/src/`.
- **String & Text Operations**: Migrated `Text.toLowercase` and `Text.toUppercase` to `Text.toLower` and `Text.toUpper`; replaced non-existent `Text.substring` with idiomatic `Iter.take` and char iterators (`slug`, `string`).
- **Array Operations**: Replaced deprecated `Array.append` with `Array.concat<T>` across `array`, `blob`, `indexer`, `multisig`, and `upload`.
- **Iterator & VarArray Modernization**: Migrated `Array.fromIter` to `Iter.toArray` in `orm/index` and `Array.fromVarArray` to `VarArray.toArray` in `orm/query`.
- **Record Construction & Mutability**: Fixed `var` field initialization in `job-queue` and `dead-letter-queue`; aligned functional record updates in `dao`, `escrow`, and `upload`.
- **Reserved Keywords**: Renamed keyword-colliding function `object` to `obj` in `json` and keyword variant `#debug` to `#dbg` in `logger`.
- **Async Function Typing**: Specialized generic async boundaries in `retry` and `saga` to concrete shared types satisfying Motoko's `shared` return constraint.
- **Compiler Cleanliness**: Eliminated all unused imports and variables across backend packages.

## [0.3.1] - 2026-11-23

### Changed
- **Official Website & Homepage**: Set official homepage to `https://icpay.cloud/icfalcon` across GitHub repository metadata, npm packages (`icfalcon`, `create-icfalcon`), and Next.js frontend navigation.
- **GitHub Repository Topics**: Configured official topics and tags (`canister`, `cli`, `framework`, `icfalcon`, `icp`, `icpay`, `internet-computer`, `motoko`, `nextjs`, `typescript`, `web3`) on `prasangaramanpokharel/icfalcon`.
- **Frontend Navigation & Links**: Updated top navigation and hero action buttons to direct to `https://icpay.cloud/icfalcon` and official documentation.

## [0.3.0] - 2026-11-23

### Added
- **Native `icp-cli` Toolchain**: Migrated build, network, and deployment pipelines from legacy `dfx` to native `icp-cli` (`v1.8.0`) with `icp.yaml` and PocketIC test networks.
- **Zero-Failure Local Auto-Deploy (`falcon b:deploy --local`)**: Automatically detects local test network status, kills stale processes, starts background network on port 8000, and deploys without manual intervention.
- **Full-Stack Env Synchronization**: Local backend deployments automatically update `frontend/.env.local` with the active canister ID and host (`http://127.0.0.1:8000`).
- **Interactive Cycles Funding (`falcon y:fund` / `falcon cycles:fund`)**: Minimal, formal terminal prompt displaying required ICP, Account ID, Principal, and a high-contrast UTF-8 QR code for scanning from mobile wallets (Plug, Bitfinity, Oisy, NNS), with interactive auto-deploy on confirmation (`I have sent [y/N]`).
- **Multi-Token Swap Standard (`swapStandard`)**: Formal protocol for multi-token AMM trading (ICP, ckBTC, ckETH, ckUSDC, ICRC tokens) with pre-flight liquidity depth checks, slippage bounds, comprehensive three-part fee breakdown, and ICRC-2 delegation flows.
- **AI Safety Guardrails (`restrictionStandard`)**: Strict rules prohibiting autonomous execution of destructive commands (`canister:delete`, `--mode=reinstall`, wasm state wipes, identity deletion) without explicit bold user confirmation (`CONFIRM EXECUTE`).
- **Authoritative Full-Stack Deploy Standard (`deployStandard`)**: Comprehensive root standard detailing end-to-end deployment runbooks for backend Motoko and Next.js frontend across local and mainnet environments.

### Fixed
- **Clean Artifacts & Legacy Removal**: Deleted obsolete `backend/.dfx/` and empty root `testing/` directories.
- **Deprecation Warnings**: Resolved all `dfx is deprecated` warnings by routing canister operations (`c:status`, `c:ping`, `c:id`) through native `icp-cli`.

## [0.2.5] - 2026-09-28

### Fixed

- **Global CLI Working Directory Context**: `falcon` now intelligently walks up from `$PWD` to discover the enclosing project's `falcon.yaml` instead of resolving to the installation symlink directory, ensuring commands (`falcon add pkg`, `falcon b:deploy`, etc.) execute on the user's active project
- **Self-Healing Package Reinstall**: `falcon add pkg` checks disk directory state and re-downloads missing package files into `backend/pkg/<name>` even if an entry existed in `icp.pkg`
- **Fallback CLI Scripts**: Automatic fallback from local project `ops/` to `CLI_ROOT/ops/` when executing global falcon commands across projects

## [0.2.4] - 2026-09-28

### Added

- **Ultra-Premium Landing Page**: Redesigned landing page with luminous background meteors, animated ShineBorder backend status card, and icPay partner attribution
- **Interactive Theme Switch**: Instant reactive dark/light mode toggle in the header with persistent localStorage caching and zero SSR hydration flicker
- **Documentation & Commands CTAs**: Prominent quick links for Framework Documentation and CLI Commands Reference

## [0.2.3] - 2026-09-28

### Added

- **Frontend Production Preview (`falcon f:production` / `falcon f:prod`)**: Command to serve the static production bundle using `npx serve@latest out` inside `frontend/`
- **Package Standard Skill (`packageStandard`)**: AI skill for discovering, mapping, and enforcing icp-hub package adoption
- **Hub Registry Expansion**: 21 enterprise packages registered in `hub/index.json` (117 total) and synced to GitHub `master` and `main`
- **10 Ready-Made SaaS Product Prompts**: Copy-pasteable AI prompts under `ops/templates/prompt/saas/` with full specifications

## [0.2.2] - 2026-09-27

### Fixed

- **Self-healing Local Replica**: Auto-cleanup for orphaned `pocket-ic`, lingering `dfx start`, `icx-proxy`, and stale `.dfx/network/local/pid` process locks (`kill_lingering_replica_processes`)
- **Clean Replica Deployment**: Cleared hardcoded local canister IDs from `canister_ids.json` and added automatic fallback from upgrade to install mode on clean replica subnet initialization
- **Non-blocking Scaffolding**: `npm create icfalcon@latest` returns cleanly to shell prompt with quickstart commands instead of blocking inside `npm run dev` (`FALCON_NO_DEV=1`)
- **Fast Frontend Setup**: Skips redundant shadcn network re-download in `setup-frontend.sh` when components already exist in `frontend/components/ui/`
- **Canister Call Working Directory**: `canister-call.sh` (`falcon c:call` and `falcon c:ping`) automatically targets `backend/` to resolve `dfx.json` from root
- **Git Ignore**: Added `test/`, `test-*/`, and `my-app/` scaffold test folders to `.gitignore`

### Added

- Comprehensive documentation suite under `ops/docs/` (`commands.md`, `architecture.md`, `universe.md`, `audit.md`, `packages.md`, `finance.md`, `frontend.md`)

## [0.2.1] - 2026-09-26

### Added

- Motoko Code Validator & Linter (`ops/scripts/code/motoko/validate-code.sh` and `ops/scripts/motoko-validator.sh`)
- `falcon audit code:motoko` and `falcon a:c:m` commands with auto-formatting (`--fix`) for trailing whitespace, CRLF, and EOF newlines
- Motoko code auditing integrated into production pre-flight checks (`falcon p:check`)
- `falconUniverseStandard` skill (`.agent/skills/falconUniverseStandard/SKILL.md`) for event-driven multi-canister architecture ("Kafka for Motoko")
- `pkg/universe` package with transactional outbox, idempotent inbox sliding-window deduplication, and wildcard topic broker
- High-throughput `mo:core/Queue` doubly-linked list backing for event outbox queue
- Timer heartbeat integration (`Timer.setTimer` & `Timer.recurringTimer`) for automatic event flushing
- Published `universe` package to the `icp-hub` registry

## [0.2.0] - 2026-09-24

### Added

- `icpsdkStandard` skill (`.agent/skills/icpsdkStandard/SKILL.md`) covering complete `@icp-sdk/core`, `@icp-sdk/auth`, and `@icp-sdk/signer` ecosystem
- `icpayControllerStandard` skill (`.agent/skills/icpayControllerStandard/SKILL.md`) for managing canister controllers via ICPay (icpay.app)
- Automated `mops` toolchain `moc` resolution in `ops/falcon` and `backend/scripts/run-tests.sh`
- Support for `--wasm-memory-persistence keep` on upgrade deploys for Motoko enhanced orthogonal persistence
- Official framework homepage linked at https://icpay.app/icfalcon

### Changed

- Migrated frontend from deprecated `@dfinity/*` packages to modern `@icp-sdk/core` and `@icp-sdk/auth`
- Streamlined `frontend/package.json` dependencies
- Set `--network ic` as default network target in `falcon` CLI (use `--local` for local replica)

## [0.1.0] - 2026-08-19

### Added

- Motoko backend with layered architecture (`api` → `service` → `repository` → `storage`)
- Next.js frontend with shadcn/ui (`base-maia` preset), dark theme, welcome page
- Global `falcon` CLI (`ops/falcon` + `falcon.yaml`) with scaffold, build, deploy, hub packages
- `falcon m:f <Name>` — Laravel-style module scaffolding
- icp-hub integration (`falcon add pkg`, `falcon p:list`, lock file `backend/icp.pkg`)
- Documentation under `docs/` (gettingStarted, backend, frontend, ops, packages, agents)
- AI agent skills under `.agent/skills/` (integration, frontend, Motoko, deploy)
- Internet Identity auth wiring on frontend
- 62 local `backend/pkg/` modules + hub registry support

### Changed

- Rebranded from icFrame to IcFalcon
- Renamed CLI from `icp` to `falcon`, config `falcon.yaml`
- `falcon s:init` installs frontend deps, all shadcn components, and runs static build

### Security

- Expanded `.gitignore` — excludes `node_modules`, `.mops`, `.dfx`, secrets, build output
- Removed vendored `backend/.mops` from version control
