#!/usr/bin/env bash
# scripts/new-module.sh — interactive scaffolding for a new training module
# Usage: ./scripts/new-module.sh

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
TRACKS_DIR="${REPO_ROOT}/tracks"

# ── Valid tracks ───────────────────────────────────────────────────────────────
VALID_TRACKS=("ai-engineer" "software-engineer" "data-engineer" "ai-agents" "gpu-monitoring" "hpc-quantum")

# ── Prompt for track ───────────────────────────────────────────────────────────
echo ""
prompt "Available tracks:"
for i in "${!VALID_TRACKS[@]}"; do
  echo "  $((i+1)). ${VALID_TRACKS[$i]}"
done
echo ""
read -rp "Track name (or number): " TRACK_INPUT

# Accept number or name
if [[ "${TRACK_INPUT}" =~ ^[0-9]+$ ]]; then
  IDX=$((TRACK_INPUT - 1))
  if [ "${IDX}" -lt 0 ] || [ "${IDX}" -ge "${#VALID_TRACKS[@]}" ]; then
    echo "Invalid track number. Exiting." && exit 1
  fi
  TRACK="${VALID_TRACKS[$IDX]}"
else
  TRACK="${TRACK_INPUT}"
  if [[ ! " ${VALID_TRACKS[*]} " =~ " ${TRACK} " ]]; then
    warn "Track '${TRACK}' is not in the standard list but will be created anyway."
  fi
fi

# ── Prompt for module number ───────────────────────────────────────────────────
read -rp "Module number (e.g. 07): " MODULE_NUM

# Pad to two digits
MODULE_NUM=$(printf "%02d" "${MODULE_NUM#0}" 2>/dev/null || echo "${MODULE_NUM}")

# ── Prompt for module name ─────────────────────────────────────────────────────
read -rp "Module name (kebab-case, e.g. model-optimization): " MODULE_NAME_RAW

# Normalize to kebab-case
MODULE_NAME=$(echo "${MODULE_NAME_RAW}" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | sed 's/[^a-z0-9-]//g')

MODULE_DIR="${TRACKS_DIR}/${TRACK}/${MODULE_NUM}-${MODULE_NAME}"

if [ -d "${MODULE_DIR}" ]; then
  warn "Directory already exists: ${MODULE_DIR}"
  read -rp "Continue and overwrite? [y/N]: " OVERWRITE
  [[ "${OVERWRITE}" =~ ^[Yy]$ ]] || exit 0
fi

# ── Prompt for type ────────────────────────────────────────────────────────────
echo ""
prompt "Module type:"
echo "  1. python  — creates requirements.txt"
echo "  2. js      — creates package.json"
echo "  3. both    — creates both"
echo "  4. none    — source files only"
read -rp "Type [1-4]: " TYPE_INPUT

case "${TYPE_INPUT}" in
  1|python) MODULE_TYPE="python" ;;
  2|js)     MODULE_TYPE="js" ;;
  3|both)   MODULE_TYPE="both" ;;
  4|none)   MODULE_TYPE="none" ;;
  *)        MODULE_TYPE="none" ;;
esac

# ── Human-readable name ────────────────────────────────────────────────────────
MODULE_DISPLAY=$(echo "${MODULE_NAME}" | tr '-' ' ' | sed 's/\b\(.\)/\u\1/g')

# ── Create directory structure ─────────────────────────────────────────────────
echo ""
info "Creating module: tracks/${TRACK}/${MODULE_NUM}-${MODULE_NAME}/"

mkdir -p "${MODULE_DIR}/src"
mkdir -p "${MODULE_DIR}/tests"

# README.md
cat > "${MODULE_DIR}/README.md" << EOF
# Module ${MODULE_NUM}: ${MODULE_DISPLAY}

**Track:** ${TRACK}
**Status:** not started
**Hours logged:** 0

## Objective

<!-- One sentence: what skill does this module build? -->

## What I built

<!-- Fill in after completing the module -->

## Key learnings

<!-- Fill in after completing the module -->
-
-
-

## How this maps to job requirements

<!-- Reference skill-matrix.md -->
This module covers skills from [doc/research/skill-matrix.md](../../../doc/research/skill-matrix.md).

## Setup

\`\`\`bash
EOF

if [[ "${MODULE_TYPE}" == "python" ]] || [[ "${MODULE_TYPE}" == "both" ]]; then
  cat >> "${MODULE_DIR}/README.md" << 'EOF'
pip install -r requirements.txt
python src/main.py
EOF
fi

if [[ "${MODULE_TYPE}" == "js" ]] || [[ "${MODULE_TYPE}" == "both" ]]; then
  cat >> "${MODULE_DIR}/README.md" << 'EOF'
npm install
npm run dev
EOF
fi

cat >> "${MODULE_DIR}/README.md" << 'EOF'
```

## Tests

```bash
EOF

if [[ "${MODULE_TYPE}" == "python" ]] || [[ "${MODULE_TYPE}" == "both" ]]; then
  cat >> "${MODULE_DIR}/README.md" << 'EOF'
pytest tests/ -v
EOF
fi

if [[ "${MODULE_TYPE}" == "js" ]] || [[ "${MODULE_TYPE}" == "both" ]]; then
  cat >> "${MODULE_DIR}/README.md" << 'EOF'
npm test
EOF
fi

cat >> "${MODULE_DIR}/README.md" << 'EOF'
```

## Resources used

1. [Resource name](URL) — what I used it for
2. [Resource name](URL)
3. [Resource name](URL)
EOF

success "Created ${MODULE_DIR}/README.md"

# src placeholder
touch "${MODULE_DIR}/src/.gitkeep"
success "Created ${MODULE_DIR}/src/"

# tests placeholder
touch "${MODULE_DIR}/tests/.gitkeep"
success "Created ${MODULE_DIR}/tests/"

# requirements.txt
if [[ "${MODULE_TYPE}" == "python" ]] || [[ "${MODULE_TYPE}" == "both" ]]; then
  cat > "${MODULE_DIR}/requirements.txt" << EOF
# Module ${MODULE_NUM}: ${MODULE_DISPLAY}
# Add module-specific dependencies here.
# Root dev deps (ruff, pytest, etc.) are already in /requirements-dev.txt

EOF
  success "Created ${MODULE_DIR}/requirements.txt"
fi

# package.json
if [[ "${MODULE_TYPE}" == "js" ]] || [[ "${MODULE_TYPE}" == "both" ]]; then
  cat > "${MODULE_DIR}/package.json" << EOF
{
  "name": "${TRACK}-${MODULE_NUM}-${MODULE_NAME}",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "node src/index.js",
    "test": "vitest"
  },
  "devDependencies": {
    "vitest": "^2.1.8"
  }
}
EOF
  success "Created ${MODULE_DIR}/package.json"
fi

# ── Print commit message ───────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Module scaffolded!${RESET}"
echo ""
echo -e "${BOLD}Next step — make your first commit:${RESET}"
echo ""
echo "  git add tracks/${TRACK}/${MODULE_NUM}-${MODULE_NAME}/"
echo "  git commit -m \"track(${TRACK}): scaffold module ${MODULE_NUM} - ${MODULE_NAME}\""
echo ""

# Remind to update progress.json
warn "Remember to add this module to dashboard/data/progress.json"
echo "  Track ID: ${TRACK}"
echo "  Module ID: ${MODULE_NUM}-${MODULE_NAME}"
echo ""
