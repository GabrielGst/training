# Master Roadmap

> Target: Full-Stack / AI Engineer employable level (junior → senior) + FDE portfolio (AI + Quantum)
> Estimated total: ~2,082 hours across all tracks and projects
> At 4 h/day, 5 days/week: ~20 months elapsed (tracks run in parallel; real time is ~12–14 months of focused effort)

---

## Architecture

```
Phase 1 — Foundations (weeks 1–4)
│   Non-negotiable baseline: Git, Python, TypeScript, Docker, PostgreSQL, Shell
│
Phase 2 — Core Tracks (weeks 5–20)
│   6 tracks running in parallel, each with Phase 1 + Phase 2 modules
│   Each module anchored to a real deliverable
│
Phase 3 — Capstones (weeks 21–28)
│   One deployable capstone per track
│
FDE / AI Projects (concurrent with Phase 2–3)
│   10 production projects targeting AI engineering roles
│
FDE / Quantum Projects (concurrent with Phase 3+)
│   12 hybrid quantum-AI projects targeting quantum FDE roles
│
Phase 4 — Portfolio & Job Prep (weeks 29–32)
    Convert all artifacts to hiring-ready portfolio
```

Full module catalog: [`doc/roadmap/modules.md`](modules.md)  
Skill matrix: [`doc/research/skill-matrix.md`](../research/skill-matrix.md)  
Project catalog: [`doc/roadmap/projects/`](projects/)  
Skill-project bridge: [`doc/roadmap/bridge.md`](bridge.md)

---

## Phase 1 — Foundations (Weeks 1–4)

**Goal:** Establish the non-negotiable hard floor before diving into domain tracks.

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

Full detail: [phase-1-foundations.md](phase-1-foundations.md)

---

## Phase 2 — Core Tracks (Weeks 5–20)

**Goal:** Work through all six tracks in parallel. Each module = one working deliverable minimum.

### Module schedule by track

| Track | Phase 1 modules | Phase 2 modules | Hours |
|-------|----------------|-----------------|-------|
| AI Engineer | 01-python → 05-pytorch | 06-langchain-rag → 12-mlops-cicd | 214 |
| Software Engineer | 01-shell → 03-nextjs-basics | 04-nextjs-advanced → 07-performance | 142 |
| Data Engineer | 01-postgresql → 03-mysql | 04-airflow → 07-observability | 131 |
| AI Agents | 01-llm-fundamentals → 02-langchain | 03-langgraph → 06-rag-advanced | 128 |
| GPU Monitoring | 01-cuda-setup → 02-nvidia-smi | 03-remote-bridge → 04-training-dashboard | 70 |
| HPC & Quantum | 01-hpc-intro → 02-quantum-intro | — | 70 |

### Parallel track schedule (suggested)

```
Weeks 5–7  : AIE: python-foundations + fastapi
             SWE: shell-scripting + nodejs-fundamentals
             DAT: postgresql deep dive
             AIA: llm-fundamentals
             GPU: cuda-setup

Weeks 8–10 : AIE: data-viz + tensorflow
             SWE: nextjs-basics
             DAT: django-orm
             AIA: langchain
             GPU: nvidia-smi + nvtop

Weeks 11–13: AIE: pytorch fundamentals
             SWE: nextjs-advanced
             DAT: mysql-mariadb
             AIA: langgraph
             GPU: remote-training-bridge

Weeks 14–16: AIE: langchain-rag + vector-databases
             SWE: orchestration
             DAT: data-pipelines-airflow
             AIA: crewai + mcp-tool-use
             HPC: hpc-intro + quantum-intro

Weeks 17–20: AIE: llm-prompt-eng + ml-explainability + time-series + streaming-ml + mlops-cicd
             SWE: testing-deep-dive + performance-optimization
             DAT: dbt-transformations + data-warehouse + observability
             AIA: rag-advanced
             GPU: training-dashboard
```

**Success criteria per module:**
- Working deliverable pushed to this repo
- Module directory has a README.md explaining what was built and learned
- At least one meaningful test
- Code passes lint

Full detail: [phase-2-core-tracks.md](phase-2-core-tracks.md)

---

## Phase 3 — Capstones (Weeks 21–28)

