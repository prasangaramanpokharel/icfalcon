# Next.js App Router — Exhaustive Feature & Sidebar Architecture Map (v16.4.6)

> Complete structured catalog and feature map for the Next.js App Router documentation (`https://nextjs.org/docs/app`). Every item maps directly to official raw markdown endpoints (`.md`) and Next.js docs URLs.

---

## 1. Getting Started (18 Core Modules)

| Feature | Category | Raw Markdown URL | Description |
|---|---|---|---|
| **Installation** | Setup | `https://nextjs.org/docs/app/getting-started/installation.md` | Create a new application with `create-next-app` CLI, configure TypeScript, ESLint, and path aliases. |
| **Project Structure** | Conventions | `https://nextjs.org/docs/app/getting-started/project-structure.md` | Complete folder/file conventions, special routing files, private folders (`_folder`), and route groups `(group)`. |
| **Layouts and Pages** | Routing | `https://nextjs.org/docs/app/getting-started/layouts-and-pages.md` | Define root and nested layouts, pages, layout persistence, state preservation, and client navigation with `<Link>`. |
| **Linking and Navigating** | Navigation | `https://nextjs.org/docs/app/getting-started/linking-and-navigating.md` | Built-in navigation optimizations: prefetching, prerendering, soft navigation, and slow network strategies. |
| **Server & Client Components** | Architecture | `https://nextjs.org/docs/app/getting-started/server-and-client-components.md` | React Server Components (RSC) vs Client Components (`"use client"`), network boundary, serialization over Flight RPC. |
| **Fetching Data** | Data | `https://nextjs.org/docs/app/getting-started/fetching-data.md` | Server Component data fetching, async components, streaming with `<Suspense>`, parallel queries, and waterfalls. |
| **Mutating Data** | Data | `https://nextjs.org/docs/app/getting-started/mutating-data.md` | Server Functions & Server Actions (`"use server"`), form submissions, pending states, optimistic updates. |
| **Caching** | Caching | `https://nextjs.org/docs/app/getting-started/caching.md` | Multi-layer caching architecture (Request Memoization, Data Cache, Full Route Cache, Router Cache). |
| **Revalidating** | Caching | `https://nextjs.org/docs/app/getting-started/revalidating.md` | Time-based (stale-while-revalidate) and on-demand cache revalidation via tags and paths. |
| **Error Handling** | Resilience | `https://nextjs.org/docs/app/getting-started/error-handling.md` | Expected error handling, `error.tsx` boundaries, `global-error.tsx`, and unhandled exception triage. |
| **CSS & Styling** | Styling | `https://nextjs.org/docs/app/getting-started/css.md` | Tailwind CSS, CSS Modules, Global CSS, Sass, external stylesheets, and CSS chunking. |
| **Image Optimization** | Assets | `https://nextjs.org/docs/app/getting-started/images.md` | Built-in `next/image`, responsive sizing, layout shift prevention (CLS), modern formats (WebP/AVIF), and priority loading. |
| **Font Optimization** | Assets | `https://nextjs.org/docs/app/getting-started/fonts.md` | Zero layout-shift self-hosted web fonts via `next/font/google` and `next/font/local`. |
| **Metadata and OG Images** | SEO | `https://nextjs.org/docs/app/getting-started/metadata-and-og-images.md` | Static & dynamic SEO metadata (`generateMetadata`), social cards, OpenGraph, and dynamic OG image generation. |
| **Route Handlers** | API | `https://nextjs.org/docs/app/getting-started/route-handlers.md` | Custom backend endpoints (`route.ts`) built on Web Standard `Request` and `Response` APIs. |
| **Proxy (Middleware Evolution)** | Network | `https://nextjs.org/docs/app/getting-started/proxy.md` | Intercept incoming requests, rewrite, redirect, modify headers, or respond before request completion. |
| **Deploying** | DevOps | `https://nextjs.org/docs/app/getting-started/deploying.md` | Deployment workflows: managed hosting (Vercel), Node.js server, Docker containers, and static exports. |
| **Upgrading** | Lifecycle | `https://nextjs.org/docs/app/getting-started/upgrading.md` | Upgrading Next.js versions, canary builds, codemods, and automated AI coding agent upgrades. |

---

## 2. Guides (Comprehensive Use Cases & Production Patterns)

