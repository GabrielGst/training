# Training Module Structure

## Every module must have

```
tracks/<track>/<number>-<name>/
├── README.md          # Required — see template below
├── src/               # All source code
└── tests/             # All tests (pytest or jest/vitest)
```

### Optional by track type

```
# Python tracks
├── requirements.txt   # Module-specific deps (not root deps)
├── pyproject.toml     # If the module is a proper Python package
└── Makefile           # Convenience commands: make test, make lint

# JS/TS tracks (plain Node / non-Next.js)
├── package.json       # Module-specific deps
├── tsconfig.json      # Extends root tsconfig
└── .eslintrc.json     # Extends root eslint config

# Next.js projects (ALL Next.js modules and capstones must use src/app/)
├── package.json
├── tsconfig.json      # paths: { "@/*": ["./src/*"] }
├── next.config.ts
├── tailwind.config.ts # content: ["./src/**/*.{ts,tsx}"]
└── src/
    ├── app/           # App Router — all pages, layouts, loading, error files
    │   ├── layout.tsx
    │   ├── page.tsx
    │   └── globals.css
    ├── components/    # Shared UI components
    ├── lib/           # Utilities, data access, server actions
    └── types/         # TypeScript type definitions

# Data tracks
└── sql/               # SQL scripts and migrations

# Agent tracks
├── prompts/           # Prompt templates (markdown)
└── evals/             # Evaluation scripts/datasets
```

---

## README.md Template for Modules

```markdown
# Module <number>: <Name>

**Track:** <track name>
**Status:** not started | in progress | completed
**Hours logged:** 0

## Objective

One sentence: what skill does this module build?

## What I built

<!-- Fill in after completing the module -->
Describe the project: what it does, how to run it.

## Key learnings

<!-- Fill in after completing the module -->
- Insight 1
- Insight 2
- Insight 3

## How this maps to job requirements

<!-- Reference skill-matrix.md -->
This module covers: [Skill Name](../../../doc/research/skill-matrix.md#domain) — rated **High** frequency in job postings.

## Setup

```bash
# Install dependencies
pip install -r requirements.txt
# or
npm install

# Run
python src/main.py
# or
npm run dev
```

## Tests

```bash
pytest tests/ -v
# or
npm test
```

## Resources used

1. [Resource name](URL) — what I used it for
2. [Resource name](URL)
3. [Resource name](URL)
```

---

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Module folder | `<two-digit-number>-<kebab-name>` | `03-data-viz-seaborn-plotly` |
| Source files (Python) | `snake_case.py` | `data_processor.py` |
| Source files (TS) | `kebab-case.ts` | `data-processor.ts` |
| Test files (Python) | `test_<name>.py` | `test_data_processor.py` |
| Test files (TS) | `<name>.test.ts` | `data-processor.test.ts` |
| Classes | `PascalCase` | `DataProcessor` |
| Functions / variables | `snake_case` (Python) / `camelCase` (TS) | |
| Constants | `UPPER_SNAKE_CASE` | `MAX_BATCH_SIZE` |
| Environment variables | `UPPER_SNAKE_CASE` | `DATABASE_URL` |

---

## Capstone Project Structure

Capstones live in `tracks/<track>/06-capstone-*/` and follow the module structure plus:

```
06-capstone-<name>/
├── README.md          # Full project README (as if it were a public repo)
├── CASE_STUDY.md      # Technical case study for portfolio
├── src/               # Application source
├── tests/             # Full test suite
├── docker-compose.yml # If the project has infrastructure
├── Dockerfile         # If containerized
├── .env.example       # Required env vars documented
└── scripts/           # Any helper scripts
```

The capstone README must include:
- What it does (1-paragraph summary)
- Architecture diagram (ASCII or Mermaid)
- Setup instructions (from scratch to running)
- API documentation (if applicable)
- Performance benchmarks (if applicable)
- Known limitations and future improvements
