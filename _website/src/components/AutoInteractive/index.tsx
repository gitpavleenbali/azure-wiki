import React, { useEffect, useState, useCallback } from "react";

interface FlashcardItem {
  front: string;
  back: string;
}

interface QuizQuestion {
  question: string;
  answer: string;
}

/**
 * AutoInteractive — scans the current doc page DOM for:
 *   1. "Key Takeaways" lists → generates flip-card flashcards
 *   2. <details> with <summary>Answer</summary> → generates quiz mode
 * Renders floating action buttons when content is detected.
 */
export default function AutoInteractive(): JSX.Element | null {
  const [flashcards, setFlashcards] = useState<FlashcardItem[]>([]);
  const [quizItems, setQuizItems] = useState<QuizQuestion[]>([]);
  const [showFlashcards, setShowFlashcards] = useState(false);
  const [showQuiz, setShowQuiz] = useState(false);

  // Scan DOM after render
  useEffect(() => {
    const timer = setTimeout(() => {
      // --- Extract flashcards from multiple sources ---
      const cards: FlashcardItem[] = [];
      const seen = new Set<string>();

      const addCard = (front: string, back: string) => {
        const key = front.slice(0, 40);
        if (front.length > 8 && back.length > 8 && !seen.has(key)) {
          seen.add(key);
          cards.push({ front, back });
        }
      };

      // Source 1: Key Takeaways lists
      const headings = document.querySelectorAll("article h2, article h3");
      headings.forEach((h) => {
        if (/key takeaway|takeaway/i.test(h.textContent || "")) {
          let el = h.nextElementSibling;
          while (el && !/^H[1-3]$/.test(el.tagName)) {
            if (el.tagName === "OL" || el.tagName === "UL") {
              el.querySelectorAll("li").forEach((li) => {
                const text = (li.textContent || "").trim();
                if (text.length > 15) {
                  const sepIdx =
                    text.indexOf("—") > 0 ? text.indexOf("—")
                    : text.indexOf(":") > 0 ? text.indexOf(":")
                    : -1;
                  if (sepIdx > 0) {
                    addCard(text.slice(0, sepIdx).trim(), text.slice(sepIdx + 1).trim());
                  } else {
                    addCard(text.length > 70 ? text.slice(0, 70) + "..." : text, text);
                  }
                }
              });
            }
            el = el.nextElementSibling;
          }
        }
      });

      // Source 2: Tables with Strategy/Description or Optimization columns
      const tables = document.querySelectorAll("article table");
      tables.forEach((table) => {
        const headers = Array.from(table.querySelectorAll("th")).map((th) =>
          (th.textContent || "").toLowerCase().trim()
        );
        // Find columns that make good front/back pairs
        const termIdx = headers.findIndex((h) =>
          /strategy|optimization|technique|feature|pattern|tool|metric|driver|category|resource|name|type/i.test(h)
        );
        const descIdx = headers.findIndex((h) =>
          /description|detail|purpose|savings|recommendation|action|best for|use case|use when/i.test(h)
        );
        if (termIdx >= 0 && descIdx >= 0) {
          const rows = table.querySelectorAll("tbody tr");
          rows.forEach((row) => {
            const cells = row.querySelectorAll("td");
            const front = (cells[termIdx]?.textContent || "").trim();
            const back = (cells[descIdx]?.textContent || "").trim();
            if (front.length > 3 && back.length > 3) {
              addCard(front, back);
            }
          });
        }
      });

      // Source 3: Bold terms in paragraphs (definitions)
      if (cards.length < 5) {
        const paras = document.querySelectorAll("article p");
        paras.forEach((p) => {
          const strongs = p.querySelectorAll("strong");
          strongs.forEach((s) => {
            const term = (s.textContent || "").trim();
            const context = (p.textContent || "").trim();
            if (term.length > 3 && term.length < 80 && context.length > 30 && cards.length < 20) {
              addCard(term, context.length > 200 ? context.slice(0, 200) + "..." : context);
            }
          });
        });
      }

      // Cap at 25 cards max
      setFlashcards(cards.slice(0, 25));

      // --- Extract quiz items from <details> with Answer summary ---
      const quiz: QuizQuestion[] = [];
      const details = document.querySelectorAll("article details");
      details.forEach((d) => {
        const summary = d.querySelector("summary");
        if (summary && /answer/i.test(summary.textContent || "")) {
          let questionEl = d.previousElementSibling;
          while (questionEl && questionEl.tagName === "HR") {
            questionEl = questionEl.previousElementSibling;
          }
          const questionText = questionEl ? (questionEl.textContent || "").trim() : "";
          const answerText = (d.textContent || "")
            .replace(summary.textContent || "", "")
            .trim();
          if (questionText.length > 5 && answerText.length > 5) {
            quiz.push({ question: questionText, answer: answerText });
          }
        }
      });
      setQuizItems(quiz);
    }, 800); // wait for DOM render

    return () => clearTimeout(timer);
  }, []);

  // Reset on navigation
  useEffect(() => {
    setShowFlashcards(false);
    setShowQuiz(false);
  }, [flashcards, quizItems]);

  const hasContent = flashcards.length > 0 || quizItems.length > 0;
  if (!hasContent) return null;

  return (
    <>
      {/* Floating action buttons */}
      <div style={fabContainerStyle}>
        {flashcards.length > 0 && (
          <button
            style={fabStyle}
            onClick={() => { setShowFlashcards(true); setShowQuiz(false); }}
            title={`${flashcards.length} Flashcards available`}
          >
            <span style={fabIconStyle}>⚡</span> {flashcards.length} Flashcards
          </button>
        )}
        {quizItems.length > 0 && (
          <button
            style={{ ...fabStyle, background: "linear-gradient(135deg, #059669, #10b981)" }}
            onClick={() => { setShowQuiz(true); setShowFlashcards(false); }}
            title={`${quizItems.length} Quiz questions available`}
          >
            <span style={fabIconStyle}>✓</span> Quiz Mode
          </button>
        )}
      </div>

      {/* Flashcard overlay */}
      {showFlashcards && (
        <FlashcardOverlay cards={flashcards} onClose={() => setShowFlashcards(false)} />
      )}

      {/* Quiz overlay */}
      {showQuiz && (
        <QuizOverlay items={quizItems} onClose={() => setShowQuiz(false)} />
      )}
    </>
  );
}

