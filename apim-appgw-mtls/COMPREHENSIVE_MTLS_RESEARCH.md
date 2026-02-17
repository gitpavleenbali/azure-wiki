# Comprehensive MTLS Research Analysis
**Date:** January 23, 2026  
**Research Status:** In Progress

---

## 1. Application Gateway Mutual Authentication Overview

### Two Supported Modes

#### **Mode 1: MTLS Passthrough (Recommended for your case)**
- **API Version Required:** `2025-03-01` or later (newly released November 2025)
- **Certificate Validation:** ❌ NOT performed by Application Gateway
- **Certificate Forwarding:** ✅ YES - Available through server variables
- **Behavior:** 
  - App Gateway requests certificate during TLS handshake
  - Does NOT reject connection if certificate missing/invalid
  - Connection to backend proceeds regardless
  - Backend (APIM) is responsible for validation
  - Server variables populate IF certificate is provided

**Why This Suits Your Scenario:**
- APIM (backend) needs to validate the certificate itself
- Allows flexibility in validation logic
- No need to upload CA certificate to App Gateway initially
- Perfect match for your policy-based validation approach

---

#### **Mode 2: MTLS Strict Mode (Alternative)**
- **Certificate Validation:** ✅ ENFORCED by Application Gateway
- **Trusted CA Required:** YES - Must upload trusted client CA certificate(s)
- **Returns:** HTTP 400 if certificate missing or invalid
- **File Requirements:** 
  - PEM or CER format
  - Max 25 KB per file
  - Must include full certificate chain (root + intermediates)
  - Up to 100 trusted CA certificate chains per SSL profile
  - Up to 200 total per Application Gateway

**Certificate Chain Details:**
- If client cert chain has: root → intermediate → leaf
  - Intermediate's subject name is extracted as "issuer DN"
  - This is used for additional validation (optional)
- Must be careful with multiple chains in same file (can cause issues)

**Advanced Features:**
- Verify client certificate DN (issuer validation) - optional
- OCSP revocation check support
- CRL revocation NOT supported

**Why NOT Ideal for Your Scenario (at least initially):**
- Requires uploading trusted CA certificate to App Gateway
- Gateway rejects invalid certs before reaching APIM
- Less flexible than letting APIM handle validation
- Requires more upfront configuration

---

### Server Variables (Critical for Certificate Forwarding)

**Available in PASSTHROUGH mode:**
```
{var_client_certificate}              - Full certificate (PEM format)
{var_client_certificate_fingerprint}  - Certificate fingerprint/thumbprint
{var_client_certificate_verification} - Certificate verification status (SUCCESS/NONE/FAILED)
{var_client_certificate_issuer_dn}    - Certificate issuer distinguished name
{var_client_certificate_subject_dn}   - Certificate subject distinguished name
{var_client_certificate_subject_cn}   - Certificate subject common name
```

**How Server Variables Work:**
1. Client sends certificate during TLS handshake
2. App Gateway (with PASSTHROUGH enabled) captures it
3. Server variables are populated with certificate data
4. Rewrite rules use these variables to add headers
5. Backend receives headers with certificate info

**Current Issue in Your Setup:**
- Server variables are NULL because:
  1. No SSL profile with passthrough configured
  2. No listener configured to request certificate
  3. App Gateway doesn't capture certificate data
  4. Variables have nothing to populate

---

## 2. Key Technical Insights from Microsoft Docs

### Mutual Authentication Requirements
- **SKU Limitation:** Only Standard_v2 and WAF_v2 support mutual authentication
  - Your setup uses WAF_v2 ✅ (Correct)
- **TLS Minimum:** TLS 1.2 recommended (mandatory in future)
- **API Version:** 2025-03-01 for PASSTHROUGH mode (newest)

### Configuration Validation Rules
When uploading certificate chains:
1. **Single chain per file is recommended** (best practice)
2. Root CA must always be included
3. Intermediate CAs are optional but common
4. Chain must be valid and complete
5. Files must be PEM or CER format

### Certificate Revocation (Advanced)
- OCSP supported (Online Certificate Status Protocol)
- CRL NOT supported
- Revocation check introduced in API v2022-05-01
- Requires OCSP responder availability
- Uses local cache for performance

---

## 3. Why Current Rewrite Rules Return NULL

