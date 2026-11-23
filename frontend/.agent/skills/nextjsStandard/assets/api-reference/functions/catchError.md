---
title: catchError
description: API Reference for the catchError function.
url: "https://nextjs.org/docs/app/api-reference/functions/catchError"
docs_index: /docs/llms.txt
lastUpdated: 2026-10-15
prerequisites:
  - "API Reference: /docs/app/api-reference"
  - "Functions: /docs/app/api-reference/functions"
related:
  - /docs/app/getting-started/error-handling
  - /docs/app/api-reference/file-conventions/error
---

> For an index of all documentation, see [/docs/llms.txt](/docs/llms.txt).

The `catchError` function creates a component that wraps its children in an error boundary. It provides a programmatic alternative to the [`error.js`](/docs/app/api-reference/file-conventions/error) file convention, enabling component-level error recovery anywhere in your component tree.

Compared to a custom React error boundary, `catchError` is designed to work with Next.js out of the box:

- **Built-in error recovery** — [`retry()`](/docs/app/api-reference/file-conventions/error#retry) re-renders the page inside a [Transition](https://react.dev/reference/react/startTransition), preserving Client Components state outside of the error boundary.
- **Framework-aware integration** — APIs like `redirect()` and `notFound()` work by throwing special errors under the hood. `catchError` handles these seamlessly, so they're not accidentally caught by your error boundary.
- **Client navigation handling** — The error state automatically clears when you do a client navigation to a different route.

`catchError` can be called from [Client Components](/docs/app/getting-started/server-and-client-components).

**TypeScript**

```tsx title="app/custom-error-boundary.tsx" 
'use client'

import { catchError, type ErrorInfo } from 'next/error'

function ErrorFallback(props: { title: string }, { error, retry }: ErrorInfo) {
  const message = error instanceof Error ? error.message : String(error)

  return (
    <div>
      <h2>{props.title}</h2>
      <p>{message}</p>
      <button onClick={() => retry()}>Try again</button>
    </div>
  )
}

export default catchError(ErrorFallback)
```

**JavaScript**

```jsx title="app/custom-error-boundary.js" 
'use client'

import { catchError } from 'next/error'

function ErrorFallback(props, { error, retry }) {
  const message = error instanceof Error ? error.message : String(error)

  return (
    <div>
      <h2>{props.title}</h2>
      <p>{message}</p>
      <button onClick={() => retry()}>Try again</button>
    </div>
  )
}

export default catchError(ErrorFallback)
```

## Reference

### Parameters

`catchError` accepts a single argument:

```ts
const ErrorWrapper = catchError(fallback)
```

#### `fallback`

A function that renders the error UI when an error is caught. It receives two arguments:

- `props` — The props passed to the wrapper component (excluding `children`).
- `errorInfo` — An object containing information about the error:

| Property | Type         | Description                                                                                                                                     |
| -------- | ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `error`  | `unknown`    | The value that was thrown. Narrow it, for example with `instanceof Error`, before reading properties like `message`.                            |
| `retry`  | `() => void` | Re-fetches and re-renders the error boundary's children. If successful, the fallback is replaced with the re-rendered result.                   |
| `reset`  | `() => void` | Resets the error state and re-renders without re-fetching. Use [`retry()`](/docs/app/api-reference/file-conventions/error#retry) in most cases. |

The `fallback` function must be a Client Component (or defined in a `'use client'` module).

### Returns

`catchError` returns a React component that:

- Accepts the same props as your fallback's first argument, plus `children`.
- Wraps `children` in an error boundary.
- Renders the `fallback` when an error is caught in `children`.

## Examples

### Basic usage

Define a fallback and use the returned component to wrap parts of your UI:

**TypeScript**

```tsx title="app/some-component.tsx" 
import ErrorWrapper from '../custom-error-boundary'

export default function Component({ children }: { children: React.ReactNode }) {
  return <ErrorWrapper title="Dashboard Error">{children}</ErrorWrapper>
}
```

**JavaScript**

```jsx title="app/some-component.js" 
import ErrorWrapper from '../custom-error-boundary'

export default function Component({ children }) {
  return <ErrorWrapper title="Dashboard Error">{children}</ErrorWrapper>
}
```

### Recovering from errors

Use `retry()` to prompt the user to recover from the error. When called, the function re-fetches and re-renders the error boundary's children. If successful, the fallback is replaced with the re-rendered result.

In most cases, use `retry()` instead of `reset()`. The `reset()` function only clears the error state and re-renders without re-fetching, which means it won't recover from Server Component errors.

**TypeScript**

```tsx title="app/custom-error-boundary.tsx" 
'use client'

import { catchError, type ErrorInfo } from 'next/error'

function ErrorFallback(props: {}, { error, retry, reset }: ErrorInfo) {
  const message = error instanceof Error ? error.message : String(error)

  return (
    <div>
      <p>{message}</p>
      <button onClick={() => retry()}>Try again</button>
      <button onClick={() => reset()}>Reset</button>
    </div>
  )
}

export default catchError(ErrorFallback)
```

**JavaScript**

```jsx title="app/custom-error-boundary.js" 
'use client'

import { catchError } from 'next/error'

function ErrorFallback(props, { error, retry, reset }) {
  const message = error instanceof Error ? error.message : String(error)

  return (
    <div>
      <p>{message}</p>
      <button onClick={() => retry()}>Try again</button>
      <button onClick={() => reset()}>Reset</button>
    </div>
  )
}

export default catchError(ErrorFallback)
```

### Server-rendered error fallback

You can pass server-rendered content as a prop to display data-driven fallback UI. This works by rendering a Server Component as a `React.ReactNode` prop that the fallback displays when an error is caught.

> **Good to know:**
>
> This pattern eagerly renders the fallback on every page render, even when no error occurs. For most use cases, a simpler client-side fallback is sufficient.

**TypeScript**

```tsx title="app/error-boundary.tsx" 
'use client'

import { catchError, type ErrorInfo } from 'next/error'

function ErrorFallback(
  props: { fallback: React.ReactNode },
  errorInfo: ErrorInfo
) {
  return props.fallback
}

export default catchError(ErrorFallback)
```

```tsx title="app/some-component.tsx" 
import ErrorBoundary from '../error-boundary'

async function ErrorFallback() {
  const data = await getData()
  return <div>{data.message}</div>
}

export default function Component({ children }: { children: React.ReactNode }) {
  return <ErrorBoundary fallback={<ErrorFallback />}>{children}</ErrorBoundary>
}
```

**JavaScript**

```jsx title="app/error-boundary.js" 
'use client'

import { catchError } from 'next/error'

function ErrorFallback(props, errorInfo) {
  return props.fallback
}

export default catchError(ErrorFallback)
```

```jsx title="app/some-component.js" 
import ErrorBoundary from '../error-boundary'

async function ErrorFallback() {
  const data = await getData()
  return <div>{data.message}</div>
}

export default function Component({ children }) {
  return <ErrorBoundary fallback={<ErrorFallback />}>{children}</ErrorBoundary>
}
```

> **Good to know:**
>
> - Unlike the `error.js` file convention which is scoped to route segments, `catchError` can be used to wrap any part of your component tree for component-level error recovery.
> - Props passed to the wrapper component are forwarded to the fallback function, making it easy to create reusable error UIs with different configurations.
> - You don't need to wrap `error.js` default exports with `catchError`. The [`error.js`](/docs/app/api-reference/file-conventions/error) file convention already renders inside a built-in error boundary provided by Next.js.

## Version History

| Version   | Changes                           |
| --------- | --------------------------------- |
| `v16.3.0` | `catchError` became stable.       |
| `v16.2.0` | `unstable_catchError` introduced. |

## Learn more about error handling

- [Error Handling](/docs/app/getting-started/error-handling): Learn how to display expected errors and handle uncaught exceptions.
- [error.js](/docs/app/api-reference/file-conventions/error): API reference for the error.js special file.

---

For a semantic overview of all documentation, see [/sitemap.md](/sitemap.md)

For an index of all available documentation, see [/docs/llms.txt](/docs/llms.txt)