---
name: deployStandard
description: >-
  Canister deployment lifecycle, cycles funding economics, and friendly out-of-cycles triage
  with terminal QR codes. Use when deploying canisters, debugging cycle exhaustion, or funding.
---

# Deploy Standard

Standardized lifecycle, cycle economics, and automated funding triage for IcFalcon deployments.

## Purpose

Provide deterministic deployment workflows across local replica and mainnet environments, ensuring that cycle exhaustion is detected cleanly and resolved with user-friendly instructions and terminal QR codes rather than cryptic error traces.

## When to use

- Deploying backend or frontend canisters (`falcon b:deploy`, `falcon f:deploy`)
- Diagnosing deployment errors (`Canister is out of cycles`, `insufficient cycles`)
- Instructing users or AI agents on funding an identity with ICP to mint cycles
- Generating mobile-scannable terminal QR codes for wallet top-ups

## Related

- Local deployment: [`guideStandard/localDeployStandard`](../localDeployStandard/SKILL.md)
- Production deployment: [`guideStandard/productionDeployStandard`](../productionDeployStandard/SKILL.md)
- Cycle cost reference: [`cycleCostStandard`](../../cycleCostStandard/SKILL.md)
- CLI command reference: [`commandStandard`](../../commandStandard/SKILL.md)

---

## Deployment Environments

| Environment | Flag | Cycles Needed? | Ledger Target |
|---|---|---|---|
| **Local Replica** | `--local` | No (mocked/infinite) | Local ledger |
| **Mainnet** | *(no flag)* | **Yes (real cycles)** | Mainnet NNS ledger |

---

## Cycle Economics for Canisters

On the Internet Computer, 1 XDR is pegged to **1 Trillion cycles ($1.30 USD)**:
- **Canister Creation Fee:** ~100 Billion cycles minimum (1.5T - 2.0T recommended for reserve).
- **Execution & Storage:** 1 GiB/year is ~127 Billion cycles ($0.165/year).
- **Recommended Initial Reserve:** **2.0 to 5.0 Trillion cycles** (~0.20 to 0.50 ICP depending on market rate).

---

## Handling Deployment Cycle Failures

When a deployment fails with errors such as:
- `Failed to create canister ... Canister is out of cycles`
- `The replica returned an HTTP Error: ... Canister has insufficient cycles to perform this call`
- `Caller does not have enough cycles`

### AI & CLI Behavior Rules

1. **NEVER** output raw hex dumps or cryptic error traces without explanation.
2. **NEVER** attempt destructive reinstalls (`--mode=reinstall` or `--clean`) to bypass cycles issues.
3. **ALWAYS** guide the user with a friendly, structured funding prompt.

### Automated Funding Command

Run:
```bash
falcon y:fund [amount_in_icp]
```
*(Default suggested amount is 0.50 ICP, which mints ~5 Trillion cycles).*

### The Minimal & Formal Funding Flow

When `falcon y:fund` runs, it outputs clean text and a high-contrast UTF-8 QR code without emojis:

```
==================================================================
CYCLES FUNDING REQUIRED
==================================================================

Identity:        <identity_name>
Required:        ~5.00 T Cycles
Suggested:       0.50 ICP

Account ID (Recommended):
  <64_character_hex_account_id>

Principal ID:
  <principal_id>

Scan QR Code:
  [High-contrast UTF-8 QR code rendered in terminal]
==================================================================

I have sent [y/N]: 
```

### Auto-Deploy on User Confirmation
- If the user responds with `y`, `yes`, or presses enter after confirming: the CLI automatically initiates the build and deployment pipeline (`falcon b:deploy`).
- If `n` or cancelled: the process pauses cleanly without leaving dangling tasks.

---

## Pre-flight Deploy Checklist

Before executing any mainnet deployment:
- [ ] Confirm identity: `falcon whoami`
- [ ] Check cycles balance: `falcon y:bal`
- [ ] Check canister status: `falcon c:status app`
- [ ] Ensure migration hooks are intact if modifying persistent records
- [ ] If cycles are low (<1T), run `falcon y:fund` before deploying
