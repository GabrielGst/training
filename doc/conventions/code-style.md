# Code Style Guide

## Python

### Toolchain

| Tool | Purpose | Config |
|------|---------|--------|
| `ruff` | Linting + import sorting | `pyproject.toml` |
| `black` | Formatting | `pyproject.toml` |
| `mypy` | Type checking | `pyproject.toml` |
| `pytest` | Testing | `pyproject.toml` |

### ruff configuration

Add to each Python project's `pyproject.toml`:

```toml
[tool.ruff]
line-length = 88
target-version = "py312"

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
    "UP",  # pyupgrade
    "N",   # pep8-naming
]
ignore = ["E501"]  # line length handled by formatter

[tool.ruff.lint.isort]
known-first-party = ["src"]

[tool.black]
line-length = 88
target-version = ["py312"]

[tool.mypy]
python_version = "3.12"
strict = true
ignore_missing_imports = true

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --cov=src --cov-report=term-missing"
```

### Python Rules

**Typing:**
```python
# Good — explicit types everywhere
def process_batch(items: list[str], *, limit: int = 100) -> list[dict[str, str]]:
    ...

# Bad — no types
def process_batch(items, limit=100):
    ...
```

**OOP — composition over inheritance:**
```python
# Good
class DataProcessor:
    def __init__(self, validator: Validator, formatter: Formatter) -> None:
        self._validator = validator
        self._formatter = formatter

# Avoid deep inheritance chains — use Protocol for duck typing
```

**Error handling — be specific:**
```python
# Good
try:
    result = call_external_api(url)
except httpx.TimeoutException as e:
    raise ServiceUnavailableError(f"API timeout: {url}") from e

# Bad
try:
    result = call_external_api(url)
except Exception:
    pass
```

**No magic numbers:**
```python
# Good
MAX_RETRY_ATTEMPTS = 3
BATCH_SIZE = 256

# Bad
for _ in range(3):
    ...
```

---

## JavaScript / TypeScript

### Toolchain

| Tool | Purpose | Config |
|------|---------|--------|
| `eslint` | Linting | `eslint.config.mjs` |
| `prettier` | Formatting | `.prettierrc` |
| `typescript` | Type checking | `tsconfig.json` |
| `vitest` / `jest` | Unit testing | `vitest.config.ts` |
| `playwright` | E2E testing | `playwright.config.ts` |

### Prettier configuration (`.prettierrc`)

```json
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2,
  "arrowParens": "always"
}
```

### TypeScript Rules

**Strict mode — no exceptions:**
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  }
}
```

**No `any` — use `unknown` and narrow:**
```typescript
// Good
function processResponse(data: unknown): ProcessedData {
  if (!isValidData(data)) throw new Error('Invalid response shape');
  return transform(data);
}

// Bad
function processResponse(data: any): ProcessedData {
  return transform(data);
}
```

**Prefer `const`, use `let` only when mutation is intentional:**
```typescript
// Good
const user = await fetchUser(id);

// Only use let when the variable genuinely changes
let retries = 0;
while (retries < MAX_RETRIES) { retries++; }
```

**Early returns over nested conditionals:**
```typescript
// Good
function getDiscount(user: User): number {
  if (!user.isActive) return 0;
  if (user.tier === 'premium') return 0.2;
  return 0.1;
}

// Bad
function getDiscount(user: User): number {
  if (user.isActive) {
    if (user.tier === 'premium') {
      return 0.2;
    } else {
      return 0.1;
    }
  } else {
    return 0;
  }
}
```

---

## Comments

Write no comments by default. Only add one when the WHY is non-obvious:
- A hidden constraint or system-level invariant
- A workaround for a specific known bug (link the issue)
- Behavior that would genuinely surprise a reader

**Never explain what the code does — name it to be self-explanatory.**

```python
# Good — explains a non-obvious constraint
# Postgres COPY requires a real file, not a buffer — write temp file first
with tempfile.NamedTemporaryFile(suffix=".csv", delete=False) as f:
    ...

# Bad — explains what the code already says
# Increment counter
counter += 1
```

---

## File Structure per Module

```
<module-name>/
├── README.md          # What was built, what was learned, key commands
├── src/               # Source code
│   └── __init__.py    # or index.ts
├── tests/             # All tests
├── requirements.txt   # Python: module-specific deps (if applicable)
├── package.json       # JS: module-specific (if applicable)
└── .env.example       # Any env vars required (never commit .env)
```
