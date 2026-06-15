#!/usr/bin/env bash
# scripts/new-project.sh — scaffold one or all FDE project directories under projects/
#
# Usage:
#   ./scripts/new-project.sh              # interactive: pick one project
#   ./scripts/new-project.sh --all        # batch: scaffold all 22 projects
#   ./scripts/new-project.sh --id P01     # scaffold AI project P01
#   ./scripts/new-project.sh --id QP03    # scaffold Quantum project QP03

set -euo pipefail

# ── Color helpers ──────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[OK]${RESET}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $*"; }
prompt()  { echo -e "${BOLD}$*${RESET}"; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECTS_DIR="${REPO_ROOT}/projects"
RESOURCES_DIR="${REPO_ROOT}/doc/roadmap/resources"

# ── Require Python 3 ──────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
  echo "python3 is required but not found. Exiting." && exit 1
fi

# ── Parse args ────────────────────────────────────────────────────────────────
MODE="interactive"
TARGET_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)   MODE="all";  shift ;;
    --id)    MODE="single"; TARGET_ID="${2:-}"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--all | --id <P01|QP03>]"
      exit 0 ;;
    *) echo "Unknown argument: $1" && exit 1 ;;
  esac
done

# ── Load project metadata via Python ──────────────────────────────────────────
# Outputs one line per project: ID|slug|name|track|type|tech_stack|skills|tools|problem_short|portfolio
PROJECTS_DATA=$(python3 - "${RESOURCES_DIR}" << 'PYEOF'
import csv, sys, re

base = sys.argv[1] if len(sys.argv) > 1 else '.'

# Tech stack → module type heuristic
def infer_type(stack):
    stack_lower = stack.lower()
    has_py = any(t in stack_lower for t in ['fastapi','flask','pytorch','python','airflow','dbt','django','sklearn','xgboost','langchain','whisper','spacy'])
    has_js = any(t in stack_lower for t in ['next.js','react','express','node','typescript'])
    if has_py and has_js:
        return 'both'
    elif has_js:
        return 'js'
    elif has_py:
        return 'python'
    return 'python'

def slugify(s):
    s = s.lower()
    s = re.sub(r'[^a-z0-9\s-]', '', s)
    s = re.sub(r'[\s]+', '-', s.strip())
    s = re.sub(r'-+', '-', s)
    return s[:50]

def short(s, n=120):
    return s.replace('\n',' ').strip()[:n]

# AI projects
with open(f'{base}/fde_ai_projects.csv') as f:
    for row in csv.DictReader(f):
        pid  = row['project_id']
        name = row['project_name']
        slug = slugify(name)
        track = 'fde-ai'
        mtype = infer_type(row['tech_stack_high_level'])
        tech  = short(row['tech_stack_high_level'], 120)
        skills= row['skill_stack_ids'].replace(' ','')
        tools = row['tool_stack_ids'].replace(' ','')
        prob  = short(row['business_problem'], 200)
        port  = short(row['portfolio_fit_notes'], 200)
        print(f"{pid}|{slug}|{name}|{track}|{mtype}|{tech}|{skills}|{tools}|{prob}|{port}")

# Quantum projects
with open(f'{base}/fde_quantum_projects.csv') as f:
    for i, row in enumerate(csv.DictReader(f), 1):
        pid  = f'QP{i:02d}'
        name = row['project_name']
        slug = slugify(name)
        track = 'fde-quantum'
        mtype = 'python'  # all quantum projects are Python-based
        tech  = short(row['tech_stack_high_level'], 120)
        skills= row['skill_stack_ids'].replace(' ','')
        tools = row['tool_stack_ids'].replace(' ','')
        prob  = short(row['business_problem'], 200)
        port  = short(row['portfolio_fit_notes'], 200)
        print(f"{pid}|{slug}|{name}|{track}|{mtype}|{tech}|{skills}|{tools}|{prob}|{port}")
PYEOF
)

