import React, { useEffect } from "react";
import { useLocation } from "@docusaurus/router";
import GamificationBadge from "@site/src/components/GamificationBadge";
import ProgressBar from "@site/src/components/ProgressBar";
import AutoInteractive from "@site/src/components/AutoInteractive";

interface RootProps {
  children: React.ReactNode;
}

export default function Root({ children }: RootProps): JSX.Element {
  const location = useLocation();

  // Scroll to top on every page navigation - AGGRESSIVE approach
  useEffect(() => {
    // Multiple attempts to override Docusaurus scroll restoration
    window.scrollTo(0, 0);
    setTimeout(() => window.scrollTo(0, 0), 0);
    setTimeout(() => window.scrollTo(0, 0), 1);
    setTimeout(() => window.scrollTo(0, 0), 10);
    setTimeout(() => window.scrollTo(0, 0), 50);
    requestAnimationFrame(() => window.scrollTo(0, 0));
    requestAnimationFrame(() => {
      requestAnimationFrame(() => window.scrollTo(0, 0));
    });
  }, [location.pathname]);

  return (
    <>
      <ProgressBar />
      {children}
      <AutoInteractive />
      <GamificationBadge />
    </>
  );
}
