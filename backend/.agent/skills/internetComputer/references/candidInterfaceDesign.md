# Candid Interface Design (.did)

Candid is the language-agnostic interface definition language (IDL) used to describe canister APIs and serialize binary payloads.

---

## 1. Candid Specification Syntax

```candid
type UserId = principal;
type Timestamp = nat64;

type Account = record {
  owner : principal;
  subaccount : opt blob;
};

type TransferArgs = record {
  from_subaccount : opt blob;
  to : Account;
  amount : nat;
  created_at_time : opt Timestamp;
};

type TransferResult = variant {
  Ok : nat;
  Err : TransferError;
};

type TransferError = variant {
  BadFee : record { expected_fee : nat };
  InsufficientFunds : record { balance : nat };
  TooOld;
  Duplicate : record { duplicate_of : nat };
};

service : {
  icrc1_balance_of : (Account) -> (nat) query;
  icrc1_transfer : (TransferArgs) -> (TransferResult);
}
```

---

## 2. Backward Compatibility Rules

When evolving Candid interfaces in production:
1. **Never rename or reorder fields in records**: Candid serializes field names using hash integers.
2. **Adding parameters to methods**: New input parameters MUST be wrapped in `opt` (optional).
3. **Removing methods**: Mark deprecated methods before removal; removing active methods will break existing frontend agents or inter-canister callers.
