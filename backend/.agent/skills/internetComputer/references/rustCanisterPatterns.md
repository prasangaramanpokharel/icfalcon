# Rust Canister Development Guide (`ic-cdk`)

This guide outlines production practices for building enterprise-grade WebAssembly canisters in Rust using `ic-cdk` and `ic-stable-structures`.

---

## 1. Minimal Secure Canister Structure

```rust
use ic_cdk_macros::{init, post_upgrade, pre_upgrade, query, update};
use candid::{CandidType, Principal};
use serde::{Deserialize, Serialize};

#[derive(CandidType, Serialize, Deserialize, Clone, Debug)]
pub struct Account {
    pub owner: Principal,
    pub balance: u64,
}

#[update]
fn transfer(recipient: Principal, amount: u64) -> Result<u64, String> {
    let caller = ic_cdk::caller();
    
    // 1. Guard against anonymous principals
    if caller == Principal::anonymous() {
        return Err("Anonymous caller rejected".to_string());
    }

    if recipient == Principal::anonymous() {
        return Err("Cannot transfer to anonymous principal".to_string());
    }

    // 2. Perform balance checks and state mutations
    // (In production, read and mutate using ic-stable-structures)
    Ok(amount)
}

#[query]
fn get_balance(owner: Principal) -> u64 {
    // Read directly from stable structure without mutating state
    0
}
```

---

## 2. Zero-Copy Persistence with `ic-stable-structures`

Avoid serializing the entire heap to stable memory during `pre_upgrade` because large canisters exceed instruction limits and trap, freezing the canister forever.

Use `ic-stable-structures`:
```rust
use ic_stable_structures::memory_manager::{MemoryId, MemoryManager, VirtualMemory};
use ic_stable_structures::{DefaultMemoryImpl, StableBTreeMap, Storable};
use std::cell::RefCell;

type Memory = VirtualMemory<DefaultMemoryImpl>;

thread_local! {
    static MEMORY_MANAGER: RefCell<MemoryManager<DefaultMemoryImpl>> =
        RefCell::new(MemoryManager::init(DefaultMemoryImpl::default()));

    static BALANCES: RefCell<StableBTreeMap<Principal, u64, Memory>> = RefCell::new(
        StableBTreeMap::init(
            MEMORY_MANAGER.with(|m| m.borrow().get(MemoryId::new(0)))
        )
    );
}
```

---

## 3. Candid Macro Export

Ensure Candid definitions are accurately exported using `candid::export_service!`:

```rust
candid::export_service!();

#[query(name = "__get_candid_interface_tmp_hack")]
fn export_candid() -> String {
    __export_service()
}
```
