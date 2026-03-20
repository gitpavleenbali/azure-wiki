# 🌳 FrootAI MCP Server

> **Add AI architecture knowledge to any agent in 30 seconds.**
> 17 modules, 200+ terms, 7 architecture decision guides — queryable from any MCP client.

---

## Zero-Friction Setup

### Option 1: From GitHub (Recommended)

```bash
git clone https://github.com/gitpavleenbali/azure-wiki.git
cd azure-wiki/mcp-server
npm install
```

Add to your MCP config:

**Claude Desktop** (`claude_desktop_config.json`):
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

**VS Code / GitHub Copilot** (`.vscode/mcp.json`):
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

**Cursor / Windsurf / Any MCP Client:**
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

---

## Why Add FrootAI to Your Agent?

Your agent already has general knowledge. But when a customer asks:

> *"Should I use Semantic Kernel or Microsoft Agent Framework?"*
> *"How do I size GPUs for a 70B model?"*
> *"What's the difference between top-k and top-p?"*

...your agent searches the internet, burns tokens, and gives a generic answer.

**With FrootAI MCP**, your agent gets **precise, curated answers** in milliseconds — from a knowledge base built by architects, for architects.

```
Without FrootAI:  User → Agent → LLM (hallucinate) → generic answer
With FrootAI:     User → Agent → FrootAI MCP → precise answer → user
```

| Benefit | How |
|---------|-----|
| **Less token burn** | Pre-written content instead of generating from scratch |
| **No hallucination** | Answers from curated knowledge, not model imagination |
| **Always current** | `git pull` for latest — no model retraining |
| **7 decision guides** | RAG, agents, hosting, cost, determinism, multi-agent, fine-tuning |
| **200+ glossary terms** | Precise definitions your agent can cite |

---

## 5 Tools Your Agent Gets

| Tool | What It Does | Example Prompt |
|------|-------------|----------------|
| `list_modules` | Browse all 17 modules by FROOT layer | "What topics does FrootAI cover?" |
| `get_module` | Read any module (F1–T3), optionally a section | "Tell me about RAG Architecture" |
| `lookup_term` | Look up AI/ML terms from 200+ glossary | "What is LoRA?" |
| `search_knowledge` | Full-text search across all modules | "How to reduce hallucination?" |
| `get_architecture_pattern` | 7 pre-built decision guides | "Design a RAG pipeline" |

### Architecture Patterns

| Scenario | What You Get |
|----------|-------------|
| `rag_pipeline` | Pipeline design, chunk sizing, Azure services |
| `agent_hosting` | Container Apps vs AKS vs App Service matrix |
| `model_selection` | Which model for which use case |
| `cost_optimization` | Token economics, caching, cost formulas |
| `deterministic_ai` | 5-layer defense against hallucination |
| `multi_agent` | Supervisor vs pipeline vs swarm |
| `fine_tuning_decision` | Fine-tune vs RAG vs prompting tree |

---

## How It Works

```
┌──────────────────┐     MCP Protocol      ┌──────────────────┐
│  Your AI Agent   │ ◄──────────────────► │  FrootAI MCP     │
│  (Claude, Copilot│     stdio             │  Server          │
│   Custom Agent)  │                       │                  │
└──────────────────┘                       │  ┌────────────┐  │
                                           │  │ 17 Modules │  │
                                           │  │ 200+ Terms │  │
                                           │  │ 7 Patterns │  │
                                           │  └────────────┘  │
                                           └──────────────────┘
```

No API keys. No cloud services. Everything runs locally. The server reads from bundled knowledge (knowledge.json) or live markdown files from the repo.

---

## The FROOT Framework

```
  🍎  T — Transformation (The Fruit)     Fine-tuning, safety, production
  🏗️  O — Operations (The Canopy)        Azure AI, hosting, Copilot
  🌿  O — Orchestration (The Branches)   SK, agents, MCP, tools
  🪵  R — Reasoning (The Trunk)          Prompts, RAG, determinism
  🌱  F — Foundations (The Roots)         Tokens, models, glossary
  ─────────────────────────────────────
  ⬇️  Infrastructure (The Bedrock)       AI Landing Zones, GPU, networking
```

---

*FrootAI — Static docs become agent skills.*
