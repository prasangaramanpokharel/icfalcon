# Next.js Full Production Audit Checklist

An exhaustive checklist reflecting the official Next.js guidelines across the application lifecycle.

## Phase 1: During Development
- [ ] **Routing**:
  - [ ] Use `layout.tsx` for persistent shell UI and shared state.
  - [ ] Use `<Link>` with `prefetch` for fast page transitions.
- [ ] **Media & Assets**:
  - [ ] `next/image` used with explicit dimensions to prevent CLS.
  - [ ] Critical above-the-fold hero image marked with `priority`.
  - [ ] `next/font` used with `display: 'swap'` for zero font layout shift.
  - [ ] Third-party scripts loaded via `next/script` with appropriate strategies (`afterInteractive`, `lazyOnload`).
- [ ] **Data Fetching**:
  - [ ] Request waterfalls eliminated using `Promise.all` or parallel Server Components.
  - [ ] Server actions encapsulated with authentication and schema validation (Zod).

---

## Phase 2: Security & Privacy
- [ ] **Module Boundaries**:
  - [ ] `import "server-only"` added to all database, ORM, and secret handling files.
  - [ ] Taint API (`experimental_taintUniqueValue`) applied to sensitive user fields (tokens, hashes).
- [ ] **Environment Variables**:
  - [ ] Audit `.env.local` to verify only public values carry the `NEXT_PUBLIC_` prefix.
  - [ ] `.env*` files excluded from Git tracking in `.gitignore`.
- [ ] **Security Headers & CSP**:
  - [ ] Strict Content Security Policy (CSP) with cryptographic nonces configured in `middleware.ts`.
  - [ ] Strict-Transport-Security (HSTS), X-Content-Type-Options, X-Frame-Options configured.

---

## Phase 3: Error Handling & Observability
- [ ] **Error Boundaries**:
  - [ ] `app/error.tsx` implemented with retry controls.
  - [ ] `app/global-error.tsx` configured to wrap `<html>` and `<body>`.
  - [ ] `app/not-found.tsx` styled to match brand design.
- [ ] **Observability**:
  - [ ] OpenTelemetry instrumentation configured via `instrumentation.ts`.
  - [ ] Real-user monitoring (RUM) configured for Core Web Vitals (LCP, INP, CLS).

---

## Phase 4: Build & Deployment
- [ ] **Build Verification**:
  - [ ] Successful local build: `npm run build`.
  - [ ] Local production run verified: `npm run start`.
  - [ ] `output: 'standalone'` configured if deploying to Docker or Kubernetes.
  - [ ] Bundle analyzer inspected via `@next/bundle-analyzer` to eliminate bloat packages.
