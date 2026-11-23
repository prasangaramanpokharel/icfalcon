---
title: forbidden
description: API Reference for the forbidden function.
url: "https://nextjs.org/docs/app/api-reference/functions/forbidden"
docs_index: /docs/llms.txt
lastUpdated: 2026-11-06
badge: "Experimental"
prerequisites:
  - "API Reference: /docs/app/api-reference"
  - "Functions: /docs/app/api-reference/functions"
related:
  - /docs/app/api-reference/file-conventions/forbidden
  - /docs/app/api-reference/functions/not-found
  - /docs/app/api-reference/functions/unauthorized
  - /docs/app/api-reference/config/next-config-js/authInterrupts
---

> For an index of all documentation, see [/docs/llms.txt](/docs/llms.txt).

The `forbidden` function throws an error that renders the forbidden UI. It's useful for handling authorization errors in your application. You can customize the UI using the [`forbidden.js` file](/docs/app/api-reference/file-conventions/forbidden).

Invoking `forbidden()` throws a `NEXT_HTTP_ERROR_FALLBACK;403` error and terminates rendering of the route segment where it was thrown. Next.js also injects a `<meta name="robots" content="noindex" />` tag so the page is not indexed. Because it works by throwing, call it in the render path: a component, or a function a component `await`s. A call left in an un-awaited promise throws where nothing catches it, and no forbidden UI renders.

To start using `forbidden`, enable the experimental [`authInterrupts`](/docs/app/api-reference/config/next-config-js/authInterrupts) configuration option in your `next.config.js` file:

**TypeScript**

```ts title="next.config.ts" 
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  experimental: {
    authInterrupts: true,
  },
}

export default nextConfig
```

**JavaScript**

```js title="next.config.js" 
module.exports = {
  experimental: {
    authInterrupts: true,
  },
}
```

`forbidden` can be invoked in [Server Components](/docs/app/getting-started/server-and-client-components), [Server Functions](/docs/app/getting-started/mutating-data), and [Route Handlers](/docs/app/api-reference/file-conventions/route).

**TypeScript**

```tsx title="app/admin/page.tsx" 
import { verifySession } from '@/app/lib/dal'
import { forbidden } from 'next/navigation'

export default async function AdminPage() {
  const session = await verifySession()

  // Check if the user has the 'admin' role
  if (session.role !== 'admin') {
    forbidden()
  }

  // Render the admin page for authorized users
  return <></>
}
```

**JavaScript**

```jsx title="app/admin/page.js" 
import { verifySession } from '@/app/lib/dal'
import { forbidden } from 'next/navigation'

export default async function AdminPage() {
  const session = await verifySession()

  // Check if the user has the 'admin' role
  if (session.role !== 'admin') {
    forbidden()
  }

  // Render the admin page for authorized users
  return <></>
}
```

## Good to know

