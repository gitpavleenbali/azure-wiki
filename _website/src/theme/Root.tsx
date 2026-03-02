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

  // Scroll to top on every page navigation
  useEffect(() => {
    window.scrollTo({ top: 0, behavior: "instant" });
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
