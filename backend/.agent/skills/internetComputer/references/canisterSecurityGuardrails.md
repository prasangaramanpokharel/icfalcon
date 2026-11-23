# Canister Security Guardrails & Verification

Security on the Internet Computer requires strict adherence to asynchronous safety, access control, and denial-of-service mitigations.

---

## 1. Reentrancy and the CallerGuard Pattern

Because all inter-canister calls are asynchronous (`await`), execution pauses and yields control back to the scheduler. During this window, other incoming messages can be processed:

```motoko
// SECURE PATTERN: Check-Effects-Interactions & Lock
actor class Vault() {
  private var isLocked : Bool = false;
  private var balances : [(Principal, Nat)] = [];

  public shared ({ caller }) func withdraw(amount : Nat) : async Bool {
    // 1. Guard check
    if (isLocked) return false;
    isLocked := true;

    // 2. State effect (decrease balance before external call)
    // deduct_balance(caller, amount);

    // 3. External interaction
    // await ledger.transfer(...);

    isLocked := false;
    true
  };
};
```

---

## 2. Anonymous Caller Defense

The anonymous principal (`2vxsx-mae` in text, `Principal.anonymous()` in code) represents unauthenticated public requests:

```rust
// In Rust (ic-cdk)
#[update]
fn admin_action() -> Result<(), String> {
    let caller = ic_cdk::caller();
    if caller == Principal::anonymous() {
        return Err("Anonymous callers are prohibited".to_string());
    }
    if !is_admin(&caller) {
        return Err("Unauthorized".to_string());
    }
    Ok(())
}
```

---

## 3. Cycle Drain Attack Prevention

Malicious users can flood expensive update calls or HTTPS outcalls to drain cycles:
1. Impose minimum cycle deposits or fee mechanisms for resource-intensive computation.
2. Rate-limit update calls per principal using token bucket algorithms.
3. Set cycle monitoring hooks (`ic_cdk::api::canister_balance128()`) with automated top-ups.