| Topic | Raw Markdown URL | Description |
|---|---|---|
| **Adopting Partial Prefetching** | `https://nextjs.org/docs/app/guides/adopting-partial-prefetching.md` | Enable Partial Prefetching (PPR) and understand `<Link>` behavior changes. |
| **AI Coding Agents** | `https://nextjs.org/docs/app/guides/ai-agents.md` | Framework integration for AI agents, built-in docs inspection, verification, and issue triage. |
| **Analytics & Web Vitals** | `https://nextjs.org/docs/app/guides/analytics.md` | Track Core Web Vitals (LCP, FID/INP, CLS) with Speed Insights and custom reporters. |
| **Authentication** | `https://nextjs.org/docs/app/guides/authentication.md` | Session management, cookie validation, Server Actions auth, and route protection. |
| **Authentication with Cache Components** | `https://nextjs.org/docs/app/guides/authentication-with-cache-components.md` | Read user sessions without blocking static shells, caching user-derived states safely. |
| **Backend for Frontend (BFF)** | `https://nextjs.org/docs/app/guides/backend-for-frontend.md` | Architecture patterns using Next.js as an enterprise backend aggregation layer. |
| **Building (`next build`)** | `https://nextjs.org/docs/app/guides/building.md` | Deep dive into build lifecycle, asset tracing, static prerendering, and output logs. |
| **Caching (Legacy Model)** | `https://nextjs.org/docs/app/guides/caching-without-cache-components.md` | Classic fetch options, `unstable_cache`, and segment configs without Cache Components. |
| **CDN Caching** | `https://nextjs.org/docs/app/guides/cdn-caching.md` | Pathname-based edge keying, cache variability, and CDN invalidation. |
| **CI Build Caching** | `https://nextjs.org/docs/app/guides/ci-build-caching.md` | Persistent `.next/cache` restoration across GitHub Actions and CI pipelines. |
| **Client-Side Data Fetching (SWR)** | `https://nextjs.org/docs/app/guides/client-side-data-fetching/swr.md` | Coordinate client-side SWR caching with Server Component initial data hydration. |
| **Client-Side Data Fetching (TanStack Query)** | `https://nextjs.org/docs/app/guides/client-side-data-fetching/tanstack-query.md` | Prefetching in RSC and dehydrating state into TanStack Query client providers. |
| **Content Security Policy (CSP)** | `https://nextjs.org/docs/app/guides/content-security-policy.md` | Strict nonce generation in middleware, CSP headers, inline script protection. |
| **CSS-in-JS** | `https://nextjs.org/docs/app/guides/css-in-js.md` | Integrating styled-components, Emotion, and style registries with streaming RSC. |
| **Custom Server** | `https://nextjs.org/docs/app/guides/custom-server.md` | Running custom Express, Fastify, or Node HTTP servers with Next.js programmatic API. |
| **Data Security & Taint API** | `https://nextjs.org/docs/app/guides/data-security.md` | React Taint APIs (`taintObjectReference`, `taintUniqueValue`) and Data Access Layer boundaries. |
| **Debugging** | `https://nextjs.org/docs/app/guides/debugging.md` | Source maps, VS Code launch configurations, Chrome/Firefox DevTools inspection. |
| **Deploying to Platforms** | `https://nextjs.org/docs/app/guides/deploying-to-platforms.md` | Feature matrix across deployment platforms (streaming, image optimization, edge vs node). |
| **Draft Mode** | `https://nextjs.org/docs/app/guides/draft-mode.md` | Bypass static caching for headless CMS live preview workflows. |
| **Environment Variables** | `https://nextjs.org/docs/app/guides/environment-variables.md` | `.env.production`, `.env.local`, build-time embedding vs runtime server variables. |
| **Forms & Server Actions** | `https://nextjs.org/docs/app/guides/forms.md` | Progressive enhancement, `useActionState`, `useFormStatus`, validation, and pending states. |
| **How Revalidation Works** | `https://nextjs.org/docs/app/guides/how-revalidation-works.md` | Invalidation tags, cache consistency, stale-while-revalidate, and multi-instance sync. |
| **Incremental Static Regeneration (ISR)** | `https://nextjs.org/docs/app/guides/incremental-static-regeneration.md` | Static page creation/regeneration at runtime without rebuilding the entire app. |
| **ISR with Cache Components** | `https://nextjs.org/docs/app/guides/incremental-static-regeneration-cache-components.md` | Prerender dynamic subsets, serve instant App Shells, and revalidate in background. |
| **Instant Navigation** | `https://nextjs.org/docs/app/guides/instant-navigation.md` | Optimize prefetching and prerendering for zero-latency client-side transitions. |
| **Instrumentation** | `https://nextjs.org/docs/app/guides/instrumentation.md` | `register()` lifecycle hook executed once on server startup for telemetry and monitors. |
| **Interactive Apps** | `https://nextjs.org/docs/app/guides/interactive-apps.md` | High-fidelity interactive UI with transitions (`useTransition`), optimistic UI, and feedback. |
| **Internationalization (i18n)** | `https://nextjs.org/docs/app/guides/internationalization.md` | Sub-path routing `/[lang]/`, locale detection, and dictionary translations. |
| **JSON-LD** | `https://nextjs.org/docs/app/guides/json-ld.md` | Structured data injection in RSC for search engines and rich snippets. |
| **Keeping Pages Static** | `https://nextjs.org/docs/app/guides/keeping-pages-static.md` | Prevent unintentional dynamic bailing and enforce route staticness. |
| **Lazy Loading** | `https://nextjs.org/docs/app/guides/lazy-loading.md` | Dynamic imports (`next/dynamic`), `React.lazy`, and client component code-splitting. |
| **Local Development** | `https://nextjs.org/docs/app/guides/local-development.md` | Optimizing local dev server, Turbopack startup, HMR latency, and memory footprints. |
| **Next.js MCP Server** | `https://nextjs.org/docs/app/guides/mcp.md` | Built-in Model Context Protocol endpoint for coding agents to inspect live running state. |
| **MDX** | `https://nextjs.org/docs/app/guides/mdx.md` | Markdown + JSX compilation via `@next/mdx` or Rust-based `mdxRs`. |
| **Memory Usage** | `https://nextjs.org/docs/app/guides/memory-usage.md` | Memory profiling, heap snapshots, and leak prevention in Node.js production servers. |
| **Migrating: Pages to App Router** | `https://nextjs.org/docs/app/guides/migrating/app-router-migration.md` | Incremental co-existence and migration from `pages/` to `app/`. |
| **Migrating: Create React App** | `https://nextjs.org/docs/app/guides/migrating/from-create-react-app.md` | Migrating legacy CRA single-page applications to Next.js. |
| **Migrating: Vite** | `https://nextjs.org/docs/app/guides/migrating/from-vite.md` | Migrating Vite SPA or SSR architectures to the App Router. |
| **Migrating to Cache Components** | `https://nextjs.org/docs/app/guides/migrating-to-cache-components.md` | Transition from segment config flags to `"use cache"` and `cacheLife`. |
| **Multi-Tenant Architecture** | `https://nextjs.org/docs/app/guides/multi-tenant.md` | Custom domains, wildcard subdomains, and dynamic tenant routing. |
| **Multi-Zones** | `https://nextjs.org/docs/app/guides/multi-zones.md` | Micro-frontend routing across multiple independent Next.js applications under one domain. |
| **Offline Support** | `https://nextjs.org/docs/app/guides/offline-support.md` | Graceful recovery on network disconnection, offline flags, and retry strategies. |
| **OpenTelemetry (OTel)** | `https://nextjs.org/docs/app/guides/open-telemetry.md` | Tracing spans, metrics export, and distributed observability across services. |
| **Optimizing Prefetching** | `https://nextjs.org/docs/app/guides/optimizing-prefetching.md` | Fine-tuning `<Link prefetch={...}>`, viewport observers, and background payloads. |
| **Optimizing the Static Shell** | `https://nextjs.org/docs/app/guides/optimizing-the-static-shell.md` | App shell architecture, instant header/navigation render, and deferred data streaming. |
| **Package Bundling & Analyzer** | `https://nextjs.org/docs/app/guides/package-bundling.md` | Bundle size breakdown using `@next/bundle-analyzer` and Turbopack analysis tools. |
| **PPR Platform Guide** | `https://nextjs.org/docs/app/guides/ppr-platform-guide.md` | Platform and infrastructure specifications for hosting Partial Prerendering. |
| **Preserving UI State** | `https://nextjs.org/docs/app/guides/preserving-ui-state.md` | React `Activity` component and layout state preservation across client transitions. |
| **Preventing FOUC** | `https://nextjs.org/docs/app/guides/preventing-flash-before-hydration.md` | Eliminating flash of unstyled theme content (dark mode) prior to hydration. |
| **Production Checklist** | `https://nextjs.org/docs/app/guides/production-checklist.md` | Official pre-launch verification: caching, security, performance, fonts, and logging. |
| **Progressive Web Apps (PWA)** | `https://nextjs.org/docs/app/guides/progressive-web-apps.md` | Service workers, web app manifests, and offline installability. |
| **Public Static Pages** | `https://nextjs.org/docs/app/guides/public-static-pages.md` | Highly scalable shared static content (marketing, catalogs, blogs). |
| **Redirecting** | `https://nextjs.org/docs/app/guides/redirecting.md` | Server-side `redirect()`, `permanentRedirect()`, `next.config.js` rewrites, and client hooks. |
| **Rendering Philosophy** | `https://nextjs.org/docs/app/guides/rendering-philosophy.md` | The component-level spectrum between fully static, partially cached, and purely dynamic rendering. |
| **Self-Hosting** | `https://nextjs.org/docs/app/guides/self-hosting.md` | Docker multi-stage builds, Node server clusters, static exports, and reverse proxying (NGINX/Caddy). |
| **Server Actions Deep Dive** | `https://nextjs.org/docs/app/guides/server-actions.md` | Single-roundtrip mutation model, sequential queuing, and CSRF protection. |
| **Server/Client Boundary** | `https://nextjs.org/docs/app/guides/server-and-client-boundary.md` | Rules for passing props across the boundary, serialization, and children composition pattern. |
| **Single Page Applications (SPAs)** | `https://nextjs.org/docs/app/guides/single-page-applications.md` | Building fast SPA experiences with App Router client-side routing. |
| **Static Exports (`next export`)** | `https://nextjs.org/docs/app/guides/static-exports.md` | `output: 'export'` generation for S3, Cloudflare Pages, or static web servers. |
| **Streaming UI** | `https://nextjs.org/docs/app/guides/streaming.md` | Progressive rendering via React Suspense and HTTP/2 chunked transfer encoding. |
| **Testing (E2E & Unit)** | `https://nextjs.org/docs/app/guides/testing.md` | Vitest, Jest, Cypress, and Playwright configurations with RSC and App Router. |
| **Third-Party Libraries** | `https://nextjs.org/docs/app/guides/third-party-libraries.md` | `@next/third-parties` for Google Tag Manager, Analytics, YouTube, and Google Maps. |
| **View Transitions** | `https://nextjs.org/docs/app/guides/view-transitions.md` | Native browser View Transitions API integration during route navigations. |

