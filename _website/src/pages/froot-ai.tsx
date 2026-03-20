import React from "react";
import Layout from "@theme/Layout";
import Link from "@docusaurus/Link";
import styles from "./froot-ai.module.css";

// ─── FROOT Layer Data ───────────────────────────────────────────────

const layers = [
  {
    id: "F",
    icon: "🌱",
    title: "Foundations — The Roots",
    meta: "What AI is, how it thinks, the vocabulary you need",
    color: "#f59e0b",
    bgColor: "rgba(245, 158, 11, 0.08)",
    modules: [
      { id: "F1", title: "GenAI Foundations", desc: "Transformers, attention, tokenization, inference, parameters, context windows, embeddings", duration: "60–90 min", link: "/aifroot/GenAI-Foundations" },
      { id: "F2", title: "LLM Landscape & Model Selection", desc: "GPT, Claude, Llama, Gemini, Phi — benchmarks, open vs proprietary, when to use what", duration: "45–60 min", link: "/aifroot/LLM-Landscape" },
      { id: "F3", title: "AI Glossary A–Z", desc: "200+ terms — from ablation to zero-shot", duration: "Reference", link: "/aifroot/F3-AI-Glossary-AZ" },
    ],
  },
  {
    id: "R",
    icon: "🪵",
    title: "Reasoning — The Trunk",
    meta: "How to make AI think well — reliably, accurately, without hallucination",
    color: "#10b981",
    bgColor: "rgba(16, 185, 129, 0.08)",
    modules: [
      { id: "R1", title: "Prompt Engineering & Grounding", desc: "System messages, few-shot, chain-of-thought, structured output, guardrails", duration: "60–90 min", link: "/aifroot/Prompt-Engineering" },
      { id: "R2", title: "RAG Architecture & Retrieval", desc: "Chunking, embeddings, vector search, Azure AI Search, semantic ranking", duration: "90–120 min", link: "/aifroot/RAG-Architecture" },
      { id: "R3", title: "Making AI Deterministic", desc: "Hallucination reduction, grounding, temperature tuning, evaluation", duration: "60–90 min", link: "/aifroot/R3-Deterministic-AI" },
    ],
  },
  {
    id: "O¹",
    icon: "🌿",
    title: "Orchestration — The Branches",
    meta: "Connecting AI into intelligent systems — agents, tools, frameworks",
    color: "#06b6d4",
    bgColor: "rgba(6, 182, 212, 0.08)",
    modules: [
      { id: "O1", title: "Semantic Kernel & Orchestration", desc: "Plugins, planners, memory, connectors, comparison with LangChain", duration: "60 min", link: "/aifroot/Semantic-Kernel" },
      { id: "O2", title: "AI Agents & Agent Framework", desc: "Agent concepts, planning, memory, tool use, multi-agent, AutoGen", duration: "90–120 min", link: "/aifroot/AI-Agents-Deep-Dive" },
      { id: "O3", title: "MCP, Tools & Function Calling", desc: "Model Context Protocol, tool schemas, A2A, MCP servers", duration: "60–90 min", link: "/aifroot/O3-MCP-Tools-Functions" },
    ],
  },
  {
    id: "O²",
    icon: "🏗️",
    title: "Operations — The Canopy",
    meta: "Running AI in production — platforms, infrastructure, hosting",
    color: "#6366f1",
    bgColor: "rgba(99, 102, 241, 0.08)",
    modules: [
      { id: "O4", title: "Azure AI Platform & Landing Zones", desc: "AI Foundry, Model Catalog, deployments, endpoints, enterprise patterns", duration: "60–90 min", link: "/aifroot/Azure-AI-Foundry" },
      { id: "O5", title: "AI Infrastructure & Hosting", desc: "GPU compute, Container Apps, AKS, model serving, scaling", duration: "60–90 min", link: "/aifroot/AI-Infrastructure" },
      { id: "O6", title: "Copilot Ecosystem & Low-Code", desc: "M365 Copilot, Copilot Studio, Power Platform, GitHub Copilot", duration: "45–60 min", link: "/aifroot/Copilot-Ecosystem" },
    ],
  },
  {
    id: "T",
    icon: "🍎",
    title: "Transformation — The Fruit",
    meta: "Turning AI into real-world impact — safely, efficiently, at scale",
    color: "#7c3aed",
    bgColor: "rgba(124, 58, 237, 0.08)",
    modules: [
      { id: "T1", title: "Fine-Tuning & Customization", desc: "LoRA, QLoRA, RLHF, DPO, evaluation, MLOps lifecycle", duration: "60–90 min", link: "/aifroot/T1-Fine-Tuning-MLOps" },
      { id: "T2", title: "Responsible AI & Safety", desc: "Content safety, red teaming, guardrails, Azure AI Content Safety", duration: "45–60 min", link: "/aifroot/Responsible-AI-Safety" },
      { id: "T3", title: "Production Architecture", desc: "Multi-agent hosting, API gateway, cost control, monitoring", duration: "60–90 min", link: "/aifroot/T3-Production-Patterns" },
    ],
  },
];

