# Unified Monitoring Solution (UMS)

> **Workshop Edition** - Cloud Platform Observability  
> **Purpose**: Federated monitoring solution for enterprise Azure environments

---

## 📚 Solution Documents

| # | Document | Description | Audience |
|---|----------|-------------|----------|
| 1 | [Architecture Overview](./01-architecture-overview.md) | Federated monitoring architecture, LAW design patterns, RBAC strategy | Architects, Platform Team |
| 2 | [Operations Runbook](./02-operations-runbook.md) | KQL queries, alert response, troubleshooting, cost optimization, DCR patterns | Operations, SRE, DevOps |
| 3 | [Advanced Topics](./03-advanced-topics.md) | Audit logs, DR, cost optimization, AIOps roadmap | Architects, Leadership |
| 4 | [Platform Observability Scenarios](./04-platform-observability-scenarios.md) | Platform vs LZ monitoring, visibility at scale, Service Health | Platform Team, Leadership |

---

## 🎯 Key Concepts

### Federated Monitoring Model

```
┌─────────────────────────────────────────────────────────────┐
│                    CENTRAL PLATFORM TEAM                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ Central LAW │  │ DCR Baseline│  │ AMBA Policy        │  │
│  │ (Golden)    │  │ (Standard)  │  │ Initiative         │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ Landing Zone A  │ │ Landing Zone B  │ │ Landing Zone C  │
│ ┌─────────────┐ │ │ ┌─────────────┐ │ │ ┌─────────────┐ │
│ │Custom Alerts│ │ │ │Custom DCRs  │ │ │ │Team Workbks │ │
│ └─────────────┘ │ │ └─────────────┘ │ │ └─────────────┘ │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

### Technology Stack

- **Data Collection**: Azure Monitor Agent (AMA), Data Collection Rules (DCR), Data Collection Endpoints (DCE)
- **Storage**: Log Analytics Workspace (LAW) with resource-context RBAC
- **Alerting**: AMBA (Azure Monitor Baseline Alerts), Alert Processing Rules, Action Groups
- **Visualization**: Azure Workbooks, Azure Dashboards
- **Infrastructure as Code**: Bicep

---

## 🚀 Quick Start

### 1. Deploy Central Log Analytics Workspace
```powershell
az deployment group create `
  --resource-group <resource-group-name> `
  --template-file ./log-analytic-workspace.bicep `
  --parameters lawName=law-ums-central-prod
```

### 2. Deploy Baseline DCR
```powershell
az deployment group create `
  --resource-group <resource-group-name> `
  --template-file ./dcr-baseline.bicep `
  --parameters lawId=<law-resource-id>
```

### 3. Assign AMBA Policy Initiative
```powershell
az policy assignment create `
  --name 'AMBA-UMS' `
  --policy-set-definition '/providers/Microsoft.Management/managementGroups/<mg>/providers/Microsoft.Authorization/policySetDefinitions/Alerting-ServiceHealth'
```

---

## 📚 Microsoft Official Documentation References

> These are the authoritative Microsoft sources that informed this solution. Use these for the latest updates and deep-dives.

#### Azure Monitor Best Practices
| Topic | Official URL |
|-------|--------------|
| **Cost Optimization in Azure Monitor** | https://learn.microsoft.com/en-us/azure/azure-monitor/best-practices-cost |
| **Reliability Best Practices** | https://learn.microsoft.com/en-us/azure/azure-monitor/best-practices-reliability |
| **Operational Excellence** | https://learn.microsoft.com/en-us/azure/azure-monitor/best-practices-operation |
| **Performance Efficiency** | https://learn.microsoft.com/en-us/azure/azure-monitor/best-practices-performance |
| **Enterprise Monitoring Architecture** | https://learn.microsoft.com/en-us/azure/azure-monitor/fundamentals/enterprise-monitoring-architecture |

#### Log Analytics Workspace
| Topic | Official URL |
|-------|--------------|
| **LAW Best Practices** | https://learn.microsoft.com/en-us/azure/azure-monitor/logs/best-practices-logs |
| **Well-Architected LAW Service Guide** | https://learn.microsoft.com/en-us/azure/well-architected/service-guides/azure-log-analytics |
| **Workspace Design** | https://learn.microsoft.com/en-us/azure/azure-monitor/logs/workspace-design |
| **Cost Calculations & Options** | https://learn.microsoft.com/en-us/azure/azure-monitor/logs/cost-logs |
| **Data Retention & Archive** | https://learn.microsoft.com/en-us/azure/azure-monitor/logs/data-retention-configure |

#### Data Collection Rules (DCR)
| Topic | Official URL |
|-------|--------------|
| **DCR Overview** | https://learn.microsoft.com/en-us/azure/azure-monitor/data-collection/data-collection-rule-overview |
| **DCR Best Practices** | https://learn.microsoft.com/en-us/azure/azure-monitor/data-collection/data-collection-rule-best-practices |
| **Transformations in Azure Monitor** | https://learn.microsoft.com/en-us/azure/azure-monitor/data-collection/data-collection-transformations |
| **Transformation Samples** | https://learn.microsoft.com/en-us/azure/azure-monitor/data-collection/data-collection-transformations-samples |

#### Alerting & AMBA
| Topic | Official URL |
|-------|--------------|
| **Azure Monitor Alerts Overview** | https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview |
| **Alert Types** | https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-types |
| **Azure Monitor Baseline Alerts (AMBA)** | https://azure.github.io/azure-monitor-baseline-alerts/ |
| **AMBA ALZ Deployment** | https://azure.github.io/azure-monitor-baseline-alerts/patterns/alz/HowTo/deploy/Introduction-to-deploying-the-ALZ-Pattern/ |

#### Well-Architected Framework
| Topic | Official URL |
|-------|--------------|
| **Monitoring & Alerting Strategy** | https://learn.microsoft.com/en-us/azure/well-architected/reliability/monitoring-alerting-strategy |
| **Observability Design** | https://learn.microsoft.com/en-us/azure/well-architected/operational-excellence/observability |

---

## 📊 Workshop Agenda

| Time | Topic | Document |
|------|-------|----------|
| 09:00-10:30 | Architecture Deep-Dive | [01-architecture-overview.md](./01-architecture-overview.md) |
| 10:45-12:30 | Operations & Runbooks | [02-operations-runbook.md](./02-operations-runbook.md) |
| 13:30-15:00 | Advanced Topics & Roadmap | [03-advanced-topics.md](./03-advanced-topics.md) |

---

## 📝 Document Control

| Property | Value |
|----------|-------|
| Maintained by | Central Platform Team |
| Review Cycle | Monthly |
| Classification | Internal |
| Version | 1.0 - Workshop Edition |
