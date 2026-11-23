---
name: nextjs
description: Production Next.js App Router engineering and readiness checklist. Covers Server Components vs Client boundaries, Data Access Layer (DAL), taint APIs, CSP security headers, metadata SEO, OpenTelemetry, bundle optimization, and standalone Docker deployment.
version: 16.x
last-verified: 2026-11-17
compatibility: Next.js 14, Next.js 15, Next.js 16, React 19, TypeScript 5+
slash-commands:
  - command: /nextjs-production
    description: Full Next.js production architecture audit and readiness checklist
    argument-hint: "[--feature=rsc|dal|csp|cwv] [--audit]"
  - command: /nextjs-rsc
    description: Server and Client Component boundary design and serialization triage
    argument-hint: "[--component=Name] [--boundary=server|client]"
  - command: /nextjs-dal
    description: Data Access Layer pattern implementation with DTOs and security boundaries
    argument-hint: "[--entity=Name]"
  - command: /nextjs-security
    description: CSP, taint API, and security headers configuration
    argument-hint: "[--mode=strict|csp|taint]"
  - command: /nextjs-metadata
    description: SEO metadata and dynamic OG image generation with ImageResponse
    argument-hint: "[--type=static|dynamic] [--page=route]"
  - command: /nextjs-features
    description: Direct lookup of official Next.js App Router features and raw docs
    argument-hint: "[--query=keyword]"
---

# Next.js App Router Production Engineering Guide

Based on the official **Next.js Production Checklist** and verified against Next.js App Router specifications (`https://nextjs.org/docs/app`).

## 1. Core Architecture & Architectural Boundaries

```
┌────────────────────────────────────────────────────────┐
│             Server-Side Boundary (Default)             │
│   • Server Components (RSC) with zero client bundle    │
│   • Direct DB access via Data Access Layer (DAL)       │
│   • Secrets protected with 'server-only' & Taint API   │
└──────────────────────────┬─────────────────────────────┘
                           │ Props serialized via Flight RPC
                           ▼
┌────────────────────────────────────────────────────────┐
│             Client Boundary ("use client")             │
│   • Push to leaf nodes (interactivity, state, hooks)   │
│   • Wrapped in Suspense & error.tsx boundaries         │
└────────────────────────────────────────────────────────┘
```

---

## 2. The Production Readiness Checklist

### A. Security & Data Protection
1. **Enforce `server-only`**: Prevent server modules from leaking into client bundles:
   ```bash
   npm install server-only
   ```
   ```typescript
   // lib/db.ts
   import "server-only";
   import { db } from "@/lib/connection";
   ```
2. **Data Access Layer (DAL)**: Never run ad-hoc raw queries inside random UI components. Centralize authentication and database queries in `src/data-access/` with Data Transfer Objects (DTOs). See [references/dataAccessLayer.md](references/dataAccessLayer.md).
3. **React Taint API**: Prevent secret strings or tokens from reaching client components:
   ```typescript
   import { experimental_taintUniqueValue } from "react";
   experimental_taintUniqueValue("Do not leak API token", user, user.apiToken);
   ```
4. **Environment Variables**: Only expose client-needed vars with `NEXT_PUBLIC_`. Never put private secrets in `NEXT_PUBLIC_`.
5. **Content Security Policy (CSP)**: Implement strict CSP nonces in `middleware.ts` to prevent XSS. See [references/securityHeadersCsp.md](references/securityHeadersCsp.md).

### B. Performance & Core Web Vitals
1. **LCP (Largest Contentful Paint)**: Add `priority` to above-the-fold hero images via `next/image`:
   ```tsx
   <Image src="/hero.webp" alt="Hero banner" width={1200} height={600} priority />
   ```
2. **CLS (Cumulative Layout Shift)**: Always load fonts via `next/font/google` or `next/font/local` to eliminate layout shift:
   ```tsx
   import { Inter } from "next/font/google";
   const inter = Inter({ subsets: ["latin"], display: "swap" });
   ```
3. **Parallel Data Fetching**: Prevent request waterfalls. Use `Promise.all` or independent parallel Server Components:
   ```typescript
   // Fetch in parallel
   const [userData, orders] = await Promise.all([getUser(id), getOrders(id)]);
   ```

### C. Error Handling & Granular Fallbacks
1. **Route Error Boundaries**: Place `error.tsx` (`"use client"`) inside route segments to contain crashes without blowing up the whole layout.
2. **Global Fallback**: Create `app/global-error.tsx` to handle failures in the root `app/layout.tsx`.
3. **Not Found**: Implement `not-found.tsx` and invoke it deliberately via `notFound()`.

### D. SEO & Social Metadata
1. **Metadata API**: Define static or dynamic metadata in `page.tsx`:
   ```typescript
   export async function generateMetadata({ params }): Promise<Metadata> {
     const product = await getProduct(params.id);
     return { title: product.name, description: product.summary };
   }
   ```
2. **Automated Search Engine Files**:
   - `app/sitemap.ts`: Dynamic XML sitemap generator.
   - `app/robots.ts`: Crawling rules for search bots.
   - `app/opengraph-image.tsx`: Dynamic social card generator via `@vercel/og` or `ImageResponse`.

### E. Build & Deployment Optimization
1. **Standalone Output**: Essential for Docker and self-hosted Kubernetes containers:
   ```typescript
   // next.config.ts
   const nextConfig: NextConfig = {
     output: "standalone", // Bundles only required dependencies into .next/standalone
   };
   export default nextConfig;
   ```
2. **Bundle Analysis**: Audit oversized client dependencies:
   ```bash
   ANALYZE=true npm run build
   ```
3. **Pre-Deployment Verification**: Always test with `npm run build && npm run start` (never deploy based solely on `next dev` behavior).

---

## 3. Anti-Patterns & Critical Pitfalls
- ❌ **`"use client"` at Page Root**: Do not place `"use client"` at the top of `page.tsx` or `layout.tsx`; keep pages as Server Components and import interactive client components as leaf nodes.
- ❌ **Client-Side Secret Imports**: Never import database clients (`prisma`, `pg`, `drizzle`) inside files marked with `"use client"`.
- ❌ **Waterfall Fetching**: Avoid sequential `await a(); await b(); await c();` when queries are independent.
- ❌ **Missing Root Error Boundary**: Omitting `global-error.tsx` results in unstyled generic browser error screens when root layouts fail.

---

## 4. References & Bundled Utilities
- **Complete Next.js Feature Map (v16.4.6)**: [references/nextjsFeatureMap.md](references/nextjsFeatureMap.md) — Exhaustive map of all 18 Getting Started modules, 40+ Guides, and 200+ API references with raw documentation URLs.
- **Offline Getting Started Markdown Library**: [assets/](assets/) — Full offline copy of all 18 official Getting Started modules + App Router index & API references for zero-network AI context retrieval.
- Comprehensive production audit checklist: [references/productionChecklist.md](references/productionChecklist.md)
- Security headers and CSP nonce middleware: [references/securityHeadersCsp.md](references/securityHeadersCsp.md)
- Data Access Layer (DAL) implementation: [references/dataAccessLayer.md](references/dataAccessLayer.md)
- Production readiness audit scanner: [scripts/auditProductionReadiness.py](scripts/auditProductionReadiness.py)
