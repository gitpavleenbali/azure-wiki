import React, { useEffect, useState, useCallback } from "react";
import { useLocation } from "@docusaurus/router";
import knowledgeBase from "@site/src/data/knowledgeBase.json";

interface FlashcardItem { front: string; back: string; }
interface QuizQuestion { question: string; options: string[]; correct: number; explanation: string; }
interface ModuleKB { flashcards: FlashcardItem[]; quiz: QuizQuestion[]; }

function getModuleKey(pathname: string): string | null {
  const clean = pathname.replace(/^\/azure-wiki\/?/, "").replace(/\/$/, "");
  const segments = clean.split("/");
  const folder = segments[0];
  if (!folder) return null;
  const kb = knowledgeBase as Record<string, ModuleKB>;
  if (kb[folder]) return folder;
  return null;
}

export default function AutoInteractive(): JSX.Element | null {
  const location = useLocation();
  const [moduleKey, setModuleKey] = useState<string | null>(null);
  const [showFlashcards, setShowFlashcards] = useState(false);
  const [showQuiz, setShowQuiz] = useState(false);

  useEffect(() => {
    setShowFlashcards(false);
    setShowQuiz(false);
    setModuleKey(getModuleKey(location.pathname));
  }, [location.pathname]);

  const kb = knowledgeBase as Record<string, ModuleKB>;
  const data = moduleKey ? kb[moduleKey] : null;
  const flashcards = data?.flashcards || [];
  const quiz = data?.quiz || [];

  // Hide on homepage
  const isHomepage = location.pathname === "/azure-wiki/" || location.pathname === "/azure-wiki" || location.pathname === "/";
  if (isHomepage) return null;
  if (flashcards.length === 0 && quiz.length === 0) return null;

  return (
    <>
      <div style={fabContainerStyle}>
        {quiz.length > 0 && (
          <button style={fabQuizStyle} onClick={() => { setShowQuiz(true); setShowFlashcards(false); }}>
             Quiz ({quiz.length})
          </button>
        )}
        {flashcards.length > 0 && (
          <button style={fabFlashStyle} onClick={() => { setShowFlashcards(true); setShowQuiz(false); }}>
             Flashcards ({flashcards.length})
          </button>
        )}
      </div>
      {showFlashcards && <FlashcardOverlay cards={flashcards} onClose={() => setShowFlashcards(false)} />}
      {showQuiz && <QuizOverlay questions={quiz} onClose={() => setShowQuiz(false)} />}
    </>
  );
}

/* ---- FLASHCARD OVERLAY ---- */
function FlashcardOverlay({ cards, onClose }: { cards: FlashcardItem[]; onClose: () => void }) {
  const [idx, setIdx] = useState(0);
  const [flipped, setFlipped] = useState(false);
  const next = useCallback(() => { setFlipped(false); setIdx(i => (i + 1) % cards.length); }, [cards.length]);
  const prev = useCallback(() => { setFlipped(false); setIdx(i => (i - 1 + cards.length) % cards.length); }, [cards.length]);

  useEffect(() => {
    const h = (e: KeyboardEvent) => {
      if (e.key === "ArrowRight") next();
      else if (e.key === "ArrowLeft") prev();
      else if (e.key === " ") { e.preventDefault(); setFlipped(f => !f); }
      else if (e.key === "Escape") onClose();
    };
    window.addEventListener("keydown", h);
    return () => window.removeEventListener("keydown", h);
  }, [next, prev, onClose]);

  return (
    <div style={overlayStyle} onClick={onClose}>
      <div style={modalStyle} onClick={e => e.stopPropagation()}>
        <div style={counterStyle}>{idx + 1} / {cards.length}</div>
        <div style={{ ...cardBase, ...(flipped ? cardBackS : cardFrontS) }} onClick={() => setFlipped(f => !f)}>
          {flipped ? cards[idx].back : cards[idx].front}
        </div>
        <p style={hintStyle}>Click card or Space to flip  Arrow keys to navigate  Esc to close</p>
        <div style={navRow}>
          <button style={navBtn} onClick={prev}> Prev</button>
          <button style={navBtn} onClick={next}>Next </button>
        </div>
        <div style={{ ...progressBar, marginTop: 16 }}>
          <div style={{ ...progressFill, width: `${((idx + 1) / cards.length) * 100}%` }} />
        </div>
        <button style={closeBtn} onClick={onClose}>Close</button>
      </div>
    </div>
  );
}

