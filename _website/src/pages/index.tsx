import React from "react";
import Layout from "@theme/Layout";
import Link from "@docusaurus/Link";
import styles from "./index.module.css";

const modules = [
  {
    title: "Cost Optimization",
    description: "9-module FinOps curriculum — from WAF fundamentals through AI token economics",
    link: "/cost-optimization/",
    tag: "9 Modules",
    icon: "💰",
    color: "#6366f1",
  },
  {
    title: "APIM Best Practices",
    description: "19-chapter deep-dive into Azure API Management architecture and operations",
    link: "/APIM-best-practices/",
    tag: "19 Chapters",
    icon: "🔌",
    color: "#8b5cf6",
  },
  {
    title: "Front Door",
    description: "WAF-aligned guide to Azure Front Door — reliability, security, performance",
    link: "/FrontDoor-best-practices/",
    tag: "6 Modules",
    icon: "🚪",
    color: "#a855f7",
  },
  {
    title: "Unified Monitoring",
    description: "Enterprise-scale federated observability — architecture, KQL runbooks, AMBA alerts",
    link: "/unified-monitoring-solution/",
    tag: "5 Modules",
    icon: "📊",
    color: "#c084fc",
  },
  {
    title: "BCDR",
    description: "Business continuity & disaster recovery — PaaS backup matrix, workload tiering, multi-region DR",
    link: "/BCDR/",
    tag: "4 Guides",
    icon: "🛡️",
    color: "#f43f5e",
  },
  {
    title: "AI Foundry",
    description: "Cross-region Azure AI Foundry architecture patterns and capacity planning",
    link: "/azure-ai-foundry/AI-Foundry-Cross-Region-Architecture",
    tag: "Deep-Dive",
    icon: "🧠",
    color: "#818cf8",
  },
  {
    title: "DevSecOps",
    description: "Complete DevSecOps best practices — CI/CD security, supply chain, SBOM",
    link: "/devsecops/DEVSECOPS_BEST_PRACTICES_GUIDE",
    tag: "Guide",
    icon: "🔐",
    color: "#7c3aed",
  },
  {
    title: "ADLS Gen2",
    description: "Azure Data Lake Storage Gen2 strategy — hierarchical namespace, access patterns, lifecycle",
    link: "/azure-storage/ADLS-Gen2-Strategy-Guidance",
    tag: "Strategy",
    icon: "🗄️",
    color: "#0ea5e9",
  },
  {
    title: "IaC & Deployment Stacks",
    description: "Bicep + Deployment Stacks architectural guidance — layered model, What-If, CI/CD patterns",
    link: "/iac-deployment-stacks/",
    tag: "NEW",
    icon: "🏗️",
    color: "#f59e0b",
  },
  {
    title: "🌳 FrootAI",
    description: "From Root to Fruit — the complete AI knowledge tree. 17 modules across foundations, reasoning, orchestration, operations & transformation",
    link: "https://www.frootai.dev",
    tag: "17 Modules · External",
    icon: "",
    color: "#10b981",
  },
];

const quickLinks = [
  { label: "PaaS Backup Matrix", to: "/BCDR/bcdr-queries", icon: "📋" },
  { label: "EU Region Comparison", to: "/BCDR/general-queries", icon: "🌍" },
  { label: "Zero Trust CI/CD", to: "/BCDR/azure-devops-github-queries", icon: "🔑" },
  { label: "AI Platform Resilience", to: "/BCDR/foundry-queries", icon: "🤖" },
  { label: "KQL Query Library", to: "/unified-monitoring-solution/operations-runbook", icon: "📖" },
  { label: "APIM Production Checklist", to: "/APIM-best-practices/production-checklist", icon: "✅" },
];

