# 🎯 Customer Meeting Runbook: App Gateway ↔ APIM mTLS Issue

**Customer:** Priyanka (APIM Team)  
**Incident:** 2511240050002800  
**Duration:** 1 Hour  
**Date:** January 15, 2026

---

## 📋 Meeting Agenda

| Time | Section | Duration |
|:----:|---------|:--------:|
| 0:00 | Introduction & Problem Summary | 5 min |
| 0:05 | Discovery Questions | 15 min |
| 0:20 | Live Debugging Session | 25 min |
| 0:45 | Solution Proposition | 10 min |
| 0:55 | Next Steps & Wrap-up | 5 min |

---

## 1️⃣ Introduction & Problem Summary (5 min)

### Opening Script

> "Hi Priyanka, thank you for joining today. I've reviewed your case and understand you're facing a challenge with mutual TLS between your Application Gateway and API Management. Let me quickly summarize what I understand, and please correct me if I'm missing anything."

### Problem Statement

```
+----------+       HTTPS        +------------------+      mTLS       +------+
|          |  (TLS Termination) |                  | (FAILING HERE) |      |
|  Client  | -----------------> | App Gateway v2   | -----X--------> | APIM |
| (External)|                   |                  |                 |      |
+----------+                    +------------------+                 +------+
```

**What's Working:**
- ✅ mTLS between client and APIM directly (within network)

**What's NOT Working:**
- ❌ TLS handshake fails when traffic flows: Client → App Gateway → APIM
- ❌ External users cannot access APIs through App Gateway with mTLS

---

## 2️⃣ Discovery Questions (15 min)

### Question 1: Architecture Clarification

> "Can you walk me through your current architecture?"

**What to capture:**

| Component | Details to Note |
|-----------|-----------------|
| App Gateway SKU | v1 or v2? (v2 required for certain mTLS features) |
| App Gateway Tier | Standard or WAF? |
| APIM SKU | Developer, Basic, Standard, Premium? |
| APIM Mode | External, Internal, or Internal with App Gateway? |
| Network Setup | VNET integrated? Private endpoints? |

**Portal Path:**
- App Gateway: `Portal → Application Gateway → Overview → SKU`
- APIM: `Portal → API Management → Overview → Pricing tier`

**CLI Commands:**
```bash
# Check App Gateway details
az network application-gateway show \
  --resource-group <rg-name> \
  --name <appgw-name> \
  --query "{sku:sku, tier:sku.tier, capacity:sku.capacity}"

# Check APIM details
az apim show \
  --resource-group <rg-name> \
  --name <apim-name> \
  --query "{sku:sku, publicIpAddresses:publicIpAddresses, privateIpAddresses:privateIpAddresses, virtualNetworkType:virtualNetworkType}"
```

---

### Question 2: Current Certificate Configuration

> "Let's understand your certificate setup. What certificates are currently configured?"

**What to capture:**

| Certificate | Location | Purpose |
|-------------|----------|---------|
| Frontend/Listener Cert | App Gateway Listener | Client → App Gateway TLS |
| Backend Auth Cert | App Gateway HTTP Settings | App Gateway → APIM trust |
| Client Cert | App Gateway HTTP Settings | App Gateway presents to APIM |
| CA Certificate | APIM | APIM trusts this CA for client certs |
| Gateway Cert | APIM | APIM's server certificate |

**Portal Path:**
- App Gateway Certs: `Application Gateway → Settings → Listeners → (select listener) → Certificate`
- App Gateway Backend: `Application Gateway → Settings → HTTP settings → (select) → Backend authentication`
- APIM Certs: `API Management → Security → Certificates`

**CLI Commands:**
```bash
# List App Gateway SSL certificates
az network application-gateway ssl-cert list \
  --resource-group <rg-name> \
  --gateway-name <appgw-name> \
  --query "[].{name:name, publicCertData:publicCertData}"

# List App Gateway trusted root certificates
az network application-gateway root-cert list \
  --resource-group <rg-name> \
  --gateway-name <appgw-name>

# List App Gateway auth certificates (v1) 
az network application-gateway auth-cert list \
  --resource-group <rg-name> \
  --gateway-name <appgw-name>

# Check APIM certificates
az apim show \
  --resource-group <rg-name> \
  --name <apim-name> \
  --query "certificates"
```

---

### Question 3: Backend Health Status

> "What does the backend health show for APIM in App Gateway?"

**This is CRITICAL** - often reveals the root cause immediately.

**Portal Path:**
- `Application Gateway → Monitoring → Backend health`

**CLI Command:**
```bash
az network application-gateway show-backend-health \
  --resource-group <rg-name> \
  --name <appgw-name> \
  --output table
```

**What to look for:**

| Status | Meaning | Action |
|--------|---------|--------|
| Healthy | Backend is reachable | Check other issues |
| Unhealthy | Connection failing | Check certificates, NSG, firewall |
| Unknown | Probe not configured | Configure custom probe |

