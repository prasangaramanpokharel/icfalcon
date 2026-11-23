---
title: unauthorized.js
description: API reference for the unauthorized.js special file.
url: "https://nextjs.org/docs/app/api-reference/file-conventions/unauthorized"
docs_index: /docs/llms.txt
lastUpdated: 2026-11-06
badge: "Experimental"
prerequisites:
  - "API Reference: /docs/app/api-reference"
  - "File-system conventions: /docs/app/api-reference/file-conventions"
related:
  - /docs/app/api-reference/functions/unauthorized
---

> For an index of all documentation, see [/docs/llms.txt](/docs/llms.txt).

The **unauthorized** file renders UI when the [`unauthorized`](/docs/app/api-reference/functions/unauthorized) function is invoked.

Before streaming starts, Next.js returns a `401` status code. After streaming starts, the status code remains `200` and the unauthorized UI renders in the response. Next.js injects a `<meta name="robots" content="noindex" />` tag in both cases. See [Status codes](/docs/app/api-reference/file-conventions/loading#status-codes) for details.

**TypeScript**

```tsx title="app/unauthorized.tsx" 
import Login from '@/app/components/Login'

export default function Unauthorized() {
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

```jsx title="app/unauthorized.js" 
import Login from '@/app/components/Login'

export default function Unauthorized() {
  return (
    <main>
      <h1>401 - Unauthorized</h1>
      <p>Please log in to access this page.</p>
      <Login />
    </main>
  )
}
```

## Reference

### Props

`unauthorized.js` components do not accept any props.

> **Good to know:**
>
> Next.js sends each `unauthorized.js` file with every route under its segment, even when `unauthorized()` is never called, and loads the Client Components it imports on those pages. Prefer Server Components and [`<Link>`](/docs/app/api-reference/components/link) there over interactive UI.

## Examples

### Displaying login UI to unauthenticated users

You can use [`unauthorized`](/docs/app/api-reference/functions/unauthorized) function to render the `unauthorized.js` file with a login UI.

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

## Version History

| Version   | Changes                       |
| --------- | ----------------------------- |
| `v15.1.0` | `unauthorized.js` introduced. |

- [unauthorized](/docs/app/api-reference/functions/unauthorized): API Reference for the unauthorized function.

---

For a semantic overview of all documentation, see [/sitemap.md](/sitemap.md)

For an index of all available documentation, see [/docs/llms.txt](/docs/llms.txt)