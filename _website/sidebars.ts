import type { SidebarsConfig } from "@docusaurus/plugin-content-docs";

const sidebars: SidebarsConfig = {
  costOptSidebar: [
    {
      type: "category",
      label: "Cost Optimization",
      collapsible: true,
      collapsed: false,
      items: [
        "cost-optimization/README",
        "cost-optimization/Module-Cost-Optimization-Fundamentals",
        "cost-optimization/Module-Cost-Transparency",
        "cost-optimization/Module-Financial-Controls",
        "cost-optimization/Module-Rate-Optimization",
        "cost-optimization/Module-Usage-Optimization",
        "cost-optimization/Module-Workload-Optimization",
        "cost-optimization/Module-AI-Cost-Optimization",
        "cost-optimization/Demo-Guide",
        "cost-optimization/Quiz-Assessment",
      ],
    },
  ],

  apimSidebar: [
    {
      type: "category",
      label: "APIM Best Practices",
      collapsible: true,
      collapsed: false,
      items: [
        "APIM-best-practices/README",
        "APIM-best-practices/architecture-overview",
        "APIM-best-practices/reliability",
        "APIM-best-practices/security",
        "APIM-best-practices/policies",
        "APIM-best-practices/devops-apiops",
        "APIM-best-practices/monitoring",
        "APIM-best-practices/ai-gateway",
        "APIM-best-practices/self-hosted-gateway",
        "APIM-best-practices/cost-optimization",
        "APIM-best-practices/performance-efficiency",
        "APIM-best-practices/monetization",
        "APIM-best-practices/tradeoffs",
        "APIM-best-practices/customer-qa",
        "APIM-best-practices/api-governance",
        "APIM-best-practices/migration-patterns",
        "APIM-best-practices/production-checklist",
        "APIM-best-practices/troubleshooting",
        "APIM-best-practices/capacity-planning",
        "APIM-best-practices/workspaces",
      ],
    },
  ],

  frontdoorSidebar: [
    {
      type: "category",
      label: "Front Door Best Practices",
      collapsible: true,
      collapsed: false,
      items: [
        "FrontDoor-best-practices/README",
        "FrontDoor-best-practices/architecture-overview",
        "FrontDoor-best-practices/reliability",
        "FrontDoor-best-practices/security",
        "FrontDoor-best-practices/cost-optimization",
        "FrontDoor-best-practices/operational-excellence",
        "FrontDoor-best-practices/performance-efficiency",
      ],
    },
  ],

  monitoringSidebar: [
    {
      type: "category",
      label: "Unified Monitoring",
      collapsible: true,
      collapsed: false,
      items: [
        "unified-monitoring-solution/README",
        "unified-monitoring-solution/architecture-overview",
        "unified-monitoring-solution/operations-runbook",
        "unified-monitoring-solution/advanced-topics",
        "unified-monitoring-solution/platform-observability-scenarios",
      ],
    },
  ],

  aiNexusSidebar: [
    {
      type: "category",
      label: "AI Nexus",
      collapsible: true,
      collapsed: false,
      items: [
        "ai-nexus/README",
        "ai-nexus/GenAI-Foundations",
        "ai-nexus/LLM-Landscape",
        "ai-nexus/Azure-AI-Foundry",
        "ai-nexus/Copilot-Ecosystem",
        "ai-nexus/RAG-Architecture",
        "ai-nexus/AI-Agents-Deep-Dive",
        "ai-nexus/Semantic-Kernel",
        "ai-nexus/Prompt-Engineering",
        "ai-nexus/AI-Infrastructure",
        "ai-nexus/Responsible-AI-Safety",
        "ai-nexus/Quick-Reference-Cards",
        "ai-nexus/Quiz-Assessment",
      ],
    },
  ],
};

export default sidebars;
