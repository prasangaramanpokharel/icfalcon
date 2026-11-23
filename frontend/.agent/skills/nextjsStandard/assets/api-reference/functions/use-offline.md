---
title: useOffline
description: API Reference for the useOffline hook.
url: "https://nextjs.org/docs/app/api-reference/functions/use-offline"
docs_index: /docs/llms.txt
lastUpdated: 2026-07-28
badge: "Experimental"
prerequisites:
  - "API Reference: /docs/app/api-reference"
  - "Functions: /docs/app/api-reference/functions"
related:
  - /docs/app/api-reference/config/next-config-js/useOffline
  - /docs/app/guides/progressive-web-apps
---

> For an index of all documentation, see [/docs/llms.txt](/docs/llms.txt).

The `useOffline` hook returns a boolean indicating whether the app is currently offline. Use it to render connectivity-aware UI, such as a banner when the user loses their network connection, or an offline-aware Suspense fallback.

The hook is one piece of a larger feature. Enabling the [`experimental.useOffline`](/docs/app/api-reference/config/next-config-js/useOffline) config option turns on offline connectivity detection and automatic retry of blocked navigation, prefetch, and Server Action requests, and exposes this hook so Client Components can read the state.

Without the flag, this hook always returns `false`.

```js title="next.config.js"
module.exports = {
  experimental: {
    useOffline: true,
  },
}
```

**TypeScript**

```tsx title="app/offline-status.tsx" 
'use client'

import { useOffline } from 'next/offline'

export function OfflineStatus() {
  const isOffline = useOffline()
  return <div>{isOffline ? 'Offline' : 'Online'}</div>
}
```

**JavaScript**

```jsx title="app/offline-status.js" 
'use client'

import { useOffline } from 'next/offline'

export function OfflineStatus() {
  const isOffline = useOffline()
  return <div>{isOffline ? 'Offline' : 'Online'}</div>
}
```

For details on how connectivity is detected and requests retried, see [How retry works](/docs/app/api-reference/config/next-config-js/useOffline#how-retry-works).

## Parameters

```tsx
const isOffline = useOffline()
```

`useOffline` does not take any parameters.

## Returns

`useOffline` returns a `boolean`:

| Value   | Meaning                                                                                                   |
| ------- | --------------------------------------------------------------------------------------------------------- |
| `true`  | The app is offline. A network request has failed, or the browser has fired an `offline` event.            |
| `false` | The app is online, or rendering on the server. This is also the initial value before hydration completes. |

## Examples

### Show an offline banner

Render a persistent banner whenever the user loses connectivity.

**TypeScript**

```tsx title="app/components/offline-banner.tsx" 
'use client'

import { useOffline } from 'next/offline'

export function OfflineBanner() {
  const isOffline = useOffline()

  if (!isOffline) {
    return null
  }

  return (
    <div role="status" className="offline-banner">
      You are offline. Some content may be unavailable.
    </div>
  )
}
```

**JavaScript**

```jsx title="app/components/offline-banner.js" 
'use client'

import { useOffline } from 'next/offline'

export function OfflineBanner() {
  const isOffline = useOffline()

  if (!isOffline) {
    return null
  }

  return (
    <div role="status" className="offline-banner">
      You are offline. Some content may be unavailable.
    </div>
  )
}
```

Render it in the root layout so the banner shows on every route:

**TypeScript**

```tsx title="app/layout.tsx" 
import { OfflineBanner } from './components/offline-banner'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html>
      <body>
        <OfflineBanner />
        {children}
      </body>
    </html>
  )
}
```

**JavaScript**

```jsx title="app/layout.js" 
import { OfflineBanner } from './components/offline-banner'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <OfflineBanner />
        {children}
      </body>
    </html>
  )
}
```

### Offline-aware Suspense fallback

When a user navigates to a route while offline, the prefetched static shell renders immediately but the dynamic content behind a `<Suspense>` boundary blocks on the network. For example, use `useOffline` inside a [`loading.tsx`](/docs/app/api-reference/file-conventions/loading) file to explain why the content is taking longer than expected.

**TypeScript**

```tsx title="app/destination/loading.tsx" 
'use client'

import { useOffline } from 'next/offline'

export default function Loading() {
  const isOffline = useOffline()

  return (
    <div>
      {isOffline ? 'Waiting for connection to load this page...' : 'Loading...'}
    </div>
  )
}
```

**JavaScript**

```jsx title="app/destination/loading.js" 
'use client'

import { useOffline } from 'next/offline'

export default function Loading() {
  const isOffline = useOffline()

  return (
    <div>
      {isOffline ? 'Waiting for connection to load this page...' : 'Loading...'}
    </div>
  )
}
```

When connectivity is restored, Next.js retries the blocked request and the dynamic content streams in automatically.

## Version History

| Version   | Changes                       |
| --------- | ----------------------------- |
| `v16.x.0` | `useOffline` hook introduced. |

- [useOffline](/docs/app/api-reference/config/next-config-js/useOffline): Learn how to enable the experimental \`useOffline\` configuration option to detect connectivity and retry failed requests automatically.
- [PWAs](/docs/app/guides/progressive-web-apps): Learn how to build a Progressive Web Application (PWA) with Next.js.

---

For a semantic overview of all documentation, see [/sitemap.md](/sitemap.md)

For an index of all available documentation, see [/docs/llms.txt](/docs/llms.txt)