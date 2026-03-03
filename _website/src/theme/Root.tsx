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

  // Force scroll to top on every page navigation.
  // Uses a persistent interval to override Docusaurus scroll restoration,
  // which fires asynchronously and can restore saved scroll position AFTER
  // our initial scrollTo calls.
  useEffect(() => {
    window.scrollTo(0, 0);

    // Keep forcing scroll to top for 600ms to beat Docusaurus scroll restore
    const interval = setInterval(() => window.scrollTo(0, 0), 16); // every frame
    const cleanup = setTimeout(() => clearInterval(interval), 600);

    return () => {
      clearInterval(interval);
      clearTimeout(cleanup);
    };
  }, [location.pathname]);

  // Intercept logo/title click: ALWAYS scroll to top, even if already on homepage
  useEffect(() => {
    const handleBrandClick = (e: MouseEvent) => {
      const link = (e.target as HTMLElement).closest?.("a.navbar__brand");
      if (!link) return;

      const isHome =
        location.pathname === "/azure-wiki/" ||
        location.pathname === "/azure-wiki" ||
        location.pathname === "/";

      if (isHome) {
        e.preventDefault();
      }

      // Always force to top — whether same page or navigating
      window.scrollTo(0, 0);
      const interval = setInterval(() => window.scrollTo(0, 0), 16);
      setTimeout(() => clearInterval(interval), 600);
    };

    document.addEventListener("click", handleBrandClick, true);
    return () => document.removeEventListener("click", handleBrandClick, true);
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