---

## 3. API Reference: Directives & Components

### A. Directives
| Directive | Raw Markdown URL | Purpose |
|---|---|---|
| `"use client"` | `https://nextjs.org/docs/app/api-reference/directives/use-client.md` | Declares a boundary between Server and Client component trees. Required for React hooks and DOM listeners. |
| `"use server"` | `https://nextjs.org/docs/app/api-reference/directives/use-server.md` | Marks a function or module as callable from the client (Server Actions / Server Functions). |
| `"use cache"` | `https://nextjs.org/docs/app/api-reference/directives/use-cache.md` | Next.js 15+ Cache Component directive to mark asynchronous functions or components for automatic caching. |
| `"use cache: private"` | `https://nextjs.org/docs/app/api-reference/directives/use-cache-private.md` | Caches functions that access runtime request APIs (e.g. user session tokens) in private isolated contexts. |
| `"use cache: remote"` | `https://nextjs.org/docs/app/api-reference/directives/use-cache-remote.md` | Enables persistent, distributed cache handlers for multi-instance deployments. |

### B. Built-in Components
| Component | Raw Markdown URL | Key Capabilities |
|---|---|---|
| `<Image>` | `https://nextjs.org/docs/app/api-reference/components/image.md` | Automatic format negotiation (WebP/AVIF), intrinsic aspect ratio reservation, lazy loading, blur placeholder. |
| `<Link>` | `https://nextjs.org/docs/app/api-reference/components/link.md` | Fast client-side transitions, viewport prefetching, scroll restoration, and shallow routing. |
| `<Form>` | `https://nextjs.org/docs/app/api-reference/components/form.md` | Progressive form submission with client-side navigation and search parameter syncing. |
| `<Script>` | `https://nextjs.org/docs/app/api-reference/components/script.md` | Fine-grained 3rd party script loading strategies: `beforeInteractive`, `afterInteractive`, `lazyOnload`, `worker`. |
| `next/font` | `https://nextjs.org/docs/app/api-reference/components/font.md` | Built-in font loaders with automated CSS variable binding and zero Cumulative Layout Shift. |