const learningPaths = [
  { emoji: "🚀", title: "I'm New to AI", desc: "Start from the roots, build layer by layer", duration: "6–8 hours", modules: "F1 → F3 → F2 → R1 → R2 → R3" },
  { emoji: "⚡", title: "Build an Agent NOW", desc: "Fast-track to agent development", duration: "4–5 hours", modules: "F1 → R1 → O2 → O3 → O1 → T3" },
  { emoji: "🏗️", title: "AI Infrastructure", desc: "Platform and operations for infra architects", duration: "5–6 hours", modules: "F1 → O4 → O5 → T3 → R2 → T1" },
  { emoji: "🔍", title: "Make AI Reliable", desc: "Determinism, grounding, and safety", duration: "3–4 hours", modules: "R3 → R1 → R2 → T2 → REF" },
  { emoji: "🎯", title: "The Complete Journey", desc: "Every module, roots to fruit", duration: "16–22 hours", modules: "F1 → F2 → F3 → R1 → ... → T3" },
];

// ─── Components ────────────────────────────────────────────────────

function HeroBanner(): JSX.Element {
  return (
    <div className={styles.hero}>
      <div className={styles.heroInner}>
        <img src="/azure-wiki/img/aifroot-logo.svg" alt="FrootAI" className={styles.heroLogo} />
        <p className={styles.heroLabel}>The Open Glue for AI Architecture</p>
        <h1 className={styles.heroTitle}>FrootAI</h1>
        <p className={styles.heroAcronym}>
          AI{" "}
          <span className={styles.heroAcronymF}>F</span>oundations ·{" "}
          <span className={styles.heroAcronymR}>R</span>easoning ·{" "}
          <span className={styles.heroAcronymO1}>O</span>rchestration ·{" "}
          <span className={styles.heroAcronymO2}>O</span>perations ·{" "}
          <span className={styles.heroAcronymT}>T</span>ransformation
        </p>
        <p className={styles.heroSub}>
          The open glue that binds infrastructure, platform, and application.
          <br />
          Not just documentation — an <strong>MCP-powered skill set</strong> for your AI agents.
        </p>
        <p className={styles.heroSlogan}>
          "The telescope and the microscope for AI architecture"
        </p>
        <div className={styles.heroCta}>
          <Link className={styles.ctaPrimary} to="/aifroot/GenAI-Foundations">
            🌱 Start from the Roots
          </Link>
          <Link className={styles.ctaSecondary} to="#mcp-tooling">
            🔌 Explore MCP Tooling
          </Link>
        </div>
        <div className={styles.heroStats}>
          <div className={styles.stat}>
            <span className={styles.statNum} style={{ color: "#10b981" }}>17</span>
            <span className={styles.statLabel}>Modules</span>
          </div>
          <div className={styles.stat}>
            <span className={styles.statNum} style={{ color: "#06b6d4" }}>5</span>
            <span className={styles.statLabel}>MCP Tools</span>
          </div>
          <div className={styles.stat}>
            <span className={styles.statNum} style={{ color: "#6366f1" }}>200+</span>
            <span className={styles.statLabel}>AI Terms</span>
          </div>
          <div className={styles.stat}>
            <span className={styles.statNum} style={{ color: "#7c3aed" }}>0</span>
            <span className={styles.statLabel}>Hallucinations</span>
          </div>
        </div>
      </div>
    </div>
  );
}