**Common Backend Health Errors:**

| Error Message | Root Cause |
|---------------|------------|
| `The Common Name (CN) doesn't match` | SNI/hostname mismatch |
| `The root certificate of the server certificate is not trusted` | Missing trusted root cert in App Gateway |
| `Connection timed out` | NSG/Firewall blocking traffic |
| `Received invalid status code: 403` | APIM rejecting - missing/invalid client cert |

---

### Question 4: Health Probe Configuration

> "How is your health probe configured for the APIM backend?"

**Portal Path:**
- `Application Gateway → Settings → Health probes`

**CLI Command:**
```bash
az network application-gateway probe list \
  --resource-group <rg-name> \
  --gateway-name <appgw-name> \
  --query "[].{name:name, protocol:protocol, host:host, path:path, interval:interval, timeout:timeout}"
```

**Expected Configuration for APIM:**

| Setting | Recommended Value |
|---------|-------------------|
| Protocol | HTTPS |
| Host | `<apim-name>.azure-api.net` |
| Path | `/status-0123456789abcdef` |
| Interval | 30 seconds |
| Timeout | 30 seconds |
| Unhealthy threshold | 3 |

> ⚠️ **Important:** The `/status-0123456789abcdef` endpoint doesn't require authentication!

---

### Question 5: HTTP Settings Configuration

> "What are your HTTP settings configured for the APIM backend?"

**Portal Path:**
- `Application Gateway → Settings → HTTP settings`

**CLI Command:**
```bash
az network application-gateway http-settings list \
  --resource-group <rg-name> \
  --gateway-name <appgw-name> \
  --query "[].{name:name, protocol:protocol, port:port, hostName:hostName, pickHostNameFromBackend:pickHostNameFromBackendAddress, trustedRootCerts:trustedRootCertificates}"
```

**What to verify:**