---

## 4. API Reference: File-System Conventions

### A. Route Files
| File Name | Scope | Raw Markdown URL | Description |
|---|---|---|---|
| `layout.tsx` | Shared | `https://nextjs.org/docs/app/api-reference/file-conventions/layout.md` | Shared UI across route segments. Preserves state and does not re-render on navigation. |
| `page.tsx` | Unique | `https://nextjs.org/docs/app/api-reference/file-conventions/page.md` | Unique UI of a route segment. Makes the route publicly accessible. |
| `loading.tsx` | Segment | `https://nextjs.org/docs/app/api-reference/file-conventions/loading.md` | Instant loading state automatically wrapped in React Suspense boundary. |
| `not-found.tsx` | Segment | `https://nextjs.org/docs/app/api-reference/file-conventions/not-found.md` | Triggered by `notFound()` or unmatched routes within the segment. |
| `error.tsx` | Segment | `https://nextjs.org/docs/app/api-reference/file-conventions/error.md` | React error boundary for route segment (`"use client"`). Recovers with `reset()`. |
| `global-error.tsx` | Root | `https://nextjs.org/docs/app/api-reference/file-conventions/error.md` | Top-level catch-all error boundary replacing the root layout on catastrophic failure. |
| `route.ts` | Backend | `https://nextjs.org/docs/app/api-reference/file-conventions/route.md` | Backend API handler (GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD). |
| `template.tsx` | Segment | `https://nextjs.org/docs/app/api-reference/file-conventions/template.md` | Like layout, but creates a new instance and resets state on every navigation. |
| `default.tsx` | Slot | `https://nextjs.org/docs/app/api-reference/file-conventions/default.md` | Fallback component rendered inside parallel route slots (`@slot`) on page reloads. |
| `forbidden.tsx` | Segment | `https://nextjs.org/docs/app/api-reference/file-conventions/forbidden.md` | UI displayed when `forbidden()` is thrown (requires `authInterrupts`). |
| `unauthorized.tsx` | Segment | `https://nextjs.org/docs/app/api-reference/file-conventions/unauthorized.md` | UI displayed when `unauthorized()` is thrown (requires `authInterrupts`). |
| `proxy.ts` | Network | `https://nextjs.org/docs/app/api-reference/file-conventions/proxy.md` | Next.js Proxy request interceptor (evolved middleware pattern). |
| `instrumentation.ts` | Server | `https://nextjs.org/docs/app/api-reference/file-conventions/instrumentation.md` | Server initialization code run when the Next.js Node/Edge server boots up. |
| `instrumentation-client.ts` | Client | `https://nextjs.org/docs/app/api-reference/file-conventions/instrumentation-client.md` | Client-side frontend telemetry and performance monitoring initialization. |

