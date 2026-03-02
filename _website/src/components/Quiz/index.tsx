import React, { useState, useCallback } from "react";
import styles from "./Quiz.module.css";

interface QuizQuestion {
  question: string;
  options: string[];
  correct: number; // 0-based index
  explanation?: string;
}

interface QuizProps {
  questions: QuizQuestion[];
  title?: string;
}

export default function Quiz({ questions, title }: QuizProps): JSX.Element {
  const [current, setCurrent] = useState(0);
  const [selected, setSelected] = useState<number | null>(null);
  const [score, setScore] = useState(0);
  const [answered, setAnswered] = useState<Set<number>>(new Set());
  const [finished, setFinished] = useState(false);

  const q = questions[current];
  const isAnswered = answered.has(current);
  const isCorrect = selected === q.correct;

  const handleSelect = useCallback(
    (idx: number) => {
      if (isAnswered) return;
      setSelected(idx);
      setAnswered((a) => new Set(a).add(current));
      if (idx === q.correct) setScore((s) => s + 1);
    },
    [current, q.correct, isAnswered]
  );

  const next = useCallback(() => {
    if (current + 1 >= questions.length) {
      setFinished(true);
    } else {
      setCurrent((c) => c + 1);
      setSelected(null);
    }
  }, [current, questions.length]);

  const restart = useCallback(() => {
    setCurrent(0);
    setSelected(null);
    setScore(0);
    setAnswered(new Set());
    setFinished(false);
  }, []);

  if (finished) {
    const pct = Math.round((score / questions.length) * 100);
    let grade: string;
    if (pct >= 90) grade = "Cloud Master";
    else if (pct >= 70) grade = "Cloud Expert";
    else if (pct >= 50) grade = "Cloud Practitioner";
    else grade = "Keep Learning";

    return (
      <div className={styles.container}>
        <div className={styles.results}>
          <div className={styles.scoreCircle}>
            <span>{pct}%</span>
          </div>
          <h3 className={styles.grade}>{grade}</h3>
          <p className={styles.scoreStat}>
            {score} / {questions.length} correct
          </p>
          <button className={styles.restartBtn} onClick={restart}>
            Try Again
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className={styles.container}>
      {title && <h3 className={styles.title}>{title}</h3>}

      <div className={styles.header}>
        <span className={styles.counter}>
          Question {current + 1} / {questions.length}
        </span>
        <span className={styles.scoreLabel}>Score: {score}</span>
      </div>

      <div className={styles.questionCard}>
        <p className={styles.question}>{q.question}</p>

        <div className={styles.options}>
          {q.options.map((opt, idx) => {
            let optClass = styles.option;
            if (isAnswered) {
              if (idx === q.correct) optClass += " " + styles.correct;
              else if (idx === selected) optClass += " " + styles.wrong;
            }
            if (idx === selected && !isAnswered)
              optClass += " " + styles.selected;

            return (
              <button
                key={idx}
                className={optClass}
                onClick={() => handleSelect(idx)}
                disabled={isAnswered}
              >
                <span className={styles.optionLetter}>
                  {String.fromCharCode(65 + idx)}
                </span>
                {opt}
              </button>
            );
          })}
        </div>

        {isAnswered && q.explanation && (
          <div
            className={`${styles.explanation} ${
              isCorrect ? styles.explCorrect : styles.explWrong
            }`}
          >
            {q.explanation}
          </div>
        )}

        {isAnswered && (
          <button className={styles.nextBtn} onClick={next}>
            {current + 1 >= questions.length ? "See Results" : "Next Question"}
          </button>
        )}
      </div>

      <div className={styles.progressBar}>
        <div
          className={styles.progressFill}
          style={{ width: `${((current + 1) / questions.length) * 100}%` }}
        />
      </div>
    </div>
  );
}
