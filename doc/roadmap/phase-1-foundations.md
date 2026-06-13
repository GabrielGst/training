# Phase 1 — Foundations (Weeks 1–4)

## Objectives

Establish the non-negotiable baseline that every subsequent track depends on. Phase 1 is non-negotiable — do not start track modules until these are solid.

---

## Week 1: Git + Python

### Git (8 hours)

**Topics:**
- Conventional commits: all 10 types used in this repo
- Branching: `feat/`, `fix/`, `docs/`, `chore/`, `track/` naming
- Interactive rebase (`git rebase -i`) for squash and fixup
- Conflict resolution workflow
- PR-based workflow even when working solo

**Deliverable:** Personalized Git cheat sheet saved in `doc/conventions/git-workflow.md` (update with any personal additions)

### Python Fluency (20 hours)

**Topics:**
- Type hints (`typing`, `dataclasses`, `Protocol`)
- OOP: composition over inheritance
- Packaging: `pyproject.toml`, virtual envs, pyenv
- Error handling: custom exceptions, context managers
- Testing: pytest fixtures, parametrize, coverage
- Linting: ruff + black workflow

**Deliverable:** A typed Python mini-library (e.g., a simple CLI tool or data validator) with 100% test coverage and passing ruff.

---

## Week 2: JavaScript / TypeScript + Shell

### TypeScript (20 hours)

**Topics:**
- ES6+ recap: destructuring, spread, optional chaining
- TypeScript strict mode: all flags enabled
- Generics, utility types (`Partial`, `Readonly`, `Record`, `Pick`)
- Module system: ESM vs CJS
- Async patterns: Promises, async/await, error boundaries

**Deliverable:** 10 TypeScript kata exercises, each covering a different type challenge.

### Shell Scripting (10 hours)

**Topics:**
- Bash syntax: variables, conditionals, loops, functions
- Pipes, redirections, process substitution
- Error handling: `set -euo pipefail`, traps
- Script structure: idempotency, help text, color output
- Cron syntax (reference only — use GitHub Actions for automation)

**Deliverable:** `scripts/setup.sh` — the repo bootstrap script.

---

## Week 3: Docker + PostgreSQL

### Docker Fundamentals (10 hours)

**Topics:**
- Dockerfile layers and caching
- Multi-stage builds for Python and Node
- Docker Compose: services, volumes, networks, health checks
- Environment variables: `.env` files and override patterns
- GPU passthrough with NVIDIA Container Toolkit (reference)

**Deliverable:** Docker Compose stack running (postgres + pgadmin verified). Document in `doc/environment/local-setup.md`.

### PostgreSQL Basics (12 hours)

**Topics:**
- DDL: CREATE TABLE, constraints, data types
- DML: INSERT, UPDATE, DELETE, UPSERT (ON CONFLICT)
- Queries: JOINs (inner, left, cross), GROUP BY, HAVING
- Indexes: B-tree, when to index, EXPLAIN ANALYZE
- Transactions: ACID, isolation levels, rollback
- psql CLI: `\d`, `\dt`, `\l`, `\copy`, meta-commands

**Deliverable:** A schema for a real dataset (e.g., movie database, product catalog) with proper constraints and indexes. Practice at pgexercises.com.

---

## Week 4: Integration + Review

- Integrate all Phase 1 skills: build a Python script that reads from PostgreSQL, exposes results via a simple HTTP endpoint (raw HTTP — no FastAPI yet), and runs via Docker Compose.
- Review and finalize all conventions docs
- Verify CI passes on a test PR
- Set up the dashboard and log first entries

**Deliverable:** "Phase 1 integration project" — a working Python + PostgreSQL + Docker mini-app.

---

## Success Gate

Do not proceed to Phase 2 until:

- [ ] Can write and explain a Git interactive rebase
- [ ] Python project passes `ruff check`, `ruff format --check`, and `pytest --cov` at > 80%
- [ ] Can explain TypeScript's type system to someone without a TS background
- [ ] Docker Compose stack runs from scratch on a clean machine
- [ ] Can write a `SELECT` with window functions without looking at docs
- [ ] Phase 1 integration project is pushed and CI passes
