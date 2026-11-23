# SaaS Prompt Template: Customer Feedback & Roadmap Voting Board

Copy and paste this prompt directly into your AI coding assistant to build an interactive customer feedback and roadmap voting SaaS on the Internet Computer with IcFalcon.

---

```markdown
You are an expert full-stack Internet Computer engineer building "FalconBoard" — a customer feedback, feature request, and public roadmap SaaS built on IcFalcon.

### 1. Mandatory Skills to Read First
1. `.agent/skills/integrationStandard/SKILL.md` (Feature integration flow)
2. `.agent/skills/layeringStandard/SKILL.md` (4-tier architecture: api → services → repositories → storage)
3. `.agent/skills/packageStandard/SKILL.md` (icp-hub package catalog)
4. `.agent/skills/codingStandard/SKILL.md` (Motoko conventions, mo:core imports)
5. `.agent/skills/frontendStandard/SKILL.md` (Next.js with shadcn/ui, dark mode, responsive layout)

### 2. Install Required icp-hub Packages
Run the following package install commands:
```bash
falcon add pkg rbac
falcon add pkg caller
falcon add pkg slug
falcon add pkg pagination
falcon add pkg validate-text
falcon add pkg crud
falcon add pkg time
falcon add pkg errors
```

### 3. Backend Specification
Scaffold the feature module using the CLI:
```bash
falcon m:f Feedback
```

Implement the following layered architecture in `backend/src/`:
1. **Types (`backend/src/types.mo`):**
   - `PostStatus`: `#underReview; #planned; #inProgress; #completed; #closed`
   - `PostCategory`: `#feature; #bug; #integration; #ux`
   - `FeedbackPost`: `{ id : Text; slug : Text; title : Text; description : Text; author : Principal; status : PostStatus; category : PostCategory; upvotes : Nat; commentCount : Nat; createdAt : Int }`
   - `Comment`: `{ id : Text; postId : Text; author : Principal; content : Text; isAdminReply : Bool; createdAt : Int }`
   - `VoteRecord`: `{ postId : Text; voter : Principal; votedAt : Int }`

2. **Storage (`backend/src/storage/FeedbackStorage.mo`):**
   - Persistent `Map.Map<Text, FeedbackPost>` keyed by post ID.
   - Persistent `Map.Map<Text, Comment>` keyed by comment ID.
   - Persistent `Map.Map<Text, VoteRecord>` keyed by `postId # ":" # Principal.toText(voter)` to prevent double upvoting!

3. **Validators (`backend/src/validators/FeedbackValidator.mo`):**
   - Title must be between 5 and 120 characters (`mo:pkg/validate/text`).
   - Description must be between 10 and 2000 characters.

4. **Service (`backend/src/services/FeedbackService.mo`):**
   - `createPost(title : Text, desc : Text, cat : PostCategory)`: Validates input, generates URL slug via `mo:pkg/slug/slug`, assigns initial status `#underReview`.
   - `toggleUpvote(postId : Text)`: Checks if caller already voted. If voted, decrements upvote count and removes record; if not, increments and saves vote.
   - `updateStatus(postId : Text, newStatus : PostStatus)`: Guarded by `mo:pkg/rbac/rbac` (Admin only).
   - `addComment(postId : Text, content : Text)`: Appends comment and increments `commentCount`.

5. **API Endpoint (`backend/src/api/v1/Feedback.mo`):**
   - `listPosts(status : ?PostStatus, category : ?PostCategory, page : Nat, limit : Nat) : async ApiResult<Page<FeedbackPost>>`
   - `getPostBySlug(slug : Text) : async ApiResult<FeedbackPost>`
   - `submitFeedback(title : Text, desc : Text, cat : PostCategory) : async ApiResult<FeedbackPost>`
   - `votePost(postId : Text) : async ApiResult<Nat>`
   - `listRoadmap() : async ApiResult<RoadmapColumns>`

### 4. Frontend Specification (`frontend/app/`)
Build a high-conversion modern feedback interface using shadcn/ui:
1. **Public Board View (`/board`):**
   - Category filter pills (All, Features, Bugs, Integrations).
   - Sort dropdown (Top Voted, Newest, Most Discussed).
   - Feedback post card: Upvote arrow button with vote counter (active state highlights if caller voted), title, description preview, status tag, author avatar.
2. **Roadmap Kanban View (`/roadmap`):**
   - 3-column Kanban layout: **Planned**, **In Progress**, **Completed**.
   - Draggable or column-sorted cards with status indicators.
3. **Submit Idea Modal:**
   - Dialog with Title input, Category select, and Markdown description editor.
4. **Post Detail Page (`/board/[slug]`):**
   - Full post discussion, upvote button, comment list, and admin response banner with `#admin` badge.

### 5. Verification & Audit
```bash
falcon audit code:motoko --fix
falcon b:test --local
falcon b:deploy --local
falcon f:dev
```
```
