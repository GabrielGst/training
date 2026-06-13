#!/usr/bin/env bash
# scripts/preflight.sh — pre-flight offline readiness check
# Run this while still online, before a flight.
# Exit 0 = all clear. Exit 1 = blockers found.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

PASS="${GREEN}✓${RESET}"
FAIL="${RED}✗${RESET}"
WARN="${YELLOW}!${RESET}"

BLOCKERS=0
WARNINGS=0

ok()   { echo -e "  ${PASS}  $*"; }
fail() { echo -e "  ${FAIL}  $*"; BLOCKERS=$((BLOCKERS + 1)); }
warn() { echo -e "  ${WARN}  $*"; WARNINGS=$((WARNINGS + 1)); }
header() { echo -e "\n${BOLD}${CYAN}$*${RESET}"; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_VERSION="$(cat "${REPO_ROOT}/.python-version" | tr -d '[:space:]')"
NODE_VERSION="$(cat "${REPO_ROOT}/.nvmrc" | tr -d '[:space:]')"

echo ""
echo -e "${BOLD}Pre-flight Offline Readiness Check${RESET}"
echo -e "Repo: ${REPO_ROOT}"
echo -e "Time: $(date '+%Y-%m-%d %H:%M %Z')"

# ── 1. Git ──────────────────────────────────────────────────────────────────
header "1. Git"

if command -v git &>/dev/null; then
  ok "git $(git --version | cut -d' ' -f3)"
else
  fail "git not found"
fi

cd "${REPO_ROOT}"

UNPUSHED=$(git log origin/main..HEAD --oneline 2>/dev/null | wc -l | tr -d ' ')
if [ "${UNPUSHED}" -eq 0 ]; then
  ok "All commits pushed to origin/main"
else
  warn "${UNPUSHED} commit(s) not yet pushed — push before boarding if you want GitHub backup"
  git log origin/main..HEAD --oneline | sed 's/^/       /'
fi

DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [ "${DIRTY}" -eq 0 ]; then
  ok "Working tree clean"
else
  warn "${DIRTY} uncommitted change(s) — stash or commit before the flight"
fi

# ── 2. Python ───────────────────────────────────────────────────────────────
header "2. Python"

export PYENV_ROOT="${HOME}/.pyenv"
export PATH="${PYENV_ROOT}/bin:${PATH}"
eval "$(pyenv init -)" 2>/dev/null || true

if command -v python &>/dev/null; then
  ACTUAL_PY="$(python --version 2>&1 | cut -d' ' -f2)"
  if [ "${ACTUAL_PY}" = "${PYTHON_VERSION}" ]; then
    ok "Python ${ACTUAL_PY}"
  else
    warn "Python ${ACTUAL_PY} active, expected ${PYTHON_VERSION} (check pyenv)"
  fi
else
  fail "python not found"
fi

for pkg in ruff black pytest mypy ipykernel python-dotenv; do
  if python -m pip show "${pkg}" &>/dev/null 2>&1; then
    VER=$(python -m pip show "${pkg}" 2>/dev/null | grep ^Version | cut -d' ' -f2)
    ok "${pkg} ${VER}"
  else
    fail "${pkg} not installed — run: pip install -r requirements-dev.txt"
  fi
done

# ── 3. Node ─────────────────────────────────────────────────────────────────
header "3. Node.js"

export NVM_DIR="${HOME}/.nvm"
[ -s "${NVM_DIR}/nvm.sh" ] && source "${NVM_DIR}/nvm.sh" 2>/dev/null || true

if command -v node &>/dev/null; then
  ACTUAL_NODE="$(node --version | tr -d 'v')"
  if [ "${ACTUAL_NODE}" = "${NODE_VERSION}" ]; then
    ok "Node.js v${ACTUAL_NODE}"
  else
    warn "Node v${ACTUAL_NODE} active, .nvmrc expects v${NODE_VERSION}"
  fi
else
  fail "node not found"
fi

if command -v npm &>/dev/null; then
  ok "npm $(npm --version)"
else
  fail "npm not found"
fi

# Root node_modules
if [ -d "${REPO_ROOT}/node_modules" ]; then
  ok "Root node_modules present"
else
  fail "Root node_modules missing — run: npm install"
fi

# Dashboard node_modules
if [ -d "${REPO_ROOT}/dashboard/node_modules" ]; then
  ok "Dashboard node_modules present"
else
  fail "Dashboard node_modules missing — run: cd dashboard && npm install"
fi

# ── 4. Dashboard build ──────────────────────────────────────────────────────
header "4. Dashboard"

if [ -f "${REPO_ROOT}/dashboard/package.json" ]; then
  ok "dashboard/package.json present"
else
  fail "dashboard/package.json missing"
fi

if [ -f "${REPO_ROOT}/dashboard/data/progress.json" ]; then
  MODULES=$(python -c "
import json, sys
data = json.load(open('${REPO_ROOT}/dashboard/data/progress.json'))
total = sum(len(t['modules']) for t in data['tracks'])
print(total)
" 2>/dev/null || echo "?")
  ok "progress.json present (${MODULES} modules tracked)"
else
  fail "dashboard/data/progress.json missing"
fi

# ── 5. Docker & images ──────────────────────────────────────────────────────
header "5. Docker"

if command -v docker &>/dev/null; then
  if docker info &>/dev/null 2>&1; then
    ok "Docker running ($(docker --version | cut -d' ' -f3 | tr -d ','))"

    for image in "postgres:16-alpine" "dpage/pgadmin4"; do
      if docker image inspect "${image}" &>/dev/null 2>&1; then
        ok "Image pulled: ${image}"
      else
        fail "Image not pulled: ${image} — run: docker pull ${image}"
      fi
    done

    # Check if compose stack is startable
    if docker compose -f "${REPO_ROOT}/docker-compose.yml" config &>/dev/null 2>&1; then
      ok "docker-compose.yml valid"
    else
      warn "docker-compose.yml validation failed"
    fi

  else
    warn "Docker installed but daemon not running — start Docker before the flight"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  warn "Docker not found — PostgreSQL won't be available offline"
fi

# ── 6. Husky hooks ──────────────────────────────────────────────────────────
header "6. Git hooks (commitlint)"

if [ -f "${REPO_ROOT}/.husky/commit-msg" ]; then
  ok ".husky/commit-msg hook present"
else
  fail ".husky/commit-msg missing — run: npm run prepare"
fi

if [ -f "${REPO_ROOT}/node_modules/.bin/commitlint" ]; then
  ok "commitlint binary present"
else
  fail "commitlint binary missing — run: npm install"
fi

# ── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}─────────────────────────────${RESET}"

if [ "${BLOCKERS}" -eq 0 ] && [ "${WARNINGS}" -eq 0 ]; then
  echo -e "${GREEN}${BOLD}All clear — you're ready to fly offline.${RESET}"
  echo ""
  exit 0
elif [ "${BLOCKERS}" -eq 0 ]; then
  echo -e "${YELLOW}${BOLD}Ready with ${WARNINGS} warning(s) — review above before boarding.${RESET}"
  echo ""
  exit 0
else
  echo -e "${RED}${BOLD}${BLOCKERS} blocker(s) found — fix before boarding.${RESET}"
  if [ "${WARNINGS}" -gt 0 ]; then
    echo -e "${YELLOW}${WARNINGS} additional warning(s).${RESET}"
  fi
  echo ""
  exit 1
fi
