---
name: icpayDomainStandard
description: >-
  Custom domain management on the Internet Computer (DNS configuration, IC Boundary Node REST API,
  ACME SSL certificates, and Internet Identity alternative origins). Read when adding, verifying,
  or troubleshooting custom domains for ICPay.
---

# ICPay Custom Domain & Origin Management

This skill documents how custom domains (such as `icpay.app` and `icpay.cloud`) are configured, secured with automated TLS/SSL certificates, and integrated with Internet Identity on the Internet Computer.

---

## Purpose

Provide a unified standard and runbook for registering, certifying, and managing apex domains and subdomains on the Internet Computer boundary nodes while guaranteeing 100% derivation origin parity for Internet Identity authentication.

---

## When to use

- Adding a new custom domain or subdomain to ICPay
- Configuring DNS records (TXT, CNAME, A) for IC boundary nodes
- Requesting automated ACME TLS/SSL certificate issuance via the Boundary Node REST API
- Adding domains to Internet Identity `.well-known/ii-alternative-origins`
- Troubleshooting domain resolution, SSL errors, or principal mismatch bugs

---

## 1. Non-Negotiable Invariant: Derivation Origin & Parity

> [!CAUTION]
> **Never change `NEXT_PUBLIC_DERIVATION_ORIGIN`.**
> It is permanently pinned to `https://63dke-waaaa-aaaan-q6mvq-cai.icp0.io`. Changing this value invalidates all existing users' identity principals and locks their funds permanently.

### Origin Parity Rule
Internet Identity derives unique principals based on origin. To allow users to log in through custom domains (e.g. `icpay.app`, `icpay.cloud`) and access the exact same wallet principal and funds:

1. Every custom domain must be registered in `frontend/public/.well-known/ii-alternative-origins`.
2. The exact same domains must be added to the `ALTERNATIVE_ORIGINS` array in `frontend/services/icp.ts`.
3. **Parity is 100% mandatory**: If an origin exists in one file but not the other, authentication silently diverges.

---

## 2. Currently Registered Domains

| Domain / Origin | Infrastructure Type | Target / Resolution | Status |
|---|---|---|---|
| `https://63dke-waaaa-aaaan-q6mvq-cai.icp0.io` | Canonical On-Chain Canister | Canister `63dke-waaaa-aaaan-q6mvq-cai` | Active (Derivation Origin) |
| `https://icpay.app` | Production Custom Domain | Vercel Edge (`76.76.21.21`) | Active |
| `https://www.icpay.app` | Production Custom Subdomain | Vercel (`cname.vercel-dns.com`) | Active |
| `https://icpay.cloud` | Direct On-Chain Custom Domain | IC Boundary Node (`208.115.197.139`) | Active & Registered |
| `https://www.icpay.cloud` | Direct On-Chain Custom Subdomain | IC Boundary Node (`icpay.cloud.icp1.io`) | Active & Registered |
| `https://63dke-waaaa-aaaan-q6mvq-cai.raw.icp0.io` | Raw Uncertified Gateway | Canister `63dke-waaaa-aaaan-q6mvq-cai` | Active (Alternative Origin) |
| `https://ic-pay.vercel.app` | Staging Preview | Vercel Staging | Active |

---

## 3. Step-by-Step Domain Registration Runbook

Follow these steps whenever adding a new custom domain to ICPay:

### Step 1: Update Codebase Files

1. Add the new domain to `frontend/public/.well-known/ii-alternative-origins`:
   ```json
   {
     "alternativeOrigins": [
       "https://ic-pay.vercel.app",
       "https://icpay.app",
       "https://www.icpay.app",
       "https://icpay.cloud",
       "https://www.icpay.cloud",
       "https://newdomain.com",
       "https://www.newdomain.com"
     ]
   }
   ```

2. Add the same domain to `frontend/services/icp.ts`:
   ```typescript
   const ALTERNATIVE_ORIGINS = [
     "https://ic-pay.vercel.app",
     "https://icpay.app",
     "https://www.icpay.app",
     "https://icpay.cloud",
     "https://www.icpay.cloud",
     "https://newdomain.com",
     "https://www.newdomain.com",
   ]
   ```

3. Add the domain to `frontend/public/.well-known/ic-domains`:
   ```text
   icpay.cloud
   www.icpay.cloud
   newdomain.com
   www.newdomain.com
   ```

---

### Step 2: Deploy to Mainnet Asset Canister First

