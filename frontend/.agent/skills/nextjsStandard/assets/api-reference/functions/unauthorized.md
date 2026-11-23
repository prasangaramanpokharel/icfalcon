---
title: unauthorized
description: API Reference for the unauthorized function.
url: "https://nextjs.org/docs/app/api-reference/functions/unauthorized"
docs_index: /docs/llms.txt
lastUpdated: 2026-11-06
badge: "Experimental"
prerequisites:
  - "API Reference: /docs/app/api-reference"
  - "Functions: /docs/app/api-reference/functions"
related:
  - /docs/app/api-reference/file-conventions/unauthorized
  - /docs/app/api-reference/functions/not-found
  - /docs/app/api-reference/functions/forbidden
  - /docs/app/api-reference/config/next-config-js/authInterrupts
---

> For an index of all documentation, see [/docs/llms.txt](/docs/llms.txt).

The `unauthorized` function throws an error that renders the unauthorized UI. It's useful for handling authentication errors when a request is not signed in. You can customize the UI using the [`unauthorized.js` file](/docs/app/api-reference/file-conventions/unauthorized).

Invoking `unauthorized()` throws a `NEXT_HTTP_ERROR_FALLBACK;401` error and terminates rendering of the route segment where it was thrown. Next.js also injects a `<meta name="robots" content="noindex" />` tag so the page is not indexed. Because it works by throwing, call it in the render path: a component, or a function a component `await`s. A call left in an un-awaited promise throws where nothing catches it, and no unauthorized UI renders.

To start using `unauthorized`, enable the experimental [`authInterrupts`](/docs/app/api-reference/config/next-config-js/authInterrupts) configuration option in your `next.config.js` file:

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

`unauthorized` can be invoked in [Server Components](/docs/app/getting-started/server-and-client-components), [Server Functions](/docs/app/getting-started/mutating-data), and [Route Handlers](/docs/app/api-reference/file-conventions/route).

**TypeScript**

```tsx title="app/dashboard/page.tsx" 
import { verifySession } from '@/app/lib/dal'
import { unauthorized } from 'next/navigation'

export default async function DashboardPage() {
  const session = await verifySession()

  if (!session) {
    unauthorized()
  }

  // Render the dashboard for authenticated users
  return (
    <main>
      <h1>Welcome to the Dashboard</h1>
      <p>Hi, {session.user.name}.</p>
    </main>
  )
}
```

**JavaScript**

```jsx title="app/dashboard/page.js" 
import { verifySession } from '@/app/lib/dal'
import { unauthorized } from 'next/navigation'

export default async function DashboardPage() {
  const session = await verifySession()

  if (!session) {
    unauthorized()
  }

  // Render the dashboard for authenticated users
  return (
    <main>
      <h1>Welcome to the Dashboard</h1>
      <p>Hi, {session.user.name}.</p>
    </main>
  )
}
```

## Good to know

