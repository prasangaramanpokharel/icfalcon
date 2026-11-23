# Stable Memory and Orthogonal Persistence

Understanding data persistence is critical to avoid out-of-memory errors and data loss during canister upgrades.

---

## 1. Heap Memory vs. Stable Memory

- **Wasm Heap (32-bit)**: Fast access, max 4 GB. Does NOT automatically survive code upgrades without explicit serialization.
- **Stable Memory (64-bit)**: High capacity, up to 400 GB per canister. Directly backed by the replicated disk layer. Survives code upgrades completely.

---

## 2. Using `ic-stable-structures` in Rust

In Rust canisters, never serialize large hash maps in `pre_upgrade`. Instead, write directly to stable structures:

```rust
use ic_stable_structures::memory_manager::{MemoryId, MemoryManager, VirtualMemory};
use ic_stable_structures::{DefaultMemoryImpl, StableBTreeMap};

type Memory = VirtualMemory<DefaultMemoryImpl>;

thread_local! {
    static MEMORY_MANAGER: RefCell<MemoryManager<DefaultMemoryImpl>> =
        RefCell::new(MemoryManager::init(DefaultMemoryImpl::default()));

    static USERS: RefCell<StableBTreeMap<u64, Vec<u8>, Memory>> = RefCell::new(
        StableBTreeMap::init(
            MEMORY_MANAGER.with(|m| m.borrow().get(MemoryId::new(0))),
        )
    );
}
```

This guarantees **zero-downtime upgrades** with unlimited storage scalability.
