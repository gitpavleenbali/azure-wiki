# MTLS Solution Implementation Guide
**Created:** January 23, 2026  
**Customer:** Uniper  
**Issue:** Mutual TLS Authentication between Application Gateway and APIM  
**Status:** Ready for Implementation

---

## Executive Summary

### Problem
External API requests through Application Gateway fail with 403 errors because:
1. **Application Gateway** doesn't request/capture client certificates (no SSL profile configured)
2. **Server variables** cannot populate certificate data (prerequisites not met)
3. **APIM** is not configured to negotiate client certificates (negotiateClientCertificate = false)
4. **Rewrite rules** return NULL header values (no source data from App Gateway)

### Root Cause
All three components are misconfigured as a system. The issue is NOT with the policy logic but with infrastructure configuration.

### Solution
Implement MTLS PASSTHROUGH mode on Application Gateway with the following changes:

1. **Application Gateway:** Create SSL profile, enable certificate capture via listener
2. **APIM:** Enable `negotiateClientCertificate = true`
3. **Policy:** Update to validate certificates from both native context and headers
4. **Rewrite Rules:** Already correct, but now will have data to populate

### Expected Outcome
✅ External clients can authenticate via client certificates  
✅ App Gateway captures and forwards certificate data  
✅ APIM validates certificate thumbprint  
✅ Invalid certificates rejected with 403  
✅ Valid certificates allowed through  

---

## Solution Components

### 1. Application Gateway Bicep Changes (mainAPINW.bicep)

#### Change 1.1: Add SSL Profile with MTLS Passthrough Configuration

**Location:** After `trustedClientCertificates: []` section (around line 224)

Replace:
```bicep
    trustedClientCertificates: []
    sslProfiles: []
```

With:
```bicep
    trustedClientCertificates: []
    sslProfiles: [
      {
        name: 'mtls-passthrough-profile'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslProfiles/mtls-passthrough-profile'
        properties: {
          clientAuthConfiguration: {
            verifyClientCertIssuerDN: false
            verifyClientRevocation: 'None'
          }
          tlsPolicy: 'AppGwSSLPolicy20170401S'
          minProtocolVersion: 'TLSv1_2'
        }
      }
    ]
```

**Why This Works:**
- Enables certificate capture during TLS handshake
- Allows connection regardless of certificate validity (PASSTHROUGH)
- Populates server variables with certificate data
- Backend (APIM) handles actual validation

---

#### Change 1.2: Update Gateway Dev Listener to Use SSL Profile

**Location:** Find the listener `uniperapis-dev-gateway-listener-001` (around line 531-551)

Replace:
```bicep
        {
          name: 'uniperapis-dev-gateway-listener-001'
          id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/uniperapis-dev-gateway-listener-001'
          properties: {
            frontendIPConfiguration: {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
            }
            frontendPort: {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendPorts/port_443'
            }
            protocol: 'Https'
            sslCertificate: {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/gateway-dev.apis.uniper.energy_26Feb2026'
            }
          }
        }
```

With:
```bicep
        {
          name: 'uniperapis-dev-gateway-listener-001'
          id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/uniperapis-dev-gateway-listener-001'
          properties: {
            frontendIPConfiguration: {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
            }
            frontendPort: {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendPorts/port_443'
            }
            protocol: 'Https'
            sslCertificate: {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/gateway-dev.apis.uniper.energy_26Feb2026'
            }
            sslProfile: {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslProfiles/mtls-passthrough-profile'
            }
          }
        }
```

**Note:** Apply same change to other gateway listeners:
- `uniperapis-uat-gateway-listener-001` (add sslProfile reference)
- Any other gateway listener used for external API access

---

### 2. APIM Bicep Changes (APIMHub.bicep)

#### Change 2.1: Enable Client Certificate Negotiation for Gateway Proxy

**Location:** Find the `gateway-dev.apis.uniper.energy` proxy hostname configuration (around line 103-116)

