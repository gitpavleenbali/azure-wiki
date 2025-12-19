# Azure AI Foundry Cross-Region Private Endpoint Architecture

## Executive Summary

This document outlines the network architecture for accessing GPT models deployed in Sweden Central from Germany West Central using private endpoints (cross-region private endpoint functionality), ensuring secure, compliant, and performant connectivity for enterprise AI workloads.

## Cross-Region Private Endpoint Architecture

### Customer Question:
*"How does it work if we have the private endpoint in GWEC and want to use it for a model in Sweden?"*

### Answer: YES, this works with Azure's internal backbone routing!

#### How Cross-Region Private Endpoints Work:
1. **Private Endpoint Location**: You create the private endpoint in YOUR region (Germany West Central)
2. **AI Foundry Hub Location**: The AI Foundry Hub can be in ANY Azure region (Sweden Central)
3. **Azure Backbone Routing**: Azure's internal network automatically routes traffic between regions
4. **No VNet Required in Target Region**: You don't need a VNet in Sweden Central

#### Cross-Region Network Flow:
```
Your App (GWEC) → Private Endpoint (GWEC) → Azure Backbone → AI Foundry Hub (Sweden Central) → GPT Models
```

## Frequently Asked Questions (FAQ)

### Q: Do I need a VNet in Sweden Central to use models there with my private endpoint in Germany West Central?
**A: NO!** You only need:
- Private endpoint in YOUR region (Germany West Central) 
- AI Foundry Hub in the target region (Sweden Central)
- Azure automatically handles the backbone routing between regions

### Q: Is the connection still private when crossing regions?
**A: YES!** The entire path remains private:
- Your app → Private endpoint (private)
- Private endpoint → Azure backbone (private Microsoft network)
- Azure backbone → AI Foundry Hub (private)
- No traffic goes over public internet

### Q: What's the performance difference between local and cross-region?
**A: Performance Comparison:**
- Local (GWEC to GWEC): <5ms latency
- Cross-region (GWEC to Sweden): ~15-25ms latency
- Both options provide excellent performance for most AI workloads

### Q: Which approach should I choose?
**A: Recommendations:**
- **For GPT-4o, O1, O3**: Use local processing in Germany West Central (optimal performance)
- **For GPT-5**: Use cross-region to Sweden Central (when GPT-5 is required)
- **Hybrid**: Deploy both and route based on model requirements

### ⚠️ **IMPORTANT LIMITATIONS AND EXCEPTIONS**

**Critical Limitation Found in Microsoft Documentation:**

**For Agent Service (Private Network Secured Environments):**
- **"All Foundry workspace resources must be deployed in the same region as the virtual network (VNet)"**
- This includes: Cosmos DB, Storage Account, AI Search, Foundry Account, Project, Managed Identity, Azure OpenAI, or another Foundry resource used for model deployments
- **Exception**: This limitation applies specifically to Agent Service with private network isolation

**For Standard AI Foundry Hub/Project:**
- Cross-region private endpoints ARE supported ✅
- Private endpoint can be in different region than AI Foundry Hub
- Azure backbone routing works as described

**Key Distinction:**
- **Standard AI Foundry**: Cross-region private endpoints supported ✅
- **Agent Service with Private Networks**: Same-region requirement ⚠️

**Recommendation:**
- Verify with customer if they plan to use Agent Service or standard AI Foundry
- For standard workloads: Cross-region approach works
- For Agent Service: Consider regional deployment strategy

## Architecture Overview

```mermaid
architecture-beta
    group germany(cloud)[Germany West Central Region]
    group sweden(cloud)[Sweden Central Region]
    group azure_backbone(internet)[Azure Global Backbone]

    service customer_vnet(server)[Customer VNet] in germany
    service private_endpoint(disk)[Private Endpoint] in germany
    service dns_resolver(database)[Private DNS Zone] in germany
    service client_app(server)[Client Applications] in germany

    service ai_foundry_hub(cloud)[AI Foundry Hub] in sweden
    service gpt5_deployment(database)[GPT5 Deployment] in sweden
    service sweden_compute(server)[AI Compute] in sweden

    service azure_network(internet)[Azure Backbone Network] in azure_backbone
    service traffic_manager(server)[Traffic Manager] in azure_backbone

    client_app:R --> R:private_endpoint
    private_endpoint:B --> T:dns_resolver
    private_endpoint:R --> L:azure_network
    azure_network:R --> L:ai_foundry_hub
    ai_foundry_hub:B --> T:gpt5_deployment
    gpt5_deployment:R --> L:sweden_compute
```

## Detailed Network Components

### 1. Germany West Central Components

