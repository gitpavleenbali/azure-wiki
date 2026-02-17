# ============================================================================
# MTLS Solution Validation Script
# ============================================================================
# Purpose: Deploy and test MTLS configuration in a test Azure subscription
# Author: Pavleen Bali (CSA)
# Date: January 2026
# ============================================================================

#Requires -Modules Az.Network, Az.ApiManagement

# ============================================================================
# CONFIGURATION - UPDATE THESE VALUES FOR YOUR TEST ENVIRONMENT
# ============================================================================

$Config = @{
    # Resource Group
    ResourceGroupName = "rg-mtls-validation-test"
    Location = "westeurope"
    
    # Application Gateway
    AppGwName = "appgw-mtls-test"
    AppGwSubnetName = "subnet-appgw"
    AppGwSubnetPrefix = "10.0.1.0/24"
    AppGwPublicIpName = "pip-appgw-mtls-test"
    
    # APIM
    ApimName = "apim-mtls-test-$(Get-Random -Maximum 9999)"
    ApimSubnetName = "subnet-apim"
    ApimSubnetPrefix = "10.0.2.0/24"
    ApimPublisherEmail = "pavleen.bali@microsoft.com"
    ApimPublisherName = "MTLS Test"
    
    # Virtual Network
    VNetName = "vnet-mtls-test"
    VNetAddressPrefix = "10.0.0.0/16"
    
    # Certificate paths (update these)
    # For testing, we'll generate self-signed certificates
    CertOutputPath = "C:\temp\mtls-certs"
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "=" * 70 -ForegroundColor Cyan
    Write-Host "STEP: $Message" -ForegroundColor Cyan
    Write-Host "=" * 70 -ForegroundColor Cyan
}

function Write-SubStep {
    param([string]$Message)
    Write-Host "  → $Message" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "  ✗ $Message" -ForegroundColor Red
}

# ============================================================================
# STEP 0: Generate Test Certificates
# ============================================================================

function New-TestCertificates {
    Write-Step "Generating Test Certificates"
    
    # Create output directory
    if (-not (Test-Path $Config.CertOutputPath)) {
        New-Item -ItemType Directory -Path $Config.CertOutputPath -Force | Out-Null
    }
    
    # Generate CA Certificate (Root)
    Write-SubStep "Creating Root CA Certificate..."
    $CaParams = @{
        Type = 'Custom'
        Subject = 'CN=MTLS-Test-CA,O=Microsoft CSA,C=US'
        KeySpec = 'Signature'
        KeyExportPolicy = 'Exportable'
        KeyUsage = 'CertSign'
        KeyUsageProperty = 'Sign'
        KeyLength = 2048
        HashAlgorithm = 'SHA256'
        NotAfter = (Get-Date).AddYears(5)
        CertStoreLocation = 'Cert:\CurrentUser\My'
        TextExtension = @("2.5.29.19={critical}{text}ca=TRUE")
    }
    $CaCert = New-SelfSignedCertificate @CaParams
    Write-Success "CA Certificate created: $($CaCert.Thumbprint)"
    
    # Export CA Certificate (for Application Gateway trusted client certs)
    $CaCertPath = Join-Path $Config.CertOutputPath "ca-certificate.cer"
    Export-Certificate -Cert $CaCert -FilePath $CaCertPath -Type CERT | Out-Null
    Write-Success "CA Certificate exported to: $CaCertPath"
    
    # Generate Client Certificate (signed by CA)
    Write-SubStep "Creating Client Certificate..."
    $ClientParams = @{
        Type = 'Custom'
        Subject = 'CN=MTLS-Test-Client,O=Test Client,C=US'
        KeySpec = 'Signature'
        KeyExportPolicy = 'Exportable'
        KeyUsage = 'DigitalSignature'
        KeyLength = 2048
        HashAlgorithm = 'SHA256'
        NotAfter = (Get-Date).AddYears(1)
        CertStoreLocation = 'Cert:\CurrentUser\My'
        Signer = $CaCert
        TextExtension = @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")
    }
    $ClientCert = New-SelfSignedCertificate @ClientParams
    Write-Success "Client Certificate created: $($ClientCert.Thumbprint)"
    
    # Export Client Certificate as PFX (for API testing)
    $ClientPfxPath = Join-Path $Config.CertOutputPath "client-certificate.pfx"
    $PfxPassword = ConvertTo-SecureString -String "TestPassword123!" -Force -AsPlainText
    Export-PfxCertificate -Cert $ClientCert -FilePath $ClientPfxPath -Password $PfxPassword | Out-Null
    Write-Success "Client Certificate exported to: $ClientPfxPath"
    
    # Generate Server Certificate (for Application Gateway SSL)
    Write-SubStep "Creating Server/SSL Certificate..."
    $ServerParams = @{
        DnsName = "mtls-test.local", "localhost"
        Subject = 'CN=mtls-test.local'
        KeySpec = 'KeyExchange'
        KeyExportPolicy = 'Exportable'
        KeyUsage = 'DigitalSignature', 'KeyEncipherment'
        KeyLength = 2048
        HashAlgorithm = 'SHA256'
        NotAfter = (Get-Date).AddYears(1)
        CertStoreLocation = 'Cert:\CurrentUser\My'
    }
    $ServerCert = New-SelfSignedCertificate @ServerParams
    Write-Success "Server Certificate created: $($ServerCert.Thumbprint)"
    
    # Export Server Certificate as PFX
    $ServerPfxPath = Join-Path $Config.CertOutputPath "server-certificate.pfx"
    Export-PfxCertificate -Cert $ServerCert -FilePath $ServerPfxPath -Password $PfxPassword | Out-Null
    Write-Success "Server Certificate exported to: $ServerPfxPath"
    
    # Return certificate info
    return @{
        CaCert = $CaCert
        CaCertPath = $CaCertPath
        ClientCert = $ClientCert
        ClientPfxPath = $ClientPfxPath
        ServerCert = $ServerCert
        ServerPfxPath = $ServerPfxPath
        PfxPassword = $PfxPassword
    }
}

