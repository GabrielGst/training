# Pre-flight Offline Readiness Check

Run the preflight script and interpret the results. Fix any blockers found.

## Steps

1. Run the preflight script:
```bash
bash scripts/preflight.sh
```

2. Read the output carefully. For each **blocker** (✗), run the fix command shown and re-check.

3. For each **warning** (!), decide whether it matters for this flight:
   - Unpushed commits → push them if you want a GitHub backup before going offline
   - Uncommitted changes → stash (`git stash`) or commit them
   - Docker not running → start it now; pull images before boarding

4. If any blockers remain after fixes, report what's failing and I'll help diagnose.

5. Once all clear, confirm you're ready with: `bash scripts/preflight.sh && echo "READY"`

## What this checks
- Git: unpushed commits, dirty working tree
- Python: version matches `.python-version`, all root dev deps installed
- Node: version matches `.nvmrc`, root and dashboard `node_modules` present
- Dashboard: `package.json` and `progress.json` present
- Docker: daemon running, `postgres:16-alpine` and `dpage/pgadmin4` images pulled
- Husky: commit-msg hook and commitlint binary present
