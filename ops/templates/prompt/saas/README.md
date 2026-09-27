# IcFalcon Ready-Made SaaS Product Prompts

Pre-engineered, production-ready prompts designed for AI coding assistants (Antigravity, Cursor, Claude, Windsurf, or ChatGPT) to build complete full-stack SaaS applications on the Internet Computer with **zero guesswork**.

Every prompt explicitly specifies:
1. **Mandatory Skills** to read first (`integrationStandard`, `layeringStandard`, `packageStandard`, etc.).
2. **Exact Hub Packages** to install from `icp-hub` (`falcon add pkg <name>`).
3. **Layered Motoko Backend** (Types, persistent Storage, pure Validators, Services, API mixins).
4. **Next.js Frontend** with shadcn/ui components and dark mode.
5. **Testing & Verification** commands (`falcon b:test --local`, `falcon audit code:motoko`).

---

## Catalog of 10 SaaS Product Prompts

| # | Product Name | Template File | Domain & Capabilities | Required Hub Packages |
|---|---|---|---|---|
| 1 | **FalconCopy** | [`ai-copywriter.md`](ai-copywriter.md) | AI Marketing Copywriter & Content Generator SaaS | `openai`, `rate-limit`, `rbac`, `caller`, `nanoid`, `validate-text`, `time`, `errors` |
| 2 | **FalconBoard** | [`feedback-board.md`](feedback-board.md) | Customer Feedback, Feature Requests & Roadmap Voting SaaS | `rbac`, `caller`, `slug`, `pagination`, `validate-text`, `crud`, `time`, `errors` |
| 3 | **FalconForm** | [`form-builder.md`](form-builder.md) | Interactive Typeform-style Form & Survey Builder with Webhooks | `nanoid`, `validate-json`, `webhook`, `validate-text`, `csv`, `crud`, `time`, `errors` |
| 4 | **FalconStatus** | [`status-page.md`](status-page.md) | Uptime Monitor & Public Status Page with IC HTTP Outcalls | `http`, `cron`, `ring-buffer`, `validate-url`, `validate-text`, `time`, `errors` |
| 5 | **FalconInvoice** | [`invoicing-ledger.md`](invoicing-ledger.md) | B2B Multi-Currency Invoicing & On-Chain Payment Reconciliation | `invoice`, `wallet`, `transfer`, `subaccount`, `icrc1`, `nanoid`, `validate-text`, `time`, `errors` |
| 6 | **FalconLink** | [`link-shortener.md`](link-shortener.md) | Branded URL Shortener with 302 Redirection & QR Analytics | `slug`, `nanoid`, `validate-url`, `cache`, `crud`, `time`, `errors` |
| 7 | **FalconPost** | [`newsletter-platform.md`](newsletter-platform.md) | Creator Newsletter Publishing & Subscriber Management | `resend`, `validate-email`, `email-verify`, `subscription`, `slug`, `sanitize`, `time`, `errors` |
| 8 | **FalconKey** | [`api-key-manager.md`](api-key-manager.md) | Developer API Gateway, Secret Key Provisioning & Quota Manager | `api-key`, `rate-limit`, `rbac`, `caller`, `nanoid`, `validate-text`, `time`, `errors` |
| 9 | **FalconEscrow** | [`token-escrow-p2p.md`](token-escrow-p2p.md) | Web3 P2P Escrow, Milestone Release & Dispute Marketplace | `escrow`, `wallet`, `transfer`, `subaccount`, `icrc1`, `rbac`, `nanoid`, `time`, `errors` |
| 10 | **FalconPass** | [`event-ticketing.md`](event-ticketing.md) | On-Chain Event Ticketing & Gate Pass QR Scanner SaaS | `nanoid`, `wallet`, `transfer`, `icrc1`, `lock`, `validate-text`, `time`, `errors` |

---

## How to Use

1. Choose a SaaS product from the table above.
2. Open its markdown file and copy the contents inside the code block.
3. Paste directly into your AI assistant prompt:
   > *"Build this SaaS application in my IcFalcon repository according to this specification:"*
4. Sit back and watch the AI install the exact packages, generate the Motoko backend, create the frontend dashboard, and run tests!