Replace:
```bicep
      {
        type: 'Proxy'
        hostName: 'gateway-dev.apis.uniper.energy'
        keyVaultId: 'https://${service_uniperapis_dev_name}-kv-001.vault.azure.net/secrets/gateway-dev'
        negotiateClientCertificate: false
        certificate: {
          expiry: '2026-02-25T23:59:59+00:00'
          thumbprint: '7E8388A95EC32D1B26290031A62417538C70D576'
          subject: 'CN=gateway-dev.apis.uniper.energy, O=Uniper SE, L=Düsseldorf, S=Nordrhein-Westfalen, C=DE'
        }
        defaultSslBinding: true
        certificateSource: 'KeyVault'
      }
```

With:
```bicep
      {
        type: 'Proxy'
        hostName: 'gateway-dev.apis.uniper.energy'
        keyVaultId: 'https://${service_uniperapis_dev_name}-kv-001.vault.azure.net/secrets/gateway-dev'
        negotiateClientCertificate: true
        certificate: {
          expiry: '2026-02-25T23:59:59+00:00'
          thumbprint: '7E8388A95EC32D1B26290031A62417538C70D576'
          subject: 'CN=gateway-dev.apis.uniper.energy, O=Uniper SE, L=Düsseldorf, S=Nordrhein-Westfalen, C=DE'
        }
        defaultSslBinding: true
        certificateSource: 'KeyVault'
      }
```

**Change:** `negotiateClientCertificate: false` → `true`

**Effect:**
- APIM will request client certificates from clients
- `context.Request.Certificate` will be populated
- Policy can now access native certificate context

---

#### Change 2.2 (Optional): Apply Same to UAT Gateway

Find `gateway-uat.apis.uniper.energy` hostname and apply same change if needed.

---

### 3. APIM Policy Update

The existing policy in your system is mostly correct. However, update it with this enhanced version that handles both native context and header fallback:

**Updated Inbound Policy:**
```xml
<inbound>
    <base />
    
    <!-- Remove subscription key header -->
    <set-header name="Ocp-Apim-Subscription-Key" exists-action="delete" />
    
    <!-- Attempt 1: Use native certificate context (primary method) -->
    <choose>
        <when condition="@(context.Request.Certificate != null)">
            <!-- Certificate received via APIM's TLS negotiation -->
            <set-variable name="certThumbprint" value="@(context.Request.Certificate.Thumbprint)" />
            <set-variable name="certSource" value="native" />
        </when>
        <otherwise>
            <!-- Attempt 2: Use certificate data from App Gateway headers (fallback) -->
            <set-variable name="certFingerprint" value="@(context.Request.Headers.GetValueOrDefault("X-Client-Cert-Fingerprint", ""))" />
            
            <choose>
                <when condition="@(!string.IsNullOrEmpty((string)context.Variables["certFingerprint"]))">
                    <set-variable name="certThumbprint" value="@((string)context.Variables["certFingerprint"])" />
                    <set-variable name="certSource" value="header" />
                </when>
                <otherwise>
                    <!-- No certificate from either source -->
                    <return-response>
                        <set-status code="403" reason="Forbidden" />
                        <set-body>@{
                            return new JObject(
                                new JProperty("error", "Client certificate required"),
                                new JProperty("details", "No client certificate provided in request")
                            ).ToString();
                        }</set-body>
                    </return-response>
                </otherwise>
            </choose>
        </otherwise>
    </choose>
    
    <!-- Validate thumbprint against expected value(s) -->
    <set-variable name="expectedThumbprint" value="EXPECTED_THUMBPRINT_HERE" />
    
    <choose>
        <when condition="@((string)context.Variables["certThumbprint"] == (string)context.Variables["expectedThumbprint"])">
            <!-- Valid certificate - allow request to proceed -->
        </when>
        <otherwise>
            <!-- Invalid certificate thumbprint -->
            <return-response>
                <set-status code="403" reason="Forbidden" />
                <set-body>@{
                    return new JObject(
                        new JProperty("error", "Invalid client certificate"),
                        new JProperty("details", "Certificate thumbprint does not match expected value"),
                        new JProperty("received", (string)context.Variables["certThumbprint"]),
                        new JProperty("certSource", (string)context.Variables["certSource"])
                    ).ToString();
                }</set-body>
            </return-response>
        </otherwise>
    </choose>
</inbound>
```