**Root Cause Chain:**
```
┌─────────────────────────────────────────────────────────────────────┐
│ Issue: Server Variables Are NULL                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│ Prerequisite 1: SSL Profile with PASSTHROUGH config                │
│   └─ Current State: sslProfiles: [] (EMPTY) ❌                      │
│                                                                     │
│ Prerequisite 2: Listener referencing the SSL profile               │
│   └─ Current State: No sslProfile in listener ❌                    │
│                                                                     │
│ Prerequisite 3: Client sends certificate in TLS                    │
│   └─ Current State: App Gateway not requesting it ❌                │
│                                                                     │
│ RESULT: No data to populate variables → NULL values                │
│                                                                     │
│ Rewrite Rules get: {var_client_certificate} = NULL                 │
│                    {var_client_certificate_fingerprint} = NULL      │
│                    {var_client_certificate_verification} = NONE     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 4. Solution Architecture (PASSTHROUGH MODE - RECOMMENDED)

### Step 1: Create SSL Profile with PASSTHROUGH Configuration

**Bicep Configuration:**
```bicep
sslProfiles: [
  {
    name: 'mtls-passthrough-profile'
    properties: {
      clientAuthConfiguration: {
        verifyClientCertIssuerDN: false  // Optional: can enable for stricter validation
        verifyClientRevocation: 'None'   // Or 'OCSP' if you need revocation checks
      }
      tlsPolicy: 'AppGwSSLPolicy20170401S'  // Or newer policy
      minProtocolVersion: 'TLSv1_2'
      clientAuthConfiguration: {
        enabled: true  // This enables passthrough
      }
    }
  }
]
```

### Step 2: Update HTTP Listener to Use Profile

**Bicep Configuration:**
```bicep
httpListeners: [
  {
    name: 'uniperapis-dev-gateway-listener-001'
    properties: {
      protocol: 'Https'
      port: 443
      sslProfile: {
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslProfiles/mtls-passthrough-profile'
      }
      // ... other properties
    }
  }
]
```

### Step 3: Update APIM to Enable Certificate Negotiation

**Bicep Configuration (APIMHub.bicep):**
```bicep
hostnameConfigurations: [
  {
    type: 'Proxy'
    hostName: 'gateway-dev.apis.uniper.energy'
    negotiateClientCertificate: true  // ✅ CHANGE FROM false
    keyVaultId: 'https://${service_uniperapis_dev_name}-kv-001.vault.azure.net/secrets/gateway-dev'
    // ... rest of config
  }
]
```

### Step 4: Update Rewrite Rules

**Application Gateway Rewrite Rules:**
```bicep
// In requestRoutingRules, add rewrite rules similar to:
{
  name: 'mtls-certificate-headers'
  properties: {
    conditions: []
    actions: [
      {
        requestHeaderActions: [
          {
            actionType: 'Set'
            headerName: 'X-Client-Cert-Fingerprint'
            headerValue: '{var_client_certificate_fingerprint}'
          }
          {
            actionType: 'Set'
            headerName: 'X-Client-Cert-Verification'
            headerValue: '{var_client_certificate_verification}'
          }
          {
            actionType: 'Set'
            headerName: 'X-Client-Cert'
            headerValue: '{var_client_certificate}'
          }
        ]
      }
    ]
  }
}
```

### Step 5: Update APIM Policy

**Improved Policy Logic:**
```xml
<policies>
    <inbound>
        <base />
        <set-header name="Ocp-Apim-Subscription-Key" exists-action="delete" />
        
        <!-- Check native certificate context (when negotiateClientCertificate=true) -->
        <choose>
            <when condition="@(context.Request.Certificate != null)">
                <!-- Certificate received and verified by APIM's TLS negotiation -->
                <set-variable name="certThumbprint" value="@(context.Request.Certificate.Thumbprint)" />
                <set-variable name="certValid" value="true" />
            </when>
            <otherwise>
                <!-- Fallback: Check headers from App Gateway rewrite -->
                <set-variable name="certFingerprint" value="@(context.Request.Headers.GetValueOrDefault("X-Client-Cert-Fingerprint", ""))" />
                
                <choose>
                    <when condition="@(!string.IsNullOrEmpty((string)context.Variables["certFingerprint"]))">
                        <set-variable name="certThumbprint" value="@((string)context.Variables["certFingerprint"])" />
                        <set-variable name="certValid" value="true" />
                    </when>
                    <otherwise>
                        <return-response>
                            <set-status code="403" reason="Client certificate required" />
                            <set-body>{"error": "No client certificate found"}</set-body>
                        </return-response>
                    </otherwise>
                </choose>
            </otherwise>
        </choose>
        
        <!-- Validate thumbprint against expected value -->
        <choose>
            <when condition="@((string)context.Variables["certThumbprint"] == "EXPECTED_THUMBPRINT_HERE")">
                <!-- Certificate is valid, allow request -->
            </when>
            <otherwise>
                <return-response>
                    <set-status code="403" reason="Invalid certificate" />
                    <set-body>@{
                        return new JObject(
                            new JProperty("error", "Certificate thumbprint mismatch"),
                            new JProperty("received", context.Variables["certThumbprint"])
                        ).ToString();
                    }</set-body>
                </return-response>
            </otherwise>
        </choose>
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
```

---

## 5. Data Flow After Implementation

```
┌────────────────────────────────────────────────────────────────┐
│ FIXED MTLS DATA FLOW                                           │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│ 1. External Client                                            │
│    └─ Makes HTTPS request with client certificate             │
│                                                                │
│ 2. Application Gateway Listener (with SSL Profile)            │
│    └─ Accepts connection                                      │
│    └─ Requests certificate in TLS handshake                   │
│    └─ Client presents certificate                             │
│    └─ App Gateway captures certificate data                   │
│    └─ Populates server variables:                             │
│       - {var_client_certificate_fingerprint}                  │
│       - {var_client_certificate_verification}                 │
│       - {var_client_certificate}                              │
│                                                                │
│ 3. Rewrite Rules                                              │
│    └─ Adds headers to request:                                │
│       X-Client-Cert-Fingerprint: [fingerprint value]          │
│       X-Client-Cert-Verification: SUCCESS                     │
│       X-Client-Cert: [cert data]                              │
│                                                                │
│ 4. APIM Policy (negotiateClientCertificate=true)             │
│    └─ Receives request with headers                           │
│    └─ APIM also receives native cert via TLS negotiation      │
│    └─ Policy extracts thumbprint                              │
│    └─ Validates against expected value                        │
│    └─ If match → Allow request                                │
│    └─ If mismatch → Return 403                                │
│                                                                │
│ 5. Backend Service                                            │
│    └─ Receives authenticated request                          │
│    └─ Processes normally                                      │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## 6. Comparison: Current vs. Fixed Configuration

