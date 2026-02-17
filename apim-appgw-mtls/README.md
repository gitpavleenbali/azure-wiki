# APIM ↔ Application Gateway Mutual TLS (mTLS) Authentication Issue

**Status:** ✅ RESOLVED - Complete Solution Delivered  
**Date:** January 23, 2026 (Updated: February 16, 2026)  
**Customer:** Uniper  
**Issue:** Mutual TLS authentication failing between Application Gateway and APIM

---

## 🆕 NEW: PASSTHROUGH Solution (February 2026)

**Customer Constraints Addressed:**
- ❌ Cannot have multiple listeners (single listener requirement)
- ❌ Cannot set `negotiateClientCertificate=true` (affects all clients)

**New Solution:** [PASSTHROUGH_SOLUTION_GUIDE.md](PASSTHROUGH_SOLUTION_GUIDE.md)

This alternative approach enables MTLS WITHOUT requiring:
1. Multiple listeners (uses existing single listener)
2. Changes to APIM `negotiateClientCertificate` (stays `false`)
3. Uploading trusted CA certificates to App Gateway

**Quick Deploy:**
```powershell
# Deploy PASSTHROUGH mode
.\Deploy-MtlsPassthrough.ps1 -ResourceGroupName "APINW-iaas-HUB-rgp-001" `
                              -AppGatewayName "hub-uni-apim-npd-appgwv2-001" `
                              -ListenerName "uniperapis-dev-gateway-listener-001"

# Rollback if needed
.\Rollback-MtlsPassthrough.ps1 -ResourceGroupName "APINW-iaas-HUB-rgp-001" `
                                -AppGatewayName "hub-uni-apim-npd-appgwv2-001" `
                                -ListenerName "uniperapis-dev-gateway-listener-001"
```

**ARM Templates:** See [arm-templates/](arm-templates/) folder

---

## 🎯 Problem Statement

External API requests through Application Gateway fail with **HTTP 403 Forbidden** error because mutual TLS authentication is not properly configured. While internal requests and sandbox environments work correctly, external traffic through the Application Gateway (WAF_v2) cannot authenticate using client certificates.

**Error Response:**
```json
{
  "error": "Client certificate required",
  "clientcert": null,
  "clientcertverification": "NONE",
  "clientcertfingerprint": null
}
```

---

## 🔍 Root Cause Analysis

### Three-Layer Misconfiguration Identified:

#### Layer 1: Application Gateway 🚪
**Issue:** SSL profile not configured for MTLS
- `sslProfiles: []` - Empty (should contain PASSTHROUGH profile)
- `trustedClientCertificates: []` - Empty
- HTTP listener doesn't reference any SSL profile
- **Result:** Gateway doesn't request or capture client certificates

#### Layer 2: APIM 🛡️
**Issue:** Certificate negotiation disabled
- `negotiateClientCertificate: false` - Should be `true`
- **Result:** APIM ignores incoming certificates, `context.Request.Certificate` stays null

#### Layer 3: Rewrite Rules 📝
**Issue:** Server variables return NULL
- Attempted to use: `{var_client_certificate_fingerprint}` 
- Returns NULL because prerequisites not met
- **Result:** Headers set to empty values

**Why All Three?**
```
Server Variables Populated Only When:
  1. SSL Profile Exists ✗ (missing)
  2. Listener References Profile ✗ (missing)  
  3. Client Sends Certificate ✗ (not requested)

Without ALL THREE: Variables = NULL
```

---

## ✅ Solution Overview

### MTLS PASSTHROUGH Mode Implementation

Deploy a three-component fix:

**1. Application Gateway:** Add SSL Profile
- Creates PASSTHROUGH configuration
- Enables certificate capture during TLS
- Populates server variables with certificate data

**2. APIM:** Enable Certificate Negotiation  
- Changes `negotiateClientCertificate: false` → `true`
- Enables `context.Request.Certificate` population
- APIM can now process certificates

**3. APIM Policy:** Update Validation Logic
- Validates certificate from native context
- Falls back to header-based validation
- Returns 403 for invalid/missing certificates

---

## 📚 Documentation Provided

### 1. **EXECUTIVE_SUMMARY.md** 
Quick overview of research findings and solution  
**For:** Stakeholders, management, decision makers

### 2. **COMPREHENSIVE_MTLS_RESEARCH.md**
Deep technical analysis of MTLS mechanisms  
**For:** Solution architects, technical leads

### 3. **MTLS_CONFIGURATION_ANALYSIS.md**
Infrastructure gap analysis with specific fixes  
**For:** Infrastructure team, DevOps engineers

