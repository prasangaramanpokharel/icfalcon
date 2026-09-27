# SaaS Prompt Template: Branded URL Shortener & QR Analytics

Copy and paste this prompt directly into your AI coding assistant to build a high-performance URL shortener and click analytics SaaS on the Internet Computer with IcFalcon.

---

```markdown
You are an expert full-stack Internet Computer engineer building "FalconLink" — a branded link management, 301/302 gateway redirection, and click analytics SaaS on IcFalcon.

### 1. Mandatory Skills to Read First
1. `.agents/skills/integrationStandard/SKILL.md` (Feature integration flow)
2. `.agents/skills/layeringStandard/SKILL.md` (4-tier architecture)
3. `.agents/skills/packageStandard/SKILL.md` (icp-hub package catalog)
4. `.agents/skills/codingStandard/SKILL.md` (Motoko conventions)
5. `.agents/skills/frontendStandard/SKILL.md` (Next.js with shadcn/ui)

### 2. Install Required icp-hub Packages
Run the following package install commands:
```bash
falcon add pkg slug
falcon add pkg nanoid
falcon add pkg validate-url
falcon add pkg cache
falcon add pkg crud
falcon add pkg time
falcon add pkg errors
```

### 3. Backend Specification
Scaffold the feature module using the CLI:
```bash
falcon m:f Shortener
```

Implement the following layered architecture in `backend/src/`:
1. **Types (`backend/src/types.mo`):**
   - `ShortLink`: `{ id : Text; slug : Text; originalUrl : Text; title : Text; owner : Principal; totalClicks : Nat; isActive : Bool; createdAt : Int }`
   - `ClickEvent`: `{ linkId : Text; timestamp : Int; referer : Text; userAgent : Text }`
   - `LinkAnalytics`: `{ link : ShortLink; recentClicks : [ClickEvent]; clicksLast24h : Nat }`

2. **Storage (`backend/src/storage/ShortenerStorage.mo`):**
   - Persistent `Map.Map<Text, ShortLink>` keyed by slug for instant lookup.
   - Persistent `Map.Map<Text, [ClickEvent]>` storing click histories per link ID.
   - Fast in-memory TTL lookup cache using `mo:pkg/cache/cache`.

3. **Validators (`backend/src/validators/ShortenerValidator.mo`):**
   - Validate target URL protocol (`http://` or `https://`) via `mo:pkg/validate/url`.
   - Validate custom slug (alphanumeric, dashes, 3-32 chars) via `mo:pkg/slug/slug`.

4. **Service (`backend/src/services/ShortenerService.mo`):**
   - `createLink(url : Text, title : Text, customSlugOpt : ?Text)`: If custom slug provided, verifies uniqueness; otherwise generates a collision-free 6-character shortcode using `mo:pkg/nanoid/nanoid`.
   - `recordClick(slug : Text, referer : Text, ua : Text)`: Increments click counter, appends click event, updates in-memory cache.
   - Canister `http_request` routing: When a user visits `https://<canister-id>.raw.icp0.io/<slug>`, intercepts the raw HTTP request and returns an HTTP `302 Found` with `Location: <originalUrl>`!

5. **API Endpoint (`backend/src/api/v1/Shortener.mo`):**
   - `createShortLink(url : Text, title : Text, customSlug : ?Text) : async ApiResult<ShortLink>`
   - `getMyLinks() : async ApiResult<[ShortLink]>`
   - `getAnalytics(slug : Text) : async ApiResult<LinkAnalytics>`
   - `deleteLink(slug : Text) : async ApiResult<Bool>`

### 4. Frontend Specification (`frontend/app/`)
Build a high-conversion link management dashboard:
1. **Quick Shorten Hero Input (`/dashboard/links`):**
   - Prominent URL input with "Shorten Link" button and optional custom slug toggle.
2. **Link Inventory Table:**
   - Displays Title, Original URL (truncated), Shortened Link (`https://...`), Click Count Badge, Created Date.
   - Actions: 1-click "Copy Short Link", "View Analytics", "QR Code", "Delete".
3. **Analytics Detail Drawer (`/dashboard/links/[slug]`):**
   - Top metrics cards: Total Clicks, Unique Referrers, Peak Activity Hour.
   - Referrer breakdown list (Twitter, Direct, Google, LinkedIn).
4. **QR Code Modal:**
   - Instant visual QR code preview for printing or mobile scanning, with PNG download option.

### 5. Verification & Audit
```bash
falcon audit code:motoko --fix
falcon b:test --local
falcon b:deploy --local
falcon f:dev
```
```
