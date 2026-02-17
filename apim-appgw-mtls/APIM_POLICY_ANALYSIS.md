# APIM Policy Analysis - Current Certificate Validation Logic

## Current Policy Overview

The policy implements a **basic certificate validation check** that:
1. Captures certificate-related headers from Application Gateway
2. Checks if a client certificate exists in the request context
3. Returns certificate details or 403 error based on certificate presence

---

## Policy Flow Breakdown

### 1. **Inbound Section**

#### Remove Subscription Key Header
```xml
<set-header name="Ocp-Apim-Subscription-Key" exists-action="delete" />
```
- Removes subscription key header (switching from key-based to cert-based auth)
- Good practice for certificate-based authentication

#### Capture Headers from App Gateway
```xml
<set-variable name="clientCertheader" value="@{
    var clientcert = context.Request.Headers.GetValueOrDefault("X-Client-Cert");  
    var clientcertverification = context.Request.Headers.GetValueOrDefault("X-Client-Cert-Verification");
    var clientcertfingerprint = context.Request.Headers.GetValueOrDefault("X-Client-Cert-Fingerprint");
    var cerheaderinfo = new JObject(
        new JProperty("clientcert", clientcert),
        new JProperty("clientcertverification", clientcertverification),
        new JProperty("clientcertfingerprint", clientcertfingerprint)
    );
    return cerheaderinfo;    
}" />
```

**Current Status:** ❌ **NOT WORKING**
- Reading headers that App Gateway is trying to populate via rewrite rules
- But since App Gateway server variables are null, these headers are empty
- This is why the test response shows: `{"clientcert":null, "clientcertverification":"NONE", "clientcertfingerprint":null}`

---

### 2. **Certificate Validation Logic (Choose/When)**

#### When Certificate Exists
```xml
<when condition="@(context.Request.Certificate != null)">
    <set-variable name="clientCertDetails" value="@{
        var thumbprint = context.Request.Certificate.Thumbprint;    
        var certInfo = new JObject(
            new JProperty("Thumbprint", thumbprint)
        );
        return certInfo;    
    }" />
    <return-response>
        <set-status code="200" reason="ok" />
        <set-body>@{
            var certInfo = context.Variables.GetValueOrDefault("clientCertDetails");
            return Newtonsoft.Json.JsonConvert.SerializeObject(certInfo);
        }</set-body>
    </return-response>
</when>
```

**What it does:**
- Checks `context.Request.Certificate` (native APIM certificate object, not header-based)
- If certificate exists → extracts thumbprint → returns 200 with thumbprint
- This works **only if APIM is negotiating client certificates**

**Current Status:** ❌ **FAILING**
- `context.Request.Certificate` is NULL because:
  - APIM's `negotiateClientCertificate` is set to `false` in APIMHub.bicep
  - Even if App Gateway sent a certificate, APIM won't process it without this flag

#### Otherwise (No Certificate)
```xml
<otherwise>
    <return-response>
        <set-status code="403" reason="Client certificate required" />
        <set-body>@{
            var certheaderInfo = context.Variables.GetValueOrDefault("clientCertheader");
            return Newtonsoft.Json.JsonConvert.SerializeObject(certheaderInfo);
        }</set-body>
    </return-response>
</otherwise>
```

**What it does:**
- Returns 403 when no certificate found
- Includes the header values (which are currently null)

**Current Status:** ✅ **WORKING** (but wrong reason)
- Currently returns: `{"clientcert":null, "clientcertverification":"NONE", "clientcertfingerprint":null}`
- This matches the test failure we saw

---

## Why The Current Policy Fails

