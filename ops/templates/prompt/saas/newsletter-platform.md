# SaaS Prompt Template: Creator Newsletter & Subscription Publishing

Copy and paste this prompt directly into your AI coding assistant to build a creator newsletter and email publishing platform on the Internet Computer with IcFalcon.

---

```markdown
You are an expert full-stack Internet Computer engineer building "FalconPost" — a creator newsletter publishing and subscriber management SaaS on IcFalcon.

### 1. Mandatory Skills to Read First
1. `.agent/skills/integrationStandard/SKILL.md` (Feature integration flow)
2. `.agent/skills/layeringStandard/SKILL.md` (4-tier architecture)
3. `.agent/skills/packageStandard/SKILL.md` (icp-hub package catalog)
4. `.agent/skills/extensionsStandard/emailStandard/SKILL.md` (Transactional email dispatch)
5. `.agent/skills/frontendStandard/SKILL.md` (Next.js with shadcn/ui)

### 2. Install Required icp-hub Packages
Run the following package install commands:
```bash
falcon add pkg resend
falcon add pkg validate-email
falcon add pkg email-verify
falcon add pkg subscription
falcon add pkg slug
falcon add pkg sanitize
falcon add pkg time
falcon add pkg errors
```

### 3. Backend Specification
Scaffold the feature module using the CLI:
```bash
falcon m:f Newsletter
```

Implement the following layered architecture in `backend/src/`:
1. **Types (`backend/src/types.mo`):**
   - `PostState`: `#draft; #scheduled(publishAt : Int); #published; #archived`
   - `SubscriberStatus`: `#unverified; #active; #unsubscribed`
   - `Subscriber`: `{ id : Text; email : Text; status : SubscriberStatus; verificationToken : Text; subscribedAt : Int }`
   - `NewsletterPost`: `{ id : Text; slug : Text; title : Text; subtitle : Text; contentMarkdown : Text; state : PostState; author : Principal; views : Nat; publishedAt : ?Int }`

2. **Storage (`backend/src/storage/NewsletterStorage.mo`):**
   - Persistent `Map.Map<Text, NewsletterPost>` keyed by post ID.
   - Persistent `Map.Map<Text, Subscriber>` keyed by normalized email.
   - Secondary index mapping verification tokens to subscriber records.

3. **Validators (`backend/src/validators/NewsletterValidator.mo`):**
   - Strict email format validation via `mo:pkg/validate/email`.
   - Markdown sanitization via `mo:pkg/sanitize/sanitize` to strip unsafe scripts and attributes.

4. **Service (`backend/src/services/NewsletterService.mo`):**
   - `subscribe(email : Text)`: Checks if already active. If new, generates verification token with `mo:pkg/email-verify/email-verify` and triggers a confirmation email via Resend API outcall (`mo:pkg/resend/resend`).
   - `verifySubscriber(token : Text)`: Marks subscriber `#active`.
   - `publishAndBroadcast(postId : Text)`: Updates post state to `#published`. Iterates over active subscribers and triggers a batch email delivery broadcast through Resend.

5. **API Endpoint (`backend/src/api/v1/Newsletter.mo`):**
   - `subscribe(email : Text) : async ApiResult<Text>`
   - `verify(token : Text) : async ApiResult<Bool>`
   - `getPublicFeed() : async ApiResult<[PublicPostSnippet]>`
   - `getPostBySlug(slug : Text) : async ApiResult<NewsletterPost>`
   - `createDraft(title : Text, content : Text) : async ApiResult<NewsletterPost>`
   - `publishPost(id : Text) : async ApiResult<Bool>`
   - `getSubscriberStats() : async ApiResult<SubscriberStats>`

### 4. Frontend Specification (`frontend/app/`)
Build a Substack-style reading experience and clean writing studio:
1. **Public Publication Home (`/newsletter`):**
   - Clean editorial header with publication name and description.
   - Prominent email subscription box with instant validation.
   - Chronological list of published essays with reading time estimates.
2. **Post Reader View (`/newsletter/[slug]`):**
   - Distraction-free typography (large headings, generous line height, code syntax highlighting).
   - Sticky newsletter subscription footer.
3. **Creator Studio (`/dashboard/newsletter/write`):**
   - Split-pane or tabbed Markdown editor with real-time live preview.
   - "Publish & Send to Subscribers" confirmation dialog showing total recipient count.
4. **Subscriber Analytics Dashboard (`/dashboard/newsletter/subscribers`):**
   - Total active subscribers metric card.
   - Subscriber table with signup dates and verification status.

### 5. Verification & Audit
```bash
falcon audit code:motoko --fix
falcon b:test --local
falcon b:deploy --local
falcon f:dev
```
```
