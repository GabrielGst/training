# Training Repository

![CI](https://github.com/YOUR_USERNAME/training/actions/workflows/ci.yml/badge.svg)
![Last Commit](https://img.shields.io/github/last-commit/YOUR_USERNAME/training)
![License](https://img.shields.io/badge/license-MIT-blue)

> A production-grade, project-driven self-training repository targeting **Full-Stack / AI Engineer** employability — from junior baseline to senior readiness across six domains.

---

## Philosophy

This repo is not a collection of tutorials. Every module produces a **deployable artifact**: an API, a pipeline, a working agent, a dashboard feature. Progress is tracked, commits are conventional, and every piece of work is explainable in a portfolio review.

The repo is itself a demonstration of engineering discipline: conventional commits, CI on every PR, typed code, and documented decisions.

---

## Quick Start

```bash
# 1. Clone
git clone https://github.com/YOUR_USERNAME/training.git
cd training

# 2. Bootstrap your local environment (pyenv + nvm + docker + deps)
chmod +x scripts/setup.sh
./scripts/setup.sh

# 3. Start the database stack
docker compose up -d

# 4. Launch the progress dashboard
cd dashboard && npm run dev
# → http://localhost:3000
```

---

## Repository Map

```
training/
├── tracks/          # Six learning tracks — the core of the repo
├── doc/             # All documentation: roadmap, conventions, environment
├── dashboard/       # Next.js progress tracker (also a training project)
├── projects/        # Index of capstone projects
├── scripts/         # Bootstrap and scaffolding scripts
└── .github/         # CI workflows and PR/issue templates
```

---

## Learning Tracks

| Track | Domain | Key Technologies | Capstone |
|-------|--------|-----------------|---------|
| [ai-engineer](tracks/ai-engineer/) | ML / AI | Python, PyTorch, TensorFlow, FastAPI | ML model serving API |
| [software-engineer](tracks/software-engineer/) | Full-Stack | Node.js, Next.js, Docker, GitHub Actions | Full-stack web app |
| [data-engineer](tracks/data-engineer/) | Data | PostgreSQL, dbt, Airflow, Django ORM | Data platform |
| [ai-agents](tracks/ai-agents/) | LLM Agents | LangGraph, CrewAI, MCP, RAG | Multi-agent system |
| [gpu-monitoring](tracks/gpu-monitoring/) | MLOps | CUDA, nvidia-smi, remote SSH | Remote GPU training bridge |
| [hpc-quantum](tracks/hpc-quantum/) | HPC/QC | Slurm, MPI, Qiskit | HPC job + quantum circuit |

---

## How to Use This Repo

### Starting a new module

```bash
./scripts/new-module.sh
# Interactive prompt → creates folder, README, src/, and prints the commit message
```

### Logging progress

Open the dashboard at `http://localhost:3000`, navigate to your track, and:
- Toggle module status (`not started` → `in progress` → `completed`)
- Log hours worked
- Add notes

### Making commits

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Adding a training module
git commit -m "track(ai-engineer): scaffold module 02 - fastapi"

# New feature in the dashboard
git commit -m "feat(dashboard): add streak counter to overview page"

# Docs update
git commit -m "docs(roadmap): update phase-2 milestones"
```

Husky + commitlint enforce this on every commit locally.

---

## Roadmap Overview

| Phase | Duration | Focus |
|-------|----------|-------|
| Phase 1 — Foundations | Weeks 1–4 | Git, Python/JS fundamentals, Docker, shell |
| Phase 2 — Core Tracks | Weeks 5–20 | All 6 tracks in parallel, 1 project/module |
| Phase 3 — Capstones | Weeks 21–28 | One deployable capstone per track |
| Phase 4 — Portfolio | Weeks 29–32 | Polish, deploy, case studies, interview prep |

Full roadmap: [doc/roadmap/ROADMAP.md](doc/roadmap/ROADMAP.md)

---

## Documentation Index

- [Roadmap](doc/roadmap/ROADMAP.md) — phases, milestones, timelines
- [Git workflow](doc/conventions/git-workflow.md) — branches, commits, PR lifecycle
- [Code style](doc/conventions/code-style.md) — Python (ruff/black) and JS (ESLint/Prettier)
- [Local setup](doc/environment/local-setup.md) — pyenv, nvm, Docker, PostgreSQL
- [GPU bridge](doc/environment/gpu-bridge.md) — remote NVIDIA machine over SSH
- [Skill matrix](doc/research/skill-matrix.md) — what the job market actually requires
- [Repo architecture](doc/architecture/repo-architecture.md) — design decisions explained

---

## Contributing / Workflow

This is a personal training repository. PRs are used as a discipline tool even when working solo:
- All work happens on a branch
- PRs are self-reviewed using the PR template
- CI must pass before merge
- No force-push to `main`

See [git-workflow.md](doc/conventions/git-workflow.md) for the full workflow.

