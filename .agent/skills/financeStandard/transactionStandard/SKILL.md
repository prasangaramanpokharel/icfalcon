---
name: transactionStandard
description: >-
  Transaction history, deposit sync index, and double-entry swap audit logs.
  Use when recording tx rows, building history UI, or debugging reconciliation.
---

# Transaction Standard

## Purpose

Teach agents how to index ledger activity, token transfers, and multi-token swaps — not replace the ledger.

## When to use

- `TransactionRepository` / `TxStore` design
- History API (`txHistory` query)
- Multi-token swap double-entry bookkeeping
- Deposit sync reconciliation and ICRC-3 block audits

## Packages

```bash
falcon add pkg transaction ledger
```

## Pattern

```
TransferService → Transfer.recordsForTransfer → Transaction.insert
DepositService  → sync formula → Transaction.insert (#deposit)
SwapService     → Swap.recordsForSwap → Transaction.insert (#swapOut + #swapIn)
api/v1/Wallet.mo → query txHistory (no ledger calls)
```

```motoko
import Transaction "mo:pkg/transaction/transaction";

Transaction.insert(store, {
  id = transferId;
  user = caller;
  kind = #transferOut;
  amount; fee;
  token = account.token;
  status = #pending;  // before ledger await
  createdAt = Time.now();
  // ...
});
```

### Double-Entry Trade Bookkeeping

When recording a token swap, write two atomic linked records:

```motoko
// Outgoing debit row:
Transaction.insert(store, {
  id = swapId # "-out";
  user = caller;
  kind = #swapOut;
  amount = amountIn;
  fee = sourceFee;
  token = tokenIn;
  status = #completed;
  createdAt = Time.now();
});

// Incoming credit row:
Transaction.insert(store, {
  id = swapId # "-in";
  user = caller;
  kind = #swapIn;
  amount = amountOut;
  fee = 0;
  token = tokenOut;
  status = #completed;
  createdAt = Time.now();
});
```

## Rules

- TxStore is an **index** — never sum rows as spendable balance
- `#pending` before await → `#completed` with `blockIndex` or `#failed` + verify ledger
- `TokenRef` on every row for multi-token apps
- Always link trade pairs using a deterministic `swapId`
- Verify block indices against ICRC-3 block audit feeds where available
- At scale: paginate in `repositories/`, use `mo:pkg/indexer` — not raw pkg scan
- Deposit sync formula and double-credit hazards: read
  [`../../motokoStandard/ledgerIntegrationStandard/SKILL.md`](../../motokoStandard/ledgerIntegrationStandard/SKILL.md)

## Related

| Task | Skill |
|---|---|
| Transfers | [`../transferStandard/SKILL.md`](../transferStandard/SKILL.md) |
| Token swaps & AMM | [`../swapStandard/SKILL.md`](../swapStandard/SKILL.md) |
| Wallet | [`../walletStandard/SKILL.md`](../walletStandard/SKILL.md) |
