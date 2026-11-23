---
name: shadcn-ui
description: High-density guide and automation for shadcn/ui v4. Supports adding atomic primitives, composite blocks, direct component MDX retrieval, and CVA composition. Use when building, styling, or scaffolding UI with React, Next.js, and Tailwind CSS.
version: v4
last-verified: 2026-11-17
compatibility: React 18+, Next.js 14/15/16, Tailwind CSS v3/v4, Vite
slash-commands:
  - command: /shadcn-add
    description: Add atomic primitives or composite UI blocks via CLI
    argument-hint: "<component|block-name> [--yes] [--overwrite]"
  - command: /shadcn-ai
    description: Scaffold agentic AI components (chat, reasoning, tool-call, prompt-input)
    argument-hint: "<@ai-elements/name>"
  - command: /shadcn-theme
    description: Configure CSS variables, design tokens, and dark mode
    argument-hint: "[--base-color=neutral|slate|zinc] [--css-vars]"
  - command: /shadcn-diff
    description: Inspect differences against upstream component registries
    argument-hint: "[<component>]"
---

# shadcn/ui Engineering Guide

## 1. Core Architecture & Philosophy
- **Code Ownership**: Components live inside your repository (`components/ui/`). Never treat them as locked node_modules.
- **Atomic Composition**: Built on accessible headless primitives (Radix UI, Base UI, React Aria), styled using Tailwind CSS, and variant-composed with `cva` (Class Variance Authority).
- **Utility Standard**: Always use `cn(...)` (`clsx` + `tailwind-merge`) to resolve className conflicts.

---

## 2. CLI Command Matrix (CLI v4)

Run via your package runner (`npx shadcn@latest`, `pnpm dlx shadcn@latest`, `bunx --bun shadcn@latest`):

| Action | Command | Key Flags |
| :--- | :--- | :--- |
| **Initialize** | `npx shadcn@latest init` | `-t, --template <next\|vite>`<br>`-b, --base <radix\|base\|aria>`<br>`-d, --defaults`, `-y, --yes` |
| **Add Primitive** | `npx shadcn@latest add <name>` | `-y` (skip prompts), `-o` (overwrite), `--dry-run`, `--diff` |
| **Add Composite Block** | `npx shadcn@latest add <block-name>` | e.g. `dashboard-01`, `login-01`, `sidebar-01` |
| **Add AI Components** | `npx shadcn@latest add @ai-elements/<component>` | e.g. `prompt-input`, `reasoning`, `tool-call`, `conversation` |
| **Add Remote Block / Registry** | `npx shadcn@latest add "<url-or-spec>"` | e.g. `https://www.shadcn-ui-blocks.com/r/hero-01.json`<br>`@namespace/block-name` |
| **Fetch Terminal Docs / MD** | `npx shadcn@latest docs <component>` | Fetches live MD documentation directly into stdout |
| **Diagnose Environment** | `npx shadcn@latest info` | Inspects Tailwind variables, framework, and installed components |

---

## 3. Direct Component MD / MDX Target Integration
Rather than guessing or reading generic websites, fetch component `.mdx` files directly:

1. **CLI Native**:
   ```bash
   npx shadcn@latest docs button
   ```
2. **Deterministic Script Fetcher**:
   Use the bundled [scripts/fetchComponentDocs.py](scripts/fetchComponentDocs.py) to pull raw `.mdx` directly from the official shadcn repository:
   ```bash
   python3 skills/frontend/shadcn-ui/scripts/fetchComponentDocs.py --component dialog
   ```
3. See [references/componentMarkdownSources.md](references/componentMarkdownSources.md) for the direct raw GitHub MDX endpoints.

---

## 4. shadcn AI Components & Agentic UI
For LLM chat interfaces, agent reasoning, and generative UI:
- **Core Primitives**: `conversation`, `message`, `prompt-input`, `reasoning`, `tool-call`, `sources`, and `code-block`.
- **Install Syntax**:
  ```bash
  # Chat layout
  npx shadcn@latest add @ai-elements/conversation @ai-elements/prompt-input -y
  # Agent thought & tool inspection cards
  npx shadcn@latest add @ai-elements/reasoning @ai-elements/tool-call -y
  ```
- **Custom Registry Config**: Configure `@ai-elements` or `@assistant-ui` in `components.json`. See [references/aiComponentsCatalog.md](references/aiComponentsCatalog.md) for complete details.

---

## 5. Blocks & Layout Workflow
When building complex screens:
1. Check available blocks or templates (dashboards, forms, navbars).
2. Install via block command:
   ```bash
   npx shadcn@latest add dashboard-01 -y
   ```
3. Customize exported components directly inside `components/blocks/` or `app/`.

---

## 5. Anti-Patterns & Pitfalls
- ❌ **Wrapper Antipath**: Do not create redundant abstraction wrappers around shadcn primitives unless extending global design tokens.
- ❌ **Inline Style Overrides**: Do not use `style={{...}}`; use Tailwind utility classes via `className={cn("...", className)}`.
- ❌ **Hardcoded Hex Values**: Always use semantic design tokens (`bg-background`, `text-foreground`, `text-muted-foreground`, `border-border`).
- ❌ **Blind Overwrite**: Use `--diff` or `--dry-run` when updating existing primitives to avoid wiping customizations.

---

## 6. References & Bundled Tools
- **Complete shadcn/ui Offline Docs Library**: [assets/](assets/) — Exhaustive offline markdown docs covering 69 UI primitives, 22 AI elements, theming, CLI, forms, dark mode, and registry specifications.
- Detailed command flags: [references/cliCommands.md](references/cliCommands.md)
- AI components catalog: [references/aiComponentsCatalog.md](references/aiComponentsCatalog.md)
- Block registries & sources: [references/blocksCatalog.md](references/blocksCatalog.md)
- Raw MDX component source links: [references/componentMarkdownSources.md](references/componentMarkdownSources.md)
- CLI doc retrieval tool: [scripts/fetchComponentDocs.py](scripts/fetchComponentDocs.py)
