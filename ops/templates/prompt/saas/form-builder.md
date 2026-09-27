# SaaS Prompt Template: Interactive Form & Survey Builder

Copy and paste this prompt directly into your AI coding assistant to build an interactive form and survey builder SaaS on the Internet Computer with IcFalcon.

---

```markdown
You are an expert full-stack Internet Computer engineer building "FalconForm" — a dynamic form builder and response collection SaaS built on IcFalcon.

### 1. Mandatory Skills to Read First
1. `.agents/skills/integrationStandard/SKILL.md` (Feature integration flow)
2. `.agents/skills/layeringStandard/SKILL.md` (4-tier architecture)
3. `.agents/skills/packageStandard/SKILL.md` (icp-hub package catalog)
4. `.agents/skills/codingStandard/SKILL.md` (Motoko conventions)
5. `.agents/skills/frontendStandard/SKILL.md` (Next.js with shadcn/ui)

### 2. Install Required icp-hub Packages
Run the following package install commands:
```bash
falcon add pkg nanoid
falcon add pkg validate-json
falcon add pkg webhook
falcon add pkg validate-text
falcon add pkg csv
falcon add pkg crud
falcon add pkg time
falcon add pkg errors
```

### 3. Backend Specification
Scaffold the feature module using the CLI:
```bash
falcon m:f Form
```

Implement the following layered architecture in `backend/src/`:
1. **Types (`backend/src/types.mo`):**
   - `FieldType`: `#shortText; #longText; #singleChoice; #multipleChoice; #rating; #email`
   - `FormField`: `{ id : Text; label : Text; fieldType : FieldType; placeholder : Text; isRequired : Bool; options : [Text] }`
   - `FormSchema`: `{ id : Text; owner : Principal; title : Text; description : Text; fields : [FormField]; webhookUrl : ?Text; isPublished : Bool; createdAt : Int }`
   - `FormSubmission`: `{ id : Text; formId : Text; respondent : ?Principal; answersJson : Text; submittedAt : Int }`

2. **Storage (`backend/src/storage/FormStorage.mo`):**
   - Persistent `Map.Map<Text, FormSchema>` keyed by form ID.
   - Persistent `Map.Map<Text, FormSubmission>` keyed by submission ID.
   - Secondary index mapping `formId -> [submissionId]`.

3. **Validators (`backend/src/validators/FormValidator.mo`):**
   - Title must be between 3 and 100 characters.
   - At least 1 field must be provided in the form schema.
   - Validate answers JSON format using `mo:pkg/validate/json`.

4. **Service (`backend/src/services/FormService.mo`):**
   - `createForm(title : Text, desc : Text, fields : [FormField], webhookUrl : ?Text)`: Generates form ID with `mo:pkg/nanoid/nanoid`, saves schema.
   - `submitResponse(formId : Text, answersJson : Text)`: Saves submission; if `webhookUrl` is configured, dispatches an asynchronous IC HTTP outcall notification using `mo:pkg/webhook/webhook`.
   - `exportResponsesCsv(formId : Text)`: Uses `mo:pkg/csv/csv` to compile submission rows into a formatted CSV string.

5. **API Endpoint (`backend/src/api/v1/Form.mo`):**
   - `getForm(formId : Text) : async ApiResult<FormSchema>` (public query for respondents)
   - `saveForm(schema : FormSchema) : async ApiResult<Text>`
   - `submit(formId : Text, answersJson : Text) : async ApiResult<Text>`
   - `getSubmissions(formId : Text) : async ApiResult<[FormSubmission]>`
   - `downloadCsv(formId : Text) : async ApiResult<Text>`

### 4. Frontend Specification (`frontend/app/`)
Build a drag-and-drop or click-to-add form builder and public responder UI:
1. **Form Builder (`/dashboard/forms/[id]/edit`):**
   - Left sidebar with draggable field types (Text, Multi-choice, Star Rating, Email).
   - Canvas area showing interactive form preview with real-time field editing.
   - Webhook integration settings sheet to enter external endpoints (Zapier, Slack, n8n).
2. **Public Respondent View (`/f/[id]`):**
   - Distraction-free, responsive one-question-at-a-time or single-page survey form.
   - Smooth step transitions and success confirmation screen.
3. **Submissions Analytics View (`/dashboard/forms/[id]/responses`):**
   - Summary statistics card (Total Responses, Completion Rate).
   - Data table of responses with sorting and pagination.
   - 1-click "Export to CSV" button triggering direct browser file download.

### 5. Verification & Audit
```bash
falcon audit code:motoko --fix
falcon b:test --local
falcon b:deploy --local
falcon f:dev
```
```
