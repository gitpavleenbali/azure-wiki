<#
.SYNOPSIS
    Rollback MTLS PASSTHROUGH configuration from Application Gateway

.DESCRIPTION
    This script removes the MTLS PASSTHROUGH configuration by:
    1. Removing the SSL Profile reference from the listener
    2. Optionally removing the SSL Profile itself
    
    Use this script if the MTLS PASSTHROUGH deployment causes issues.

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

.PARAMETER BackupFile
    Path to a backup file to restore from (created by Deploy-MtlsPassthrough.ps1)

.PARAMETER WhatIf
    Show what would happen without making changes

.EXAMPLE
    # Rollback by removing SSL profile reference only
    .\Rollback-MtlsPassthrough.ps1 -ResourceGroupName "APINW-iaas-HUB-rgp-001" `
                                    -AppGatewayName "hub-uni-apim-npd-appgwv2-001" `
                                    -ListenerName "uniperapis-dev-gateway-listener-001"

.EXAMPLE
    # Rollback and also remove the SSL profile
    .\Rollback-MtlsPassthrough.ps1 -ResourceGroupName "APINW-iaas-HUB-rgp-001" `
                                    -AppGatewayName "hub-uni-apim-npd-appgwv2-001" `
                                    -ListenerName "uniperapis-dev-gateway-listener-001" `
                                    -RemoveSslProfile

.EXAMPLE
    # Preview what would happen
    .\Rollback-MtlsPassthrough.ps1 -ResourceGroupName "APINW-iaas-HUB-rgp-001" `
                                    -AppGatewayName "hub-uni-apim-npd-appgwv2-001" `
                                    -ListenerName "uniperapis-dev-gateway-listener-001" `
                                    -WhatIf

.NOTES
    Author: Pavleen Bali, Microsoft CSA
    Date: February 2026
    Version: 1.0
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
    [switch]$RemoveSslProfile,

    [Parameter(Mandatory = $false)]
    [string]$BackupFile,

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

# ============================================================================
# MAIN SCRIPT
# ============================================================================

