---
name: restrictionStandard
description: >-
  Strict safety guardrails restricting AI agents from executing destructive canister,
  wasm reset, or database wiping commands without explicit bold human confirmation.
---

# Restriction Standard

Mandatory behavioral safety guardrails for autonomous AI coding agents and CLI automation.

## Purpose

Prevent accidental data loss, state corruption, wasm resets, and canister forfeiture by establishing strict execution boundaries for AI assistants operating on Internet Computer canisters.

## When to use

- AI proposes or executes any canister management, deploy, or database operation
- Upgrading or installing canisters in local or mainnet environments
- Handling dangerous CLI flags (`--mode=reinstall`, `--clean`, `canister delete`)
- Protecting persistent stable memory and FalconORM databases from unauthorized wipes

## Related

- Production deployment: [`guideStandard/productionDeployStandard`](../guideStandard/productionDeployStandard/SKILL.md)
- Safe canister migrations: [`migrationStandard`](../migrationStandard/SKILL.md)
- CLI commands & safety flags: [`commandStandard`](../commandStandard/SKILL.md)
- Error handling patterns: [`errorHandlingStandard`](../errorHandlingStandard/SKILL.md)

---

## Prohibited Destructive Operations

The following commands are classified as **HIGH-RISK / DESTRUCTIVE** and **MUST NEVER** be executed by an AI agent autonomously without explicit human confirmation:

| Operation | Prohibited Commands | Risk & Impact |
|---|---|---|
| **Canister Deletion** | `falcon c:delete`, `icp canister delete`, `dfx canister delete` | Permanent loss of canister ID, cycles, and state |
| **Code Uninstallation** | `falcon c:uninstall`, `canister:uninstall`, `dfx canister uninstall-code` | Wipes wasm module and locks the canister interface |
| **Wasm Reset / Clean** | `falcon b:deploy --clean`, `--mode=reinstall` | **Permanently erases all stable memory, FalconORM tables, and user accounts** |
| **Identity Destruction** | `dfx identity delete`, `icp identity delete`, deleting `.dfx/` or `.icp/` | Irrevocable loss of controller keys, identity anchors, and funds |
| **Database Purges** | Deleting stable partitions, dropping FalconORM tables | Irreversible loss of user ledgers and records |

---

## Mandatory AI Confirmation Protocol

Whenever a task, error recovery, or user prompt leads to an action classified above:

### Step 1: HALT Immediately
Do **NOT** execute the command in the background. Do **NOT** assume consent.

### Step 2: Display Prominent Bold Warning
Format the warning using GitHub-style callouts with bold consequences:

```markdown
> [!CAUTION]
> **CRITICAL ACTION: USER CONFIRMATION REQUIRED**
>
> You are about to execute a **DESTRUCTIVE / IRREVERSIBLE** operation:
> **Command:** `<exact_command_to_run>`
>
> **Consequences:**
> - All stable memory, persisted accounts, and ORM tables will be **permanently wiped**.
> - Canister state cannot be recovered unless an explicit snapshot was created.
> - This action **cannot be undone**.
>
> **To proceed, please reply explicitly with:**
> **CONFIRM EXECUTE**
```

### Step 3: Wait for Explicit Confirmation
The agent must wait until the user explicitly responds with `CONFIRM EXECUTE` (or the specific action name) in the conversation before running the command.

---

## Safe Alternatives Standard

AI agents must always recommend non-destructive alternatives before asking for destructive confirmation:

| Destructive Intent | Safe Alternative | Rationale |
|---|---|---|
| Reinstalling wasm to fix migration bug | Use `upgrade` mode with migration module | Preserves existing data while migrating schema |
| Deleting canister to clean up | Stop canister: `falcon c:stop <canister>` | Can be safely restarted without losing canister ID |
| Resetting local state | Create snapshot first: `falcon snap:create` | Allows instant rollback if needed |
| Updating frontend | Deploy assets canister only (`falcon f:deploy`) | Leaves backend canister and stable memory untouched |
