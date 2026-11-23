# shadcn AI Components & Registries Catalog

Modern agentic and chat interfaces built on `shadcn/ui` use specialized AI component registries (`@ai-elements`, `@assistant-ui`, and AI SDK primitives). Like core shadcn, you own the copied source code in `components/ai/`.

---

## 1. Full Available AI Component Matrix

| Category | Component Name | CLI Install Command | Purpose & Features |
| :--- | :--- | :--- | :--- |
| **Conversations** | `conversation` / `thread` | `npx shadcn@latest add @ai-elements/conversation` | Thread container, auto-scroll to bottom, scroll pinning during streaming. |
| **Messages** | `message` | `npx shadcn@latest add @ai-elements/message` | User/assistant message bubbles, avatar slots, status badges, markdown rendering. |
| **Prompt Input** | `prompt-input` | `npx shadcn@latest add @ai-elements/prompt-input` | Auto-resizing textarea, submit/stop buttons, attachment drawer, audio recording triggers. |
| **Reasoning** | `reasoning` | `npx shadcn@latest add @ai-elements/reasoning` | Expandable/collapsible accordion for chain-of-thought, model thinking duration counter. |
| **Tool Calls** | `tool-call` | `npx shadcn@latest add @ai-elements/tool-call` | Execution card for agent tool invocations, parameter JSON viewer, output state (running/success/error). |
| **Code & Artifacts** | `code-block` / `artifact` | `npx shadcn@latest add @ai-elements/code-block` | Syntax-highlighted code output, copy button, side-drawer artifact panel for live previews. |
| **Citations & RAG** | `sources` / `citations` | `npx shadcn@latest add @ai-elements/sources` | Pill or popover cards displaying grounded web links, doc snippets, and relevancy tags. |
| **Action Bar** | `message-actions` | `npx shadcn@latest add @ai-elements/message-actions` | Thumbs up/down feedback, message regenerate, copy markdown, edit prompt button. |
| **Model Selector** | `model-selector` | `npx shadcn@latest add @ai-elements/model-selector` | Dropdown picker for switching LLMs, temperature, or thinking budgets. |

---

## 2. Registry Setup in `components.json`

To enable installing AI components seamlessly via namespaces:

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "default",
  "registries": {
    "@ai-elements": "https://ai-elements.vercel.sh/r",
    "@assistant-ui": "https://r.assistant-ui.com/styles/{style}"
  }
}
```

---

## 3. Quick Install Commands

```bash
# Add core chat interface primitives
npx shadcn@latest add @ai-elements/conversation @ai-elements/message @ai-elements/prompt-input -y

# Add agent reasoning & tool inspection
npx shadcn@latest add @ai-elements/reasoning @ai-elements/tool-call -y

# Add RAG citations & code view
npx shadcn@latest add @ai-elements/sources @ai-elements/code-block -y
```
