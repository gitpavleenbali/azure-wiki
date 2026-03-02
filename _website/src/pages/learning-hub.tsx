import React, { useState, useEffect } from "react";
import Layout from "@theme/Layout";
import knowledgeBase from "@site/src/data/knowledgeBase.json";
import styles from "./learning-hub.module.css";

interface FlashcardItem { front: string; back: string; }
interface QuizQuestion { question: string; options: string[]; correct: number; explanation: string; }
interface ModuleKB { flashcards: FlashcardItem[]; quiz: QuizQuestion[]; }

const STORAGE_KEY = "azurewiki_xp";
const LEVELS = [
  { name: "Cloud Novice", min: 0 },
  { name: "Cloud Practitioner", min: 50 },
  { name: "Cloud Architect", min: 150 },
  { name: "Cloud Expert", min: 350 },
  { name: "Cloud Master", min: 600 },
  { name: "FinOps Legend", min: 1000 },
];

function getLevel(xp: number) {
  let lvl = LEVELS[0];
  for (const l of LEVELS) if (xp >= l.min) lvl = l;
  return lvl;
}
function getNextLevel(xp: number) {
  for (const l of LEVELS) if (xp < l.min) return l;
  return null;
}

const MODULE_LABELS: Record<string, string> = {
  "cost-optimization": "Cost Optimization",
  "APIM-best-practices": "APIM Best Practices",
  "FrontDoor-best-practices": "Front Door",
  "unified-monitoring-solution": "Monitoring",
  "azure-ai-foundry": "AI Foundry",
  "devsecops": "DevSecOps",
  "azure-storage": "ADLS Gen2 Storage",
};

export default function LearningHub(): JSX.Element {
  const [xpState, setXpState] = useState({ xp: 0, pagesRead: [] as string[], streak: 0 });

  useEffect(() => {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) setXpState(JSON.parse(raw));
    } catch {}
  }, []);

  const kb = knowledgeBase as Record<string, ModuleKB>;
  const modules = Object.keys(kb);
  const totalFlashcards = modules.reduce((s, m) => s + (kb[m].flashcards?.length || 0), 0);
  const totalQuiz = modules.reduce((s, m) => s + (kb[m].quiz?.length || 0), 0);
  const lvl = getLevel(xpState.xp);
  const nxt = getNextLevel(xpState.xp);
  const pct = nxt ? Math.round(((xpState.xp - lvl.min) / (nxt.min - lvl.min)) * 100) : 100;

  return (
    <Layout title="Learning Hub" description="Centralized learning dashboard — Flashcards, Quizzes, XP Tracking">
      <div className={styles.page}>
        {/* XP Dashboard */}
        <section className={styles.dashboard}>
          <div className={styles.xpCard}>
            <div className={styles.xpNumber}>{xpState.xp}</div>
            <div className={styles.xpLabel}>XP Earned</div>
          </div>
          <div className={styles.xpCard}>
            <div className={styles.xpNumber}>{lvl.name}</div>
            <div className={styles.xpLabel}>Current Level</div>
          </div>
          <div className={styles.xpCard}>
            <div className={styles.xpNumber}>{xpState.pagesRead.length}</div>
            <div className={styles.xpLabel}>Pages Read</div>
          </div>
          <div className={styles.xpCard}>
            <div className={styles.xpNumber}>{xpState.streak}</div>
            <div className={styles.xpLabel}>Day Streak</div>
          </div>
        </section>

        <div className={styles.progressSection}>
          <div className={styles.progressLabel}>
            {nxt ? `Next level: ${nxt.name} (${nxt.min} XP)` : "Max level reached!"}
          </div>
          <div className={styles.progressBar}>
            <div className={styles.progressFill} style={{ width: `${pct}%` }} />
          </div>
        </div>

        {/* Level Roadmap */}
        <section className={styles.levels}>
          <h2 className={styles.sectionTitle}>Level Roadmap</h2>
          <div className={styles.levelGrid}>
            {LEVELS.map((l) => (
              <div key={l.name} className={`${styles.levelCard} ${xpState.xp >= l.min ? styles.levelUnlocked : styles.levelLocked}`}>
                <div className={styles.levelMin}>{l.min} XP</div>
                <div className={styles.levelName}>{l.name}</div>
              </div>
            ))}
          </div>
        </section>

        {/* Module Knowledge Base */}
        <section className={styles.kbSection}>
          <h2 className={styles.sectionTitle}>Knowledge Base by Module</h2>
          <p className={styles.sectionSub}>{totalFlashcards} flashcards and {totalQuiz} quiz questions across {modules.length} modules</p>
          <div className={styles.moduleGrid}>
            {modules.map((key) => {
              const fc = kb[key].flashcards?.length || 0;
              const qz = kb[key].quiz?.length || 0;
              const label = MODULE_LABELS[key] || key;
              return (
                <div key={key} className={styles.moduleCard}>
                  <h3 className={styles.moduleTitle}>{label}</h3>
                  <div className={styles.moduleStat}>
                    <span className={styles.statFlash}>⚡ {fc} Flashcards</span>
                    <span className={styles.statQuiz}>✓ {qz} Quiz</span>
                  </div>
                  <a href={`/azure-wiki/${key}/`} className={styles.moduleLink}>
                    Open Module →
                  </a>
                </div>
              );
            })}
          </div>
        </section>

        {/* How it works */}
        <section className={styles.howSection}>
          <h2 className={styles.sectionTitle}>How It Works</h2>
          <div className={styles.howGrid}>
            <div className={styles.howCard}>
              <div className={styles.howStep}>1</div>
              <h3>Read a Module</h3>
              <p>Scroll past 65% of any doc page to earn 10 XP</p>
            </div>
            <div className={styles.howCard}>
              <div className={styles.howStep}>2</div>
              <h3>Study Flashcards</h3>
              <p>Click the ⚡ button on any module page to review flip cards</p>
            </div>
            <div className={styles.howCard}>
              <div className={styles.howStep}>3</div>
              <h3>Take the Quiz</h3>
              <p>Click the ✓ button for MCQ with instant grading</p>
            </div>
            <div className={styles.howCard}>
              <div className={styles.howStep}>4</div>
              <h3>Level Up</h3>
              <p>Track your streak and progress from Cloud Novice to FinOps Legend</p>
            </div>
          </div>
        </section>
      </div>
    </Layout>
  );
}