- The `unauthorized` function cannot be called in the [root layout](/docs/app/api-reference/file-conventions/layout#root-layout).
- You do not need to write `return unauthorized()`. It throws (its TypeScript [`never`](https://www.typescriptlang.org/docs/handbook/2/functions.html#never) return type), so execution stops. A `try/catch` around the call suppresses the interrupt and no unauthorized UI renders. Use [`unstable_rethrow`](/docs/app/api-reference/functions/unstable_rethrow) to let it through.
- An `unauthorized()` left in an un-awaited promise throws where nothing catches it, so no unauthorized UI renders. In development the server logs `⨯ unhandledRejection: NEXT_HTTP_ERROR_FALLBACK;401`. Always `await` the function that may call it.

## Examples

### Calling `unauthorized()` after streaming has started

To keep the page's shell and loading UI visible while the session is verified, put the auth check in the [Data Access Layer](/docs/app/guides/authentication#creating-a-data-access-layer-dal) function that loads the data, and render it in a component wrapped in [`<Suspense>`](https://react.dev/reference/react/Suspense). The check runs inside the boundary, so the shell streams while the session resolves:

**TypeScript**

```tsx highlight={8} title="app/account/page.tsx" 
import { Suspense } from 'react'
import { verifySession } from '@/app/lib/dal'
import { unauthorized } from 'next/navigation'

async function getAccount() {
  const session = await verifySession()
  if (!session) {
    unauthorized()
  }
  return db.accounts.findByUserId(session.userId)
}

async function AccountDetails() {
  const account = await getAccount()
  return <p>Signed in as {account.email}</p>
}

export default function AccountPage() {
  return (
    <main>
      <h1>Account</h1>
      <Suspense fallback={<p>Loading...</p>}>
        <AccountDetails />
      </Suspense>
    </main>
  )
}
```

**JavaScript**

```jsx highlight={8} title="app/account/page.js" 
import { Suspense } from 'react'
import { verifySession } from '@/app/lib/dal'
import { unauthorized } from 'next/navigation'

async function getAccount() {
  const session = await verifySession()
  if (!session) {
    unauthorized()
  }
  return db.accounts.findByUserId(session.userId)
}

async function AccountDetails() {
  const account = await getAccount()
  return <p>Signed in as {account.email}</p>
}

export default function AccountPage() {
  return (
    <main>
      <h1>Account</h1>
      <Suspense fallback={<p>Loading...</p>}>
        <AccountDetails />
      </Suspense>
    </main>
  )
}
```

When the request isn't signed in, `getAccount` calls `unauthorized()`, which throws. Because this happens during rendering, the exception propagates to the nearest [`unauthorized`](/docs/app/api-reference/file-conventions/unauthorized) boundary, which renders in place of the streamed-in content, even though the page shell has already been sent.

Add an `unauthorized.tsx` alongside the route to define that UI:

**TypeScript**

```tsx title="app/account/unauthorized.tsx" 
import Link from 'next/link'

export default function Unauthorized() {
  return (
    <main>
      <h1>401 - Unauthorized</h1>
      <p>
        Please <Link href="/login">sign in</Link> to view your account.
      </p>
    </main>
  )
}
```

**JavaScript**

```jsx title="app/account/unauthorized.js" 
import Link from 'next/link'

export default function Unauthorized() {
  return (
    <main>
      <h1>401 - Unauthorized</h1>
      <p>
        Please <Link href="/login">sign in</Link> to view your account.
      </p>
    </main>
  )
}
```

The response starts streaming from the `<Suspense>` boundary before `unauthorized()` runs, so it keeps its `200` status. Next.js adds a `noindex` tag.

`unauthorized()` returns a `401` when it runs before the response starts, including during prerendering. See [Status codes](/docs/app/api-reference/file-conventions/loading#status-codes).

### Displaying login UI to unauthenticated users

You can use `unauthorized` function to display the `unauthorized.js` file with a login UI.

**TypeScript**

```tsx title="app/dashboard/page.tsx" 
import { verifySession } from '@/app/lib/dal'
import { unauthorized } from 'next/navigation'

export default async function DashboardPage() {
  const session = await verifySession()

  if (!session) {
    unauthorized()
  }

  return <div>Dashboard</div>
}
```

```tsx title="app/unauthorized.tsx" 
import Login from '@/app/components/Login'

export default function UnauthorizedPage() {
  return (
    <main>
      <h1>401 - Unauthorized</h1>
      <p>Please log in to access this page.</p>
      <Login />
    </main>
  )
}
```

**JavaScript**

```jsx title="app/dashboard/page.js" 
import { verifySession } from '@/app/lib/dal'
import { unauthorized } from 'next/navigation'

export default async function DashboardPage() {
  const session = await verifySession()

  if (!session) {
    unauthorized()
  }

  return <div>Dashboard</div>
}
```

```jsx title="app/unauthorized.js" 
import Login from '@/app/components/Login'

export default function UnauthorizedPage() {
  return (
    <main>
      <h1>401 - Unauthorized</h1>
      <p>Please log in to access this page.</p>
      <Login />
    </main>
  )
}
```

### Mutations with Server Actions

You can invoke `unauthorized` in Server Actions to ensure only authenticated users can perform specific mutations.

**TypeScript**

```ts title="app/actions/update-profile.ts" 
'use server'

import { verifySession } from '@/app/lib/dal'
import { unauthorized } from 'next/navigation'
import db from '@/app/lib/db'

export async function updateProfile(data: FormData) {
  const session = await verifySession()

  // If unauthenticated, render the nearest unauthorized boundary
  if (!session) {
    unauthorized()
  }

  // Proceed with mutation
  // ...
}
```

**JavaScript**

```js title="app/actions/update-profile.js" 
'use server'

import { verifySession } from '@/app/lib/dal'
import { unauthorized } from 'next/navigation'
import db from '@/app/lib/db'

export async function updateProfile(data) {
  const session = await verifySession()

  // If unauthenticated, render the nearest unauthorized boundary
  if (!session) {
    unauthorized()
  }

  // Proceed with mutation
  // ...
}
```

### Fetching data with Route Handlers

You can use `unauthorized` in Route Handlers to ensure only authenticated users can access the endpoint.

**TypeScript**

```tsx title="app/api/profile/route.ts" 
import { NextRequest, NextResponse } from 'next/server'
import { verifySession } from '@/app/lib/dal'
import { unauthorized } from 'next/navigation'

export async function GET(req: NextRequest): Promise<NextResponse> {
  // Verify the user's session
  const session = await verifySession()

  // If no session exists, return an empty 401 response
  if (!session) {
    unauthorized()
  }

  // Fetch data
  // ...
}
```

**JavaScript**

```jsx title="app/api/profile/route.js" 
import { verifySession } from '@/app/lib/dal'
import { unauthorized } from 'next/navigation'

export async function GET() {
  const session = await verifySession()

  // If the user is not authenticated, return an empty 401 response
  if (!session) {
    unauthorized()
  }

  // Fetch data
  // ...
}
```

## Version History

| Version   | Changes                    |
| --------- | -------------------------- |
| `v15.1.0` | `unauthorized` introduced. |

- [unauthorized.js](/docs/app/api-reference/file-conventions/unauthorized): API reference for the unauthorized.js special file.
- [notFound](/docs/app/api-reference/functions/not-found): API Reference for the notFound function.
- [forbidden](/docs/app/api-reference/functions/forbidden): API Reference for the forbidden function.
- [authInterrupts](/docs/app/api-reference/config/next-config-js/authInterrupts): Learn how to enable the experimental \`authInterrupts\` configuration option to use \`forbidden\` and \`unauthorized\`.

---

For a semantic overview of all documentation, see [/sitemap.md](/sitemap.md)

For an index of all available documentation, see [/docs/llms.txt](/docs/llms.txt)