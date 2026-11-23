---
title: forbidden.js
description: API reference for the forbidden.js special file.
url: "https://nextjs.org/docs/app/api-reference/file-conventions/forbidden"
docs_index: /docs/llms.txt
lastUpdated: 2026-11-06
badge: "Experimental"
prerequisites:
  - "API Reference: /docs/app/api-reference"
  - "File-system conventions: /docs/app/api-reference/file-conventions"
related:
  - /docs/app/api-reference/functions/forbidden
---

> For an index of all documentation, see [/docs/llms.txt](/docs/llms.txt).

The **forbidden** file renders UI when the [`forbidden`](/docs/app/api-reference/functions/forbidden) function is invoked.

Before streaming starts, Next.js returns a `403` status code. After streaming starts, the status code remains `200` and the forbidden UI renders in the response. Next.js injects a `<meta name="robots" content="noindex" />` tag in both cases. See [Status codes](/docs/app/api-reference/file-conventions/loading#status-codes) for details.

**TypeScript**

```tsx title="app/forbidden.tsx" 
import Link from 'next/link'

export default function Forbidden() {
  return (
    <div>
      <h2>Forbidden</h2>
      <p>You are not authorized to access this resource.</p>
      <Link href="/">Return Home</Link>
    </div>
  )
}
```

**JavaScript**

```jsx title="app/forbidden.jsx" 
import Link from 'next/link'

export default function Forbidden() {
  return (
    <div>
      <h2>Forbidden</h2>
      <p>You are not authorized to access this resource.</p>
      <Link href="/">Return Home</Link>
    </div>
  )
}
```

## Reference

### Props

`forbidden.js` components do not accept any props.

> **Good to know:**
>
> Next.js sends each `forbidden.js` file with every route under its segment, even when `forbidden()` is never called, and loads the Client Components it imports on those pages. Prefer Server Components and [`<Link>`](/docs/app/api-reference/components/link) there over interactive UI.

## Version History

| Version   | Changes                    |
| --------- | -------------------------- |
| `v15.1.0` | `forbidden.js` introduced. |

- [forbidden](/docs/app/api-reference/functions/forbidden): API Reference for the forbidden function.

---

For a semantic overview of all documentation, see [/sitemap.md](/sitemap.md)

For an index of all available documentation, see [/docs/llms.txt](/docs/llms.txt)