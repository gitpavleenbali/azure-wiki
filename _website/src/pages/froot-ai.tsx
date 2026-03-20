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
      {
        id: "F1",
        title: "GenAI Foundations",
        desc: "Transformers, attention, tokenization, inference, parameters, context windows, embeddings",
        duration: "60–90 min",
        link: "/aifroot/GenAI-Foundations",
      },
      {
        id: "F2",
        title: "LLM Landscape & Model Selection",
        desc: "GPT, Claude, Llama, Gemini, Phi — benchmarks, open vs proprietary, when to use what",
        duration: "45–60 min",
        link: "/aifroot/LLM-Landscape",
      },
      {
        id: "F3",
        title: "AI Glossary A–Z",
        desc: "200+ terms defined — from ablation to zero-shot. The dictionary you keep open in another tab",
        duration: "Reference",
        link: "/aifroot/F3-AI-Glossary-AZ",
      },
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
      {
        id: "R1",
        title: "Prompt Engineering & Grounding",
        desc: "System messages, few-shot, chain-of-thought, structured output, guardrails, function calling",
        duration: "60–90 min",
        link: "/aifroot/Prompt-Engineering",
      },
      {
        id: "R2",
        title: "RAG Architecture & Retrieval",
        desc: "Chunking, embeddings, vector search, Azure AI Search, semantic ranking, reranking, hybrid search",
        duration: "90–120 min",
        link: "/aifroot/RAG-Architecture",
      },
      {
        id: "R3",
        title: "Making AI Deterministic & Reliable",
        desc: "Hallucination reduction, grounding, temperature tuning, evaluation metrics, guardrails",
        duration: "60–90 min",
        link: "/aifroot/R3-Deterministic-AI",
      },
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
      {
        id: "O1",
        title: "Semantic Kernel & Orchestration",
        desc: "Plugins, planners, memory, connectors, comparison with LangChain, when to use SK",
        duration: "60 min",
        link: "/aifroot/Semantic-Kernel",
      },
      {
        id: "O2",
        title: "AI Agents & Microsoft Agent Framework",
        desc: "Agent concepts, planning, memory, tool use, AutoGen, multi-agent, deterministic agents",
        duration: "90–120 min",
        link: "/aifroot/AI-Agents-Deep-Dive",
      },
      {
        id: "O3",
        title: "MCP, Tools & Function Calling",
        desc: "Model Context Protocol, tool schemas, function calling, A2A, MCP servers, registry",
        duration: "60–90 min",
        link: "/aifroot/O3-MCP-Tools-Functions",
      },
    ],
  },
  {
    id: "O²",
    icon: "🏗️",
    title: "Operations — The Canopy",
    meta: "Running AI in production — platforms, infrastructure, hosting, low-code",
    color: "#6366f1",
    bgColor: "rgba(99, 102, 241, 0.08)",
    modules: [
      {
        id: "O4",
        title: "Azure AI Platform & Landing Zones",
        desc: "AI Foundry, Model Catalog, deployments, endpoints, AI Landing Zone, enterprise patterns",
        duration: "60–90 min",
        link: "/aifroot/Azure-AI-Foundry",
      },
      {
        id: "O5",
        title: "AI Infrastructure & Hosting",
        desc: "GPU compute, Container Apps, AKS, App Service, model serving, scaling, cost optimization",
        duration: "60–90 min",
        link: "/aifroot/AI-Infrastructure",
      },
      {
        id: "O6",
        title: "Copilot Ecosystem & Low-Code AI",
        desc: "M365 Copilot, Copilot Studio, Power Platform AI, GitHub Copilot, extensibility",
        duration: "45–60 min",
        link: "/aifroot/Copilot-Ecosystem",
      },
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
      {
        id: "T1",
        title: "Fine-Tuning & Model Customization",
        desc: "When to fine-tune vs RAG, LoRA, QLoRA, RLHF, DPO, evaluation, MLOps lifecycle",
        duration: "60–90 min",
        link: "/aifroot/T1-Fine-Tuning-MLOps",
      },
      {
        id: "T2",
        title: "Responsible AI & Safety",
        desc: "Content safety, red teaming, guardrails, Azure AI Content Safety, evaluation frameworks",
        duration: "45–60 min",
        link: "/aifroot/Responsible-AI-Safety",
      },
      {
        id: "T3",
        title: "Production Architecture Patterns",
        desc: "Multi-agent hosting, API gateway for AI, latency, cost control, monitoring, resilience",
        duration: "60–90 min",
        link: "/aifroot/T3-Production-Patterns",
      },
    ],
  },
];