# ============================================================================
# STEP 1: Create Resource Group
# ============================================================================

function New-TestResourceGroup {
    Write-Step "Creating Resource Group"
    
    $Rg = Get-AzResourceGroup -Name $Config.ResourceGroupName -ErrorAction SilentlyContinue
    if ($Rg) {
        Write-SubStep "Resource group already exists, skipping..."
        return $Rg
    }
    
    $Rg = New-AzResourceGroup -Name $Config.ResourceGroupName -Location $Config.Location
    Write-Success "Resource group created: $($Config.ResourceGroupName)"
    return $Rg
}

# ============================================================================
# STEP 2: Create Virtual Network
# ============================================================================

function New-TestVirtualNetwork {
    Write-Step "Creating Virtual Network"
    
    $VNet = Get-AzVirtualNetwork -Name $Config.VNetName -ResourceGroupName $Config.ResourceGroupName -ErrorAction SilentlyContinue
    if ($VNet) {
        Write-SubStep "Virtual network already exists, skipping..."
        return $VNet
    }
    
    # Create subnets
    $AppGwSubnet = New-AzVirtualNetworkSubnetConfig -Name $Config.AppGwSubnetName -AddressPrefix $Config.AppGwSubnetPrefix
    $ApimSubnet = New-AzVirtualNetworkSubnetConfig -Name $Config.ApimSubnetName -AddressPrefix $Config.ApimSubnetPrefix
    
    # Create VNet
    $VNet = New-AzVirtualNetwork `
        -Name $Config.VNetName `
        -ResourceGroupName $Config.ResourceGroupName `
        -Location $Config.Location `
        -AddressPrefix $Config.VNetAddressPrefix `
        -Subnet $AppGwSubnet, $ApimSubnet
    
    Write-Success "Virtual network created: $($Config.VNetName)"
    return $VNet
}

# ============================================================================
# STEP 3: Create Application Gateway with MTLS
# ============================================================================

function New-TestApplicationGateway {
    param($Certs)
    
    Write-Step "Creating Application Gateway with MTLS Configuration"
    
    $AppGw = Get-AzApplicationGateway -Name $Config.AppGwName -ResourceGroupName $Config.ResourceGroupName -ErrorAction SilentlyContinue
    if ($AppGw) {
        Write-SubStep "Application Gateway already exists, skipping creation..."
        return $AppGw
    }
    
    # Get subnet
    $VNet = Get-AzVirtualNetwork -Name $Config.VNetName -ResourceGroupName $Config.ResourceGroupName
    $AppGwSubnet = Get-AzVirtualNetworkSubnetConfig -Name $Config.AppGwSubnetName -VirtualNetwork $VNet
    
    # Create public IP
    Write-SubStep "Creating Public IP..."
    $PublicIp = New-AzPublicIpAddress `
        -Name $Config.AppGwPublicIpName `
        -ResourceGroupName $Config.ResourceGroupName `
        -Location $Config.Location `
        -Sku Standard `
        -AllocationMethod Static
    
    # Create IP configuration
    $GatewayIpConfig = New-AzApplicationGatewayIPConfiguration `
        -Name "appGwIpConfig" `
        -Subnet $AppGwSubnet
    
    # Create frontend IP configuration
    $FrontendIpConfig = New-AzApplicationGatewayFrontendIPConfig `
        -Name "appGwFrontendIp" `
        -PublicIPAddress $PublicIp
    
    # Create frontend ports
    $FrontendPort80 = New-AzApplicationGatewayFrontendPort -Name "port80" -Port 80
    $FrontendPort443 = New-AzApplicationGatewayFrontendPort -Name "port443" -Port 443
    
    # Create SSL certificate for HTTPS listener
    Write-SubStep "Configuring SSL certificate..."
    $SslCert = New-AzApplicationGatewaySslCertificate `
        -Name "server-ssl-cert" `
        -CertificateFile $Certs.ServerPfxPath `
        -Password $Certs.PfxPassword
    
    # =========================================================================
    # THIS IS THE KEY MTLS CONFIGURATION
    # =========================================================================
    
    # Create trusted client certificate (CA cert for validating client certs)
    Write-SubStep "Adding Trusted Client CA Certificate..."
    $TrustedClientCert = New-AzApplicationGatewayTrustedClientCertificate `
        -Name "client-ca-cert" `
        -CertificateFile $Certs.CaCertPath
    
    # Create client authentication configuration
    Write-SubStep "Creating Client Authentication Configuration..."
    $ClientAuthConfig = New-AzApplicationGatewayClientAuthConfiguration `
        -VerifyClientCertIssuerDN
    
    # Create SSL profile with MTLS
    Write-SubStep "Creating SSL Profile with Mutual TLS..."
    $SslPolicy = New-AzApplicationGatewaySslPolicy `
        -PolicyType Predefined `
        -PolicyName AppGwSslPolicy20220101S
    
    $SslProfile = New-AzApplicationGatewaySslProfile `
        -Name "mtls-ssl-profile" `
        -SslPolicy $SslPolicy `
        -TrustedClientCertificate $TrustedClientCert `
        -ClientAuthConfiguration $ClientAuthConfig
    
    # =========================================================================
    
    # Create HTTP listener (for redirect)
    $HttpListener = New-AzApplicationGatewayHttpListener `
        -Name "http-listener" `
        -Protocol Http `
        -FrontendIPConfiguration $FrontendIpConfig `
        -FrontendPort $FrontendPort80
    
    # Create HTTPS listener WITH SSL PROFILE (MTLS enabled)
    Write-SubStep "Creating HTTPS Listener with MTLS SSL Profile..."
    $HttpsListener = New-AzApplicationGatewayHttpListener `
        -Name "https-listener-mtls" `
        -Protocol Https `
        -FrontendIPConfiguration $FrontendIpConfig `
        -FrontendPort $FrontendPort443 `
        -SslCertificate $SslCert `
        -SslProfile $SslProfile
    
    # Create backend pool (dummy for now)
    $BackendPool = New-AzApplicationGatewayBackendAddressPool `
        -Name "backend-pool" `
        -BackendIPAddresses "10.0.2.4"
    
    # Create backend HTTP settings
    $BackendHttpSettings = New-AzApplicationGatewayBackendHttpSetting `
        -Name "backend-http-settings" `
        -Port 443 `
        -Protocol Https `
        -CookieBasedAffinity Disabled `
        -RequestTimeout 30
    
    # Create routing rules
    $HttpRule = New-AzApplicationGatewayRequestRoutingRule `
        -Name "http-rule" `
        -RuleType Basic `
        -Priority 100 `
        -HttpListener $HttpListener `
        -BackendAddressPool $BackendPool `
        -BackendHttpSettings $BackendHttpSettings
    
    $HttpsRule = New-AzApplicationGatewayRequestRoutingRule `
        -Name "https-mtls-rule" `
        -RuleType Basic `
        -Priority 200 `
        -HttpListener $HttpsListener `
        -BackendAddressPool $BackendPool `
        -BackendHttpSettings $BackendHttpSettings
    
    # Create SKU
    $Sku = New-AzApplicationGatewaySku -Name WAF_v2 -Tier WAF_v2 -Capacity 1
    
    # Create the Application Gateway
    Write-SubStep "Deploying Application Gateway (this may take 15-20 minutes)..."
    $AppGw = New-AzApplicationGateway `
        -Name $Config.AppGwName `
        -ResourceGroupName $Config.ResourceGroupName `
        -Location $Config.Location `
        -Sku $Sku `
        -GatewayIPConfigurations $GatewayIpConfig `
        -FrontendIPConfigurations $FrontendIpConfig `
        -FrontendPorts $FrontendPort80, $FrontendPort443 `
        -SslCertificates $SslCert `
        -TrustedClientCertificates $TrustedClientCert `
        -SslProfiles $SslProfile `
        -HttpListeners $HttpListener, $HttpsListener `
        -BackendAddressPools $BackendPool `
        -BackendHttpSettingsCollection $BackendHttpSettings `
        -RequestRoutingRules $HttpRule, $HttpsRule
    
    Write-Success "Application Gateway created with MTLS enabled!"
    return $AppGw
}

# ============================================================================
# STEP 4: Verify MTLS Configuration
# ============================================================================

function Test-MtlsConfiguration {
    param($Certs)
    
    Write-Step "Verifying MTLS Configuration"
    
    $AppGw = Get-AzApplicationGateway -Name $Config.AppGwName -ResourceGroupName $Config.ResourceGroupName
    
    # Check trusted client certificates
    Write-SubStep "Checking Trusted Client Certificates..."
    if ($AppGw.TrustedClientCertificates.Count -gt 0) {
        Write-Success "Trusted client certificates configured: $($AppGw.TrustedClientCertificates.Count)"
        foreach ($cert in $AppGw.TrustedClientCertificates) {
            Write-Host "    - $($cert.Name)" -ForegroundColor Gray
        }
    } else {
        Write-Error "No trusted client certificates found!"
    }
    
    # Check SSL profiles
    Write-SubStep "Checking SSL Profiles..."
    if ($AppGw.SslProfiles.Count -gt 0) {
        Write-Success "SSL profiles configured: $($AppGw.SslProfiles.Count)"
        foreach ($profile in $AppGw.SslProfiles) {
            Write-Host "    - $($profile.Name)" -ForegroundColor Gray
            if ($profile.ClientAuthConfiguration) {
                Write-Host "      VerifyClientCertIssuerDN: $($profile.ClientAuthConfiguration.VerifyClientCertIssuerDN)" -ForegroundColor Gray
            }
        }
    } else {
        Write-Error "No SSL profiles found!"
    }
    
    # Check HTTPS listener has SSL profile
    Write-SubStep "Checking HTTPS Listener SSL Profile..."
    $HttpsListener = $AppGw.HttpListeners | Where-Object { $_.Name -eq "https-listener-mtls" }
    if ($HttpsListener.SslProfile) {
        Write-Success "HTTPS listener has SSL profile attached!"
    } else {
        Write-Error "HTTPS listener does NOT have SSL profile!"
    }
    
    return $AppGw
}

# ============================================================================
# STEP 5: Test API Call with Client Certificate
# ============================================================================

function Test-MtlsApiCall {
    param($Certs)
    
    Write-Step "Testing API Call with Client Certificate"
    
    # Get public IP of Application Gateway
    $PublicIp = Get-AzPublicIpAddress -Name $Config.AppGwPublicIpName -ResourceGroupName $Config.ResourceGroupName
    $AppGwIp = $PublicIp.IpAddress
    
    Write-SubStep "Application Gateway IP: $AppGwIp"
    
    # Load client certificate
    $ClientCert = Get-PfxCertificate -FilePath $Certs.ClientPfxPath -Password $Certs.PfxPassword
    
    Write-SubStep "Client Certificate Thumbprint: $($ClientCert.Thumbprint)"
    
    # Note: For a real test, you would need a backend that can receive the request
    # For now, we'll just verify the certificate can be loaded and used
    
    Write-Host ""
    Write-Host "To test the full MTLS flow, run this curl command:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "curl -v --insecure --cert `"$($Certs.ClientPfxPath)`":TestPassword123! https://$AppGwIp/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or use PowerShell:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host @"
`$cert = Get-PfxCertificate -FilePath "$($Certs.ClientPfxPath)"
Invoke-WebRequest -Uri "https://$AppGwIp/" -Certificate `$cert -SkipCertificateCheck
"@ -ForegroundColor Cyan
    
    return @{
        AppGwIp = $AppGwIp
        ClientCertThumbprint = $ClientCert.Thumbprint
    }
}

