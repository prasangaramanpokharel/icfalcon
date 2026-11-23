---
title: Parallel Routes
description: Simultaneously render one or more pages in the same view that can be navigated independently. A pattern for highly dynamic applications.
url: "https://nextjs.org/docs/app/api-reference/file-conventions/parallel-routes"
docs_index: /docs/llms.txt
lastUpdated: 2026-10-15
prerequisites:
  - "API Reference: /docs/app/api-reference"
  - "File-system conventions: /docs/app/api-reference/file-conventions"
related:
  - /docs/app/api-reference/file-conventions/default
  - /docs/app/guides/authentication
---

> For an index of all documentation, see [/docs/llms.txt](/docs/llms.txt).

Parallel Routes allows you to simultaneously or conditionally render one or more pages within the same layout. They are useful for highly dynamic sections of an app, such as dashboards and feeds on social sites.

For example, considering a dashboard, you can use parallel routes to simultaneously render the `team` and `analytics` pages:

![Parallel Routes Diagram](/docs/light/parallel-routes.png)

## Convention

### Slots

Parallel routes are created using named **slots**. Slots are defined with the `@folder` convention. For example, the following file structure defines two slots: `@analytics` and `@team`:

![Parallel Routes File-system Structure](/docs/light/parallel-routes-file-system.png)

Slots are passed as props to the shared parent layout. For the example above, the component in `app/layout.js` now accepts the `@analytics` and `@team` slots props, and can render them in parallel alongside the `children` prop:

**TypeScript**

```tsx title="app/layout.tsx" 
export default function Layout({
  children,
  team,
  analytics,
}: {
  children: React.ReactNode
  analytics: React.ReactNode
  team: React.ReactNode
}) {
  return (
    <>
      {children}
      {team}
      {analytics}
    </>
  )
}
```

**JavaScript**

```jsx title="app/layout.js" 
export default function Layout({ children, team, analytics }) {
  return (
    <>
      {children}
      {team}
      {analytics}
    </>
  )
}
```