const learningPaths = [
  {
    emoji: "🚀",
    title: "I'm New to AI",
    desc: "Start from the roots, build understanding layer by layer",
    duration: "6–8 hours",
    modules: "F1 → F3 → F2 → R1 → R2 → R3",
  },
  {
    emoji: "⚡",
    title: "Build an Agent NOW",
    desc: "Fast-track to agent development with just enough foundation",
    duration: "4–5 hours",
    modules: "F1 → R1 → O2 → O3 → O1 → T3",
  },
  {
    emoji: "🏗️",
    title: "AI Infrastructure",
    desc: "Platform and operations focus for infra architects",
    duration: "5–6 hours",
    modules: "F1 → O4 → O5 → T3 → R2 → T1",
  },
  {
    emoji: "🔍",
    title: "Make AI Reliable",
    desc: "Determinism, grounding, and safety — for when AI must not fail",
    duration: "3–4 hours",
    modules: "R3 → R1 → R2 → T2 → REF",
  },
  {
    emoji: "🎯",
    title: "The Complete Journey",
    desc: "Every module, roots to fruit — become the AI architect",
    duration: "16–22 hours",
    modules: "F1 → F2 → F3 → R1 → R2 → ... → T3",
  },
];

// ─── Components ────────────────────────────────────────────────────

function HeroBanner(): JSX.Element {
  return (
    <div className={styles.hero}>
      <div className={styles.heroInner}>
        <img
          src="/azure-wiki/img/aifroot-logo.svg"
          alt="FrootAI"
          className={styles.heroLogo}
        />
        <p className={styles.heroLabel}>From Root to Fruit</p>
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
          From a single token to a production agent fleet.
        </p>
        <p className={styles.heroSlogan}>
          "The telescope and the microscope for AI architecture"
        </p>
        <div className={styles.heroCta}>
          <Link className={styles.ctaPrimary} to="/aifroot/GenAI-Foundations">
            Start from the Roots
          </Link>
          <Link className={styles.ctaSecondary} to="/aifroot/">
            Browse All Modules
          </Link>
        </div>
        <div className={styles.heroStats}>
          <div className={styles.stat}>
            <span className={styles.statNum} style={{ color: "#10b981" }}>
              17
            </span>
            <span className={styles.statLabel}>Modules</span>
          </div>
          <div className={styles.stat}>
            <span className={styles.statNum} style={{ color: "#06b6d4" }}>
              5
            </span>
            <span className={styles.statLabel}>FROOT Layers</span>
          </div>
          <div className={styles.stat}>
            <span className={styles.statNum} style={{ color: "#6366f1" }}>
              200+
            </span>
            <span className={styles.statLabel}>AI Terms</span>
          </div>
          <div className={styles.stat}>
            <span className={styles.statNum} style={{ color: "#7c3aed" }}>
              16-22h
            </span>
            <span className={styles.statLabel}>Full Journey</span>
          </div>
        </div>
      </div>
    </div>
  );
}

