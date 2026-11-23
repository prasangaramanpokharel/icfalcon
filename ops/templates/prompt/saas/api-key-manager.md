# SaaS Prompt Template: Developer API Key Gateway & Quota Manager

Copy and paste this prompt directly into your AI coding assistant to build an API key provisioning, rate-limiting, and usage analytics SaaS on the Internet Computer with IcFalcon.

---

```markdown
You are an expert full-stack Internet Computer engineer building "FalconKey" — a developer API gateway, secret key manager, and quota control SaaS on IcFalcon.

### 1. Mandatory Skills to Read First
1. `.agent/skills/integrationStandard/SKILL.md` (Feature integration flow)
2. `.agent/skills/layeringStandard/SKILL.md` (4-tier architecture)
3. `.agent/skills/packageStandard/SKILL.md` (icp-hub package catalog)
4. `.agent/skills/codingStandard/SKILL.md` (Motoko conventions)
5. `.agent/skills/frontendStandard/SKILL.md` (Next.js with shadcn/ui)

### 2. Install Required icp-hub Packages
Run the following package install commands:
```bash
falcon add pkg api-key
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
falcon m:f ApiKey
```

Implement the following layered architecture in `backend/src/`:
1. **Types (`backend/src/types.mo`):**
   - `KeyScope`: `#readOnly; #readWrite; #admin`
   - `ApiKeyRecord`: `{ id : Text; keyPrefix : Text; hashedSecret : Text; name : Text; owner : Principal; scope : KeyScope; requestsThisMonth : Nat; monthlyLimit : Nat; isActive : Bool; createdAt : Int; lastUsedAt : ?Int }`
   - `KeyGenerationResult`: `{ record : ApiKeyRecord; rawSecret : Text }` (raw secret only returned once at creation!)

2. **Storage (`backend/src/storage/ApiKeyStorage.mo`):**
   - Persistent `Map.Map<Text, ApiKeyRecord>` keyed by key ID.
   - Persistent `Map.Map<Text, Text>` indexing `hashedSecret -> keyId` for O(1) request authentication.

3. **Validators (`backend/src/validators/ApiKeyValidator.mo`):**
   - Key name must be non-empty (3-40 chars).
   - Valid monthly limit bounds (1,000 to 1,000,000 requests).

4. **Service (`backend/src/services/ApiKeyService.mo`):**
   - `generateKey(name : Text, scope : KeyScope, limit : Nat)`:
     - Generates raw key with prefix (`ak_live_` + random 32-char string via `mo:pkg/nanoid/nanoid`).
     - Computes SHA-256 hash of the secret using `mo:pkg/api-key/api-key`.
     - Stores only `hashedSecret` in persistence.
     - Returns `rawSecret` once to the user.
   - `authenticateKey(rawSecret : Text)`: Hashes input, performs lookup, verifies `isActive`, increments request counter, checks against monthly quota, and applies sliding-window rate limiting via `mo:pkg/rate-limit/rate-limit`.
   - `revokeKey(keyId : Text)`: Immediately marks key inactive.

5. **API Endpoint (`backend/src/api/v1/ApiKey.mo`):**
   - `createKey(name : Text, scope : KeyScope, limit : Nat) : async ApiResult<KeyGenerationResult>`
   - `listKeys() : async ApiResult<[ApiKeyRecord]>`
   - `revoke(keyId : Text) : async ApiResult<Bool>`
   - `getUsageStats() : async ApiResult<UsageOverview>`

### 4. Frontend Specification (`frontend/app/`)
Build a Stripe-style developer API keys dashboard:
1. **API Keys Management View (`/dashboard/keys`):**
   - Table of active keys showing Name, Key Prefix (e.g. `ak_live_a1b2...`), Scope Badge, Created Date, Last Used timestamp.
   - Monthly Quota progress bar (e.g. `24,500 / 100,000 requests used (24.5%)`).
   - "Revoke" button with destructive confirmation alert dialog.
2. **"Create New API Key" Dialog:**
   - Input for Key Name and Scope radio group (Read-Only, Read-Write, Full Access).
   - Monthly quota tier selector.
3. **One-Time Secret Reveal Modal:**
   - Prominent alert: "Save this key now. You won't be able to see it again!"
   - Blurred/revealed secret key with 1-click "Copy to Clipboard" button.
4. **Developer Quickstart Guide:**
   - Code snippet tabs (cURL, JavaScript, Python) showing how to pass the `Authorization: Bearer ak_live_...` header.

### 5. Verification & Audit
```bash
falcon audit code:motoko --fix
falcon b:test --local
falcon b:deploy --local
falcon f:dev
```
```
