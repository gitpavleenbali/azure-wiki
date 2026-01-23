# MTLS Authentication: Application Gateway + API Management

**Customer:** Uniper Energy  
**Issue:** Client certificates not forwarded from Application Gateway to APIM — resulting in 403 errors  
**Resolution Date:** January 23, 2026  
**Author:** Pavleen Bali, Cloud Solution Architect, Microsoft

---

## Executive Summary

External API consumers authenticating via client certificates receive `403 Forbidden` errors. Investigation revealed that MTLS (Mutual TLS) was not properly configured on the Application Gateway, causing all certificate-related server variables to return `NULL`.

**Root Cause:** Application Gateway was missing the required MTLS configuration components:
- No trusted client CA certificates uploaded
- No SSL profile with client authentication enabled
- HTTPS listener not bound to an SSL profile
- APIM `negotiateClientCertificate` set to `false`

**Resolution:** Configure end-to-end MTLS by enabling mutual authentication on Application Gateway and client certificate negotiation on APIM.

**Validation Status:** ✅ Solution validated in test environment on January 23, 2026

---

## Problem Summary

| Symptom | Root Cause |
|---------|------------|
| API returns 403 Forbidden | Client certificate not reaching APIM |
| `context.Request.Certificate` is NULL in APIM policy | APIM not configured to request client certificates |
| Server variables `{var_client_certificate}` return NULL | Application Gateway MTLS not enabled |
| Rewrite rules forward empty headers | No SSL profile attached to listener |

### Evidence from Customer Environment

**Application Gateway Configuration (mainAPINW.bicep):**
```bicep
trustedClientCertificates: []   // ❌ Empty - No CA certificates
sslProfiles: []                  // ❌ Empty - No MTLS profile
```

**APIM Configuration (APIMHub.bicep):**
```bicep
hostName: 'gateway-dev.apis.uniper.energy'
negotiateClientCertificate: false  // ❌ APIM won't request certificates
```

---

## Solution Architecture

```
┌──────────────┐      ┌─────────────────────────────────────┐      ┌──────────────┐
│   Client     │ TLS  │      Application Gateway            │ TLS  │     APIM     │
│ (with cert)  │─────▶│  ✅ Trusted CA Certificate          │─────▶│ ✅ negotiate │
│              │      │  ✅ SSL Profile (MTLS enabled)      │      │    = true    │
│              │      │  ✅ Listener → SSL Profile          │      │              │
│              │      │  ✅ Rewrite Rules → Headers         │      │              │
└──────────────┘      └─────────────────────────────────────┘      └──────────────┘
```

---

## Implementation Steps

### Step 1: Upload Trusted Client CA Certificate

Upload the CA certificate that signs your client certificates to Application Gateway.

```bash
az network application-gateway client-cert add \
  --resource-group <RESOURCE_GROUP> \
  --gateway-name <APP_GATEWAY_NAME> \
  --name "client-ca-cert" \
  --data <BASE64_ENCODED_CA_CERT>
```

### Step 2: Create SSL Profile with Mutual Authentication

Create an SSL profile that requires and validates client certificates.

```bash
az network application-gateway ssl-profile add \
  --resource-group <RESOURCE_GROUP> \
  --gateway-name <APP_GATEWAY_NAME> \
  --name "mtls-ssl-profile" \
  --client-auth-configuration verify-client-cert-issuer-dn=true \
  --trusted-client-certificates "client-ca-cert"
```

### Step 3: Bind SSL Profile to HTTPS Listener

Attach the SSL profile to your HTTPS listener to enforce MTLS.

```bash
az network application-gateway http-listener update \
  --resource-group <RESOURCE_GROUP> \
  --gateway-name <APP_GATEWAY_NAME> \
  --name "<HTTPS_LISTENER_NAME>" \
  --ssl-profile "mtls-ssl-profile"
```

### Step 4: Configure Rewrite Rules for Certificate Headers

Create rewrite rules to forward certificate data to the backend.

