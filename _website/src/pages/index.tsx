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
    color: "#6366f1",
  },
  {
    title: "APIM Best Practices",
    description: "19-chapter deep-dive into Azure API Management architecture and operations",
    link: "/APIM-best-practices/",
    tag: "19 Chapters",
    color: "#8b5cf6",
  },
  {
    title: "Front Door",
    description: "WAF-aligned guide to Azure Front Door — reliability, security, performance",
    link: "/FrontDoor-best-practices/",
    tag: "6 Modules",
    color: "#a855f7",
  },
  {
    title: "Monitoring",
    description: "Enterprise-scale unified observability — architecture, runbooks, scenarios",
    link: "/unified-monitoring-solution/",
    tag: "4 Modules",
    color: "#c084fc",
  },
  {
    title: "AI Foundry",
    description: "Cross-region Azure AI Foundry architecture patterns",
    link: "/azure-ai-foundry/AI-Foundry-Cross-Region-Architecture",
    tag: "Deep-Dive",
    color: "#818cf8",
  },
  {
    title: "DevSecOps",
    description: "Complete DevSecOps best practices and CI/CD security integration",
    link: "/devsecops/DEVSECOPS_BEST_PRACTICES_GUIDE",
    tag: "Guide",
    color: "#7c3aed",
  },
  {
    title: "🌳 FrootAI",
    description: "From Root to Fruit — the complete AI knowledge tree. 17 modules covering foundations, reasoning, orchestration, operations & transformation",
    link: "https://gitpavleenbali.github.io/frootai/",
    tag: "17 Modules · NEW",
    color: "#10b981",
  },
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
        <p className={styles.heroLabel}>The Open Glue for AI Architecture</p>
        <h1 className={styles.heroTitle}>Azure Wiki</h1>
        <p className={styles.heroSub}>
          The open glue that binds infrastructure, platform, and application.
          <br />
          From the bedrock of infra to the fruit of AI agents.
        </p>
        <div className={styles.heroCta}>
          <Link className={styles.ctaPrimary} to="https://gitpavleenbali.github.io/frootai/">
            Explore FrootAI
          </Link>
          <Link
            className={styles.ctaSecondary}
            to="https://github.com/gitpavleenbali/azure-wiki"
          >
            View on GitHub
          </Link>
        </div>
        <div className={styles.heroStats}>
          <div className={styles.stat}>
            <span className={styles.statNum}>60+</span>
            <span className={styles.statLabel}>Guides</span>
          </div>
          <div className={styles.stat}>
            <span className={styles.statNum}>17</span>
            <span className={styles.statLabel}>AIFROOT Modules</span>
          </div>
          <div className={styles.stat}>
            <span className={styles.statNum}>19</span>
            <span className={styles.statLabel}>APIM Chapters</span>
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
  color,
}: {
  title: string;
  description: string;
  link: string;
  tag: string;
  color: string;
}): JSX.Element {
  return (
    <Link to={link} className={styles.card}>
      <span className={styles.cardTag} style={{ color }}>
        {tag}
      </span>
      <h3 className={styles.cardTitle}>{title}</h3>
      <p className={styles.cardDesc}>{description}</p>
      <span className={styles.cardArrow}>&rarr;</span>
    </Link>
  );
}

export default function Home(): JSX.Element {
  return (
    <Layout
      title="Azure Wiki — Interactive Learning Platform"
      description="Visual guides, architecture patterns, gamified learning for Azure Cloud"
    >
      <HeroBanner />
      <main className={styles.main}>
        <section className={styles.modules}>
          <h2 className={styles.sectionTitle}>Explore Modules</h2>
          <div className={styles.grid}>
            {modules.map((m) => (
              <ModuleCard key={m.title} {...m} />
            ))}
          </div>
        </section>

        <section className={styles.features}>
          <h2 className={styles.sectionTitle}>Interactive Learning</h2>
          <div className={styles.featureGrid}>
            <div className={styles.feature}>
              <div className={styles.featureIcon}>&#9881;</div>
              <h3>Flashcards</h3>
              <p>Key takeaways turned into interactive flip cards with keyboard navigation</p>
            </div>
            <div className={styles.feature}>
              <div className={styles.featureIcon}>&#10003;</div>
              <h3>Quizzes</h3>
              <p>Test your knowledge with instant feedback, explanations, and scoring</p>
            </div>
            <div className={styles.feature}>
              <div className={styles.featureIcon}>&#9733;</div>
              <h3>Gamification</h3>
              <p>Earn XP, track streaks, and level up from Cloud Novice to FinOps Legend</p>
            </div>
            <div className={styles.feature}>
              <div className={styles.featureIcon}>&#9783;</div>
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
