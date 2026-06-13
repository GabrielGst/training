## Summary

<!-- One paragraph: what does this PR do and why? -->

Closes #<!-- issue number -->

---

## Type of change

- [ ] `feat` — new training module or feature
- [ ] `fix` — bug fix
- [ ] `docs` — documentation only
- [ ] `chore` — tooling, config, dependencies
- [ ] `track` — adding or updating training module content
- [ ] `refactor` — code restructure, no behavior change
- [ ] `ci` — CI/CD changes

---

## Checklist

### Before marking ready for review

- [ ] PR title follows conventional commit format: `type(scope): short description`
- [ ] Branch name follows convention: `feat/`, `fix/`, `docs/`, `chore/`, `track/`
- [ ] All commits in this PR follow conventional commit format
- [ ] No secrets, credentials, or API keys committed
- [ ] No leftover debug code, print statements, or `TODO: remove` comments

### Code quality

- [ ] Python files pass `ruff check` and `ruff format --check`
- [ ] JS/TS files pass ESLint with zero warnings
- [ ] New Python code has at least basic test coverage (or test coverage is noted as deferred with reason)
- [ ] No `any` types introduced in TypeScript without comment explaining why

### Documentation

- [ ] Updated relevant `README.md` if module structure changed
- [ ] Updated `doc/roadmap/ROADMAP.md` if milestones changed
- [ ] Any new environment variable added to `.env.example`

---

## Test evidence

<!-- Screenshot, terminal output, or describe how you verified this works -->

```
# paste relevant output here
```

---

## Self-review notes

<!-- Anything the reviewer should pay special attention to, known trade-offs, or known debt introduced -->
