import { themes as prismThemes } from "prism-react-renderer";
import type { Config } from "@docusaurus/types";
import type * as Preset from "@docusaurus/preset-classic";

const config: Config = {
  title: "Azure Wiki",
  tagline: "The open glue — binding infrastructure, platform, and application for AI architecture",
  favicon: "img/favicon.ico",

  url: "https://gitpavleenbali.github.io",
  baseUrl: "/azure-wiki/",

  organizationName: "gitpavleenbali",
  projectName: "azure-wiki",
  trailingSlash: false,

  onBrokenLinks: "warn",
  onBrokenMarkdownLinks: "warn",

  i18n: {
    defaultLocale: "en",
    locales: ["en"],
  },

  markdown: {
    mermaid: true,
    format: "detect",
  },

  themes: ["@docusaurus/theme-mermaid"],

  presets: [
    [
      "classic",
      {
        docs: {
          path: "../",
          routeBasePath: "/",
          include: [
            "cost-optimization/**/*.md",
            "APIM-best-practices/**/*.md",
            "FrontDoor-best-practices/**/*.md",
            "unified-monitoring-solution/**/*.md",
            "azure-ai-foundry/**/*.md",
            "azure-storage/**/*.md",
            "devsecops/**/*.md",
            "aifroot/**/*.md",
          ],
          exclude: [
            "README.md",
            "_website/**",
            ".internal/**",
            "apim-appgw-mtls/**",
            "node_modules/**",
          ],
          sidebarPath: "./sidebars.ts",
          editUrl: "https://github.com/gitpavleenbali/azure-wiki/tree/master/",
        },
        blog: false,
        theme: {
          customCss: "./src/css/custom.css",
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: "img/azure-wiki-social.png",

    // Announcement bar
    announcementBar: {
      id: "interactive_learning",
      content:
        'Interactive learning platform — Flashcards, Quizzes & Gamification built in. Press <kbd>Alt+G</kbd> for your dashboard.',
      backgroundColor: "#1a1a2e",
      textColor: "#e0e0e0",
      isCloseable: true,
    },

    // Navbar
    navbar: {
      title: "Azure Wiki",
      logo: {
        alt: "Azure Wiki",
        src: "img/logo.svg",
        href: "/azure-wiki/",
      },
      items: [
        {
          type: "docSidebar",
          sidebarId: "costOptSidebar",
          position: "left",
          label: "Cost Optimization",
        },
        {
          type: "docSidebar",
          sidebarId: "apimSidebar",
          position: "left",
          label: "APIM",
        },
        {
          type: "docSidebar",
          sidebarId: "frontdoorSidebar",
          position: "left",
          label: "Front Door",
        },
        {
          type: "docSidebar",
          sidebarId: "monitoringSidebar",
          position: "left",
          label: "Monitoring",
        },
        {
          type: "docSidebar",
          sidebarId: "aifrootSidebar",
          position: "left",
          label: "AI Hub",
        },
        {
          to: "/froot-ai",
          label: "🌳 FrootAI",
          position: "right",
          className: "navbar-frootai",
        },
        {
          to: "/learning-hub",
          label: "★ Learning Hub",
          position: "right",
          className: "navbar-learning-hub",
        },
        {
          href: "https://www.linkedin.com/build-relation/newsletter-follow?entityUrn=7001119707667832832",
          label: "Newsletter",
          position: "right",
        },
        {
          href: "https://github.com/gitpavleenbali/azure-wiki",
          label: "GitHub",
          position: "right",
        },
      ],
    },

    // Footer
    footer: {
      style: "dark",
      links: [
        {
          title: "Modules",
          items: [
            { label: "Cost Optimization", to: "/cost-optimization/" },
            { label: "APIM Best Practices", to: "/APIM-best-practices/" },
            { label: "Front Door", to: "/FrontDoor-best-practices/" },
            { label: "Monitoring", to: "/unified-monitoring-solution/" },
          ],
        },
        {
          title: "More Topics",
          items: [
            { label: "🌳 FrootAI", to: "/froot-ai" },
            { label: "AI Foundry", to: "/azure-ai-foundry/AI-Foundry-Cross-Region-Architecture" },
            { label: "ADLS Gen2", to: "/azure-storage/ADLS-Gen2-Strategy-Guidance" },
            { label: "DevSecOps", to: "/devsecops/DEVSECOPS_BEST_PRACTICES_GUIDE" },
          ],
        },
        {
          title: "Connect",
          items: [
            {
              label: "LinkedIn",
              href: "https://linkedin.com/in/pavleenbali",
            },
            {
              label: "GitHub",
              href: "https://github.com/gitpavleenbali",
            },
            {
              label: "Check1Minute Newsletter",
              href: "https://www.linkedin.com/build-relation/newsletter-follow?entityUrn=7001119707667832832",
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Pavleen Bali — Built with passion for the Azure community.`,
    },

    // Prism syntax highlighting
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: [
        "powershell",
        "bicep",
        "bash",
        "json",
        "yaml",
        "kusto",
        "csharp",
        "python",
        "hcl",
      ],
    },

    // Color mode
    colorMode: {
      defaultMode: "dark",
      disableSwitch: false,
      respectPrefersColorScheme: true,
    },

    // Mermaid
    mermaid: {
      theme: { light: "neutral", dark: "dark" },
    },

    // Table of contents depth
    tableOfContents: {
      minHeadingLevel: 2,
      maxHeadingLevel: 4,
    },

    // Algolia search (placeholder — can switch to local search)
    // For now using the built-in lunr search via plugin below
  } satisfies Preset.ThemeConfig,

  // Local search (no Algolia needed)
  plugins: [],
};

export default config;