**Key Updates:**
1. Dual certificate validation (native first, headers as fallback)
2. Better error messages with certificate source info
3. Thumbprint validation logic
4. Logging of certificate source for debugging

---

### 4. Application Gateway Rewrite Rules

**Current rewrite rules (should already exist):**
```bicep
// These should already be in your requestRoutingRules
{
  name: 'Add-Client-Cert-Headers'
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

**Status:** No changes needed - these rules will now work because server variables will be populated

---

## Implementation Checklist

### Pre-Deployment
- [ ] Backup current Bicep files
- [ ] Document current APIM configuration
- [ ] Document expected client certificate thumbprints
- [ ] Notify operations team of upcoming changes
- [ ] Prepare rollback plan
- [ ] Schedule change window (off-peak hours)

### Deployment Steps
- [ ] Update mainAPINW.bicep (Application Gateway):
  - [ ] Add SSL profile with PASSTHROUGH configuration
  - [ ] Add sslProfile reference to gateway dev listener
  - [ ] Add sslProfile reference to gateway uat listener (if applicable)
- [ ] Update APIMHub.bicep (APIM):
  - [ ] Change `negotiateClientCertificate: false` → `true` for gateway-dev
  - [ ] Change `negotiateClientCertificate: false` → `true` for gateway-uat (if applicable)
- [ ] Update APIM Policy:
  - [ ] Deploy updated inbound policy with dual validation
  - [ ] Set expected thumbprint value (replace EXPECTED_THUMBPRINT_HERE)
- [ ] Deploy Bicep changes to development environment first
- [ ] Run deployment validation

### Post-Deployment Testing
- [ ] Test without client certificate → Verify 403 response
- [ ] Test with valid client certificate → Verify 200 response
- [ ] Test with invalid certificate → Verify 403 response
- [ ] Check Application Gateway logs for certificate capture
- [ ] Check APIM policy execution logs
- [ ] Verify certificate thumbprint matches across all layers
- [ ] Performance testing (ensure no significant latency increase)

### Validation Tests

#### Test 1: No Certificate (Should Fail)
```powershell
$uri = "https://gateway-dev.apis.uniper.energy/api/ex/ennea-api-external/v1.0/ProcessSVAMeterReadings"
$response = Invoke-WebRequest -Uri $uri -Method Get
# Expected: 403 Forbidden with error "Client certificate required"
```

#### Test 2: Valid Certificate (Should Succeed)
```powershell
$cert = Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object { $_.Thumbprint -eq "EXPECTED_THUMBPRINT_HERE" }
$response = Invoke-WebRequest -Uri $uri -Method Get -Certificate $cert
# Expected: 200 OK (or appropriate success response from backend)
```

#### Test 3: Invalid Certificate (Should Fail)
```powershell
$invalidCert = Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object { $_.Thumbprint -ne "EXPECTED_THUMBPRINT_HERE" } | Select-Object -First 1
$response = Invoke-WebRequest -Uri $uri -Method Get -Certificate $invalidCert
# Expected: 403 Forbidden with error "Invalid client certificate"
```

---

## Rollback Plan

If issues occur during testing:

### Quick Rollback (< 5 minutes)
```powershell
# Revert APIM setting to disable certificate negotiation
# In APIMHub.bicep, change:
# negotiateClientCertificate: true → false

# Redeploy APIM bicep file
az deployment group create `
  -g "APIM-XaaS-HUB-rgp-002" `
  -f APIMHub.bicep `
  --parameters parameters.json

# This allows API to work without certificates again (current state)
```

### Full Rollback
```powershell
# Restore all files from backup and redeploy:
git checkout -- mainAPINW.bicep APIMHub.bicep
az deployment group create -g "APINW-iaas-HUB-rgp-001" -f mainAPINW.bicep
az deployment group create -g "APIM-XaaS-HUB-rgp-002" -f APIMHub.bicep

# This restores the original configuration
```

---

## Certificate Thumbprint Configuration

### How to Get Expected Thumbprint

**Option 1: From PFX/Certificate File**
```powershell
$cert = Get-PfxCertificate -FilePath "C:\path\to\certificate.pfx"
$cert.Thumbprint
# Output: 7E8388A95EC32D1B26290031A62417538C70D576
```