**Goal:** One deployable, GitHub-showcaseable capstone per track.

| Track | Capstone | Stack | Deploy target | Hours |
|-------|---------|-------|--------------|-------|
| AI Engineer | ML model serving API | PyTorch + FastAPI + Docker | Render / Railway | 40 |
| Software Engineer | Full-stack task management app | Next.js + Node.js + PostgreSQL | Vercel + Railway | 50 |
| Data Engineer | End-to-end data platform | Airflow + dbt + PostgreSQL + Looker | Docker on VPS | 45 |
| AI Agents | Multi-agent research assistant | LangGraph + MCP + RAG + Streamlit | Streamlit Cloud | 50 |
| GPU Monitoring | Remote training CLI + dashboard | PyTorch + nvidia-smi + SSH | Local + remote | 30 |
| HPC / Quantum | Hybrid quantum-classical optimization | Qiskit + Python + Slurm | IBM Quantum + local HPC | 40 |

Full detail: [phase-3-capstones.md](phase-3-capstones.md)

---

## FDE / AI Projects (Concurrent with Phase 2–3)

**Goal:** 10 production AI projects targeting FDE roles at AI-native companies.  
**Prerequisite:** Phase 1 complete + relevant track modules.

| Phase | Projects | Hours |
|-------|---------|-------|
| Foundation (P01–P02, P05) | VC Analyst, Customer Support, Sales GTM | 175 |
| Vertical (P03–P04, P06–P07) | Fraud Detection, Supply Chain, AI Copilot, Field Service | 245 |
| Regulated (P08–P10) | Healthcare, Marketing Attribution, Cinema Pricing | 180 |

Full project specs: [projects/ai-projects.md](projects/ai-projects.md)  
Skill-project mapping: [bridge.md](bridge.md)

---

## FDE / Quantum Projects (Phase 3+)

**Goal:** 12 hybrid quantum-AI projects targeting Pasqal, IonQ, D-Wave, and IBM Quantum FDE roles.  
**Prerequisite:** `hpc-quantum/02-quantum-intro` complete.

| Phase | Projects | Modality | Hours |
|-------|---------|----------|-------|
| Theory bootcamp | q-theory-01 → q-theory-06 | — | 52 |
| 2A: Superconducting | QP01, QP06, QP08, QP10 | IBM/Qiskit | 320 |
| 2B: Neutral-atom | QP02 | Pasqal/Pulser | 90 |
| 2C: Photonic | QP03, QP09 | Perceval | 160 |
| 2D: Trapped-ion | QP04 | IonQ/TKET | 90 |
| 2E: Annealing | QP05, QP11 | D-Wave | 150 |
| 2F: Post-quantum crypto | QP07 | liboqs | 75 |
| Phase 3 capstone | QP12 | Multi-modality | 80 |

Full project specs: [projects/quantum-projects.md](projects/quantum-projects.md)

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

---

## Milestone Tracker

| Milestone | Target Week | Status |
|-----------|-------------|--------|
| Repo initialized | Week 0 | ✅ |
| Skill matrix + module catalog complete | Week 0 | ✅ |
| Phase 1 complete | Week 4 | ⏳ |
| All tracks started | Week 5 | ⏳ |
| First module deliverable | Week 8 | ⏳ |
| Phase 2 complete | Week 20 | ⏳ |
| First FDE AI project complete | Week 22 | ⏳ |
| First capstone deployed | Week 23 | ⏳ |
| All capstones deployed | Week 28 | ⏳ |
| First FDE Quantum project complete | Week 30 | ⏳ |
| First job application | Week 30 | ⏳ |
| Offer received | Week 32+ | ⏳ |

---

## Hour Summary

| Track / Thread | Total Hours |
|----------------|-------------|
| AI Engineer | 214 |
| Software Engineer | 142 |
| Data Engineer | 131 |
| AI Agents | 128 |
| GPU Monitoring | 70 |
| HPC & Quantum (general) | 70 |
| FDE / AI (10 projects) | 535 |
| FDE / Quantum (12 projects) | 792 |
| **Grand total** | **~2,082** |

At 4 h/day, 5 days/week: ~20 months. At 6 h/day: ~13 months. Tracks run in parallel so real elapsed time is shorter.
