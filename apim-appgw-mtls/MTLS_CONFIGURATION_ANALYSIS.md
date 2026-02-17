# MTLS Authentication Issue - Configuration Analysis

## Executive Summary
The mutual TLS (MTLS) authentication is failing for external requests through Application Gateway because:
1. **MTLS pass-through is not enabled** on the Application Gateway
2. **SSL profiles are empty** - no MTLS configuration defined
3. **Trusted client certificates are not configured** - empty array
4. **Server variable rewrites cannot work** because the Application Gateway doesn't have the certificate data to rewrite

---

## Current Configuration Issues

### 1. Application Gateway (mainAPINW.bicep)

#### **Problem 1: Empty SSL Profiles**
```bicep
sslProfiles: []
```
- **Line:** 224
- **Impact:** No MTLS policy is defined for the gateway
- **Current State:** The gateway is not configured to handle MTLS pass-through

#### **Problem 2: No Trusted Client Certificates**
```bicep
trustedClientCertificates: []
```
- **Line:** 223
- **Impact:** Even if MTLS pass-through were enabled, there are no trusted certificates defined
- **Expected:** Should contain the client certificate(s) that APIM will present or that external clients will present

#### **Problem 3: HTTP Listeners Without MTLS**
```bicep
httpListeners: [
  {
    id: '${...}/httpListeners/uniperapis-dev-gateway-listener-001'
    // ... no sslProfile or MTLS configuration
  }
]
```
- The gateway listener for `gateway-dev.apis.uniper.energy` does NOT reference any SSL profile
- Cannot force certificate negotiation on requests

### 2. API Management (APIMHub.bicep)

#### **Observation: Client Certificate Negotiation Disabled**
```bicep
hostnameConfigurations: [
  {
    type: 'Proxy'
    hostName: 'gateway-dev.apis.uniper.energy'
    negotiateClientCertificate: false  // <-- This is the problem!
    // ...
  }
]
```
- **Impact:** APIM is not requesting client certificates from incoming requests
- **Root Cause:** The hostname is configured with `negotiateClientCertificate: false`
- **Why it's failing:** Even if the Application Gateway forwarded certificates, APIM wouldn't process them because negotiation is disabled

---

## Why Current Rewrite Rules Don't Work

The team attempted to use server variable rewrites:
```
X-Client-Cert-Fingerprint: {var_client_certificate_fingerprint}
X-Client-Cert-Verification: {var_client_certificate_verification}
X-Client-Cert: {var_client_certificate}
```

**Why they return NULL:**
- Application Gateway server variables like `{var_client_certificate_*}` are ONLY populated when:
  1. An SSL profile with MTLS is defined and applied to the listener
  2. The listener is configured to request/require client certificates
  3. The client sends a certificate in the TLS handshake

**Since neither of these is true, the variables are empty → headers are set to empty values → APIM receives null → 403 error**

---

## Required Changes

### Step 1: Enable Client Certificate Negotiation in APIM
```bicep
hostnameConfigurations: [
  {
    type: 'Proxy'
    hostName: 'gateway-dev.apis.uniper.energy'
    negotiateClientCertificate: true  // <-- Change from false to true
    certificateSource: 'KeyVault'
    // ... rest of config
  }
]
```

### Step 2: Configure MTLS on Application Gateway Listener

#### Option A: Using SSL Profile (Recommended for November 2025+ feature)
```bicep
sslProfiles: [
  {
    name: 'mtls-profile'
    properties: {
      clientAuthConfiguration: {
        verifyClientCertIssuerDN: true
        verifyClientRevocation: 'OCSP'  // or 'CRL' depending on your setup
      }
      tlsPolicy: 'AppGwSSLPolicy20170401S'  // or newer policy
      minProtocolVersion: 'TLSv1_2'
    }
  }
]
```

#### Option B: Trusted Client Certificates
```bicep
trustedClientCertificates: [
  {
    name: 'client-ca-cert'
    properties: {
      data: '<Base64-encoded certificate>'
    }
  }
]
```

### Step 3: Apply SSL Profile to HTTP Listener
```bicep
httpListeners: [
  {
    name: 'uniperapis-dev-gateway-listener-001'
    properties: {
      // ... other properties
      sslProfile: {
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslProfiles/mtls-profile'
      }
    }
  }
]
```

### Step 4: Update Backend HTTP Settings (if needed)
Ensure the backend settings for APIM match:
```bicep
backendHttpSettingsCollection: [
  {
    name: 'uniperapis-dev-gateway-HttpSettings-001'
    properties: {
      port: 443
      protocol: 'Https'
      cookieBasedAffinity: 'Disabled'
      // If APIM also needs client cert for backend connection:
      clientAuthConfiguration: {
        enabled: true
      }
    }
  }
]
```

---

## Data Flow After Fix

```
External Client
    ↓ (with client cert in TLS handshake)
Application Gateway (with MTLS SSL Profile)
    ↓ (verifies client cert, populates {var_client_certificate_*})
Rewrite Rules
    ↓ (adds headers with certificate data)
APIM (negotiateClientCertificate: true)
    ↓ (receives certificate, validates fingerprint)
Policy Check
    ↓ (if thumbprint matches → allow)
Backend Service
```

---

## Verification Steps

1. **Check APIM negotiateClientCertificate setting:**
   ```powershell
   $service = Get-AzApiManagement -ResourceGroupName "rg-name" -Name "uniperapis-dev"
   $service.HostnameConfigurations | Where-Object {$_.HostName -like "gateway-dev*"}
   ```

2. **Check Application Gateway SSL Profiles:**
   ```powershell
   $appgw = Get-AzApplicationGateway -ResourceGroupName "rg-name" -Name "hub-uni-apim-npd-appgwv2-001"
   $appgw.SslProfiles
   ```

3. **Verify Listener Configuration:**
   ```powershell
   $appgw.HttpListeners | Where-Object {$_.Name -like "*gateway*"}
   ```

---

## November 2025 Azure Feature Reference

Azure launched **MTLS pass-through mode** on Application Gateway (November 2025) which allows:
- Automatic certificate forwarding from client to backend
- No need for manual rewrite rules
- Simplified configuration through SSL profiles and listener settings

**To Enable:**
- Set `clientAuthConfiguration` in SSL profile
- Reference profile in HTTP listener
- APIM must have `negotiateClientCertificate: true`

---

## Testing Checklist

- [ ] Enable `negotiateClientCertificate: true` in APIM for gateway-dev hostname
- [ ] Create SSL profile with MTLS configuration in App Gateway
- [ ] Add trusted client certificate(s) to App Gateway if needed
- [ ] Apply SSL profile to gateway listener
- [ ] Test with client certificate in dev environment
- [ ] Verify certificate is received by APIM (check logs for thumbprint match)
- [ ] Plan rollback strategy
- [ ] Document changes for operations team
