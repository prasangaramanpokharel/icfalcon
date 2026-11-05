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
- Querying records with filtering, sorting, and pagination (`where`, `orderBy`, `paginate`)
- Safely evolving data models across canister upgrades with 1-line schema migrations

---

## 1. Table & Index Definition

Always normalize entities into atomic tables (3NF). Use foreign keys instead of embedding unbounded nested arrays:

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
public let UserTable = ORM.createTable<User>({
  name = "users";
  primaryKey = func(u : User) : Text { u.id };
  indices = [
    {
      name = "email";
      indexType = #unique; // Enforces unique email constraint
      extractKey = func(u : User) : Text { u.email };
    },
    {
      name = "tenantId";
      indexType = #foreignKey; // 1-to-Many group index
      extractKey = func(u : User) : Text { u.tenantId };
    },
    {
      name = "role";
      indexType = #index; // Non-unique filter index
      extractKey = func(u : User) : Text { u.role };
    },
  ];
});
```

---

## 2. CRUD Operations

```motoko
// Insert: Validates unique constraints & auto-indexes all keys
let result = UserTable.insert(newUser); // Result<User, Text>

// Primary Key lookup: O(1)
let user = UserTable.findById("u-123"); // ?User

// Unique Index lookup: O(1)
let byEmail = UserTable.findOneByIndex("email", "alice@example.com"); // ?User

// Foreign Key / Group lookup: O(1)
let tenantUsers = UserTable.findManyByIndex("tenantId", "tenant-1"); // [User]

// Update: Diffs modified fields and re-indexes dirty indices atomically
UserTable.update("u-123", func(u : User) : User {
  { u with role = "admin" }
});

// Delete: Removes primary key and purges all secondary indices
UserTable.delete("u-123");
```

---

## 3. 3NF Relational Queries

Resolve parent-child relationships through normalized foreign keys:

```motoko
// Resolves 1-to-Many (e.g. User hasMany Orders)
let userOrders = ORM.hasMany<User, Order>(
  user,
  func(u : User) { u.id },
  OrderTable,
  "userId"
);

// Resolves Many-to-1 (e.g. Order belongsTo User)
let orderOwner = ORM.belongsTo<Order, User>(
  order,
  func(o : Order) { o.userId },
  UserTable
);
```

---

## 4. Query Builder (Filter, Sort, Paginate)

```motoko
let page = UserTable.builder()
  .where(func(u : User) : Bool { u.role == "admin" })
  .orderBy(func(a : User, b : User) : Bool { a.createdAt > b.createdAt }) // Newest first
  .paginate(0, 20); // offset = 0, limit = 20

// Returns:
// { items = [User]; total = 42; offset = 0; limit = 20; hasMore = true }
```

---

## 5. Schema Migration (1-Line Upgrades)

When upgrading canister state with new attributes:

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
