# MTLS PASSTHROUGH Solution Guide
## Single Listener Approach - No APIM Certificate Negotiation Change Required

**Customer:** Uniper Energy  
**Date:** February 16, 2026  
**Author:** Pavleen Bali, Cloud Solution Architect, Microsoft  
**Solution Type:** PASSTHROUGH Mode (Header-based validation only)

---

## Executive Summary

This document provides an alternative MTLS solution that addresses the following customer constraints:

| Constraint | Original Solution | PASSTHROUGH Solution |
|------------|------------------|---------------------|
| Multiple Listeners | Required new listener | ✅ Uses EXISTING listener |
| `negotiateClientCertificate=true` | Required | ✅ NOT required (keep `false`) |
| Impact on all clients | All clients affected | ✅ Selective validation via APIM policy |

### Why This Works

The PASSTHROUGH mode in Application Gateway:
1. **Captures** client certificates during TLS handshake
2. **Does NOT reject** connections without certificates (non-mandatory)
3. **Populates** server variables with certificate data (when provided)
4. **Forwards** certificate data to APIM via rewrite headers
5. **APIM validates** using headers only (no native TLS negotiation needed)

This approach allows:
- MTLS clients to be validated via certificate headers
- Non-MTLS clients to connect normally (policy decides access)
- Single listener for both client types
- No change to APIM `negotiateClientCertificate` setting

---

## Solution Architecture

### Current State (BROKEN)
```
┌─────────────────┐     ┌──────────────────────────────────────────────┐     ┌─────────────────┐
│ External Client │────▶│ Application Gateway                          │────▶│ APIM            │
│ (with cert)     │     │ ❌ sslProfiles: []                            │     │ negotiate:false │
│                 │     │ ❌ No SSL Profile on listener                 │     │ (stays false)   │
│                 │     │ ❌ Server variables = NULL                    │     │                 │
└─────────────────┘     └──────────────────────────────────────────────┘     └─────────────────┘
                                         │
                                         ▼
                        Rewrite Headers = NULL
                        APIM policy fails → 403 Forbidden
```

### Target State (PASSTHROUGH)
```
┌─────────────────┐     ┌──────────────────────────────────────────────┐     ┌─────────────────┐
│ External Client │────▶│ Application Gateway                          │────▶│ APIM            │
│ (with cert)     │     │ ✅ SSL Profile (PASSTHROUGH mode)             │     │ negotiate:false │
│                 │     │ ✅ Listener references SSL Profile            │     │ (NO CHANGE)     │
│                 │     │ ✅ Server variables POPULATED                 │     │                 │
└─────────────────┘     └──────────────────────────────────────────────┘     └─────────────────┘
                                         │
                                         ▼
                        Rewrite Headers contain certificate data:
                        - X-Client-Cert-Fingerprint: <thumbprint>
                        - X-Client-Cert-Verification: SUCCESS
                        - X-Client-Cert: <PEM certificate>
                                         │
                                         ▼
                        APIM policy validates via headers → 200 OK
```

---

## Key Difference: PASSTHROUGH vs STRICT Mode

| Feature | PASSTHROUGH Mode | STRICT Mode |
|---------|-----------------|-------------|
| Certificate Validation | Performed by APIM policy | Performed by App Gateway |
| Trusted CA Upload | NOT required | Required |
| Connection without cert | Allowed (policy decides) | Rejected (400 error) |
| Invalid cert handling | Policy returns 403 | Gateway returns 400 |
| Flexibility | High (policy-based rules) | Low (gateway enforces) |
| Best for | Selective MTLS validation | Mandatory MTLS |

**Why PASSTHROUGH is ideal for your case:**
- You want MTLS for SOME clients (external APIs) but not ALL
- You don't want to upload CA certificates to App Gateway
- You want APIM policy to control validation logic
- You need flexibility to adjust validation rules

---

## Implementation Requirements

### Prerequisites
- [ ] Access to Application Gateway resource
- [ ] API Version `2023-09-01` or later (PASSTHROUGH support)
- [ ] Change approval for development environment
- [ ] Valid client certificate for testing

