# Scripts

Automation scripts for the training repository.

---

## setup.sh

One-command bootstrap for a fresh Ubuntu machine. Idempotent — safe to run multiple times.

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

What it does:
1. Checks and installs system dependencies (git, curl, build-essential, libpq-dev)
2. Installs pyenv and Python 3.12.10
3. Installs nvm and Node.js v22.16.0
4. Installs root Python dev dependencies (`requirements-dev.txt`)
5. Installs root Node dependencies (commitlint + husky)
6. Starts Docker services (postgres + pgadmin)
7. Prints a success summary with next steps

---

## new-module.sh

Interactive scaffolding script for new training modules.

```bash
chmod +x scripts/new-module.sh
./scripts/new-module.sh
```

What it does:
1. Prompts for: track name, module number, module name, module type (python/js/both/none)
2. Creates the folder under `tracks/<track>/<number>-<name>/`
3. Creates: `README.md` (from template), `src/` folder, `tests/` folder, `.gitkeep`
4. Optionally creates `requirements.txt` or `package.json`
5. Prints the conventional commit message to use

Example output:
```
✓ Created tracks/ai-engineer/07-model-optimization/
✓ Created tracks/ai-engineer/07-model-optimization/README.md
✓ Created tracks/ai-engineer/07-model-optimization/src/
✓ Created tracks/ai-engineer/07-model-optimization/tests/
✓ Created tracks/ai-engineer/07-model-optimization/requirements.txt

Next step — make your first commit:
  git add tracks/ai-engineer/07-model-optimization/
  git commit -m "track(ai-engineer): scaffold module 07 - model-optimization"
```

---

## db-init/

Place `.sql` files here to auto-run on first PostgreSQL container start.
Files are executed in alphabetical order.

Example: `db-init/001-sample-schema.sql`