### 4. **APIM_POLICY_ANALYSIS.md**
Policy logic explanation and improvements  
**For:** APIM developers, policy architects

### 5. **SOLUTION_IMPLEMENTATION_GUIDE.md**
Step-by-step implementation with exact line numbers  
**For:** Operations, DevOps, deployment team

### 6. **DELIVERABLES_INDEX.md**
Complete index and usage guide for all documents  
**For:** Project managers, team leads

### 7. **PASSTHROUGH_SOLUTION_GUIDE.md** (NEW - Feb 2026)
Alternative solution for single-listener, no-negotiateClientCertificate constraint  
**For:** Customers who cannot change APIM settings or use multiple listeners

### 8. **Deploy-MtlsPassthrough.ps1** (NEW - Feb 2026)
PowerShell deployment script for PASSTHROUGH mode  
**For:** Operations team, automated deployment

### 9. **Rollback-MtlsPassthrough.ps1** (NEW - Feb 2026)
PowerShell rollback script for PASSTHROUGH mode  
**For:** Operations team, incident response

### 10. **arm-templates/** (NEW - Feb 2026)
ARM templates for infrastructure-as-code deployment  
**For:** DevOps teams requiring ARM-based deployment

---

## 🚀 Quick Start Implementation

### For the Impatient (30-Minute Overview):

1. **Read:** EXECUTIVE_SUMMARY.md (10 min)
2. **Read:** DELIVERABLES_INDEX.md usage guide (5 min)
3. **Review:** SOLUTION_IMPLEMENTATION_GUIDE.md changes section (15 min)

### For Full Understanding (2-Hour Deep Dive):

1. Read EXECUTIVE_SUMMARY.md (15 min)
2. Read COMPREHENSIVE_MTLS_RESEARCH.md (45 min)
3. Read SOLUTION_IMPLEMENTATION_GUIDE.md (60 min)
4. Review MTLS_CONFIGURATION_ANALYSIS.md specifics (20 min)

---

## 📝 Required Bicep Changes

### Application Gateway (mainAPINW.bicep)

**Change 1:** Add SSL Profile (~line 224)
```bicep
sslProfiles: [
  {
    name: 'mtls-passthrough-profile'
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

**Change 2:** Update Listeners
- Add `sslProfile` reference to gateway listeners
- Affected lines: ~531, ~551, ~591

### APIM (APIMHub.bicep)

**Change 1:** Enable Certificate Negotiation (~line 103)
```bicep
negotiateClientCertificate: false  →  negotiateClientCertificate: true
```

---

## 🧪 Testing Strategy

### Phase 1: Dev Environment
```
Deploy Changes → Test Certificate Flow → Verify Logs → Document Results
```

### Phase 2: UAT Environment
```
Deploy Changes → Test with Real Certs → Performance Test → Security Review
```

### Phase 3: Production
```
Schedule Window → Deploy → Monitor → Validate → Communicate
```

### Test Scenarios

**Test 1: No Certificate**
```powershell
curl https://gateway-dev.apis.uniper.energy/api/...
# Expected: 403 Forbidden
```

**Test 2: Valid Certificate**
```powershell
curl --cert client.pem https://gateway-dev.apis.uniper.energy/api/...
# Expected: 200 OK (with valid thumbprint)
```

**Test 3: Invalid Certificate**
```powershell
curl --cert wrong.pem https://gateway-dev.apis.uniper.energy/api/...
# Expected: 403 Forbidden
```

---

## 🛠️ Troubleshooting Quick Links

| Issue | Document | Section |
|-------|----------|---------|
| Policy always returns 403 | SOLUTION_IMPLEMENTATION_GUIDE | Troubleshooting |
| Server variables are NULL | COMPREHENSIVE_MTLS_RESEARCH | Why NULL? |
| Certificate data in headers | APIM_POLICY_ANALYSIS | Header validation |
| Thumbprint mismatch | SOLUTION_IMPLEMENTATION_GUIDE | Troubleshooting |

---

## 🔄 Expected Data Flow After Implementation

```
┌──────────────┐
│ External     │ (sends certificate)
│ Client       │
└──────┬───────┘
       │ HTTPS with client cert
       ↓
┌──────────────────────────────┐
│ Application Gateway          │
│ - Receives certificate       │ (SSL Profile processes it)
│ - Captures cert data         │
│ - Populates server variables │
│ - Adds headers with cert     │
└──────┬───────────────────────┘
       │ Request with X-Client-Cert-* headers
       ↓