/* ---- Flashcard Overlay ---- */
function FlashcardOverlay({
  cards,
  onClose,
}: {
  cards: FlashcardItem[];
  onClose: () => void;
}) {
  const [idx, setIdx] = useState(0);
  const [flipped, setFlipped] = useState(false);

  const next = useCallback(() => { setFlipped(false); setIdx((i) => (i + 1) % cards.length); }, [cards.length]);
  const prev = useCallback(() => { setFlipped(false); setIdx((i) => (i - 1 + cards.length) % cards.length); }, [cards.length]);

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key === "ArrowRight") next();
      else if (e.key === "ArrowLeft") prev();
      else if (e.key === " ") { e.preventDefault(); setFlipped((f) => !f); }
      else if (e.key === "Escape") onClose();
    };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [next, prev, onClose]);

  const card = cards[idx];

  return (
    <div style={overlayStyle} onClick={onClose}>
      <div style={modalStyle} onClick={(e) => e.stopPropagation()}>
        <div style={counterStyle}>{idx + 1} / {cards.length}</div>
        <div
          style={{
            ...cardStyle,
            ...(flipped ? cardBackStyle : cardFrontStyle),
          }}
          onClick={() => setFlipped((f) => !f)}
        >
          {flipped ? card.back : card.front}
        </div>
        <p style={hintStyle}>Click card or Space to flip · Arrow keys to navigate · Esc to close</p>
        <div style={navStyle}>
          <button style={navBtnStyle} onClick={prev}>← Prev</button>
          <button style={navBtnStyle} onClick={next}>Next →</button>
        </div>
        <button style={closeBtnStyle} onClick={onClose}>Close</button>
      </div>
    </div>
  );
}

