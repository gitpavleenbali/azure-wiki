import React from "react";
import Layout from "@theme/Layout";
import Link from "@docusaurus/Link";
import Flashcard from "@site/src/components/Flashcard";
import Quiz from "@site/src/components/Quiz";
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
        <p className={styles.heroLabel}>Open-Source Learning Platform</p>
        <h1 className={styles.heroTitle}>Azure Wiki</h1>
        <p className={styles.heroSub}>
          Interactive guides, architecture patterns, and production-ready code.
          <br />
          Built for Cloud Architects, FinOps Practitioners, and AI Engineers.
        </p>
        <div className={styles.heroCta}>
          <Link className={styles.ctaPrimary} to="/cost-optimization/">
            Start Learning
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
            <span className={styles.statNum}>40+</span>
            <span className={styles.statLabel}>Guides</span>
          </div>
          <div className={styles.stat}>
            <span className={styles.statNum}>9</span>
            <span className={styles.statLabel}>Cost Modules</span>
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

        <section className={styles.demoSection}>
          <h2 className={styles.sectionTitle}>Try It Now</h2>
          <div className={styles.demoGrid}>
            <div>
              <Flashcard
                title="Cost Optimization Essentials"
                cards={[
                  { front: "What are the 3 cloud cost drivers?", back: "Compute (50-70%), Storage (15-25%), and Data Transfer / Egress (5-15%)" },
                  { front: "What is the #1 AI cost lever?", back: "Model selection — the difference between cheapest and most expensive model for the same task can be 100x" },
                  { front: "What is FinOps?", back: "A cultural practice that brings financial accountability to cloud spend through collaboration between Engineering, Finance, and Business teams" },
                  { front: "Reservations vs Savings Plans?", back: "Reservations: fixed SKU + region, up to 72% savings. Savings Plans: flexible across SKUs/regions, up to 65% savings" },
                  { front: "What is semantic caching?", back: "Caching embeddings of queries — if a semantically similar query was recently answered, return the cached response instead of calling the LLM. Saves 60-80% on token costs" },
                ]}
              />
            </div>
            <div>
              <Quiz
                title="Quick Knowledge Check"
                questions={[
                  {
                    question: "What percentage of cloud waste is typically from idle or over-provisioned resources?",
                    options: ["20-30%", "40-50%", "72-80%", "90-95%"],
                    correct: 2,
                    explanation: "72-80% of cloud waste comes from idle or over-provisioned resources, making usage optimization the single highest-impact lever.",
                  },
                  {
                    question: "How much cheaper is GPT-4o-mini compared to GPT-4o for input tokens?",
                    options: ["2x cheaper", "5x cheaper", "10x cheaper", "16x cheaper"],
                    correct: 3,
                    explanation: "GPT-4o-mini is 16x cheaper than GPT-4o for input tokens ($0.15 vs $2.50 per 1M tokens) and delivers excellent quality for most business tasks.",
                  },
                  {
                    question: "What is the WAF Cost Optimization pillar primarily about?",
                    options: ["Cutting costs at all costs", "Maximizing value per dollar spent", "Using only free-tier services", "Avoiding cloud entirely"],
                    correct: 1,
                    explanation: "Cost optimization is about maximizing business value per unit of cloud spend while meeting performance, reliability, and security requirements.",
                  },
                ]}
              />
            </div>
          </div>
        </section>
      </main>
    </Layout>
  );
}