- The `forbidden` function cannot be called in the [root layout](/docs/app/api-reference/file-conventions/layout#root-layout).
- You do not need to write `return forbidden()`. It throws (its TypeScript [`never`](https://www.typescriptlang.org/docs/handbook/2/functions.html#never) return type), so execution stops. A `try/catch` around the call suppresses the interrupt and no forbidden UI renders. Use [`unstable_rethrow`](/docs/app/api-reference/functions/unstable_rethrow) to let it through.
- A `forbidden()` left in an un-awaited promise throws where nothing catches it, so no forbidden UI renders. In development the server logs `⨯ unhandledRejection: NEXT_HTTP_ERROR_FALLBACK;403`. Always `await` the function that may call it.

## Examples

### Calling `forbidden()` after streaming has started

To keep the page's shell and loading UI visible while the session is checked, put the role check in the [Data Access Layer](/docs/app/guides/authentication#creating-a-data-access-layer-dal) function that loads the data, and render it in a component wrapped in [`<Suspense>`](https://react.dev/reference/react/Suspense). The check runs inside the boundary, so the shell streams while the session resolves:

**TypeScript**

```tsx highlight={8} title="app/projects/page.tsx" 
import { Suspense } from 'react'
import { verifySession } from '@/app/lib/dal'
import { forbidden } from 'next/navigation'

async function getProjects() {
  const session = await verifySession()
  if (session?.role !== 'admin') {
    forbidden()
  }
  return db.projects.findMany()
}

async function Projects() {
  const projects = await getProjects()
  return (
    <ul>
      {projects.map((project) => (
        <li key={project.id}>{project.name}</li>
      ))}
    </ul>
  )
}

export default function ProjectsPage() {
  return (
    <main>
      <h1>Projects</h1>
      <Suspense fallback={<p>Loading...</p>}>
        <Projects />
      </Suspense>
    </main>
  )
}
```

**JavaScript**

```jsx highlight={8} title="app/projects/page.js" 
import { Suspense } from 'react'
import { verifySession } from '@/app/lib/dal'
import { forbidden } from 'next/navigation'

async function getProjects() {
  const session = await verifySession()
  if (session?.role !== 'admin') {
    forbidden()
  }
  return db.projects.findMany()
}

async function Projects() {
  const projects = await getProjects()
  return (
    <ul>
      {projects.map((project) => (
        <li key={project.id}>{project.name}</li>
      ))}
    </ul>
  )
}

export default function ProjectsPage() {
  return (
    <main>
      <h1>Projects</h1>
      <Suspense fallback={<p>Loading...</p>}>
        <Projects />
      </Suspense>
    </main>
  )
}
```

When the session lacks access, `getProjects` calls `forbidden()`, which throws. Because this happens during rendering, the exception propagates to the nearest [`forbidden`](/docs/app/api-reference/file-conventions/forbidden) boundary, which renders in place of the streamed-in content, even though the page shell has already been sent.

Add a `forbidden.tsx` alongside the route to define that UI:

**TypeScript**

```tsx title="app/projects/forbidden.tsx" 
export default function Forbidden() {
  return (
    <main>
      <h1>403 - Forbidden</h1>
      <p>You don't have access to this page.</p>
    </main>
  )
}
```

**JavaScript**

```jsx title="app/projects/forbidden.js" 
export default function Forbidden() {
  return (
    <main>
      <h1>403 - Forbidden</h1>
      <p>You don't have access to this page.</p>
    </main>
  )
}
```

The response starts streaming from the `<Suspense>` boundary before `forbidden()` runs, so it keeps its `200` status. Next.js adds a `noindex` tag.

`forbidden()` returns a `403` when it runs before the response starts, including during prerendering. See [Status codes](/docs/app/api-reference/file-conventions/loading#status-codes).

### Role-based route protection

You can use `forbidden` to restrict access to certain routes based on user roles. This ensures that users who are authenticated but lack the required permissions cannot access the route.

**TypeScript**

```tsx title="app/admin/page.tsx" 
import { verifySession } from '@/app/lib/dal'
import { forbidden } from 'next/navigation'

export default async function AdminPage() {
  const session = await verifySession()

  // Check if the user has the 'admin' role
  if (session.role !== 'admin') {
    forbidden()
  }

  // Render the admin page for authorized users
  return (
    <main>
      <h1>Admin Dashboard</h1>
      <p>Welcome, {session.user.name}!</p>
    </main>
  )
}
```

**JavaScript**

```jsx title="app/admin/page.js" 
import { verifySession } from '@/app/lib/dal'
import { forbidden } from 'next/navigation'

export default async function AdminPage() {
  const session = await verifySession()

  // Check if the user has the 'admin' role
  if (session.role !== 'admin') {
    forbidden()
  }

  // Render the admin page for authorized users
  return (
    <main>
      <h1>Admin Dashboard</h1>
      <p>Welcome, {session.user.name}!</p>
    </main>
  )
}
```

### Mutations with Server Actions

When implementing mutations in Server Actions, you can use `forbidden` to only allow users with a specific role to update sensitive data.

**TypeScript**

```ts title="app/actions/update-role.ts" 
'use server'

import { verifySession } from '@/app/lib/dal'
import { forbidden } from 'next/navigation'
import db from '@/app/lib/db'

export async function updateRole(formData: FormData) {
  const session = await verifySession()

  // Ensure only admins can update roles
  if (session.role !== 'admin') {
    forbidden()
  }

  // Perform the role update for authorized users
  // ...
}
```

**JavaScript**

```js title="app/actions/update-role.js" 
'use server'

import { verifySession } from '@/app/lib/dal'
import { forbidden } from 'next/navigation'
import db from '@/app/lib/db'

export async function updateRole(formData) {
  const session = await verifySession()

  // Ensure only admins can update roles
  if (session.role !== 'admin') {
    forbidden()
  }

  // Perform the role update for authorized users
  // ...
}
```

## Version History

| Version   | Changes                 |
| --------- | ----------------------- |
| `v15.1.0` | `forbidden` introduced. |

- [forbidden.js](/docs/app/api-reference/file-conventions/forbidden): API reference for the forbidden.js special file.
- [notFound](/docs/app/api-reference/functions/not-found): API Reference for the notFound function.
- [unauthorized](/docs/app/api-reference/functions/unauthorized): API Reference for the unauthorized function.
- [authInterrupts](/docs/app/api-reference/config/next-config-js/authInterrupts): Learn how to enable the experimental \`authInterrupts\` configuration option to use \`forbidden\` and \`unauthorized\`.

---

For a semantic overview of all documentation, see [/sitemap.md](/sitemap.md)

For an index of all available documentation, see [/docs/llms.txt](/docs/llms.txt)