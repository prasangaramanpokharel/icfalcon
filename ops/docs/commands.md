# Commands Reference

Everything runs via the global CLI: `falcon <command> [--local] [args]`

- **Mainnet by default**: Commands deploy and query mainnet without flags.
- **Local replica**: Append `--local` for local development replica.
- **Install once**: `./ops/install.sh` (symlinks `falcon` to `~/.local/bin/falcon`).

---

## Quick Reference Table

| Category | Command | Alias | What It Does |
|---|---|---|---|
| **Setup** | `falcon setup:init` | `falcon s:init` | Install dependencies, shadcn components, build, start dev server |
| | `falcon replica:start` | `falcon r:start` | Start local IC replica (`dfx start --background`) |
| | `falcon replica:stop` | `falcon r:stop` | Stop local IC replica |
| **Audit** | `falcon audit:motoko` | `falcon a:c:m` / `falcon audit code:motoko` | Audit Motoko code style, layering & syntax (black-style) |
| | `falcon audit code:motoko --fix` | `falcon a:c:m -f` | Auto-fix whitespace, CRLF line endings, and EOF newlines |
| | `falcon audit code:motoko --all` | `falcon a:c:m -a` | Audit both `backend/src` and `backend/pkg` |
| | `falcon audit code:motoko --strict`| `falcon a:c:m -s` | Strict mode (treat warnings as errors for CI) |
| **Backend** | `falcon backend:test` | `falcon b:test` | Run Motoko unit tests + build canister |
| | `falcon backend:build` | `falcon b:build` | Compile Motoko canister Wasm |
| | `falcon backend:deploy` | `falcon b:deploy` | Build and deploy canister with upgrade mode |
| | `falcon backend:hash` | `falcon b:hash` | Show module hash and canister info |
| | `falcon backend:logs` | `falcon b:logs` | View canister execution logs |
| **Production** | `falcon prod:check` | `falcon p:check` | Validate skills + audit Motoko code + build backend + frontend |
| | `falcon prod:ship` | `falcon p:ship` | Deploy backend to network + build frontend |
| **Skills** | `falcon skills:validate` | `falcon sk:validate` | Validate AI skills structure, frontmatter & links |
| **Packages** | `falcon pkg:list` | `falcon p:list` | List all available packages in the `icp-hub` registry |
| | `falcon pkg:add <name>` | `falcon add pkg <name>` / `falcon a:p <name>` | Install a package from `icp-hub` into `backend/pkg/` |
| | `falcon pkg:installed` | `falcon p:ls` | List installed packages and lockfile status |
| | `falcon pkg:push <name>` | `falcon p:push` | Publish local package to registry |
| **Scaffold** | `falcon make:feature <Name>` | `falcon m:f <Name>` | Scaffold full domain feature (backend + frontend) |
| | `falcon make:canister <Name>` | `falcon m:c <Name>` | Scaffold standalone micro-canister with Falcon Universe mesh |
| **Canister** | `falcon canister:status` | `falcon c:status` | Query canister operational status and memory |
| | `falcon canister:ping` | `falcon c:ping` | Run health ping query |
| | `falcon canister:id` | `falcon c:id` | Show canister ID |
| | `falcon canister:call <method>` | `falcon c:call` | Call canister Candid method |
| **Identity** | `falcon identity:whoami` | `falcon whoami` / `id:whoami` | Show current active identity |
| | `falcon identity:principal` | `falcon id:p` / `id:principal` | Show principal ID of current identity |
| | `falcon identity:address` | `falcon id:addr` / `id:address` | Show ledger account ID |
| | `falcon identity:list` | `falcon id:ls` / `id:list` | List all identities |
| | `falcon identity:use <name>` | `falcon id:use <name>` | Switch active identity |
| | `falcon identity:new <name>` | `falcon id:new <name>` | Create a new identity |
| | `falcon identity:export` | `falcon id:export` | Export identity PEM file |
| | `falcon identity:import` | `falcon id:import` | Import identity PEM file |
| **Token (ICP/ICRC)** | `falcon token:balance [token]` | `falcon t:bal` / `t:balance` | Check ledger token balance (default: icp) |
| | `falcon token:transfer <dest> <amt>` | `falcon t:send` / `t:transfer` | Transfer tokens to destination |
| | `falcon token:approve <spender> <amt>` | `falcon t:approve` | ICRC-2 token approval |
| | `falcon token:allowance <spender>` | `falcon t:allowance` | ICRC-2 allowance check |
| **Cycles** | `falcon cycles:balance` | `falcon y:bal` | Check canister cycles balance |
| | `falcon cycles:mint <amount>` | `falcon y:mint` | Convert ICP tokens to cycles |
| | `falcon cycles:transfer <dest>` | `falcon y:send` / `y:transfer` | Transfer cycles to canister or principal |
| | `falcon cycles:topup [amount]` | `falcon y:topup` / `c:topup` | Top up canister with cycles |
| | `falcon cycles:address` | `falcon y:addr` | Display cycles ledger account ID |
| **Canister** | `falcon canister:status` | `falcon c:status` | Query canister operational status and memory |
| | `falcon canister:ping` | `falcon c:ping` | Run health ping query |
| | `falcon canister:id` | `falcon c:id` | Show canister ID |
| | `falcon canister:create` | `falcon c:create` | Create canister on network |
| | `falcon canister:start` | `falcon c:start` | Start canister |
| | `falcon canister:stop` | `falcon c:stop` | Stop canister |
| | `falcon canister:delete` | `falcon c:delete` / `c:del` | Delete canister |
| | `falcon canister:metadata` | `falcon c:metadata` / `c:meta` | Read Wasm metadata section |
| | `falcon canister:settings` | `falcon c:settings` | Manage canister controllers and settings |
| | `falcon canister:sync` | `falcon c:sync` | Sync canister bindings and assets |
| | `falcon canister:call <method>` | `falcon c:call` | Call canister Candid method |
| **Network & Project** | `falcon network:list` | `falcon net:ls` / `net:list` | List networks |
| | `falcon network:ping` | `falcon net:ping` / `r:ping` | Ping local network |
| | `falcon network:status` | `falcon net:status` / `r:status` | Get network status |
| | `falcon project:show` | `falcon prj:show` / `p:show` | Show project configuration (`icp.yaml`) |
| | `falcon env:list` | `falcon env:ls` / `env:list` | List environments |
| **Users** | `falcon users:count` | `falcon u:count` | Status query of registered users and counters |
| **Frontend** | `falcon frontend:dev` | `falcon f:dev` | Launch Next.js local development server |
| **Completions** | `falcon completions [shell]` | `falcon completions` | Generate shell completions (bash/zsh) |
| | `falcon frontend:build` | `falcon f:build` | Static export build for asset canister hosting |
| | `falcon frontend:production` | `falcon f:production` / `f:prod` | Serve static production build (`npx serve@latest out`) |

