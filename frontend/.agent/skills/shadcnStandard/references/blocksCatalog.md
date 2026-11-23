# shadcn Blocks & External Registry Catalog

Blocks are multi-component layouts (e.g. sidebars, auth screens, dashboards, settings pages).

## Standard Official Blocks
Install official blocks directly via:
```bash
npx shadcn@latest add dashboard-01 -y
npx shadcn@latest add login-01 -y
npx shadcn@latest add sidebar-01 -y
npx shadcn@latest add calendar-01 -y
```

## Adding from External Registries & URLs
shadcn CLI supports adding blocks directly from third-party registry JSON endpoints:

### URL Syntax
```bash
npx shadcn@latest add "https://www.shadcn-ui-blocks.com/r/hero-01.json" -y
```

### Namespace Syntax
```bash
npx shadcn@latest add @namespace/block-name -y
```

## Best Practices for Blocks
1. Inspect before writing using `--dry-run`:
   ```bash
   npx shadcn@latest add dashboard-01 --dry-run
   ```
2. Verify existing primitives are not inadvertently broken by inspecting git diff after installation.
