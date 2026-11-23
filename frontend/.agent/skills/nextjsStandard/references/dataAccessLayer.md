# Data Access Layer (DAL) in Next.js App Router

## The DAL Principle
The Data Access Layer encapsulates authorization and database queries. It guarantees that client components and Server Actions cannot execute unauthorized or unverified queries.

```typescript
// src/data-access/users.ts
import "server-only";
import { db } from "@/lib/db";
import { getCurrentSession } from "@/lib/auth";
import { experimental_taintObjectReference } from "react";

export interface UserDTO {
  id: string;
  name: string;
  email: string;
}

export async function getCurrentUser(): Promise<UserDTO | null> {
  const session = await getCurrentSession();
  if (!session) return null;

  const rawUser = await db.user.findUnique({ where: { id: session.userId } });
  if (!rawUser) return null;

  // Taint internal database object so it cannot be serialized to the client
  experimental_taintObjectReference(
    "Never pass raw internal database records to client components",
    rawUser
  );

  // Return clean DTO
  return {
    id: rawUser.id,
    name: rawUser.name,
    email: rawUser.email,
  };
}
```
