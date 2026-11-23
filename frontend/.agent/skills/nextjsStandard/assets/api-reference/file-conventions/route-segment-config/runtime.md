---
title: runtime
description: API reference for the runtime route segment config option.
url: "https://nextjs.org/docs/app/api-reference/file-conventions/route-segment-config/runtime"
docs_index: /docs/llms.txt
lastUpdated: 2026-10-15
prerequisites:
  - "File-system conventions: /docs/app/api-reference/file-conventions"
  - "Route Segment Config: /docs/app/api-reference/file-conventions/route-segment-config"
---

> For an index of all documentation, see [/docs/llms.txt](/docs/llms.txt).

The `runtime` option allows you to select the JavaScript runtime used for rendering your route.

**TypeScript**

```tsx title="layout.tsx | page.tsx | route.ts" 
export const runtime = 'nodejs'
// 'nodejs'
```

**JavaScript**

```js title="layout.js | page.js | route.js" 
export const runtime = 'nodejs'
// 'nodejs'
```

- **`'nodejs'`** (default)
- **`'edge'`** (deprecated)

> **Good to know:**
>
> - The Edge Runtime is deprecated. Remove the `runtime` export from your route files. See [Edge Runtime Deprecated](/docs/messages/edge-runtime-deprecated).
> - When [Cache Components](/docs/app/api-reference/config/next-config-js/cacheComponents) is enabled, remove the `runtime` export, including `runtime = 'nodejs'`. Cache Components uses the default Node.js runtime and does not support the `runtime` route segment config. See [Migrating to Cache Components](/docs/app/guides/migrating-to-cache-components#runtime--edge).
> - This option cannot be used in [Proxy](/docs/app/api-reference/file-conventions/proxy).

---

For a semantic overview of all documentation, see [/sitemap.md](/sitemap.md)

For an index of all available documentation, see [/docs/llms.txt](/docs/llms.txt)