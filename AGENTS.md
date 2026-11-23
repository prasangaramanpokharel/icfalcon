# IcFalcon

Internet Computer app framework: Motoko backend, Next.js frontend, `falcon` ops CLI.

## Quick start

```bash
./ops/install.sh
falcon s:init
```

## Scaffold a module

```bash
falcon m:f Order
falcon b:test --local
falcon b:deploy --local
```

## Packages (icp-hub)

```bash
falcon p:list
falcon add pkg wallet
falcon a:p dao
falcon p:ls
```

Hub: https://github.com/prasangapokharel/icp-hub

## Layout

| Path | Role |
|---|---|
| `backend/` | Motoko canister + `pkg/` |
| `frontend/` | Next.js + Internet Identity |
| `.agent/` | AI skills — start at [`.agent/SKILLS.md`](.agent/SKILLS.md) |
| `ops/` | CLI, templates, docs |
| `falcon.yaml` | Command config |
| `hub/` | Package registry (gitignored — separate repo) |

## Agent skills map

Read [`.agent/SKILLS.md`](.agent/SKILLS.md) first — layered router (Foundation → Money → Extensions → Apps).

**Naming:** every folder under `.agent/skills/` ends with `Standard` (categories and leaf skills), e.g. `financeStandard/walletStandard`. YAML `name:` must match the folder name.

**Validate after skill edits:**

```bash
falcon sk:validate          # skills structure + links
falcon audit code:motoko    # Motoko code style, layering & syntax (or: falcon a:c:m)
falcon p:check --local      # skills + code audit + backend + frontend build
```

### Core tasks

| Task | Skill path |
|---|---|
| CLI commands & ops | `.agent/skills/commandStandard/SKILL.md` |
| New feature | `.agent/skills/integrationStandard/SKILL.md` |
| Scaffold CLI | `falcon m:f <Name>` |
| Code audit / linter | `falcon audit code:motoko` / `falcon a:c:m` |
| Layer rules | `.agent/skills/layeringStandard/SKILL.md` |
| Hub packages / modules | `.agent/skills/packageStandard/SKILL.md` |
| Multi-canister mesh | `.agent/skills/falconUniverseStandard/SKILL.md` |
| ORM / 3NF models | `.agent/skills/ormStandard/SKILL.md` |
| Code style | `.agent/skills/codingStandard/SKILL.md` |
| Errors | `.agent/skills/errorHandlingStandard/SKILL.md` |
| Migrations | `.agent/skills/migrationStandard/SKILL.md` |
| Tests | `.agent/skills/testingStandard/SKILL.md` |
| Endpoints | `.agent/skills/endpointsStandard/SKILL.md` |
| Write Motoko | `.agent/skills/motokoStandard/writingMotokoStandard/SKILL.md` |
| Project setup | `.agent/skills/guideStandard/projectSetupStandard/SKILL.md` |
| Local deploy | `.agent/skills/guideStandard/localDeployStandard/SKILL.md` |
| Production deploy | `.agent/skills/guideStandard/productionDeployStandard/SKILL.md` |
| ICPay controllers | `.agent/skills/icpayControllerStandard/SKILL.md` |
| Custom domains / SSL | `.agent/skills/domainStandard/SKILL.md` |
| Cycle costs & pricing | `.agent/skills/cycleCostStandard/SKILL.md` |
| Release | `.agent/skills/guideStandard/releaseStandard/SKILL.md` |
| Deploy reference | `.agent/skills/motokoStandard/deployGuideStandard/SKILL.md` |
| Frontend | `.agent/skills/frontendStandard/SKILL.md` |
| @icp-sdk | `.agent/skills/icpsdkStandard/SKILL.md` |
| Versions & dependencies | `.agent/skills/versionStandard/SKILL.md` |
| **Wallet demo (Phase 3)** | `/wallet` — [`docs/phase/3/PLAN.md`](docs/phase/3/PLAN.md) |
| Logo / brand | `.agent/skills/logoStandard/SKILL.md` |
| II auth | `.agent/skills/motokoStandard/internetIdentityAuthStandard/SKILL.md` |
| RBAC / auth | `.agent/skills/motokoStandard/authorizationStandard/SKILL.md` |
| HTTP outcalls | `.agent/skills/motokoStandard/httpOutcallsStandard/SKILL.md` |
| Threshold signatures (Solana/Bitcoin/EVM) | `.agent/skills/motokoStandard/thresholdSignaturesStandard/SKILL.md` |
| EVM RPC (Ethereum/Base/Arbitrum) | `.agent/skills/extensionsStandard/evmRpcStandard/SKILL.md` |
| vetKeys (on-chain encryption) | `.agent/skills/extensionsStandard/vetKeysStandard/SKILL.md` |
| Extensions (OpenAI, Stripe, email, …) | [`.agent/SKILLS.md`](.agent/SKILLS.md) → Extensions |
| Connectors (Slack, Gmail, Calendar) | [`.agent/SKILLS.md`](.agent/SKILLS.md) → Connectors |