function HeroBanner(): JSX.Element {
  return (
    <div className={styles.hero}>
      <div className={styles.heroInner}>
        <img
          src="/azure-wiki/img/logo.svg"
          alt="Azure Wiki"
          className={styles.heroLogo}
        />
        <p className={styles.heroLabel}>Enterprise Azure Architecture Hub</p>
        <h1 className={styles.heroTitle}>Azure Wiki</h1>
        <p className={styles.heroSub}>
          Production-grade guides binding infrastructure, platform, and AI.
          <br />
          From the bedrock of infra to the fruit of intelligent agents.
        </p>
        <div className={styles.heroCta}>
          <Link className={styles.ctaPrimary} to="/cost-optimization/">
            Get Started
          </Link>
          <Link
            className={styles.ctaSecondary}
            to="https://www.frootai.dev"
          >
            🌳 Explore FrootAI
          </Link>
          <Link
            className={styles.ctaTertiary}
            to="https://github.com/frootai/frootai"
          >
            GitHub
          </Link>
        </div>
        <div className={styles.heroStats}>
          <div className={styles.stat}>
            <span className={styles.statNum}>70+</span>
            <span className={styles.statLabel}>Guides</span>
          </div>
          <div className={styles.stat}>
            <span className={styles.statNum}>9</span>
            <span className={styles.statLabel}>Solution Areas</span>
          </div>
          <div className={styles.stat}>
            <span className={styles.statNum}>17</span>
            <span className={styles.statLabel}>FrootAI Modules</span>
          </div>
          <div className={styles.stat}>
            <span className={styles.statNum}>100+</span>
            <span className={styles.statLabel}>Mermaid Diagrams</span>
          </div>
        </div>
      </div>
    </div>
  );
}

function ModuleCard({
  title,
  description,
  link,
  tag,
  icon,
  color,
}: {
  title: string;
  description: string;
  link: string;
  tag: string;
  icon: string;
  color: string;
}): JSX.Element {
  return (
    <Link to={link} className={styles.card}>
      <div className={styles.cardHeader}>
        {icon && <span className={styles.cardIcon}>{icon}</span>}
        <span className={styles.cardTag} style={{ color }}>
          {tag}
        </span>
      </div>
      <h3 className={styles.cardTitle}>{title}</h3>
      <p className={styles.cardDesc}>{description}</p>
      <span className={styles.cardArrow}>&rarr;</span>
    </Link>
  );
}

export default function Home(): JSX.Element {
  return (
    <Layout
      title="Azure Wiki — Enterprise Architecture Hub"
      description="Production-grade Azure guides, architecture patterns, and interactive learning"
    >
      <HeroBanner />
      <main className={styles.main}>
        <section className={styles.modules}>
          <h2 className={styles.sectionTitle}>Solution Areas</h2>
          <p className={styles.sectionSub}>Deep-dive guides across Azure infrastructure, platform, security, and AI</p>
          <div className={styles.grid}>
            {modules.map((m) => (
              <ModuleCard key={m.title} {...m} />
            ))}
          </div>
        </section>

        <section className={styles.quickAccess}>
          <h2 className={styles.sectionTitle}>Quick Access</h2>
          <p className={styles.sectionSub}>Jump directly to the most-referenced resources</p>
          <div className={styles.quickGrid}>
            {quickLinks.map((q) => (
              <Link key={q.label} to={q.to} className={styles.quickLink}>
                <span className={styles.quickIcon}>{q.icon}</span>
                <span className={styles.quickLabel}>{q.label}</span>
                <span className={styles.quickArrow}>&rarr;</span>
              </Link>
            ))}
          </div>
        </section>

        <section className={styles.features}>
          <h2 className={styles.sectionTitle}>Interactive Learning</h2>
          <p className={styles.sectionSub}>Built-in gamification across every module</p>
          <div className={styles.featureGrid}>
            <div className={styles.feature}>
              <div className={styles.featureIcon}>🎴</div>
              <h3>Flashcards</h3>
              <p>Key takeaways turned into interactive flip cards with keyboard navigation</p>
            </div>
            <div className={styles.feature}>
              <div className={styles.featureIcon}>✅</div>
              <h3>Quizzes</h3>
              <p>Test your knowledge with instant feedback, explanations, and scoring</p>
            </div>
            <div className={styles.feature}>
              <div className={styles.featureIcon}>⭐</div>
              <h3>Gamification</h3>
              <p>Earn XP, track streaks, and level up from Cloud Novice to FinOps Legend</p>
            </div>
            <div className={styles.feature}>
              <div className={styles.featureIcon}>📐</div>
              <h3>Mermaid Diagrams</h3>
              <p>Visual architecture diagrams, decision trees, and flow charts throughout</p>
            </div>
          </div>
        </section>

        <section className={styles.hubCta}>
          <h2 className={styles.sectionTitle}>Start Your Learning Journey</h2>
          <p className={styles.hubDesc}>
            Track your XP, study flashcards, take quizzes, and level up across all modules.
          </p>
          <Link className={styles.hubButton} to="/learning-hub">
            ★ Open Learning Hub
          </Link>
        </section>
      </main>
    </Layout>
  );
}