try {
    Write-Banner "MTLS PASSTHROUGH ROLLBACK" "Yellow"
    Write-Host "`n  Configuration:" -ForegroundColor White
    Write-Host "    Resource Group:    $ResourceGroupName"
    Write-Host "    App Gateway:       $AppGatewayName"
    Write-Host "    Listener:          $ListenerName"
    Write-Host "    SSL Profile:       $SslProfileName"
    Write-Host "    Remove Profile:    $RemoveSslProfile"
    Write-Host "    WhatIf Mode:       $WhatIf"

    # Verify Azure connection
    Write-Step "Verifying Azure connection..."
    if (-not (Test-AzureConnection)) {
        Write-Err "Not connected to Azure. Please run 'Connect-AzAccount' first."
        exit 1
    }
    Write-Success "Azure connection verified"

    # Get current Application Gateway configuration
    Write-Step "Retrieving Application Gateway configuration..."
    $appGw = Get-AzApplicationGateway -ResourceGroupName $ResourceGroupName -Name $AppGatewayName -ErrorAction Stop
    Write-Success "Retrieved Application Gateway: $($appGw.Name)"
    Write-Info "Provisioning State: $($appGw.ProvisioningState)"
    Write-Info "SSL Profiles Count: $($appGw.SslProfiles.Count)"
    Write-Info "Listeners Count: $($appGw.HttpListeners.Count)"

    # Create pre-rollback backup
    Write-Step "Creating pre-rollback backup..."
    $backupPath = ".\BACKUP_PreRollback_$($AppGatewayName)_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    
    $backupData = @{
        Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss UTC")
        Operation = "Pre-Rollback Backup"
        AppGatewayName = $AppGatewayName
        ResourceGroupName = $ResourceGroupName
        SslProfiles = @($appGw.SslProfiles | ForEach-Object { 
            @{
                Name = $_.Name
                Id = $_.Id
                ClientAuthConfiguration = $_.ClientAuthConfiguration
            }
        })
        ListenerConfig = @($appGw.HttpListeners | Where-Object { $_.Name -eq $ListenerName } | ForEach-Object {
            @{
                Name = $_.Name
                Id = $_.Id
                SslProfileId = $_.SslProfile.Id
                Protocol = $_.Protocol
                HostName = $_.HostName
            }
        })
    }
    
    $backupData | ConvertTo-Json -Depth 10 | Out-File -FilePath $backupPath -Encoding UTF8
    Write-Success "Backup saved to: $backupPath"

    # Find the target listener
    Write-Step "Locating listener: $ListenerName..."
    $listener = $appGw.HttpListeners | Where-Object { $_.Name -eq $ListenerName }
    
    if (-not $listener) {
        Write-Err "Listener '$ListenerName' not found!"
        Write-Info "Available listeners:"
        $appGw.HttpListeners | ForEach-Object { Write-Info "  - $($_.Name)" }
        exit 1
    }
    Write-Success "Listener found: $($listener.Name)"
    
    if ($listener.SslProfile) {
        Write-Info "Current SSL Profile: $($listener.SslProfile.Id)"
    } else {
        Write-Warn "Listener has no SSL Profile attached (already rolled back?)"
    }

    # Check if SSL profile exists
    Write-Step "Checking for SSL profile: $SslProfileName..."
    $sslProfile = $appGw.SslProfiles | Where-Object { $_.Name -eq $SslProfileName }
    
    if ($sslProfile) {
        Write-Success "SSL Profile found: $($sslProfile.Name)"
    } else {
        Write-Warn "SSL Profile '$SslProfileName' not found"
    }

    # WhatIf mode check
    if ($WhatIf) {
        Write-Banner "WHATIF MODE - NO CHANGES WILL BE MADE" "Yellow"
        Write-Host "`n  Actions that WOULD be performed:" -ForegroundColor White
        Write-Host "    1. Remove SSL Profile reference from listener: $ListenerName"
        if ($RemoveSslProfile -and $sslProfile) {
            Write-Host "    2. Remove SSL Profile: $SslProfileName"
        }
        Write-Host "`n  Current State:" -ForegroundColor White
        Write-Host "    Listener SSL Profile: $($listener.SslProfile.Id ?? 'None')"
        Write-Host "    SSL Profile Exists: $($null -ne $sslProfile)"
        Write-Host "`n  Post-Rollback State:" -ForegroundColor White
        Write-Host "    Listener SSL Profile: None"
        Write-Host "    MTLS PASSTHROUGH: DISABLED"
        Write-Host "    Server Variables: Will return NULL"
        Write-Host "    Rewrite Headers: Will be empty"
        return
    }

    # Remove SSL Profile reference from listener
    Write-Step "Removing SSL Profile reference from listener..."
    
    $listenerIndex = 0
    $listenerFound = $false
    
    foreach ($l in $appGw.HttpListeners) {
        if ($l.Name -eq $ListenerName) {
            if ($l.SslProfile) {
                $appGw.HttpListeners[$listenerIndex].SslProfile = $null
                $listenerFound = $true
                Write-Success "SSL Profile reference removed from listener"
            } else {
                Write-Warn "Listener already has no SSL Profile reference"
                $listenerFound = $true
            }
            break
        }
        $listenerIndex++
    }
    
    if (-not $listenerFound) {
        Write-Err "Failed to find listener in array"
        exit 1
    }

    # Optionally remove SSL Profile
    if ($RemoveSslProfile) {
        Write-Step "Removing SSL Profile: $SslProfileName..."
        
        if ($sslProfile) {
            try {
                $appGw = Remove-AzApplicationGatewaySslProfile -ApplicationGateway $appGw -Name $SslProfileName
                Write-Success "SSL Profile removed"
            } catch {
                Write-Warn "Could not remove SSL Profile: $($_.Exception.Message)"
                Write-Info "This might happen if the profile is still referenced elsewhere"
            }
        } else {
            Write-Warn "SSL Profile not found - nothing to remove"
        }
    } else {
        Write-Step "Keeping SSL Profile (can be reused later)..."
        Write-Success "SSL Profile preserved"
    }

    # Apply changes to Application Gateway
    Write-Step "Applying rollback changes to Application Gateway..."
    Write-Host "  This operation typically takes 5-10 minutes..." -ForegroundColor Yellow
    Write-Host "  Please wait..." -ForegroundColor Yellow
    
    $startTime = Get-Date
    $result = Set-AzApplicationGateway -ApplicationGateway $appGw
    $duration = (Get-Date) - $startTime
    
    if ($result.ProvisioningState -eq "Succeeded") {
        Write-Success "Application Gateway updated successfully"
        Write-Info "Duration: $($duration.TotalMinutes.ToString('0.0')) minutes"
    } else {
        Write-Err "Update failed. Provisioning State: $($result.ProvisioningState)"
        exit 1
    }

    # Verify rollback
    Write-Step "Verifying rollback..."
    $verifyGw = Get-AzApplicationGateway -ResourceGroupName $ResourceGroupName -Name $AppGatewayName
    $verifyListener = $verifyGw.HttpListeners | Where-Object { $_.Name -eq $ListenerName }
    
    if (-not $verifyListener.SslProfile) {
        Write-Success "Listener verified: No SSL Profile attached"
    } else {
        Write-Warn "Listener still has SSL Profile attached: $($verifyListener.SslProfile.Id)"
    }
    
    if ($RemoveSslProfile) {
        $verifySslProfile = $verifyGw.SslProfiles | Where-Object { $_.Name -eq $SslProfileName }
        if (-not $verifySslProfile) {
            Write-Success "SSL Profile verified: Removed"
        } else {
            Write-Warn "SSL Profile still exists"
        }
    }

    # Summary
    Write-Banner "ROLLBACK COMPLETED SUCCESSFULLY" "Green"
    
    Write-Host "`n  Changes Applied:" -ForegroundColor White
    Write-Host "    - Removed SSL Profile reference from: $ListenerName"
    if ($RemoveSslProfile) {
        Write-Host "    - Removed SSL Profile: $SslProfileName"
    }
    
    Write-Host "`n  Current System State:" -ForegroundColor White
    Write-Host "    - MTLS PASSTHROUGH: DISABLED"
    Write-Host "    - Server variables: Will return NULL"
    Write-Host "    - Rewrite headers: Will be empty"
    Write-Host "    - Client certificates: Not captured by App Gateway"
    
    Write-Host "`n  Backup File:" -ForegroundColor White
    Write-Host "    $backupPath"
    
    Write-Host "`n  To Re-enable MTLS PASSTHROUGH:" -ForegroundColor White
    Write-Host "    Run: .\Deploy-MtlsPassthrough.ps1 -ResourceGroupName `"$ResourceGroupName`" -AppGatewayName `"$AppGatewayName`" -ListenerName `"$ListenerName`""
    Write-Host ""

} catch {
    Write-Err "Rollback failed: $($_.Exception.Message)"
    Write-Host "`n  Stack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    
    if ($backupPath -and (Test-Path $backupPath)) {
        Write-Host "`n  Pre-rollback backup available at:" -ForegroundColor Yellow
        Write-Host "    $backupPath" -ForegroundColor Yellow
    }
    
    Write-Host "`n  For manual rollback, use Azure Portal or CLI:" -ForegroundColor Yellow
    Write-Host "    az network application-gateway http-listener update --resource-group $ResourceGroupName --gateway-name $AppGatewayName --name $ListenerName --remove sslProfile" -ForegroundColor Yellow
    
    exit 1
}