### B. Dynamic & Parallel Routing Conventions
| Pattern | Syntax | Raw Markdown URL | Purpose |
|---|---|---|---|
| Dynamic Segment | `[slug]` | `https://nextjs.org/docs/app/api-reference/file-conventions/dynamic-routes.md` | Matches a single dynamic URL path parameter. |
| Catch-All Segment | `[...slug]` | `https://nextjs.org/docs/app/api-reference/file-conventions/dynamic-routes.md` | Matches all subsequent path segments into an array. |
| Optional Catch-All | `[[...slug]]` | `https://nextjs.org/docs/app/api-reference/file-conventions/dynamic-routes.md` | Matches the route with or without additional path segments. |
| Route Groups | `(marketing)` | `https://nextjs.org/docs/app/api-reference/file-conventions/route-groups.md` | Organizes routes into logical folders without affecting the URL path. |
| Parallel Routes | `@analytics` | `https://nextjs.org/docs/app/api-reference/file-conventions/parallel-routes.md` | Simultaneously renders multiple independent pages into named layout slots. |
| Intercepting Routes | `(.)photo`, `(..)` | `https://nextjs.org/docs/app/api-reference/file-conventions/intercepting-routes.md` | Loads a route within the current layout (e.g. modal overlay) while masking URL. |

### C. Metadata Files
| File | Raw Markdown URL | Description |
|---|---|---|
| `sitemap.xml` / `sitemap.ts` | `https://nextjs.org/docs/app/api-reference/file-conventions/metadata/sitemap.md` | XML sitemap generator supporting multi-sitemap indexing. |
| `robots.txt` / `robots.ts` | `https://nextjs.org/docs/app/api-reference/file-conventions/metadata/robots.md` | Search crawler indexing instructions and sitemap discovery rules. |
| `opengraph-image.tsx` | `https://nextjs.org/docs/app/api-reference/file-conventions/metadata/opengraph-image.md` | Dynamically generated Open Graph & Twitter social card images via JSX/Satori. |
| `manifest.json` / `manifest.ts` | `https://nextjs.org/docs/app/api-reference/file-conventions/metadata/manifest.md` | Web App Manifest for Progressive Web Apps (PWAs). |
| `favicon.ico`, `icon.png`, `apple-icon.png` | `https://nextjs.org/docs/app/api-reference/file-conventions/metadata/app-icons.md` | Static or programmatic favicon and application touch icons. |