However, slots are **not** route segments and do not affect the URL structure. For example, for `/@analytics/views`, the URL will be `/views` since `@analytics` is a slot. Slots are combined with the regular [Page](/docs/app/api-reference/file-conventions/page) component to form the final page associated with the route segment. Because of this, you cannot have separate [prerendered](/docs/app/glossary#prerendering) and [dynamically rendered](/docs/app/glossary#dynamic-rendering) slots at the same route segment level. If one slot is dynamic, all slots at that level must be dynamic.

> **Good to know:**
>
> - The `children` prop is an implicit slot that does not need to be mapped to a folder. This means `app/page.js` is equivalent to `app/@children/page.js`.

### `default.js`

You can define a `default.js` file to render as a fallback for unmatched slots during the initial load or full-page reload.

Consider the following folder structure. The `@team` slot has a `/settings` page, but `@analytics` does not.

![Parallel Routes unmatched routes](/docs/light/parallel-routes-unmatched-routes.png)

When navigating to `/settings`, the `@team` slot will render the `/settings` page while maintaining the currently active page for the `@analytics` slot.

On refresh, Next.js will render a `default.js` for `@analytics`. If `default.js` doesn't exist, a `404` is rendered instead.

Additionally, since `children` is an implicit slot, you also need to create a `default.js` file to render a fallback for `children` when Next.js cannot recover the active state of the parent page.

## Behavior

By default, Next.js keeps track of the active *state* (or subpage) for each slot. However, the content rendered within a slot will depend on the type of navigation:

- [**Soft Navigation**](/docs/app/getting-started/linking-and-navigating#client-side-transitions): During client-side navigation, Next.js will perform a [partial render](/docs/app/getting-started/linking-and-navigating#client-side-transitions), changing the subpage within the slot, while maintaining the other slot's active subpages, even if they don't match the current URL.
- **Hard Navigation**: After a full-page load (browser refresh), Next.js cannot determine the active state for the slots that don't match the current URL. Instead, it will render a [`default.js`](#defaultjs) file for the unmatched slots, or `404` if `default.js` doesn't exist.

> **Good to know:**
>
> - The `404` for unmatched routes helps ensure that you don't accidentally render a parallel route on a page that it was not intended for.

## Examples

### With `useSelectedLayoutSegment(s)`

Both [`useSelectedLayoutSegment`](/docs/app/api-reference/functions/use-selected-layout-segment) and [`useSelectedLayoutSegments`](/docs/app/api-reference/functions/use-selected-layout-segments) accept a `parallelRouteKey` parameter, which allows you to read the active route segment within a slot.

**TypeScript**

```tsx title="app/layout.tsx" 
'use client'

import { useSelectedLayoutSegment } from 'next/navigation'

export default function Layout({ auth }: { auth: React.ReactNode }) {
  const loginSegment = useSelectedLayoutSegment('auth')
  // ...
}
```

**JavaScript**

```jsx title="app/layout.js" 
'use client'

import { useSelectedLayoutSegment } from 'next/navigation'

export default function Layout({ auth }) {
  const loginSegment = useSelectedLayoutSegment('auth')
  // ...
}
```

When a user navigates to `app/@auth/login` (or `/login` in the URL bar), `loginSegment` will be equal to the string `"login"`.

### Conditional Routes

You can use Parallel Routes to conditionally render routes based on certain conditions, such as user role. For example, to render a different dashboard page for the `/admin` or `/user` roles:

![Conditional routes diagram](/docs/light/conditional-routes-ui.png)

**TypeScript**

```tsx title="app/dashboard/layout.tsx" 
import { checkUserRole } from '@/lib/auth'

export default function Layout({
  user,
  admin,
}: {
  user: React.ReactNode
  admin: React.ReactNode
}) {
  const role = checkUserRole()
  return role === 'admin' ? admin : user
}
```

**JavaScript**

```jsx title="app/dashboard/layout.js" 
import { checkUserRole } from '@/lib/auth'

export default function Layout({ user, admin }) {
  const role = checkUserRole()
  return role === 'admin' ? admin : user
}
```

Both slots render on the server, regardless of which one the layout returns. The conditional decides what the user sees, not what runs: `@admin/page.js` executes its data fetches for every user, and its output is included in the response sent to the browser. Authorize inside each slot's page, or in your [Data Access Layer](/docs/app/guides/authentication#creating-a-data-access-layer-dal):

**TypeScript**

```tsx title="app/dashboard/@admin/page.tsx" 
import { getAdminStats } from '@/lib/dal'

export default async function AdminPage() {
  const stats = await getAdminStats()
  return <Stats stats={stats} />
}
```

**JavaScript**

```jsx title="app/dashboard/@admin/page.js" 
import { getAdminStats } from '@/lib/dal'

export default async function AdminPage() {
  const stats = await getAdminStats()
  return <Stats stats={stats} />
}
```

### Tab Groups

You can add a `layout` inside a slot to allow users to navigate the slot independently. This is useful for creating tabs.

For example, the `@analytics` slot has two subpages: `/page-views` and `/visitors`.

![Analytics slot with two subpages and a layout](/docs/light/parallel-routes-tab-groups.png)

Within `@analytics`, create a [`layout`](/docs/app/api-reference/file-conventions/layout) file to share the tabs between the two pages:

**TypeScript**

```tsx title="app/@analytics/layout.tsx" 
import Link from 'next/link'

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <nav>
        <Link href="/page-views">Page Views</Link>
        <Link href="/visitors">Visitors</Link>
      </nav>
      <div>{children}</div>
    </>
  )
}
```

**JavaScript**

```jsx title="app/@analytics/layout.js" 
import Link from 'next/link'

export default function Layout({ children }) {
  return (
    <>
      <nav>
        <Link href="/page-views">Page Views</Link>
        <Link href="/visitors">Visitors</Link>
      </nav>
      <div>{children}</div>
    </>
  )
}
```

### Modals

Parallel Routes can be used together with [Intercepting Routes](/docs/app/api-reference/file-conventions/intercepting-routes) to create modals that support deep linking. This allows you to solve common challenges when building modals, such as:

- Making the modal content **shareable through a URL**.
- **Preserving context** when the page is refreshed, instead of closing the modal.
- **Closing the modal on backwards navigation** rather than going to the previous route.
- **Reopening the modal on forwards navigation**.

Consider the following UI pattern, where a user can open a login modal from a layout using client-side navigation, or access a separate `/login` page:

![Parallel Routes Diagram](/docs/light/parallel-routes-auth-modal.png)

To implement this pattern, start by creating a `/login` route that renders your **main** login page.

![Parallel Routes Diagram](/docs/light/parallel-routes-modal-login-page.png)

**TypeScript**

```tsx title="app/login/page.tsx" 
import { Login } from '@/app/ui/login'

export default function Page() {
  return <Login />
}
```

**JavaScript**

```jsx title="app/login/page.js" 
import { Login } from '@/app/ui/login'

export default function Page() {
  return <Login />
}
```

Then, inside the `@auth` slot, add [`default.js`](/docs/app/api-reference/file-conventions/default) file that returns `null`. This ensures that the modal is not rendered when it's not active.

**TypeScript**

```tsx title="app/@auth/default.tsx" 
export default function Default() {
  return null
}
```

**JavaScript**

```jsx title="app/@auth/default.js" 
export default function Default() {
  return null
}
```

Inside your `@auth` slot, intercept the `/login` route by importing the `<Modal>` component and its children into the `@auth/(.)login/page.tsx` file, and updating the folder name to `/@auth/(.)login/page.tsx`.

**TypeScript**

```tsx title="app/@auth/(.)login/page.tsx" 
import { Modal } from '@/app/ui/modal'
import { Login } from '@/app/ui/login'

export default function Page() {
  return (
    <Modal>
      <Login />
    </Modal>
  )
}
```

**JavaScript**

```jsx title="app/@auth/(.)login/page.js" 
import { Modal } from '@/app/ui/modal'
import { Login } from '@/app/ui/login'

export default function Page() {
  return (
    <Modal>
      <Login />
    </Modal>
  )
}
```

> **Good to know:**
>
> - The convention `(.)` is used for intercepting routes. See [Intercepting Routes](/docs/app/api-reference/file-conventions/intercepting-routes#convention) docs for more information.
> - By separating the `<Modal>` functionality from the modal content (`<Login>`), you can ensure any content inside the modal, e.g. [forms](/docs/app/guides/forms), are Server Components. See [Interleaving Client and Server Components](/docs/app/getting-started/server-and-client-components#interleaving-server-and-client-components) for more information.

#### Opening the modal

Now, you can leverage the Next.js router to open and close the modal. This ensures the URL is correctly updated when the modal is open, and when navigating backwards and forwards.

To open the modal, pass the `@auth` slot as a prop to the parent layout and render it alongside the `children` prop.

**TypeScript**

```tsx title="app/layout.tsx" 
import Link from 'next/link'

export default function Layout({
  auth,
  children,
}: {
  auth: React.ReactNode
  children: React.ReactNode
}) {
  return (
    <>
      <nav>
        <Link href="/login">Open modal</Link>
      </nav>
      <div>{auth}</div>
      <div>{children}</div>
    </>
  )
}
```

**JavaScript**

```jsx title="app/layout.js" 
import Link from 'next/link'

export default function Layout({ auth, children }) {
  return (
    <>
      <nav>
        <Link href="/login">Open modal</Link>
      </nav>
      <div>{auth}</div>
      <div>{children}</div>
    </>
  )
}
```

When the user clicks the `<Link>`, the modal will open instead of navigating to the `/login` page. However, on refresh or initial load, navigating to `/login` will take the user to the main login page.

#### Closing the modal

You can close the modal by calling `router.back()` or by using the `Link` component.

**TypeScript**

```tsx title="app/ui/modal.tsx" 
'use client'

import { useRouter } from 'next/navigation'

export function Modal({ children }: { children: React.ReactNode }) {
  const router = useRouter()

  return (
    <>
      <button
        onClick={() => {
          router.back()
        }}
      >
        Close modal
      </button>
      <div>{children}</div>
    </>
  )
}
```

**JavaScript**

```jsx title="app/ui/modal.js" 
'use client'

import { useRouter } from 'next/navigation'

export function Modal({ children }) {
  const router = useRouter()

  return (
    <>
      <button
        onClick={() => {
          router.back()
        }}
      >
        Close modal
      </button>
      <div>{children}</div>
    </>
  )
}
```

When using the `Link` component to navigate away from a page that shouldn't render the `@auth` slot anymore, we need to make sure the parallel route matches to a component that returns `null`. For example, when navigating back to the root page, we create a `@auth/page.tsx` component:

**TypeScript**

```tsx title="app/ui/modal.tsx" 
import Link from 'next/link'

export function Modal({ children }: { children: React.ReactNode }) {
  return (
    <>
      <Link href="/">Close modal</Link>
      <div>{children}</div>
    </>
  )
}
```

```tsx title="app/@auth/page.tsx" 
export default function Page() {
  return null
}
```

**JavaScript**

```jsx title="app/ui/modal.js" 
import Link from 'next/link'

export function Modal({ children }) {
  return (
    <>
      <Link href="/">Close modal</Link>
      <div>{children}</div>
    </>
  )
}
```

```jsx title="app/@auth/page.js" 
export default function Page() {
  return null
}
```

Or if navigating to any other page (such as `/foo`, `/foo/bar`, etc), you can use a catch-all slot:

**TypeScript**

```tsx title="app/@auth/[...catchAll]/page.tsx" 
export default function CatchAll() {
  return null
}
```

**JavaScript**

```jsx title="app/@auth/[...catchAll]/page.js" 
export default function CatchAll() {
  return null
}
```

> **Good to know:**
>
> - We use a catch-all route in our `@auth` slot to close the modal because of how parallel routes behave. Since client-side navigations to a route that no longer match the slot will remain visible, we need to match the slot to a route that returns `null` to close the modal.
> - Other examples could include opening a photo modal in a gallery while also having a dedicated `/photo/[id]` page, or opening a shopping cart in a side modal.
> - [View an example](https://github.com/nextjs/nextgram) of modals with Intercepted and Parallel Routes.

### Loading and Error UI

Parallel Routes can be streamed independently, allowing you to define independent error and loading states for each route:

![Parallel routes enable custom error and loading states](/docs/light/parallel-routes-cinematic-universe.png)

See the [Loading UI](/docs/app/api-reference/file-conventions/loading) and [Error Handling](/docs/app/getting-started/error-handling) documentation for more information.

- [default.js](/docs/app/api-reference/file-conventions/default): API Reference for the default.js file.
- [Authentication](/docs/app/guides/authentication): Learn how to implement authentication in your Next.js application.

---

For a semantic overview of all documentation, see [/sitemap.md](/sitemap.md)

For an index of all available documentation, see [/docs/llms.txt](/docs/llms.txt)