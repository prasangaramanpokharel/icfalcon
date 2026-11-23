# SaaS Prompt Template: Web3 P2P Escrow & Milestone Marketplace

Copy and paste this prompt directly into your AI coding assistant to build a trustless peer-to-peer escrow and milestone payment SaaS on the Internet Computer with IcFalcon.

---

```markdown
You are an expert full-stack Internet Computer engineer building "FalconEscrow" — a trustless P2P escrow, milestone release, and dispute resolution SaaS on IcFalcon.

### 1. Mandatory Skills to Read First
1. `.agent/skills/integrationStandard/SKILL.md` (Feature integration flow)
2. `.agent/skills/layeringStandard/SKILL.md` (4-tier architecture)
3. `.agent/skills/packageStandard/SKILL.md` (icp-hub package catalog)
4. `.agent/skills/financeStandard/walletStandard/SKILL.md` (Custodial subaccounts & deposit addresses)
5. `.agent/skills/financeStandard/transferStandard/SKILL.md` (ICRC transfer patterns & ledger calls)

### 2. Install Required icp-hub Packages
Run the following package install commands:
```bash
falcon add pkg escrow
falcon add pkg wallet
falcon add pkg transfer
falcon add pkg subaccount
falcon add pkg icrc1
falcon add pkg rbac
falcon add pkg nanoid
falcon add pkg time
falcon add pkg errors
```

### 3. Backend Specification
Scaffold the feature module using the CLI:
```bash
falcon m:f Escrow
```

Implement the following layered architecture in `backend/src/`:
1. **Types (`backend/src/types.mo`):**
   - `EscrowStatus`: `#awaitingDeposit; #fundsLocked; #completed; #disputed; #refunded`
   - `EscrowContract`: `{ id : Text; title : Text; buyer : Principal; seller : Principal; arbiter : Principal; amountE8s : Nat; feeE8s : Nat; depositSubaccount : Blob; status : EscrowStatus; terms : Text; createdAt : Int; fundedAt : ?Int; completedAt : ?Int }`
   - `DisputeResolution`: `{ contractId : Text; buyerSplitPercent : Nat; sellerSplitPercent : Nat; resolutionNotes : Text }`

2. **Storage (`backend/src/storage/EscrowStorage.mo`):**
   - Persistent `Map.Map<Text, EscrowContract>` keyed by contract ID.
   - Persistent `Map.Map<Blob, Text>` indexing `subaccount -> contractId`.

3. **Validators (`backend/src/validators/EscrowValidator.mo`):**
   - Buyer, seller, and arbiter must all be distinct Principals.
   - Amount must be greater than minimum threshold (e.g., 100_000 e8s / 0.001 ICP).

4. **Service (`backend/src/services/EscrowService.mo`):**
   - `createContract(seller, arbiter, amount, terms)`: Derives contract's unique 32-byte subaccount using `mo:pkg/subaccount/subaccount`. Initial status: `#awaitingDeposit`.
   - `verifyDeposit(contractId)`: Reads balance on contract subaccount via `mo:pkg/wallet/wallet`. Once `balance >= amountE8s + feeE8s`, locks funds and transitions status to `#fundsLocked`.
   - `releaseFunds(contractId)`: Can be triggered by the Buyer or Arbiter. Transfers `amountE8s` to the Seller and platform fee to the Treasury using `mo:pkg/transfer/transfer`. Status -> `#completed`.
   - `refundBuyer(contractId)`: Triggered by Seller or Arbiter. Returns deposit to Buyer. Status -> `#refunded`.
   - `resolveDispute(resolution)`: Arbiter splits the escrow balance between Buyer and Seller according to percentage agreement.

5. **API Endpoint (`backend/src/api/v1/Escrow.mo`):**
   - `createDeal(seller : Principal, arbiter : Principal, amount : Nat, terms : Text) : async ApiResult<EscrowContract>`
   - `confirmFunding(contractId : Text) : async ApiResult<EscrowStatus>`
   - `release(contractId : Text) : async ApiResult<Bool>`
   - `raiseDispute(contractId : Text, reason : Text) : async ApiResult<Bool>`
   - `getMyContracts() : async ApiResult<[EscrowContract]>`

### 4. Frontend Specification (`frontend/app/`)
Build a high-trust Web3 escrow dashboard:
1. **Contract Overview (`/dashboard/escrow`):**
   - Role filter tabs: As Buyer, As Seller, As Arbiter.
   - Escrow card: Title, Parties with Principal tags, Amount, Status badge (Awaiting Deposit, Funds Locked, Completed).
2. **Contract Detail Room (`/escrow/[id]`):**
   - Interactive progress timeline (Created -> Funded -> Milestone Delivered -> Released).
   - Deposit instructions card with AccountIdentifier, QR code, and "Verify Deposit" button.
   - Contextual action buttons:
     - For Buyer: "Release Funds to Seller" (Green), "Raise Dispute" (Amber).
     - For Seller: "Request Release", "Refund Buyer".
     - For Arbiter: "Resolve Dispute" dialog with slider (0% to 100% split).

### 5. Verification & Audit
```bash
falcon audit code:motoko --fix
falcon b:test --local
falcon b:deploy --local
falcon f:dev
```
```