### What Changes
| Component | Change |
|-----------|--------|
| Application Gateway | Add SSL Profile with PASSTHROUGH configuration |
| Existing Listener | Add reference to SSL Profile (in-place update) |
| APIM | **NO CHANGE** - keep `negotiateClientCertificate: false` |
| APIM Policy | Update to validate certificate via headers |

---

## ARM Template Implementation

### Option 1: Incremental ARM Template (Recommended)

Create a file `mtls-passthrough-update.json`:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "applicationGatewayName": {
      "type": "string",
      "defaultValue": "hub-uni-apim-npd-appgwv2-001",
      "metadata": {
        "description": "Name of the Application Gateway"
      }
    },
    "resourceGroupName": {
      "type": "string",
      "defaultValue": "APINW-iaas-HUB-rgp-001",
      "metadata": {
        "description": "Resource group containing the Application Gateway"
      }
    },
    "listenerName": {
      "type": "string",
      "defaultValue": "uniperapis-dev-gateway-listener-001",
      "metadata": {
        "description": "Name of the HTTPS listener to update"
      }
    },
    "sslProfileName": {
      "type": "string",
      "defaultValue": "mtls-passthrough-profile",
      "metadata": {
        "description": "Name for the new SSL profile"
      }
    }
  },
  "variables": {
    "appGwId": "[resourceId('Microsoft.Network/applicationGateways', parameters('applicationGatewayName'))]"
  },
  "resources": [],
  "outputs": {
    "sslProfileConfiguration": {
      "type": "object",
      "value": {
        "name": "[parameters('sslProfileName')]",
        "properties": {
          "clientAuthConfiguration": {
            "verifyClientCertIssuerDN": false,
            "verifyClientRevocation": "None"
          },
          "sslPolicy": {
            "policyType": "Predefined",
            "policyName": "AppGwSslPolicy20220101S"
          }
        }
      }
    },
    "listenerSslProfileReference": {
      "type": "object",
      "value": {
        "sslProfile": {
          "id": "[concat(variables('appGwId'), '/sslProfiles/', parameters('sslProfileName'))]"
        }
      }
    }
  }
}
```

### Option 2: PowerShell Script for ARM Deployment

Create a file `Deploy-MtlsPassthrough.ps1`:

```powershell
<#
.SYNOPSIS
    Deploys MTLS PASSTHROUGH configuration to Application Gateway using ARM API

.DESCRIPTION
    This script:
    1. Gets current Application Gateway configuration
    2. Adds SSL Profile with PASSTHROUGH mode
    3. Updates the specified listener to use the SSL Profile
    4. Deploys changes using ARM API

.PARAMETER ResourceGroupName
    Resource group containing the Application Gateway

.PARAMETER AppGatewayName
    Name of the Application Gateway

.PARAMETER ListenerName
    Name of the listener to update (e.g., uniperapis-dev-gateway-listener-001)

.PARAMETER SslProfileName
    Name for the new SSL profile (default: mtls-passthrough-profile)

.EXAMPLE
    .\Deploy-MtlsPassthrough.ps1 -ResourceGroupName "APINW-iaas-HUB-rgp-001" `
                                  -AppGatewayName "hub-uni-apim-npd-appgwv2-001" `
                                  -ListenerName "uniperapis-dev-gateway-listener-001"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$AppGatewayName,

    [Parameter(Mandatory = $true)]
    [string]$ListenerName,

    [Parameter(Mandatory = $false)]
    [string]$SslProfileName = "mtls-passthrough-profile",

    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

# ============================================================================
# FUNCTIONS
# ============================================================================

function Write-Step {
    param([string]$Message)
    Write-Host "`n[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "  ⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "  ❌ $Message" -ForegroundColor Red
}