# ── Project picker for interactive mode ───────────────────────────────────────
if [ "${MODE}" == "interactive" ]; then
  echo ""
  prompt "Available projects:"
  echo ""
  IFS=$'\n' read -r -d '' -a LINES <<< "${PROJECTS_DATA}" || true
  for i in "${!LINES[@]}"; do
    IFS='|' read -r pid slug name track _ <<< "${LINES[$i]}"
    printf "  %3s. [%-12s] %s\n" "$((i+1))" "${pid}" "${name}"
  done
  echo ""
  read -rp "Project ID or number (e.g. P01 or QP03): " INPUT
  echo ""

  if [[ "${INPUT}" =~ ^[0-9]+$ ]]; then
    IDX=$((INPUT - 1))
    TARGET_ID=$(echo "${LINES[$IDX]}" | cut -d'|' -f1)
  else
    TARGET_ID="${INPUT}"
  fi
  MODE="single"
fi

# ── Scaffold function ─────────────────────────────────────────────────────────
scaffold_project() {
  local pid="$1" slug="$2" name="$3" track="$4" mtype="$5"
  local tech="$6" skills="$7" tools="$8" prob="$9" port="${10}"

  local proj_dir="${PROJECTS_DIR}/${track}/${pid,,}-${slug}"

  if [ -d "${proj_dir}" ] && [ -f "${proj_dir}/README.md" ]; then
    warn "Already exists, skipping: ${proj_dir##"${REPO_ROOT}/"}"
    return 0
  fi

  info "Scaffolding ${pid}: ${name}"
  mkdir -p "${proj_dir}/src" "${proj_dir}/tests" "${proj_dir}/docs"

  # ── README.md ──────────────────────────────────────────────────────────────
  cat > "${proj_dir}/README.md" << EOF
# ${pid} — ${name}

**Track:** \`${track}\`
**Status:** not started
**Hours logged:** 0

## Business Problem

${prob}

## Solution Architecture

<!-- Fill in as you build -->

## Tech Stack

\`${tech}\`

## Skills Required

<!-- From skill-matrix.md: ${skills} -->

## Tools

<!-- From bridge.md: ${tools} -->

## Portfolio Value

${port}

---

## Setup

\`\`\`bash
EOF

  if [[ "${mtype}" == "python" ]] || [[ "${mtype}" == "both" ]]; then
    cat >> "${proj_dir}/README.md" << 'EOF'
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # fill in API keys
EOF
  fi

  if [[ "${mtype}" == "js" ]] || [[ "${mtype}" == "both" ]]; then
    cat >> "${proj_dir}/README.md" << 'EOF'
npm install
cp .env.example .env   # fill in API keys
npm run dev
EOF
  fi

  cat >> "${proj_dir}/README.md" << 'EOF'
```

## Run

```bash
# TODO: fill in once implemented
```

## Tests

```bash
EOF

  if [[ "${mtype}" == "python" ]] || [[ "${mtype}" == "both" ]]; then
    cat >> "${proj_dir}/README.md" << 'EOF'
pytest tests/ -v
EOF
  fi

  if [[ "${mtype}" == "js" ]] || [[ "${mtype}" == "both" ]]; then
    cat >> "${proj_dir}/README.md" << 'EOF'
npm test
EOF
  fi

  cat >> "${proj_dir}/README.md" << 'EOF'
```

## Architecture

See [`docs/architecture.md`](docs/architecture.md).

## Case Study

See [`CASE_STUDY.md`](CASE_STUDY.md) once the project is complete.

## Resources

1. [Resource name](URL) — description
2. [Resource name](URL)

## Skill coverage

Full spec: [`doc/roadmap/projects/`](../../../doc/roadmap/projects/)
EOF

  # ── CASE_STUDY.md ──────────────────────────────────────────────────────────
  cat > "${proj_dir}/CASE_STUDY.md" << EOF
# Case Study: ${name}

> Fill in after completing the project.

## Problem statement

<!-- What business problem did you solve? Who is the user? What was the pain? -->

## Solution

<!-- What did you build? How does it work? -->

## Key decisions

<!-- 3-5 architectural or implementation choices and why you made them -->

1.
2.
3.

## What I learned

<!-- Specific technical skills, patterns, or insights gained -->

-
-
-

## What I'd do differently

<!-- Honest retrospective — what would change if you rebuilt it? -->

-
-

## Results / metrics

<!-- Any measurable impact: latency, accuracy, cost savings, user feedback -->

## Demo

<!-- Link to live demo, Loom video, or reproducible demo script -->
EOF

  # ── .env.example ───────────────────────────────────────────────────────────
  cat > "${proj_dir}/.env.example" << 'EOF'
# Copy to .env and fill in values. Never commit .env.

# LLM API
MISTRAL_API_KEY=
ANTHROPIC_API_KEY=
OPENAI_API_KEY=

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# Cloud storage
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_S3_BUCKET=

# Vector DB
QDRANT_URL=http://localhost:6333
PINECONE_API_KEY=
PINECONE_ENV=

# Other
LOG_LEVEL=INFO
EOF

  # ── docs/architecture.md ───────────────────────────────────────────────────
  cat > "${proj_dir}/docs/architecture.md" << EOF
# Architecture: ${name}

## System diagram

<!-- Add diagram here (Mermaid, draw.io export, or ASCII) -->

\`\`\`
[source] → [ingestion] → [transform] → [storage] → [API] → [frontend]
\`\`\`

## Components

| Component | Technology | Responsibility |
|-----------|-----------|----------------|
| | | |

## Data flow

1.
2.
3.

## Infrastructure

<!-- Deployment target, cloud services, container orchestration -->

## Sequence diagram

<!-- Optional: add for complex flows -->
EOF

  # ── Language-specific project files ────────────────────────────────────────
  if [[ "${mtype}" == "python" ]] || [[ "${mtype}" == "both" ]]; then
    cat > "${proj_dir}/requirements.txt" << EOF
# ${name}
# Add project dependencies below.
# Keep pinned versions once working: package==x.y.z

EOF

    cat > "${proj_dir}/src/__init__.py" << 'EOF'
EOF
    rm -f "${proj_dir}/src/.gitkeep"

    cat > "${proj_dir}/tests/__init__.py" << 'EOF'
EOF
    cat > "${proj_dir}/tests/test_placeholder.py" << EOF
"""Placeholder test — replace with real tests as you build ${name}."""


def test_placeholder():
    """Remove this once real tests exist."""
    assert True
EOF
    rm -f "${proj_dir}/tests/.gitkeep"
  fi

  if [[ "${mtype}" == "js" ]] || [[ "${mtype}" == "both" ]]; then
    local pkg_name
    pkg_name=$(echo "${pid,,}-${slug}" | tr '/' '-')
    cat > "${proj_dir}/package.json" << EOF
{
  "name": "${pkg_name}",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "node src/index.js",
    "build": "echo 'TODO'",
    "test": "vitest"
  },
  "devDependencies": {
    "vitest": "^2.1.8"
  }
}
EOF
  fi

  # ── .gitignore ─────────────────────────────────────────────────────────────
  cat > "${proj_dir}/.gitignore" << 'EOF'
.env
.venv/
__pycache__/
*.pyc
*.egg-info/
dist/
node_modules/
.next/
*.log
*.db
EOF

  success "Created ${proj_dir##"${REPO_ROOT}/"}"
}

# ── Dispatch ──────────────────────────────────────────────────────────────────
COUNT=0

while IFS='|' read -r pid slug name track mtype tech skills tools prob port; do
  if [ "${MODE}" == "all" ] || [ "${pid}" == "${TARGET_ID}" ]; then
    scaffold_project "${pid}" "${slug}" "${name}" "${track}" "${mtype}" \
                     "${tech}" "${skills}" "${tools}" "${prob}" "${port}"
    COUNT=$((COUNT + 1))
  fi
done <<< "${PROJECTS_DATA}"

if [ "${COUNT}" -eq 0 ]; then
  warn "No project matched '${TARGET_ID}'. Run with --all to list or scaffold all projects."
  exit 1
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Done — ${COUNT} project(s) scaffolded.${RESET}"
echo ""

if [ "${MODE}" != "all" ] && [ "${COUNT}" -eq 1 ]; then
  echo -e "${BOLD}Suggested first commit:${RESET}"
  IFS='|' read -r pid slug name track _ <<< "$(grep "^${TARGET_ID}|" <<< "${PROJECTS_DATA}" | head -1)"
  echo ""
  echo "  git add projects/${track}/${pid,,}-${slug}/"
  echo "  git commit -m \"feat(projects): scaffold ${pid} - ${slug}\""
  echo ""
fi

echo -e "${BOLD}Next steps:${RESET}"
echo "  1. Open the project README and read the business problem"
echo "  2. Fill in docs/architecture.md with your system design"
echo "  3. Add dependencies to requirements.txt (or package.json)"
echo "  4. Start building in src/"
echo ""
