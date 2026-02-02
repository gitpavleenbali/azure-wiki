# 05 - Operational Excellence

> Infrastructure as Code, monitoring, alerting, and certificate management for Azure Front Door

[![WAF](https://img.shields.io/badge/WAF-Operational%20Excellence-blue)](https://learn.microsoft.com/azure/well-architected/operational-excellence/)

---

## 🎯 Operational Excellence Principles

| Principle | Front Door Implementation |
|-----------|---------------------------|
| **Automate operations** | IaC with Bicep/Terraform, CI/CD pipelines |
| **Monitor everything** | Diagnostic logs, metrics, alerts |
| **Document procedures** | Runbooks for common operations |
| **Plan for incidents** | Alerting, escalation, rollback procedures |

---

## ✅ Operational Excellence Checklist

| # | Recommendation | Priority |
|---|----------------|----------|
| 1 | Deploy using Infrastructure as Code | 🔴 Critical |
| 2 | Enable diagnostic logging | 🔴 Critical |
| 3 | Configure alerts for key metrics | 🔴 Critical |
| 4 | Use managed TLS certificates | 🟡 High |
| 5 | Implement CI/CD for configuration changes | 🟡 High |
| 6 | Create operational runbooks | 🟡 High |
| 7 | Tag resources for cost tracking | 🟢 Medium |
| 8 | Review configuration drift regularly | 🟢 Medium |

---

## 🏗️ Infrastructure as Code

### Bicep Deployment

#### Complete Front Door Profile

```bicep
@description('Azure Front Door Profile')
resource frontDoor 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: 'fd-${workloadName}-${environment}'
  location: 'global'
  tags: {
    Environment: environment
    Application: workloadName
    CostCenter: costCenter
  }
  sku: {
    name: 'Premium_AzureFrontDoor'  // or 'Standard_AzureFrontDoor'
  }
}

@description('Front Door Endpoint')
resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  name: 'endpoint-${workloadName}'
  parent: frontDoor
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

@description('Origin Group with Health Probes')
resource originGroup 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
  name: 'og-${workloadName}'
  parent: frontDoor
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/health'
      probeProtocol: 'Https'
      probeRequestType: 'HEAD'
      probeIntervalInSeconds: 30
    }
    sessionAffinityState: 'Disabled'
  }
}

@description('Origin Configuration')
resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  name: 'origin-primary'
  parent: originGroup
  properties: {
    hostName: primaryOriginHostname
    originHostHeader: customDomainName
    httpPort: 80
    httpsPort: 443
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
  }
}

@description('Route Configuration')
resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  name: 'route-default'
  parent: endpoint
  properties: {
    originGroup: { id: originGroup.id }
    originPath: '/'
    patternsToMatch: ['/*']
    forwardingProtocol: 'HttpsOnly'
    httpsRedirect: 'Enabled'
    linkToDefaultDomain: 'Enabled'
    cacheConfiguration: {
      queryStringCachingBehavior: 'UseQueryString'
      cacheBehavior: 'HonorOrigin'
      compressionSettings: {
        isCompressionEnabled: true
        contentTypesToCompress: [
          'text/html'
          'text/css'
          'application/javascript'
          'application/json'
        ]
      }
    }
  }
  dependsOn: [origin]
}
```

#### WAF Policy

```bicep
@description('WAF Policy for Front Door')
resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' = {
  name: 'waf-${workloadName}-${environment}'
  location: 'global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      mode: wafMode  // 'Detection' or 'Prevention'
      enabledState: 'Enabled'
      requestBodyCheck: 'Enabled'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.1'
        }
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '1.0'
        }
      ]
    }
  }
}

@description('Associate WAF with Security Policy')
resource securityPolicy 'Microsoft.Cdn/profiles/securityPolicies@2023-05-01' = {
  name: 'secpol-${workloadName}'
  parent: frontDoor
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      wafPolicy: { id: wafPolicy.id }
      associations: [
        {
          domains: [{ id: endpoint.id }]
          patternsToMatch: ['/*']
        }
      ]
    }
  }
}
```

### Terraform Deployment

```hcl
resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "fd-${var.workload_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Premium_AzureFrontDoor"

  tags = {
    Environment = var.environment
    Application = var.workload_name
  }
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "endpoint-${var.workload_name}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  enabled                  = true
}

resource "azurerm_cdn_frontdoor_origin_group" "main" {
  name                     = "og-${var.workload_name}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  session_affinity_enabled = false

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
    additional_latency_in_milliseconds = 50
  }

  health_probe {
    path                = "/health"
    protocol            = "Https"
    request_type        = "HEAD"
    interval_in_seconds = 30
  }
}

resource "azurerm_cdn_frontdoor_origin" "primary" {
  name                          = "origin-primary"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  enabled                       = true

  host_name          = var.primary_origin_hostname
  origin_host_header = var.custom_domain_name
  http_port          = 80
  https_port         = 443
  priority           = 1
  weight             = 1000
}

resource "azurerm_cdn_frontdoor_route" "main" {
  name                          = "route-default"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.primary.id]

  patterns_to_match   = ["/*"]
  supported_protocols = ["Http", "Https"]
  forwarding_protocol = "HttpsOnly"
  https_redirect_enabled = true

  cache {
    query_string_caching_behavior = "UseQueryString"
    compression_enabled           = true
    content_types_to_compress     = ["text/html", "text/css", "application/javascript", "application/json"]
  }
}
```

---

## 📊 Monitoring & Diagnostics

### Enable Diagnostic Settings

```bicep
resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'fd-diagnostics'
  scope: frontDoor
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'FrontDoorAccessLog'
        enabled: true
        retentionPolicy: { enabled: true, days: 30 }
      }
      {
        category: 'FrontDoorHealthProbeLog'
        enabled: true
        retentionPolicy: { enabled: true, days: 30 }
      }
      {
        category: 'FrontDoorWebApplicationFirewallLog'
        enabled: true
        retentionPolicy: { enabled: true, days: 90 }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: { enabled: true, days: 30 }
      }
    ]
  }
}
```

### Key Metrics Dashboard

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| **Request Count** | Total requests | Anomaly detection |
| **Origin Health %** | Backend availability | < 80% |
| **Total Latency** | End-to-end latency | > 500ms |
| **4XX Error %** | Client errors | > 5% |
| **5XX Error %** | Server errors | > 1% |
| **WAF Blocked** | Blocked requests | Anomaly detection |
| **Byte Hit Ratio** | Cache efficiency | < 50% |

### Useful KQL Queries

#### Request Analysis

```kusto
// Request count by status code over time
AzureDiagnostics
| where Category == "FrontDoorAccessLog"
| summarize Count = count() by bin(TimeGenerated, 5m), httpStatusCode_s
| render timechart
```

#### Cache Performance

```kusto
// Cache hit ratio by route
AzureDiagnostics
| where Category == "FrontDoorAccessLog"
| summarize 
    TotalRequests = count(),
    CacheHits = countif(cacheStatus_s == "HIT"),
    CacheMisses = countif(cacheStatus_s == "MISS")
    by routeName_s
| extend CacheHitRatio = round((CacheHits * 100.0) / TotalRequests, 2)
| order by TotalRequests desc
```

#### Latency Analysis

```kusto
// P50, P95, P99 latency by endpoint
AzureDiagnostics
| where Category == "FrontDoorAccessLog"
| summarize 
    P50 = percentile(toint(timeTaken_s) * 1000, 50),
    P95 = percentile(toint(timeTaken_s) * 1000, 95),
    P99 = percentile(toint(timeTaken_s) * 1000, 99)
    by endpoint_s, bin(TimeGenerated, 1h)
| render timechart
```

#### Error Investigation

```kusto
// 5xx errors with details
AzureDiagnostics
| where Category == "FrontDoorAccessLog"
| where httpStatusCode_s startswith "5"
| project 
    TimeGenerated,
    clientIP_s,
    httpMethod_s,
    requestUri_s,
    httpStatusCode_s,
    originName_s,
    errorInfo_s
| order by TimeGenerated desc
| take 100
```

#### WAF Analysis

```kusto
// Top blocked requests by rule
AzureDiagnostics
| where Category == "FrontDoorWebApplicationFirewallLog"
| where action_s == "Block"
| summarize Count = count() by ruleName_s, clientIP_s
| order by Count desc
| take 20
```

---

## 🚨 Alerting

### Critical Alerts

```bicep
// High Error Rate Alert
resource errorAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'fd-high-error-rate'
  location: 'global'
  properties: {
    description: 'High 5xx error rate detected'
    severity: 1
    enabled: true
    scopes: [frontDoor.id]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'Percentage5XX'
          metricName: 'Percentage5XX'
          operator: 'GreaterThan'
          threshold: 5
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      { actionGroupId: actionGroup.id }
    ]
  }
}

// Origin Health Alert
resource originHealthAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'fd-origin-unhealthy'
  location: 'global'
  properties: {
    description: 'Origin health below threshold'
    severity: 1
    enabled: true
    scopes: [frontDoor.id]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'OriginHealthPercentage'
          metricName: 'OriginHealthPercentage'
          operator: 'LessThan'
          threshold: 80
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      { actionGroupId: actionGroup.id }
    ]
  }
}
```

### Recommended Alert Configuration

| Alert | Condition | Severity | Action |
|-------|-----------|----------|--------|
| **Origin Unhealthy** | Health < 80% | Critical (1) | Page on-call |
| **High 5XX Rate** | > 5% for 15 min | Critical (1) | Page on-call |
| **High Latency** | P95 > 2s | Warning (2) | Notify team |
| **WAF Block Spike** | 10x normal | Warning (2) | Investigate |
| **High 4XX Rate** | > 20% | Info (3) | Review logs |

---

## 🔐 Certificate Management

### Managed Certificates (Recommended)

```bicep
resource customDomain 'Microsoft.Cdn/profiles/customDomains@2023-05-01' = {
  name: 'domain-api'
  parent: frontDoor
  properties: {
    hostName: 'api.example.com'
    tlsSettings: {
      certificateType: 'ManagedCertificate'  // Azure handles renewal
      minimumTlsVersion: 'TLS12'
    }
    azureDnsZone: {
      id: dnsZone.id  // For automatic DNS validation
    }
  }
}
```

### Customer-Managed Certificates (Key Vault)

```bicep
resource customDomainWithCert 'Microsoft.Cdn/profiles/customDomains@2023-05-01' = {
  name: 'domain-custom-cert'
  parent: frontDoor
  properties: {
    hostName: 'secure.example.com'
    tlsSettings: {
      certificateType: 'CustomerCertificate'
      minimumTlsVersion: 'TLS12'
      secret: {
        id: 'https://keyvault.vault.azure.net/secrets/frontdoor-cert'
      }
    }
  }
}
```

### Certificate Expiry Monitoring

```kusto
// Check certificate expiry (run weekly)
AzureDiagnostics
| where Category == "FrontDoorAccessLog"
| distinct endpoint_s
| extend 
    CertExpiryDays = datetime_diff('day', todatetime("2025-03-01"), now()) // Replace with actual expiry
| where CertExpiryDays < 30
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions Example

```yaml
name: Deploy Front Door

on:
  push:
    branches: [main]
    paths:
      - 'infra/frontdoor/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Azure Login
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Deploy Front Door
        uses: azure/arm-deploy@v2
        with:
          resourceGroupName: ${{ vars.RESOURCE_GROUP }}
          template: ./infra/frontdoor/main.bicep
          parameters: ./infra/frontdoor/parameters.${{ vars.ENVIRONMENT }}.json
          failOnStdErr: false
      
      - name: Validate Deployment
        run: |
          az afd endpoint show \
            --profile-name fd-myapp-prod \
            --endpoint-name endpoint-myapp \
            --resource-group ${{ vars.RESOURCE_GROUP }}
```

### Azure DevOps Pipeline

```yaml
trigger:
  branches:
    include:
      - main
  paths:
    include:
      - infra/frontdoor/*

stages:
  - stage: Deploy
    jobs:
      - job: DeployFrontDoor
        pool:
          vmImage: ubuntu-latest
        steps:
          - task: AzureCLI@2
            inputs:
              azureSubscription: 'Azure-Connection'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                az deployment group create \
                  --resource-group $(ResourceGroup) \
                  --template-file infra/frontdoor/main.bicep \
                  --parameters @infra/frontdoor/parameters.$(Environment).json
```

---

## 📋 Operational Runbooks

### Runbook: Emergency Origin Failover

```markdown
## Emergency Origin Failover

**Trigger:** Primary origin unresponsive, automatic failover not occurring

### Steps:
1. Verify origin health in Portal: Front Door → Origin Groups → Health
2. If manual failover needed:
   ```bash
   az afd origin update \
     --profile-name fd-myapp-prod \
     --origin-group-name og-api \
     --origin-name origin-primary \
     --enabled-state Disabled
   ```
3. Monitor traffic shift in metrics
4. Investigate root cause on disabled origin
5. Re-enable when resolved:
   ```bash
   az afd origin update \
     --origin-name origin-primary \
     --enabled-state Enabled
   ```
```

### Runbook: WAF False Positive

```markdown
## Handle WAF False Positive

**Trigger:** Legitimate traffic blocked by WAF rule

### Steps:
1. Identify the blocking rule from WAF logs
2. Temporarily switch to Detection mode if critical:
   ```bash
   az network front-door waf-policy update \
     --name waf-myapp-prod \
     --resource-group rg-myapp \
     --mode Detection
   ```
3. Add exclusion for the false positive:
   ```bash
   # Add rule exclusion via Portal or ARM template
   ```
4. Switch back to Prevention mode
5. Document the exclusion and reason
```

---

## 🔗 References

| Resource | Link |
|----------|------|
| **Operational Excellence** | [WAF Operational Excellence](https://learn.microsoft.com/azure/well-architected/operational-excellence/) |
| **Monitoring** | [Front Door Monitoring](https://learn.microsoft.com/azure/frontdoor/front-door-diagnostics) |
| **Bicep Reference** | [Front Door Bicep](https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles) |
| **Terraform Provider** | [azurerm_cdn_frontdoor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_profile) |

---

*Previous: [04 - Cost Optimization](04-cost-optimization.md) | Next: [06 - Performance Efficiency](06-performance-efficiency.md)*
