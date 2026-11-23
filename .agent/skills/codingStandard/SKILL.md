---
name: codingStandard
description: >-
  IcFalcon Motoko coding standards — naming, imports, file size, mo:core patterns,
  layering imports, reserved keywords, and comments. Read before writing or
  reviewing any backend/src/*.mo file.
---

# IcFalcon — Coding Standard

Project conventions on top of Motoko language rules. When this doc and generic
Motoko advice conflict, **this doc wins for IcFalcon**.

Language reference: [`skills/motokoStandard/writingMotokoStandard/SKILL.md`](../motokoStandard/writingMotokoStandard/SKILL.md)  
Architecture: [`skills/layeringStandard/SKILL.md`](../layeringStandard/SKILL.md)

---

## Stack libraries

| Use | Don't use |
|---|---|
| `mo:core` (2.x) | `mo:base` (deprecated) |
| Contextual dot: `map.get(k)`, `list.add(x)` | Module-first: `Map.get(map, k)` |
| `persistent actor` in `main.mo` | Manual `stable var` serialisation |
| `(with migration = …)` for upgrades | `preupgrade` / `postupgrade` for data |

Import `Map` in any file that calls `.remove` on a map — otherwise the compiler
treats the value as a plain record.

---

## mo:core (2.x) API Rules

When writing Motoko using `mo:core` (2.x), always use modern standard library methods. Never use removed `mo:base` patterns:

| Operation | Standard (`mo:core`) | Forbidden (`mo:base` / legacy) | Notes |
|---|---|---|---|
| String lowercase | `Text.toLower(t)` | `Text.toLowercase(t)` | Method is `toLower`, not `toLowercase` |
| String uppercase | `Text.toUpper(t)` | `Text.toUppercase(t)` | Method is `toUpper`, not `toUppercase` |
| Substring / slice | `Iter.take(t.chars(), n)` | `Text.substring(t, start, len)` | `Text` has no `substring` in `mo:core`; use char iterators + `Text.fromIter` |
| Join strings | `Text.join(iter, sep)` | `Text.join(sep, iter)` | First argument is iterator, second argument is separator |
| Array concat | `Array.concat<T>(a, b)` | `Array.append(a, b)` | `Array.append` is removed/deprecated |
| Array slice | `Array.sliceToArray<T>(a, i, j)` | `Array.subArray(a, i, j)` | `Array.subArray` is removed/deprecated |
| Iter to Array | `Iter.toArray(iter)` | `Array.fromIter(iter)` | `Array.fromIter` is deprecated in favor of `Iter.toArray` |
| VarArray to Array | `VarArray.toArray(varArr)` | `Array.fromVarArray(varArr)` | `Array.fromVarArray` is deprecated in favor of `VarArray.toArray` |
| List | `mo:core/List` or `mo:core/pure/List` | `mo:base/List` | Use `list.add` / `list.put`, never `push` |

---

## File and module layout

```
backend/src/
├── main.mo              actor entry — wire storage, services, API mixins
├── types.mo             shared public types, ApiResult
├── api/v1/<Name>.mo     mixin — thin endpoints
├── services/<Name>Service.mo   or services/<domain>/*.mo
├── repositories/<Name>Repository.mo
├── storage/<Name>Storage.mo
├── validators/<Name>.mo
├── migrations/<Name>.mo
├── config/Config.mo
├── ledger/
└── utils/
```

| Rule | Limit |
|---|---|
| Max ~**300 lines** per file | Split into `services/<domain>/` folder + facade |
| One module per file | `module { … }` at file scope |
| Facade shim | Keep `services/FooService.mo` re-exporting split modules |

---

## Naming

| Item | Convention | Example |
|---|---|---|
| Module file | `PascalCase.mo` | `TransferService.mo` |
| Service type | `FooService` | `public type TransferService = { … }` |
| Factory | `create` | `public func create(...): TransferService` |
| Service funcs | `camelCase`, first arg `service` | `transferByUsername(service, caller, …)` |
| Storage factory | `createXMap` / `createXList` | `createUserMap()` |
| Repository | verb + entity | `findByPrincipal`, `insert`, `remove` |
| Validator | `validate` / `validateX` | returns `?Text` |
| Types in `types.mo` | `PascalCase` | `UserPublic`, `ApiResult` |
| Variants | `#camelCase` | `#ok`, `#err`, `#deposit` |
| Config constants | `SCREAMING_SNAKE` in Config | `ICP_FEE`, `MAX_TITLE` |
| Migration module | `PascalCase` verb | `AddSocialLinks.mo`, `StampLedgerId.mo` |

Test files: `<Name>.test.mo` under `testing/`.

---

## Imports — order and paths

```motoko
import Array "mo:core/Array";           // 1. mo:core
import Principal "mo:core/Principal";
import Types "../types";                 // 2. project types
import UserRepo "../repositories/UserRepository";
import UserStorage "../storage/UserStorage";
import UsernameValidator "../validators/UsernameValidator";
import Config "../config/Config";
```

| Layer | May import |
|---|---|
| `api/v1/` | services, types, middleware |
| `services/` | repositories, storage, validators, ledger, config |
| `repositories/` | storage, types |
| `storage/` | types, mo:core only |
| `validators/` | config, types — **pure only** |

Never: `api/` → `storage/` directly.

---

## Service module pattern

```motoko
module {
  public type MyService = {
    users: UserStorage.UserMap;
    // fields are storage refs + config, not business state
  };

  public func create(users: UserStorage.UserMap): MyService {
    { users }
  };

  public func doWork(service: MyService, caller: Principal, input: Text): Types.ApiResult<Types.MyPublic> {
    // validate → authorize → repo → #ok
  };
};
```

- **No classes** — use `module` + record service type.
- First parameter after `service` is usually `caller: Principal` for auth paths.
- Return `Types.ApiResult<T>` from public service functions that can fail.

---

## API mixin pattern

```motoko
mixin (svc: MyService.MyService, mwConfig: MiddlewareAuth.Config) {
  public shared ({ caller }) func myMethod(...): async Types.ApiResult<T> {
    MyService.doWork(svc, MiddlewareAuth.effectiveCaller(mwConfig, caller), ...);
  };

  public shared query ({ caller }) func myQuery(...): async T {
    MyService.read(svc, MiddlewareAuth.effectiveCaller(mwConfig, caller), ...);
  };
};
```

- Reads that are free and safe → `shared query`.
- Mutations and fund paths → `shared` (update).
- API files contain **no** validation logic beyond delegating.

---

## Persistent actor — stable vs transient

```motoko
persistent actor self {
  let users = UserStorage.createUserMap();     // persists — never transient
  transient let transfer = TransferService.create(users, ...);  // rebuilt each upgrade
  transient let rateLimits = RateLimitStorage.createRateLimitMap();  // OK to reset
};
```

| Persists | Transient OK |
|---|---|
| Users, balances, transactions, buckets, tokens | Service records |
| Ledger registry, settings | Rate limit counters |
| Live rooms (while feature active) | Upload sessions, caches |

Getting this wrong **silently wipes mainnet data** on upgrade.

---

## Reserved keywords & naming restrictions

Never use reserved Motoko keywords as identifiers — variable, function, record field, parameter, or variant tag:
`actor`, `and`, `assert`, `async`, `async*`, `await`, `await*`, `break`, `case`, `catch`, `class`, `composite`, `continue`, `debug`, `debug_show`, `do`, `else`, `false`, `finally`, `for`, `func`, `if`, `ignore`, `import`, `in`, `label`, `let`, `loop`, `mixin`, `module`, `not`, `null`, `object`, `or`, `persistent`, `private`, `public`, `query`, `return`, `shared`, `stable`, `switch`, `system`, `throw`, `transient`, `true`, `try`, `type`, `var`, `while`, `with`.

### Common AI traps to avoid:
1. **Never use `#debug` as a variant tag**: `debug` is a reserved expression keyword in Motoko. Use `#dbg` or `#Debug`.
2. **Never name functions `object`**: `object` is a reserved keyword (`object { ... }`). Use `func obj` or `func item`.
3. **Never name record fields `type` or `query`**: Use `kind` or `category`, `request` or `searchTerm`.

---

## Records, mutability, and functional updates

1. **Constructing records with mutable fields**:
   When constructing a record that declares `var field : T`, record construction MUST explicitly prefix with `var`:
   ```motoko
   public type Job = { id : Nat; var status : JobStatus };
   let job : Job = { id = 1; var status = #pending }; // 'var' is required!
   ```

2. **Functional record updates `{ record with ... }`**:
   Motoko does NOT allow functional updates if the record has un-overwritten `var` fields (error `M0179: base has non-aliasable var field`).
   - Domain models that undergo functional updates should keep fields immutable (`status : Status`), returning updated copies.
   - If a record has mutable fields, mutate them in place (`record.status := #completed`) or overwrite ALL `var` fields in the `with` expression.

3. **Prefer spread over manual copy for immutable records**:
   ```motoko
   { user with displayName = name; updatedAt = Time.now() }
   ```

---

## Async return typing & shareability (`M0033`)

In Motoko, both `async T` and `async* T` return types strictly require `T` to be a **shared type** (`Shareability`).
- Primitive types (`Text`, `Nat`, `Int`, `Bool`, `Principal`, `Blob`) and immutable records/variants/arrays of shared types are shared.
- Unconstrained generic type parameters (e.g. `<T>`) are **NOT** known to be shared!
- **AI Trap**: Do NOT write generic async utility functions returning unconstrained `async Result<T>` or `async* T` (causes compiler error `M0033: async has non-shared content type`). Always specialize async utility functions to concrete shared types (e.g. `async Result<Text>`, `async Bool`, `async ()`).

---

## Error handling patterns

Variant checks:

```motoko
switch (result) {
  case (#ok(v)) { … };
  case (#err(e)) { … };
};
```

Early return for errors — avoid deep nesting:

```motoko
switch (Validator.validate(x)) {
  case (?err) { return #err(err) };
  case (null) {};
};
```

---

## Comments

- Code should be self-explanatory for simple flow.
- **Do** comment non-obvious business rules (custody, permanence, fee policy).
- **Do** comment migration headers (`APPLIED`, why re-wire forbidden).
- **Do** comment why a pre-flight ledger read was **not** added.
- **Don't** restate what the code obviously does.

Example (good):

```motoko
// Username is a payment destination — first claim is permanent.
```

---

## File size — when to split

Split when a service file exceeds ~300 lines:

```
services/swap/
├── Context.mo
├── Pool.mo
├── Quote.mo
├── Execute.mo
├── SwapService.mo   ← facade
services/SwapService.mo  ← shim: public let quote = Quote.quote
```

Rules while splitting:

1. No circular imports.
2. Facade re-exports only — no new logic in shim.
3. Refactor-only split — behaviour unchanged, tests green.

---

## Security coding rules

| Rule | Reason |
|---|---|
| Fund paths use `caller`, not param principal | Prevents spending others' ICP |
| Never store keys, seeds, passwords | II-only auth |
| Official ledger interfaces only | `ledger/LedgerClient.mo` |
| Validate all external input | Via `validators/` |
| No `Debug.trap` for user errors | Return `#err` |
| Cap mainnet call loops ~10–30 | Cycle burn |

---

## Verify before PR

```bash
falcon audit code:motoko    # audit formatting, layering, and syntax (or: falcon a:c:m)
falcon audit code:motoko --fix  # auto-fix whitespace & line-endings
cd backend && bash scripts/run-tests.sh
cd backend && dfx build icp_wallet_backend --check --network ic
```

---

## Related skills

| Topic | Path |
|---|---|
| Layering | [`skills/layeringStandard/SKILL.md`](../layeringStandard/SKILL.md) |
| Errors | [`skills/errorHandlingStandard/SKILL.md`](../errorHandlingStandard/SKILL.md) |
| Tests | [`skills/testingStandard/SKILL.md`](../testingStandard/SKILL.md) |
| Migrations | [`skills/migrationStandard/SKILL.md`](../migrationStandard/SKILL.md) |
| Motoko style guide | [`skills/motokoStandard/docs/reference/style-guide.md`](../motokoStandard/docs/reference/style-guide.md) |
