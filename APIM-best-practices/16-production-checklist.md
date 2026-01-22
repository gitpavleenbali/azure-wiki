# 16 - Production Checklist

> Comprehensive go-live readiness checklist for Azure API Management

---

## 🎯 Overview

This checklist consolidates all production readiness requirements across WAF pillars. Use it as your **final gate before go-live**.

---

## ✅ Pre-Production Checklist

### 🏗️ Architecture & Design

| Item | Priority | Status |
|------|:--------:|:------:|
| Tier selected based on requirements (Premium for VNet/zones) | 🔴 Critical | ☐ |
| Network topology designed (hub-spoke, VNet integration) | 🔴 Critical | ☐ |
| VNet integration mode selected (Internal recommended) | 🔴 Critical | ☐ |
| Subnet sizing validated (/27 minimum, /26 recommended) | 🔴 Critical | ☐ |
| Private DNS zones configured | 🔴 Critical | ☐ |
| Application Gateway/Front Door in front of APIM | 🟡 High | ☐ |
| Backend services accessible via private endpoints | 🟡 High | ☐ |
| Self-hosted gateway planned (if hybrid required) | 🟢 Medium | ☐ |

### 🔵 Reliability

| Item | Priority | Status |
|------|:--------:|:------:|
| Zone redundancy enabled (Premium, min 2 units) | 🔴 Critical | ☐ |
| Multi-region deployment configured (if required) | 🟡 High | ☐ |
| Minimum 2 scale units for production | 🔴 Critical | ☐ |
| Autoscaling rules configured | 🟡 High | ☐ |
| Capacity alerts configured (>70%, >80%) | 🔴 Critical | ☐ |
| Backend circuit breakers implemented | 🟡 High | ☐ |
| Retry policies configured | 🟡 High | ☐ |
| Backup schedule configured | 🔴 Critical | ☐ |
| DR runbook documented | 🔴 Critical | ☐ |
| RTO/RPO requirements validated | 🔴 Critical | ☐ |
| Failover procedure tested | 🟡 High | ☐ |

### 🔴 Security

| Item | Priority | Status |
|------|:--------:|:------:|
| TLS 1.2+ enforced (legacy protocols disabled) | 🔴 Critical | ☐ |
| Weak ciphers disabled | 🔴 Critical | ☐ |
| WAF v2 configured (OWASP 3.2 ruleset) | 🔴 Critical | ☐ |
| DDoS Protection Standard enabled | 🟡 High | ☐ |
| OAuth 2.0 / JWT validation configured | 🔴 Critical | ☐ |
| Managed identities configured (no secrets in code) | 🔴 Critical | ☐ |
| Secrets stored in Key Vault | 🔴 Critical | ☐ |
| Named values reference Key Vault | 🔴 Critical | ☐ |
| Custom domain certificates in Key Vault | 🟡 High | ☐ |
| Certificate rotation automated | 🟡 High | ☐ |
| Direct management API disabled | 🔴 Critical | ☐ |
| Developer portal anonymous access disabled | 🟡 High | ☐ |
| Microsoft Defender for APIs enabled | 🟡 High | ☐ |
| NSG rules configured for APIM subnet | 🔴 Critical | ☐ |
| Backend validates APIM origin (certificate/header) | 🟡 High | ☐ |
| API tracing disabled in production | 🔴 Critical | ☐ |
| Subscription keys rotated from defaults | 🔴 Critical | ☐ |
| Content validation policies applied | 🟡 High | ☐ |
| IP filtering configured (if required) | 🟢 Medium | ☐ |
| CORS policy defined | 🟢 Medium | ☐ |

### 🟡 Cost Optimization

| Item | Priority | Status |
|------|:--------:|:------:|
| Tier right-sized for workload | 🟡 High | ☐ |
| Scale units optimized | 🟡 High | ☐ |
| Dev/Test using Developer tier | 🟢 Medium | ☐ |
| Budget alerts configured | 🟡 High | ☐ |
| Cost allocation tags applied | 🟡 High | ☐ |
| Reserved instances evaluated (if stable workload) | 🟢 Medium | ☐ |
| Caching policies implemented | 🟡 High | ☐ |

### 🟢 Operational Excellence

| Item | Priority | Status |
|------|:--------:|:------:|
| Diagnostic settings enabled | 🔴 Critical | ☐ |
| Application Insights connected | 🔴 Critical | ☐ |
| Sampling rate configured appropriately | 🟡 High | ☐ |
| Log Analytics workspace configured | 🔴 Critical | ☐ |
| Alerts defined for key metrics | 🔴 Critical | ☐ |
| Action groups configured | 🔴 Critical | ☐ |
| Runbooks documented | 🟡 High | ☐ |
| CI/CD pipeline configured | 🔴 Critical | ☐ |
| IaC templates in source control | 🔴 Critical | ☐ |
| API specs in source control | 🔴 Critical | ☐ |
| Policies in source control | 🔴 Critical | ☐ |
| What-if/Plan before deployment | 🟡 High | ☐ |
| Smoke tests in pipeline | 🟡 High | ☐ |
| API linting (Spectral) in pipeline | 🟡 High | ☐ |
| Git branch protection enabled | 🟡 High | ☐ |
| Secrets not in source control | 🔴 Critical | ☐ |

### 🟣 Performance Efficiency