```bash
# Create rewrite rule set
az network application-gateway rewrite-rule set create \
  --resource-group <RESOURCE_GROUP> \
  --gateway-name <APP_GATEWAY_NAME> \
  --name "mtls-rewrite-rules"

# Add certificate header rules
az network application-gateway rewrite-rule create \
  --resource-group <RESOURCE_GROUP> \
  --gateway-name <APP_GATEWAY_NAME> \
  --rule-set-name "mtls-rewrite-rules" \
  --name "add-client-cert-header" \
  --sequence 100 \
  --request-headers "X-Client-Cert={var_client_certificate}"

az network application-gateway rewrite-rule create \
  --resource-group <RESOURCE_GROUP> \
  --gateway-name <APP_GATEWAY_NAME> \
  --rule-set-name "mtls-rewrite-rules" \
  --name "add-fingerprint-header" \
  --sequence 101 \
  --request-headers "X-Client-Cert-Fingerprint={var_client_certificate_fingerprint}"
```

### Step 5: Enable Client Certificate Negotiation in APIM

Configure APIM to request client certificates from Application Gateway.

```bash
az apim update \
  --resource-group <APIM_RESOURCE_GROUP> \
  --name <APIM_NAME> \
  --set hostnameConfigurations[0].negotiateClientCertificate=true
```

### Step 6: Configure APIM Policy to Read Certificate

Add an APIM policy that can read the client certificate. There are two options:

**Option A: Read from TLS Context (Direct APIM or end-to-end TLS passthrough)**

When calling APIM directly or when App Gateway passes the TLS connection through, use `context.Request.Certificate`:

```xml
<policies>
    <inbound>
        <base />
        <choose>
            <when condition="@(context.Request.Certificate != null)">
                <set-header name="X-Client-Thumbprint" exists-action="override">
                    <value>@(context.Request.Certificate.Thumbprint)</value>
                </set-header>
                <set-header name="X-Client-Subject" exists-action="override">
                    <value>@(context.Request.Certificate.Subject)</value>
                </set-header>
            </when>
            <otherwise>
                <return-response>
                    <set-status code="403" reason="Forbidden" />
                    <set-body>Client certificate required</set-body>
                </return-response>
            </otherwise>
        </choose>
    </inbound>
    <backend><base /></backend>
    <outbound><base /></outbound>
    <on-error><base /></on-error>
</policies>
```

**Option B: Read from HTTP Headers (When App Gateway terminates TLS)**

When App Gateway terminates TLS and forwards certificate via rewrite headers:

```xml
<policies>
    <inbound>
        <base />
        <set-variable name="clientCert" value="@(context.Request.Headers.GetValueOrDefault("X-Client-Cert", ""))" />
        <set-variable name="clientFingerprint" value="@(context.Request.Headers.GetValueOrDefault("X-Client-Cert-Fingerprint", ""))" />
        <choose>
            <when condition="@(context.Variables.GetValueOrDefault<string>("clientFingerprint", "") != "")">
                <!-- Certificate received via header - proceed -->
            </when>
            <otherwise>
                <return-response>
                    <set-status code="403" reason="Forbidden" />
                    <set-body>Client certificate required</set-body>
                </return-response>
            </otherwise>
        </choose>
    </inbound>
    <backend><base /></backend>
    <outbound><base /></outbound>
    <on-error><base /></on-error>
</policies>
```

**Test API Policy (Echo Certificate Info):**

Use this policy to verify certificate is being received:

```xml
<policies>
    <inbound>
        <base />
        <return-response>
            <set-status code="200" reason="OK" />
            <set-header name="Content-Type" exists-action="override">
                <value>application/json</value>
            </set-header>
            <set-body>@{
                var result = new JObject();
                result["tlsCertExists"] = context.Request.Certificate != null;
                if(context.Request.Certificate != null) {
                    result["tlsCertThumbprint"] = context.Request.Certificate.Thumbprint;
                    result["tlsCertSubject"] = context.Request.Certificate.Subject;
                }
                result["xClientCertHeader"] = context.Request.Headers.GetValueOrDefault("X-Client-Cert", "NOT_FOUND");
                result["xClientCertFingerprint"] = context.Request.Headers.GetValueOrDefault("X-Client-Cert-Fingerprint", "NOT_FOUND");
                return result.ToString();
            }</set-body>
        </return-response>
    </inbound>
    <backend><base /></backend>
    <outbound><base /></outbound>
    <on-error><base /></on-error>
</policies>
```

