---
name: transferStandard
description: >-
  ICRC transfers — dynamic fee reserve, idempotency, ICRC-2 delegations, and two-row records.
  Use when building TransferService or sending ICP/ICRC from a custodial wallet.
---

# Transfer Standard

## Purpose

Teach agents how to send tokens safely using hub `transfer` + `transaction` pkgs and modern ICRC standards.

## When to use

- `TransferService.send` implementation
- Internal user-to-user transfers
- ICRC-2 approve and transfer_from flows
- Multi-token fee resolution prior to executing swaps

## Packages

```bash
falcon add pkg transfer
falcon add pkg transaction
falcon add pkg icrc1
```

Prerequisite: [`walletStandard`](../walletStandard/SKILL.md) (custodial account).

## Pattern

```
api/v1/Wallet.mo → TransferService → mo:pkg/transfer
                                   → await ledger.icrc1_transfer (service only)
```

```motoko
import Transfer "mo:pkg/transfer/transfer";

// 1. Dynamic fee resolution:
let fee = await ledger.icrc1_fee();

// 2. Pre-flight balance check:
if (balance < req.amount + fee) {
  return #err("Insufficient funds: balance must cover amount + fee");
};

// 3. Idempotency check (TxStore) — see transactionStandard
// 4. Validate + build (pure)
switch (Transfer.validateRequest(req, balance, fee)) {
  case (?msg) { return #err(msg) };
  case (null) {};
};
let args = Transfer.buildTransferArgs(req, fee);

// 5. Await ledger ONCE in service
let raw = await ledger.icrc1_transfer(args);
let result = Transfer.mapResult(raw);

// 6. Two rows for internal transfers
let rows = Transfer.recordsForTransfer(req, result, fee, ?recipient, Time.now());
```

### ICRC-2 Delegated Transfer (`transfer_from`)

When pulling funds previously approved by a user or escrow account:

```motoko
let transferFromArgs : ICRC2.TransferFromArgs = {
  spender_subaccount = canisterSubaccount;
  from = userIcrcAccount;
  to = destinationAccount;
  amount = amount;
  fee = ?fee;
  memo = null;
  created_at_time = ?Time.now();
};
let transferFromRes = await ledger.icrc2_transfer_from(transferFromArgs);
```

## Rules

- Idempotency in **TransferService** — check `transferId` in TxStore before await
- Write `#pending` tx row **before** `icrc1_transfer` await
- Internal transfer = **two** `TxRecord` rows (sender + recipient)
- Always query `icrc1_fee()` dynamically — never hardcode 10_000 for non-ICP tokens
- Guard self-transfers
- Test with a **second identity**
- AI may propose transfers; human confirms before execute (Phase 2)

Fee, failure, and double-credit hazards: read
[`../../motokoStandard/ledgerIntegrationStandard/SKILL.md`](../../motokoStandard/ledgerIntegrationStandard/SKILL.md).

## Related

| Task | Skill |
|---|---|
| Wallet setup | [`../walletStandard/SKILL.md`](../walletStandard/SKILL.md) |
| Token swaps & AMM | [`../swapStandard/SKILL.md`](../swapStandard/SKILL.md) |
| Tx records | [`../transactionStandard/SKILL.md`](../transactionStandard/SKILL.md) |
| Auth | [`../../motokoStandard/authorizationStandard/SKILL.md`](../../motokoStandard/authorizationStandard/SKILL.md) |
