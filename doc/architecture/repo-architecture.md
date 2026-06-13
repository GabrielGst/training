# Repository Architecture — Design Decisions

> This document explains every major structural decision in this repository. It is written to be defensible in a senior engineering portfolio review.

---

## Why a monorepo?

All six tracks live in a single repository rather than six separate repos. Reasons:

1. **Cross-track dependency visibility** — the AI agents track depends on FastAPI knowledge (AI engineer track) and PostgreSQL knowledge (data engineer track). A monorepo makes these dependencies explicit and searchable.
2. **Single source of truth for conventions** — one `.editorconfig`, one commitlint config, one CI workflow definition. Convention drift across repos is a real maintenance burden.
3. **Unified progress tracking** — the dashboard reads `progress.json` which covers all tracks. This would be harder across repos.
4. **Portfolio coherence** — a single GitHub repo with a rich history tells a cleaner story than six sparse repos.

**Trade-off accepted:** The repo grows large over time. Mitigation: `.gitignore` excludes all build artifacts, model checkpoints, and dataset files. The repo stays code-and-docs only.

---

## Why `tracks/` not `src/`?

The naming signals intent: this is a learning environment, not a production codebase. Each track is a domain (`ai-engineer`, `data-engineer`, etc.) and each module is a numbered progression. This structure:

- Enforces forward-only progression (you cannot "refactor" module 01 into module 03 — they're separate projects)
- Mirrors how job descriptions and skill matrices are organized (domain → skill → level)
- Makes GitHub browsing intuitive for a portfolio viewer

---

## Why numbered modules (`01-`, `02-`)?

Lexicographic ordering matters in a filesystem. Numbers guarantee the display order matches learning progression. Two-digit padding (`01` not `1`) ensures correct sort order past 9.

---

## Why a Next.js dashboard instead of a spreadsheet?

1. **The dashboard is a training project itself.** Building it is the `software-engineer` track capstone. It demonstrates Next.js App Router, TypeScript, Tailwind, and data management.
2. **It lives where the work happens.** A spreadsheet is a context switch. The dashboard is at `localhost:3000` — same environment as the training work.
3. **It demonstrates the "eat your own dog food" principle.** Using your own software in production (even personal production) reveals product gaps that motivate real improvements.

---

## Why JSON for dashboard persistence (not a database)?

**Starting with `progress.json`:**
- Zero infrastructure — works on a fresh machine with just Node installed
- No migration risk — easy to edit by hand if the dashboard breaks
- Version controllable — git history of `progress.json` is a log of learning progress

**Why it's designed to be swappable for PostgreSQL:**
- The data access layer in the dashboard is isolated in `dashboard/lib/data.ts`
- All components receive typed data via that layer — they don't know the source
- The PostgreSQL migration path is documented in `dashboard/README.md`

This is a deliberate architectural pattern: start simple, design for extensibility, document the migration.

---

## Why conventional commits enforced by husky?

Husky runs `commitlint` on every `git commit`. This is not optional. Reasons:

1. **CI enforces it too** — the `commitlint` CI job runs on every PR. Local enforcement means fewer PR failures.
2. **Commit messages are a searchable log** — `git log --grep="track(ai-engineer)"` finds all AI engineer module commits instantly.
3. **It's a real industry skill** — every production team with any commit discipline uses conventional commits. Practicing it here means it's automatic by the time you're in a team.
4. **Semantic versioning** — the CHANGELOG can be auto-generated from conventional commit messages if desired.

The custom `track` type (not in the conventional commits standard) is intentional. It makes training module commits distinguishable from infrastructure changes. `track(ai-engineer): complete pytorch basics` is semantically different from `feat(ai-engineer): add FastAPI endpoint`.

---

## Why a custom `scripts/new-module.sh` scaffolding script?

The scaffolding script exists because:
1. **Consistency** — every module has the same structure (README, src/, tests/, .gitkeep). Manual creation introduces drift.
2. **Commit message generation** — the script prints the exact conventional commit message. Zero thinking required at the command line.
3. **It's a training project** — writing the script exercises Bash skills from `tracks/software-engineer/01-shell-scripting/`.

---

## Why GitHub Actions over alternatives (GitLab CI, CircleCI, Jenkins)?

1. **Zero infrastructure** — no server to run, no accounts to manage beyond GitHub
2. **Industry prevalence** — GitHub Actions appears in more job descriptions than any other CI system for small-to-mid teams
3. **First-class marketplace** — `actions/checkout`, `actions/setup-python`, `actions/setup-node` are maintained by GitHub and reliable
4. **Free for public repos** — this training repo will be public, so CI is free

---

## Why PostgreSQL 16 specifically?

1. **Most common in job descriptions** for data engineering and full-stack roles
2. **PostgreSQL 16 features** used in training: logical replication improvements, better partition pruning, pg_stat_io
3. **Alpine image** (`postgres:16-alpine`) keeps the Docker image small (~80MB vs ~400MB for the standard image)
4. **pgAdmin 4** is included in Compose for visual exploration — essential for learning SQL schema design

---

## Why pyenv for Python, nvm for Node?

Both tools solve the same problem: multiple projects requiring different runtime versions. Alternatives:

- **Python**: conda, venv alone, asdf — pyenv is the most widely documented, works well on Ubuntu, and integrates with `direnv` for automatic version switching
- **Node**: Volta, fnm, asdf — nvm has the largest user base and most documentation. fnm is faster but nvm's behavior is better documented for troubleshooting

Pinning to `.python-version` and `.nvmrc` files makes the versions project-local and explicit. Any tool that reads these files (including `scripts/setup.sh`) will install the correct version.

---

## Why ruff over flake8 + isort + pylint?

Ruff replaces flake8, isort, pyupgrade, and partial pylint functionality in a single Rust-based tool that runs 10–100x faster. It has become the de facto Python linting standard in new projects as of 2024–2025 (used by FastAPI, Pydantic, Astral, and others). There is no meaningful reason to use the older toolchain for new projects.

---

## Future Scale Considerations

This structure accommodates:
- **New tracks** — add `tracks/<new-track>/` with its own README and numbered modules
- **New modules** — run `scripts/new-module.sh` — one command
- **Database migration** — replace `dashboard/data/progress.json` reads with PostgreSQL queries in `dashboard/lib/data.ts`
- **Multi-user** — add auth to the dashboard and move data to PostgreSQL (migration path documented in `dashboard/README.md`)
- **Team use** — the conventions, CI, and PR workflow already support a team. Add CODEOWNERS and branch protection rules.