### D. Route Segment Config Options
| Option | Raw Markdown URL | Typical Values |
|---|---|---|
| `dynamic` | `https://nextjs.org/docs/app/api-reference/file-conventions/route-segment-config.md` | `'auto' \| 'force-dynamic' \| 'error' \| 'force-static'` |
| `dynamicParams` | `https://nextjs.org/docs/app/api-reference/file-conventions/route-segment-config/dynamicParams.md` | `true \| false` (controls 404 on ungenerated static params) |
| `revalidate` | `https://nextjs.org/docs/app/api-reference/file-conventions/route-segment-config.md` | `false \| 0 \| number` (seconds for ISR) |
| `runtime` | `https://nextjs.org/docs/app/api-reference/file-conventions/route-segment-config/runtime.md` | `'nodejs' \| 'edge'` |
| `maxDuration` | `https://nextjs.org/docs/app/api-reference/file-conventions/route-segment-config/maxDuration.md` | Number (timeout execution in seconds for serverless functions) |
| `ensureStatic` | `https://nextjs.org/docs/app/api-reference/file-conventions/route-segment-config/ensureStatic.md` | Enforces that route output remains strictly static during build. |
| `instant` | `https://nextjs.org/docs/app/api-reference/file-conventions/route-segment-config/instant.md` | Validates instant navigation compliance for route segments. |
| `prefetch` | `https://nextjs.org/docs/app/api-reference/file-conventions/route-segment-config/prefetch.md` | Configures segment-level prefetch bundling during client navigation. |

---

## 5. API Reference: Functions and Hooks (Complete Index)

