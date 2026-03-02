import React, { useState, useCallback, useEffect } from "react";
import styles from "./Flashcard.module.css";

interface FlashcardItem {
  front: string;
  back: string;
}

interface FlashcardProps {
  cards: FlashcardItem[];
  title?: string;
}

export default function Flashcard({ cards, title }: FlashcardProps): JSX.Element {
  const [index, setIndex] = useState(0);
  const [flipped, setFlipped] = useState(false);
  const [reviewed, setReviewed] = useState<Set<number>>(new Set());

  const current = cards[index];
  const progress = Math.round((reviewed.size / cards.length) * 100);

  const flip = useCallback(() => {
    setFlipped((f) => !f);
    setReviewed((r) => new Set(r).add(index));
  }, [index]);

  const next = useCallback(() => {
    setFlipped(false);
    setIndex((i) => (i + 1) % cards.length);
  }, [cards.length]);

  const prev = useCallback(() => {
    setFlipped(false);
    setIndex((i) => (i - 1 + cards.length) % cards.length);
  }, [cards.length]);

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key === "ArrowRight") next();
      else if (e.key === "ArrowLeft") prev();
      else if (e.key === " ") { e.preventDefault(); flip(); }
    };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [next, prev, flip]);

  return (
    <div className={styles.container}>
      {title && <h3 className={styles.title}>{title}</h3>}

      <div className={styles.counter}>
        {index + 1} / {cards.length}
        <span className={styles.reviewed}>{reviewed.size} reviewed</span>
      </div>

      <div
        className={`${styles.card} ${flipped ? styles.flipped : ""}`}
        onClick={flip}
        role="button"
        tabIndex={0}
        aria-label="Click to flip"
      >
        <div className={styles.front}>{current.front}</div>
        <div className={styles.back}>{current.back}</div>
      </div>

      <p className={styles.hint}>Click card or press Space to flip. Arrow keys to navigate.</p>

      <div className={styles.nav}>
        <button className={styles.btn} onClick={prev}>&larr; Prev</button>
        <button className={styles.btn} onClick={next}>Next &rarr;</button>
      </div>

      <div className={styles.progressBar}>
        <div className={styles.progressFill} style={{ width: `${progress}%` }} />
      </div>
    </div>
  );
}