---

## Detailed Command Guides

### 1. Code Audit & Linting (`falcon audit code:motoko`)

Brings Python `black` and `flake8` consistency to Motoko.

```bash
falcon audit code:motoko            # audit backend/src
falcon a:c:m                        # short alias
falcon audit code:motoko --fix      # auto-fix formatting issues
falcon audit code:motoko --strict   # fail on warnings (CI mode)
falcon audit code:motoko --all      # audit src and pkg folders
```

**Checks enforced:**
- Formatting: No trailing whitespace, no Windows CRLF (`\r`), single newline at EOF.
- Layering: `api/` must NEVER import `storage/` directly. `validators/` must be pure.
- Deprecations: Strict ban on legacy `mo:base` (enforces `mo:core`).
- File size: Warning when any file exceeds 300 lines (prompting domain module splits).
- Safety: `persistent actor` in `main.mo`, no `Debug.trap` in public/shared endpoints.
- Compiler check: Direct `moc --check` syntax and type validation.

---

### 2. Package Management (`icp-hub`)

Install reusable, audited Motoko modules with zero boilerplate:

```bash
# List all 65+ packages
falcon p:list

# Install packages
falcon add pkg universe    # Multi-canister event mesh ("Kafka for Motoko")
falcon add pkg wallet      # Custodial wallet & balance manager
falcon add pkg transfer    # ICRC transfer helpers
falcon add pkg openai      # AI chat & payload builder
falcon add pkg stripe      # Stripe checkout integration

# List installed packages
falcon p:ls
```

