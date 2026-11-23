---
name: swapStandard
description: >-
  Multi-token swaps, AMM liquidity integration, pre-flight slippage assertions,
  and ICRC-2 atomic trade flows. Use when building swaps, DEX routers, or trading pairs.
---

# Swap Standard

Standards for decentralized multi-token swaps, liquidity pools, and atomic trade settlements on the Internet Computer.

## Purpose

Standardize multi-token atomic swaps (ICP, ckBTC, ckETH, ckUSDC, ICRC-1/2) with robust pre-flight liquidity depth checks, slippage guarantees, comprehensive fee breakdown, and ICRC-2 delegation flows.

## When to use

- Implementing token swap endpoints (`api/v1/Swap.mo`, `SwapService.mo`)
- Routing trades through AMMs (KongSwap, ICPSwap, or internal pools)
- Enforcing pre-trade validations (slippage bounds, liquidity reserves, deadline)
- Double-entry trade bookkeeping and refund/rollback reconciliation

## Related

- Custodial accounts: [`walletStandard`](../walletStandard/SKILL.md)
- ICRC transfers & dynamic fees: [`transferStandard`](../transferStandard/SKILL.md)
- Trade history indexing: [`transactionStandard`](../transactionStandard/SKILL.md)
- Ledger hazards: [`motokoStandard/ledgerIntegrationStandard`](../../motokoStandard/ledgerIntegrationStandard/SKILL.md)

---

## Token Swap Architecture

```
User / Caller
    │
    ▼
SwapService (backend/src/services/SwapService.mo)
    │  1. getQuote & pre-flight assertions (liquidity, slippage, fees)
    │  2. icrc2_approve on Source Token Ledger (amountIn + sourceFee)
    │  3. call DEX Router / AMM Pool swap()
    │  4. verify destination token transfer & settle
    ▼
TxStore (Double-entry: debit tokenIn, credit tokenOut, net fee)
```

---

## Pre-Flight Validations (Mandatory)

Before executing any swap on-chain, `SwapService` must assert five safety constraints:

### 1. Liquidity Depth & Pool Reserve Check
Verify the target liquidity pool has sufficient depth to prevent catastrophic price impact:
```motoko
if (poolReserveIn == 0 or poolReserveOut == 0) {
  return #err(#InsufficientLiquidity);
};
let priceImpact : Float = calculatePriceImpact(amountIn, poolReserveIn, poolReserveOut);
if (priceImpact > maxAllowedPriceImpact) { // e.g. 0.05 (5%)
  return #err(#PriceImpactTooHigh(priceImpact));
};
```

### 2. Slippage & Minimum Output Assertion
Never execute market swaps with open-ended outputs. Compute `minAmountOut`:
$$\text{minAmountOut} = \text{expectedOut} \times (1 - \text{slippageTolerance})$$
Reject any quote where simulated output fails to meet caller minimum.

### 3. Comprehensive Fee Accounting
Account for all three fee components prior to initiating the trade:
$$\text{Total Fee} = \text{Fee}_{\text{source\_ledger}} + \text{Fee}_{\text{protocol\_swap}} + \text{Fee}_{\text{dest\_ledger}}$$

Verify caller balance satisfies:
```motoko
assert(callerBalance >= amountIn + sourceLedgerFee);
```

### 4. Deadline Timestamp (MEV / Front-Running Protection)
Set an explicit block expiration (e.g. current IC time + 3 minutes). If block execution is delayed past `deadline`, the DEX contract traps or refunds without executing at stale prices.

---

## Atomic ICRC-2 Swap Flow

### Step 1: Pre-flight Quote
```motoko
public func getQuote(tokenIn : Token, tokenOut : Token, amountIn : Nat) : async Result.Result<Quote, SwapError>
```

### Step 2: ICRC-2 Approval
Approve the AMM router canister as an authorized spender for `amountIn + sourceLedgerFee`:
```motoko
let approveArgs : ICRC2.ApproveArgs = {
  spender = dexRouterPrincipal;
  amount = amountIn + sourceLedgerFee;
  expected_allowance = null;
  expires_at = ?(Time.now() + 180_000_000_000); // 3 min
  fee = ?sourceLedgerFee;
  memo = null;
  from_subaccount = userSubaccount;
  created_at_time = ?Time.now();
};
let approveRes = await tokenInLedger.icrc2_approve(approveArgs);
```

### Step 3: Swap Execution
Invoke the DEX swap endpoint with `minAmountOut` and `deadline`:
```motoko
let swapRes = await dexRouter.swap({
  tokenIn = tokenIn.canisterId;
  tokenOut = tokenOut.canisterId;
  amountIn = amountIn;
  minAmountOut = minAmountOut;
  deadline = deadline;
});
```

### Step 4: Verification & Double-Entry Recording
Record two rows in `TransactionRepository` (or `TxStore`):
1. Debit row: `-amountIn` of `tokenIn` (type: `#swapOut`, fee: `sourceLedgerFee`).
2. Credit row: `+receivedAmount` of `tokenOut` (type: `#swapIn`).
Link both records via `swapId` for reconciliation.

---

## Standard Error Types

```motoko
public type SwapError = {
  #InsufficientBalance;
  #InsufficientLiquidity;
  #PriceImpactTooHigh : Float;
  #SlippageExceeded : { minExpected : Nat; actual : Nat };
  #ExpiredDeadline;
  #AllowanceFailed : Text;
  #RouterError : Text;
  #TransferFailed : Text;
};
```
