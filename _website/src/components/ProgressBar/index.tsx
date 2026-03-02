import React, { useEffect, useRef } from "react";

export default function ProgressBar(): JSX.Element {
  const fillRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handler = () => {
      if (!fillRef.current) return;
      const scrollTop = window.scrollY;
      const docHeight = document.documentElement.scrollHeight - window.innerHeight;
      const pct = docHeight > 0 ? Math.min((scrollTop / docHeight) * 100, 100) : 0;
      fillRef.current.style.width = `${pct}%`;
    };

    window.addEventListener("scroll", handler, { passive: true });
    return () => window.removeEventListener("scroll", handler);
  }, []);

  return (
    <div className="aw-progress-bar">
      <div className="aw-progress-fill" ref={fillRef} />
    </div>
  );
}
