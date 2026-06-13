# Git Workflow

## Conventional Commits Reference

All commits in this repository must follow [Conventional Commits v1.0.0](https://www.conventionalcommits.org/).

### Format

```
<type>(<scope>): <short description>

[optional body]

[optional footer: BREAKING CHANGE: ..., Closes #NNN]
```

**Rules:**
- Type and scope: lower-case, kebab-case
- Short description: lower-case, present tense, ≤ 72 chars, no period
- Body: wrap at 120 chars, explain the WHY (not the what)
- Header max: 100 chars

---

### Types

| Type | Use for |
|------|---------|
| `feat` | A new feature (module, dashboard page, API endpoint, script) |
| `fix` | A bug fix |
| `docs` | Documentation only (README, roadmap, guides) |
| `style` | Formatting, whitespace — zero logic change |
| `refactor` | Code restructure with no behavior change |
| `test` | Adding or correcting tests only |
| `chore` | Build tooling, config, dependencies, CI |
| `ci` | GitHub Actions workflows |
| `perf` | Performance improvement |
| `revert` | Reverts a previous commit |
| `track` | **(Custom)** Adding or updating training module content |

---

### Scope Examples per Domain

| Scope | Domain |
|-------|--------|
| `ai-engineer` | AI engineer track |
| `software-engineer` | Software engineer track |
| `data-engineer` | Data engineer track |
| `ai-agents` | AI agents track |
| `gpu-monitoring` | GPU monitoring track |
| `hpc-quantum` | HPC and quantum track |
| `dashboard` | Next.js progress dashboard |
| `scripts` | Shell scripts |
| `ci` | CI/CD config |
| `docker` | Docker / Compose config |
| `docs` | Documentation |
| `deps` | Dependency updates |

---

### Example Commit Messages

```bash
# Initialize the repo
chore: initialize training repository with full scaffold, docs, and dashboard

# Add a training module
track(ai-engineer): scaffold module 02 - fastapi

# Complete a module with a project
track(data-engineer): complete module 01 - postgresql with analytics exercises

# Dashboard feature
feat(dashboard): add streak counter to overview page

# Fix a broken test
fix(ai-engineer): correct pytest fixture for FastAPI client

# Update documentation
docs(roadmap): update phase-2 schedule to reflect completed modules

# Dependency update
chore(deps): bump husky to 9.1.7

# Breaking change
feat(dashboard)!: replace JSON persistence with PostgreSQL backend

BREAKING CHANGE: progress.json is no longer the data source.
Run the migration script before updating: scripts/migrate-to-postgres.sh
```

---

## Branch Naming

```
<type>/<short-description>
```

- Use kebab-case
- Max ~50 chars
- Mirror the commit type

```bash
feat/dashboard-roadmap-timeline
fix/docker-postgres-healthcheck
docs/gpu-bridge-setup
chore/husky-v9-upgrade
track/ai-engineer-fastapi-module
track/data-engineer-postgresql-module
```

---

## PR Lifecycle

### 1. Start work
```bash
git checkout main && git pull
git checkout -b track/ai-engineer-fastapi-module
```

### 2. Work and commit
```bash
# Small, atomic commits as you go
git add src/api/main.py tests/test_api.py
git commit -m "feat(ai-engineer): add FastAPI CRUD endpoints with Pydantic models"

git add README.md
git commit -m "docs(ai-engineer): add FastAPI module learning log"
```

### 3. Push and open PR
```bash
git push -u origin track/ai-engineer-fastapi-module
gh pr create --draft --title "track(ai-engineer): complete module 02 - fastapi"
```

### 4. Self-review
- Fill in the PR template checklist
- Check CI passes
- Read your own diff with fresh eyes
- Mark ready for review (even solo — this is discipline)

### 5. Merge
```bash
# Use squash merge for small modules, merge commit for large features
# Never rebase published branches
gh pr merge --squash
git checkout main && git pull
git branch -d track/ai-engineer-fastapi-module
```

---

## Main Branch Protection Rules

Document these rules in GitHub settings (Settings → Branches → main):

- [x] Require a pull request before merging
- [x] Require status checks to pass (CI: lint-python, lint-node, test-python, commitlint)
- [x] Require branches to be up to date before merging
- [x] Do not allow force pushes
- [x] Do not allow deletions

---

## Commit Signing (Optional but Recommended)

```bash
# Generate GPG key
gpg --full-generate-key

# Configure git
git config --global user.signingkey <YOUR_KEY_ID>
git config --global commit.gpgsign true

# Add to GitHub: Settings → SSH and GPG keys → New GPG key
gpg --armor --export <YOUR_KEY_ID>
```
