---
name: domainStandard
description: >-
  Custom domain management on the Internet Computer (DNS configuration, IC Boundary Node REST API,
  ACME SSL certificates, and Internet Identity alternative origins). Read when adding, verifying,
  or troubleshooting custom domains for any IcFalcon application.
---

# IcFalcon Custom Domain & Origin Management

This skill documents how to configure custom domains (apex domains and subdomains) for any IcFalcon application on the Internet Computer, secure them with automated boundary-node TLS/SSL certificates, and maintain persistent user identity across domains via Internet Identity.

---

## Purpose

Provide a framework-wide standard and runbook for registering, certifying, and managing apex domains and subdomains on IC boundary nodes while guaranteeing 100% derivation origin parity for Internet Identity authentication.

---

## When to use

- Connecting a custom domain or subdomain (e.g. `myapp.com`, `app.myapp.com`) to an IcFalcon canister
- Configuring DNS records (TXT, CNAME, A) for IC boundary nodes
- Requesting automated ACME TLS/SSL certificates via the Boundary Node REST API
- Adding custom domains to Internet Identity `.well-known/ii-alternative-origins`
- Troubleshooting domain resolution, SSL issuance, or principal mismatch across domains

---

## 1. Non-Negotiable Invariant: Derivation Origin & Parity

> [!CAUTION]
> **Never change your production `NEXT_PUBLIC_DERIVATION_ORIGIN`.**
> When your app is deployed, this value should be pinned to your canonical on-chain canister URL (e.g. `https://<canister-id>.icp0.io`). Changing this value after users have signed up will invalidate all existing user principals and permanently lock their data or custodial balances.

### Why Derivation Origin Matters
By default, Internet Identity derives a **different Principal ID** for every distinct domain a user visits. To ensure a user logging in via `https://myapp.com`, `https://www.myapp.com`, or `https://<canister-id>.icp0.io` receives the **exact same Principal and wallet funds**, you must configure a single shared Derivation Origin.

### The Origin Parity Rule
To allow users to log in through your custom domains:

1. Every custom domain must be registered in your frontend's `frontend/public/.well-known/ii-alternative-origins`:
   ```json
   {
     "alternativeOrigins": [
       "https://myapp.com",
       "https://www.myapp.com"
     ]
   }
   ```
2. The exact same domains must be added to your client auth configuration (e.g. `ALTERNATIVE_ORIGINS` in your frontend auth service):
   ```typescript
   export const ALTERNATIVE_ORIGINS = [
     "https://myapp.com",
     "https://www.myapp.com",
   ]
   ```
3. **Parity is 100% mandatory**: If an origin exists in one file but not the other, Internet Identity authentication will silently fail or derive differing principals.

---

## 2. Step-by-Step Domain Registration Runbook

Follow these steps whenever adding a custom domain to your IcFalcon app:

### Step 1: Update Frontend Well-Known Files

1. Add the domain to `frontend/public/.well-known/ii-alternative-origins` (as shown above).
2. Add the domain to `frontend/public/.well-known/ic-domains`:
   ```text
   myapp.com
   www.myapp.com
   ```

---

### Step 2: Deploy to Mainnet Asset Canister First

> [!IMPORTANT]
> The canister must be deployed **before** registering the domain with the boundary node. The IC boundary node and Internet Identity make live HTTP requests to `https://<canister-id>.icp0.io/.well-known/` to verify ownership and authorization.

```bash
falcon b:deploy           # Deploy your canister to mainnet
```

Verify that the files are serving publicly:
```bash
curl -s "https://<canister-id>.icp0.io/.well-known/ii-alternative-origins"
curl -s "https://<canister-id>.icp0.io/.well-known/ic-domains"
```

---

### Step 3: Configure DNS Records at Domain Registrar

In your DNS provider (Cloudflare, Namecheap, Route53, Hostinger, etc.), add the required records:

| Record Type | Name / Host | Target / Value | Purpose |
|---|---|---|---|
| **TXT** | `_canister-id` | `<your-canister-id>` | Links domain to your canister |
| **CNAME** | `_acme-challenge` | `_acme-challenge.<domain>.icp2.io` | Automated ACME TLS/SSL certificate issuance |
| **A** *(Apex `@`)* | `@` | `208.115.197.139` *(or `154.45.251.219`)* | Direct boundary node routing |
| **CNAME** *(Subdomain)* | `www` (or `<subdomain>`) | `<domain>.icp1.io` | Subdomain gateway routing |

*Note for Cloudflare users: Proxy status must be set to **"DNS only"** (gray cloud) during certificate issuance.*

---

### Step 4: Validate Configuration with Boundary Node API

Check if the IC gateway recognizes your DNS configuration and canister files:

```bash
curl -sL "https://icp.net/custom-domains/v1/<domain>/validate"
```

*Expected response:*
```json
{
  "status": "success",
  "message": "Domain is eligible for registration: DNS records are valid and canister ownership is verified",
  "data": {
    "domain": "<domain>",
    "canister_id": "<your-canister-id>",
    "validation_status": "valid"
  }
}
```

---

### Step 5: Submit Domain Registration Request

Send the registration request to initiate automated TLS certificate provisioning:

```bash
curl -sL -X POST "https://icp.net/custom-domains/v1/<domain>"
```

*Expected response:*
```json
{
  "status": "success",
  "message": "Domain registration request accepted and may take a few minutes to process",
  "data": {
    "domain": "<domain>",
    "canister_id": "<your-canister-id>"
  }
}
```

---

### Step 6: Monitor Registration Status

Poll the status until `registration_status` transitions to `registered`:

```bash
curl -sL "https://icp.net/custom-domains/v1/<domain>"
```

*Expected response:*
```json
{
  "status": "success",
  "message": "Registration status of the domain",
  "data": {
    "domain": "<domain>",
    "canister_id": "<your-canister-id>",
    "registration_status": "registered"
  }
}
```

---

## 3. Diagnostic & Troubleshooting Cheatsheet

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
Verify that the boundary node serves your canister with proper IC certification headers:
```bash
curl -sI -k https://208.115.197.139 -H "Host: <domain>"
```
*Expected HTTP response: `HTTP/2 200` with `x-ic-canister-id: <your-canister-id>`.*

### Verify Alternative Origins File
```bash
curl -s "https://<canister-id>.icp0.io/.well-known/ii-alternative-origins" | jq
```

### Remove / Deregister a Custom Domain
If a domain needs to be decoupled or reassigned to a different canister:
```bash
curl -sL -X DELETE "https://icp.net/custom-domains/v1/<domain>"
```

---

## Related

| Skill | Path |
|---|---|
| Frontend Standard | [`skills/frontendStandard/SKILL.md`](../frontendStandard/SKILL.md) |
| Internet Identity Auth | [`skills/motokoStandard/internetIdentityAuthStandard/SKILL.md`](../motokoStandard/internetIdentityAuthStandard/SKILL.md) |
| Production Deploy | [`skills/guideStandard/productionDeployStandard/SKILL.md`](../guideStandard/productionDeployStandard/SKILL.md) |
