# Motoko & FalconORM Architecture Guide

Comprehensive developer reference for **Motoko 1.6.0** language features, compiler capabilities, memory architecture, and the **FalconORM** 3NF relational database engine.

---

## Table of Contents

1. [Motoko 1.6.0 Compiler & Runtime Powers](#1-motoko-160-compiler--runtime-powers)
2. [Variables, Mutability & Control Flow](#2-variables-mutability--control-flow)
3. [Classes, Objects & Actor Powers](#3-classes-objects--actor-powers)
4. [Asynchronous Execution & Concurrency](#4-asynchronous-execution--concurrency)
5. [System Capabilities & Inter-Canister Primitives](#5-system-capabilities--inter-canister-primitives)
6. [Memory Architecture: EOP, Regions & GC](#6-memory-architecture-eop-regions--gc)
7. [FalconORM: 3NF Relational Database Engine](#7-falconorm-3nf-relational-database-engine)
8. [Database Ecosystem Comparison](#8-database-ecosystem-comparison)
9. [High-Scale Multi-Canister Sharding](#9-high-scale-multi-canister-sharding)

---

## 1. Motoko 1.6.0 Compiler & Runtime Powers

The IcFalcon framework leverages the official DFINITY Motoko compiler (`moc 1.6.0`).

### Essential Compiler Flags

```bash
moc \
  --package core .mops/core@2.6.1/src \
  --package pkg backend/pkg \
  --enhanced-orthogonal-persistence \
  --incremental-gc \
  -fno-shared-code \
  -W M0236 -W M0237 -W M0223 \
  -c src/main.mo -o .dfx/local/canisters/app/app.wasm
```

| Flag | Role & Effect |
|---|---|
| `--enhanced-orthogonal-persistence` | **Default in moc 1.6.0+**. Upgrades retain 64-bit Wasm heap directly without serialization into classical stable memory. |
| `--incremental-gc` | **Default GC**. Incremental, mark-sweep-compact collector interleaved with message processing. Eliminates latency pause spikes. |
| `-fno-shared-code` | Omits low-level utility function sharing across modules, resulting in slightly larger binary size but significantly **lower cycle consumption**. |
| `--generate-view-queries` | Generates Candid query methods for stable canister state automatically. |
| `--ai-errors` | Emits AI-tailored error diagnostics with structured hints and fix suggestions. |
| `--idl` | Compiles canister interfaces directly into standardized `.did` Candid definitions. |
| `-W M0236` | Lints non-dot-notation calls on types with `self` (enforces contextual dot notation). |
| `-W M0237` | Lints redundant explicit arguments where the compiler can auto-derive comparison/equality. |
| `-W M0223` | Lints redundant type parameter instantiations. |

---

## 2. Variables, Mutability & Control Flow

### Variable Declarations in Persistent Actors

Under Enhanced Orthogonal Persistence (`persistent actor`), top-level declarations are **persistent (stable) by default**:

```motoko
persistent actor Canister {
  // 1. Persistent State (survives upgrades automatically without serialization)
  let users = UserStorage.createUserMap(); // Immutable reference to mutable Map
  var globalCounter : Nat = 0;            // Reassignable, persisted across upgrade

  // 2. Ephemeral State (explicitly reset on each canister upgrade)
  transient var activeSessions : Nat = 0;       // Reset to 0 on upgrade
  transient let requestCache = Cache.empty();  // Cleared on upgrade
  transient let ormTable = OrderStorage.createTable(null); // In-memory ORM handle
};
```

> [!IMPORTANT]
> Never use the deprecated `stable` keyword in persistent actors. It is redundant and produces compiler warning `M0218`.

### `let ... else` Early Returns

Motoko 1.6.0 natively supports pattern extraction with diverging fallback blocks (`return`, `throw`, `assert false`, or `break`):

```motoko
func processOrder(orderOpt : ?Order) : Result<(), Text> {
  // Unpack option cleanly; diverge if null
  let ?order = orderOpt else {
    return #err("Order does not exist");
  };

  // Unpack tuple or record variants
  let (#admin(role)) = order.callerRole else {
    return #err("Unauthorized: admin role required");
  };

  #ok(())
};
```

### Mutability: Pure Value vs In-Place Arrays & Records

```motoko
// Immutable array (Pure value, safe for public APIs)
let numbers : [Nat] = [1, 2, 3];

// Mutable array (In-place updates inside algorithms)
let mutBuffer : [var Nat] = [var 1, 2, 3];
mutBuffer[0] := 99;

// Record with mutable fields
type CounterState = { var count : Nat; name : Text };
let state : CounterState = { var count = 0; name = "Primary" };
state.count += 1;

// Functional Record Update (Copy-with-spread)
type Profile = { id : Text; email : Text; tier : Text };
let p1 : Profile = { id = "1"; email = "a@b.com"; tier = "free" };
let p2 : Profile = { p1 with tier = "pro" }; // Functional update
```

---

## 3. Classes, Objects & Actor Powers

### Classes vs Objects

- **Object Literal**: An immutable or mutable record of functions and fields created once.
- **Class**: A constructor function producing new object instances with encapsulated state:

```motoko
module {
  // Generic class with type parameters and private encapsulated state
  public class Stack<T>() {
    private var elements : [T] = [];

    public func push(item : T) {
      elements := Array.append(elements, [item]);
    };

    public func pop() : ?T {
      if (elements.size() == 0) { null }
      else {
        let last = elements[elements.size() - 1];
        elements := Array.subArray(elements, 0, elements.size() - 1);
        ?last;
      };
    };

    public func count() : Nat { elements.size() };
  };
};
```

### Actor Classes (Dynamic Micro-Canister Spawning)

Motoko supports programmatic canister creation through **Actor Classes**:

```motoko
// Canister definition
actor class PartitionCanister(partitionId : Nat, owner : Principal) {
  public query func getPartitionId() : async Nat { partitionId };
  public shared ({ caller }) func storeData(key : Text, val : Blob) : async Bool {
    assert (caller == owner);
    // ...
    true;
  };
};

// Orchestrator Canister (spawns new canisters dynamically on-chain)
persistent actor MeshOrchestrator {
  public shared ({ caller }) func spawnPartition(id : Nat) : async Principal {
    let newCanister = await PartitionCanister(id, caller);
    Principal.fromActor(newCanister);
  };
};
```

---

## 4. Asynchronous Execution & Concurrency

### Standard `async` vs Starred `async*` (Deferred Coroutines)

Motoko provides two distinct concurrency mechanisms:

1. **Standard `async T`**: Sends an inter-canister message or enqueues a future onto the Internet Computer message queue. Every `await` is a commit point.
2. **Starred `async* T`**: A **deferred local asynchronous computation** (coroutine). It executes cooperatively without queuing an inter-canister message until explicitly awaited with `await*`.

```motoko
// Local async computation without IC message overhead
func calculateFee(amount : Nat) : async* Nat {
  if (amount < 10_000) { 10 } else { 100 };
};

// Consuming deferred computations
public shared func executePayment(amount : Nat) : async Nat {
  let fee = await* calculateFee(amount);
  amount + fee;
};
```

### Option Unpacking with `await?`

When calling an asynchronous function returning an option (`async ?T`), `await?` awaits and unpacks the value in a `do ? { ... }` block:

```motoko
public func loadUserProfile(canister : RemoteActor, id : Text) : async ?Profile {
  do ? {
    let user = await? canister.lookupUser(id); // Returns null early if null
    user.profile;
  };
};
```

---

## 5. System Capabilities & Inter-Canister Primitives

### Native System Functions

Canister entry points hook into system lifecycle events:

```motoko
persistent actor App {
  // 1. Periodic Timer (Dynamic Timer Hook)
  system func timer(expirationTime : Int) : async () {
    // Executes when system timer fires
  };

  // 2. Heartbeat (Periodic Subnet Call — every round ~1s)
  system func heartbeat() : async () {
    // Process background queues
  };

  // 3. Inspect (Ingress Message Filter — zero-cycle firewall)
  system func inspect({ caller : Principal; msg : { #inspect; #submitOrder : { amount : Nat } } }) : Bool {
    // Reject malformed or unauthorized HTTP requests BEFORE consensus
    caller != Principal.anonymous();
  };

  // 4. Low Memory Notification
  system func low_memory() : async () {
    // Trigger cleanup or emit alarm when heap approaches threshold
  };
};
```

### Call Options: `@timeout` and `@cycles`

Configure call timeouts and cycle attachments directly on message expressions:

```motoko
// Attach cycles to canister creation or payment call
let canisterPrincipal = await (PartitionCanister(id, caller))(@cycles(1_000_000_000_000));

// Enforce strict timeout (in nanoseconds) to prevent hung ingress
let result = await (remoteCanister.queryPrice())(@timeout(5_000_000_000)); // 5s timeout
```

### Composite Queries (`shared composite query`)

Standard queries cannot call other canisters. **Composite queries** lift this restriction, allowing synchronous read calls across multiple canisters without consensus delay or cycle burn:

```motoko
public shared composite query func getAggregatedPortfolio(owner : Principal) : async PortfolioView {
  let btcBalance = await ckbtcCanister.balanceOf(owner);
  let ethBalance = await evmCanister.balanceOf(owner);
  let icpBalance = await ledgerCanister.icrc1_balance_of({ owner = owner; subaccount = null });
  { btc = btcBalance; eth = ethBalance; icp = icpBalance }
};
```

---

## 6. Memory Architecture: EOP, Regions & GC

```
┌─────────────────────────────────────────────────────────────────┐
│                      Internet Computer Canister                 │
│                                                                 │
│  ┌───────────────────────────────┐  ┌────────────────────────┐  │
│  │   64-bit Persistent Heap      │  │   Stable Memory (64GB) │  │
│  │ (Enhanced Orthogonal Persist) │  │                        │  │
│  │                               │  │  ┌──────────────────┐  │  │
│  │  let users = UserStorage...   │  │  │ Region 0 (Logs)  │  │  │
│  │  TableState<T> (Indices/Maps) │  │  ├──────────────────┤  │  │
│  │                               │  │  │ Region 1 (Blobs) │  │  │
│  │  ✓ Preserved across upgrades  │  │  ├──────────────────┤  │  │
│  │  ✓ Zero serialization cost    │  │  │ Region N (Files) │  │  │
│  │  ✓ Up to 64GB address space   │  │  └──────────────────┘  │  │
│  └───────────────────────────────┘  └────────────────────────┘  │
│                                                                 │
│  Incremental Garbage Collector (--incremental-gc):             │
│  - Runs concurrently in small slices during update execution    │
│  - Prevents stop-the-world GC latency pauses                   │
└─────────────────────────────────────────────────────────────────┘
```

### Enhanced Orthogonal Persistence (EOP)
- **Zero Serialization**: Canister upgrades do NOT serialize variables to stable memory and deserialize them on restart. The heap memory is retained across Wasm module upgrades.
- **64-bit Address Space**: Canisters can utilize large memory pools beyond the 4GB 32-bit Wasm heap limit.

### Stable Regions (`Region` module)
When raw binary control is required (e.g., append-only audit logs or massive blob storage), `Region` provides virtual 64KiB pages:

```motoko
import Region "mo:core/Region";

let logRegion = Region.new();
let prevPages = Region.grow(logRegion, 10); // Allocates 10 pages (640 KiB)
Region.storeNat64(logRegion, 0, 123456789);
let val = Region.loadNat64(logRegion, 0);
```

---

## 7. FalconORM: 3NF Relational Database Engine

**FalconORM** (`mo:pkg/orm/orm`) provides a Third Normal Form relational architecture directly in Motoko.

### Normalized 3NF Architecture

```
❌ Anti-Pattern (Denormalized):
User: { id, name, orders: [{ id, total, items: [...] }] }
--> Serializing nested arrays risks 2MB message limits and creates data desync.

✅ 3NF Normalized with FalconORM:
┌─────────────────┐           ┌─────────────────┐           ┌─────────────────┐
│     Tenants     │           │      Users      │           │     Orders      │
├─────────────────┤ 1       * ├─────────────────┤ 1       * ├─────────────────┤
│ id (PK)         │──────────<│ id (PK)         │──────────<│ id (PK)         │
│ name            │           │ tenantId (FK)   │           │ userId (FK)     │
│ createdAt       │           │ email (Unique)  │           │ amount          │
└─────────────────┘           │ role (Index)    │           │ status (Index)  │
                              └─────────────────┘           └─────────────────┘
```

### Declarative Schema & Dual Persistence Modes

FalconORM supports two execution models:

#### Mode A: Zero-Serialization Persistent State (`TableState<T>`)
Because `TableState<T>` is composed of pure `Map.Map` structures, it is a **stable type** and can be declared as a top-level `let` in persistent actors:

```motoko
// backend/src/storage/UserStorage.mo
import ORM "mo:pkg/orm/orm";
import Types "../types";

module {
  public type UserTable = ORM.Table<Types.User>;
  public type UserState = ORM.TableState<Types.User>;

  public let config = ORM.config<Types.User>("users", func(u) { u.id }, [
    ORM.unique("email", func(u) { u.email }),
    ORM.foreignKey("tenantId", func(u) { u.tenantId }),
    ORM.index("role", func(u) { u.role }),
  ]);

  public func createState() : UserState { ORM.createState<Types.User>() };
  public func createTable(optState : ?UserState) : UserTable {
    switch (optState) {
      case (?st) { ORM.createTableFromState(config, st) };
      case (null) { ORM.createTable(config) };
    };
  };
};

// backend/src/main.mo
persistent actor App {
  // Survives canister upgrade in 64-bit persistent heap with zero serialization!
  let userState = UserStorage.createState();
  transient let userTable = UserStorage.createTable(?userState);
};
```

#### Mode B: In-Memory Table with 1-Line Array Restoration
```motoko
// Preupgrade & Postupgrade serialization for classical canisters
system func preupgrade() {
  stableUsers := userTable.all();
};

system func postupgrade() {
  userTable := switch (ORM.fromArray(userConfig, stableUsers)) {
    case (#ok(tbl)) { tbl };
    case (#err(msg)) { Debug.trap(msg) };
  };
};
```

---

## 8. Database Ecosystem Comparison

| Feature | FalconORM | CanDB | ZenDB | MotokoStableBTree | Raw Map (`mo:core`) |
|---|---|---|---|---|---|
| **Data Model** | **3NF Relational** | Multi-Canister Document | Document / JSON | Key-Value / Ordered | Key-Value |
| **Secondary Indices** | **Auto-Synchronized** | Manual Index Partitioning | Dynamic Schema Index | Sorted Keys only | None (Manual) |
| **Unique Constraints** | **Atomic Enforcement** | Manual check | Manual check | Primary key only | Primary key only |
| **Foreign Keys & Relations** | `hasMany`, `belongsTo`, `hasOne` | Cross-canister pointers | Unenforced pointers | None | None |
| **Referential Integrity** | `validateForeignKey` | None | None | None | None |
| **Cascade / Restrict Deletes**| `deleteCascade`, `deleteRestrict` | None | None | None | None |
| **Batch Operations** | **Atomic with Rollback** | Eventual consistency | Non-atomic | Single key | Non-atomic |
| **Query Builder** | Fluent `.where()`, `.orderBy()`, `.skip()`, `.take()`, `.paginate()` | Custom range queries | Mongo-style filters | Range iterator | Iter / Array |
| **EOP Heap Compatibility** | **Native (`TableState<T>`)** | Custom serialization | Byte serialization | Stable Memory only | Native `Map.Map` |
| **Read Complexity** | **$O(1)$ PK & Unique** | Network RPC overhead | Index traversal | $O(\log n)$ | $O(1)$ |
| **Dependencies** | **Zero (`mo:core` only)** | Multi-repo framework | Custom parser | Byte serialization libs | `mo:core` |

---

## 9. High-Scale Multi-Canister Sharding

When data exceeds the capacity of a single canister (e.g. >100M rows or high concurrent write throughput), combine **Falcon Universe** with **FalconORM**:

```
                              ┌──────────────────────────────────┐
                              │     Router / Gateway Canister    │
                              │     (Consistent Hash Partition)  │
                              └────────────────┬─────────────────┘
                                               │
                    ┌──────────────────────────┼──────────────────────────┐
                    ▼                          ▼                          ▼
       ┌────────────────────────┐ ┌────────────────────────┐ ┌────────────────────────┐
       │   Canister Partition 0 │ │   Canister Partition 1 │ │   Canister Partition 2 │
       ├────────────────────────┤ ├────────────────────────┤ ├────────────────────────┤
       │ FalconORM (Users 0..K) │ │ FalconORM (Users K..M) │ │ FalconORM (Users M..N) │
       │ - UserTable            │ │ - UserTable            │ │ - UserTable            │
       │ - OrderTable           │ │ - OrderTable           │ │ - OrderTable           │
       │                        │ │                        │ │                        │
       │ Universe Pub/Sub Mesh  │ │ Universe Pub/Sub Mesh  │ │ Universe Pub/Sub Mesh  │
       └────────────────────────┘ └────────────────────────┘ └────────────────────────┘
```

1. **Partition by Tenant or Primary Key**: The Gateway hashes `id` to route requests to the designated partition canister.
2. **Local 3NF Integrity**: Each canister runs FalconORM for atomic ACID transactions, foreign keys, and indexes within its partition.
3. **Cross-Partition Consistency**: Distributed state mutations publish events through the **Falcon Universe Event Mesh** (`Universe.publish`) with outbox idempotency.
4. **Cross-Canister Aggregation**: Frontend queries use **Composite Queries** (`shared composite query`) to read across partitions without consensus latency.