**Option 2: From Certificate Store**
```powershell
Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object { $_.Subject -match "client-cert-name" } | Select-Object Thumbprint
```

**Option 3: From Certificate File (PowerShell)**
```powershell
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("C:\path\to\cert.cer")
$cert.Thumbprint
```

### Update Policy with Actual Thumbprint
In the policy, replace:
```xml
<set-variable name="expectedThumbprint" value="EXPECTED_THUMBPRINT_HERE" />
```

With actual thumbprint (example):
```xml
<set-variable name="expectedThumbprint" value="7E8388A95EC32D1B26290031A62417538C70D576" />
```

---

## Troubleshooting Guide

### Issue 1: Still Getting 403 After Deployment

**Diagnostic Steps:**
1. Check APIM policy execution trace
   - Enable diagnostics: Settings → Diagnostics logging
   - Look for certificate source (native vs header)
   - Verify thumbprint is being captured

2. Check Application Gateway logs
   - Look for certificate capture in diagnostic logs
   - Verify listener is using SSL profile
   - Check if server variables are populated

3. Verify APIM configuration
   ```powershell
   $service = Get-AzApiManagement -ResourceGroupName "APIM-XaaS-HUB-rgp-002" -Name "uniperapis-dev"
   $service.HostnameConfigurations | Where-Object { $_.HostName -eq "gateway-dev.apis.uniper.energy" } | Select-Object NegotiateClientCertificate
   # Should show: True
   ```

---

### Issue 2: Certificate Data Not in Headers

**Diagnostic Steps:**
1. Verify SSL profile is attached to listener:
   ```powershell
   $appgw = Get-AzApplicationGateway -ResourceGroupName "APINW-iaas-HUB-rgp-001" -Name "hub-uni-apim-npd-appgwv2-001"
   $appgw.HttpListeners | Where-Object { $_.Name -eq "uniperapis-dev-gateway-listener-001" } | Select-Object SslProfile
   # Should show profile reference, not empty
   ```

2. Check if listener is requesting certificate:
   - In Azure Portal, navigate to listener settings
   - Verify "Client authentication" is enabled

3. Monitor rewrite rule execution:
   - Enable rule tracing in diagnostic logs
   - Check if variables are being populated

---

### Issue 3: Thumbprint Mismatch

**Diagnostic Steps:**
1. Capture actual thumbprint from logs
   - Check APIM policy output
   - Compare with expected value in policy

2. Verify certificate being used by client
   ```powershell
   $cert = Get-Item -Path "Cert:\CurrentUser\My\THUMBPRINT_HERE"
   $cert | Select-Object Thumbprint, Subject, Issuer, NotBefore, NotAfter
   ```

3. Update policy with correct thumbprint:
   - Ensure no spaces or case mismatches
   - Thumbprints are case-insensitive but good practice to be consistent

---

## Success Criteria

After implementation, the following should be true:

✅ External clients can authenticate using client certificates  
✅ Application Gateway captures certificate during TLS handshake  
✅ Server variables populate with certificate data  
✅ Rewrite rules add headers with valid certificate info  
✅ APIM receives both native certificate context and header data  
✅ Policy validates certificate thumbprint  
✅ Valid certificates allowed (200 OK)  
✅ Invalid/missing certificates rejected (403 Forbidden)  
✅ Error messages are clear and helpful  
✅ Logs contain sufficient diagnostic information  

---

## References

- Microsoft Docs: [Overview of mutual authentication with Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/mutual-authentication-overview)
- Microsoft Docs: [Configure Application Gateway with mutual authentication using ARM Template](https://learn.microsoft.com/en-us/azure/application-gateway/mutual-authentication-arm-template)
- Microsoft Docs: [Mutual authentication server variables](https://learn.microsoft.com/en-us/azure/application-gateway/rewrite-http-headers-url#mutual-authentication-server-variables)
- API Version: 2025-03-01 (for latest MTLS features)
- SKU Requirement: WAF_v2 (your current setup ✓)

---

**Document Status:** Ready for Implementation  
**Next Step:** Review with customer and proceed with deployment in dev environment
