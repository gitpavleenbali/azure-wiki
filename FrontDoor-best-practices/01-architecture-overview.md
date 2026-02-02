# 01 - Architecture Overview

> Core concepts, deployment patterns, and architectural decisions for Azure Front Door

[![WAF](https://img.shields.io/badge/WAF-Architecture-blue)](https://learn.microsoft.com/azure/well-architected/)

---

## 📊 Azure Front Door Architecture

```mermaid
flowchart TB
    subgraph Users["Global Users"]
        U1["User EU"]
        U2["User US"]
        U3["User Asia"]
    end

    subgraph AFD["Azure Front Door (Global)"]
        subgraph POPs["Edge POPs (118+ locations)"]
            POP1["Amsterdam"]
            POP2["New York"]
            POP3["Singapore"]
        end
        
        WAF["Web Application Firewall"]
        Cache["CDN Cache Layer"]
        Rules["Rules Engine"]
        
        subgraph Routing["Traffic Routing"]
            LB["Load Balancing"]
            Health["Health Probes"]
        end
    end

    subgraph Origins["Origin Groups"]
        subgraph OG1["Origin Group 1"]
            O1["App Service<br/>West Europe"]
            O2["App Service<br/>North Europe"]
        end
        subgraph OG2["Origin Group 2"]
            O3["AKS<br/>East US"]
            O4["AKS<br/>West US"]
        end
    end

    U1 --> POP1
    U2 --> POP2
    U3 --> POP3
    
    POP1 & POP2 & POP3 --> WAF --> Cache --> Rules --> LB
    Health -.->|Probe| O1 & O2 & O3 & O4
    LB --> OG1 & OG2

    style AFD fill:#0078D4,stroke:#fff,stroke-width:2px,color:#fff
    style POPs fill:#50E6FF,stroke:#0078D4,color:#000
    style Origins fill:#107C10,stroke:#fff,color:#fff
```

---

## 🏗️ Core Concepts

### Endpoints
A Front Door **endpoint** is the entry point for your application traffic. Each endpoint has a unique hostname (e.g., `myapp.azurefd.net`).

### Custom Domains
Map your own domain names (e.g., `www.contoso.com`) to Front Door endpoints with automatic or custom TLS certificates.

### Origin Groups
A logical grouping of origins that receive traffic. Configure:
- **Health probes** for monitoring
- **Load balancing** settings (latency, priority, weight)

### Origins
Backend servers that serve your content:
- App Service, Functions
- AKS, Container Apps
- Storage Accounts
- Application Gateway
- Custom hosts (on-premises, other clouds)

### Routes
Define how traffic flows from endpoints to origin groups:
- Path patterns (`/api/*`, `/static/*`)
- Protocols (HTTP, HTTPS)
- Caching rules

### Rules Engine
Apply transformations and routing logic:
- URL rewrite
- Header manipulation
- Origin group override

---

## 📐 Deployment Patterns

### Pattern 1: Active-Active Multi-Region

```mermaid
flowchart LR
    subgraph AFD["Azure Front Door"]
        Route["Route: /*"]
    end

    subgraph OG["Origin Group"]
        O1["West Europe<br/>Priority: 1<br/>Weight: 50"]
        O2["East US<br/>Priority: 1<br/>Weight: 50"]
    end

    Route --> OG
    OG --> O1 & O2

    style AFD fill:#0078D4,color:#fff
    style OG fill:#107C10,color:#fff
```

**Configuration:**
- Both origins with **Priority: 1** (same priority)
- **Weight: 50** each (equal distribution)
- **Latency sensitivity: 50ms** (route to fastest within range)

**Use Case:** Maximum availability, load distribution across regions.

---

### Pattern 2: Active-Passive (Failover)

```mermaid
flowchart LR
    subgraph AFD["Azure Front Door"]
        Route["Route: /*"]
    end

    subgraph OG["Origin Group"]
        O1["West Europe<br/>Priority: 1 (Primary)"]
        O2["East US<br/>Priority: 2 (Backup)"]
    end

    Route --> OG
    OG -->|Primary| O1
    OG -.->|Failover| O2

    style AFD fill:#0078D4,color:#fff
    style O1 fill:#107C10,color:#fff
    style O2 fill:#FFB900,color:#000
```

**Configuration:**
- Primary origin with **Priority: 1**
- Backup origin with **Priority: 2**
- Health probes detect primary failure → automatic failover

**Use Case:** Cost optimization, DR scenarios.

---

### Pattern 3: Path-Based Routing

```mermaid
flowchart LR
    subgraph AFD["Azure Front Door"]
        R1["Route: /api/*"]
        R2["Route: /static/*"]
        R3["Route: /*"]
    end

    subgraph Origins["Origin Groups"]
        API["API Servers<br/>(App Service)"]
        CDN["Static Content<br/>(Storage)"]
        Web["Web App<br/>(AKS)"]
    end

    R1 --> API
    R2 --> CDN
    R3 --> Web

    style AFD fill:#0078D4,color:#fff
```

**Use Case:** Microservices, separating static/dynamic content.

---

### Pattern 4: Blue-Green Deployment

```mermaid
flowchart LR
    subgraph AFD["Azure Front Door"]
        Rules["Rules Engine"]
    end

    subgraph OG["Origin Groups"]
        Blue["Blue (Current)<br/>Weight: 90%"]
        Green["Green (New)<br/>Weight: 10%"]
    end

    Rules --> Blue & Green

    style AFD fill:#0078D4,color:#fff
    style Blue fill:#0078D4,color:#fff
    style Green fill:#107C10,color:#fff
```

**Configuration:**
- Use **weighted routing** for gradual traffic shift
- Start with 90/10, gradually move to 0/100
- Rollback by adjusting weights

**Use Case:** Zero-downtime deployments, canary releases.

---

## 🔧 Key Configuration Decisions

| Decision | Options | Recommendation |
|----------|---------|----------------|
| **Tier** | Standard / Premium | Premium for Private Link & managed WAF |
| **Routing Method** | Priority / Weight / Latency | Combine based on use case |
| **Session Affinity** | Enabled / Disabled | Disable for reliability |
| **Caching** | Enabled / Disabled per route | Enable for static content |
| **WAF Mode** | Detection / Prevention | Start Detection, move to Prevention |
| **TLS Version** | 1.0, 1.1, 1.2, 1.3 | Minimum TLS 1.2 |

---

## 📋 Tier Comparison

| Capability | Standard | Premium |
|------------|----------|---------|
| **Monthly Base Fee** | $35 | $330 |
| **Global Load Balancing** | ✅ | ✅ |
| **SSL Offloading** | ✅ | ✅ |
| **Custom Domains** | ✅ | ✅ |
| **Compression** | ✅ | ✅ |
| **Caching** | ✅ | ✅ |
| **Rules Engine** | ✅ | ✅ |
| **Custom WAF Rules** | ✅ | ✅ |
| **Managed WAF Rules (OWASP)** | ❌ | ✅ |
| **Bot Protection** | ❌ | ✅ |
| **Private Link to Origins** | ❌ | ✅ |
| **Enhanced Reports** | ❌ | ✅ |

---

## 🔗 References

| Resource | Link |
|----------|------|
| **WAF Service Guide** | [Architecture best practices](https://learn.microsoft.com/azure/well-architected/service-guides/azure-front-door) |
| **Routing Methods** | [Traffic routing methods](https://learn.microsoft.com/azure/frontdoor/routing-methods) |
| **Origins & Groups** | [Origins and origin groups](https://learn.microsoft.com/azure/frontdoor/origin) |

---

*Next: [02 - Reliability](02-reliability.md)*