| Aspect | Current ❌ | Fixed ✅ |
|--------|-----------|---------|
| **App Gateway SSL Profile** | Empty array | PASSTHROUGH profile defined |
| **Listener SSL Profile Ref** | None | References mtls-passthrough-profile |
| **Server Variables** | NULL (not captured) | Populated with cert data |
| **APIM negotiateClientCert** | false | true |
| **context.Request.Certificate** | null | Populated |
| **Rewrite Headers** | Empty/null values | Actual cert fingerprint |
| **Certificate Validation** | Never reached | Works as designed |
| **Result** | 403 always | 200 on valid cert, 403 on invalid |

---

## 7. Testing Strategy

1. **Phase 1: Enable Certificate Capture**
   - Deploy SSL profile to App Gateway
   - Update listener to use profile
   - Test: Does App Gateway now capture certificate?
   - Verify: Check App Gateway diagnostic logs for certificate capture

2. **Phase 2: Enable APIM Negotiation**
   - Update APIM hostname config: `negotiateClientCertificate: true`
   - Test: Does `context.Request.Certificate` now populate?
   - Verify: Test API call and check policy variables

3. **Phase 3: Full Integration**
   - Deploy updated policy with thumbprint validation
   - Test with valid certificate → expect 200
   - Test with invalid certificate → expect 403
   - Verify fingerprints match between all layers

4. **Phase 4: Production Readiness**
   - Document expected thumbprint(s)
   - Create rollback procedure
   - Plan client certificate rotation strategy
   - Test with actual client certificates

---

## 8. Key Findings Summary

### From Microsoft Docs:
1. ✅ App Gateway WAF_v2 supports MTLS (both PASSTHROUGH and STRICT)
2. ✅ PASSTHROUGH mode is perfect for delegating validation to backend
3. ✅ Server variables ONLY populate when certificate provided AND profile enabled
4. ✅ API version 2025-03-01 required for latest features
5. ✅ Certificate chain must be complete (root required for STRICT mode)
6. ✅ OCSP revocation checking available but requires responder availability

### Gap Analysis:
1. ❌ No SSL profile defined → Variables never populated
2. ❌ No listener configuration for MTLS → No certificate capture
3. ❌ APIM negotiation disabled → Native certificate context empty
4. ❌ Rewrite rules get NULL values → Headers are empty
5. ❌ Policy always returns 403 → Never reaches validation logic

---

## 9. Next Steps

- [ ] Fetch and analyze Microsoft Q&A link (first link) for additional context
- [ ] Review Stack Overflow discussion for implementation details
- [ ] Review Reddit community discussion for lessons learned
- [ ] Consolidate all findings into final solution document
- [ ] Generate updated Bicep files with all fixes
- [ ] Create deployment checklist
- [ ] Create testing checklist
- [ ] Create rollback procedure

---

**Status:** Awaiting additional link analysis to finalize solution  
**Last Updated:** January 23, 2026