function MCPTeaser(): JSX.Element {
  return (
    <section className={styles.lensSection} style={{ borderBottom: "1px solid var(--ifm-color-emphasis-200)", paddingBottom: "48px", marginBottom: "16px" }}>
      <h2 className={styles.sectionTitle}>🔌 Not Just Docs — An Agent Skill Set</h2>
      <p className={styles.sectionSub}>
        FrootAI ships as an <strong>MCP Server</strong>. Add it to any AI agent in 30 seconds.
        Your agent gets 17 modules, 200+ terms, and 7 architecture decision guides — no internet search, no hallucination, less tokens burned.
      </p>
      <div className={styles.lensGrid}>
        <div className={styles.lensCard} style={{ borderColor: "rgba(16, 185, 129, 0.2)" }}>
          <div className={styles.lensEmoji}>📚</div>
          <h3 className={styles.lensTitle}>Without FrootAI MCP</h3>
          <ul className={styles.lensList}>
            <li>Agent searches the internet</li>
            <li>Burns 5,000+ tokens per query</li>
            <li>May hallucinate architecture guidance</li>
            <li>Generic, uncurated answers</li>
            <li>No Azure-specific patterns</li>
          </ul>
        </div>
        <div className={styles.lensCard} style={{ borderColor: "rgba(16, 185, 129, 0.4)", background: "rgba(16, 185, 129, 0.03)" }}>
          <div className={styles.lensEmoji}>🌳</div>
          <h3 className={styles.lensTitle}>With FrootAI MCP</h3>
          <ul className={styles.lensList}>
            <li>Agent queries curated knowledge base</li>
            <li>Pre-written content, minimal token use</li>
            <li>Zero hallucination — grounded in docs</li>
            <li>Azure-specific best practices</li>
            <li>7 ready-made decision guides</li>
          </ul>
        </div>
      </div>
      <div style={{ textAlign: "center", marginTop: "20px" }}>
        <Link className={styles.ctaButton} to="#mcp-tooling" style={{ background: "linear-gradient(135deg, #059669, #10b981)" }}>
          ↓ See Full MCP Setup Below
        </Link>
      </div>
    </section>
  );
}

function FROOTLayer({ layer }: { layer: (typeof layers)[0] }): JSX.Element {
  return (
    <div className={styles.layer}>
      <div className={styles.layerHeader}>
        <div className={styles.layerIcon} style={{ background: layer.bgColor }}>{layer.icon}</div>
        <div>
          <h3 className={styles.layerTitle} style={{ color: layer.color }}>{layer.id} — {layer.title}</h3>
          <p className={styles.layerMeta}>{layer.meta}</p>
        </div>
      </div>
      <div className={styles.layerModules}>
        {layer.modules.map((mod) => (
          <Link key={mod.id} to={mod.link} className={styles.moduleCard} style={{ borderColor: `${layer.color}22` }}>
            <span className={styles.moduleId} style={{ color: layer.color }}>{mod.id}</span>
            <span className={styles.moduleTitle}>{mod.title}</span>
            <span className={styles.moduleDesc}>{mod.desc}</span>
            <span className={styles.moduleDuration}>{mod.duration}</span>
            <span className={styles.moduleArrow} style={{ color: layer.color }}>→</span>
          </Link>
        ))}
      </div>
    </div>
  );
}

function LensSection(): JSX.Element {
  return (
    <section className={styles.lensSection}>
      <h2 className={styles.sectionTitle}>Two Lenses, One Tree</h2>
      <p className={styles.sectionSub}>FrootAI gives you both the big picture and the tiny details</p>
      <div className={styles.lensGrid}>
        <div className={styles.lensCard}>
          <div className={styles.lensEmoji}>🔭</div>
          <h3 className={styles.lensTitle}>Telescope — Big Picture</h3>
          <ul className={styles.lensList}>
            <li>AI Landing Zone architecture</li>
            <li>Semantic Kernel vs Agent Framework</li>
            <li>Multi-agent hosting patterns</li>
            <li>10M-document RAG pipelines</li>
            <li>Enterprise copilot strategy</li>
          </ul>
        </div>
        <div className={styles.lensCard}>
          <div className={styles.lensEmoji}>🔬</div>
          <h3 className={styles.lensTitle}>Microscope — Tiny Details</h3>
          <ul className={styles.lensList}>
            <li>top_k=40 vs top_k=10</li>
            <li>BPE tokenization internals</li>
            <li>Why temperature=0 isn't truly deterministic</li>
            <li>Cosine similarity thresholds</li>
            <li>LoRA rank selection</li>
          </ul>
        </div>
      </div>
    </section>
  );
}