/* ---- QUIZ OVERLAY ---- */
function QuizOverlay({ questions, onClose }: { questions: QuizQuestion[]; onClose: () => void }) {
  const [idx, setIdx] = useState(0);
  const [selected, setSelected] = useState<number | null>(null);
  const [score, setScore] = useState(0);
  const [answered, setAnswered] = useState(false);
  const [finished, setFinished] = useState(false);

  useEffect(() => {
    const h = (e: KeyboardEvent) => { if (e.key === "Escape") onClose(); };
    window.addEventListener("keydown", h);
    return () => window.removeEventListener("keydown", h);
  }, [onClose]);

  const q = questions[idx];
  const isCorrect = selected === q?.correct;

  const handleSelect = (i: number) => {
    if (answered) return;
    setSelected(i);
    setAnswered(true);
    if (i === q.correct) setScore(s => s + 1);
  };

  const advance = () => {
    setSelected(null);
    setAnswered(false);
    if (idx + 1 >= questions.length) setFinished(true);
    else setIdx(i => i + 1);
  };

  if (finished) {
    const pct = Math.round((score / questions.length) * 100);
    let grade = "Keep Learning";
    if (pct >= 90) grade = "Cloud Master";
    else if (pct >= 70) grade = "Cloud Expert";
    else if (pct >= 50) grade = "Cloud Practitioner";
    return (
      <div style={overlayStyle} onClick={onClose}>
        <div style={{ ...modalStyle, textAlign: "center" as const }} onClick={e => e.stopPropagation()}>
          <h2 style={{ fontSize: "1.3rem", marginBottom: 16 }}>Quiz Complete</h2>
          <div style={scoreCircle}><span>{pct}%</span></div>
          <p style={{ fontSize: "1rem", fontWeight: 700, color: "#6366f1" }}>{grade}</p>
          <p style={{ fontSize: "0.88rem", margin: "8px 0 20px" }}>{score} / {questions.length} correct</p>
          <button style={{ ...closeBtn, background: "linear-gradient(135deg, #6366f1, #8b5cf6)", color: "#fff" }} onClick={onClose}>Close</button>
        </div>
      </div>
    );
  }

  return (
    <div style={overlayStyle} onClick={onClose}>
      <div style={modalStyle} onClick={e => e.stopPropagation()}>
        <div style={counterStyle}>Question {idx + 1} / {questions.length}  Score: {score}</div>
        <p style={{ fontSize: "1.05rem", fontWeight: 600, lineHeight: 1.6, marginBottom: 20 }}>{q.question}</p>
        <div style={{ display: "flex", flexDirection: "column" as const, gap: 8 }}>
          {q.options.map((opt, i) => {
            let bg = "transparent";
            let border = "1px solid var(--ifm-color-emphasis-200, #ddd)";
            if (answered && i === q.correct) { bg = "rgba(34,197,94,0.1)"; border = "2px solid #22c55e"; }
            else if (answered && i === selected) { bg = "rgba(239,68,68,0.08)"; border = "2px solid #ef4444"; }
            return (
              <button key={i} onClick={() => handleSelect(i)} disabled={answered}
                style={{ padding: "12px 16px", borderRadius: 10, border, background: bg, textAlign: "left" as const, fontSize: "0.9rem", cursor: answered ? "default" : "pointer", display: "flex", gap: 10, alignItems: "center" }}>
                <span style={{ display: "inline-flex", justifyContent: "center", alignItems: "center", minWidth: 26, height: 26, borderRadius: 7, fontSize: "0.75rem", fontWeight: 700, background: answered && i === q.correct ? "#22c55e" : answered && i === selected ? "#ef4444" : "var(--ifm-color-emphasis-100, #eee)", color: answered && (i === q.correct || i === selected) ? "#fff" : "inherit" }}>
                  {String.fromCharCode(65 + i)}
                </span>
                {opt}
              </button>
            );
          })}
        </div>
        {answered && (
          <div style={{ marginTop: 16, padding: 14, borderRadius: 10, background: isCorrect ? "rgba(34,197,94,0.08)" : "rgba(239,68,68,0.06)", borderLeft: `4px solid ${isCorrect ? "#22c55e" : "#ef4444"}`, fontSize: "0.88rem", lineHeight: 1.6 }}>
            {q.explanation}
          </div>
        )}
        {answered && (
          <button onClick={advance} style={{ display: "block", margin: "20px auto 0", padding: "10px 28px", border: "none", borderRadius: 10, background: "linear-gradient(135deg, #6366f1, #8b5cf6)", color: "#fff", fontSize: "0.88rem", fontWeight: 600, cursor: "pointer" }}>
            {idx + 1 >= questions.length ? "See Results" : "Next Question"}
          </button>
        )}
        <div style={{ ...progressBar, marginTop: 20 }}>
          <div style={{ ...progressFill, width: `${((idx + 1) / questions.length) * 100}%` }} />
        </div>
        <button style={closeBtn} onClick={onClose}>Close</button>
      </div>
    </div>
  );
}

