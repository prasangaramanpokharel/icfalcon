# Motoko Canister Development Guide

This guide establishes production patterns for developing WebAssembly canisters using Motoko on the Internet Computer.

---

## 1. Actor Architecture & Entry Points

In Motoko, an actor represents an isolated state machine with an asynchronous message queue.

```motoko
import Principal "mo:core/Principal";
import Result "mo:core/Result";
import Iter "mo:core/Iter";

actor class SecureVault(owner : Principal) = this {
  // Orthogonal stable storage surviving upgrades
  private stable var balances : [(Principal, Nat)] = [];

  // Guards against unauthorized access
  private func isOwner(caller : Principal) : Bool {
    caller == owner
  };

  // State-mutating update call
  public shared ({ caller }) func deposit(amount : Nat) : async Result.Result<Nat, Text> {
    if (Principal.isAnonymous(caller)) {
      return #err("Anonymous callers are rejected");
    };
    if (amount == 0) {
      return #err("Deposit amount must be positive");
    };

    // Update balance
    balances := Iter.toArray(
      Iter.concat(
        Iter.filter(balances.vals(), func((k, _)) { k != caller }),
        Iter.fromArray([(caller, amount)])
      )
    );
    #ok(amount)
  };

  // Low-latency query call (read-only)
  public query ({ caller }) func getBalance() : async Nat {
    for ((user, bal) in balances.vals()) {
      if (user == caller) {
        return bal;
      };
    };
    0
  };
};
```

---

## 2. Orthogonal Persistence & Upgrades

1. **`stable` Variables**: Keep state across code upgrades automatically without manual serialization.
2. **Enhanced Orthogonal Persistence**: Motoko 0.13+ supports direct 64-bit stable memory heap management.
3. **Migration from `mo:base` to `mo:core`**:
   - Modern Motoko uses `mo:core` (`mo:core/Principal`, `mo:core/Result`, `mo:core/Iter`).
   - Avoid legacy `mo:base` deprecated imports.

---

## 3. Reentrancy & Asynchronous Await Protection

Because canister execution is interleaved across `await` points:
```motoko
// ❌ WRONG: State mutation after await (Reentrancy risk)
public shared ({ caller }) func withdraw(amount : Nat) : async Result.Result<Nat, Text> {
  let bal = getBalance(caller);
  if (bal < amount) return #err("Insufficient funds");
  
  // External call happens before state update!
  await externalLedger.transfer(caller, amount);
  updateBalance(caller, bal - amount); // ⚠️ Vulnerable!
  #ok(amount)
};

// ✅ CORRECT: State mutation BEFORE external await
public shared ({ caller }) func withdraw(amount : Nat) : async Result.Result<Nat, Text> {
  let bal = getBalance(caller);
  if (bal < amount) return #err("Insufficient funds");
  
  // Deduct first (pessimistic lock)
  updateBalance(caller, bal - amount);
  try {
    await externalLedger.transfer(caller, amount);
    #ok(amount)
  } catch (err) {
    // Revert if external transfer fails
    updateBalance(caller, bal);
    #err("Transfer failed")
  }
};
```
