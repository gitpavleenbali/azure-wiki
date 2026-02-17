# MTLS Authentication: Definitive Solution Guide

## Customer: Uniper Energy
## Issue: External API requests through Application Gateway fail with 403 - Client certificate not forwarded to APIM
## Date: January 2026
## Author: Pavleen Bali (CSA)

---

# EXECUTIVE SUMMARY

## The Problem
External clients calling APIs through `gateway-dev.apis.uniper.energy` receive 403 errors because:
1. Application Gateway is NOT configured to request/validate client certificates (MTLS)
2. Server variables for certificate data are NULL (because MTLS isn't enabled)
3. Rewrite rules forward empty headers to APIM
4. APIM's `negotiateClientCertificate` is set to `false`

## The Solution (3 Steps)
1. **Enable Mutual Authentication on Application Gateway** - Upload trusted CA certificate and create SSL profile
2. **Apply SSL Profile to HTTPS Listener** - Configure the gateway-dev listener to use MTLS
3. **Enable Client Certificate Negotiation in APIM** - Set `negotiateClientCertificate: true`

---

# PART 1: ROOT CAUSE ANALYSIS

## Current Architecture Flow (BROKEN)
```
┌─────────────────┐     ┌──────────────────────────────────────────────┐     ┌─────────────────┐
│ External Client │────▶│ Application Gateway                          │────▶│ APIM            │
│ (with cert)     │     │ ❌ sslProfiles: []                            │     │ ❌ negotiate:    │
│                 │     │ ❌ trustedClientCertificates: []              │     │    false        │
│                 │     │ ❌ listener: no SSL profile                   │     │                 │
└─────────────────┘     └──────────────────────────────────────────────┘     └─────────────────┘
                                         │
                                         ▼
                        Server Variables = NULL
                        Headers = NULL
                        APIM context.Request.Certificate = NULL
                        Result: 403 Forbidden
```

## Fixed Architecture Flow (TARGET)
```
┌─────────────────┐     ┌──────────────────────────────────────────────┐     ┌─────────────────┐
│ External Client │────▶│ Application Gateway                          │────▶│ APIM            │
│ (with cert)     │     │ ✅ trustedClientCertificates: [CA cert]       │     │ ✅ negotiate:    │
│                 │     │ ✅ sslProfiles: [mtls-profile]                │     │    true         │
│                 │     │ ✅ listener: references mtls-profile          │     │                 │
└─────────────────┘     └──────────────────────────────────────────────┘     └─────────────────┘
                                         │
                                         ▼
                        Server Variables = POPULATED
                        Headers = Certificate Data
                        APIM context.Request.Certificate = VALID
                        Result: 200 OK
```

## Evidence from Customer Environment

### From Bicep File: APIMHub.bicep (Line ~75)
```bicep
{
  type: 'Proxy'
  hostName: 'gateway-dev.apis.uniper.energy'
  negotiateClientCertificate: false  // ❌ THIS IS THE PROBLEM
  ...
}
```

### From Bicep File: mainAPINW.bicep (Lines 223-224)
```bicep
trustedClientCertificates: []  // ❌ NO TRUSTED CA CERTS
sslProfiles: []                // ❌ NO MTLS PROFILE
```

### From Test Results (Screenshot)
```json
{
  "clientcert": null,
  "clientcertverification": "NONE",
  "clientcertfingerprint": null
}
```
Status Code: 403

---

# PART 2: SOLUTION IMPLEMENTATION

## Prerequisites
- [ ] Client's trusted CA certificate (PEM format, base64 encoded)
- [ ] Access to Application Gateway resource
- [ ] Access to APIM resource
- [ ] Change window approved for dev environment

---

## STEP 1: Upload Trusted Client CA Certificate to Application Gateway

The CA certificate is used to validate that incoming client certificates are trusted.

### Option A: Azure CLI
```bash
# Variables
RG_NAME="APINW-iaas-HUB-rgp-001"
APPGW_NAME="hub-uni-apim-npd-appgwv2-001"
CA_CERT_PATH="./client-ca-certificate.cer"  # Path to CA cert file

# Upload trusted client certificate
az network application-gateway ssl-cert create \
  --resource-group $RG_NAME \
  --gateway-name $APPGW_NAME \
  --name "uniper-client-ca-cert" \
  --cert-file $CA_CERT_PATH
```

### Option B: PowerShell
```powershell
# Variables
$RgName = "APINW-iaas-HUB-rgp-001"
$AppGwName = "hub-uni-apim-npd-appgwv2-001"
$CaCertPath = "C:\certs\client-ca-certificate.cer"

# Get Application Gateway
$AppGw = Get-AzApplicationGateway -ResourceGroupName $RgName -Name $AppGwName

# Read CA certificate and convert to base64
$CaCertBytes = [System.IO.File]::ReadAllBytes($CaCertPath)
$CaCertBase64 = [System.Convert]::ToBase64String($CaCertBytes)

# Add trusted client certificate
Add-AzApplicationGatewayTrustedClientCertificate `
  -ApplicationGateway $AppGw `
  -Name "uniper-client-ca-cert" `
  -CertificateFile $CaCertPath

# Apply changes
Set-AzApplicationGateway -ApplicationGateway $AppGw
```

---

## STEP 2: Create SSL Profile with Mutual Authentication

### Option A: Azure CLI
```bash
# Create SSL profile with client authentication
az network application-gateway ssl-profile add \
  --resource-group $RG_NAME \
  --gateway-name $APPGW_NAME \
  --name "mtls-ssl-profile" \
  --client-auth-configuration verify-client-cert-issuer-dn=true \
  --trusted-client-certificates "uniper-client-ca-cert" \
  --policy-type Predefined \
  --policy-name AppGwSslPolicy20220101S
```

### Option B: PowerShell
```powershell
# Get updated Application Gateway
$AppGw = Get-AzApplicationGateway -ResourceGroupName $RgName -Name $AppGwName

# Get the trusted client certificate reference
$TrustedClientCert = Get-AzApplicationGatewayTrustedClientCertificate `
  -ApplicationGateway $AppGw `
  -Name "uniper-client-ca-cert"

# Create client authentication configuration
$ClientAuthConfig = New-AzApplicationGatewayClientAuthConfiguration `
  -VerifyClientCertIssuerDN

# Create SSL profile with MTLS
Add-AzApplicationGatewaySslProfile `
  -ApplicationGateway $AppGw `
  -Name "mtls-ssl-profile" `
  -SslPolicy (New-AzApplicationGatewaySslPolicy -PolicyType Predefined -PolicyName AppGwSslPolicy20220101S) `
  -TrustedClientCertificate $TrustedClientCert `
  -ClientAuthConfiguration $ClientAuthConfig

# Apply changes
Set-AzApplicationGateway -ApplicationGateway $AppGw
```

---

## STEP 3: Apply SSL Profile to HTTPS Listener

### Option A: Azure CLI
```bash
# Update the gateway-dev listener to use SSL profile
az network application-gateway http-listener update \
  --resource-group $RG_NAME \
  --gateway-name $APPGW_NAME \
  --name "uniperapis-dev-gateway-listener-001" \
  --ssl-profile "mtls-ssl-profile"
```

### Option B: PowerShell
```powershell
# Get updated Application Gateway
$AppGw = Get-AzApplicationGateway -ResourceGroupName $RgName -Name $AppGwName

# Get the SSL profile
$SslProfile = Get-AzApplicationGatewaySslProfile -ApplicationGateway $AppGw -Name "mtls-ssl-profile"

# Get the listener
$Listener = Get-AzApplicationGatewayHttpListener -ApplicationGateway $AppGw -Name "uniperapis-dev-gateway-listener-001"

# Update listener with SSL profile
Set-AzApplicationGatewayHttpListener `
  -ApplicationGateway $AppGw `
  -Name "uniperapis-dev-gateway-listener-001" `
  -FrontendIPConfiguration $Listener.FrontendIPConfiguration `
  -FrontendPort $Listener.FrontendPort `
  -Protocol Https `
  -SslCertificate $Listener.SslCertificate `
  -SslProfile $SslProfile `
  -HostName $Listener.HostName

# Apply changes
Set-AzApplicationGateway -ApplicationGateway $AppGw
```

---

## STEP 4: Enable Client Certificate Negotiation in APIM

### Option A: Azure CLI
```bash
# Variables
APIM_RG="APIM-XaaS-HUB-rgp-002"  # or actual RG
APIM_NAME="uniperapis-dev"

# Update hostname configuration to negotiate client certificates
az apim update \
  --resource-group $APIM_RG \
  --name $APIM_NAME \
  --set hostnameConfigurations[?hostName=='gateway-dev.apis.uniper.energy'].negotiateClientCertificate=true
```

### Option B: PowerShell
```powershell
# Variables
$ApimRgName = "APIM-XaaS-HUB-rgp-002"
$ApimName = "uniperapis-dev"

# Get APIM context
$ApimContext = New-AzApiManagementContext -ResourceGroupName $ApimRgName -ServiceName $ApimName

# Get current hostname configurations
$Apim = Get-AzApiManagement -ResourceGroupName $ApimRgName -Name $ApimName

# Find and update the gateway-dev hostname configuration
foreach ($hostname in $Apim.ProxyCustomHostnameConfiguration) {
    if ($hostname.Hostname -eq "gateway-dev.apis.uniper.energy") {
        $hostname.NegotiateClientCertificate = $true
    }
}

# Apply changes
Set-AzApiManagement -InputObject $Apim
```

### Option C: Azure Portal
1. Navigate to APIM → Custom domains
2. Find `gateway-dev.apis.uniper.energy`
3. Check "Negotiate client certificate"
4. Save

---

## STEP 5: Update/Verify Rewrite Rules (Optional - for header-based approach)

If you want to use the header-based approach as a backup, ensure rewrite rules are correctly configured:

```bash
# Create rewrite rule set for certificate headers
az network application-gateway rewrite-rule set create \
  --resource-group $RG_NAME \
  --gateway-name $APPGW_NAME \
  --name "mtls-headers-rewrite"

# Add rule to forward client certificate
az network application-gateway rewrite-rule create \
  --resource-group $RG_NAME \
  --gateway-name $APPGW_NAME \
  --rule-set-name "mtls-headers-rewrite" \
  --name "forward-client-cert" \
  --request-headers "X-Client-Cert={var_client_certificate}" \
  --request-headers "X-Client-Cert-Fingerprint={var_client_certificate_fingerprint}" \
  --request-headers "X-Client-Cert-Verification={var_client_certificate_verification}"
```

---

# PART 3: VERIFICATION

## Test 1: Verify Application Gateway Configuration

```powershell
# Check trusted client certificates
$AppGw = Get-AzApplicationGateway -ResourceGroupName $RgName -Name $AppGwName
$AppGw.TrustedClientCertificates | Format-List

# Check SSL profiles
$AppGw.SslProfiles | Format-List

# Check listener has SSL profile
$AppGw.HttpListeners | Where-Object {$_.Name -like "*gateway-dev*"} | Format-List
```

Expected output:
- TrustedClientCertificates: Should show the CA cert
- SslProfiles: Should show mtls-ssl-profile
- HttpListener SslProfile: Should reference mtls-ssl-profile

## Test 2: Verify APIM Configuration

```powershell
# Check APIM hostname configuration
$Apim = Get-AzApiManagement -ResourceGroupName $ApimRgName -Name $ApimName
$Apim.ProxyCustomHostnameConfiguration | Where-Object {$_.Hostname -like "*gateway-dev*"} | Format-List
```

Expected output:
- NegotiateClientCertificate: True

## Test 3: API Call Test with Client Certificate

### Using curl
```bash
curl -v \
  --cert client-certificate.pfx:password \
  --cert-type P12 \
  https://gateway-dev.apis.uniper.energy/api/ex/ennea-api-external/v1.0/ProcessSVAMeterReadings
```

### Using PowerShell
```powershell
$CertPath = "C:\certs\client-certificate.pfx"
$CertPassword = ConvertTo-SecureString -String "password" -Force -AsPlainText
$Cert = Get-PfxCertificate -FilePath $CertPath -Password $CertPassword

$Response = Invoke-RestMethod `
  -Uri "https://gateway-dev.apis.uniper.energy/api/ex/ennea-api-external/v1.0/ProcessSVAMeterReadings" `
  -Certificate $Cert `
  -Method GET

$Response
```

### Using Python (Customer's test script)
```python
import requests

url = "https://gateway-dev.apis.uniper.energy/api/ex/ennea-api-external/v1.0/ProcessSVAMeterReadings"
cert_path = "C:/certs/client-certificate.pfx"
cert_password = "password"

response = requests.get(
    url,
    cert=(cert_path, cert_password),
    verify=True
)

print(f"Status Code: {response.status_code}")
print(f"Response: {response.json()}")
```

Expected output after fix:
```json
{
  "Thumbprint": "ABC123DEF456..."
}
```
Status Code: 200

---

# PART 4: ROLLBACK PLAN

If issues occur, rollback in reverse order:

## Rollback Step 1: APIM
```powershell
# Set negotiateClientCertificate back to false
foreach ($hostname in $Apim.ProxyCustomHostnameConfiguration) {
    if ($hostname.Hostname -eq "gateway-dev.apis.uniper.energy") {
        $hostname.NegotiateClientCertificate = $false
    }
}
Set-AzApiManagement -InputObject $Apim
```

## Rollback Step 2: Application Gateway Listener
```powershell
$AppGw = Get-AzApplicationGateway -ResourceGroupName $RgName -Name $AppGwName
$Listener = Get-AzApplicationGatewayHttpListener -ApplicationGateway $AppGw -Name "uniperapis-dev-gateway-listener-001"

# Remove SSL profile from listener
Set-AzApplicationGatewayHttpListener `
  -ApplicationGateway $AppGw `
  -Name "uniperapis-dev-gateway-listener-001" `
  -FrontendIPConfiguration $Listener.FrontendIPConfiguration `
  -FrontendPort $Listener.FrontendPort `
  -Protocol Https `
  -SslCertificate $Listener.SslCertificate `
  -SslProfile $null `
  -HostName $Listener.HostName

Set-AzApplicationGateway -ApplicationGateway $AppGw
```

## Rollback Step 3: Remove SSL Profile
```powershell
$AppGw = Get-AzApplicationGateway -ResourceGroupName $RgName -Name $AppGwName
Remove-AzApplicationGatewaySslProfile -ApplicationGateway $AppGw -Name "mtls-ssl-profile"
Set-AzApplicationGateway -ApplicationGateway $AppGw
```

## Rollback Step 4: Remove Trusted Client Certificate
```powershell
$AppGw = Get-AzApplicationGateway -ResourceGroupName $RgName -Name $AppGwName
Remove-AzApplicationGatewayTrustedClientCertificate -ApplicationGateway $AppGw -Name "uniper-client-ca-cert"
Set-AzApplicationGateway -ApplicationGateway $AppGw
```

---

# PART 5: UPDATED APIM POLICY

After implementing the infrastructure changes, update the APIM policy:

```xml
<policies>
    <inbound>
        <base />
        <!-- Remove subscription key since using certificate auth -->
        <set-header name="Ocp-Apim-Subscription-Key" exists-action="delete" />
        
        <!-- Check for client certificate -->
        <choose>
            <when condition="@(context.Request.Certificate == null)">
                <!-- No certificate provided -->
                <return-response>
                    <set-status code="403" reason="Client certificate required" />
                    <set-header name="Content-Type" exists-action="override">
                        <value>application/json</value>
                    </set-header>
                    <set-body>{"error": "Client certificate is required for this API"}</set-body>
                </return-response>
            </when>
            <when condition="@(context.Request.Certificate.Thumbprint != "EXPECTED_THUMBPRINT_HERE")">
                <!-- Certificate provided but thumbprint doesn't match -->
                <return-response>
                    <set-status code="403" reason="Invalid certificate" />
                    <set-header name="Content-Type" exists-action="override">
                        <value>application/json</value>
                    </set-header>
                    <set-body>@{
                        return new JObject(
                            new JProperty("error", "Certificate thumbprint mismatch"),
                            new JProperty("providedThumbprint", context.Request.Certificate.Thumbprint)
                        ).ToString();
                    }</set-body>
                </return-response>
            </when>
            <otherwise>
                <!-- Valid certificate - proceed -->
                <set-header name="X-Certificate-Valid" exists-action="override">
                    <value>true</value>
                </set-header>
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

# PART 6: CHECKLIST FOR CUSTOMER

## Pre-Implementation
- [ ] Obtain client CA certificate from the external API client (Ennea)
- [ ] Schedule change window with all teams using dev environment
- [ ] Notify Mohamed and Priyanka of planned changes
- [ ] Prepare rollback scripts
- [ ] Backup current Application Gateway configuration

## Implementation
- [ ] Step 1: Upload trusted CA certificate to Application Gateway
- [ ] Step 2: Create SSL profile with mutual authentication
- [ ] Step 3: Apply SSL profile to gateway-dev listener
- [ ] Step 4: Enable negotiateClientCertificate in APIM
- [ ] Step 5: Update APIM policy with certificate validation

## Verification
- [ ] Verify Application Gateway shows trusted client certificate
- [ ] Verify SSL profile is configured correctly
- [ ] Verify listener references SSL profile
- [ ] Verify APIM negotiateClientCertificate is true
- [ ] Test API call with client certificate
- [ ] Confirm 200 response with certificate thumbprint

## Post-Implementation
- [ ] Document changes made
- [ ] Update runbook with new configuration
- [ ] Share success evidence with Microsoft CSA (Pavleen)
- [ ] Plan production deployment

---

# APPENDIX A: Key Azure Documentation References

1. **Application Gateway Mutual Authentication Overview**
   - https://learn.microsoft.com/en-us/azure/application-gateway/mutual-authentication-overview

2. **Rewrite HTTP Headers - Mutual Authentication Server Variables**
   - https://learn.microsoft.com/en-us/azure/application-gateway/rewrite-http-headers-url#mutual-authentication-server-variables

3. **APIM Client Certificate Authentication**
   - https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-mutual-certificates-for-clients

---

# APPENDIX B: Server Variables Available After MTLS Enabled

| Variable | Description |
|----------|-------------|
| `{var_client_certificate}` | Base64-encoded client certificate |
| `{var_client_certificate_fingerprint}` | SHA1 fingerprint of client certificate |
| `{var_client_certificate_issuer}` | Certificate issuer DN |
| `{var_client_certificate_serial}` | Certificate serial number |
| `{var_client_certificate_subject}` | Certificate subject DN |
| `{var_client_certificate_verification}` | Verification status (SUCCESS, FAILED, NONE) |
| `{var_client_certificate_start_date}` | Certificate validity start date |
| `{var_client_certificate_end_date}` | Certificate expiry date |

---

**Document Version:** 1.0
**Last Updated:** January 23, 2026
**Status:** Ready for Validation