function MCPFullSection(): JSX.Element {
  return (
    <section id="mcp-tooling" className={styles.lensSection} style={{ scrollMarginTop: "80px" }}>
      <h2 className={styles.sectionTitle}>🔌 MCP Tooling — Add FrootAI to Your Agent</h2>
      <p className={styles.sectionSub}>
        Two setup paths depending on your environment. Both give your agent the same 5 tools.
      </p>

      {/* Dual setup paths */}
      <div className={styles.lensGrid}>
        <div className={styles.lensCard}>
          <div className={styles.lensEmoji}>🏠</div>
          <h3 className={styles.lensTitle}>Self-Hosted (Private)</h3>
          <ul className={styles.lensList}>
            <li><strong>For:</strong> Enterprise, air-gapped, private data</li>
            <li><strong>1.</strong> <code>git clone https://github.com/gitpavleenbali/azure-wiki.git</code></li>
            <li><strong>2.</strong> <code>cd azure-wiki/mcp-server && npm install</code></li>
            <li><strong>3.</strong> Add to your MCP config (see below)</li>
            <li>Runs 100% locally — no external calls</li>
            <li>Update anytime with <code>git pull</code></li>
          </ul>
        </div>
        <div className={styles.lensCard}>
          <div className={styles.lensEmoji}>🌐</div>
          <h3 className={styles.lensTitle}>Connected (GitHub-Hosted)</h3>
          <ul className={styles.lensList}>
            <li><strong>For:</strong> Quick setup, always latest content</li>
            <li><strong>AI Foundry:</strong> Add as MCP tool in agent config</li>
            <li><strong>VS Code:</strong> Workspace <code>.vscode/mcp.json</code> auto-detects</li>
            <li><strong>Copilot Studio:</strong> Add as MCP connector</li>
            <li>Point to GitHub repo — always current</li>
            <li>Works with any MCP-compatible client</li>
          </ul>
        </div>
      </div>

      {/* Config blocks */}
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(300px, 1fr))", gap: "16px", marginTop: "24px" }}>
        <div style={{ padding: "16px 20px", borderRadius: "12px", fontSize: "0.78rem", fontFamily: "var(--ifm-font-family-monospace)", background: "rgba(16, 185, 129, 0.04)", border: "1px solid rgba(16, 185, 129, 0.12)", lineHeight: "1.7" }}>
          <div style={{ fontWeight: 700, marginBottom: "8px", fontSize: "0.82rem", fontFamily: "var(--ifm-font-family-base)" }}>Claude Desktop / Cursor / Windsurf</div>
          <div style={{ color: "var(--ifm-color-emphasis-400)" }}>// claude_desktop_config.json</div>
          <div>{`{ "mcpServers": { "frootai": {`}</div>
          <div>{`    "command": "node",`}</div>
          <div>{`    "args": ["/path/to/mcp-server/index.js"]`}</div>
          <div>{`} } }`}</div>
        </div>
        <div style={{ padding: "16px 20px", borderRadius: "12px", fontSize: "0.78rem", fontFamily: "var(--ifm-font-family-monospace)", background: "rgba(99, 102, 241, 0.04)", border: "1px solid rgba(99, 102, 241, 0.12)", lineHeight: "1.7" }}>
          <div style={{ fontWeight: 700, marginBottom: "8px", fontSize: "0.82rem", fontFamily: "var(--ifm-font-family-base)" }}>VS Code / GitHub Copilot</div>
          <div style={{ color: "var(--ifm-color-emphasis-400)" }}>// .vscode/mcp.json (already in repo!)</div>
          <div>{`{ "servers": { "frootai": {`}</div>
          <div>{`    "command": "node",`}</div>
          <div>{`    "args": ["\${workspaceFolder}/mcp-server/index.js"]`}</div>
          <div>{`} } }`}</div>
        </div>
      </div>

      {/* 5 tools */}
      <h3 className={styles.sectionTitle} style={{ marginTop: "40px", fontSize: "1.15rem" }}>5 Tools Your Agent Receives</h3>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(180px, 1fr))", gap: "12px", marginTop: "16px" }}>
        {[
          { name: "list_modules", desc: "Browse 17 modules by FROOT layer", icon: "📋" },
          { name: "get_module", desc: "Read any module content (F1–T3)", icon: "📖" },
          { name: "lookup_term", desc: "200+ AI/ML term definitions", icon: "🔍" },
          { name: "search_knowledge", desc: "Full-text search all modules", icon: "🔎" },
          { name: "get_architecture_pattern", desc: "7 pre-built decision guides", icon: "🏗️" },
        ].map((tool) => (
          <div key={tool.name} style={{ padding: "16px", borderRadius: "12px", border: "1px solid var(--ifm-color-emphasis-200)", textAlign: "center" }}>
            <div style={{ fontSize: "1.5rem", marginBottom: "6px" }}>{tool.icon}</div>
            <div style={{ fontSize: "0.78rem", fontFamily: "var(--ifm-font-family-monospace)", fontWeight: 600, color: "#10b981" }}>{tool.name}</div>
            <div style={{ fontSize: "0.75rem", color: "var(--ifm-color-emphasis-500)", marginTop: "4px" }}>{tool.desc}</div>
          </div>
        ))}
      </div>

      {/* Use cases & advantages */}
      <h3 className={styles.sectionTitle} style={{ marginTop: "40px", fontSize: "1.15rem" }}>Why MCP? Use Cases & Advantages</h3>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: "12px", marginTop: "16px" }}>
        {[
          { icon: "🎯", title: "Agent Skill Set", desc: "Your agent learns Azure AI architecture patterns as a skill — like adding a senior architect to the team" },
          { icon: "💰", title: "Less Token Burn", desc: "Pre-written 664KB knowledge base vs generating from scratch. Saves 80-90% tokens per architecture query" },
          { icon: "🛡️", title: "Zero Hallucination", desc: "Answers come from curated, verified content — not model imagination. Grounded by design" },
          { icon: "🔄", title: "Always Current", desc: "git pull to update. No model retraining, no re-deployment, no API key rotation" },
          { icon: "🔒", title: "Privacy-First", desc: "Runs 100% locally. No data leaves your machine. No external API calls. Air-gap compatible" },
          { icon: "⚡", title: "Instant Decisions", desc: "7 architecture patterns (RAG, agents, hosting, cost, fine-tuning, multi-agent, determinism) on demand" },
        ].map((item) => (
          <div key={item.title} style={{ padding: "20px", borderRadius: "12px", border: "1px solid var(--ifm-color-emphasis-200)" }}>
            <div style={{ fontSize: "1.3rem", marginBottom: "6px" }}>{item.icon}</div>
            <div style={{ fontWeight: 700, fontSize: "0.9rem", marginBottom: "4px" }}>{item.title}</div>
            <div style={{ fontSize: "0.8rem", color: "var(--ifm-color-emphasis-500)", lineHeight: 1.5 }}>{item.desc}</div>
          </div>
        ))}
      </div>

      {/* Inspired by */}
      <h3 className={styles.sectionTitle} style={{ marginTop: "40px", fontSize: "1.15rem" }}>Inspired by the MCP Ecosystem</h3>
      <p className={styles.sectionSub}>FrootAI follows the same pattern as leading MCP servers in the ecosystem</p>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(240px, 1fr))", gap: "12px", marginTop: "16px" }}>
        {[
          { name: "Azure MCP", by: "Microsoft", desc: "40+ Azure services as MCP tools", pattern: "FrootAI does this for AI architecture knowledge" },
          { name: "GitHub MCP", by: "GitHub", desc: "Repos, issues, PRs as MCP tools", pattern: "FrootAI does this for AI learning modules" },
          { name: "Playwright MCP", by: "Microsoft", desc: "Browser automation as MCP tools", pattern: "FrootAI does this for architecture decisions" },
          { name: "Awesome MCP Servers", by: "Community", desc: "600+ MCP servers catalogued", pattern: "FrootAI brings knowledge bases to MCP" },
        ].map((item) => (
          <div key={item.name} style={{ padding: "16px", borderRadius: "12px", border: "1px solid var(--ifm-color-emphasis-200)", fontSize: "0.82rem" }}>
            <div style={{ fontWeight: 700, marginBottom: "2px" }}>{item.name} <span style={{ fontWeight: 400, color: "var(--ifm-color-emphasis-400)" }}>by {item.by}</span></div>
            <div style={{ color: "var(--ifm-color-emphasis-500)", marginBottom: "6px" }}>{item.desc}</div>
            <div style={{ color: "#10b981", fontSize: "0.78rem", fontStyle: "italic" }}>→ {item.pattern}</div>
          </div>
        ))}
      </div>

      <div style={{ textAlign: "center", marginTop: "28px" }}>
        <Link className={styles.ctaButton} to="https://github.com/gitpavleenbali/azure-wiki/tree/master/mcp-server" style={{ background: "linear-gradient(135deg, #6366f1, #7c3aed)" }}>
          🔌 Get the MCP Server on GitHub
        </Link>
      </div>
    </section>
  );
}