> [!IMPORTANT]
> The canister must be deployed **before** registering the domain. Internet Identity and the IC boundary node make live HTTP requests to `https://63dke-waaaa-aaaan-q6mvq-cai.icp0.io/.well-known/` to verify ownership and authorization.

```bash
npm run ci frontend:deploy
```

Verify that the files are serving on mainnet:
```bash
curl -s "https://63dke-waaaa-aaaan-q6mvq-cai.icp0.io/.well-known/ii-alternative-origins"
curl -s "https://63dke-waaaa-aaaan-q6mvq-cai.icp0.io/.well-known/ic-domains"
```

---

### Step 3: Configure DNS Records at Domain Registrar

In your DNS provider (Hostinger, Cloudflare, Namecheap, etc.), add the required records:

| Record Type | Name / Host | Target / Value | Purpose |
|---|---|---|---|
| **TXT** | `_canister-id` | `63dke-waaaa-aaaan-q6mvq-cai` | Canister identification |
| **CNAME** | `_acme-challenge` | `_acme-challenge.<domain>.icp2.io` | Automated ACME TLS/SSL certificate issuance |
| **A** *(Apex `@`)* | `@` | `208.115.197.139` *(or `154.45.251.219`)* | Direct boundary node routing |
| **CNAME** *(Subdomain `www`)* | `www` | `<domain>.icp1.io` | Subdomain gateway routing |

*Note for Cloudflare: Proxy status must be set to "DNS only" (gray cloud) during certificate issuance.*

---

### Step 4: Validate Configuration with Boundary Node API

Check if the IC gateway recognizes your DNS and canister files:

```bash
curl -sL "https://icp.net/custom-domains/v1/<domain>/validate"
```

*Expected output:*
```json
{
  "status": "success",
  "message": "Domain is eligible for registration: DNS records are valid and canister ownership is verified",
  "data": {
    "domain": "<domain>",
    "canister_id": "63dke-waaaa-aaaan-q6mvq-cai",
    "validation_status": "valid"
  }
}
```

---

### Step 5: Submit Domain Registration Request

Send the registration order to initiate TLS certificate provisioning:

```bash
curl -sL -X POST "https://icp.net/custom-domains/v1/<domain>"
```

*Expected output:*
```json
{
  "status": "success",
  "message": "Domain registration request accepted and may take a few minutes to process",
  "data": {
    "domain": "<domain>",
    "canister_id": "63dke-waaaa-aaaan-q6mvq-cai"
  }
}
```

---

### Step 6: Monitor Registration Status

Poll the status until `registration_status` transitions to `registered`:

```bash
curl -sL "https://icp.net/custom-domains/v1/<domain>"
```

*Expected output:*
```json
{
  "status": "success",
  "message": "Registration status of the domain",
  "data": {
    "domain": "<domain>",
    "canister_id": "63dke-waaaa-aaaan-q6mvq-cai",
    "registration_status": "registered"
  }
}
```

---

## 4. Diagnostic & Troubleshooting Cheatsheet

### Verify DNS Records Directly
```bash
# 1. Check canister ID TXT record
dig +short TXT _canister-id.<domain>

# 2. Check ACME challenge CNAME
dig +short CNAME _acme-challenge.<domain>

# 3. Check Apex A record resolution on Google DNS
dig +short A <domain> @8.8.8.8

# 4. Check Subdomain CNAME resolution
dig +short CNAME www.<domain>
```

### Test Boundary Node Response
Test whether the boundary node serves your on-chain canister with proper IC certification headers:
```bash
curl -sI -k https://208.115.197.139 -H "Host: <domain>"
```
*Expected HTTP response: `HTTP/2 200` with `x-ic-canister-id: 63dke-waaaa-aaaan-q6mvq-cai`.*

### Verify Alternative Origins File
```bash
curl -s "https://63dke-waaaa-aaaan-q6mvq-cai.icp0.io/.well-known/ii-alternative-origins" | jq
```

### Remove / Deregister a Custom Domain
If a domain needs to be decoupled or reassigned:
```bash
curl -sL -X DELETE "https://icp.net/custom-domains/v1/<domain>"
```

---

## Related

| Skill | Path |
|---|---|
| ICPay Controllers | [`skills/icpayControllerStandard/SKILL.md`](../icpayControllerStandard/SKILL.md) |
| Internet Identity Auth | [`skills/motokoStandard/internetIdentityAuthStandard/SKILL.md`](../motokoStandard/internetIdentityAuthStandard/SKILL.md) |
| Production Deploy | [`skills/guideStandard/productionDeployStandard/SKILL.md`](../guideStandard/productionDeployStandard/SKILL.md) |
