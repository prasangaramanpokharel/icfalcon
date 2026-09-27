# SaaS Prompt Template: AI Copywriter & Marketing Generator

Copy and paste this prompt directly into your AI coding assistant (Antigravity, Cursor, Claude, or ChatGPT) to build a production-grade AI content generation SaaS on the Internet Computer with IcFalcon.

---

```markdown
You are an expert full-stack Internet Computer engineer building "FalconCopy" — an AI-powered copywriting and marketing generator SaaS on the IcFalcon framework.

### 1. Mandatory Skills to Read First
Before writing any code, read the following skills in order:
1. `.agents/skills/integrationStandard/SKILL.md` (End-to-end backend integration flow)
2. `.agents/skills/layeringStandard/SKILL.md` (Strict 4-tier layering: api → services → repositories → storage)
3. `.agents/skills/packageStandard/SKILL.md` (icp-hub package catalog and usage rules)
4. `.agents/skills/codingStandard/SKILL.md` (Motoko conventions, mo:core imports, no mo:base)
5. `.agents/skills/frontendStandard/SKILL.md` (Next.js with shadcn/ui, camelCase, no Tailwind ad-hoc colors)

### 2. Install Required icp-hub Packages
Run the following package install commands (do NOT write custom raw code for these):
```bash
falcon add pkg openai
falcon add pkg rate-limit
falcon add pkg rbac
falcon add pkg caller
falcon add pkg nanoid
falcon add pkg validate-text
falcon add pkg time
falcon add pkg errors
```

### 3. Backend Specification
Scaffold the feature module using the CLI:
```bash
falcon m:f Copy
```

Implement the following layered architecture in `backend/src/`:
1. **Types (`backend/src/types.mo` & `backend/src/types/CopyTypes.mo`):**
   - `ContentTemplate`: `#blogIntro; #productDescription; #tweetThread; #adCopy; #emailSubject`
   - `GenerationRequest`: `{ template : ContentTemplate; topic : Text; tone : Text; keywords : [Text]; maxTokens : Nat }`
   - `CopyRecord`: `{ id : Text; owner : Principal; template : ContentTemplate; prompt : Text; output : Text; tokensUsed : Nat; createdAt : Int }`
   - `UserCredits`: `{ owner : Principal; remainingCredits : Nat; plan : Text; updatedAt : Int }`

2. **Storage (`backend/src/storage/CopyStorage.mo`):**
   - Persistent `Map.Map<Text, CopyRecord>` keyed by ID.
   - Persistent `Map.Map<Principal, UserCredits>` for token quotas.

3. **Validators (`backend/src/validators/CopyValidator.mo`):**
   - Use `mo:pkg/validate/text` to check non-empty topic (3 to 300 chars) and tone.
   - Enforce positive `maxTokens <= 2048`.

4. **Service (`backend/src/services/CopyService.mo`):**
   - Enforce caller authentication via `mo:pkg/principal/caller`.
   - Apply per-principal rate limiting using `mo:pkg/rate-limit/rate-limit`.
   - Verify user has sufficient credits; deduct tokens upon successful completion.
   - Compose OpenAI API payload using `mo:pkg/openai/openai` and trigger an HTTP outcall.
   - Save record into `CopyRepository` and return `ApiResult<CopyRecord>`.

5. **API Endpoint (`backend/src/api/v1/Copy.mo`):**
   - `generateCopy(req : GenerationRequest) : async ApiResult<CopyRecord>`
   - `getHistory(limit : Nat) : async ApiResult<[CopyRecord]>`
   - `getCredits() : async ApiResult<UserCredits>`
   - Thin mixin delegating directly to `CopyService`. Wire into `backend/src/main.mo`.

### 4. Frontend Specification (`frontend/app/`)
Build a sleek dark-themed dashboard using shadcn/ui components (`Card`, `Button`, `Input`, `Textarea`, `Select`, `Badge`, `Skeleton`):
1. **Header / Auth Bar:** Shows user's Internet Identity Principal, remaining credits badge, and disconnect button.
2. **Generator View (`/dashboard/copy`):**
   - Select content type (Blog Intro, Ad Headline, Tweet Thread).
   - Input fields for Topic, Keywords, Tone (Professional, Casual, Punchy, Urgency).
   - "Generate Copy" button with loading spinner and disabled state when credits are 0.
3. **Output Card:**
   - Markdown rendered text display with a 1-click "Copy to Clipboard" button with checkmark micro-animation.
   - Token count badge.
4. **History Drawer / Table:** Shows past generation items with timestamp, template type, and preview snippet.

### 5. Verification & Audit
Run the verification pipeline to ensure 100% compliance:
```bash
falcon audit code:motoko --fix
falcon b:test --local
falcon b:deploy --local
falcon f:dev
```
```
