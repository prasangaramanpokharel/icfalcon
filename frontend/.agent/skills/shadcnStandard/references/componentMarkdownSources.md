# shadcn/ui Component MDX & Markdown Sources

Targeting raw Markdown (`.mdx`) files directly from the official repository (`shadcn-ui/ui`):

## Direct Raw GitHub MDX Endpoints
Base URL: `https://raw.githubusercontent.com/shadcn-ui/ui/main/apps/www/content/docs/components/`

| Component | Raw MDX URL |
| :--- | :--- |
| **Accordion** | `.../accordion.mdx` |
| **Alert** | `.../alert.mdx` |
| **Alert Dialog** | `.../alert-dialog.mdx` |
| **Avatar** | `.../avatar.mdx` |
| **Badge** | `.../badge.mdx` |
| **Button** | `.../button.mdx` |
| **Card** | `.../card.mdx` |
| **Checkbox** | `.../checkbox.mdx` |
| **Combobox** | `.../combobox.mdx` |
| **Command** | `.../command.mdx` |
| **Dialog** | `.../dialog.mdx` |
| **Dropdown Menu** | `.../dropdown-menu.mdx` |
| **Form** | `.../form.mdx` |
| **Input** | `.../input.mdx` |
| **Popover** | `.../popover.mdx` |
| **Select** | `.../select.mdx` |
| **Sheet** | `.../sheet.mdx` |
| **Sidebar** | `.../sidebar.mdx` |
| **Table** | `.../table.mdx` |
| **Tabs** | `.../tabs.mdx` |
| **Toast / Sonner**| `.../sonner.mdx` |

## AI-Native & Agentic Components (@ai-elements & @assistant-ui)
Custom registry definitions and source locations for AI-specific components:

| AI Component | Registry Target | Description |
| :--- | :--- | :--- |
| **Conversation** | `@ai-elements/conversation` | Thread container with auto-scroll pinning |
| **Prompt Input** | `@ai-elements/prompt-input` | Auto-expanding composer with attachments & stop controls |
| **Reasoning** | `@ai-elements/reasoning` | Collapsible chain-of-thought and thinking time display |
| **Tool Call** | `@ai-elements/tool-call` | Card displaying tool arguments and execution output |
| **Sources** | `@ai-elements/sources` | Grounded citation pills with snippet popovers |
| **Code Block** | `@ai-elements/code-block` | Syntax-highlighted code with copy & diff toggles |

## Programmatic Fetching
Fetch any component's raw documentation using `scripts/fetchComponentDocs.py`:
```bash
python3 scripts/fetchComponentDocs.py --component button --save
```