#### Customer Virtual Network (VNet)
- **Address Space**: 10.0.0.0/16 (customer-defined)
- **Subnets**:
  - Application Subnet: 10.0.1.0/24
  - Private Endpoint Subnet: 10.0.2.0/24
  - Management Subnet: 10.0.3.0/24

#### Private Endpoint Configuration
```yaml
Private Endpoint:
  Name: pe-aifoundry-sweden-gwec
  Location: Germany West Central
  Subnet: 10.0.2.0/24
  Target Resource: AI Foundry Hub (Sweden Central)
  Target Sub-resource: amlworkspace
  Private IP: 10.0.2.4
  FQDN: aifoundry-sweden.privatelink.api.azureml.ms
```

#### Private DNS Zone
```yaml
Private DNS Zone:
  Zone Name: privatelink.api.azureml.ms
  Linked VNets: [Customer-VNet-GWEC]
  A Records:
    - Name: aifoundry-sweden
      IP: 10.0.2.4
    - Name: aifoundry-sweden.westeurope
      IP: 10.0.2.4
```

### 2. Sweden Central Components

#### AI Foundry Hub
```yaml
AI Foundry Hub:
  Name: aifoundry-sweden-hub
  Location: Sweden Central
  Resource Group: rg-aifoundry-sweden-prod
  Public Network Access: Disabled
  Identity: System Assigned Managed Identity
```

#### GPT-5 Model Deployment
```yaml
GPT-5 Deployment:
  Model: gpt-5 (2025-08-07)
  Deployment Type: Standard (Regional)
  Location: Sweden Central
  Endpoint: https://aifoundry-sweden.openai.azure.com/
  API Version: 2024-10-01-preview
  Authentication: API Key + Azure AD
```

## Network Flow Architecture

```mermaid
sequenceDiagram
    participant App as Client Application<br/>(Germany West Central)
    participant PE as Private Endpoint<br/>(Germany West Central)
    participant DNS as Private DNS<br/>(Germany West Central)
    participant AB as Azure Backbone<br/>(Global Network)
    participant AIH as AI Foundry Hub<br/>(Sweden Central)
    participant GPT as GPT-5 Model<br/>(Sweden Central)

    App->>DNS: Resolve aifoundry-sweden.privatelink.api.azureml.ms
    DNS->>App: Return 10.0.2.4 (Private IP)
    App->>PE: HTTPS Request to 10.0.2.4:443
    PE->>AB: Forward via Azure Backbone Network
    AB->>AIH: Route to Sweden Central AI Foundry
    AIH->>GPT: Process inference request
    GPT->>AIH: Return model response
    AIH->>AB: Send response via backbone
    AB->>PE: Route response back
    PE->>App: Return AI response
```

## Security Architecture

### Network Security Groups (NSG)

#### Application Subnet NSG
```yaml
Inbound Rules:
  - Name: Allow-HTTPS-Internal
    Priority: 100
    Source: 10.0.0.0/16
    Destination: 10.0.1.0/24
    Port: 443
    Protocol: TCP
    Action: Allow

Outbound Rules:
  - Name: Allow-AI-Foundry
    Priority: 100
    Source: 10.0.1.0/24
    Destination: PrivateEndpoint
    Port: 443
    Protocol: TCP
    Action: Allow
```

#### Private Endpoint Subnet NSG
```yaml
Inbound Rules:
  - Name: Allow-Internal-HTTPS
    Priority: 100
    Source: 10.0.0.0/16
    Destination: 10.0.2.0/24
    Port: 443
    Protocol: TCP
    Action: Allow

Outbound Rules:
  - Name: Allow-Azure-Backbone
    Priority: 100
    Source: 10.0.2.0/24
    Destination: Internet
    Port: 443
    Protocol: TCP
    Action: Allow
```

### Authentication & Authorization

```yaml
Authentication Methods:
  1. Azure AD Service Principal:
     - Client ID: <service-principal-id>
     - Client Secret: <stored-in-key-vault>
     - Tenant ID: <tenant-id>
  
  2. Managed Identity:
     - Type: System Assigned
     - Scope: AI Foundry Hub Resource
  
  3. API Key (Backup):
     - Stored: Azure Key Vault
     - Rotation: 90 days

RBAC Assignments:
  - Role: Cognitive Services OpenAI User
  - Principal: Uniper Application Service Principal
  - Scope: AI Foundry Hub (Sweden Central)
```

## Alternative Architecture Comparison

