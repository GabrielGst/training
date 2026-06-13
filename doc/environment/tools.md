# Recommended Tools

## CLI Tools

| Tool | Purpose | Install |
|------|---------|---------|
| `pyenv` | Python version management | `curl https://pyenv.run \| bash` |
| `nvm` | Node.js version management | `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh \| bash` |
| `docker` | Containerization | `curl -fsSL https://get.docker.com \| bash` |
| `gh` | GitHub CLI | `sudo apt install gh` then `gh auth login` |
| `ruff` | Python linter (replaces flake8 + isort) | `pip install ruff` |
| `black` | Python formatter | `pip install black` |
| `nvtop` | GPU process monitor (htop for NVIDIA) | `sudo apt install nvtop` |
| `htop` | Process monitor | `sudo apt install htop` |
| `jq` | JSON processor | `sudo apt install jq` |
| `rsync` | File sync | Pre-installed on Ubuntu |
| `tmux` | Terminal multiplexer | `sudo apt install tmux` |
| `tree` | Directory tree viewer | `sudo apt install tree` |
| `httpie` | HTTP client (better curl) | `pip install httpie` |
| `pgcli` | PostgreSQL CLI with autocomplete | `pip install pgcli` |

## VSCode Extensions

| Extension | ID | Purpose |
|-----------|-----|---------|
| Python | `ms-python.python` | Python language support |
| Pylance | `ms-python.vscode-pylance` | Fast Python type checking |
| Ruff | `charliermarsh.ruff` | Inline ruff linting |
| Prettier | `esbenp.prettier-vscode` | JS/TS/JSON formatting |
| ESLint | `dbaeumer.vscode-eslint` | JS/TS linting |
| Tailwind CSS IntelliSense | `bradlc.vscode-tailwindcss` | Tailwind autocomplete |
| Docker | `ms-azuretools.vscode-docker` | Docker file editing + explorer |
| GitLens | `eamodio.gitlens` | Git blame, history, compare |
| Remote SSH | `ms-vscode-remote.remote-ssh` | Connect to GPU machine |
| Jupyter | `ms-toolsai.jupyter` | Notebook support |
| Thunder Client | `rangav.vscode-thunder-client` | REST API testing in VSCode |
| Error Lens | `usernamehw.errorlens` | Inline error highlighting |
| Even Better TOML | `tamasfe.even-better-toml` | TOML file support |

## VSCode Settings (`.vscode/settings.json`)

Create per-repo `.vscode/settings.json`:

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.codeActionsOnSave": {
      "source.fixAll.ruff": "explicit",
      "source.organizeImports.ruff": "explicit"
    }
  },
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
  "ruff.enable": true,
  "ruff.lint.run": "onSave",
  "typescript.preferences.importModuleSpecifier": "non-relative",
  "tailwindCSS.experimental.classRegex": [
    ["cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"]
  ]
}
```

## Bash Aliases

Add to `~/.bashrc`:

```bash
# Docker
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dcp='docker compose ps'

# PostgreSQL (dev)
alias pgdev='psql postgresql://training_user:training_pass@localhost:5432/training_db'

# Python
alias py='python'
alias ipy='ipython'
alias pytest='python -m pytest'

# Git
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias gp='git push'
alias gpl='git pull'

# Navigation
alias training='cd ~/Documents/Git/training'
alias dashboard='cd ~/Documents/Git/training/dashboard'
```

## tmux Configuration

Create `~/.tmux.conf`:

```bash
# Mouse support
set -g mouse on

# Start windows at 1
set -g base-index 1

# Better colors
set -g default-terminal "screen-256color"

# Status bar
set -g status-right '%Y-%m-%d %H:%M'

# Key bindings
bind | split-window -h
bind - split-window -v
```

## Git Global Config

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global core.editor "code --wait"
git config --global pull.rebase true
git config --global init.defaultBranch main
git config --global alias.lg "log --oneline --graph --decorate -20"
git config --global alias.st "status"
```
