# SaaS Prompt Template: Web3 Event Tickets & Gate Pass Access

Copy and paste this prompt directly into your AI coding assistant to build an event ticketing, gate access verification, and NFT pass SaaS on the Internet Computer with IcFalcon.

---

```markdown
You are an expert full-stack Internet Computer engineer building "FalconPass" — an on-chain event ticketing, QR code gate verification, and attendee management SaaS on IcFalcon.

### 1. Mandatory Skills to Read First
1. `.agent/skills/integrationStandard/SKILL.md` (Feature integration flow)
2. `.agent/skills/layeringStandard/SKILL.md` (4-tier architecture)
3. `.agent/skills/packageStandard/SKILL.md` (icp-hub package catalog)
4. `.agent/skills/codingStandard/SKILL.md` (Motoko conventions)
5. `.agent/skills/frontendStandard/SKILL.md` (Next.js with shadcn/ui)

### 2. Install Required icp-hub Packages
Run the following package install commands:
```bash
falcon add pkg nanoid
falcon add pkg wallet
falcon add pkg transfer
falcon add pkg icrc1
falcon add pkg lock
falcon add pkg validate-text
falcon add pkg time
falcon add pkg errors
```

### 3. Backend Specification
Scaffold the feature module using the CLI:
```bash
falcon m:f Tickets
```

Implement the following layered architecture in `backend/src/`:
1. **Types (`backend/src/types.mo`):**
   - `TicketTier`: `{ name : Text; priceE8s : Nat; totalCapacity : Nat; soldCount : Nat }`
   - `Event`: `{ id : Text; organizer : Principal; title : Text; description : Text; venue : Text; eventTime : Int; tiers : [TicketTier]; isActive : Bool; createdAt : Int }`
   - `TicketStatus`: `#valid; #checkedIn; #cancelled`
   - `TicketPass`: `{ id : Text; eventId : Text; owner : Principal; tierName : Text; pricePaidE8s : Nat; qrCodePayload : Text; status : TicketStatus; purchasedAt : Int; checkedInAt : ?Int }`

2. **Storage (`backend/src/storage/TicketsStorage.mo`):**
   - Persistent `Map.Map<Text, Event>` keyed by event ID.
   - Persistent `Map.Map<Text, TicketPass>` keyed by ticket ID.
   - Secondary index `eventId -> [ticketId]`.

3. **Validators (`backend/src/validators/TicketsValidator.mo`):**
   - Event title (3-100 chars), valid future event time.
   - Positive ticket capacity and valid tier prices.

4. **Service (`backend/src/services/TicketsService.mo`):**
   - `buyTicket(eventId : Text, tierName : Text)`:
     - Uses `mo:pkg/lock/lock` to guard against ticket overselling race conditions across async payment calls!
     - Verifies tier has remaining capacity (`soldCount < totalCapacity`).
     - Executes ICRC-1 token payment transfer from user to event organizer using `mo:pkg/transfer/transfer`.
     - Generates unique secure ticket pass ID and verification payload using `mo:pkg/nanoid/nanoid`.
     - Increments `soldCount` and releases the lock.
   - `verifyGatePass(ticketId : Text)`:
     - Restricted to Event Organizer or authorized Staff principals.
     - Checks ticket status: if `#valid`, updates to `#checkedIn`, records `checkedInAt = Time.now()`, and returns success.
     - If already `#checkedIn`, rejects with `"Ticket already used at <time>"`.

5. **API Endpoint (`backend/src/api/v1/Tickets.mo`):**
   - `createEvent(req : CreateEventReq) : async ApiResult<Event>`
   - `listEvents() : async ApiResult<[Event]>`
   - `purchaseTicket(eventId : Text, tierName : Text) : async ApiResult<TicketPass>`
   - `getMyTickets() : async ApiResult<[TicketPass]>`
   - `checkInAttendee(ticketId : Text) : async ApiResult<CheckInResult>`

### 4. Frontend Specification (`frontend/app/`)
Build an event showcase and ticket wallet interface:
1. **Public Event Discovery (`/events`):**
   - Featured event hero banner with date countdown.
   - Event cards displaying Venue, Date, Starting Price, and Available Spots badge.
2. **Event Detail & Ticket Purchase (`/events/[id]`):**
   - Event description, venue map preview, and organizer details.
   - Ticket Tier selection cards (General Admission, VIP, Backstage) showing remaining availability bars.
   - 1-click "Purchase Ticket" button integrating Internet Identity and ICRC balance.
3. **Attendee Ticket Wallet (`/dashboard/tickets`):**
   - Digital event pass card styled like an airline boarding pass.
   - Prominent high-contrast QR code for entrance scanning.
   - "Checked In" watermark banner once scanned.
4. **Staff Gate Scanner View (`/scanner`):**
   - Mobile-optimized camera QR scanner or manual ticket ID entry input.
   - Instant visual feedback: Large Green Checkmark ("Welcome!") or Red X ("Already Used").

### 5. Verification & Audit
```bash
falcon audit code:motoko --fix
falcon b:test --local
falcon b:deploy --local
falcon f:dev
```
```