/* ---- STYLES ---- */
const fabContainerStyle: React.CSSProperties = { position: "fixed", bottom: 70, left: 16, zIndex: 998, display: "flex", flexDirection: "column", gap: 8 };
const fabBase: React.CSSProperties = { padding: "8px 14px", border: "none", borderRadius: 10, color: "#fff", fontSize: "0.75rem", fontWeight: 600, cursor: "pointer", boxShadow: "0 3px 12px rgba(0,0,0,0.18)", transition: "all 0.2s", width: 120, textAlign: "center" as const, lineHeight: "1" };
const fabFlashStyle: React.CSSProperties = { ...fabBase, background: "linear-gradient(135deg, #6366f1, #8b5cf6)" };
const fabQuizStyle: React.CSSProperties = { ...fabBase, background: "linear-gradient(135deg, #059669, #10b981)" };
const overlayStyle: React.CSSProperties = { position: "fixed", inset: 0, zIndex: 10000, display: "flex", justifyContent: "center", alignItems: "center", background: "rgba(0,0,0,0.75)", backdropFilter: "blur(6px)" };
const modalStyle: React.CSSProperties = { width: "92%", maxWidth: 560, maxHeight: "85vh", overflowY: "auto", padding: 32, borderRadius: 16, background: "var(--ifm-background-color, #fff)", boxShadow: "0 24px 64px rgba(0,0,0,0.3)" };
const counterStyle: React.CSSProperties = { fontSize: "0.75rem", fontWeight: 600, color: "#6366f1", textTransform: "uppercase", letterSpacing: 1, marginBottom: 16, textAlign: "center" };
const cardBase: React.CSSProperties = { width: "100%", minHeight: 180, display: "flex", justifyContent: "center", alignItems: "center", padding: 28, borderRadius: 14, fontSize: "0.95rem", lineHeight: 1.6, textAlign: "center", cursor: "pointer", transition: "all 0.3s", boxShadow: "0 8px 32px rgba(0,0,0,0.12)" };
const cardFrontS: React.CSSProperties = { background: "linear-gradient(135deg, #1e1b4b, #312e81)", color: "#fff", fontWeight: 700, fontSize: "1.05rem" };
const cardBackS: React.CSSProperties = { background: "var(--ifm-background-color, #fff)", color: "var(--ifm-font-color-base, #333)", border: "2px solid #6366f1", fontWeight: 500 };
const hintStyle: React.CSSProperties = { textAlign: "center", fontSize: "0.7rem", color: "var(--ifm-color-emphasis-500, #888)", marginTop: 12 };
const navRow: React.CSSProperties = { display: "flex", gap: 12, justifyContent: "center", marginTop: 16 };
const navBtn: React.CSSProperties = { padding: "8px 24px", border: "1px solid var(--ifm-color-emphasis-300, #ccc)", borderRadius: 8, background: "transparent", color: "var(--ifm-font-color-base, #333)", fontSize: "0.85rem", fontWeight: 600, cursor: "pointer" };
const closeBtn: React.CSSProperties = { display: "block", margin: "12px auto 0", padding: "6px 20px", border: "none", borderRadius: 8, background: "rgba(128,128,128,0.1)", color: "var(--ifm-color-emphasis-600, #666)", fontSize: "0.78rem", cursor: "pointer" };
const progressBar: React.CSSProperties = { height: 3, background: "rgba(128,128,128,0.15)", borderRadius: 2, overflow: "hidden" };
const progressFill: React.CSSProperties = { height: "100%", background: "linear-gradient(90deg, #6366f1, #a855f7)", borderRadius: 2, transition: "width 0.3s" };
const scoreCircle: React.CSSProperties = { display: "flex", justifyContent: "center", alignItems: "center", width: 100, height: 100, borderRadius: "50%", border: "4px solid #6366f1", margin: "0 auto 12px", fontSize: "1.6rem", fontWeight: 800, color: "#6366f1" };
