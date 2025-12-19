# 🌐 Azure Wiki

<div align="center">

![Azure Wiki Banner](https://img.shields.io/badge/Azure-Wiki-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)
[![Contributions Welcome](https://img.shields.io/badge/Contributions-Welcome-brightgreen?style=for-the-badge)](CONTRIBUTING.md)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

### **Your One-Stop Azure Knowledge Hub**
*Beyond documentation — Visual guides, architecture patterns, and production-ready code*

[🚀 Quick Start](#-quick-start) • [📂 Table of Contents](#-table-of-contents) • [🎯 Why Azure Wiki](#-why-azure-wiki) • [🤝 Contribute](#-contribute)

---

</div>

## 📂 Table of Contents

| # | Folder | Topic | Description |
|:-:|--------|-------|-------------|
| 1 | 📁 [azure-ai-foundry](./azure-ai-foundry/) | **AI & ML** | Azure AI Foundry cross-region architecture patterns |
| 2 | 📁 [azure-storage](./azure-storage/) | **Storage** | ADLS Gen2 strategy and data lake guidance |
| 3 | 📁 [devsecops](./devsecops/) | **Security** | DevSecOps best practices and CI/CD security |

### 📄 Quick Links to Guides

| Guide | Category | Description |
|-------|----------|-------------|
| [AI Foundry Cross-Region Architecture](./azure-ai-foundry/AI-Foundry-Cross-Region-Architecture.md) | 🤖 AI/ML | Multi-region AI deployment patterns |
| [ADLS Gen2 Strategy Guidance](./azure-storage/ADLS-Gen2-Strategy-Guidance.md) | 💾 Storage | Data lake storage best practices |
| [DevSecOps Best Practices](./devsecops/DEVSECOPS_BEST_PRACTICES_GUIDE.md) | 🔐 Security | Complete security integration guide |

---

## 🎯 Why Azure Wiki?

| Traditional Docs | Azure Wiki |
|:-----------------|:-----------|
| 📄 Text-heavy walls | 🎨 **Visual-first** with diagrams |
| 🔍 Hard to find answers | 📋 **Curated** best practices |
| 🤔 Theory-focused | 💻 **Code snippets** ready to use |
| 📚 Scattered resources | 🎯 **One-stop** solution |

```
+---------------------------------------------------------------------+
|                          AZURE WIKI                                 |
+---------------------------------------------------------------------+
|                                                                     |
|   +-------------+  +-------------+  +-------------+  +-------------+|
|   |             |  |             |  |             |  |             ||
|   |  Diagrams   |  |  Security   |  |     IaC     |  |    Real     ||
|   |  & Visuals  |  |  Patterns   |  |  Templates  |  |  Examples   ||
|   |             |  |             |  |             |  |             ||
|   +-------------+  +-------------+  +-------------+  +-------------+|
|         |               |                |                |         |
|         +---------------+----------------+----------------+         |
|                                |                                    |
|                                v                                    |
|                 +-----------------------------+                     |
|                 |  Production-Ready Knowledge |                     |
|                 +-----------------------------+                     |
|                                                                     |
+---------------------------------------------------------------------+
```

---

## 🚀 Quick Start

```bash
# Clone the wiki
git clone https://github.com/gitpavleenbali/azure-wiki.git

# Navigate to topics
cd azure-wiki
```

---

## 🏗️ Architecture Patterns

```
+---------------------------------------------------------------------+
|                    Azure Solution Architectures                      |
+---------------------------------------------------------------------+
|                                                                     |
|   +-----------+     +-----------+     +-----------+     +-----------+
|   |           |     |           |     |           |     |           |
|   |    Web    |---->|    API    |---->|   Data    |---->|    AI     |
|   |   Apps    |     |   Mgmt    |     |   Layer   |     |    ML     |
|   |           |     |           |     |           |     |           |
|   +-----------+     +-----------+     +-----------+     +-----------+
|        |                 |                 |                 |      |
|        v                 v                 v                 v      |
|   +-----------+     +-----------+     +-----------+     +-----------+
|   |  Static   |     |   Azure   |     |  Cosmos   |     |   Azure   |
|   |   Web     |     | Functions |     |    DB     |     |    AI     |
|   |   Apps    |     |  + AKS    |     |  + SQL    |     | Services  |
|   +-----------+     +-----------+     +-----------+     +-----------+
|                                                                     |
+---------------------------------------------------------------------+
```

---

## 💻 Code Snippet Preview

### 🔧 Quick Azure CLI Commands

```bash
# 🚀 Create a resource group
az group create --name myResourceGroup --location eastus

# 🌐 Deploy a web app
az webapp create --resource-group myResourceGroup \
    --plan myAppServicePlan \
    --name myUniqueAppName \
    --runtime "DOTNET|6.0"

# 🔐 Create a Key Vault
az keyvault create --name myKeyVault \
    --resource-group myResourceGroup \
    --location eastus
```

### 🏗️ Bicep Infrastructure as Code

```bicep
// 🎯 Deploy a secure web app with Key Vault integration
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'mySecureWebApp'
  location: resourceGroup().location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}
```

---

## 🗺️ Roadmap

| Status | Topic | ETA |
|:------:|-------|-----|
| ✅ | DevSecOps Best Practices | Available |
| ✅ | Azure AI Foundry Architecture | Available |
| ✅ | ADLS Gen2 Strategy | Available |
| 🔄 | Azure Networking Deep Dive | Coming Soon |
| 📋 | AKS Production Patterns | Planned |
| 📋 | Cost Optimization Guide | Planned |
| 📋 | Disaster Recovery Patterns | Planned |

---

## 🤝 Contribute

We welcome contributions! Here's how you can help:

```
+--------------------------------------------+
|         Contribution Workflow              |
+--------------------------------------------+
|                                            |
|    [Fork]  --->  [Edit]  --->  [PR]        |
|                                            |
|    1. Fork this repository                 |
|    2. Create your feature branch           |
|    3. Add your knowledge                   |
|    4. Submit a pull request                |
|                                            |
+--------------------------------------------+
```

### 📝 Contribution Guidelines

- ✅ Use diagrams and visuals where possible
- ✅ Include working code snippets
- ✅ Keep explanations concise and practical
- ✅ Add real-world examples
- ✅ Follow the existing structure

---

## 📬 Connect

<div align="center">

| Platform | Link |
|----------|------|
| 📧 Newsletter | [Subscribe to Check1Minute](https://www.linkedin.com/build-relation/newsletter-follow?entityUrn=7001119707667832832) |
| 💼 LinkedIn | [Connect](https://linkedin.com/in/pavleenbali) |
| 🐙 GitHub | [@gitpavleenbali](https://github.com/gitpavleenbali) |

---

### ⭐ If this helps you, give it a star!

**Made with 💙 for the Azure Community**

</div>
