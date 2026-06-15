# Track: Software Engineer

## Objective

Build production-grade full-stack engineering skills: from shell scripting and Node.js backends to Next.js frontends and CI/CD pipelines. By the end of this track you can ship a full-stack web application end-to-end, solo or in a team — and anchor that in real FDE portfolio projects.

---

## Junior → Senior Progression

| Level | Can do |
|-------|--------|
| Junior | Write a REST API in Node.js/Express, build a multi-page Next.js app with SSR, write basic Bash scripts, run a Docker Compose stack |
| Mid | Build with Next.js App Router (RSC, streaming), write E2E tests with Playwright, set up GitHub Actions CI/CD, understand web performance optimization |
| Senior | Architect a full-stack system (API design, auth, caching, DB design), lead design docs, make framework trade-offs, mentor code reviews, optimize for Core Web Vitals |

---

## Modules

### Phase 1 — Foundations

| # | Slug | Key Skills | Hours | Status |
|---|------|-----------|-------|--------|
| 01 | [01-shell-scripting](01-shell-scripting/) | Bash, pipes, error handling, idempotent scripts, env management | 10 | ⏳ |
| 02 | [02-nodejs-fundamentals](02-nodejs-fundamentals/) | Node.js, Express/Fastify, REST, async, streams | 15 | ⏳ |
| 03 | [03-nextjs-basics](03-nextjs/) | App Router, RSC, SSR/SSG, TypeScript strict mode, Tailwind | 15 | ⏳ |

### Phase 2 — Core Modules

| # | Slug | Key Skills | Hours | Anchor Project | Status |
|---|------|-----------|-------|---------------|--------|
| 04 | [04-nextjs-advanced](04-nextjs-advanced/) | API routes, server actions, auth (NextAuth), middleware, performance | 15 | P06 AI Copilot | ⏳ |
| 05 | [05-orchestration](05-orchestration/) | Docker Compose, GitHub Actions, k8s intro, Helm basics | 15 | P02 Customer Support | ⏳ |
| 06 | [06-testing-deep-dive](06-testing-deep-dive/) | Unit, integration, E2E (Playwright), coverage gates, mocking | 12 | P07 Field Service | ⏳ |
| 07 | [07-performance-optimization](07-performance-optimization/) | Profiling, caching, query optimization, bundle analysis | 10 | P07 Field Service | ⏳ |

### Phase 3 — Capstone

| Slug | Description | Hours | Status |
|------|-------------|-------|--------|
| [capstone-fullstack-app](capstone-fullstack-app/) | Kanban task board: Next.js + Node.js + PostgreSQL + Playwright, deployed | 50 | ⏳ |

---

## FDE Portfolio Projects (anchored in this track)

| Project | Domain | Key Skills | Modules Required |
|---------|--------|-----------|-----------------|
| [P07 Field Service](../../doc/roadmap/projects/ai-projects.md#p07) | Field Services | SK04, SK05, SK27, SK28 | 02, 03, 04, 06 |
| [P06 AI Copilot](../../doc/roadmap/projects/ai-projects.md#p06) | Developer Tools | SK04, SK05, SK24 | 03, 04 |

---

## Job Market Mapping

From [`skill-matrix.md`](../../doc/research/skill-matrix.md):

| Skill ID | Skill | JD Frequency | Tier | Module |
|----------|-------|------------|------|--------|
| — | JavaScript / TypeScript | **High** (66% JS, TS growing) | P1 | 02-nodejs-fundamentals, 03-nextjs-basics |
| — | React | **High** (43%) | P1 | 03-nextjs-basics |
| — | Next.js (App Router) | **High** | P1 | 03-nextjs-basics, 04-nextjs-advanced |
| — | Node.js | **High** | P1 | 02-nodejs-fundamentals |
| SK04 | API Design & Contract Management | **High** | P1 | 02-nodejs-fundamentals |
| SK05 | Full-Stack Application Development | **High** | P1 | 03-nextjs-basics, 04-nextjs-advanced |
| — | Docker / Docker Compose | **High** | P1 | 05-orchestration |
| — | GitHub Actions / CI-CD | **High** | P1 | 05-orchestration |
| — | Testing (Jest / Playwright) | **High** | P1 | 06-testing-deep-dive |
| — | Shell scripting (Bash) | **Medium** | P2 | 01-shell-scripting |

---

## Resources

1. [Next.js documentation](https://nextjs.org/docs) — App Router is the future; master it here
2. [Josh Comeau's blog](https://www.joshwcomeau.com) — Best React + CSS mental models online
3. [TechWorld with Nana YouTube](https://www.youtube.com/@TechWorldwithNana) — Docker, k8s, CI/CD — best production intros

---

## Capstone

**`capstone-fullstack-app` — Full-Stack Task Management App**

A Kanban task board with drag-and-drop, real-time updates, and a PostgreSQL backend. Built with Next.js 14+ App Router, TypeScript, Tailwind, and Playwright E2E tests. Deployed to Vercel (frontend) + Railway (database).

Full spec: [doc/roadmap/phase-3-capstones.md](../../doc/roadmap/phase-3-capstones.md#capstone-2-full-stack-task-management-app-software-engineer)