| Function / Hook | Environment | Raw Markdown URL | Description |
|---|---|---|---|
| **`after(callback)`** | Server | `https://nextjs.org/docs/app/api-reference/functions/after.md` | Schedules non-blocking work (logging, analytics) to execute after the response closes. |
| **`cacheLife(profile)`** | Server | `https://nextjs.org/docs/app/api-reference/functions/cacheLife.md` | Configures cache expiration thresholds (`stale`, `revalidate`, `expire`) inside `"use cache"`. |
| **`cacheTag(...tags)`** | Server | `https://nextjs.org/docs/app/api-reference/functions/cacheTag.md` | Attaches cache invalidation tags to functions or components wrapped with `"use cache"`. |
| **`revalidateTag(tag)`** | Server | `https://nextjs.org/docs/app/api-reference/functions/revalidateTag.md` | Purges all cached entries matching the specified cache tag. |
| **`revalidatePath(path)`** | Server | `https://nextjs.org/docs/app/api-reference/functions/revalidatePath.md` | Purges cached data and UI associated with a specific route path. |
| **`updateTag(tag)`** | Server | `https://nextjs.org/docs/app/api-reference/functions/updateTag.md` | Revalidates and updates cache tags in real-time. |
| **`cookies()`** | Server | `https://nextjs.org/docs/app/api-reference/functions/cookies.md` | Read, set, and delete incoming request cookies in Server Components or Actions. |
| **`headers()`** | Server | `https://nextjs.org/docs/app/api-reference/functions/headers.md` | Read incoming HTTP headers inside Server Components. |
| **`connection()`** | Server | `https://nextjs.org/docs/app/api-reference/functions/connection.md` | Explicitly declares a dependency on incoming request connection (opts into dynamic rendering). |
| **`notFound()`** | Server | `https://nextjs.org/docs/app/api-reference/functions/not-found.md` | Throws a 404 response and renders the nearest `not-found.tsx` boundary. |
| **`redirect(url)`** | Server | `https://nextjs.org/docs/app/api-reference/functions/redirect.md` | Performs an HTTP 307 redirect within Server Components or Server Actions. |
| **`permanentRedirect(url)`** | Server | `https://nextjs.org/docs/app/api-reference/functions/permanentRedirect.md` | Performs an HTTP 308 permanent redirect. |
| **`forbidden()`** | Server | `https://nextjs.org/docs/app/api-reference/functions/forbidden.md` | Throws an HTTP 403 response and renders `forbidden.tsx`. |
| **`unauthorized()`** | Server | `https://nextjs.org/docs/app/api-reference/functions/unauthorized.md` | Throws an HTTP 401 response and renders `unauthorized.tsx`. |
| **`generateMetadata(props)`** | Server | `https://nextjs.org/docs/app/api-reference/functions/generate-metadata.md` | Computes dynamic SEO `<title>`, `<meta>`, OpenGraph, and JSON-LD tags. |
| **`generateViewport(props)`** | Server | `https://nextjs.org/docs/app/api-reference/functions/generate-viewport.md` | Dynamic configuration for viewport meta tag (`themeColor`, `width`, `initialScale`). |
| **`generateStaticParams()`** | Server | `https://nextjs.org/docs/app/api-reference/functions/generate-static-params.md` | Pre-renders dynamic route segments at build time for static generation. |
| **`generateImageMetadata()`** | Server | `https://nextjs.org/docs/app/api-reference/functions/generate-image-metadata.md` | Generates multiple OG images from a single special file. |
| **`generateSitemaps()`** | Server | `https://nextjs.org/docs/app/api-reference/functions/generate-sitemaps.md` | Splits large application sitemaps into multiple indexed XML files. |
| **`draftMode()`** | Server | `https://nextjs.org/docs/app/api-reference/functions/draft-mode.md` | Inspects and toggles draft mode cookies for headless CMS previewing. |
| **`unstable_cache(fn, keys, opts)`** | Server | `https://nextjs.org/docs/app/api-reference/functions/unstable_cache.md` | Low-level caching wrapper for caching expensive async function results across requests. |
| **`unstable_noStore()`** | Server | `https://nextjs.org/docs/app/api-reference/functions/unstable_noStore.md` | Opts out of caching declaratively inside data-fetching functions. |
| **`unstable_rethrow(err)`** | Server | `https://nextjs.org/docs/app/api-reference/functions/unstable_rethrow.md` | Re-throws internal Next.js control-flow errors (redirects, notFound) in catch blocks. |
| **`ImageResponse`** | Server / Edge | `https://nextjs.org/docs/app/api-reference/functions/image-response.md` | Generates dynamic PNG social images from JSX and CSS styles using Satori. |
| **`NextRequest`** | Server / Middleware | `https://nextjs.org/docs/app/api-reference/functions/next-request.md` | Extended Web Standard Request object with cookies, nextUrl, and geo ip helpers. |
| **`NextResponse`** | Server / Middleware | `https://nextjs.org/docs/app/api-reference/functions/next-response.md` | Extended Web Standard Response object for headers, cookies, redirects, and rewrites. |
| **`useRouter()`** | Client | `https://nextjs.org/docs/app/api-reference/functions/use-router.md` | Programmatic client-side navigation (`push`, `replace`, `refresh`, `back`, `forward`). |
| **`usePathname()`** | Client | `https://nextjs.org/docs/app/api-reference/functions/use-pathname.md` | Reads current URL pathname string without search parameters. |
| **`useSearchParams()`** | Client | `https://nextjs.org/docs/app/api-reference/functions/use-search-params.md` | Read-only access to URL query parameters (`URLSearchParams`). |
| **`useParams()`** | Client | `https://nextjs.org/docs/app/api-reference/functions/use-params.md` | Accesses dynamic route segment parameters filled by current route. |
| **`useSelectedLayoutSegment()`** | Client | `https://nextjs.org/docs/app/api-reference/functions/use-selected-layout-segment.md` | Reads active child route segment one level below calling layout. |
| **`useSelectedLayoutSegments()`** | Client | `https://nextjs.org/docs/app/api-reference/functions/use-selected-layout-segments.md` | Reads array of all active nested child segments below calling layout. |
| **`useReportWebVitals(fn)`** | Client | `https://nextjs.org/docs/app/api-reference/functions/use-report-web-vitals.md` | Custom hook to report metrics (FCP, LCP, CLS, FID, TTFB, INP) to analytics. |
| **`useServerInsertedHTML(cb)`** | Client | `https://nextjs.org/docs/app/api-reference/functions/use-server-inserted-html.md` | Inserts critical CSS or tags directly into the server HTML stream before hydration. |
| **`useLinkStatus(href)`** | Client | `https://nextjs.org/docs/app/api-reference/functions/use-link-status.md` | Inspects prefetching and navigation status of a target route link. |
| **`useOffline()`** | Client | `https://nextjs.org/docs/app/api-reference/functions/use-offline.md` | React hook to detect online/offline network transitions and retry requests. |
| **`userAgent(request)`** | Server / Middleware | `https://nextjs.org/docs/app/api-reference/functions/userAgent.md` | Helper to parse user agent strings into browser, device, OS, and bot metadata. |

---

## 6. Key `next.config.js` Production Directives

