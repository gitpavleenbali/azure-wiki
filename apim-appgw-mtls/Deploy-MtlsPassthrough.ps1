<#
.SYNOPSIS
    Deploy MTLS PASSTHROUGH configuration to Application Gateway

.DESCRIPTION
    This script enables MTLS PASSTHROUGH mode on an Application Gateway listener by:
    1. Creating an SSL Profile with PASSTHROUGH configuration (no trusted CA certs required)
    2. Updating the target listener to reference the SSL Profile
    
    PASSTHROUGH Mode Benefits:
    - Does NOT require uploading trusted CA certificates
    - Does NOT reject clients without certificates (non-mandatory)
    - Captures certificates for clients that provide them
    - Populates server variables with certificate data
    - Allows APIM to validate certificates via headers
    
    This script addresses customer constraints:
    - Uses existing listener (no multiple listeners needed)
    - Does NOT require APIM negotiateClientCertificate=true
    - Selective validation via APIM policy

.PARAMETER ResourceGroupName
    Resource group containing the Application Gateway

.PARAMETER AppGatewayName
    Name of the Application Gateway

.PARAMETER ListenerName
    Name of the listener to enable MTLS on (e.g., uniperapis-dev-gateway-listener-001)

.PARAMETER SslProfileName
    Name for the new SSL profile (default: mtls-passthrough-profile)

.PARAMETER SslPolicyName
    SSL policy to use (default: AppGwSslPolicy20220101S)

.PARAMETER WhatIf
    Preview changes without applying them

.EXAMPLE
    # Deploy MTLS PASSTHROUGH
    .\Deploy-MtlsPassthrough.ps1 -ResourceGroupName "APINW-iaas-HUB-rgp-001" `
                                  -AppGatewayName "hub-uni-apim-npd-appgwv2-001" `
                                  -ListenerName "uniperapis-dev-gateway-listener-001"

.EXAMPLE
    # Preview changes without applying
    .\Deploy-MtlsPassthrough.ps1 -ResourceGroupName "APINW-iaas-HUB-rgp-001" `
                                  -AppGatewayName "hub-uni-apim-npd-appgwv2-001" `
                                  -ListenerName "uniperapis-dev-gateway-listener-001" `
                                  -WhatIf

.NOTES
    Author: Pavleen Bali, Microsoft CSA
    Date: February 2026
    Version: 1.0
    
    Rollback: Use Rollback-MtlsPassthrough.ps1 if issues occur
#>

[CmdletBinding(SupportsShouldProcess = $true)]
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
    [ValidateSet("AppGwSslPolicy20150501", "AppGwSslPolicy20170401", "AppGwSslPolicy20170401S", "AppGwSslPolicy20220101", "AppGwSslPolicy20220101S")]
    [string]$SslPolicyName = "AppGwSslPolicy20220101S",

    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Write-Banner {
    param([string]$Title, [string]$Color = "White")
    Write-Host "`n" + "=" * 70 -ForegroundColor $Color
    Write-Host "  $Title" -ForegroundColor $Color
    Write-Host "=" * 70 -ForegroundColor $Color
}

function Write-Step {
    param([string]$Message)
    Write-Host "`n[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  [WARN] $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "  [ERROR] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "  $Message" -ForegroundColor Gray
}

function Test-AzureConnection {
    try {
        $context = Get-AzContext
        if (-not $context) {
            throw "No Azure context found"
        }
        return $true
    } catch {
        return $false
    }
}

