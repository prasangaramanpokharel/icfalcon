---
title: Upgrading
description: Learn how to upgrade your Next.js application to the latest version or canary.
url: "https://nextjs.org/docs/app/getting-started/upgrading"
docs_index: /docs/llms.txt
lastUpdated: 2026-10-06
prerequisites:
  - "Getting Started: /docs/app/getting-started"
related:
  - /docs/app/guides/upgrading/version-16
  - /docs/app/guides/upgrading/version-15
  - /docs/app/guides/upgrading/version-14
---

> For an index of all documentation, see [/docs/llms.txt](/docs/llms.txt).

## Latest version

To update to the latest version of Next.js, you can use the `upgrade` command:

**pnpm**

```bash
pnpm next upgrade
```

**npm**

```bash
npx next upgrade
```

**yarn**

```bash
yarn next upgrade
```

**bun**

```bash
bunx next upgrade
```

Versions before Next.js 16.1.0 do not support the `upgrade` command and need to use a separate package instead:

```bash title="Terminal"
npx @next/codemod@canary upgrade latest
```

To have a coding agent perform and verify the upgrade, run:

```bash title="Terminal"
npx next@canary upgrade --agent=latest
```

See [Upgrade with a coding agent](/docs/app/guides/upgrading/agent-upgrade) for other policies and upgrade reminders.

If you prefer to upgrade manually, install the latest Next.js and React versions:

**pnpm**

```bash
pnpm i next@latest react@latest react-dom@latest eslint-config-next@latest
```

**npm**

```bash
npm i next@latest react@latest react-dom@latest eslint-config-next@latest
```

**yarn**

```bash
yarn add next@latest react@latest react-dom@latest eslint-config-next@latest
```

**bun**

```bash
bun add next@latest react@latest react-dom@latest eslint-config-next@latest
```

## Canary version

To update to the latest canary, make sure you're on the latest version of Next.js and everything is working as expected. Then, run the following command:

**pnpm**

```bash
pnpm add next@canary
```

**npm**

```bash
npm i next@canary
```

**yarn**

```bash
yarn add next@canary
```

**bun**

```bash
bun add next@canary
```

### Features available in canary

The following features are currently available in canary:

**Authentication**:

- [`forbidden`](/docs/app/api-reference/functions/forbidden)
- [`unauthorized`](/docs/app/api-reference/functions/unauthorized)
- [`forbidden.js`](/docs/app/api-reference/file-conventions/forbidden)
- [`unauthorized.js`](/docs/app/api-reference/file-conventions/unauthorized)
- [`authInterrupts`](/docs/app/api-reference/config/next-config-js/authInterrupts)

## Version guides

See the version guides for in-depth upgrade instructions.

- [Version 16](/docs/app/guides/upgrading/version-16): Upgrade your Next.js Application from Version 15 to 16.
- [Version 15](/docs/app/guides/upgrading/version-15): Upgrade your Next.js Application from Version 14 to 15.
- [Version 14](/docs/app/guides/upgrading/version-14): Upgrade your Next.js Application from Version 13 to 14.

---

For a semantic overview of all documentation, see [/sitemap.md](/sitemap.md)

For an index of all available documentation, see [/docs/llms.txt](/docs/llms.txt)