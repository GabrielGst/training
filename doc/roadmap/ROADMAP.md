# Master Roadmap

> Target: Full-Stack / AI Engineer employable level (junior → senior)
> Estimated total: ~2,180 hours across all tracks
> At 4 h/day, 5 days/week: ~22 months elapsed (tracks run in parallel, so real time is ~12–14 months of focused effort)

---

## Phase 1 — Foundations (Weeks 1–4)

**Goal:** Establish non-negotiable hard floor skills before diving into domain tracks.

| Area | Topics | Hours |
|------|--------|-------|
| Git mastery | Conventional commits, rebasing, conflict resolution, PR workflow | 8 |
| Python fluency | Type hints, OOP, packaging, testing with pytest, ruff/black | 20 |
| JavaScript / TypeScript | ES6+, async/await, TS strict mode, module system | 20 |
| Docker fundamentals | Dockerfile, Compose, volumes, networking | 10 |
| Shell scripting | Bash, pipes, cron, environment management | 10 |
| PostgreSQL basics | DDL, DML, joins, indexes, psql CLI | 12 |

**Success criteria:**
- Can explain a Git rebase vs merge and when to use each
- Can write a typed Python module with tests that passes `ruff` and `pytest`
- Can write a TypeScript function with proper generics
- Can build and run a multi-container Compose stack
- Can write a non-trivial Bash script with error handling
- Docker stack (`docker compose up`) works on clean machine

**Deliverables:**
- Git cheat sheet personalized to this repo's conventions
- Python "starter kit" module (typed, tested, linted)
- TypeScript kata set (10 exercises)
- Compose stack running (postgres + pgadmin verified)
- `scripts/setup.sh` written and verified

Full detail: [phase-1-foundations.md](phase-1-foundations.md)

---

## Phase 2 — Core Tracks (Weeks 5–20)

**Goal:** Work through all six tracks in parallel. Each module = one project minimum. Target 3–4 modules per track per month.

### Parallel track schedule

```
Week  5–7   : AI Eng: python-foundations + fastapi
              SWE:    shell-scripting + nodejs-fundamentals
              Data:   postgresql deep dive
              Agents: llm-fundamentals
              GPU:    cuda-setup

Week  8–10  : AI Eng: data-viz (seaborn + plotly)
              SWE:    nextjs (pages + routing + SSR)
              Data:   django-orm
              Agents: langchain
              GPU:    nvidia-smi + nvtop

Week 11–13  : AI Eng: tensorflow fundamentals
              SWE:    nextjs (App Router, RSC, auth)
              Data:   mysql-mariadb
              Agents: langgraph
              GPU:    remote-training-bridge

Week 14–16  : AI Eng: pytorch fundamentals
              SWE:    orchestration (Docker Compose → GitHub Actions → k8s intro)
              Data:   data-pipelines (Airflow + dbt)
              Agents: crewai
              HPC:    hpc-intro (Slurm + MPI)

Week 17–20  : AI Eng: pytorch advanced (DDP, AMP, HF Transformers)
              SWE:    testing deep dive + perf optimization
              Data:   data-pipelines advanced + cloud warehouses
              Agents: mcp-tool-use
              HPC:    quantum-intro (Qiskit)
```

**Success criteria per module:**
- Working project pushed to this repo
- Module README updated with what was built and learned
- At least one meaningful test
- Code passes lint

Full detail: [phase-2-core-tracks.md](phase-2-core-tracks.md)

---

## Phase 3 — Capstones (Weeks 21–28)

**Goal:** One deployable, GitHub-showcaseable capstone per track.

| Track | Capstone | Stack | Deploy target |
|-------|---------|-------|--------------|
| AI Engineer | ML model serving API — fine-tuned classifier served via FastAPI | PyTorch + FastAPI + Docker | Render / Railway |
| Software Engineer | Full-stack task management app | Next.js + Node.js + PostgreSQL | Vercel + Railway |
| Data Engineer | End-to-end data platform: ETL → warehouse → dbt → dashboard | Airflow + dbt + PostgreSQL | Docker on VPS |
| AI Agents | Multi-agent research assistant with memory and tools | LangGraph + MCP + RAG + Streamlit | Streamlit Cloud |
| GPU Monitoring | Remote training CLI + monitoring dashboard | PyTorch + nvidia-smi + SSH | Local + remote |
| HPC / Quantum | Hybrid quantum-classical optimization problem | Qiskit + Python + Slurm | IBM Quantum + local HPC |

**Success criteria:**
- Each capstone has a public GitHub repo with a clear README
- Each has a live demo or reproducible demo script
- Each has a written case study (what it does, tech decisions, what I'd do differently)
- All pass CI (lint + tests)

Full detail: [phase-3-capstones.md](phase-3-capstones.md)

---

## Phase 4 — Portfolio & Job Prep (Weeks 29–32)

**Goal:** Convert training artifacts into hiring-ready portfolio.

| Area | Tasks | Hours |
|------|-------|-------|
| Portfolio site | Build or deploy personal site showcasing all capstones | 20 |
| Case studies | Write technical case study for each capstone (blog post format) | 20 |
| Resume | Update CV with all projects, skills, technologies | 8 |
| GitHub profile | Polish profile README, pin capstone repos, write good READMEs | 8 |
| Interview prep | LeetCode medium (2/day), system design (Grokking), behavioral stories | 40 |
| Mock interviews | 2 technical + 1 system design + 1 behavioral per week | 20 |
| Open source | At least 1 meaningful contribution to a Python or JS OSS project | 15 |

**Success criteria:**
- 6 capstone repos, each with live demo + case study
- Resume reviewed by 3 people in target role
- Portfolio site deployed and accessible
- Completed 50+ LeetCode mediums
- Completed 2 full system design mock interviews

---

## Milestone Tracker

| Milestone | Target Week | Status |
|-----------|-------------|--------|
| Repo initialized | Week 0 | ✅ |
| Phase 1 complete | Week 4 | ⏳ |
| All tracks started | Week 5 | ⏳ |
| First module capstone | Week 8 | ⏳ |
| Phase 2 complete | Week 20 | ⏳ |
| First capstone deployed | Week 23 | ⏳ |
| All capstones deployed | Week 28 | ⏳ |
| First job application | Week 30 | ⏳ |
| Offer received | Week 32+ | ⏳ |