function Export-BackupConfiguration {
    param(
        [Parameter(Mandatory = $true)]
        [object]$AppGateway,
        [Parameter(Mandatory = $true)]
        [string]$BackupPath
    )
    
    $backupData = @{
        Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss UTC")
        Operation = "Pre-Deployment Backup"
        AppGatewayName = $AppGateway.Name
        ResourceGroupName = $ResourceGroupName
        ProvisioningState = $AppGateway.ProvisioningState
        SslProfiles = @($AppGateway.SslProfiles | ForEach-Object { 
            @{
                Name = $_.Name
                Id = $_.Id
                ClientAuthConfiguration = @{
                    VerifyClientCertIssuerDN = $_.ClientAuthConfiguration.VerifyClientCertIssuerDN
                    VerifyClientRevocation = $_.ClientAuthConfiguration.VerifyClientRevocation
                }
            }
        })
        TargetListenerConfig = @($AppGateway.HttpListeners | Where-Object { $_.Name -eq $ListenerName } | ForEach-Object {
            @{
                Name = $_.Name
                Id = $_.Id
                SslProfileId = $_.SslProfile.Id
                SslCertificateId = $_.SslCertificate.Id
                Protocol = $_.Protocol
                HostName = $_.HostName
            }
        })
    }
    
    $backupData | ConvertTo-Json -Depth 10 | Out-File -FilePath $BackupPath -Encoding UTF8
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

try {
    Write-Banner "MTLS PASSTHROUGH DEPLOYMENT" "Cyan"
    Write-Host "`n  Configuration:" -ForegroundColor White
    Write-Host "    Resource Group:    $ResourceGroupName"
    Write-Host "    App Gateway:       $AppGatewayName"
    Write-Host "    Listener:          $ListenerName"
    Write-Host "    SSL Profile:       $SslProfileName"
    Write-Host "    SSL Policy:        $SslPolicyName"
    Write-Host "    WhatIf Mode:       $WhatIf"
    
    Write-Host "`n  PASSTHROUGH Mode Configuration:" -ForegroundColor White
    Write-Host "    Verify Client DN:  false (disabled)"
    Write-Host "    Revocation Check:  None"
    Write-Host "    Trusted CA Certs:  Not required"

    # Verify Azure connection
    Write-Step "Step 1: Verifying Azure connection..."
    if (-not (Test-AzureConnection)) {
        Write-Err "Not connected to Azure. Please run 'Connect-AzAccount' first."
        exit 1
    }
    $context = Get-AzContext
    Write-Success "Connected to Azure"
    Write-Info "Subscription: $($context.Subscription.Name)"
    Write-Info "Account: $($context.Account.Id)"

    # Get current Application Gateway configuration
    Write-Step "Step 2: Retrieving Application Gateway configuration..."
    $appGw = Get-AzApplicationGateway -ResourceGroupName $ResourceGroupName -Name $AppGatewayName -ErrorAction Stop
    Write-Success "Retrieved Application Gateway: $($appGw.Name)"
    Write-Info "Location: $($appGw.Location)"
    Write-Info "Provisioning State: $($appGw.ProvisioningState)"
    Write-Info "SKU: $($appGw.Sku.Name) / $($appGw.Sku.Tier)"
    Write-Info "Current SSL Profiles: $($appGw.SslProfiles.Count)"
    Write-Info "HTTP Listeners: $($appGw.HttpListeners.Count)"

    # Create backup
    Write-Step "Step 3: Creating backup of current configuration..."
    $backupPath = ".\BACKUP_AppGw_$($AppGatewayName)_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    Export-BackupConfiguration -AppGateway $appGw -BackupPath $backupPath
    Write-Success "Backup saved to: $backupPath"

    # Verify target listener exists
    Write-Step "Step 4: Verifying target listener exists..."
    $listener = $appGw.HttpListeners | Where-Object { $_.Name -eq $ListenerName }
    
    if (-not $listener) {
        Write-Err "Listener '$ListenerName' not found!"
        Write-Info "Available listeners:"
        $appGw.HttpListeners | ForEach-Object { Write-Info "  - $($_.Name)" }
        exit 1
    }
    Write-Success "Listener found: $($listener.Name)"
    Write-Info "Protocol: $($listener.Protocol)"
    Write-Info "HostName: $($listener.HostName)"
    
    if ($listener.SslProfile) {
        Write-Warn "Listener already has SSL Profile: $($listener.SslProfile.Id)"
        Write-Warn "This will be replaced with the new PASSTHROUGH profile"
    }

    # Check if SSL profile already exists
    Write-Step "Step 5: Checking for existing SSL profile..."
    $existingProfile = $appGw.SslProfiles | Where-Object { $_.Name -eq $SslProfileName }
    
    if ($existingProfile) {
        Write-Warn "SSL profile '$SslProfileName' already exists"
        Write-Warn "Will update existing profile configuration"
    } else {
        Write-Success "SSL profile '$SslProfileName' will be created"
    }

    # WhatIf mode check
    if ($WhatIf) {
        Write-Banner "WHATIF MODE - NO CHANGES WILL BE MADE" "Yellow"
        
        Write-Host "`n  Actions that WOULD be performed:" -ForegroundColor White
        Write-Host "    1. Create/Update SSL Profile: $SslProfileName"
        Write-Host "       - verifyClientCertIssuerDN: false"
        Write-Host "       - verifyClientRevocation: None"
        Write-Host "       - SSL Policy: $SslPolicyName"
        Write-Host "    2. Update listener: $ListenerName"
        Write-Host "       - Add SSL Profile reference"
        Write-Host "    3. Apply changes to Application Gateway"
        
        Write-Host "`n  Post-Deployment State:" -ForegroundColor White
        Write-Host "    - MTLS PASSTHROUGH: ENABLED"
        Write-Host "    - Server variables: Will be populated with cert data"
        Write-Host "    - Rewrite headers: Will contain certificate info"
        Write-Host "    - Clients without certs: Can still connect (PASSTHROUGH)"
        Write-Host "    - APIM negotiateClientCertificate: NO CHANGE NEEDED"
        
        Write-Host "`n  Backup saved to: $backupPath" -ForegroundColor White
        return
    }

    # Create/Update SSL Profile with PASSTHROUGH configuration
    Write-Step "Step 6: Configuring SSL Profile with PASSTHROUGH mode..."
    
    # Create client authentication configuration for PASSTHROUGH
    # PASSTHROUGH mode: verifyClientCertIssuerDN=false, no trusted client certs needed
    $clientAuthConfig = New-AzApplicationGatewayClientAuthConfiguration -VerifyClientCertIssuerDN:$false
    Write-Info "Client Auth Config: verifyClientCertIssuerDN = false"

    # Create SSL policy
    $sslPolicy = New-AzApplicationGatewaySslPolicy -PolicyType Predefined -PolicyName $SslPolicyName
    Write-Info "SSL Policy: $SslPolicyName"

    # Remove existing profile if present
    if ($existingProfile) {
        Write-Info "Removing existing SSL profile for update..."
        $appGw = Remove-AzApplicationGatewaySslProfile -ApplicationGateway $appGw -Name $SslProfileName
    }

    # Add SSL profile (PASSTHROUGH mode - no trustedClientCertificates)
    $appGw = Add-AzApplicationGatewaySslProfile `
        -ApplicationGateway $appGw `
        -Name $SslProfileName `
        -SslPolicy $sslPolicy `
        -ClientAuthConfiguration $clientAuthConfig
    
    Write-Success "SSL Profile configured with PASSTHROUGH settings"

    # Update listener to reference the SSL profile
    Write-Step "Step 7: Updating listener to reference SSL profile..."
    
    # Get the SSL profile reference
    $sslProfileRef = $appGw.SslProfiles | Where-Object { $_.Name -eq $SslProfileName }
    
    if (-not $sslProfileRef) {
        throw "Failed to create SSL profile - not found after add"
    }
    
    # Find and update the listener
    $listenerIndex = 0
    $listenerUpdated = $false
    
    foreach ($l in $appGw.HttpListeners) {
        if ($l.Name -eq $ListenerName) {
            $appGw.HttpListeners[$listenerIndex].SslProfile = New-Object Microsoft.Azure.Commands.Network.Models.PSResourceId
            $appGw.HttpListeners[$listenerIndex].SslProfile.Id = $sslProfileRef.Id
            $listenerUpdated = $true
            break
        }
        $listenerIndex++
    }
    
    if (-not $listenerUpdated) {
        throw "Failed to update listener - not found in array"
    }
    
    Write-Success "Listener updated to reference SSL profile"
    Write-Info "SSL Profile ID: $($sslProfileRef.Id)"

    # Apply changes to Application Gateway
    Write-Step "Step 8: Applying changes to Application Gateway..."
    Write-Host "  This operation typically takes 5-10 minutes..." -ForegroundColor Yellow
    Write-Host "  Please wait..." -ForegroundColor Yellow
    
    $startTime = Get-Date
    $result = Set-AzApplicationGateway -ApplicationGateway $appGw
    $duration = (Get-Date) - $startTime
    
    if ($result.ProvisioningState -eq "Succeeded") {
        Write-Success "Application Gateway updated successfully"
        Write-Info "Duration: $($duration.TotalMinutes.ToString('0.0')) minutes"
    } else {
        throw "Application Gateway update failed. Provisioning State: $($result.ProvisioningState)"
    }

    # Verify configuration
    Write-Step "Step 9: Verifying configuration..."
    $verifyGw = Get-AzApplicationGateway -ResourceGroupName $ResourceGroupName -Name $AppGatewayName
    
    $verifySslProfile = $verifyGw.SslProfiles | Where-Object { $_.Name -eq $SslProfileName }
    $verifyListener = $verifyGw.HttpListeners | Where-Object { $_.Name -eq $ListenerName }
    
    if ($verifySslProfile) {
        Write-Success "SSL Profile verified: $($verifySslProfile.Name)"
        Write-Info "Client Auth - VerifyClientCertIssuerDN: $($verifySslProfile.ClientAuthConfiguration.VerifyClientCertIssuerDN)"
    } else {
        Write-Warn "SSL Profile verification failed"
    }
    
    if ($verifyListener.SslProfile -and $verifyListener.SslProfile.Id -like "*$SslProfileName*") {
        Write-Success "Listener verified: $($verifyListener.Name) -> $SslProfileName"
    } else {
        Write-Warn "Listener SSL Profile reference verification incomplete"
    }

    # Summary
    Write-Banner "DEPLOYMENT COMPLETED SUCCESSFULLY" "Green"
    
    Write-Host "`n  Changes Applied:" -ForegroundColor White
    Write-Host "    - Created SSL Profile: $SslProfileName"
    Write-Host "    - Updated Listener: $ListenerName"
    Write-Host "    - Mode: PASSTHROUGH"
    
    Write-Host "`n  Current System State:" -ForegroundColor White
    Write-Host "    - MTLS PASSTHROUGH: ENABLED"
    Write-Host "    - Server variables: Will be populated when client provides cert"
    Write-Host "    - Rewrite headers: Will contain certificate data"
    Write-Host "    - Clients without certs: Can still connect (PASSTHROUGH mode)"
    
    Write-Host "`n  Next Steps:" -ForegroundColor White
    Write-Host "    1. Test with a client certificate:"
    Write-Host "       curl --cert client.crt --key client.key https://$($listener.HostName)/api/ex/test"
    Write-Host ""
    Write-Host "    2. Verify headers in APIM:"
    Write-Host "       - X-Client-Cert-Fingerprint should contain thumbprint"
    Write-Host "       - X-Client-Cert-Verification should be SUCCESS"
    Write-Host ""
    Write-Host "    3. Update APIM policy to validate certificate via headers"
    Write-Host "       (No change to negotiateClientCertificate required)"
    
    Write-Host "`n  Backup File:" -ForegroundColor White
    Write-Host "    $backupPath"
    
    Write-Host "`n  Rollback Command:" -ForegroundColor White
    Write-Host "    .\Rollback-MtlsPassthrough.ps1 -ResourceGroupName `"$ResourceGroupName`" -AppGatewayName `"$AppGatewayName`" -ListenerName `"$ListenerName`""
    Write-Host ""

} catch {
    Write-Err "Deployment failed: $($_.Exception.Message)"
    Write-Host "`n  Stack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    
    if ($backupPath -and (Test-Path $backupPath)) {
        Write-Host "`n  Backup file available at:" -ForegroundColor Yellow
        Write-Host "    $backupPath" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  To rollback, run:" -ForegroundColor Yellow
        Write-Host "    .\Rollback-MtlsPassthrough.ps1 -ResourceGroupName `"$ResourceGroupName`" -AppGatewayName `"$AppGatewayName`" -ListenerName `"$ListenerName`""
    }
    
    exit 1
}
