# Local Environment Setup (Ubuntu/Debian)

> The `scripts/setup.sh` script automates all steps below. This doc explains what it does and why.

---

## Prerequisites

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev libffi-dev liblzma-dev \
  libpq-dev postgresql-client
```

---

## Python — pyenv

We use pyenv to manage Python versions so the system Python is never touched.

```bash
# Install pyenv
curl https://pyenv.run | bash

# Add to ~/.bashrc or ~/.zshrc
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Reload shell
source ~/.bashrc

# Install pinned version (matches .python-version)
pyenv install 3.12.10
pyenv global 3.12.10

# Verify
python --version  # → Python 3.12.10
```

### Root Python dev dependencies

```bash
# From the training/ root
pip install -r requirements-dev.txt
```

This installs: ruff, black, pytest, pytest-cov, pytest-asyncio, ipykernel, jupyter, python-dotenv, mypy.

---

## Node — nvm

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Reload shell
source ~/.bashrc

# Install pinned version (matches .nvmrc)
nvm install         # reads .nvmrc automatically
nvm use

# Verify
node --version  # → v22.16.0
npm --version
```

### Root Node dependencies

```bash
# From the training/ root (installs commitlint + husky)
npm install

# Set up husky git hooks
npm run prepare
```

---

## Docker & Docker Compose

```bash
# Install Docker Engine (official method)
curl -fsSL https://get.docker.com | bash
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker run hello-world
docker compose version  # → Docker Compose version v2.x
```

### Start the database stack

```bash
# From training/ root
docker compose up -d

# Verify postgres is healthy
docker compose ps
# → training_postgres   running (healthy)
# → training_pgadmin    running

# Connect via psql
psql postgresql://training_user:training_pass@localhost:5432/training_db

# Open pgAdmin
# → http://localhost:5050
# Login: admin@training.local / admin
# Add server: host=postgres, port=5432, db=training_db, user=training_user, pass=training_pass
```

### Useful Docker commands

```bash
docker compose stop           # Stop without destroying
docker compose down           # Stop + remove containers (data preserved in volumes)
docker compose down -v        # Stop + remove containers AND volumes (fresh start)
docker compose logs -f        # Follow all logs
docker compose logs postgres  # Postgres logs only
```

---

## PostgreSQL (via Docker)

The Docker Compose stack provides PostgreSQL 16. No local Postgres install needed.

```bash
# Connection string
DATABASE_URL=postgresql://training_user:training_pass@localhost:5432/training_db

# psql shorthand
alias pgdev='psql postgresql://training_user:training_pass@localhost:5432/training_db'
```

Add to `~/.bashrc` for convenience.

---

## Dashboard

```bash
cd dashboard
npm install
npm run dev
# → http://localhost:3000
```

---

## VSCode Extensions

Install these for optimal DX:

```bash
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension charliermarsh.ruff
code --install-extension ms-azuretools.vscode-docker
code --install-extension bradlc.vscode-tailwindcss
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension prisma.prisma
code --install-extension eamodio.gitlens
code --install-extension ms-vscode-remote.remote-ssh
```

---

## Verifying the Full Stack

After running `scripts/setup.sh`:

```bash
# Python
python --version        # 3.12.x
ruff --version
pytest --version

# Node
node --version           # v22.x
npm --version
npx commitlint --version

# Docker
docker compose ps        # postgres healthy, pgadmin running

# Dashboard
# http://localhost:3000  should show the progress tracker
```

---

## Environment Variables

Each module that needs env vars must have a `.env.example`. Copy to `.env` and fill in:

```bash
cp tracks/ai-engineer/02-fastapi/.env.example tracks/ai-engineer/02-fastapi/.env
```

Never commit `.env` files — they are gitignored at the root level.