| Setting | Required for mTLS |
|---------|-------------------|
| Protocol | HTTPS |
| Port | 443 |
| Override with hostname | Yes (APIM FQDN) |
| Trusted Root Cert | Uploaded (APIM's root CA) |

---

### Question 6: APIM Client Certificate Settings

> "Is client certificate negotiation enabled on APIM?"

**Portal Path:**
- `API Management → Deployment + infrastructure → Custom domains → (Gateway) → Negotiate client certificate`

**CLI Command:**
```bash
az apim show \
  --resource-group <rg-name> \
  --name <apim-name> \
  --query "hostnameConfigurations[].{hostname:hostName, negotiateClientCertificate:negotiateClientCertificate}"
```

**What to verify:**
- `negotiateClientCertificate` should be `true` for the gateway hostname

---

### Question 7: Network Security Groups & Firewall

> "Are there any NSGs or firewalls between App Gateway and APIM?"

**Portal Path:**
- `Virtual Network → Subnets → (AppGW Subnet) → Network security group`
- `Virtual Network → Subnets → (APIM Subnet) → Network security group`

**CLI Commands:**
```bash
# List NSG rules on App Gateway subnet
az network nsg rule list \
  --resource-group <rg-name> \
  --nsg-name <appgw-subnet-nsg> \
  --output table

# List NSG rules on APIM subnet
az network nsg rule list \
  --resource-group <rg-name> \
  --nsg-name <apim-subnet-nsg> \
  --output table
```

**Required Rules:**

| Direction | Port | Purpose |
|-----------|------|---------|
| Inbound to APIM | 443 | HTTPS from App Gateway |
| Inbound to APIM | 3443 | Management endpoint |
| Outbound from AppGW | 443 | To APIM backend |

---

## 3️⃣ Live Debugging Session (25 min)

### Step 1: Verify Backend Health (5 min)

```bash
# Run this together with customer
az network application-gateway show-backend-health \
  --resource-group <rg-name> \
  --name <appgw-name>
```

**Document the output here:**
```
Status: _______________
Error Message: _______________
```

---

### Step 2: Test Direct Connectivity (5 min)

From a VM in the same VNET or App Gateway subnet:

```bash
# Test HTTPS connection to APIM
curl -v https://<apim-gateway-url>/status-0123456789abcdef

# Test with client certificate
curl -v --cert client.crt --key client.key https://<apim-gateway-url>/echo/resource
```

---

### Step 3: Verify Certificate Chain (5 min)

```bash
# Check APIM certificate
openssl s_client -connect <apim-name>.azure-api.net:443 -showcerts

# Verify certificate expiry
openssl s_client -connect <apim-name>.azure-api.net:443 2>/dev/null | openssl x509 -noout -dates
```

**In Portal:**
- `API Management → Security → Certificates → CA certificates`
- Verify the App Gateway's client certificate issuer CA is listed here

---

### Step 4: Check App Gateway Diagnostics (5 min)

**Portal Path:**
- `Application Gateway → Monitoring → Diagnostic settings → Enable`
- `Application Gateway → Monitoring → Logs`

**KQL Query for Access Logs:**
```kql
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where Category == "ApplicationGatewayAccessLog"
| where TimeGenerated > ago(1h)
| project TimeGenerated, clientIP_s, httpStatus_d, serverRouted_s, serverStatus_s, serverResponseLatency_s
| order by TimeGenerated desc
```

**KQL Query for Firewall Logs (if WAF):**
```kql
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where Category == "ApplicationGatewayFirewallLog"
| where TimeGenerated > ago(1h)
| project TimeGenerated, requestUri_s, action_s, ruleId_s, message_s
| order by TimeGenerated desc
```

---

### Step 5: Validate TLS Policy (5 min)

```bash
# Check App Gateway SSL Policy
az network application-gateway ssl-policy show \
  --resource-group <rg-name> \
  --gateway-name <appgw-name>
```

**Recommended Policy:** `AppGwSslPolicy20220101` or `AppGwSslPolicy20220101S`

---

## 4️⃣ Solution Proposition (10 min)

Based on findings, apply the relevant solution:

### Solution A: Missing Trusted Root Certificate

**Problem:** App Gateway doesn't trust APIM's certificate

**Fix:**
```bash
# 1. Export APIM's root CA certificate (from browser or openssl)
# 2. Upload to App Gateway
az network application-gateway root-cert create \
  --gateway-name <appgw-name> \
  --resource-group <rg-name> \
  --name apim-trusted-root \
  --cert-file ./apim-root-ca.cer

# 3. Associate with HTTP settings
az network application-gateway http-settings update \
  --gateway-name <appgw-name> \
  --resource-group <rg-name> \
  --name <http-settings-name> \
  --root-certs apim-trusted-root
```

---

### Solution B: APIM Not Trusting App Gateway Client Cert

**Problem:** APIM rejects App Gateway's client certificate

**Fix in Portal:**
1. Go to `API Management → Security → Certificates → CA certificates`
2. Click `+ Add`
3. Upload the **Root CA** that issued App Gateway's client certificate
4. Save

**Verify in APIM Policy:**
```xml
<inbound>
    <validate-client-certificate 
        validate-revocation="false"
        validate-trust="true"
        validate-not-before="true"
        validate-not-after="true" />
</inbound>
```

---

### Solution C: Hostname/SNI Mismatch

**Problem:** Backend hostname doesn't match certificate

**Fix:**
```bash
# Update HTTP settings to use correct hostname
az network application-gateway http-settings update \
  --gateway-name <appgw-name> \
  --resource-group <rg-name> \
  --name <http-settings-name> \
  --host-name "<apim-name>.azure-api.net" \
  --host-name-from-backend-pool false
```

---

### Solution D: Health Probe Failing

**Problem:** Probe doesn't work with mTLS

**Fix:**
```bash
# Update probe to use APIM's status endpoint (no auth required)
az network application-gateway probe update \
  --gateway-name <appgw-name> \
  --resource-group <rg-name> \
  --name <probe-name> \
  --protocol Https \
  --host "<apim-name>.azure-api.net" \
  --path "/status-0123456789abcdef" \
  --interval 30 \
  --timeout 30 \
  --threshold 3
```

---

### Solution E: Enable Client Certificate on APIM Gateway

**Problem:** APIM not requesting client certificate

**Fix:**
```bash
# Enable client certificate negotiation
az apim update \
  --resource-group <rg-name> \
  --name <apim-name> \
  --enable-client-certificate true
```

**Or in Portal:**
- `API Management → Custom domains → Gateway → Edit → Enable "Negotiate client certificate"`

---

## 5️⃣ Next Steps & Wrap-up (5 min)

### Action Items Template

| # | Action | Owner | Due Date |
|:-:|--------|-------|----------|
| 1 | | | |
| 2 | | | |
| 3 | | | |

### Follow-up

- [ ] Share this runbook with customer
- [ ] Schedule follow-up call if needed
- [ ] Update incident 2511240050002800

---

## 📎 Quick Reference

### Useful Documentation Links

| Topic | Link |
|-------|------|
| App Gateway + APIM Integration | [Microsoft Docs](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-integrate-internal-vnet-appgateway) |
| App Gateway mTLS | [Microsoft Docs](https://learn.microsoft.com/en-us/azure/application-gateway/mutual-authentication-overview) |
| APIM Client Certificates | [Microsoft Docs](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-mutual-certificates-for-clients) |
| App Gateway Backend Health | [Microsoft Docs](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-backend-health-troubleshooting) |

### Emergency Commands

```bash
# Quick health check
az network application-gateway show-backend-health -g <rg> -n <appgw> --query "backendAddressPools[].backendHttpSettingsCollection[].servers[]" -o table

# Restart APIM gateway (if needed)
az apim update --name <apim-name> -g <rg-name>
```

---

**Meeting Notes:**

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

*Prepared by: Azure CSA Team*  
*Last Updated: January 15, 2026*
