# shadcn CLI v4 Complete Command Reference

## 1. `init` (Project Initialization)
Initializes `components.json`, color systems, and dependencies.
```bash
npx shadcn@latest init [options]
```
### Flags
* `-t, --template <name>`: Framework template (`next`, `vite`, `start`, `react-router`, `astro`, `laravel`).
* `-b, --base <primitive>`: Headless primitive core (`radix`, `base`, `aria`).
* `-p, --preset <name>`: Preconfigured theme/style preset (e.g., `nova`).
* `-d, --defaults`: Use default configuration without interactive prompts.
* `-y, --yes`: Bypass confirmation prompts.
* `--monorepo`: Configure within a monorepo workspace.
* `--rtl` / `--no-rtl`: Toggle right-to-left layout support.

---

## 2. `add` (Adding Primitives, Blocks & Remote Registries)
```bash
npx shadcn@latest add [components...] [options]
```
### Flags
* `-y, --yes`: Skip confirmation prompts.
* `-o, --overwrite`: Overwrite existing files without asking.
* `-c, --cwd <path>`: Working directory containing `components.json`.
* `--dry-run`: View proposed file creations and dependencies without writing to disk.
* `--diff`: Check local modifications against upstream registry updates.
* `--view`: Print raw payload source directly.

---

## 3. `docs` (Agent Markdown Doc Fetcher)
Fetches formatted documentation and usage examples for any component.
```bash
npx shadcn@latest docs [component]
# Example:
npx shadcn@latest docs combobox
```

---

## 4. `info` (Project Diagnostics)
Prints active framework, CSS token setup, installed components, and direct documentation links.
```bash
npx shadcn@latest info
```
