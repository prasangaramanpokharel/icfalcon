---
title: cacheTag
description: Learn how to use the cacheTag function to manage cache invalidation in your Next.js application.
url: "https://nextjs.org/docs/app/api-reference/functions/cacheTag"
docs_index: /docs/llms.txt
lastUpdated: 2026-09-29
prerequisites:
  - "API Reference: /docs/app/api-reference"
  - "Functions: /docs/app/api-reference/functions"
related:
  - /docs/app/api-reference/config/next-config-js/cacheComponents
  - /docs/app/api-reference/directives/use-cache
  - /docs/app/api-reference/functions/revalidateTag
  - /docs/app/api-reference/functions/updateTag
  - /docs/app/api-reference/functions/cacheLife
---

> For an index of all documentation, see [/docs/llms.txt](/docs/llms.txt).

The `cacheTag` function allows you to tag cached data for on-demand invalidation. By associating tags with cache entries, you can selectively purge or revalidate specific cache entries without affecting other cached data.

## Usage

To use `cacheTag`, enable the [`cacheComponents` flag](/docs/app/api-reference/config/next-config-js/cacheComponents) in your `next.config.js` file:

**TypeScript**

```ts title="next.config.ts" 
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  cacheComponents: true,
}

export default nextConfig
```

**JavaScript**

```js title="next.config.js" 
const nextConfig = {
  cacheComponents: true,
}

module.exports = nextConfig
```

The `cacheTag` function takes one or more string values.

**TypeScript**

```tsx title="app/data.ts" 
import { cacheTag } from 'next/cache'

export async function getData() {
  'use cache'
  cacheTag('my-data')
  const res = await fetch('https://api.example.com/data')
  const data = await res.json()
  return data
}
```

**JavaScript**

```jsx title="app/data.js" 
import { cacheTag } from 'next/cache'

export async function getData() {
  'use cache'
  cacheTag('my-data')
  const res = await fetch('https://api.example.com/data')
  const data = await res.json()
  return data
}
```

You can then purge the cache on-demand from a [Server Function](/docs/app/getting-started/mutating-data) or [Route Handler](/docs/app/api-reference/file-conventions/route):

- Use [`updateTag`](/docs/app/api-reference/functions/updateTag) for read-your-own-writes scenarios, such as forms and other user-triggered mutations, where a user makes a change and the next read should fetch fresh data immediately. `updateTag` is only available inside Server Functions.
- Use [`revalidateTag`](/docs/app/api-reference/functions/revalidateTag) when it is acceptable to serve stale data while revalidation happens in the background, or when revalidating from a [Route Handler](/docs/app/api-reference/file-conventions/route) or other context.

For example, this Server Function adds a post and then purges every cache entry tagged `'my-data'` so the next read reflects the change:

**TypeScript**

```tsx title="app/action.ts" 
'use server'

import { updateTag } from 'next/cache'

export default async function submit() {
  await addPost()
  updateTag('my-data')
}
```

**JavaScript**

```jsx title="app/action.js" 
'use server'

import { updateTag } from 'next/cache'

export default async function submit() {
  await addPost()
  updateTag('my-data')
}
```

## Good to know

- **Idempotent Tags**: Applying the same tag multiple times has no additional effect.
- **Multiple Tags**: You can assign multiple tags to a single cache entry by passing multiple string values to `cacheTag`.

```tsx
cacheTag('tag-one', 'tag-two')
```

- **Limits**: A single `cacheTag()` call accepts up to 128 tags, each with a maximum length of 256 characters. Tags longer than 256 characters are skipped, and any tags past the 128th in one call are dropped. Both cases log a console warning.

## Examples

### Tagging components or functions

Tag your cached data by calling `cacheTag` within a cached function or component:

**TypeScript**

```tsx title="app/components/bookings.tsx" 
import { cacheTag } from 'next/cache'

interface BookingsProps {
  type: string
}

export async function Bookings({ type = 'haircut' }: BookingsProps) {
  'use cache'
  cacheTag('bookings-data')

  async function getBookingsData() {
    const response = await fetch(
      `https://api.example.com/bookings?type=${encodeURIComponent(type)}`
    )
    const data = await response.json()
    return data
  }

  return //...
}
```

**JavaScript**

```jsx title="app/components/bookings.js" 
import { cacheTag } from 'next/cache'

export async function Bookings({ type = 'haircut' }) {
  'use cache'
  cacheTag('bookings-data')

  async function getBookingsData() {
    const response = await fetch(
      `https://api.example.com/bookings?type=${encodeURIComponent(type)}`
    )
    const data = await response.json()
    return data
  }

  return //...
}
```

### Creating tags from external data

You can use the data returned from an async function to tag the cache entry.

**TypeScript**

```tsx title="app/components/bookings.tsx" 
import { cacheTag } from 'next/cache'

interface BookingsProps {
  type: string
}

export async function Bookings({ type = 'haircut' }: BookingsProps) {
  async function getBookingsData() {
    'use cache'
    const response = await fetch(
      `https://api.example.com/bookings?type=${encodeURIComponent(type)}`
    )
    const data = await response.json()
    cacheTag('bookings-data', data.id)
    return data
  }
  return //...
}
```

**JavaScript**

```jsx title="app/components/bookings.js" 
import { cacheTag } from 'next/cache'

export async function Bookings({ type = 'haircut' }) {
  async function getBookingsData() {
    'use cache'
    const response = await fetch(
      `https://api.example.com/bookings?type=${encodeURIComponent(type)}`
    )
    const data = await response.json()
    cacheTag('bookings-data', data.id)
    return data
  }
  return //...
}
```

### Invalidating tagged cache

Using [`revalidateTag`](/docs/app/api-reference/functions/revalidateTag), you can invalidate the cache for a specific tag when needed:

**TypeScript**

```tsx title="app/actions.ts" 
'use server'

import { revalidateTag } from 'next/cache'

export async function updateBookings() {
  await updateBookingData()
  revalidateTag('bookings-data', 'max')
}
```

**JavaScript**

```jsx title="app/actions.js" 
'use server'

import { revalidateTag } from 'next/cache'

export async function updateBookings() {
  await updateBookingData()
  revalidateTag('bookings-data', 'max')
}
```

## Version History

| Version   | Changes                                                |
| --------- | ------------------------------------------------------ |
| `v16.0.0` | `cacheTag` stabilized. `unstable_cacheTag` deprecated. |

See the [Next.js 16 upgrade guide](/docs/app/guides/upgrading/version-16#cachelife-and-cachetag) to update imports from `unstable_cacheTag` to `cacheTag`.

## Related

View related API references.

- [cacheComponents](/docs/app/api-reference/config/next-config-js/cacheComponents): Learn how to enable the cacheComponents flag in Next.js.
- [use cache](/docs/app/api-reference/directives/use-cache): Learn how to use the "use cache" directive to cache data in your Next.js application.
- [revalidateTag](/docs/app/api-reference/functions/revalidateTag): API Reference for the revalidateTag function.
- [updateTag](/docs/app/api-reference/functions/updateTag): API Reference for the updateTag function.
- [cacheLife](/docs/app/api-reference/functions/cacheLife): Learn how to use the cacheLife function to set the cache expiration time for a cached function or component.

---

For a semantic overview of all documentation, see [/sitemap.md](/sitemap.md)

For an index of all available documentation, see [/docs/llms.txt](/docs/llms.txt)