┌──────────────────────────────┐
│ APIM                         │
│ - Receives native certificate│ (TLS negotiation)
│ - Receives headers (fallback)│
│ - Extracts thumbprint        │
│ - Validates against expected │
│ - Returns 200 or 403         │
└──────┬───────────────────────┘
       │ Authenticated request
       ↓
┌──────────────────────────────┐
│ Backend Service              │
│ (Receives authorized request)│
└──────────────────────────────┘
```

---

## 📊 Implementation Checklist

### Pre-Deployment
- [ ] Review all documentation
- [ ] Backup current Bicep files
- [ ] Document current state
- [ ] Get expected certificate thumbprints
- [ ] Notify operations team
- [ ] Schedule change window

### Deployment
- [ ] Deploy App Gateway changes (mainAPINW.bicep)
- [ ] Deploy APIM changes (APIMHub.bicep)
- [ ] Update APIM policy
- [ ] Validate deployment
- [ ] Check logs for errors

### Post-Deployment
- [ ] Run all 3 test scenarios
- [ ] Verify logs contain cert data
- [ ] Check performance metrics
- [ ] Notify users
- [ ] Document in runbooks

---

## 📞 Support Matrix

| Issue Type | Primary Source | Secondary Source |
|-----------|----------------|-----------------|
| Bicep Changes | SOLUTION_IMPLEMENTATION_GUIDE | MTLS_CONFIGURATION_ANALYSIS |
| Policy Logic | APIM_POLICY_ANALYSIS | SOLUTION_IMPLEMENTATION_GUIDE |
| Server Variables | COMPREHENSIVE_MTLS_RESEARCH | Microsoft Docs |
| Testing | SOLUTION_IMPLEMENTATION_GUIDE | DELIVERABLES_INDEX |
| Troubleshooting | SOLUTION_IMPLEMENTATION_GUIDE | COMPREHENSIVE_MTLS_RESEARCH |

---

## 🎓 Key Learnings

### What You'll Learn
1. **How MTLS works in Azure** - PASSTHROUGH vs STRICT modes
2. **Why current setup fails** - Configuration gaps in all three layers
3. **How to fix it** - Exact Bicep changes needed
4. **How to test it** - Test scenarios and verification procedures
5. **How to troubleshoot** - Diagnostic procedures and common issues

### Key Insights
- ✅ Server variables require three prerequisites to populate
- ✅ APIM needs both native context AND header validation
- ✅ PASSTHROUGH mode perfect for delegated validation
- ✅ Dual validation (native + headers) most robust
- ✅ Proper logging critical for troubleshooting

---

## 🔗 References

- [Microsoft Learn: Mutual Authentication Overview](https://learn.microsoft.com/en-us/azure/application-gateway/mutual-authentication-overview)
- [Microsoft Learn: Server Variables](https://learn.microsoft.com/en-us/azure/application-gateway/rewrite-http-headers-url#mutual-authentication-server-variables)
- API Version Required: `2025-03-01` or later
- SKU Supported: WAF_v2 (your current setup ✓)

---

## 📞 Next Steps

1. **Review:** Read EXECUTIVE_SUMMARY.md (15 min)
2. **Decide:** Approve solution approach with stakeholders
3. **Plan:** Schedule development environment testing
4. **Deploy:** Follow SOLUTION_IMPLEMENTATION_GUIDE.md
5. **Test:** Execute all test scenarios
6. **Iterate:** Move through Dev → UAT → Production phases

---

## ✨ Success Criteria

After implementation, the following will be true:

- ✅ External clients can authenticate with client certificates
- ✅ Application Gateway captures and forwards certificate data
- ✅ APIM validates certificate thumbprints correctly
- ✅ Invalid certificates rejected with helpful 403 response
- ✅ Valid certificates allowed through to backend
- ✅ Logs contain sufficient diagnostic information
- ✅ Performance unaffected
- ✅ Team confident in operation and troubleshooting

---

## 🏁 Summary

**Problem:** MTLS authentication failing due to misconfigured infrastructure and APIM settings

**Root Cause:** Three-layer configuration gap (App Gateway, APIM, policies)

**Solution:** Implement PASSTHROUGH mode with proper certificate handling

**Status:** ✅ Complete solution designed, documented, and ready for implementation

**Next Action:** Proceed to development environment testing

---

**Created:** January 23, 2026  
**Version:** 1.0 - Final  
**Status:** Ready for Deployment  
**Confidence:** High (Based on Microsoft best practices)

For detailed implementation instructions, see **SOLUTION_IMPLEMENTATION_GUIDE.md**
