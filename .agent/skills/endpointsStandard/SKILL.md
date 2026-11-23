---
name: endpointsStandard
description: >-
  IcFalcon API endpoint pattern — thin mixins in api/v1/, auth, delegate to service.
  Read when adding a single endpoint or API mixin.
---

# IcFalcon — Endpoints

Endpoints live in `backend/src/api/v1/` as **mixins** — no business logic.

## Pattern

```motoko
import Types "../../types";
import OrderService "../../services/OrderService";
import MiddlewareAuth "../../middleware/Auth";

mixin (
  service : OrderService.OrderService,
  mwConfig : MiddlewareAuth.Config,
) {
  public shared ({ caller }) func createOrder(name : Text) : async Types.ApiResult<Types.Order> {
    await OrderService.createOrder(
      service,
      MiddlewareAuth.effectiveCaller(mwConfig, caller),
      name,
    );
  };

  public query func getOrder(id : Text) : async ?Types.Order {
    OrderService.getOrder(service, id);
  };
};
```

## Endpoint Modifiers

| Modifier | Execution | Canister Calls? | Cycles Cost | Use For |
|---|---|---|---|---|
| `public query func` | Single node (no consensus) | No (internal state only) | **Free (0 cycles)** | Fast reads (<50ms) from local canister state |
| `public shared composite query func` | Single node tree evaluation | **Yes** (calls other canister queries) | **Free (0 cycles)** | Cross-canister dashboard & state aggregation |
| `public shared ({ caller }) func` | Subnet consensus (update) | **Yes** (inter-canister updates) | Costs cycles (~2-5M cycles) | State mutations, balance transfers, outbox events |

## Wire in main.mo

```motoko
include OrderApi(orderService, mwConfig);
```

## Rules

- `shared` for updates, `query` for reads
- Auth via `MiddlewareAuth.effectiveCaller`
- Return `Types.ApiResult<T>` for mutations
- Delegate immediately — no validation logic in api layer

## Scaffold

```bash
falcon m:f Order
```

Template: [`ops/templates/feature/Api.mo.tpl`](../../../ops/templates/feature/Api.mo.tpl)

## Related

| Skill | Path |
|---|---|
| Layering | [`layering/SKILL.md`](../layeringStandard/SKILL.md) |
| Error handling | [`errorHandling/SKILL.md`](../errorHandlingStandard/SKILL.md) |
| II auth | [`motokoStandard/internetIdentityAuthStandard/SKILL.md`](../motokoStandard/internetIdentityAuthStandard/SKILL.md) |
