# FrootAI MCP Server

> **AI architecture knowledge at your fingertips.**
> Query 17 modules, 200+ AI terms, and architecture patterns from any MCP-compatible client.

---

## Quick Start

### 1. Run directly (no install)

```bash
cd mcp-server
npm install
node index.js
```

### 2. Configure in Claude Desktop

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "frootai": {
      "command": "node",
      "args": ["/path/to/azure-wiki/mcp-server/index.js"]
    }
  }
}
```

### 3. Configure in VS Code (GitHub Copilot)

Add to `.vscode/mcp.json`:

```json
{
  "servers": {
    "frootai": {
      "command": "node",
      "args": ["${workspaceFolder}/mcp-server/index.js"]
    }
  }
}
```

---

## Available Tools

| Tool | Description | Example |
|------|-------------|---------|
| `list_modules` | Browse all 17 modules organized by FROOT layer | "Show me the knowledge base structure" |
| `get_module` | Read a specific module by ID (F1-T3) | "Get module R3 about deterministic AI" |
| `lookup_term` | Look up any AI/ML term from the 200+ glossary | "What is LoRA?" |
| `search_knowledge` | Full-text search across all modules | "How to reduce hallucination" |
| `get_architecture_pattern` | Get decision guides for common scenarios | "Agent hosting pattern" |

### Architecture Patterns Available

| Scenario | What You Get |
|----------|-------------|
| `rag_pipeline` | RAG pipeline design decisions, Azure services, chunk sizing |
| `agent_hosting` | Container Apps vs AKS vs App Service decision matrix |
| `model_selection` | Which model for which use case + parameter guidance |
| `cost_optimization` | Token economics, caching strategies, cost formulas |
| `deterministic_ai` | 5-layer defense against hallucination |
| `multi_agent` | Supervisor vs pipeline vs swarm patterns |
| `fine_tuning_decision` | Fine-tune vs RAG vs prompting decision tree |

---

## Example Conversations

**User:** "I need to design a RAG pipeline for 10M documents on Azure"
→ Agent calls `get_architecture_pattern` with `rag_pipeline`, then `get_module` R2 for deep details

**User:** "What's the difference between temperature and top-p?"
→ Agent calls `lookup_term` for both terms, gets precise definitions

**User:** "Should I use Semantic Kernel or Microsoft Agent Framework?"
→ Agent calls `search_knowledge` with "Semantic Kernel vs Agent Framework"

**User:** "How do I make my AI agent stop hallucinating?"
→ Agent calls `get_architecture_pattern` with `deterministic_ai`

---

## The FROOT Framework

```
🌱 F — Foundations     → Tokens, parameters, models, vocabulary
🪵 R — Reasoning       → Prompts, RAG, grounding, determinism
🌿 O — Orchestration   → Semantic Kernel, agents, MCP, tools
🏗️ O — Operations      → Azure AI, infrastructure, Copilot
🍎 T — Transformation  → Fine-tuning, responsible AI, production
```

---

**FrootAI** — *The open glue for AI architecture. From root to fruit.*
