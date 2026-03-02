import React, { useState, useEffect, useCallback } from "react";
import { useLocation } from "@docusaurus/router";
import styles from "./GamificationBadge.module.css";

/* ---- Persistent State ---- */
const STORAGE_KEY = "azurewiki_xp";

interface GameState {
  xp: number;
  pagesRead: string[];
  streak: number;
  lastVisit: string | null;
  flashcardsReviewed: number;
}

const LEVELS = [
  { name: "Cloud Novice", min: 0 },
  { name: "Cloud Practitioner", min: 50 },
  { name: "Cloud Architect", min: 150 },
  { name: "Cloud Expert", min: 350 },
  { name: "Cloud Master", min: 600 },
  { name: "FinOps Legend", min: 1000 },
];

function loadState(): GameState {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw
      ? JSON.parse(raw)
      : { xp: 0, pagesRead: [], streak: 0, lastVisit: null, flashcardsReviewed: 0 };
  } catch {
    return { xp: 0, pagesRead: [], streak: 0, lastVisit: null, flashcardsReviewed: 0 };
  }
}

function saveState(s: GameState) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(s));
}

function getLevel(xp: number) {
  let lvl = LEVELS[0];
  for (const l of LEVELS) if (xp >= l.min) lvl = l;
  return lvl;
}

function getNextLevel(xp: number) {
  for (const l of LEVELS) if (xp < l.min) return l;
  return null;
}

export default function GamificationBadge(): JSX.Element {
  const [state, setState] = useState<GameState>(loadState);
  const [open, setOpen] = useState(false);
  const location = useLocation();

  // Hide on homepage
  const isHomepage = location.pathname === "/azure-wiki/" || location.pathname === "/azure-wiki" || location.pathname === "/";

  // Track page read on scroll
  useEffect(() => {
    let marked = false;
    const path = window.location.pathname;
    const handler = () => {
      if (marked) return;
      const pct = window.scrollY / (document.documentElement.scrollHeight - window.innerHeight);
      if (pct >= 0.65) {
        marked = true;
        setState((prev) => {
          if (prev.pagesRead.includes(path)) return prev;
          const next = { ...prev, pagesRead: [...prev.pagesRead, path], xp: prev.xp + 10 };
          saveState(next);
          return next;
        });
      }
    };
    window.addEventListener("scroll", handler, { passive: true });
    return () => window.removeEventListener("scroll", handler);
  }, []);

  // Track streak
  useEffect(() => {
    const today = new Date().toISOString().slice(0, 10);
    setState((prev) => {
      if (prev.lastVisit === today) return prev;
      const yesterday = new Date(Date.now() - 86400000).toISOString().slice(0, 10);
      const streak = prev.lastVisit === yesterday ? prev.streak + 1 : 1;
      const next = { ...prev, streak, lastVisit: today };
      saveState(next);
      return next;
    });
  }, []);

  // Alt+G shortcut
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.altKey && e.key === "g") {
        e.preventDefault();
        setOpen((o) => !o);
      }
    };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, []);

  const lvl = getLevel(state.xp);
  const nxt = getNextLevel(state.xp);
  const pct = nxt ? Math.round(((state.xp - lvl.min) / (nxt.min - lvl.min)) * 100) : 100;

  return (
    <>
      {null /* Badge is now rendered inside AutoInteractive fab stack */}
    </>
  );
}