function Export-BackupConfiguration {
    param(
        [Parameter(Mandatory = $true)]
        [object]$AppGateway,
        [Parameter(Mandatory = $true)]
        [string]$BackupPath
    )
    
    $backupData = @{
        Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        ResourceGroup = $ResourceGroupName
        AppGatewayName = $AppGatewayName
        ListenerName = $ListenerName
        OriginalSslProfiles = $AppGateway.SslProfiles
        OriginalListenerConfig = ($AppGateway.HttpListeners | Where-Object { $_.Name -eq $ListenerName })
    }
    
    $backupData | ConvertTo-Json -Depth 10 | Out-File -FilePath $BackupPath -Encoding UTF8
    return $BackupPath
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

try {
    Write-Host "`n" + "=" * 70 -ForegroundColor White
    Write-Host "  MTLS PASSTHROUGH DEPLOYMENT SCRIPT" -ForegroundColor White
    Write-Host "  Application Gateway: $AppGatewayName" -ForegroundColor White
    Write-Host "  Listener: $ListenerName" -ForegroundColor White
    Write-Host "=" * 70 -ForegroundColor White

    # Step 1: Get current Application Gateway configuration
    Write-Step "Step 1: Retrieving current Application Gateway configuration..."
    $appGw = Get-AzApplicationGateway -ResourceGroupName $ResourceGroupName -Name $AppGatewayName
    
    if (-not $appGw) {
        throw "Application Gateway '$AppGatewayName' not found in resource group '$ResourceGroupName'"
    }
    Write-Success "Retrieved Application Gateway configuration"

    # Step 2: Create backup
    Write-Step "Step 2: Creating backup of current configuration..."
    $backupPath = ".\BACKUP_AppGw_$($AppGatewayName)_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    Export-BackupConfiguration -AppGateway $appGw -BackupPath $backupPath
    Write-Success "Backup saved to: $backupPath"

    # Step 3: Verify listener exists
    Write-Step "Step 3: Verifying listener '$ListenerName' exists..."
    $listener = $appGw.HttpListeners | Where-Object { $_.Name -eq $ListenerName }
    
    if (-not $listener) {
        throw "Listener '$ListenerName' not found in Application Gateway"
    }
    Write-Success "Listener found: $($listener.Name)"
    
    # Check if listener already has SSL profile
    if ($listener.SslProfile) {
        Write-Warning "Listener already has SSL profile: $($listener.SslProfile.Id)"
        Write-Warning "Proceeding will replace the existing SSL profile reference"
    }

    # Step 4: Check if SSL profile already exists
    Write-Step "Step 4: Checking for existing SSL profile..."
    $existingProfile = $appGw.SslProfiles | Where-Object { $_.Name -eq $SslProfileName }
    
    if ($existingProfile) {
        Write-Warning "SSL profile '$SslProfileName' already exists"
        Write-Warning "Will update existing profile configuration"
    } else {
        Write-Success "SSL profile '$SslProfileName' will be created"
    }

    # Step 5: Add/Update SSL Profile with PASSTHROUGH configuration
    Write-Step "Step 5: Configuring SSL Profile with PASSTHROUGH mode..."
    
    if ($WhatIf) {
        Write-Warning "WhatIf mode - No changes will be made"
        Write-Host "`n  Would create SSL Profile:" -ForegroundColor Yellow
        Write-Host "    Name: $SslProfileName"
        Write-Host "    verifyClientCertIssuerDN: false"
        Write-Host "    verifyClientRevocation: None"
        Write-Host "    TLS Policy: AppGwSslPolicy20220101S"
        Write-Host "`n  Would update listener:" -ForegroundColor Yellow
        Write-Host "    Listener: $ListenerName"
        Write-Host "    SSL Profile Reference: $SslProfileName"
        return
    }

    # Create client authentication configuration (PASSTHROUGH mode)
    # In PASSTHROUGH mode:
    # - verifyClientCertIssuerDN = false (no DN verification at gateway)
    # - verifyClientRevocation = None (no revocation check)
    # - No trustedClientCertificates required (unlike STRICT mode)
    $clientAuthConfig = New-AzApplicationGatewayClientAuthConfiguration `
        -VerifyClientCertIssuerDN:$false

    # Create SSL policy
    $sslPolicy = New-AzApplicationGatewaySslPolicy `
        -PolicyType Predefined `
        -PolicyName AppGwSslPolicy20220101S

    # Add or update the SSL profile
    if ($existingProfile) {
        # Remove existing profile first
        $appGw = Remove-AzApplicationGatewaySslProfile `
            -ApplicationGateway $appGw `
            -Name $SslProfileName
    }

    # Add new SSL profile (PASSTHROUGH mode - no trustedClientCertificates)
    $appGw = Add-AzApplicationGatewaySslProfile `
        -ApplicationGateway $appGw `
        -Name $SslProfileName `
        -SslPolicy $sslPolicy `
        -ClientAuthConfiguration $clientAuthConfig
    
    Write-Success "SSL Profile configured with PASSTHROUGH settings"

    # Step 6: Update listener to reference the SSL profile
    Write-Step "Step 6: Updating listener to reference SSL profile..."
    
    # Get the SSL profile reference
    $sslProfileRef = $appGw.SslProfiles | Where-Object { $_.Name -eq $SslProfileName }
    
    # Find and update the listener
    $listenerIndex = 0
    foreach ($l in $appGw.HttpListeners) {
        if ($l.Name -eq $ListenerName) {
            $appGw.HttpListeners[$listenerIndex].SslProfile = New-Object Microsoft.Azure.Commands.Network.Models.PSResourceId
            $appGw.HttpListeners[$listenerIndex].SslProfile.Id = $sslProfileRef.Id
            break
        }
        $listenerIndex++
    }
    
    Write-Success "Listener updated to reference SSL profile"

    # Step 7: Apply changes to Application Gateway
    Write-Step "Step 7: Applying changes to Application Gateway..."
    Write-Host "  This operation may take 5-10 minutes..." -ForegroundColor Yellow
    
    $result = Set-AzApplicationGateway -ApplicationGateway $appGw
    
    if ($result.ProvisioningState -eq "Succeeded") {
        Write-Success "Application Gateway updated successfully"
    } else {
        throw "Application Gateway update failed. State: $($result.ProvisioningState)"
    }

    # Step 8: Verify configuration
    Write-Step "Step 8: Verifying configuration..."
    $verifyGw = Get-AzApplicationGateway -ResourceGroupName $ResourceGroupName -Name $AppGatewayName
    
    $verifySslProfile = $verifyGw.SslProfiles | Where-Object { $_.Name -eq $SslProfileName }
    $verifyListener = $verifyGw.HttpListeners | Where-Object { $_.Name -eq $ListenerName }
    
    if ($verifySslProfile -and $verifyListener.SslProfile.Id -like "*$SslProfileName*") {
        Write-Success "SSL Profile verified: $($verifySslProfile.Name)"
        Write-Success "Listener verified: $($verifyListener.Name) -> $($verifySslProfile.Name)"
    } else {
        Write-Warning "Verification incomplete - please check manually"
    }

    # Summary
    Write-Host "`n" + "=" * 70 -ForegroundColor Green
    Write-Host "  DEPLOYMENT COMPLETED SUCCESSFULLY" -ForegroundColor Green
    Write-Host "=" * 70 -ForegroundColor Green
    Write-Host "`n  Next Steps:" -ForegroundColor White
    Write-Host "  1. Test with a client certificate to verify headers are populated"
    Write-Host "  2. Check X-Client-Cert-Fingerprint header in APIM"
    Write-Host "  3. Verify APIM policy validates the certificate correctly"
    Write-Host "`n  Rollback:" -ForegroundColor White
    Write-Host "  If needed, run: .\Rollback-MtlsPassthrough.ps1 -BackupFile '$backupPath'"
    Write-Host ""

} catch {
    Write-Error "Deployment failed: $($_.Exception.Message)"
    Write-Host "`n  Stack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace
    
    if ($backupPath -and (Test-Path $backupPath)) {
        Write-Host "`n  Backup file available at: $backupPath" -ForegroundColor Yellow
        Write-Host "  Use this file to rollback if needed" -ForegroundColor Yellow
    }
    
    exit 1
}
```

### Option 3: Azure CLI Commands (Step-by-Step)

```bash
#!/bin/bash
# MTLS PASSTHROUGH Deployment Script
# Application Gateway: hub-uni-apim-npd-appgwv2-001
# Listener: uniperapis-dev-gateway-listener-001

# Variables
RG_NAME="APINW-iaas-HUB-rgp-001"
APPGW_NAME="hub-uni-apim-npd-appgwv2-001"
LISTENER_NAME="uniperapis-dev-gateway-listener-001"
SSL_PROFILE_NAME="mtls-passthrough-profile"

# Step 1: Create backup of current configuration
echo "Step 1: Creating backup..."
az network application-gateway show \
  --resource-group $RG_NAME \
  --name $APPGW_NAME \
  --output json > "backup_appgw_$(date +%Y%m%d_%H%M%S).json"

# Step 2: Add SSL Profile with PASSTHROUGH configuration
# Note: PASSTHROUGH mode = no trusted client certificates + client auth enabled
echo "Step 2: Creating SSL Profile..."
az network application-gateway ssl-profile add \
  --resource-group $RG_NAME \
  --gateway-name $APPGW_NAME \
  --name $SSL_PROFILE_NAME \
  --policy-type Predefined \
  --policy-name AppGwSslPolicy20220101S \
  --client-auth-configuration verify-client-cert-issuer-dn=false

# Step 3: Update listener to reference SSL profile
echo "Step 3: Updating listener..."
az network application-gateway http-listener update \
  --resource-group $RG_NAME \
  --gateway-name $APPGW_NAME \
  --name $LISTENER_NAME \
  --ssl-profile $SSL_PROFILE_NAME

# Step 4: Verify configuration
echo "Step 4: Verifying..."
az network application-gateway ssl-profile show \
  --resource-group $RG_NAME \
  --gateway-name $APPGW_NAME \
  --name $SSL_PROFILE_NAME

echo "Deployment complete!"
```

---

## Bicep Template Update (mainAPINW.bicep)

If you prefer to update the Bicep template directly, make these changes:

### Change 1: Add SSL Profile (around line 224)

**Current:**
```bicep
trustedClientCertificates: []
sslProfiles: []
```

**Change to:**
```bicep
trustedClientCertificates: []
sslProfiles: [
  {
    name: 'mtls-passthrough-profile'
    properties: {
      clientAuthConfiguration: {
        verifyClientCertIssuerDN: false
        verifyClientRevocation: 'None'
      }
      sslPolicy: {
        policyType: 'Predefined'
        policyName: 'AppGwSslPolicy20220101S'
      }
    }
  }
]
```

### Change 2: Update Listener (around line 530)

**Current:**
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
    hostName: 'gateway-dev.apis.uniper.energy'
    hostNames: []
    requireServerNameIndication: true
    customErrorConfigurations: []
  }
}
```

**Change to (add sslProfile reference):**
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
    hostName: 'gateway-dev.apis.uniper.energy'
    hostNames: []
    requireServerNameIndication: true
    customErrorConfigurations: []
  }
}
```

---

## APIM Policy Update (Header-Based Validation)

Since we're keeping `negotiateClientCertificate: false`, the APIM policy must validate using headers only:

```xml
<policies>
    <inbound>
        <base />
        <set-header name="Ocp-Apim-Subscription-Key" exists-action="delete" />
        
        <!-- Extract certificate fingerprint from App Gateway header -->
        <set-variable name="clientCertFingerprint" 
                      value="@(context.Request.Headers.GetValueOrDefault("X-Client-Cert-Fingerprint", ""))" />
        <set-variable name="clientCertVerification" 
                      value="@(context.Request.Headers.GetValueOrDefault("X-Client-Cert-Verification", "NONE"))" />
        
        <!-- Log for debugging (remove in production) -->
        <trace source="mtls-validation">
            <message>@{
                return string.Format(
                    "Certificate Fingerprint: {0}, Verification: {1}",
                    (string)context.Variables["clientCertFingerprint"],
                    (string)context.Variables["clientCertVerification"]
                );
            }</message>
        </trace>
        
        <!-- Validate certificate was provided -->
        <choose>
            <when condition="@(string.IsNullOrEmpty((string)context.Variables["clientCertFingerprint"]))">
                <return-response>
                    <set-status code="403" reason="Forbidden" />
                    <set-header name="Content-Type" exists-action="override">
                        <value>application/json</value>
                    </set-header>
                    <set-body>@{
                        return new JObject(
                            new JProperty("error", "Client certificate required"),
                            new JProperty("code", "MISSING_CLIENT_CERTIFICATE"),
                            new JProperty("details", "No client certificate was provided in the request")
                        ).ToString();
                    }</set-body>
                </return-response>
            </when>
        </choose>
        
        <!-- Validate certificate verification status -->
        <choose>
            <when condition="@((string)context.Variables["clientCertVerification"] != "SUCCESS")">
                <return-response>
                    <set-status code="403" reason="Forbidden" />
                    <set-header name="Content-Type" exists-action="override">
                        <value>application/json</value>
                    </set-header>
                    <set-body>@{
                        return new JObject(
                            new JProperty("error", "Certificate verification failed"),
                            new JProperty("code", "CERTIFICATE_VERIFICATION_FAILED"),
                            new JProperty("verification_status", (string)context.Variables["clientCertVerification"])
                        ).ToString();
                    }</set-body>
                </return-response>
            </when>
        </choose>
        
        <!-- Validate thumbprint against expected value(s) -->
        <!-- Option 1: Single expected thumbprint -->
        <choose>
            <when condition="@{
                string receivedThumbprint = ((string)context.Variables["clientCertFingerprint"]).ToUpper().Replace(":", "");
                string expectedThumbprint = "YOUR_EXPECTED_THUMBPRINT_HERE".ToUpper().Replace(":", "");
                return receivedThumbprint == expectedThumbprint;
            }">
                <!-- Certificate is valid - continue processing -->
                <set-header name="X-Certificate-Validated" exists-action="override">
                    <value>true</value>
                </set-header>
            </when>
            <otherwise>
                <return-response>
                    <set-status code="403" reason="Forbidden" />
                    <set-header name="Content-Type" exists-action="override">
                        <value>application/json</value>
                    </set-header>
                    <set-body>@{
                        return new JObject(
                            new JProperty("error", "Certificate not authorized"),
                            new JProperty("code", "CERTIFICATE_NOT_AUTHORIZED"),
                            new JProperty("received_fingerprint", (string)context.Variables["clientCertFingerprint"])
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

### Policy Variation: Allow Non-MTLS Clients for Certain Paths

If you need to allow non-MTLS clients for certain paths while enforcing MTLS for others:

```xml
<policies>
    <inbound>
        <base />
        
        <!-- Check if this path requires MTLS -->
        <choose>
            <!-- MTLS required paths -->
            <when condition="@(context.Request.Url.Path.StartsWith("/api/ex/"))">
                <!-- Validate certificate for external API paths -->
                <set-variable name="clientCertFingerprint" 
                              value="@(context.Request.Headers.GetValueOrDefault("X-Client-Cert-Fingerprint", ""))" />
                
                <choose>
                    <when condition="@(string.IsNullOrEmpty((string)context.Variables["clientCertFingerprint"]))">
                        <return-response>
                            <set-status code="403" reason="Client certificate required for external API" />
                            <set-body>{"error": "Client certificate required", "path": "@(context.Request.Url.Path)"}</set-body>
                        </return-response>
                    </when>
                </choose>
                
                <!-- Validate thumbprint here... -->
            </when>
            <otherwise>
                <!-- Non-MTLS paths - allow without certificate -->
            </otherwise>
        </choose>
        
    </inbound>
    <!-- ... rest of policy ... -->
</policies>
```

---

## Testing Plan

### Test Scenario 1: MTLS Client (with valid certificate)
```bash
# Using curl with client certificate
curl -v \
  --cert client.crt \
  --key client.key \
  https://gateway-dev.apis.uniper.energy/api/ex/test

# Expected: 200 OK
# Headers should show:
#   X-Client-Cert-Fingerprint: <thumbprint>
#   X-Client-Cert-Verification: SUCCESS
```

### Test Scenario 2: Client without certificate
```bash
# Using curl without certificate
curl -v https://gateway-dev.apis.uniper.energy/api/ex/test

# Expected: 403 Forbidden (if MTLS is enforced)
# Or: 200 OK (if non-MTLS clients are allowed for this path)
```

### Test Scenario 3: Client with invalid/untrusted certificate
```bash
# Using curl with invalid certificate
curl -v \
  --cert invalid-client.crt \
  --key invalid-client.key \
  https://gateway-dev.apis.uniper.energy/api/ex/test

# Expected: 403 Forbidden (thumbprint doesn't match)
```

### Verification Checklist
- [ ] Server variables are populated (not NULL)
- [ ] X-Client-Cert-Fingerprint header contains actual thumbprint
- [ ] X-Client-Cert-Verification shows SUCCESS for valid certs
- [ ] APIM policy returns 403 for missing/invalid certificates
- [ ] APIM policy returns 200 for valid certificates
- [ ] Non-MTLS paths (if configured) work without certificate

---

## Rollback Plan

### Quick Rollback (PowerShell)

Create `Rollback-MtlsPassthrough.ps1`:

```powershell
<#
.SYNOPSIS
    Rollback MTLS PASSTHROUGH configuration

.DESCRIPTION
    Removes SSL profile reference from listener and optionally removes the SSL profile

.PARAMETER ResourceGroupName
    Resource group containing the Application Gateway

.PARAMETER AppGatewayName
    Name of the Application Gateway

.PARAMETER ListenerName
    Name of the listener to update

.PARAMETER SslProfileName
    Name of the SSL profile to remove

.PARAMETER RemoveSslProfile
    If specified, also removes the SSL profile (not just the reference)

.EXAMPLE
    .\Rollback-MtlsPassthrough.ps1 -ResourceGroupName "APINW-iaas-HUB-rgp-001" `
                                    -AppGatewayName "hub-uni-apim-npd-appgwv2-001" `
                                    -ListenerName "uniperapis-dev-gateway-listener-001"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$AppGatewayName,

    [Parameter(Mandatory = $true)]
    [string]$ListenerName,

    [Parameter(Mandatory = $false)]
    [string]$SslProfileName = "mtls-passthrough-profile",

    [Parameter(Mandatory = $false)]
    [switch]$RemoveSslProfile,

    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

function Write-Step { param([string]$M) Write-Host "`n[$((Get-Date).ToString('HH:mm:ss'))] $M" -ForegroundColor Cyan }
function Write-Success { param([string]$M) Write-Host "  ✅ $M" -ForegroundColor Green }
function Write-Warning { param([string]$M) Write-Host "  ⚠️  $M" -ForegroundColor Yellow }
function Write-Error { param([string]$M) Write-Host "  ❌ $M" -ForegroundColor Red }

try {
    Write-Host "`n" + "=" * 70 -ForegroundColor Yellow
    Write-Host "  MTLS PASSTHROUGH ROLLBACK SCRIPT" -ForegroundColor Yellow
    Write-Host "  Application Gateway: $AppGatewayName" -ForegroundColor Yellow
    Write-Host "  Listener: $ListenerName" -ForegroundColor Yellow
    Write-Host "=" * 70 -ForegroundColor Yellow

    # Step 1: Get current configuration
    Write-Step "Step 1: Retrieving Application Gateway configuration..."
    $appGw = Get-AzApplicationGateway -ResourceGroupName $ResourceGroupName -Name $AppGatewayName
    Write-Success "Retrieved configuration"

    # Step 2: Create pre-rollback backup
    Write-Step "Step 2: Creating pre-rollback backup..."
    $backupPath = ".\BACKUP_PreRollback_$($AppGatewayName)_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    @{
        Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        SslProfiles = $appGw.SslProfiles
        ListenerConfig = ($appGw.HttpListeners | Where-Object { $_.Name -eq $ListenerName })
    } | ConvertTo-Json -Depth 10 | Out-File -FilePath $backupPath -Encoding UTF8
    Write-Success "Backup saved: $backupPath"

    # Step 3: Remove SSL profile reference from listener
    Write-Step "Step 3: Removing SSL profile reference from listener..."
    
    if ($WhatIf) {
        Write-Warning "WhatIf mode - No changes will be made"
        Write-Host "  Would remove SSL profile reference from: $ListenerName"
        if ($RemoveSslProfile) {
            Write-Host "  Would remove SSL profile: $SslProfileName"
        }
        return
    }

    $listenerIndex = 0
    $found = $false
    foreach ($l in $appGw.HttpListeners) {
        if ($l.Name -eq $ListenerName) {
            $appGw.HttpListeners[$listenerIndex].SslProfile = $null
            $found = $true
            break
        }
        $listenerIndex++
    }
    
    if ($found) {
        Write-Success "SSL profile reference removed from listener"
    } else {
        throw "Listener '$ListenerName' not found"
    }

    # Step 4: Optionally remove SSL profile
    if ($RemoveSslProfile) {
        Write-Step "Step 4: Removing SSL profile..."
        $profileExists = $appGw.SslProfiles | Where-Object { $_.Name -eq $SslProfileName }
        if ($profileExists) {
            $appGw = Remove-AzApplicationGatewaySslProfile -ApplicationGateway $appGw -Name $SslProfileName
            Write-Success "SSL profile '$SslProfileName' removed"
        } else {
            Write-Warning "SSL profile '$SslProfileName' not found - nothing to remove"
        }
    } else {
        Write-Step "Step 4: Keeping SSL profile (not removing)..."
        Write-Success "SSL profile preserved for potential re-use"
    }

    # Step 5: Apply changes
    Write-Step "Step 5: Applying rollback changes..."
    Write-Host "  This operation may take 5-10 minutes..." -ForegroundColor Yellow
    
    $result = Set-AzApplicationGateway -ApplicationGateway $appGw
    
    if ($result.ProvisioningState -eq "Succeeded") {
        Write-Success "Rollback completed successfully"
    } else {
        throw "Rollback failed. State: $($result.ProvisioningState)"
    }

    # Summary
    Write-Host "`n" + "=" * 70 -ForegroundColor Green
    Write-Host "  ROLLBACK COMPLETED" -ForegroundColor Green
    Write-Host "=" * 70 -ForegroundColor Green
    Write-Host "`n  Changes Applied:" -ForegroundColor White
    Write-Host "  - Removed SSL profile reference from listener: $ListenerName"
    if ($RemoveSslProfile) {
        Write-Host "  - Removed SSL profile: $SslProfileName"
    }
    Write-Host "`n  System State:" -ForegroundColor White
    Write-Host "  - MTLS PASSTHROUGH is now DISABLED for this listener"
    Write-Host "  - Server variables will return NULL"
    Write-Host "  - Rewrite headers will be empty"
    Write-Host ""

} catch {
    Write-Error "Rollback failed: $($_.Exception.Message)"
    exit 1
}
```

### Quick Rollback (Azure CLI)

```bash
#!/bin/bash
# MTLS PASSTHROUGH Rollback Script

RG_NAME="APINW-iaas-HUB-rgp-001"
APPGW_NAME="hub-uni-apim-npd-appgwv2-001"
LISTENER_NAME="uniperapis-dev-gateway-listener-001"
SSL_PROFILE_NAME="mtls-passthrough-profile"

# Step 1: Remove SSL profile reference from listener
echo "Removing SSL profile reference from listener..."
az network application-gateway http-listener update \
  --resource-group $RG_NAME \
  --gateway-name $APPGW_NAME \
  --name $LISTENER_NAME \
  --remove sslProfile

# Step 2: Optionally remove SSL profile (uncomment if needed)
# echo "Removing SSL profile..."
# az network application-gateway ssl-profile delete \
#   --resource-group $RG_NAME \
#   --gateway-name $APPGW_NAME \
#   --name $SSL_PROFILE_NAME

echo "Rollback complete!"
```

---

## Comparison: This Solution vs Original

| Aspect | Original Solution | This PASSTHROUGH Solution |
|--------|------------------|---------------------------|
| **Listeners** | Potentially multiple | Single existing listener ✅ |
| **APIM negotiateClientCertificate** | `true` (affects ALL clients) | `false` (no change) ✅ |
| **Trusted CA Certificates** | Required upload | NOT required ✅ |
| **Server Variables** | Populated | Populated ✅ |
| **Certificate Validation** | Gateway + APIM native | APIM policy only (headers) |
| **Non-MTLS Clients** | May be affected | Unaffected ✅ |
| **Implementation Risk** | Higher (more changes) | Lower (minimal changes) ✅ |This PASSTHROUGH solution meets ALL customer constraints while achieving the same goal.

---

## Summary

This solution enables MTLS authentication WITHOUT requiring:
1. Multiple listeners (uses existing single listener)
2. Changes to APIM `negotiateClientCertificate` (stays `false`)
3. Uploading trusted CA certificates to App Gateway

The key enabler is **PASSTHROUGH mode** which:
- Captures client certificates during TLS handshake
- Populates server variables with certificate data
- Forwards certificate data via rewrite headers
- Allows APIM policy to validate based on headers

**Deployment Time:** ~15-20 minutes (including App Gateway update)
**Rollback Time:** ~15-20 minutes

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Feb 16, 2026 | Pavleen Bali | Initial PASSTHROUGH solution |
