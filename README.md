# Azure Wiki

<div align="center">

[![Live Site](https://img.shields.io/badge/Live_Site-gitpavleenbali.github.io/azure--wiki-6366f1?style=for-the-badge)](https://gitpavleenbali.github.io/azure-wiki/)
![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)
![React](https://img.shields.io/badge/React-18-61DAFB?style=for-the-badge&logo=react&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white)

**Interactive Azure learning platform with flashcards, quizzes, and gamification.**

[Explore the Site](https://gitpavleenbali.github.io/azure-wiki/) | [LinkedIn](https://linkedin.com/in/pavleenbali) | [Newsletter](https://www.linkedin.com/build-relation/newsletter-follow?entityUrn=7001119707667832832)

</div>

---

## What Is This

An open-source, interactive knowledge base for Azure practitioners. Every doc page automatically generates flashcards from its content and offers quiz modes where applicable. A gamification engine tracks XP, streaks, and levels across your learning journey.

Built with **Docusaurus 3**, **React 18**, **TypeScript**, deployed via **GitHub Actions** to **GitHub Pages**.

---

## Modules

| Module | Chapters | What You Learn |
|--------|:--------:|----------------|
| [**Cost Optimization**](./cost-optimization/) | 9 | WAF fundamentals, FinOps lifecycle, rate/usage optimization, AI token economics, GPU cost management |
| [**APIM Best Practices**](./APIM-best-practices/) | 19 | Architecture, security, policies, AI gateway, monetization, capacity planning, troubleshooting |
| [**Front Door**](./FrontDoor-best-practices/) | 6 | Reliability, security, cost optimization, operational excellence, performance |
| [**Monitoring**](./unified-monitoring-solution/) | 4 | Unified observability architecture, operations runbook, platform scenarios |
| [**AI Foundry**](./azure-ai-foundry/) | 1 | Cross-region Azure AI Foundry architecture patterns |
| [**ADLS Gen2**](./azure-storage/) | 1 | Data lake storage strategy and governance |
| [**DevSecOps**](./devsecops/) | 1 | CI/CD security integration, shift-left practices |

---

## Interactive Features

| Feature | How It Works |
|---------|-------------|
| **Flashcards** | Auto-extracted from tables, key takeaways, and bold terms on every page. Click the floating button on the left. |
| **Quiz Mode** | Self-assessment from Q&A blocks. Reveal answer, score yourself, see results. |
| **XP & Levels** | Earn XP by reading pages (65% scroll = complete). Track streaks. Level up from Cloud Novice to FinOps Legend. |
| **Progress Bar** | Scroll-based reading progress on every page. |
| **Mermaid Diagrams** | Architecture diagrams, decision trees, and flow charts rendered natively. |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Docusaurus 3 |
| Components | React 18, TypeScript |
| Diagrams | Mermaid (native) |
| Syntax | Prism (PowerShell, Bicep, KQL, Python, C#, HCL) |
| Design | Dark-first, glassmorphism, indigo/violet palette |
| CI/CD | GitHub Actions |
| Hosting | GitHub Pages |

---

## Local Development

```bash
git clone https://github.com/gitpavleenbali/azure-wiki.git
cd azure-wiki/_website
npm install
npm start        # Dev server at localhost:3000
npm run build    # Production build
```

---

## Contributing

1. Fork the repo
2. Create a branch (`git checkout -b feature/your-topic`)
3. Add content following the existing module structure
4. Submit a pull request

All content uses standard Markdown with Mermaid diagrams. Interactive features (flashcards, quizzes) are auto-generated from content structure — no special markup needed.

---

<div align="center">

**[Explore the Site](https://gitpavleenbali.github.io/azure-wiki/)**

Made by [Pavleen Bali](https://linkedin.com/in/pavleenbali) for the Azure community.

</div>

</div>
