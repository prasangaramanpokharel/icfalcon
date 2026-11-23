# SaaS Prompt Template: Uptime & Incident Status Page

Copy and paste this prompt directly into your AI coding assistant to build an automated uptime monitoring and incident communication SaaS on the Internet Computer with IcFalcon.

---

```markdown
You are an expert full-stack Internet Computer engineer building "FalconStatus" — an uptime monitoring and public status page SaaS built on IcFalcon.

### 1. Mandatory Skills to Read First
1. `.agent/skills/integrationStandard/SKILL.md` (Feature integration flow)
2. `.agent/skills/layeringStandard/SKILL.md` (4-tier architecture)
3. `.agent/skills/packageStandard/SKILL.md` (icp-hub package catalog)
4. `.agent/skills/motokoStandard/httpOutcallsStandard/SKILL.md` (IC HTTP outcalls & consensus transforms)
5. `.agent/skills/frontendStandard/SKILL.md` (Next.js with shadcn/ui)

### 2. Install Required icp-hub Packages
Run the following package install commands:
```bash
falcon add pkg http
falcon add pkg cron
falcon add pkg ring-buffer
falcon add pkg validate-url
falcon add pkg validate-text
falcon add pkg time
falcon add pkg errors
```

### 3. Backend Specification
Scaffold the feature module using the CLI:
```bash
falcon m:f Monitor
```

Implement the following layered architecture in `backend/src/`:
1. **Types (`backend/src/types.mo`):**
   - `MonitorStatus`: `#operational; #degraded; #down; #maintenance`
   - `CheckResult`: `{ timestamp : Int; statusCode : Nat; responseTimeMs : Nat; isUp : Bool }`
   - `ServiceMonitor`: `{ id : Text; name : Text; url : Text; checkIntervalSec : Nat; status : MonitorStatus; currentUptimePercent : Nat; lastCheck : ?CheckResult }`
   - `IncidentSeverity`: `#minor; #major; #critical`
   - `Incident`: `{ id : Text; title : Text; status : MonitorStatus; severity : IncidentSeverity; message : Text; affectedServices : [Text]; createdAt : Int; resolvedAt : ?Int }`

2. **Storage (`backend/src/storage/MonitorStorage.mo`):**
   - Persistent `Map.Map<Text, ServiceMonitor>` keyed by monitor ID.
   - Persistent `Map.Map<Text, Incident>` keyed by incident ID.
   - In-memory `ring-buffer` storing the last 90 health check records per monitor for uptime sparkline graphs.

3. **Validators (`backend/src/validators/MonitorValidator.mo`):**
   - URL validation using `mo:pkg/validate/url`.
   - Monitor name (3-50 chars).

4. **Service (`backend/src/services/MonitorService.mo`):**
   - Canister heartbeat / timer integration using `mo:pkg/cron/cron` executing checks every 60 seconds.
   - For each active monitor, executes an IC HTTP GET outcall using `mo:pkg/http/client` with consensus response transform.
   - Measures response latency; pushes result to the monitor's `ring-buffer`.
   - If consecutive failures occur, updates monitor status to `#down` and creates an automatic incident.

5. **API Endpoint (`backend/src/api/v1/Monitor.mo`):**
   - `getPublicStatus() : async ApiResult<PublicStatusResponse>` (all services, current system status badge, active incidents)
   - `getMonitorHistory(monitorId : Text) : async ApiResult<[CheckResult]>`
   - `addMonitor(name : Text, url : Text) : async ApiResult<Text>`
   - `createIncident(title : Text, message : Text, severity : IncidentSeverity) : async ApiResult<Text>`
   - `resolveIncident(incidentId : Text) : async ApiResult<Bool>`

### 4. Frontend Specification (`frontend/app/`)
Build a high-trust public status page and admin control dashboard:
1. **Public Status Page (`/status`):**
   - Giant system health banner: "All Systems Operational" (emerald green) or "Active Incident Detected" (amber/rose).
   - Component list with 90-day uptime bars (interactive hover showing date and response time).
   - Real-time overall uptime percentage metric (e.g., `99.98%`).
   - Incident timeline section with timestamped status updates (Investigating, Identified, Monitoring, Resolved).
2. **Admin Management Dashboard (`/dashboard/monitors`):**
   - Add new monitor dialog with URL format validation.
   - Manual "Check Now" trigger button with live latency indicator.
   - Incident composer dialog with affected services multi-select.

### 5. Verification & Audit
```bash
falcon audit code:motoko --fix
falcon b:test --local
falcon b:deploy --local
falcon f:dev
```
```