---

## Validation Results

Solution validated in Microsoft test environment with the following results:

| Test Scenario | Expected Result | Actual Result | Status |
|---------------|-----------------|---------------|--------|
| Request WITHOUT client certificate | 400 Bad Request | 400 Bad Request | ✅ Pass |
| Request WITH valid client certificate | Request reaches APIM | 404 Not Found (APIM) | ✅ Pass |
| Backend health probe | Healthy | Healthy | ✅ Pass |

**Test Environment:**
- Application Gateway: `appgw-mtls-test` (Standard_v2)
- APIM: `apim-mtls-7842` (Developer SKU)
- Region: West Europe

**Validation Commands:**
```powershell
# Without certificate - returns 400 (MTLS enforced)
Invoke-WebRequest -Uri "https://<APP_GW_IP>/" -SkipCertificateCheck
# Result: 400 Bad Request

# With certificate - passes through to APIM
$cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new("client.pfx", $password)
Invoke-WebRequest -Uri "https://<APP_GW_IP>/" -Certificate $cert -SkipCertificateCheck
# Result: 404 Not Found (request reached APIM successfully)
```

---

## Required Bicep Changes

### Application Gateway (mainAPINW.bicep)

**Before:**
```bicep
trustedClientCertificates: []
sslProfiles: []
```

**After:**
```bicep
trustedClientCertificates: [
  {
    name: 'client-ca-cert'
    properties: {
      data: '<BASE64_CA_CERTIFICATE>'
    }
  }
]

sslProfiles: [
  {
    name: 'mtls-ssl-profile'
    properties: {
      clientAuthConfiguration: {
        verifyClientCertIssuerDN: true
      }
      trustedClientCertificates: [
        {
          id: resourceId('Microsoft.Network/applicationGateways/trustedClientCertificates', appGwName, 'client-ca-cert')
        }
      ]
    }
  }
]
```

**Listener Update:**
```bicep
httpListeners: [
  {
    name: 'gateway-dev-listener'
    properties: {
      // ... existing properties ...
      sslProfile: {
        id: resourceId('Microsoft.Network/applicationGateways/sslProfiles', appGwName, 'mtls-ssl-profile')
      }
    }
  }
]
```

### APIM (APIMHub.bicep)

**Before:**
```bicep
{
  type: 'Proxy'
  hostName: 'gateway-dev.apis.uniper.energy'
  negotiateClientCertificate: false
}
```

**After:**
```bicep
{
  type: 'Proxy'
  hostName: 'gateway-dev.apis.uniper.energy'
  negotiateClientCertificate: true
}
```

---

## Key Configuration Requirements

| Component | Property | Required Value |
|-----------|----------|----------------|
| App Gateway | trustedClientCertificates | CA certificate uploaded |
| App Gateway | sslProfiles | Profile with `verifyClientCertIssuerDN: true` |
| App Gateway | httpListener.sslProfile | Reference to MTLS profile |
| APIM | negotiateClientCertificate | `true` |

---

## Server Variables Reference

These variables are only populated when MTLS is properly configured:

| Variable | Description |
|----------|-------------|
| `{var_client_certificate}` | Base64-encoded client certificate |
| `{var_client_certificate_fingerprint}` | SHA1 thumbprint |
| `{var_client_certificate_verification}` | SUCCESS, FAILED, or NONE |
| `{var_client_certificate_issuer}` | Certificate issuer DN |
| `{var_client_certificate_subject}` | Certificate subject DN |

---

## References

- [Application Gateway Mutual Authentication Overview](https://learn.microsoft.com/en-us/azure/application-gateway/mutual-authentication-overview)
- [Rewrite HTTP Headers - Mutual Authentication Variables](https://learn.microsoft.com/en-us/azure/application-gateway/rewrite-http-headers-url#mutual-authentication-server-variables)
- [APIM Client Certificate Authentication](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-mutual-certificates-for-clients)

---

**Document Version:** 1.0  
**Last Updated:** January 23, 2026  
**Status:** ✅ Validated
