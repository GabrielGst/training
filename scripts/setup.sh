#!/usr/bin/env bash
# scripts/setup.sh — idempotent bootstrap for the training repository
# Usage: ./scripts/setup.sh
# Tested on: Ubuntu 22.04 LTS, Ubuntu 24.04 LTS

set -euo pipefail

# ── Color helpers ──────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[OK]${RESET}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error()   { echo -e "${RED}[ERR]${RESET}  $*" >&2; exit 1; }
header()  { echo -e "\n${BOLD}${CYAN}━━ $* ━━${RESET}"; }

# ── Resolve repo root ──────────────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_VERSION="$(cat "${REPO_ROOT}/.python-version" | tr -d '[:space:]')"
NODE_VERSION="$(cat "${REPO_ROOT}/.nvmrc" | tr -d '[:space:]')"

echo -e "${BOLD}Training Repository Bootstrap${RESET}"
echo "Repo:   ${REPO_ROOT}"
echo "Python: ${PYTHON_VERSION}"
echo "Node:   ${NODE_VERSION}"
echo ""

# ── Step 1: System dependencies ────────────────────────────────────────────────
header "Step 1: System dependencies"

PACKAGES=(curl wget git build-essential libssl-dev zlib1g-dev libbz2-dev
          libreadline-dev libsqlite3-dev libffi-dev liblzma-dev libpq-dev
          postgresql-client docker-compose-plugin)

MISSING=()
for pkg in "${PACKAGES[@]}"; do
  if ! dpkg -l "$pkg" &>/dev/null; then
    MISSING+=("$pkg")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  info "Installing: ${MISSING[*]}"
  sudo apt-get update -qq
  sudo apt-get install -y -qq "${MISSING[@]}"
  success "System packages installed"
else
  success "System packages already present"
fi

# Ensure Docker is installed (uses official install script if missing)
if ! command -v docker &>/dev/null; then
  info "Installing Docker via official script..."
  curl -fsSL https://get.docker.com | bash
  sudo usermod -aG docker "$USER"
  warn "Docker installed. Log out and back in (or run 'newgrp docker') to use without sudo."
else
  success "Docker $(docker --version | cut -d' ' -f3 | tr -d ',') already installed"
fi

# ── Step 2: pyenv + Python ─────────────────────────────────────────────────────
header "Step 2: pyenv + Python ${PYTHON_VERSION}"

export PYENV_ROOT="${HOME}/.pyenv"
export PATH="${PYENV_ROOT}/bin:${PATH}"

if ! command -v pyenv &>/dev/null; then
  info "Installing pyenv..."
  curl -fsSL https://pyenv.run | bash

  # Add to shell profile
  SHELL_RC="${HOME}/.bashrc"
  if [[ "${SHELL}" == *zsh ]]; then SHELL_RC="${HOME}/.zshrc"; fi

  {
    echo ''
    echo '# pyenv'
    echo 'export PYENV_ROOT="$HOME/.pyenv"'
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"'
    echo 'eval "$(pyenv init -)"'
    echo 'eval "$(pyenv virtualenv-init -)"'
  } >> "${SHELL_RC}"

  eval "$(pyenv init -)"
  success "pyenv installed"
else
  eval "$(pyenv init -)"
  success "pyenv $(pyenv --version | cut -d' ' -f2) already installed"
fi

if ! pyenv versions --bare | grep -q "^${PYTHON_VERSION}$"; then
  info "Installing Python ${PYTHON_VERSION} via pyenv..."
  pyenv install "${PYTHON_VERSION}"
  success "Python ${PYTHON_VERSION} installed"
else
  success "Python ${PYTHON_VERSION} already installed via pyenv"
fi

pyenv global "${PYTHON_VERSION}"
PYTHON_BIN="$(pyenv which python)"
success "Active Python: $("${PYTHON_BIN}" --version)"

# ── Step 3: nvm + Node ─────────────────────────────────────────────────────────
header "Step 3: nvm + Node.js ${NODE_VERSION}"

export NVM_DIR="${HOME}/.nvm"

if [ ! -d "${NVM_DIR}" ]; then
  info "Installing nvm..."
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh" | bash
  success "nvm installed"
fi

# shellcheck source=/dev/null
[ -s "${NVM_DIR}/nvm.sh" ] && source "${NVM_DIR}/nvm.sh"

if ! nvm ls "${NODE_VERSION}" &>/dev/null; then
  info "Installing Node.js ${NODE_VERSION} via nvm..."
  nvm install "${NODE_VERSION}"
  success "Node.js ${NODE_VERSION} installed"
else
  success "Node.js ${NODE_VERSION} already installed via nvm"
fi

nvm use "${NODE_VERSION}" &>/dev/null
success "Active Node: $(node --version)"

# ── Step 4: Python dev dependencies ────────────────────────────────────────────
header "Step 4: Python dev dependencies"

cd "${REPO_ROOT}"
"${PYTHON_BIN}" -m pip install --upgrade pip --quiet
"${PYTHON_BIN}" -m pip install -r requirements-dev.txt --quiet
success "Python dev dependencies installed (ruff, black, pytest, mypy, jupyter, ...)"

# ── Step 5: Node root dependencies ─────────────────────────────────────────────
header "Step 5: Node root dependencies (commitlint + husky)"

cd "${REPO_ROOT}"
npm install --silent
npm run prepare --silent 2>/dev/null || true
success "Root Node dependencies installed and husky hooks configured"

# ── Step 6: Docker Compose stack ───────────────────────────────────────────────
header "Step 6: Docker Compose stack (postgres + pgadmin)"

cd "${REPO_ROOT}"

if docker compose ps postgres 2>/dev/null | grep -q "running"; then
  success "Docker Compose stack already running"
else
  info "Starting Docker Compose stack..."
  docker compose up -d

  info "Waiting for postgres to become healthy..."
  RETRIES=15
  until docker compose exec -T postgres pg_isready -U training_user -d training_db &>/dev/null; do
    RETRIES=$((RETRIES - 1))
    if [ "$RETRIES" -eq 0 ]; then
      error "PostgreSQL did not become healthy in time. Check: docker compose logs postgres"
    fi
    sleep 2
  done
  success "PostgreSQL 16 healthy at localhost:5432"
  success "pgAdmin 4 available at http://localhost:5050"
fi

# ── Summary ────────────────────────────────────────────────────────────────────
header "Setup complete"

echo ""
echo -e "${BOLD}Version summary:${RESET}"
echo "  Python : $("${PYTHON_BIN}" --version)"
echo "  Node   : $(node --version)"
echo "  npm    : $(npm --version)"
echo "  Docker : $(docker --version | cut -d' ' -f3 | tr -d ',')"
echo "  ruff   : $(ruff --version 2>/dev/null || echo 'not in PATH — source your shell')"
echo ""
echo -e "${BOLD}Next steps:${RESET}"
echo "  1. Source your shell profile to activate pyenv/nvm in new terminals:"
echo "       source ~/.bashrc   (or ~/.zshrc)"
echo ""
echo "  2. Launch the dashboard:"
echo "       cd dashboard && npm install && npm run dev"
echo "       → http://localhost:3000"
echo ""
echo "  3. Connect to PostgreSQL:"
echo "       psql postgresql://training_user:training_pass@localhost:5432/training_db"
echo "       # or open pgAdmin at http://localhost:5050"
echo ""
echo "  4. Create your GitHub repo and push:"
echo "       gh repo create training --public --push --source=."
echo ""
echo -e "${GREEN}Happy training!${RESET}"
