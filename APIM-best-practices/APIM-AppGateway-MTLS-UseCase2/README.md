# APIM + Application Gateway MTLS - Use Case 2
## PASSTHROUGH Mode Solution (Single Listener, No APIM Config Changes)

**Date:** February 16, 2026  
**Author:** Pavleen Bali, Cloud Solution Architect, Microsoft

---

## Customer Constraints Addressed

This solution addresses the following constraints:

| Constraint | Original Solution | This PASSTHROUGH Solution |
|------------|------------------|---------------------------|
| Multiple Listeners | Required | ✅ Uses EXISTING single listener |
| `negotiateClientCertificate=true` | Required | ✅ Stays `false` (NO change) |
| Impact on all clients | Affected all | ✅ Selective via APIM policy |
| CA Certificate Upload | Required | ✅ NOT required |

---

## Files in This Folder

| File | Description |
|------|-------------|
| [PASSTHROUGH_SOLUTION_GUIDE.md](PASSTHROUGH_SOLUTION_GUIDE.md) | Complete technical guide with Bicep changes, policies, and explanations |
| [Deploy-MtlsPassthrough.ps1](Deploy-MtlsPassthrough.ps1) | PowerShell script to deploy MTLS PASSTHROUGH mode |
| [Rollback-MtlsPassthrough.ps1](Rollback-MtlsPassthrough.ps1) | PowerShell script to rollback if issues occur |
| [arm-templates/mtls-passthrough-config.json](arm-templates/mtls-passthrough-config.json) | ARM template - SSL Profile configuration |
| [arm-templates/mtls-passthrough-deploy.json](arm-templates/mtls-passthrough-deploy.json) | ARM template - Full deployment with CLI commands |

---

## Quick Start

### Option 1: PowerShell Deployment (Recommended)

```powershell
# 1. Connect to Azure
Connect-AzAccount

# 2. Deploy MTLS PASSTHROUGH
.\Deploy-MtlsPassthrough.ps1 -ResourceGroupName "APINW-iaas-HUB-rgp-001" `
                              -AppGatewayName "hub-uni-apim-npd-appgwv2-001" `
                              -ListenerName "uniperapis-dev-gateway-listener-001"

# 3. If issues occur, rollback
.\Rollback-MtlsPassthrough.ps1 -ResourceGroupName "APINW-iaas-HUB-rgp-001" `
                                -AppGatewayName "hub-uni-apim-npd-appgwv2-001" `
                                -ListenerName "uniperapis-dev-gateway-listener-001"
```

### Option 2: Azure CLI

```bash
# Add SSL Profile with PASSTHROUGH mode
az network application-gateway ssl-profile add \
  --resource-group APINW-iaas-HUB-rgp-001 \
  --gateway-name hub-uni-apim-npd-appgwv2-001 \
  --name mtls-passthrough-profile \
  --policy-type Predefined \
  --policy-name AppGwSslPolicy20220101S \
  --client-auth-configuration verify-client-cert-issuer-dn=false

# Update listener to use SSL profile
az network application-gateway http-listener update \
  --resource-group APINW-iaas-HUB-rgp-001 \
  --gateway-name hub-uni-apim-npd-appgwv2-001 \
  --name uniperapis-dev-gateway-listener-001 \
  --ssl-profile mtls-passthrough-profile
```

---

## How It Works

```
┌──────────────┐     ┌──────────────────────────────────┐     ┌──────────────┐
│   Client     │────▶│  Application Gateway             │────▶│    APIM      │
│ (with cert)  │     │  ✅ SSL Profile (PASSTHROUGH)    │     │  negotiate:  │
│              │     │  ✅ Captures cert data           │     │  false       │
│              │     │  ✅ Adds headers                 │     │  (NO CHANGE) │
└──────────────┘     └──────────────────────────────────┘     └──────────────┘
                              │
                              ▼
                     Server Variables Populated:
                     - {var_client_certificate_fingerprint}
                     - {var_client_certificate_verification}
                              │
                              ▼
                     Rewrite Rules Add Headers:
                     - X-Client-Cert-Fingerprint: <thumbprint>
                     - X-Client-Cert-Verification: SUCCESS
                              │
                              ▼
                     APIM Policy Validates via Headers
                     (NOT via context.Request.Certificate)
```

---

## Key Benefits

1. **Single Listener** - No need for multiple listeners; existing listener is updated in-place
2. **No APIM Changes** - `negotiateClientCertificate` stays `false`
3. **Non-Breaking** - Clients without certificates can still connect (PASSTHROUGH mode)
4. **Rollback Ready** - Easy rollback script provided
5. **ARM Compatible** - Templates provided for infrastructure-as-code deployment

---

## Testing

After deployment, test with:

```bash
# With certificate (should succeed)
curl -v --cert client.crt --key client.key https://gateway-dev.apis.uniper.energy/api/ex/test

# Without certificate (depends on APIM policy)
curl -v https://gateway-dev.apis.uniper.energy/api/ex/test
```

---

## Rollback

If issues occur:

```powershell
.\Rollback-MtlsPassthrough.ps1 -ResourceGroupName "APINW-iaas-HUB-rgp-001" `
                                -AppGatewayName "hub-uni-apim-npd-appgwv2-001" `
                                -ListenerName "uniperapis-dev-gateway-listener-001"
```

Or via Azure CLI:

```bash
az network application-gateway http-listener update \
  --resource-group APINW-iaas-HUB-rgp-001 \
  --gateway-name hub-uni-apim-npd-appgwv2-001 \
  --name uniperapis-dev-gateway-listener-001 \
  --remove sslProfile
```

---

## Contact

For questions or issues, contact:
- **Pavleen Bali** - Cloud Solution Architect, Microsoft