/* ---- Quiz Overlay ---- */
function QuizOverlay({
  items,
  onClose,
}: {
  items: QuizQuestion[];
  onClose: () => void;
}) {
  const [idx, setIdx] = useState(0);
  const [revealed, setRevealed] = useState(false);
  const [score, setScore] = useState(0);
  const [finished, setFinished] = useState(false);

  const total = items.length;
  const item = items[idx];

  const reveal = () => setRevealed(true);
  const knew = () => { setScore((s) => s + 1); advance(); };
  const didnt = () => advance();
  const advance = () => {
    setRevealed(false);
    if (idx + 1 >= total) setFinished(true);
    else setIdx((i) => i + 1);
  };

  useEffect(() => {
    const handler = (e: KeyboardEvent) => { if (e.key === "Escape") onClose(); };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [onClose]);

  if (finished) {
    const pct = Math.round((score / total) * 100);
    return (
      <div style={overlayStyle} onClick={onClose}>
        <div style={modalStyle} onClick={(e) => e.stopPropagation()}>
          <h2 style={{ textAlign: "center", fontSize: "1.3rem", marginBottom: 16 }}>Quiz Complete</h2>
          <div style={scoreCircleStyle}><span>{pct}%</span></div>
          <p style={{ textAlign: "center", margin: "12px 0", fontSize: "0.9rem" }}>{score} / {total} correct</p>
          <button style={closeBtnStyle} onClick={onClose}>Close</button>
        </div>
      </div>
    );
  }

  return (
    <div style={overlayStyle} onClick={onClose}>
      <div style={modalStyle} onClick={(e) => e.stopPropagation()}>
        <div style={counterStyle}>Question {idx + 1} / {total}</div>
        <p style={{ fontSize: "1.05rem", fontWeight: 600, lineHeight: 1.6, marginBottom: 20 }}>{item.question}</p>
        {!revealed && (
          <button style={revealBtnStyle} onClick={reveal}>Reveal Answer</button>
        )}
        {revealed && (
          <>
            <div style={answerBoxStyle}>{item.answer}</div>
            <p style={{ textAlign: "center", fontSize: "0.88rem", fontWeight: 600, margin: "16px 0 8px" }}>Did you know this?</p>
            <div style={navStyle}>
              <button style={{ ...navBtnStyle, background: "#22c55e", color: "#fff", border: "none" }} onClick={knew}>I knew it ✓</button>
              <button style={{ ...navBtnStyle, background: "#ef4444", color: "#fff", border: "none" }} onClick={didnt}>Didn't know ✗</button>
            </div>
          </>
        )}
        <div style={{ marginTop: 20, height: 3, background: "rgba(128,128,128,0.15)", borderRadius: 2 }}>
          <div style={{ height: "100%", width: `${((idx + 1) / total) * 100}%`, background: "linear-gradient(90deg, #6366f1, #a855f7)", borderRadius: 2, transition: "width 0.3s" }} />
        </div>
        <button style={{ ...closeBtnStyle, marginTop: 16 }} onClick={onClose}>Close</button>
      </div>
    </div>
  );
}

/* ---- Styles ---- */
const fabContainerStyle: React.CSSProperties = {
  position: "fixed",
  bottom: 24,
  left: 24,
  zIndex: 998,
  display: "flex",
  flexDirection: "column",
  gap: 8,
};

const fabStyle: React.CSSProperties = {
  padding: "8px 16px",
  border: "none",
  borderRadius: 10,
  background: "linear-gradient(135deg, #6366f1, #8b5cf6)",
  color: "#fff",
  fontSize: "0.78rem",
  fontWeight: 600,
  cursor: "pointer",
  boxShadow: "0 4px 16px rgba(99,102,241,0.35)",
  transition: "all 0.2s",
  display: "flex",
  alignItems: "center",
  gap: 6,
};

const fabIconStyle: React.CSSProperties = { fontSize: "0.9rem" };

const overlayStyle: React.CSSProperties = {
  position: "fixed",
  inset: 0,
  zIndex: 10000,
  display: "flex",
  justifyContent: "center",
  alignItems: "center",
  background: "rgba(0,0,0,0.75)",
  backdropFilter: "blur(6px)",
};

const modalStyle: React.CSSProperties = {
  width: "92%",
  maxWidth: 560,
  maxHeight: "85vh",
  overflowY: "auto",
  padding: 32,
  borderRadius: 16,
  background: "var(--ifm-background-color, #fff)",
  boxShadow: "0 24px 64px rgba(0,0,0,0.3)",
};

const counterStyle: React.CSSProperties = {
  fontSize: "0.75rem",
  fontWeight: 600,
  color: "#6366f1",
  textTransform: "uppercase",
  letterSpacing: 1,
  marginBottom: 16,
  textAlign: "center",
};

const cardStyle: React.CSSProperties = {
  width: "100%",
  minHeight: 180,
  display: "flex",
  justifyContent: "center",
  alignItems: "center",
  padding: 28,
  borderRadius: 14,
  fontSize: "0.95rem",
  lineHeight: 1.6,
  textAlign: "center",
  cursor: "pointer",
  transition: "all 0.3s",
  boxShadow: "0 8px 32px rgba(0,0,0,0.12)",
};

const cardFrontStyle: React.CSSProperties = {
  background: "linear-gradient(135deg, #1e1b4b, #312e81)",
  color: "#fff",
  fontWeight: 700,
  fontSize: "1.05rem",
};

const cardBackStyle: React.CSSProperties = {
  background: "var(--ifm-background-color, #fff)",
  color: "var(--ifm-font-color-base, #333)",
  border: "2px solid #6366f1",
  fontWeight: 500,
};

const hintStyle: React.CSSProperties = {
  textAlign: "center",
  fontSize: "0.7rem",
  color: "var(--ifm-color-emphasis-500, #888)",
  marginTop: 12,
};

const navStyle: React.CSSProperties = {
  display: "flex",
  gap: 12,
  justifyContent: "center",
  marginTop: 16,
};

const navBtnStyle: React.CSSProperties = {
  padding: "8px 24px",
  border: "1px solid var(--ifm-color-emphasis-300, #ccc)",
  borderRadius: 8,
  background: "transparent",
  color: "var(--ifm-font-color-base, #333)",
  fontSize: "0.85rem",
  fontWeight: 600,
  cursor: "pointer",
};

const closeBtnStyle: React.CSSProperties = {
  display: "block",
  margin: "12px auto 0",
  padding: "6px 20px",
  border: "none",
  borderRadius: 8,
  background: "rgba(128,128,128,0.1)",
  color: "var(--ifm-color-emphasis-600, #666)",
  fontSize: "0.78rem",
  cursor: "pointer",
};

const revealBtnStyle: React.CSSProperties = {
  display: "block",
  margin: "0 auto",
  padding: "10px 28px",
  border: "2px solid #6366f1",
  borderRadius: 8,
  background: "transparent",
  color: "#6366f1",
  fontSize: "0.9rem",
  fontWeight: 600,
  cursor: "pointer",
};

const answerBoxStyle: React.CSSProperties = {
  padding: 16,
  borderRadius: 10,
  background: "rgba(34,197,94,0.08)",
  borderLeft: "4px solid #22c55e",
  fontSize: "0.9rem",
  lineHeight: 1.6,
};

const scoreCircleStyle: React.CSSProperties = {
  display: "flex",
  justifyContent: "center",
  alignItems: "center",
  width: 100,
  height: 100,
  borderRadius: "50%",
  border: "4px solid #6366f1",
  margin: "0 auto 12px",
  fontSize: "1.6rem",
  fontWeight: 800,
  color: "#6366f1",
};