### Finance standards (`financeStandard/`)

Hub money layer for Phase 1. **Hazards only** (fees, double-credit, address formats): [`motokoStandard/ledgerIntegrationStandard`](.agent/skills/motokoStandard/ledgerIntegrationStandard/SKILL.md). **Composition patterns** below.

| What | When to use | Skill | Hub packages |
|---|---|---|---|
| **Wallet** — derive accounts, deposit addresses, balance reads | New wallet feature, deposit UI, multi-token (ICP / ckBTC) | [`walletStandard`](.agent/skills/financeStandard/walletStandard/SKILL.md) | `subaccount`, `ledger`, `icrc1`, `wallet` |
| **Transfer** — send ICRC, fee reserve, idempotency | `TransferService.send`, user-to-user sends | [`transferStandard`](.agent/skills/financeStandard/transferStandard/SKILL.md) | `transfer`, `transaction`, `icrc1` |
| **Transaction** — history index, deposit sync | `TxStore`, history API, reconciliation | [`transactionStandard`](.agent/skills/financeStandard/transactionStandard/SKILL.md) | `transaction` |

**Architecture rules (all finance skills):**

- Hub pkgs = pure logic; only `services/` awaits the ledger
- `amount + fee <= balance` before transfer
- Two tx rows per internal transfer
- `subaccount.fromPrincipal` only — never hand-roll
- Layering: `api → services → repositories → storage`

```bash
falcon add pkg wallet      # pulls subaccount, ledger, icrc1, wallet
falcon add pkg transfer
falcon add pkg transaction
```

Reference implementation (Phase 3): [docs/phase/3/PLAN.md](docs/phase/3/PLAN.md)

### Skill folders (camelCase, `*Standard` suffix)

```
.agent/skills/
├── commandStandard/
├── codingStandard/
├── errorHandlingStandard/
├── integrationStandard/
├── layeringStandard/
├── migrationStandard/
├── testingStandard/
├── endpointsStandard/
├── frontendStandard/
├── logoStandard/
├── icpayControllerStandard/
├── domainStandard/
├── icpsdkStandard/
├── falconUniverseStandard/
├── ormStandard/
├── cycleCostStandard/
├── versionStandard/
├── extensionsStandard/
│   ├── openAiStandard/
│   ├── objectStorageStandard/
│   ├── stripeStandard/
│   ├── emailStandard/
│   └── …
├── connectorsStandard/
│   ├── slackConnectorStandard/
│   ├── googleMailConnectorStandard/
│   └── googleCalendarConnectorStandard/
├── financeStandard/
│   ├── walletStandard/
│   ├── transferStandard/
│   └── transactionStandard/
├── guideStandard/
│   ├── projectSetupStandard/
│   ├── localDeployStandard/
│   ├── productionDeployStandard/
│   └── releaseStandard/
└── motokoStandard/
    ├── writingMotokoStandard/
    ├── testingMotokoStandard/
    ├── migratingMotokoStandard/
    ├── migrationTroubleshootingStandard/
    ├── httpOutcallsStandard/
    ├── authorizationStandard/
    ├── ledgerIntegrationStandard/
    ├── internetIdentityAuthStandard/
    ├── cyclesAndCostStandard/
    ├── buildAndTestStandard/
    └── deployGuideStandard/
```

## Docs

Read [`ops/docs/`](ops/docs/README.md) for full project and architecture documentation.

| Document | Contents |
|---|---|
| [ops/docs/README.md](ops/docs/README.md) | Documentation index & framework overview |
| [ops/docs/commands.md](ops/docs/commands.md) | Full `falcon` CLI reference & aliases |
| [ops/docs/architecture.md](ops/docs/architecture.md) | 4-tier Motoko architecture & persistent memory |
| [ops/docs/motoko.md](ops/docs/motoko.md) | Motoko 1.6.0 language powers, EOP memory model, and FalconORM guide |
| [ops/docs/universe.md](ops/docs/universe.md) | Falcon Universe multi-canister event mesh ("Kafka for Motoko") |
| [ops/docs/audit.md](ops/docs/audit.md) | Motoko code validator & linter (`falcon audit code:motoko`) |
| [ops/docs/packages.md](ops/docs/packages.md) | `icp-hub` packages (`falcon add pkg`), registry list |
| [ops/docs/finance.md](ops/docs/finance.md) | Money layer: ICPay, subaccounts, ICRC-1/2, custodial wallets |
| [ops/docs/frontend.md](ops/docs/frontend.md) | Next.js frontend with `@icp-sdk/core` & `@icp-sdk/auth` |
| [ops/README.md](ops/README.md) | Ops folder structure & tooling |
| [ops/templates/feature/](ops/templates/feature/) | `falcon m:f` scaffold templates |
| [ops/templates/prompt/saas/](ops/templates/prompt/saas/README.md) | 10 ready-made full-stack SaaS product prompts |

## Safety

- Upgrade only on mainnet
- Mainnet deploy requires TTY confirm
- Never commit `.env`, `*.pem`, `identity.json`
