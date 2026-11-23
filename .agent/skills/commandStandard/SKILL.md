---
name: commandStandard
description: "Comprehensive CLI command reference and use case mapping for the falcon ops tool — setup, auditing, testing, scaffolding, snapshots, cycles, packages, and production shipping."
---

# Falcon CLI Command Standard (`commandStandard`)

Standard reference and workflow mapping for the unified `falcon` developer operations tool.

---

## Purpose

The `falcon` CLI is the single developer control interface for IcFalcon. It automates repetitive operational workflows, enforces strict architectural checks before deployments, manages on-chain snapshots, and provides sub-second shortcuts for local and mainnet tasks.

---

## When to use

- Bootstrapping a new project or starting/stopping local IC replicas
- Auditing Motoko code for formatting, file size, and 4-tier layering rules
- Scaffolding new full-stack features (`falcon m:f`) or micro-canisters (`falcon m:c`)
- Managing hub packages (`falcon add pkg <name>`)
- Executing unit tests, Candid calls, and health pings
- Taking on-chain state snapshots and rolling back upgrades
- Running production preflight checks (`falcon p:check`) and shipping to mainnet

---

## 1. Network Execution Model

By default, all `falcon` commands target **mainnet** (`--network ic`) for production safety and realism:

```bash
falcon <command> [args...]            # Targets Mainnet
falcon <command> --local [args...]    # Targets Local Replica
```

Installation (once per machine):
```bash
./ops/install.sh                      # Symlinks CLI to ~/.local/bin/falcon
```

---

## 2. Command Decision Matrix by Use Case

| I want to... | Canonical Command | Fast Alias | Target Network |
|---|---|---|---|
| Initialize a fresh project & start dev server | `falcon setup:init` | `falcon s:init` | Local / Host |
| Start the local IC background replica | `falcon replica:start` | `falcon r:start` | Local |
| Stop the local IC replica | `falcon replica:stop` | `falcon r:stop` | Local |
| Audit Motoko code style, layering & syntax | `falcon audit:motoko` | `falcon a:c:m` | Any |
| Auto-fix EOF newlines & whitespace | `falcon audit:motoko --fix` | `falcon a:c:m -f` | Any |
| Run all Motoko unit tests + compiler check | `falcon backend:test` | `falcon b:test --local` | Local |
| Scaffold full-stack feature (Map storage) | `falcon make:feature <Name>` | `falcon m:f <Name>` | Host |
| Scaffold full-stack feature (FalconORM 3NF) | `falcon make:feature <Name> --orm` | `falcon m:f <Name> --orm` | Host |
| Scaffold micro-canister with Universe mesh | `falcon make:canister <Name>` | `falcon m:c <Name>` | Host |
| Install package from `icp-hub` registry | `falcon pkg:add <name>` | `falcon add pkg <name>` | Host |
| List all 65+ registry packages | `falcon pkg:list` | `falcon p:list` | Remote |
| List installed packages & lockfile | `falcon pkg:installed` | `falcon p:ls` | Local |
| Validate AI agent skills & links | `falcon skills:validate` | `falcon sk:validate` | Host |
| Create on-chain canister state snapshot | `falcon canister:snapshot:create` | `falcon c:sn:create` / `b:snapshot` | Local / IC |
| List on-chain canister snapshots | `falcon canister:snapshot:list` | `falcon c:sn:list` | Local / IC |
| Rollback canister to snapshot ID | `falcon canister:snapshot:load <id>` | `falcon c:sn:load <id>` | Local / IC |
| Fetch execution logs from canister | `falcon canister:logs` | `falcon c:logs` | Local / IC |
| Check cycles balance of canister | `falcon cycles:balance` | `falcon y:bal` | Local / IC |
| Query registered user count | `falcon users:count` | `falcon u:count` | Local / IC |
| Start Next.js frontend dev server | `falcon frontend:dev` | `falcon f:dev` | Local |
| Build static frontend asset export | `falcon frontend:build` | `falcon f:build` | Host |
| Run full preflight verification | `falcon prod:check` | `falcon p:check --local` | Local / IC |
| Deploy to production (backend + frontend) | `falcon prod:ship` | `falcon p:ship` | Mainnet |