function FROOTLayer({
  layer,
}: {
  layer: (typeof layers)[0];
}): JSX.Element {
  return (
    <div className={styles.layer}>
      <div className={styles.layerHeader}>
        <div
          className={styles.layerIcon}
          style={{ background: layer.bgColor }}
        >
          {layer.icon}
        </div>
        <div>
          <h3 className={styles.layerTitle} style={{ color: layer.color }}>
            {layer.id} — {layer.title}
          </h3>
          <p className={styles.layerMeta}>{layer.meta}</p>
        </div>
      </div>
      <div className={styles.layerModules}>
        {layer.modules.map((mod) => (
          <Link
            key={mod.id}
            to={mod.link}
            className={styles.moduleCard}
            style={{
              borderColor: `${layer.color}22`,
            }}
          >
            <span className={styles.moduleId} style={{ color: layer.color }}>
              {mod.id}
            </span>
            <span className={styles.moduleTitle}>{mod.title}</span>
            <span className={styles.moduleDesc}>{mod.desc}</span>
            <span className={styles.moduleDuration}>{mod.duration}</span>
            <span className={styles.moduleArrow} style={{ color: layer.color }}>
              →
            </span>
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
      <p className={styles.sectionSub}>
        AIFROOT gives you both the big picture and the tiny details
      </p>
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

function PathSection(): JSX.Element {
  return (
    <section className={styles.paths}>
      <h2 className={styles.sectionTitle}>Learning Paths</h2>
      <p className={styles.sectionSub}>
        Not sure where to start? Pick your path
      </p>
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

// ─── Main Page ─────────────────────────────────────────────────────

export default function FrootAIPage(): JSX.Element {
  return (
    <Layout
      title="FrootAI — The Open Glue for AI Architecture"
      description="The open glue that binds infrastructure, platform, and application. 17 modules, 200+ AI terms, MCP server. From root to fruit."
    >
      <HeroBanner />
      <main className={styles.main}>
        <section>
          <h2 className={styles.sectionTitle}>The FROOT Framework</h2>
          <p className={styles.sectionSub}>
            Five layers, each building on the last — from the roots of AI
            fundamentals to the fruit of production transformation
          </p>
          <div className={styles.layers}>
            {layers.map((layer) => (
              <FROOTLayer key={layer.id} layer={layer} />
            ))}
          </div>
        </section>

        <LensSection />
        <PathSection />

        {/* ── Ecosystem: MCP + Integrations ── */}
        <section className={styles.lensSection}>
          <h2 className={styles.sectionTitle}>🔌 Add FrootAI to Your Agent — MCP Server</h2>
          <p className={styles.sectionSub}>
            Turn static docs into agent skills. Your AI agent queries FrootAI directly — less tokens burned, zero hallucination, precise answers.
          </p>
          <div className={styles.lensGrid}>
            <div className={styles.lensCard}>
              <div className={styles.lensEmoji}>⚡</div>
              <h3 className={styles.lensTitle}>30-Second Setup</h3>
              <ul className={styles.lensList}>
                <li><strong>1.</strong> <code>git clone https://github.com/gitpavleenbali/azure-wiki.git</code></li>
                <li><strong>2.</strong> <code>cd azure-wiki/mcp-server && npm install</code></li>
                <li><strong>3.</strong> Add to your Claude Desktop / VS Code / Cursor config:</li>
              </ul>
            </div>
            <div className={styles.lensCard}>
              <div className={styles.lensEmoji}>🧠</div>
              <h3 className={styles.lensTitle}>What Your Agent Gets</h3>
              <ul className={styles.lensList}>
                <li><code>list_modules</code> — Browse 17 modules by FROOT layer</li>
                <li><code>get_module</code> — Read any module content (F1–T3)</li>
                <li><code>lookup_term</code> — 200+ AI/ML term definitions</li>
                <li><code>search_knowledge</code> — Full-text search all modules</li>
                <li><code>get_architecture_pattern</code> — 7 decision guides</li>
              </ul>
            </div>
          </div>
          <div style={{ textAlign: "center", marginTop: "24px" }}>
            <div style={{
              display: "inline-block",
              padding: "16px 24px",
              borderRadius: "12px",
              fontSize: "0.82rem",
              fontFamily: "var(--ifm-font-family-monospace)",
              background: "rgba(16, 185, 129, 0.06)",
              border: "1px solid rgba(16, 185, 129, 0.15)",
              textAlign: "left",
              maxWidth: "600px",
              lineHeight: "1.8",
            }}>
              <div style={{ color: "var(--ifm-color-emphasis-500)", marginBottom: "4px" }}>// claude_desktop_config.json or .vscode/mcp.json</div>
              <div>{`{`}</div>
              <div>{`  "mcpServers": {`}</div>
              <div>{`    "frootai": {`}</div>
              <div>{`      "command": "node",`}</div>
              <div>{`      "args": ["/path/to/azure-wiki/mcp-server/index.js"]`}</div>
              <div>{`    }`}</div>
              <div>{`  }`}</div>
              <div>{`}`}</div>
            </div>
          </div>
          <div style={{ textAlign: "center", marginTop: "20px" }}>
            <p style={{ fontSize: "0.85rem", color: "var(--ifm-color-emphasis-500)", maxWidth: "500px", margin: "0 auto" }}>
              <strong>Without FrootAI:</strong> Agent → LLM → hallucinate → generic answer<br />
              <strong>With FrootAI:</strong> Agent → MCP → curated knowledge → precise answer
            </p>
          </div>
        </section>

        <section className={styles.ctaSection}>
          <h2 className={styles.sectionTitle}>
            The Open Glue for AI Architecture
          </h2>
          <p className={styles.ctaDesc}>
            Infrastructure is the bedrock. Platform is the trunk. Application is the fruit.
            FrootAI binds them all — read it, search it, query it via MCP, build with it.
          </p>
          <div style={{ display: "flex", gap: "12px", justifyContent: "center", flexWrap: "wrap" }}>
            <Link className={styles.ctaButton} to="/aifroot/GenAI-Foundations">
              🌱 Start from the Roots
            </Link>
            <Link className={styles.ctaButton} to="https://github.com/gitpavleenbali/azure-wiki/tree/master/mcp-server" style={{ background: "linear-gradient(135deg, #6366f1, #7c3aed)" }}>
              🔌 Get the MCP Server
            </Link>
          </div>
        </section>
      </main>
    </Layout>
  );
}