```
┌─────────────────────────────────────────────────────────────────┐
│ Policy Execution Flow                                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ 1. Header Capture (NOT WORKING)                                │
│    └─> X-Client-Cert = null (App Gateway server var is null)   │
│    └─> X-Client-Cert-Verification = "NONE"                     │
│    └─> X-Client-Cert-Fingerprint = null                        │
│                                                                 │
│ 2. Certificate Check (NOT WORKING)                             │
│    └─> context.Request.Certificate = null                      │
│    └─> Reason: negotiateClientCertificate = false in APIM      │
│                                                                 │
│ 3. Result                                                       │
│    └─> Condition evaluates to FALSE (certificate is null)      │
│    └─> Goes to OTHERWISE branch                                │
│    └─> Returns 403 Forbidden                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Improved Policy - After MTLS is Enabled

Once you fix the configuration (enable negotiateClientCertificate and App Gateway MTLS):

### Option 1: Native Certificate Validation (Recommended)
```xml
<policies>
    <inbound>
        <base />
        <!-- Remove subscription key since we're using certs -->
        <set-header name="Ocp-Apim-Subscription-Key" exists-action="delete" />
        
        <!-- Check if certificate exists -->
        <choose>
            <when condition="@(context.Request.Certificate == null)">
                <return-response>
                    <set-status code="403" reason="Client certificate required" />
                    <set-body>{"error": "Client certificate is required"}</set-body>
                </return-response>
            </when>
            <otherwise>
                <!-- Validate certificate thumbprint -->
                <choose>
                    <when condition="@(context.Request.Certificate.Thumbprint == "EXPECTED_THUMBPRINT_HERE")">
                        <!-- Valid certificate -->
                        <set-variable name="validCertificate" value="true" />
                    </when>
                    <otherwise>
                        <return-response>
                            <set-status code="403" reason="Invalid certificate thumbprint" />
                            <set-body>@{
                                return new JObject(
                                    new JProperty("error", "Certificate thumbprint mismatch"),
                                    new JProperty("receivedThumbprint", context.Request.Certificate.Thumbprint)
                                ).ToString();
                            }</set-body>
                        </return-response>
                    </otherwise>
                </choose>
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

### Option 2: Header-Based Validation (Fallback if native certs unavailable)
```xml
<policies>
    <inbound>
        <base />
        <set-header name="Ocp-Apim-Subscription-Key" exists-action="delete" />
        
        <!-- Validate certificate from headers (App Gateway rewrite) -->
        <set-variable name="clientCertFingerprint" value="@{
            return context.Request.Headers.GetValueOrDefault("X-Client-Cert-Fingerprint", "");
        }" />
        
        <choose>
            <when condition="@(string.IsNullOrEmpty((string)context.Variables["clientCertFingerprint"]))">
                <return-response>
                    <set-status code="403" reason="Client certificate fingerprint missing" />
                    <set-body>{"error": "Certificate validation failed: fingerprint missing"}</set-body>
                </return-response>
            </when>
            <when condition="@((string)context.Variables["clientCertFingerprint"] == "EXPECTED_THUMBPRINT")">
                <!-- Certificate is valid -->
                <set-variable name="certificateValid" value="true" />
            </when>
            <otherwise>
                <return-response>
                    <set-status code="403" reason="Invalid certificate" />
                    <set-body>@{
                        return new JObject(
                            new JProperty("error", "Certificate thumbprint mismatch"),
                            new JProperty("receivedFingerprint", context.Variables["clientCertFingerprint"])
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

## Key Policy Improvements Needed

1. **Add Thumbprint Validation**
   - Replace "EXPECTED_THUMBPRINT_HERE" with actual expected certificate thumbprint
   - Should be provided by the external API client

2. **Better Error Messages**
   - Include actual vs. expected thumbprint in error responses
   - Distinguish between "certificate missing" and "certificate invalid"

3. **Logging**
   - Add `<trace>` statements for debugging
   - Log certificate details when validation fails

4. **Optional: Certificate Pinning**
   - Store multiple trusted thumbprints
   - Validate against list of known certificates

5. **Optional: Certificate Details**
   - Extract issuer name
   - Validate certificate not expired
   - Check certificate chain

---

## Implementation Checklist

- [ ] Fix APIM `negotiateClientCertificate: true` in APIMHub.bicep
- [ ] Fix Application Gateway SSL profile and trusted certificates
- [ ] Test with `context.Request.Certificate` to confirm it's populated
- [ ] Update policy with actual expected certificate thumbprint(s)
- [ ] Add logging/tracing for troubleshooting
- [ ] Test in dev environment before production
- [ ] Document expected client certificate requirements

---

## Test Validation Points

After implementing fixes, the policy should:
1. ✅ `context.Request.Certificate` should NOT be null
2. ✅ Certificate thumbprint should match expected value
3. ✅ Return 200 OK with certificate details on success
4. ✅ Return 403 with clear error message on failure