---

## 3. Command Category Catalog & Use Cases

### Code Quality & Layering (`audit`)

Enforces Python `black`-style formatting, file size ceilings (<300 lines), and 4-tier layer isolation:

```bash
falcon a:c:m                 # Audits backend/src/*.mo
falcon a:c:m --fix           # Auto-fixes whitespace, CRLF, and missing EOF newlines
falcon a:c:m --all           # Audits backend/src AND backend/pkg
falcon a:c:m --strict        # Treats warnings as errors (ideal for CI pipelines)
```

### Scaffolding & Code Generation (`make`)

Generates complete domain modules in seconds, pre-wired into `main.mo` and frontend:

```bash
# 1. Standard feature (CRUD Map storage)
falcon m:f Product

# 2. FalconORM 3NF relational feature (auto-indexed Table, foreign keys & query builder)
falcon m:f Order --orm

# 3. Independent micro-canister (wired to Falcon Universe event mesh)
falcon m:c Trade
```

### Package Management (`pkg`)

Direct access to the `icp-hub` ecosystem:

```bash
falcon p:list                # Explore available hub packages
falcon add pkg wallet        # Installs subaccount, ledger, icrc1, and wallet modules
falcon add pkg openai        # Installs OpenAI chat completion helpers
falcon p:ls                  # Inspect backend/icp.pkg lockfile
falcon p:push my-package     # Publishes local module to the central registry
```

### Canister Operations & Method Calls (`canister`)

Query and invoke canister methods without verbose dfx syntax:

```bash
falcon c:ping --local                               # Quick health check
falcon c:status --local                             # Memory, status, and controller query
falcon c:call status --local                        # Call Candid query method
falcon c:call createItem '("MacBook", 1500)' --update --local # Call Candid update method
```

### On-Chain Snapshots & Disaster Recovery (`snapshot`)

Freeze, backup, and restore full canister state (compiled Wasm, heap, stable memory, and chunks):

```bash
# Take a safety snapshot before upgrading
falcon c:sn:create
falcon c:sn:list
# If upgrade fails or data is corrupted, instant 1-command rollback:
falcon c:sn:load <snapshot-id>
```

### Preflight Verification & Shipping (`prod`)

Mandatory gate before merging or deploying:

```bash
# 1. Verification: skills validation + Motoko code audit + canister compile + frontend export
falcon p:check --local

# 2. Mainnet Deployment: safety confirmation prompt + upgrade deploy + frontend export
falcon p:ship
```

---

## 4. Invariants & Rules

1. **Never Ship Without Preflight**: Always run `falcon p:check --local` before committing or running `falcon p:ship`.
2. **Snapshot Before Mainnet Deploy**: Take `falcon c:sn:create` before upgrading mainnet canisters with state.
3. **Use Short Aliases**: Prefer `falcon a:c:m`, `falcon b:test`, and `falcon p:check` for velocity.
4. **Flag Positioning**: Operational flags like `--local`, `--fix`, or `--orm` can be passed anywhere in the command arguments.

---

## Related

| Skill | Path |
|---|---|
| Project Setup Guide | [`guideStandard/projectSetupStandard/SKILL.md`](../guideStandard/projectSetupStandard/SKILL.md) |
| Local Deployment | [`guideStandard/localDeployStandard/SKILL.md`](../guideStandard/localDeployStandard/SKILL.md) |
| Production Deployment | [`guideStandard/productionDeployStandard/SKILL.md`](../guideStandard/productionDeployStandard/SKILL.md) |
| Motoko Coding Standard | [`codingStandard/SKILL.md`](../codingStandard/SKILL.md) |
| Package Ecosystem | [`packageStandard/SKILL.md`](../packageStandard/SKILL.md) |
| FalconORM 3NF Engine | [`ormStandard/SKILL.md`](../ormStandard/SKILL.md) |
