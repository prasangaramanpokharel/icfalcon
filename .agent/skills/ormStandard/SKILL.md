---
name: ormStandard
description: >-
  FalconORM 3NF relational database engine for Motoko — schema definitions, auto-synchronized
  secondary indices, foreign key relations (hasMany, belongsTo), fluent query builder, and 1-line migrations.
---

# FalconORM Standard — 3NF On-Chain Database Engine

Standard for building scalable, normalized (Third Normal Form) persistent state models in Motoko using `pkg/orm`.

---

## Purpose

Eliminate manual `Map.Map` synchronization, prevent denormalization memory explosion, and provide a type-safe relational database API (Prisma/Eloquent-style) directly inside Motoko persistent actors.

---

## When to use

- Defining domain models with unique constraints (e.g. `email`, `username`)
- Maintaining One-to-Many or Many-to-One relationships (e.g. `Tenant` -> `User` -> `Order`)
- Querying records with filtering, sorting, and pagination (`where`, `orderBy`, `skip`, `take`, `paginate`)
- Enforcing referential integrity and foreign key delete cascade/restrict rules
- Safely evolving data models across canister upgrades with 1-line schema migrations

---

## 1. Declarative Table & Index Definition

Always normalize entities into atomic tables (3NF). Use declarative schema helpers instead of verbose record configs:

```motoko
import ORM "mo:pkg/orm/orm";

// 1. Normalized Model Record
public type User = {
  id : Text;
  tenantId : Text;
  email : Text;
  name : Text;
  role : Text;
  createdAt : Int;
};

// 2. Table with Primary Key & Secondary Indices
public let UserTable = ORM.createTable<User>(ORM.config("users", func(u : User) { u.id }, [
  ORM.unique("email", func(u : User) { u.email }),       // Enforces unique constraint
  ORM.foreignKey("tenantId", func(u : User) { u.tenantId }), // 1-to-Many group index
  ORM.index("role", func(u : User) { u.role }),           // Filter index
]));
```

---

## 2. CRUD, Batch & Upsert Operations

```motoko
// Insert: Validates unique constraints & auto-indexes all keys
let result = UserTable.insert(newUser); // Result<User, Text>

// Atomic Batch Insert with automatic rollback on collision
let batch = UserTable.insertMany([u1, u2, u3]); // Result<[User], Text>

// Upsert: Creates if absent, updates if exists
let upserted = UserTable.upsert(user); // Result<User, Text>

// Primary Key existence check: O(1)
let exists = UserTable.exists("u-123"); // Bool

// Lookups
let byId = UserTable.findById("u-123"); // ?User
let byEmail = UserTable.findOneByIndex("email", "alice@example.com"); // ?User
let byRole = UserTable.findManyByIndex("role", "admin"); // [User]

// Update: Diffs modified fields and re-indexes dirty indices atomically
UserTable.update("u-123", func(u : User) : User {
  { u with role = "admin" }
});

// Delete & Batch Delete
UserTable.delete("u-123");
UserTable.deleteMany(["u-1", "u-2"]); // Result<Nat, Text>
```

---

## 3. 3NF Relational Integrity & Cascade Rules

```motoko
// 1. Referential Integrity: Verify referenced parent exists before insert
let isValid = ORM.validateForeignKey<Order, User>(newOrder, func(o) { o.userId }, UserTable);

// 2. Resolves 1-to-Many (e.g. User hasMany Orders)
let userOrders = ORM.hasMany<User, Order>(user, func(u) { u.id }, OrderTable, "userId");

// 3. Resolves Many-to-1 (e.g. Order belongsTo User)
let owner = ORM.belongsTo<Order, User>(order, func(o) { o.userId }, UserTable);

// 4. Restrict Delete: Prevent parent deletion if child records exist
ORM.deleteRestrict<User, Order>(UserTable, "u-123", OrderTable, "userId");

// 5. Cascade Delete: Delete child records first, then delete parent
ORM.deleteCascade<User, Order>(UserTable, "u-123", OrderTable, "userId", func(o) { o.id });
```

---

## 4. Query Builder (Filter, Sort, Skip/Take, Paginate)

```motoko
let admins = UserTable.builder()
  .where(func(u : User) : Bool { u.role == "admin" })
  .orderBy(func(a : User, b : User) : Bool { a.createdAt > b.createdAt }) // Newest first
  .skip(10)
  .take(5)
  .toArray();

let page = UserTable.builder()
  .where(func(u : User) : Bool { u.role == "admin" })
  .paginate(0, 20); // { items = [User]; total = 42; offset = 0; limit = 20; hasMore = true }
```

---

## 5. Canister Upgrades & 1-Line Migrations

### Fast Canister Upgrade Persistence

In `preupgrade`:
```motoko
system func preupgrade() {
  stableUsers := UserTable.all();
};
```

In `postupgrade`:
```motoko
system func postupgrade() {
  UserTable := switch (ORM.fromArray(userConfig, stableUsers)) {
    case (#ok(tbl)) { tbl };
    case (#err(msg)) { D.trap("Failed to restore UserTable: " # msg) };
  };
};
```

### Schema Evolution (OldType -> NewType)

```motoko
public func migration(oldTable : ORM.Table<OldUser>) : Result<ORM.Table<NewUser>, Text> {
  ORM.migrate<OldUser, NewUser>(oldTable, newUserConfig, func(old : OldUser) : NewUser {
    {
      id = old.id;
      tenantId = old.tenantId;
      email = old.email;
      name = old.name;
      role = old.role;
      status = "active"; // New attribute default value
      createdAt = old.createdAt;
    }
  });
};
```

---

## Related

| Skill | Path |
|---|---|
| Architecture Layering | [`skills/layeringStandard/SKILL.md`](../layeringStandard/SKILL.md) |
| Migrations | [`skills/migrationStandard/SKILL.md`](../migrationStandard/SKILL.md) |
| Feature Integration | [`skills/integrationStandard/SKILL.md`](../integrationStandard/SKILL.md) |
| Error Handling | [`skills/errorHandlingStandard/SKILL.md`](../errorHandlingStandard/SKILL.md) |
