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
    window.scrollTo(0, 0);
    setTimeout(() => window.scrollTo(0, 0), 0);
    setTimeout(() => window.scrollTo(0, 0), 10);
    setTimeout(() => window.scrollTo(0, 0), 50);
    requestAnimationFrame(() => window.scrollTo(0, 0));
    requestAnimationFrame(() => {
      requestAnimationFrame(() => window.scrollTo(0, 0));
    });
  }, [location.pathname]);

  // Intercept logo/title click: ALWAYS scroll to top, even if already on homepage
  useEffect(() => {
    const handleBrandClick = (e: MouseEvent) => {
      const link = (e.target as HTMLElement).closest?.("a.navbar__brand");
      if (!link) return;

      // If already on homepage, prevent default nav and just scroll to top
      const isHome =
        location.pathname === "/azure-wiki/" ||
        location.pathname === "/azure-wiki" ||
        location.pathname === "/";

      if (isHome) {
        e.preventDefault();
        window.scrollTo({ top: 0, left: 0, behavior: "smooth" });
      }
      // If on another page, the link navigates normally and the pathname useEffect scrolls to top
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
