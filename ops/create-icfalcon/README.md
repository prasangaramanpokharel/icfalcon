# create-icfalcon

Scaffold an [IcFalcon](https://gitlab.com/prasangapokharel/icfalcon) app — Motoko backend, Next.js frontend, `falcon` CLI.

## Usage

One command. Everything else is automatic.

```bash
npm create icfalcon@latest my-app
```

Open http://localhost:3000 when setup finishes.

```bash
npx create-icfalcon my-app
```

## What runs automatically

1. Clone IcFalcon from GitLab (wallet demo, finance packages, `falcon` CLI)
2. `./ops/install.sh` — install `falcon` CLI
3. `falcon s:init` — backend, deploy, frontend, dev server

Open `/wallet` after setup for the custodial wallet reference demo.

## Prerequisites

Install these **before** running `npm create`:

- [dfx](https://internetcomputer.org/docs/current/developer-docs/getting-started/install)
- [mops](https://mops.one) — `npm install -g ic-mops`
- Node.js 20+
- git

## Links

- GitLab: https://gitlab.com/prasangapokharel/icfalcon
- Docs: https://gitlab.com/prasangapokharel/icfalcon/tree/main/docs