| Property | Raw Markdown URL | Description |
|---|---|---|
| `output: 'standalone'` | `https://nextjs.org/docs/app/api-reference/config/next-config-js/output.md` | Automatically traces file dependencies to produce minimal Docker container deployments. |
| `cacheComponents` | `https://nextjs.org/docs/app/api-reference/config/next-config-js/cacheComponents.md` | Enables `"use cache"` and `cacheLife` modern caching runtime. |
| `cacheHandlers` | `https://nextjs.org/docs/app/api-reference/config/next-config-js/cacheHandlers.md` | Connects distributed remote cache providers (Redis, Memcached, KV). |
| `experimental.taint` | `https://nextjs.org/docs/app/api-reference/config/next-config-js/taint.md` | Enables React Taint API protection against credential leakage to client bundles. |
| `experimental.reactCompiler` | `https://nextjs.org/docs/app/api-reference/config/next-config-js/reactCompiler.md` | Enables automated memoization without manual `useMemo` or `useCallback`. |
| `turbopack` | `https://nextjs.org/docs/app/api-reference/config/next-config-js/turbopack.md` | Configures Turbopack build flags, loader rules, and module aliases. |
| `turbopackFileSystemCache` | `https://nextjs.org/docs/app/api-reference/config/next-config-js/turbopackFileSystemCache.md` | Enables persistent disk-level Turbopack caching for fast cold starts. |
| `logging` | `https://nextjs.org/docs/app/api-reference/config/next-config-js/logging.md` | Terminal fetch logging (`fullUrl: true`), incoming requests, and client console forwarding. |
| `serverExternalPackages` | `https://nextjs.org/docs/app/api-reference/config/next-config-js/serverExternalPackages.md` | Excludes heavy server libraries (`sharp`, `pg`, `@prisma/client`) from bundling. |
| `images.remotePatterns` | `https://nextjs.org/docs/app/api-reference/config/next-config-js/images.md` | Whitelist approved remote hosts and protocols for image optimization. |
| `typedRoutes` | `https://nextjs.org/docs/app/api-reference/config/next-config-js/typedRoutes.md` | Enforces statically typed route strings in `<Link href="...">`. |
| `headers` & `rewrites` | `https://nextjs.org/docs/app/api-reference/config/next-config-js/headers.md` | Configures HTTP security headers and path-rewriting rules. |

---

## 7. CLI & Adapters Architecture

### A. CLI Commands
- `https://nextjs.org/docs/app/api-reference/cli/create-next-app.md`: Fast project scaffolding.
- `https://nextjs.org/docs/app/api-reference/cli/next.md`:
  - `next dev --turbopack`: Starts local development with Turbopack.
  - `next build`: Generates production bundles and runs static optimization.
  - `next start`: Starts production Node.js server.
  - `next info`: Prints environment, Node, and platform diagnostic information.

### B. Deployment Adapters (`@next/routing`)
- Adapter specification: `https://nextjs.org/docs/app/api-reference/adapters.md`
- Adapter creation: `https://nextjs.org/docs/app/api-reference/adapters/creating-an-adapter.md`
- Routing matching: `https://nextjs.org/docs/app/api-reference/adapters/routing-with-next-routing.md`
- Implementing PPR in custom adapters: `https://nextjs.org/docs/app/api-reference/adapters/implementing-ppr-in-an-adapter.md`
- Supporting immutable static assets: `https://nextjs.org/docs/app/api-reference/adapters/immutable-static-assets.md`

---

## 8. Quick Task-to-Feature Decision Matrix

When faced with an implementation task, consult this direct lookup table:

| If you need to... | Use this Next.js Feature | Direct URL |
|---|---|---|
| Secure DB queries from leaking to client | **Data Access Layer (DAL)** + `server-only` | `https://nextjs.org/docs/app/guides/data-security.md` |
| Block tokens/passwords from RSC client props | **React Taint API** (`taintObjectReference`) | `https://nextjs.org/docs/app/api-reference/config/next-config-js/taint.md` |
| Cache an expensive calculation or third-party API | **`"use cache"`** + **`cacheLife`** | `https://nextjs.org/docs/app/api-reference/directives/use-cache.md` |
| Invalidate cached entries on mutation | **`revalidateTag()`** / **`revalidatePath()`** | `https://nextjs.org/docs/app/api-reference/functions/revalidateTag.md` |
| Implement zero-shift hero images | **`<Image priority={true}>`** | `https://nextjs.org/docs/app/api-reference/components/image.md` |
| Avoid layout shift with custom web fonts | **`next/font/google`** or **`next/font/local`** | `https://nextjs.org/docs/app/api-reference/components/font.md` |
| Build modal screens with custom shareable URLs | **Intercepting Routes** (`(..)photo`) | `https://nextjs.org/docs/app/api-reference/file-conventions/intercepting-routes.md` |
| Isolate layout sections with independent loading | **Parallel Routes** (`@slot`) | `https://nextjs.org/docs/app/api-reference/file-conventions/parallel-routes.md` |
| Catch Segment Crashes with Recovery | **`error.tsx`** (`reset()`) | `https://nextjs.org/docs/app/api-reference/file-conventions/error.md` |
| Generate Dynamic Social Card PNGs | **`ImageResponse`** | `https://nextjs.org/docs/app/api-reference/functions/image-response.md` |
| Run background work after HTTP response finishes | **`after(async () => { ... })`** | `https://nextjs.org/docs/app/api-reference/functions/after.md` |
| Containerize for Kubernetes / Docker | **`output: 'standalone'`** in `next.config` | `https://nextjs.org/docs/app/guides/self-hosting.md` |