### Option 1: Local Processing (Recommended for Performance)
**Configuration**: Everything in Germany West Central
- AI Foundry Hub: Germany West Central
- GPT Models: GPT-4o, GPT-4.1, O1, O3 (available locally)
- Private Endpoint: Germany West Central
- **Benefits**: <5ms latency, simplified setup, lower costs
- **Use Case**: Standard AI workloads, optimal performance

### Option 2: Cross-Region for GPT-5 (When Specific Models Needed)
**Configuration**: Private endpoint in GWEC, AI Foundry in Sweden Central
- AI Foundry Hub: Sweden Central (for GPT-5 access)
- GPT Models: GPT-5 (only available in Sweden Central)
- Private Endpoint: Germany West Central (YOUR region)
- **Azure Backbone Routing**: Automatic cross-region connectivity
- **Benefits**: Access to GPT-5, still private connectivity, no Sweden VNet needed
- **Latency**: ~15-25ms (acceptable for most use cases)
- **Use Case**: When specific models not available locally

### Cross-Region Architecture Diagram (Option 2)

```mermaid
architecture-beta
    group germany(cloud)[Germany West Central Region]
    group sweden(cloud)[Sweden Central Region]
    group azure_backbone(internet)[Azure Global Backbone]

    service customer_vnet(server)[Customer VNet] in germany
    service private_endpoint(disk)[Private Endpoint] in germany
    service dns_resolver(database)[Private DNS Zone] in germany
    service client_app(server)[Client Applications] in germany

    service ai_foundry_hub(cloud)[AI Foundry Hub] in sweden
    service gpt5_deployment(database)[GPT5 Deployment] in sweden
    service sweden_compute(server)[AI Compute] in sweden

    service azure_network(internet)[Azure Backbone Network] in azure_backbone

    client_app:R --> R:private_endpoint
    private_endpoint:B --> T:dns_resolver
    private_endpoint:R --> L:azure_network
    azure_network:R --> L:ai_foundry_hub
    ai_foundry_hub:B --> T:gpt5_deployment
    gpt5_deployment:R --> L:sweden_compute
```

## Implementation Considerations

### When to Use Cross-Region Architecture:
1. **Model Availability**: Specific models only available in other regions
2. **Compliance Requirements**: Need EU processing but local region lacks models
3. **Business Requirements**: Specific model capabilities required
4. **Future-Proofing**: Preparing for new model releases

### When to Use Local Architecture:
1. **Performance Critical**: Applications requiring <10ms latency
2. **Cost Optimization**: Avoiding cross-region data transfer charges
3. **Simplicity**: Reduced architectural complexity
4. **Available Models**: Required models available locally

## Data Residency & Compliance

### Data Processing Locations
```yaml
Data Flow:
  Request Origin: Germany West Central
  Network Transit: Azure Backbone (encrypted)
  Processing Location: Sweden Central (EU)
  Response Transit: Azure Backbone (encrypted)
  Response Destination: Germany West Central

Compliance Framework:
  - GDPR: ✅ EU-to-EU processing
  - Data Residency: ✅ Sweden (EU member state)
  - Encryption in Transit: ✅ TLS 1.3
  - Encryption at Rest: ✅ Azure Storage Encryption
  - Network Isolation: ✅ Private Endpoints
```

## Performance Optimization

### Latency Expectations
```yaml
Network Latency Components:
  GWEC to Sweden Central: ~15-25ms (updated based on Azure backbone)
  Private Endpoint Overhead: ~2-5ms
  AI Model Processing: ~500-2000ms
  Total Expected Latency: ~520-2030ms

Performance Comparison:
  Local Processing (GWEC): <5ms network latency
  Cross-Region (GWEC to Sweden): ~15-25ms network latency
  Difference: 10-20ms additional for cross-region

Optimization Strategies:
  1. Connection Pooling: Reuse HTTPS connections
  2. Request Batching: Combine multiple prompts
  3. Async Processing: Non-blocking API calls
  4. Caching: Cache responses where appropriate
```

### Key Benefits of Cross-Region Approach:
- ✅ Single private endpoint in Germany West Central handles all connectivity
- ✅ Azure backbone provides secure, private routing cross-region
- ✅ No need to manage VNets in multiple regions
- ✅ Simplified network architecture
- ✅ Private connectivity maintained end-to-end
- ✅ Access to GPT-5 models not available in local region

### Network Bandwidth
```yaml
Bandwidth Allocation:
  Expected Throughput: 1-10 Gbps
  Request Size: 1KB - 10MB (typical)
  Response Size: 1KB - 100KB (typical)
  Concurrent Connections: 100-1000
```

## Implementation Steps

### Phase 1: Infrastructure Setup (Week 1)

