# Changelog

All notable changes to this repository are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versions follow [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Added
- **Skill matrix v2** (`doc/research/skill-matrix.md`): complete overhaul covering all 31 AI/FDE skills, 52 AI tools, 74 quantum skills, and 41 quantum tools from structured CSVs; includes priority tiers (P1/P2/P3), theory/engineering type, project coverage, and candidate gap flags
- **Project catalog** (`doc/roadmap/projects/`): full specs for 10 AI/FDE projects (P01–P10) and 12 quantum projects (QP01–QP12) derived from CSV sources, each with business problem, solution architecture, tech stack, and portfolio value
- **Skill-project bridge** (`doc/roadmap/bridge.md`): cross-reference map of skills ↔ tools ↔ projects for both AI and quantum tracks; includes cross-track overlap table
- **Module catalog** (`doc/roadmap/modules.md`): MECE module definitions across all tracks with slugs, hour targets, skill/tool tags, anchor projects, deliverables, and dependency graph; ~2,082 total hours
- **Two new FDE tracks** in `progress.json`: `fde-ai` (10 projects) and `fde-quantum` (18 modules); total 72 modules tracked
- **New module directories** scaffolded across all tracks: 19 new module stubs added (ai-engineer expanded to 13 modules, data-engineer to 8, software-engineer to 8, ai-agents to 7, gpu-monitoring to 5)
- **Agent slash commands**: `/doc-chores` and `/repo-chores` for automated documentation consistency checks and repository health maintenance
- **ROADMAP.md updated**: includes FDE/AI and FDE/Quantum project threads, revised hour estimates, and expanded milestone tracker

### Changed
- All six track READMEs updated with new module tables (hours column, anchor project column, FDE project references, skill ID cross-references)
- `progress.json` expanded from 27 to 72 tracked modules across 8 tracks

### Initial scaffold (prior entries)
- Initial repository scaffold with full directory structure
- Six learning tracks: ai-engineer, software-engineer, data-engineer, ai-agents, gpu-monitoring, hpc-quantum
- Next.js 14 progress dashboard (App Router, TypeScript, Tailwind CSS)
- Skill matrix v1 synthesized from Stack Overflow 2025 survey and job posting analysis
- Conventional commits enforcement via commitlint + husky
- CI pipeline: Python linting (ruff), Node linting (eslint), pytest, commitlint
- Docker Compose stack: PostgreSQL 16 + pgAdmin 4
- Bootstrap script `scripts/setup.sh` for one-command environment setup
- Module scaffolding script `scripts/new-module.sh`
- GitHub PR template with self-review checklist
- Full documentation: roadmap, conventions, environment guides, GPU bridge setup

---

<!-- Add entries here as work progresses. Use git log --oneline for reference. -->
