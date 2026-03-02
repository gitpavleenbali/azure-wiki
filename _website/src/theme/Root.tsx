import React from "react";
import GamificationBadge from "@site/src/components/GamificationBadge";
import ProgressBar from "@site/src/components/ProgressBar";

interface RootProps {
  children: React.ReactNode;
}

// This wraps the entire Docusaurus app — renders on every page
export default function Root({ children }: RootProps): JSX.Element {
  return (
    <>
      <ProgressBar />
      {children}
      <GamificationBadge />
    </>
  );
}