function PathSection(): JSX.Element {
  return (
    <section className={styles.paths}>
      <h2 className={styles.sectionTitle}>Learning Paths</h2>
      <p className={styles.sectionSub}>Not sure where to start? Pick your path</p>
      <div className={styles.pathGrid}>
        {learningPaths.map((path) => (
          <div key={path.title} className={styles.pathCard}>
            <div className={styles.pathEmoji}>{path.emoji}</div>
            <h3 className={styles.pathTitle}>{path.title}</h3>
            <p className={styles.pathDesc}>{path.desc}</p>
            <p className={styles.pathDuration}>{path.duration}</p>
            <p className={styles.pathModules}>{path.modules}</p>
          </div>
        ))}
      </div>
    </section>
  );
}

// ─── Main Page — Section Order ─────────────────────────────────────
// 1. Hero
// 2. MCP Teaser (before FROOT — first impression: this is not just docs)
// 3. FROOT Framework (the knowledge layers)
// 4. Two Lenses (telescope / microscope)
// 5. MCP Full Section (detailed setup, use cases, advantages)
// 6. Learning Paths
// 7. CTA

export default function FrootAIPage(): JSX.Element {
  return (
    <Layout
      title="FrootAI — The Open Glue for AI Architecture"
      description="The open glue that binds infrastructure, platform, and application. 17 modules, 200+ AI terms, MCP server. From root to fruit."
    >
      <HeroBanner />
      <main className={styles.main}>

        {/* 2. MCP Teaser — first impression */}
        <MCPTeaser />

        {/* 3. FROOT Framework */}
        <section>
          <h2 className={styles.sectionTitle}>The FROOT Framework</h2>
          <p className={styles.sectionSub}>
            Five layers, each building on the last — from the bedrock of infrastructure to the fruit of production AI
          </p>
          <div className={styles.layers}>
            {layers.map((layer) => (
              <FROOTLayer key={layer.id} layer={layer} />
            ))}
          </div>
        </section>

        {/* 4. Two Lenses */}
        <LensSection />

        {/* 5. MCP Full — detailed setup, use cases, advantages */}
        <MCPFullSection />

        {/* 6. Learning Paths */}
        <PathSection />

        {/* 7. CTA */}
        <section className={styles.ctaSection}>
          <h2 className={styles.sectionTitle}>The Open Glue for AI Architecture</h2>
          <p className={styles.ctaDesc}>
            Infrastructure is the bedrock. Platform is the trunk. Application is the fruit.
            FrootAI binds them all — read it, search it, query it via MCP, build with it.
          </p>
          <div style={{ display: "flex", gap: "12px", justifyContent: "center", flexWrap: "wrap" }}>
            <Link className={styles.ctaButton} to="/aifroot/GenAI-Foundations">
              🌱 Start from the Roots
            </Link>
            <Link className={styles.ctaButton} to="#mcp-tooling" style={{ background: "linear-gradient(135deg, #6366f1, #7c3aed)" }}>
              🔌 Add MCP to Your Agent
            </Link>
            <Link className={styles.ctaButton} to="/aifroot/" style={{ background: "linear-gradient(135deg, #f59e0b, #d97706)" }}>
              📋 Browse All Modules
            </Link>
          </div>
        </section>
      </main>
    </Layout>
  );
}
