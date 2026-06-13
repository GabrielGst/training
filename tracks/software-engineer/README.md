# Track: Software Engineer

## Objective

Build production-grade full-stack engineering skills: from shell scripting and Node.js backends to Next.js frontends and CI/CD pipelines. By the end of this track, you can ship a full-stack web application end-to-end, solo or in a team.

---

## Junior → Senior Progression

| Level | Can do |
|-------|--------|
| Junior | Write a REST API in Node.js/Express, build a multi-page Next.js app with SSR, write basic Bash scripts, run a Docker Compose stack |
| Mid | Build with Next.js App Router (RSC, streaming), write E2E tests with Playwright, set up GitHub Actions CI/CD, understand web performance optimization |
| Senior | Architect a full-stack system (API design, auth, caching, DB design), lead design docs, make framework trade-offs, mentor code reviews, optimize for Core Web Vitals |

---

## Modules

| # | Module | Key Skills | Status |
|---|--------|-----------|--------|
| 01 | [Shell Scripting](01-shell-scripting/) | Bash, pipes, error handling, idempotent scripts | ⏳ |
| 02 | [Node.js Fundamentals](02-nodejs-fundamentals/) | Node.js, Fastify/Express, REST, async, streams | ⏳ |
| 03 | [Next.js](03-nextjs/) | App Router, RSC, SSR/SSG, TypeScript, Tailwind | ⏳ |
| 04 | [Orchestration](04-orchestration/) | Docker Compose, GitHub Actions, k8s intro, Helm | ⏳ |
| 05 | [Capstone: Full-Stack App](05-capstone-fullstack-app/) | All of the above, deployed | ⏳ |

---

## Job Market Mapping

From [`skill-matrix.md`](../../doc/research/skill-matrix.md):

| Skill | JD Frequency | This Track Module |
|-------|------------|-------------------|
| TypeScript | **High** (growing) | 03-nextjs, 02-nodejs-fundamentals |
| React / Next.js | **High** (43% React) | 03-nextjs |
| Node.js | **High** | 02-nodejs-fundamentals |
| Docker | **High** | 04-orchestration |
| GitHub Actions | **High** | 04-orchestration |
| Bash scripting | **Medium** | 01-shell-scripting |
| Testing (Jest/Playwright) | **High** | 03-nextjs, 05-capstone |
| PostgreSQL | **High** | 05-capstone-fullstack-app |

---

## Resources

1. [Next.js documentation](https://nextjs.org/docs) — App Router is the future; master it here
2. [Josh Comeau's blog](https://www.joshwcomeau.com) — Best React + CSS mental models online
3. [TechWorld with Nana YouTube](https://www.youtube.com/@TechWorldwithNana) — Docker, k8s, CI/CD — best production intros

---

## Capstone

**Module 05 — Full-Stack Task Management App**

A Kanban task board with drag-and-drop, real-time updates, and a PostgreSQL backend. Built with Next.js 14+ App Router, TypeScript, Tailwind, and Playwright E2E tests. Deployed to Vercel (frontend) + Railway (database). See [doc/roadmap/phase-3-capstones.md](../../doc/roadmap/phase-3-capstones.md#capstone-2-full-stack-task-management-app-software-engineer) for full spec.