Lockfile is tracked in `backend/icp.pkg`.

---

### 3. Scaffold Full Feature (`falcon m:f <Name> [--orm]`)

Scaffolds a complete Laravel-style full-stack feature in seconds:

```bash
falcon m:f Order        # Standard Map storage
falcon m:f Order --orm  # FalconORM 3NF table with auto-indexing & query builder
```

**Automatically creates and wires:**
- Backend:
  - `backend/src/types.mo` (record types and `ApiResult`)
  - `backend/src/storage/OrderStorage.mo` (Map or FalconORM Table)
  - `backend/src/repositories/OrderRepository.mo` (CRUD or ORM query repository)
  - `backend/src/validators/OrderValidator.mo`
  - `backend/src/services/OrderService.mo`
  - `backend/src/api/v1/Order.mo`
  - Wires mixin and storage into `backend/src/main.mo`
- Frontend:
  - `frontend/src/services/orderService.ts`
  - `frontend/src/components/features/OrderPanel.tsx`

---

### 4. Scaffold Micro-Canister (`falcon m:c <Name>`)

Scaffolds an independent micro-canister wired into the Falcon Universe pub/sub event mesh:

```bash
falcon m:c Trade
# or: falcon make:canister Trade
```

**Automatically creates and wires:**
- `backend/canisters/trade/main.mo`: Persistent actor configured with a Universe node, 1,000-event deduplication window, transactional outbox, and idempotent inbox.
- `backend/canisters/trade/types.mo`: Canister domain and event types.
- `backend/dfx.json`: Registers the new canister target automatically.
- `frontend/services/trade/client.ts`: Typed `@icp-sdk/core` client with offline-first error handling and dynamic canister ID resolution.

**Build and deploy the micro-canister:**
```bash
falcon b:build --canister trade --local
falcon b:deploy --canister trade --local
falcon c:ping --canister trade --local
falcon c:status --canister trade --local
```

---

### 5. Pre-Flight Checks & Deployment

```bash
# Complete pre-flight validation (local)
falcon p:check --local

# Complete pre-flight validation (mainnet)
falcon p:check

# Deploy to mainnet (prompts TTY confirmation for safety)
falcon b:deploy
falcon p:ship
```

`falcon p:check` runs four automated stages:
1. `validate-skills.sh`: Validates all AI agent skills, frontmatter, and links.
2. `validate-code.sh`: Runs the Motoko code audit and linter.
3. Canister build: Compiles Motoko wasm with persistent memory.
4. Next.js export: Generates optimized static HTML/JS for asset canister.

---

### 5. Canister Inter-Communication

```bash
# Health check
falcon c:ping --local

# Call query method
falcon c:call status --local

# Call update method with Candid arguments
falcon c:call createProduct '("Laptop", 1200)' --update --local
```

---

### 6. Canister Snapshots, Rollbacks & Logs

Manage on-chain state snapshots and execution logs natively:

```bash
# Create an on-chain state snapshot (captures Wasm, heap & stable memory)
falcon c:sn:create --local
# or for mainnet: falcon c:sn:create

# List on-chain snapshots for a canister
falcon c:sn:list --local

# Restore / rollback to a previous snapshot
falcon c:sn:load <snapshot-id> --local

# Fetch system ring-buffer logs
falcon c:logs --local
```

---

## Adding Custom Commands

Define custom tasks in [`falcon.yaml`](../falcon.yaml):

```yaml
commands:
  my:task:
    confirm: false
    steps:
      - dfx canister call {{canister}} myMethod --query {{network}}

aliases:
  m:t: my:task
```

For scripts accepting arguments, use `script: ops/scripts/my-script.sh`.
Template available at [ops/templates/command.example.sh](../templates/command.example.sh).

