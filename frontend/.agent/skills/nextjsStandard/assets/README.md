# Next.js App Router Documentation Assets (v16.4.6)

This directory mirrors the exact sidebar hierarchy of the official Next.js App Router documentation (`https://nextjs.org/docs/app`).

## Directory Hierarchy

```
assets/
├── getting-started/             # 18 Step-by-step introductory guides
│   ├── installation.md
│   ├── project-structure.md
│   ├── layouts-and-pages.md
│   ├── linking-and-navigating.md
│   ├── server-and-client-components.md
│   ├── fetching-data.md
│   ├── mutating-data.md
│   ├── caching.md
│   ├── revalidating.md
│   ├── error-handling.md
│   ├── css.md
│   ├── images.md
│   ├── fonts.md
│   ├── metadata-and-og-images.md
│   ├── route-handlers.md
│   ├── proxy.md
│   ├── deploying.md
│   └── upgrading.md
│
├── api-reference/               # Full API technical specifications
│   ├── directives/              # use client, use server, use cache variants
│   │   ├── use-cache.md
│   │   ├── use-cache-private.md
│   │   ├── use-cache-remote.md
│   │   ├── use-client.md
│   │   └── use-server.md
│   ├── components/              # Built-in React components
│   │   ├── font.md
│   │   ├── form.md
│   │   ├── image.md
│   │   ├── link.md
│   │   └── script.md
│   ├── file-conventions/        # Special files & routing conventions
│   │   ├── layout.md, page.md, loading.md, error.md, not-found.md ...
│   │   ├── metadata/            # app-icons, manifest, opengraph-image, robots, sitemap
│   │   └── route-segment-config/# dynamicParams, ensureStatic, instant, maxDuration ...
│   ├── functions/               # 44 Server and Client functions & hooks
│   │   ├── cookies.md, headers.md, redirect.md, not-found.md ...
│   │   ├── revalidateTag.md, revalidatePath.md, cacheLife.md, cacheTag.md ...
│   │   └── useRouter.md, usePathname.md, useSearchParams.md ...
│   ├── cli/                     # CLI tooling
│   │   ├── create-next-app.md
│   │   └── next.md
│   ├── edge-runtime.md          # Edge runtime API specification
│   └── turbopack.md             # Turbopack bundler configuration
│
├── architecture/                # Core internal architectural principles
│   ├── accessibility.md         # Built-in accessibility features
│   ├── fast-refresh.md          # Hot Module Replacement & live state
│   ├── nextjs-compiler.md       # Rust compiler (SWC) architecture
│   └── supported-browsers.md    # JavaScript features and polyfill specs
│
├── community/                   # Ecosystem & contributors
│   ├── contribution-guide.md
│   └── rspack.md
│
└── glossary.md                  # Comprehensive glossary of Next.js concepts
```
