# SaaS Prompt Template: B2B Invoicing & Crypto Settlement

Copy and paste this prompt directly into your AI coding assistant to build a multi-currency invoicing and automatic on-chain payment reconciliation SaaS on the Internet Computer with IcFalcon.

---

```markdown
You are an expert full-stack Internet Computer engineer building "FalconInvoice" — an enterprise B2B multi-currency invoicing and automated ICP/ckBTC payment settlement SaaS on IcFalcon.

### 1. Mandatory Skills to Read First
1. `.agent/skills/integrationStandard/SKILL.md` (Feature integration flow)
2. `.agent/skills/layeringStandard/SKILL.md` (4-tier architecture)
3. `.agent/skills/packageStandard/SKILL.md` (icp-hub package catalog)
4. `.agent/skills/financeStandard/walletStandard/SKILL.md` (Custodial subaccounts & deposit addresses)
5. `.agent/skills/financeStandard/transferStandard/SKILL.md` (ICRC transfer patterns & ledger calls)

### 2. Install Required icp-hub Packages
Run the following package install commands:
```bash
falcon add pkg invoice
falcon add pkg wallet
falcon add pkg transfer
falcon add pkg subaccount
falcon add pkg icrc1
falcon add pkg nanoid
falcon add pkg validate-text
falcon add pkg time
falcon add pkg errors
```

### 3. Backend Specification
Scaffold the feature module using the CLI:
```bash
falcon m:f Billing
```

Implement the following layered architecture in `backend/src/`:
1. **Types (`backend/src/types.mo`):**
   - `InvoiceStatus`: `#draft; #pending; #paid; #overdue; #cancelled`
   - `InvoiceItem`: `{ description : Text; quantity : Nat; unitPriceE8s : Nat; totalE8s : Nat }`
   - `Invoice`: `{ id : Text; invoiceNumber : Text; issuer : Principal; clientName : Text; clientEmail : Text; items : [InvoiceItem]; subtotalE8s : Nat; taxE8s : Nat; totalE8s : Nat; currency : Text; depositSubaccount : Blob; status : InvoiceStatus; dueDate : Int; createdAt : Int; paidAt : ?Int }`
   - `Client`: `{ id : Text; name : Text; email : Text; company : Text; address : Text }`

2. **Storage (`backend/src/storage/BillingStorage.mo`):**
   - Persistent `Map.Map<Text, Invoice>` keyed by invoice ID.
   - Persistent `Map.Map<Blob, Text>` indexing `subaccount -> invoiceId` for instant payment lookup.
   - Persistent `Map.Map<Text, Client>` keyed by client ID.

3. **Validators (`backend/src/validators/BillingValidator.mo`):**
   - Enforce at least one line item with positive quantity and price.
   - Client email format validation.
   - Valid future due date.

4. **Service (`backend/src/services/BillingService.mo`):**
   - `createInvoice(req)`: Derives a unique deterministic 32-byte deposit subaccount for the invoice using `mo:pkg/subaccount/subaccount` based on invoice ID.
   - `checkInvoicePayment(invoiceId : Text)`: Queries the ledger canister (e.g. ICP or ckBTC ICRC-1) balance on the invoice's unique subaccount using `mo:pkg/wallet/wallet`. If `balance >= invoice.totalE8s`, marks the invoice `#paid`, records payment timestamp, and archives transaction.
   - `cancelInvoice(invoiceId : Text)`: Marks invoice cancelled if still unpaid.

5. **API Endpoint (`backend/src/api/v1/Billing.mo`):**
   - `createInvoice(req : CreateInvoiceReq) : async ApiResult<Invoice>`
   - `getInvoice(id : Text) : async ApiResult<Invoice>`
   - `getPublicInvoice(id : Text) : async ApiResult<PublicInvoiceView>`
   - `verifyPayment(id : Text) : async ApiResult<InvoiceStatus>`
   - `listInvoices(status : ?InvoiceStatus) : async ApiResult<[Invoice]>`

### 4. Frontend Specification (`frontend/app/`)
Build a professional enterprise billing dashboard and public payment portal:
1. **Invoice Builder (`/dashboard/invoices/new`):**
   - Client picker / inline client creator.
   - Dynamic line items table with "Add Item", subtotal, tax calculation, and currency selector (ICP / ckBTC / USD equivalent).
   - "Issue Invoice" button generating shareable public payment link.
2. **Public Payment Page (`/pay/[id]`):**
   - Clean printable invoice summary layout with issuer and client details.
   - Payment card displaying deposit AccountIdentifier and QR code for ICRC transfer.
   - Live "Check Payment" polling button with success confetti animation upon detection.
3. **Invoices Table (`/dashboard/invoices`):**
   - Filter by status (Paid, Pending, Overdue).
   - Revenue summary cards (Total Invoiced, Outstanding, Collected This Month).

### 5. Verification & Audit
```bash
falcon audit code:motoko --fix
falcon b:test --local
falcon b:deploy --local
falcon f:dev
```
```
