# Windows Setup Guide — WSL2 + Full Dev Stack

> Goal: mirror the Ubuntu dev environment on Windows so you can work offline on flights.
> Tested on: Windows 10 (21H2+) and Windows 11.

---

## Step 1: Install WSL2 with Ubuntu

Open **PowerShell as Administrator**:

```powershell
# Install WSL2 with Ubuntu 24.04 LTS (one command, requires reboot)
wsl --install -d Ubuntu-24.04

# After reboot, Ubuntu opens automatically — set your username and password
# (use the same username as your Ubuntu machine for consistency)
```

If WSL is already installed but on WSL1:
```powershell
wsl --set-default-version 2
wsl --set-version Ubuntu 2
```

Verify:
```powershell
wsl --list --verbose
# NAME            STATE    VERSION
# Ubuntu-24.04    Running  2       ← must be 2
```

**Everything from this point forward runs inside the WSL2 Ubuntu terminal**, not PowerShell.

---

## Step 2: Install Docker Desktop

1. Download from [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)
2. During install: check **"Use WSL 2 instead of Hyper-V"**
3. After install, open Docker Desktop → Settings → Resources → WSL Integration → enable for Ubuntu-24.04
4. Apply & Restart

Verify inside WSL2:
```bash
docker --version        # Docker version 27.x
docker compose version  # Docker Compose version v2.x
```

Pull the images you'll need offline:
```bash
docker pull postgres:16-alpine
docker pull dpage/pgadmin4
```

---

## Step 3: Install Git inside WSL2

```bash
sudo apt update && sudo apt install -y git

# Configure (use same name/email as your Ubuntu machine)
git config --global user.name "Gabriel Gostiaux"
git config --global user.email "gabriel.gostiaux@insead.edu"
git config --global init.defaultBranch main
git config --global pull.rebase true
```

### SSH key for GitHub (inside WSL2)

```bash
# Generate a new key specifically for WSL2 (keep it separate from Windows keys)
ssh-keygen -t ed25519 -C "wsl2-training" -f ~/.ssh/github_wsl2

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github_wsl2

# Copy the public key
cat ~/.ssh/github_wsl2.pub
# → paste this into GitHub: Settings → SSH and GPG keys → New SSH key

# Test
ssh -T git@github.com
# → Hi GabrielGst! You've successfully authenticated...
```

### Clone the repo

```bash
mkdir -p ~/Documents/Git && cd ~/Documents/Git
git clone git@github.com:GabrielGst/training.git
cd training
```

---

## Step 4: Install pyenv + Python

```bash
# System dependencies for pyenv
sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev libffi-dev liblzma-dev libpq-dev curl

# Install pyenv
curl https://pyenv.run | bash

# Add to ~/.bashrc
cat >> ~/.bashrc << 'EOF'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF

source ~/.bashrc

# Install Python (matches .python-version in the repo)
cd ~/Documents/Git/training
pyenv install 3.12.10
pyenv global 3.12.10
python --version   # → Python 3.12.10

# Install root dev dependencies
pip install -r requirements-dev.txt
```

---

## Step 5: Install nvm + Node.js

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc

# Install Node (matches .nvmrc)
cd ~/Documents/Git/training
nvm install        # reads .nvmrc automatically
nvm use
node --version     # → v22.16.0

# Install root dependencies (commitlint + husky)
npm install
npm run prepare    # sets up husky hooks

# Install dashboard dependencies
cd dashboard && npm install && cd ..
```

---

## Step 6: Install VS Code + Remote WSL Extension

1. Install [VS Code for Windows](https://code.visualstudio.com/) (Windows side, not inside WSL2)
2. Open VS Code → Extensions → install **"WSL"** (by Microsoft)
3. Open WSL2 terminal → navigate to the repo → type:
   ```bash
   code .
   ```
   This opens VS Code on Windows but connected to your WSL2 filesystem — full IntelliSense, terminals, debugging all work.

Install extensions inside the WSL2 VS Code session:
```bash
code --install-extension ms-python.python
code --install-extension charliermarsh.ruff
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension bradlc.vscode-tailwindcss
code --install-extension ms-azuretools.vscode-docker
code --install-extension eamodio.gitlens
```

---

## Step 7: Verify everything

Run the preflight check (inside WSL2, from the repo root):

```bash
chmod +x scripts/preflight.sh
bash scripts/preflight.sh
```

You should see all green checkmarks. Fix any blockers before your next flight.

---

## Offline workflow on the plane

Once set up, your in-flight workflow is entirely inside WSL2:

```bash
# Open a WSL2 terminal (Windows Terminal → Ubuntu tab)
cd ~/Documents/Git/training

# Start Docker services (PostgreSQL + pgAdmin)
docker compose up -d

# Open the dashboard
cd dashboard && npm run dev &
# → http://localhost:3000 in your Windows browser

# Open VS Code
code .

# Work, commit, repeat — all offline
git add . && git commit -m "track(ai-engineer): ..."

# Push when you land (WiFi back)
git push
```

---

## Windows Terminal (recommended)

Install [Windows Terminal](https://aka.ms/terminal) from the Microsoft Store. It gives you tabs for WSL2, PowerShell, and CMD in one window. Set Ubuntu as the default profile.

---

## Common Issues

| Problem | Fix |
|---------|-----|
| `wsl --install` fails | Enable virtualization in BIOS (Intel VT-x or AMD-V) |
| Docker Desktop won't start | Ensure Hyper-V and Virtual Machine Platform are enabled in Windows Features |
| `code .` doesn't open VS Code | Install VS Code on Windows (not inside WSL2), then restart WSL2 |
| Git hooks not running | Ensure you commit via WSL2 terminal, not a GUI that doesn't load `~/.bashrc` |
| `npm install` fails with EACCES | Never run `sudo npm` — fix: `npm config set prefix ~/.npm-global` |
| Python `pip install` fails | Activate pyenv: `pyenv global 3.12.10 && python --version` |
| Port 3000 not accessible in Windows browser | WSL2 auto-forwards ports — just open `http://localhost:3000` in Edge/Chrome |

---

## What does NOT work offline

- `git push` / `git pull` (needs GitHub)
- GitHub Actions CI
- `npm install` or `pip install` new packages
- `docker pull` new images

Pre-pull everything you need before boarding using `bash scripts/preflight.sh`.
