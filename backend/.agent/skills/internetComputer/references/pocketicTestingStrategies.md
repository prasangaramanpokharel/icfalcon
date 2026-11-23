# PocketIC Deterministic Testing Strategies

PocketIC is the official testing framework from DFINITY for deterministic, fast canister integration testing in Rust and Python.

---

## 1. Why PocketIC Over Local Replicas

- **Speed**: Runs tests in seconds compared to minutes with a local replica.
- **Determinism**: Fully controls execution time, message order, and subnet topologies.
- **Multi-Canister Support**: Simulates cross-canister calls and subnet boundaries in a single test process.

---

## 2. PocketIC Rust Integration Example

```rust
use pocket_ic::PocketIc;
use candid::Principal;

#[test]
fn test_canister_transfer_flow() {
    let pic = PocketIc::new();

    // Create and install canister wasm
    let canister_id = pic.create_canister();
    pic.add_cycles(canister_id, 2_000_000_000_000);
    
    let wasm_bytes = std::fs::read("target/wasm32-unknown-unknown/release/backend.wasm").unwrap();
    pic.install_canister(canister_id, wasm_bytes, vec![], None);

    // Call update method
    let caller = Principal::from_text("2vxsx-mae").unwrap(); // anonymous
    let response: Result<u64, String> = pic.update_call(
        canister_id,
        caller,
        "transfer",
        candid::encode_one(100u64).unwrap(),
    ).unwrap();

    assert!(response.is_err(), "Anonymous caller should be rejected");
}
```
