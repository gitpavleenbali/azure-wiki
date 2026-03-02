import React, { useEffect, useRef } from "react";
import { useLocation } from "@docusaurus/router";

export default function ProgressBar(): JSX.Element {
  const fillRef = useRef<HTMLDivElement>(null);
  const location = useLocation();

  useEffect(() => {
    // Reset on navigation
    if (fillRef.current) fillRef.current.style.width = "0%";

    const handler = () => {
      if (!fillRef.current) return;
      const scrollTop = window.scrollY;
      const docHeight = document.documentElement.scrollHeight - window.innerHeight;
      const pct = docHeight > 0 ? Math.min((scrollTop / docHeight) * 100, 100) : 0;
      fillRef.current.style.width = `${pct}%`;
    };

    window.addEventListener("scroll", handler, { passive: true });
    // Run once to set initial position
    handler();
    return () => window.removeEventListener("scroll", handler);
  }, [location.pathname]);

  return (
    <div className="aw-progress-bar">
      <div className="aw-progress-fill" ref={fillRef} />
    </div>
  );
}