1. **Create AI Foundry Hub in Sweden Central**
```bash
# Create resource group
az group create --name rg-aifoundry-sweden-prod --location swedencentral

# Create AI Foundry Hub
az ml workspace create \
  --name aifoundry-sweden-hub \
  --resource-group rg-aifoundry-sweden-prod \
  --location swedencentral \
  --public-network-access Disabled
```

2. **Deploy GPT-5 Model**
```bash
# Deploy GPT-5 model
az ml online-deployment create \
  --name gpt5-deployment \
  --model gpt-5:1 \
  --workspace-name aifoundry-sweden-hub \
  --resource-group rg-aifoundry-sweden-prod
```

### Phase 2: Network Configuration (Week 2)

3. **Create Private Endpoint in GWEC**
```bash
# Create private endpoint
az network private-endpoint create \
  --name pe-aifoundry-sweden-gwec \
  --resource-group rg-uniper-gwec-prod \
  --vnet-name uniper-vnet-gwec \
  --subnet private-endpoint-subnet \
  --private-connection-resource-id "/subscriptions/<sub-id>/resourceGroups/rg-aifoundry-sweden-prod/providers/Microsoft.MachineLearningServices/workspaces/aifoundry-sweden-hub" \
  --group-id amlworkspace \
  --location germanywestcentral
```

4. **Configure Private DNS Zone**
```bash
# Create private DNS zone
az network private-dns zone create \
  --name privatelink.api.azureml.ms \
  --resource-group rg-uniper-gwec-prod

# Link to VNet
az network private-dns link vnet create \
  --name link-uniper-vnet \
  --zone-name privatelink.api.azureml.ms \
  --resource-group rg-uniper-gwec-prod \
  --virtual-network uniper-vnet-gwec \
  --registration-enabled false
```

### Phase 3: Security Configuration (Week 3)

5. **Configure Network Security Groups**
6. **Set up RBAC and Service Principal**
7. **Configure Azure Key Vault for secrets**

### Phase 4: Testing & Validation (Week 4)

8. **Network connectivity testing**
9. **Performance benchmarking**
10. **Security validation**

## Monitoring & Observability

### Network Monitoring
```yaml
Metrics to Monitor:
  - Private Endpoint Connection Status
  - Network Latency (GWEC ↔ Sweden)
  - Request/Response Throughput
  - Failed Connection Attempts
  - DNS Resolution Time

Alerting Thresholds:
  - Latency > 3 seconds: Warning
  - Connection Failures > 5%: Critical
  - Private Endpoint Down: Critical
```

### Application Monitoring
```yaml
AI Foundry Metrics:
  - Model Response Time
  - Token Usage (Input/Output)
  - Error Rates by HTTP Status
  - Quota Utilization
  - Model Availability

Logging Strategy:
  - Application Logs: Log Analytics Workspace
  - Network Logs: NSG Flow Logs
  - AI Foundry Logs: Diagnostic Settings
```

## Cost Optimization

### Estimated Monthly Costs (EUR)

```yaml
Network Components:
  Private Endpoint: €7.50/month
  DNS Zone: €0.50/month
  Data Transfer (intra-EU): €0.02/GB
  
AI Foundry Components:
  GPT-5 Usage: €0.03/1K tokens (input) + €0.06/1K tokens (output)
  Compute Resources: Variable based on usage
  
Total Estimated (10M tokens/month): ~€500-800/month
```

## Troubleshooting Guide

### Common Issues & Solutions

1. **DNS Resolution Failures**
   - Verify private DNS zone configuration
   - Check VNet link association
   - Validate A record entries

2. **Connection Timeouts**
   - Review NSG rules
   - Check private endpoint status
   - Verify Azure Backbone connectivity

3. **Authentication Errors**
   - Validate service principal permissions
   - Check RBAC assignments
   - Verify API key rotation

## Security Considerations

### Data Protection
- All traffic encrypted with TLS 1.3
- Private network isolation (no internet exposure)
- EU data processing compliance
- Regular security assessments

### Access Control
- Principle of least privilege
- Role-based access control (RBAC)
- Regular access reviews
- Multi-factor authentication for management

## Compliance & Governance

### GDPR Compliance
✅ **Data Processing Location**: Sweden (EU member state)
✅ **Data Controller**: Uniper (Germany)
✅ **Data Processor**: Microsoft Azure (EU operations)
✅ **Cross-border Transfer**: EU-to-EU (Article 28 compliant)

### Internal Governance
- Change management process
- Security review requirements
- Regular compliance audits
- Incident response procedures

---

This architecture provides a secure, compliant, and performant solution for accessing GPT-5 models in Sweden Central from Germany West Central while maintaining EU data residency requirements.