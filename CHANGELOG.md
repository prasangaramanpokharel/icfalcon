# Changelog

All notable changes to IcFalcon are documented here.

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
- `falconUniverseStandard` skill (`.agents/skills/falconUniverseStandard/SKILL.md`) for event-driven multi-canister architecture ("Kafka for Motoko")
- `pkg/universe` package with transactional outbox, idempotent inbox sliding-window deduplication, and wildcard topic broker
- High-throughput `mo:core/Queue` doubly-linked list backing for event outbox queue
- Timer heartbeat integration (`Timer.setTimer` & `Timer.recurringTimer`) for automatic event flushing
- Published `universe` package to the `icp-hub` registry

## [0.2.0] - 2026-09-24

### Added

- `icpsdkStandard` skill (`.agents/skills/icpsdkStandard/SKILL.md`) covering complete `@icp-sdk/core`, `@icp-sdk/auth`, and `@icp-sdk/signer` ecosystem
- `icpayControllerStandard` skill (`.agents/skills/icpayControllerStandard/SKILL.md`) for managing canister controllers via ICPay (icpay.app)
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
- AI agent skills under `.agents/skills/` (integration, frontend, Motoko, deploy)
- Internet Identity auth wiring on frontend
- 62 local `backend/pkg/` modules + hub registry support

### Changed

- Rebranded from icFrame to IcFalcon
- Renamed CLI from `icp` to `falcon`, config `falcon.yaml`
- `falcon s:init` installs frontend deps, all shadcn components, and runs static build

### Security

- Expanded `.gitignore` — excludes `node_modules`, `.mops`, `.dfx`, secrets, build output
- Removed vendored `backend/.mops` from version control
