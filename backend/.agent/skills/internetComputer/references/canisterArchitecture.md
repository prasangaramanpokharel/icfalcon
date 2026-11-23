# Canister Architecture & Lifecycle

Canisters on the Internet Computer represent a fusion of smart contracts and cloud microservices running inside a sandboxed WebAssembly execution environment.

---

## 1. Execution Model: Queries vs. Updates

| Property | Query Calls | Update Calls |
| :--- | :--- | :--- |
| **Consensus Required** | No (Single node execution) | Yes (Subnet consensus & state replication) |
| **Latency** | ~50 - 150 ms | ~1 - 2 seconds |
| **State Mutation** | Read-only (changes are discarded after reply) | Permanent state transition |
| **Cost** | Negligible / Free | Consumes cycles per instruction and bytes stored |
| **Response Certification** | Uncertified unless using certified variables / Merkle proofs | Certified by subnet BLS threshold signature |

---

## 2. Canister Upgrades & Lifecycle Hooks

When updating canister code via `dfx deploy` or `icp canister install`:
1. `pre_upgrade`: Invoked before the existing WebAssembly module is unloaded. Used to serialize transient memory into stable memory if not using stable structures.
2. Code Reload: The new Wasm bytecode is loaded.
3. `post_upgrade`: Invoked immediately after new Wasm initialization. Restores state and initializes new schemas.

> ⚠️ **Critical Rule**: If `pre_upgrade` or `post_upgrade` traps (e.g. from hitting execution instruction limits or out-of-memory errors), the canister can become permanently locked. Always use `ic-stable-structures` in Rust or enhanced orthogonal persistence in Motoko to avoid mass serialization during upgrade hooks.
