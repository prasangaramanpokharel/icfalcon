---
name: packageStandard
description: "icp-hub package ecosystem — package discovery, domain capability mapping, and rules to install only necessary packages instead of writing raw boilerplate."
---

# Package Standard (`packageStandard`)

IcFalcon includes a dedicated package registry and package manager powered by **icp-hub** (https://github.com/prasangapokharel/icp-hub).

When building canister features, **NEVER write raw custom code for problems already solved by an audited hub package** (such as rate limiting, RBAC, ICRC tokens, UUIDs, caching, or outcalls).

---

## 1. Registry & CLI Commands

Packages are indexed in the central registry:
- **Remote Index:** `https://raw.githubusercontent.com/prasangapokharel/icp-hub/main/index.json`
- **Lockfile:** `backend/icp.pkg`
- **Installation Directory:** `backend/pkg/<name>/`

### Essential Commands

| Action | Canonical Command | Fast Alias |
|---|---|---|
| **List available packages** | `falcon pkg:list` | `falcon p:list` |
| **Install package** | `falcon pkg:add <name>` | `falcon add pkg <name>` or `falcon a:p <name>` |
| **List installed packages** | `falcon pkg:installed` | `falcon p:ls` |
| **Publish local package** | `falcon pkg:push <name>` | `falcon p:push <name>` |

---

## 2. Golden Rules for AI Agents

1. **Check Before Writing**: Before writing authentication, caching, validation, crypto, or finance logic, check the Package Map below. If a package exists, run:
   ```bash
   falcon add pkg <name>
   ```
2. **Minimal & Necessary Only**: Only install the packages directly required for the domain. Never bulk-install unneeded modules.
3. **Layering & Import Syntax**: All packages are imported into backend services and repositories using:
   ```motoko
   import Name "mo:pkg/<name>/<entry>";
   ```
   Packages belong in the pure/helper domain: services and repositories may consume them, but `api/` must stay thin.
4. **Zero Traps in Packages**: Hub packages return `ApiResult` or option types — they never invoke `Debug.trap()` for predictable client errors.

---

## 3. Package Domain Capability Map

### Identity, Auth & Access Control
- `rbac`: Role-based access control (`#owner`, `#admin`, `#member`, `#guest`)
- `caller`: Principal authentication helpers and caller verification
- `api-key`: API key generation, hashing, and validation
- `jwt`: JSON Web Token claims, expiry check, base64url parsing
- `totp`: RFC 6238 Time-based One-Time Passwords for 2FA
- `whitelist`: Allowlist and denylist principal management
- `session`: In-memory session token store with expirations

### Money, Payments & Finance
- `wallet`: Custodial wallet, subaccount derivation, balance reads
- `transfer`: ICRC-1/2 transfer argument builders, idempotency, fee reserve
- `transaction`: Transaction ledger record models and history stores
- `subaccount`: Deterministic 32-byte ICRC subaccount derivation
- `icrc1`: ICRC-1 standard ledger types and actor interfaces
- `icrc2`: ICRC-2 approve and `transfer_from` helpers
- `ckbtc`: ckBTC minter, satoshi math, and Bitcoin address validation
- `escrow`: Multi-party payment hold and release pattern
- `split-payment`: Royalty, fee split, and platform commission calculation
- `currency`: Fixed-point monetary calculations and multi-currency formatting
- `vesting`: Cliff and linear token release schedule calculator
- `invoice`: Line item totals, tax calculations, and status transitions
- `subscription`: Recurring SaaS billing tiers and renewal math
- `stripe`: Stripe checkout session metadata and webhook validation
- `paypal`: PayPal order intent and status parsing

### AI & Large Language Models
- `openai`: OpenAI Chat completions request builder and JSON serializer
- `anthropic`: Claude API messages payload builder
- `gemini`: Google Gemini API endpoints and content formatting
- `llm-router`: Multi-provider LLM routing and token estimation
- `embeddings`: Vector cosine similarity and dimension validation

### Data Structures & Performance
- `cache`: TTL in-memory key-value cache
- `lru-cache`: Fixed-capacity Least Recently Used eviction cache
- `priority-queue`: Binary Min/Max Heap priority queue for task scheduling
- `ring-buffer`: Circular zero-alloc stream buffer for logs and metrics
- `bloom-filter`: Fast probabilistic set membership testing
- `trie`: Prefix tree for autocomplete, fast prefix searches, and routing
- `bitset`: Compact 64-bit word bitfield for high-density permission flags
- `graph`: Directed graph, Kahn's topological sort, and cycle detection
- `crud`: Generic Map CRUD repository helpers for `mo:core`
- `indexer`: Secondary map indexing by foreign keys
- `pagination`: Standard Page cursor and offset response wrappers

### Architecture, Events & Resilience
- `universe`: Multi-canister event mesh ("Kafka for Motoko" — outbox, broker, inbox)
- `state-machine`: Finite State Machine (FSM) with transition guards
- `saga`: Distributed saga orchestrator with step compensation rollback
- `event-emitter`: In-memory typed pub/sub event emitter (`on`, `once`, `emit`)
- `job-queue`: Background job processing with retries and exponential delays
- `dead-letter-queue`: DLQ for failed inter-canister calls and replay
- `circuit-breaker`: Automatic failure isolation and cooldown recovery
- `retry`: Exponential and jittered retry with backoff
- `rate-limit`: Per-principal sliding window rate limiting
- `lock`: Distributed mutex / lease manager with TTL to guard async calls
- `batch`: Bulk item chunking, partitioning, and throttled execution
- `tenant`: Multi-tenant data isolation and key namespacing

### External Communications & Webhooks
- `http`: IC HTTP outcall request builder with consensus transforms
- `webhook`: Outbound webhook dispatcher with signature headers
- `webhook-verify`: Timing-safe HMAC signature verification
- `resend`: Resend transactional email API payload builder
- `sendgrid`: SendGrid v3 mail send payload builder
- `slack`: Slack incoming webhook and `chat.postMessage` payloads
- `discord`: Discord webhook embed and notification builder
- `telegram`: Telegram Bot API `sendMessage` payloads
- `whatsapp`: WhatsApp Cloud API template message payloads
- `x-post`: X (Twitter) API v2 status update builder
- `google-calendar`: Google Calendar event insertion builder
- `google-mail`: Gmail MIME message composer
- `google-oauth`: OAuth2 PKCE authorization URL and token swap helpers

### Validation, Sanitization & Text
- `validate-text`: String length, non-empty, and format validation
- `validate-nat`: Numeric ranges, bounds, and positive integers
- `validate-email`: RFC 5322 regex-free email format checking
- `validate-url`: URL protocol, host, and port validation
- `validate-principal`: Principal parsing and anonymous caller guards
- `validate-json`: JSON syntax validation
- `sanitize`: HTML entity escaping and XSS defense
- `slug`: URL-friendly slug generation from arbitrary text
- `nanoid`: Cryptographically secure short unique IDs
- `id`: Deterministic UUID generation from Principal and timestamp
