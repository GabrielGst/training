# Repo Chores

Run a full health check and maintenance pass on the training repository: lint, tests, CI status, dependency freshness, and changelog hygiene.

## Steps

### 1. Git status

```bash
cd /home/ubuntu/Documents/Git/training
git status --short
git log --oneline -10
```

Report: uncommitted changes, unpushed commits, any stale branches.

### 2. Lint all code

```bash
# Python (all track modules)
find tracks/ -name "*.py" | head -50 | xargs ruff check --no-cache 2>/dev/null || echo "No Python files yet"

# Node / TypeScript (dashboard)
cd dashboard && npm run lint 2>&1 | tail -20

# Commitlint on recent commits
cd /home/ubuntu/Documents/Git/training
git log --format="%s" -20 | npx commitlint --stdin 2>&1 | tail -10
```

### 3. Tests

```bash
# Python tests
cd /home/ubuntu/Documents/Git/training
python -m pytest --tb=short -q 2>&1 | tail -20 || echo "No Python tests yet"

# Dashboard type check
cd dashboard && npx tsc --noEmit 2>&1 | tail -20
```

### 4. Dashboard data validation

```bash
python3 -c "
import json, sys
with open('dashboard/data/progress.json') as f:
    d = json.load(f)
errors = []
valid_statuses = {'not_started', 'in_progress', 'completed'}
for track in d['tracks']:
    for mod in track['modules']:
        if mod['status'] not in valid_statuses:
            errors.append(f'{track[\"id\"]}/{mod[\"id\"]}: invalid status {mod[\"status\"]}')
        if mod['hoursLogged'] < 0:
            errors.append(f'{track[\"id\"]}/{mod[\"id\"]}: negative hours')
if errors:
    print('ERRORS:')
    for e in errors: print(f'  {e}')
else:
    total = sum(m['hoursLogged'] for t in d['tracks'] for m in t['modules'])
    done = sum(1 for t in d['tracks'] for m in t['modules'] if m['status'] == 'completed')
    total_mods = sum(len(t['modules']) for t in d['tracks'])
    print(f'progress.json OK: {total_mods} modules, {done} completed, {total}h logged')
"
```

### 5. Dependency freshness

```bash
# Check for outdated npm packages (dashboard)
cd /home/ubuntu/Documents/Git/training/dashboard
npm outdated 2>/dev/null | head -20 || echo "All packages up to date"

# Check Python dev requirements
pip list --outdated 2>/dev/null | head -20 || echo "pip list failed"
```

### 6. Changelog check

Read `CHANGELOG.md` and check:
- The `[Unreleased]` section has an entry for any significant changes since the last tagged version
- If there are commits since the last entry, add a summary under `[Unreleased]`

```bash
git log --oneline $(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~20")..HEAD 2>/dev/null | head -20
```

### 7. Module stub check

For every module directory that has only a `.gitkeep` (no README, no code):
- List it as "not started"
- Do NOT auto-create content — just report the count

```bash
count=0
for track in /home/ubuntu/Documents/Git/training/tracks/*/; do
  for mod in "$track"*/; do
    files=$(find "$mod" -type f ! -name '.gitkeep' | wc -l)
    [ "$files" -eq 0 ] && count=$((count+1)) && echo "STUB: $mod"
  done
done
echo "Total stub modules: $count"
```

### 8. Summary report

```
Repo Chores — {date}
====================
Git: {N commits ahead/behind, N uncommitted files}
Lint: {pass/fail — N issues}
Tests: {pass/fail — N tests, N failed}
Dashboard: {OK / N type errors}
Dependencies: {N outdated packages}
Changelog: {up to date / N commits unlogged}
Stub modules: {N}
```

## Do NOT change
- Source CSV files
- Skill IDs, module IDs, project IDs
- Any committed code without running lint + tests first
- Force-push or rebase published commits