| Item | Priority | Status |
|------|:--------:|:------:|
| Response caching configured | 🟡 High | ☐ |
| Cache duration optimized | 🟡 High | ☐ |
| External Redis cache (if needed) | 🟢 Medium | ☐ |
| Backend timeouts configured | 🔴 Critical | ☐ |
| Connection pooling configured | 🟡 High | ☐ |
| Payload size limits enforced | 🟡 High | ☐ |
| Load testing completed | 🔴 Critical | ☐ |
| Baseline performance documented | 🟡 High | ☐ |
| P95/P99 latency targets met | 🔴 Critical | ☐ |

---

## 📊 Key Configuration Validation

### TLS & Protocol Hardening

```bicep
// Validate these settings are applied
customProperties: {
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'false'
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'false'
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'false'
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'true'
}
```

### Required Alerts

| Alert | Metric | Threshold | Severity |
|-------|--------|-----------|----------|
| Capacity High | Capacity | > 80% for 5 min | 2 (Warning) |
| Capacity Critical | Capacity | > 90% for 5 min | 1 (Error) |
| Error Rate | Failed Requests | > 5% | 2 (Warning) |
| Latency | Duration | P95 > 5s | 2 (Warning) |
| Unauthorized | UnauthorizedRequests | > 100/min | 3 (Info) |

### Minimum Policies

```xml
<!-- Global policy - minimum requirements -->
<policies>
    <inbound>
        <!-- Correlation -->
        <set-header name="X-Correlation-Id" exists-action="skip">
            <value>@(context.RequestId.ToString())</value>
        </set-header>
        <base />
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <!-- Remove sensitive headers -->
        <set-header name="X-Powered-By" exists-action="delete" />
        <set-header name="X-AspNet-Version" exists-action="delete" />
        <set-header name="Server" exists-action="delete" />
        <!-- Add response headers -->
        <set-header name="X-Request-Id" exists-action="override">
            <value>@(context.RequestId.ToString())</value>
        </set-header>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
```

---

## 🔧 Validation Commands

### Verify APIM Configuration

```bash
# Check APIM properties
az apim show --name $APIM_NAME --resource-group $RG \
  --query '{
    tier: sku.name,
    capacity: sku.capacity,
    vnetType: virtualNetworkType,
    zones: zones,
    publicNetworkAccess: publicNetworkAccess
  }'

# Verify TLS settings
az apim show --name $APIM_NAME --resource-group $RG \
  --query 'customProperties'

# Check diagnostic settings
az monitor diagnostic-settings list --resource $APIM_RESOURCE_ID

# Verify named values (check for Key Vault references)
az apim nv list --service-name $APIM_NAME --resource-group $RG \
  --query '[].{name:displayName, secret:secret, keyVault:keyVault.secretIdentifier}'
```

### Health Check Endpoints

```bash
# APIM Gateway health
curl -I https://$APIM_GATEWAY/status-0123456789abcdef

# Developer Portal health  
curl -I https://$APIM_PORTAL/

# Specific API health
curl -H "Ocp-Apim-Subscription-Key: $SUB_KEY" \
  https://$APIM_GATEWAY/api/health
```

---

## 📋 Go-Live Day Runbook

### T-24 Hours

- [ ] Final backup of APIM configuration
- [ ] Verify all alerts are active
- [ ] Confirm on-call team availability
- [ ] Review rollback procedure

### T-4 Hours

- [ ] Notify stakeholders
- [ ] Freeze code changes
- [ ] Verify monitoring dashboards
- [ ] Confirm DNS TTL is low

### T-0 (Cutover)

- [ ] Update DNS/routing
- [ ] Verify traffic flow
- [ ] Monitor error rates
- [ ] Monitor latency

### T+1 Hour

- [ ] Confirm steady state
- [ ] Check for anomalies
- [ ] Update stakeholders

### T+24 Hours

- [ ] Increase DNS TTL
- [ ] Full traffic validation
- [ ] Post-go-live review
- [ ] Update documentation

---

## 🚨 Rollback Plan

### Quick Rollback

```bash
# If using Traffic Manager/Front Door
# Route traffic back to legacy

az network front-door backend-pool backend update \
  --front-door-name $FD_NAME \
  --resource-group $RG \
  --pool-name $POOL \
  --address $LEGACY_BACKEND \
  --weight 100

az network front-door backend-pool backend update \
  --front-door-name $FD_NAME \
  --resource-group $RG \
  --pool-name $POOL \
  --address $APIM_BACKEND \
  --weight 0
```

### Restore from Backup

```bash
az apim restore \
  --name $APIM_NAME \
  --resource-group $RG \
  --backup-name $BACKUP_NAME \
  --storage-account-name $STORAGE \
  --storage-account-container $CONTAINER \
  --storage-account-key $KEY
```

---

## 📊 Post-Go-Live Monitoring

### Week 1 Focus

| Metric | Target | Action if Exceeded |
|--------|--------|-------------------|
| Error Rate | < 1% | Investigate immediately |
| P95 Latency | < 500ms | Review backends |
| Capacity | < 70% | Stable, monitor |
| Cache Hit Rate | > 50% | Tune cache policies |

### Week 2-4 Focus

| Activity | Frequency |
|----------|-----------|
| Performance review | Weekly |
| Cost review | Weekly |
| Security scan | Weekly |
| Capacity planning | Monthly |

---

## 🔗 Related Documents

| Document | Description |
|----------|-------------|
| [02-Reliability](./02-reliability.md) | HA and DR details |
| [03-Security](./03-security.md) | Security configuration |
| [06-Monitoring](./06-monitoring.md) | Monitoring setup |

---

> **Next**: [17-Troubleshooting](./17-troubleshooting.md) - Common issues and diagnostics