# ============================================================================
# STEP 6: Cleanup
# ============================================================================

function Remove-TestResources {
    Write-Step "Cleaning Up Test Resources"
    
    $Confirm = Read-Host "Are you sure you want to delete all test resources? (yes/no)"
    if ($Confirm -ne "yes") {
        Write-SubStep "Cleanup cancelled."
        return
    }
    
    Write-SubStep "Deleting resource group (this will delete all resources)..."
    Remove-AzResourceGroup -Name $Config.ResourceGroupName -Force -AsJob
    
    Write-Success "Cleanup initiated. Resource group deletion is running in background."
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Start-MtlsValidation {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║                    MTLS SOLUTION VALIDATION                        ║" -ForegroundColor Magenta
    Write-Host "║                                                                    ║" -ForegroundColor Magenta
    Write-Host "║  This script will deploy and test MTLS configuration to validate  ║" -ForegroundColor Magenta
    Write-Host "║  the solution before recommending to the customer.                 ║" -ForegroundColor Magenta
    Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    
    # Check Azure connection
    $Context = Get-AzContext
    if (-not $Context) {
        Write-Error "Not connected to Azure. Please run Connect-AzAccount first."
        return
    }
    Write-Success "Connected to Azure: $($Context.Subscription.Name)"
    
    # Execute steps
    try {
        # Step 0: Generate certificates
        $Certs = New-TestCertificates
        
        # Step 1: Create resource group
        $Rg = New-TestResourceGroup
        
        # Step 2: Create virtual network
        $VNet = New-TestVirtualNetwork
        
        # Step 3: Create Application Gateway with MTLS
        $AppGw = New-TestApplicationGateway -Certs $Certs
        
        # Step 4: Verify configuration
        Test-MtlsConfiguration -Certs $Certs
        
        # Step 5: Test API call
        $TestResult = Test-MtlsApiCall -Certs $Certs
        
        Write-Host ""
        Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║                    VALIDATION COMPLETE                             ║" -ForegroundColor Green
        Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host ""
        Write-Host "Summary:" -ForegroundColor Green
        Write-Host "  - Resource Group: $($Config.ResourceGroupName)" -ForegroundColor White
        Write-Host "  - Application Gateway: $($Config.AppGwName)" -ForegroundColor White
        Write-Host "  - MTLS SSL Profile: mtls-ssl-profile" -ForegroundColor White
        Write-Host "  - Public IP: $($TestResult.AppGwIp)" -ForegroundColor White
        Write-Host "  - Client Cert Thumbprint: $($TestResult.ClientCertThumbprint)" -ForegroundColor White
        Write-Host ""
        Write-Host "Certificates saved to: $($Config.CertOutputPath)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "To cleanup, run: Remove-TestResources" -ForegroundColor Cyan
        
    } catch {
        Write-Error "Validation failed: $_"
        throw
    }
}

# ============================================================================
# INSTRUCTIONS
# ============================================================================
<#
USAGE:

1. Open PowerShell as Administrator

2. Connect to Azure:
   Connect-AzAccount

3. Select your subscription:
   Set-AzContext -SubscriptionId "your-subscription-id"

4. Run the validation:
   . .\Validate-MtlsSolution.ps1
   Start-MtlsValidation

5. When finished, cleanup:
   Remove-TestResources

#>

# Auto-execute when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Start-MtlsValidation
}
