# P0.2 — Python SQL Application with SQLAlchemy

**Domain:** Backend Engineering **Track:** `fde-extra` **Status:** not started **Hours target:** 2

## Business Problem

A business analyst needs to track product inventory and stock movements across a warehouse. Data must persist reliably across sessions, support concurrent updates without corruption, and be queryable without writing raw SQL strings. This project builds a layered Python backend that separates business rules from database mechanics — a pattern applicable to any data-intensive application.

## What you will build

- A pure Python domain model (no database coupling)
- A SQLAlchemy ORM layer that maps to the domain without polluting it
- An Alembic migration pipeline for schema versioning
- A Repository pattern isolating the service layer from the database
- A Flask REST API as a thin adapter over the service layer
- Unit tests using a fake repository (no DB required) and integration tests against a real SQLite test DB

## Architecture

```
HTTP Request
      |
      v
 Flask (entrypoints/) — thin adapter, no business logic
      |
      v
 Service Layer (service_layer/) — business rules, orchestration
      |
      v
 Repository (adapters/repository.py) — abstract interface
      |          |
      |          └── FakeRepository (in-memory, for unit tests)
      |
      v
 SQLAlchemy ORM (adapters/orm.py) — maps tables ↔ domain objects
      |
      v
 SQLite / PostgreSQL
      |
      v
 Alembic (migrations/) — schema versioning
```

**Dependency rule:** domain/ imports nothing. adapters/ imports domain/. service_layer/ imports domain/ and adapters/. entrypoints/ imports everything. Never invert this.

## Module & Function Map

Every class and function below, and the call chain that links them, is implemented step by step in the tutorial. Use this as a reference when you lose track of where something lives.

```
src/domain/model.py          ← pure Python, no imports outside stdlib
  StockMovement (dataclass)
    quantity: int
    reason: str
    timestamp: datetime

  Product
    __init__(sku, name, quantity=0)
    __repr__()                       → "Product(sku='...', name='...', qty=N)"
    __eq__(other)                    → identity by sku
    __hash__()                       → required to store Product in a set (FakeRepository)
    is_low_stock (property)          → True if quantity < threshold
    from_dict(data) (classmethod)    → alternative constructor from a dict
    adjust(quantity, reason) → None  → validates, updates quantity, appends StockMovement

src/adapters/orm.py
  start_mappers() → None            ← call once at startup; maps tables ↔ domain classes

src/adapters/repository.py
  AbstractRepository (ABC)
    add(product) [abstract]
    get(sku)     [abstract] → Product | None
    list()       [abstract] → list[Product]

  SqlAlchemyRepository(AbstractRepository)
    __init__(session: Session)
    add(product)  → session.add(product)
    get(sku)      → session.query(Product).filter_by(sku=sku).first()
    list()        → session.query(Product).all()

  FakeRepository(AbstractRepository)     ← in-memory, for unit tests
    __init__(products: list | None)
    add(product)  → self._products.add(product)   # needs Product.__hash__
    get(sku)      → next(filter(...), None)
    list()        → list(self._products)

src/service_layer/services.py
  exceptions: ProductNotFound, DuplicateSku
  add_product(sku, name, quantity, repo)  → Product
  adjust_stock(sku, quantity, reason, repo) → Product
  get_product(sku, repo)                  → Product
  list_products(repo)                     → list[Product]

src/entrypoints/flask_app.py
  POST   /products            → services.add_product()   → 201 | 409 | 400
  PATCH  /products/<sku>/stock → services.adjust_stock() → 200 | 404 | 400
  GET    /products            → services.list_products() → 200
  GET    /products/<sku>      → services.get_product()   → 200 | 404
```

**Full call chain for `POST /products`:**
```
HTTP POST /products (JSON body)
  └── flask_app.create_product()
        ├── services.add_product(sku, name, qty, repo)
        │     ├── repo.get(sku)              → None (not found = OK)
        │     ├── Product(sku, name, qty)    → domain object
        │     └── repo.add(product)          → staged in session
        └── session.commit()                 → written to DB
  └── jsonify(product) → 201
```

## Skills covered

| Skill | What you practice |
| ----- | ----------------- |
| OOP mechanics | `__repr__`, `__eq__`, `__hash__`, `@property`, `@classmethod`, `@dataclass`, entity vs value object |
| Python project structure | Modules, packages, `__init__.py`, layered separation, module dependency map (Hitchhiker's Guide Ch. 4) |
| SQLAlchemy Core | Table definitions, `insert()`, `select()`, `ResultProxy` (Essential SQLAlchemy Part I) |
| SQLAlchemy ORM | Declarative mapping, Session states, `session.add()`, `session.query()` (Essential SQLAlchemy Part II) |
| Alembic | Migration environment, autogenerate, `upgrade`/`downgrade` (Essential SQLAlchemy Part III) |
| Repository Pattern | Abstract + concrete + fake implementations; ABC and inheritance (Architecture Patterns Ch. 2) |
| Service Layer | Business logic separated from DB and HTTP (Architecture Patterns Ch. 4) |
| Unit of Work | Session-per-request, `commit`/`rollback` semantics (Architecture Patterns Ch. 6) |
| TDD | Unit tests with FakeRepository, integration tests with real DB (Architecture Patterns Ch. 5) |
| Flask integration | SQLAlchemy session scoping in a Flask app (Essential SQLAlchemy Ch. 14) |
| Python conventions | `logging`, type hints, docstrings, PEP 8, `python-dotenv` (Hitchhiker's Guide Ch. 4) |

## Tools & dependencies

| Tool | Version | Purpose | Install |
| ---- | ------- | ------- | ------- |
| SQLAlchemy | 2.x | ORM + Core SQL | `pip install sqlalchemy` |
| Alembic | 1.x | Schema migrations | `pip install alembic` |
| Flask | 3.x | REST API entrypoint | `pip install flask` |
| python-dotenv | latest | Env var management | `pip install python-dotenv` |
| pytest | latest | Test runner | `pip install pytest` |
| SQLite | built-in | Dev + test database | no install needed |

## Prerequisites

- Python 3.10+
- Basic SQL (SELECT, INSERT, UPDATE, transactions)
- Basic Python OOP (classes, inheritance, `__init__`)

---

## Session Plan — 2 hours

> Mentor pace: max 5–6 exchanges per step. Issues are batched. Move on as soon as mastery is demonstrated.

| Block | Time | Scope |
| ----- | ---- | ----- |
| A | 0:00–0:25 | Step 1 — OOP + domain model: dunder methods, properties, classmethods, unit tests |
| B | 0:25–0:50 | Step 2 — SQLAlchemy ORM: mapping, session, Core vs ORM |
| C | 0:50–1:05 | Step 3 — Alembic migrations |
| D | 1:05–1:25 | Step 4 — Repository pattern + integration tests |
| E | 1:25–1:45 | Step 5 — Service layer + unit tests with FakeRepository |
| F | 1:45–1:58 | Step 6 — Flask REST API adapter |
| G | 1:58–2:00 | Step 7 — Standards: logging, PEP 8, final verify |

---

## Step-by-step tutorial

### Step 1: OOP + Domain Model

**Goal:** Define the core business objects as pure Python — no SQLAlchemy, no Flask imports. Use this step to practice the OOP mechanics that the rest of the project depends on.

**Key OOP concepts covered here:**

| Concept | Where it appears | Why it matters |
| ------- | ---------------- | -------------- |
| `__init__` | `Product.__init__` | Constructor with validation — guard clauses run at creation time |
| `__repr__` | `Product.__repr__` | Controls what you see in the REPL and test failure output |
| `__eq__` + `__hash__` | `Product` | Required to store `Product` in a `set` (used by `FakeRepository`) |
| `@property` | `Product.is_low_stock` | Computed attribute — reads like a field, acts like a method |
| `@classmethod` | `Product.from_dict` | Alternative constructor — builds an object from a different input shape |
| `@dataclass` | `StockMovement` | Value object shorthand — `__init__`, `__repr__`, `__eq__` auto-generated |
| **Entity vs value object** | `Product` vs `StockMovement` | Entity has lasting identity; value object is defined only by its data |

**Domain rule:** the domain layer imports nothing from outside the standard library. No SQLAlchemy, no Flask, no third-party packages.

**Project structure to create:**
```
src/
├── domain/
│   ├── __init__.py
│   └── model.py
├── adapters/
│   ├── __init__.py
│   ├── orm.py
│   └── repository.py
├── service_layer/
│   ├── __init__.py
│   └── services.py
├── entrypoints/
│   ├── __init__.py
│   └── flask_app.py
└── config.py
tests/
├── unit/
│   ├── test_domain.py
│   └── test_services.py
└── integration/
    └── test_repository.py
migrations/
.env
requirements.txt
```

**Deliverable:** `src/domain/model.py`

```python
# src/domain/model.py — pure Python, zero imports outside stdlib
from __future__ import annotations
from dataclasses import dataclass, field
from datetime import datetime
from typing import List


@dataclass
class StockMovement:
    """Value object: describes a single stock event. Identity comes from its data, not an id."""
    quantity: int    # positive = stock in, negative = stock out
    reason: str
    timestamp: datetime = field(default_factory=datetime.utcnow)


class Product:
    """Entity: has a persistent identity (sku). Business rules live here, not in the DB layer."""

    LOW_STOCK_THRESHOLD = 10

    def __init__(self, sku: str, name: str, quantity: int = 0) -> None:
        if quantity < 0:
            raise ValueError("Initial quantity cannot be negative")
        self.sku = sku
        self.name = name
        self.quantity = quantity
        self.movements: List[StockMovement] = []

    # ── dunder methods ────────────────────────────────────────────────────────

    def __repr__(self) -> str:
        return f"Product(sku={self.sku!r}, name={self.name!r}, qty={self.quantity})"

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Product):
            return NotImplemented
        return self.sku == other.sku   # identity by SKU, not memory address

    def __hash__(self) -> int:
        return hash(self.sku)          # needed to store Product in a set or dict key

    # ── computed properties ───────────────────────────────────────────────────

    @property
    def is_low_stock(self) -> bool:
        """True when quantity is below the reorder threshold."""
        return self.quantity < self.LOW_STOCK_THRESHOLD

    # ── alternative constructors ──────────────────────────────────────────────

    @classmethod
    def from_dict(cls, data: dict) -> Product:
        """Build a Product from a raw dict (e.g. a JSON payload or a DB row)."""
        return cls(
            sku=data["sku"],
            name=data["name"],
            quantity=data.get("quantity", 0),
        )

    # ── business behaviour ────────────────────────────────────────────────────

    def adjust(self, quantity: int, reason: str) -> None:
        """Apply a stock movement. Raises ValueError if stock would go negative."""
        if self.quantity + quantity < 0:
            raise ValueError(
                f"Insufficient stock: have {self.quantity}, adjusting by {quantity}"
            )
        self.quantity += quantity
        self.movements.append(StockMovement(quantity=quantity, reason=reason))
```

**Write the unit tests first** (before the ORM). Create `tests/unit/test_domain.py`:

```python
import pytest
from src.domain.model import Product


def test_repr_shows_sku_and_quantity():
    p = Product(sku="SKU-001", name="Widget", quantity=5)
    assert "SKU-001" in repr(p)
    assert "5" in repr(p)


def test_equality_is_by_sku():
    a = Product(sku="SKU-001", name="Widget", quantity=10)
    b = Product(sku="SKU-001", name="Widget", quantity=99)  # different quantity
    assert a == b                                            # same SKU → equal


def test_products_are_hashable_and_can_live_in_a_set():
    a = Product(sku="SKU-001", name="Widget")
    b = Product(sku="SKU-002", name="Gadget")
    collection = {a, b}
    assert len(collection) == 2


def test_is_low_stock_true_below_threshold():
    p = Product(sku="SKU-001", name="Widget", quantity=5)
    assert p.is_low_stock is True


def test_is_low_stock_false_at_threshold():
    p = Product(sku="SKU-001", name="Widget", quantity=10)
    assert p.is_low_stock is False


def test_from_dict_builds_product():
    p = Product.from_dict({"sku": "SKU-001", "name": "Widget", "quantity": 20})
    assert p.sku == "SKU-001"
    assert p.quantity == 20


def test_adjust_increases_stock():
    p = Product(sku="SKU-001", name="Widget", quantity=10)
    p.adjust(5, "restock")
    assert p.quantity == 15
    assert len(p.movements) == 1


def test_adjust_below_zero_raises():
    p = Product(sku="SKU-001", name="Widget", quantity=3)
    with pytest.raises(ValueError, match="Insufficient stock"):
        p.adjust(-5, "sale")


def test_negative_initial_quantity_raises():
    with pytest.raises(ValueError):
        Product(sku="SKU-001", name="Widget", quantity=-1)
```

**Verify:**
```bash
pytest tests/unit/test_domain.py -v
# Expected: 9 passed
```

---

### Step 2: SQLAlchemy ORM — Mapping Tables to the Domain

**Goal:** Define the database schema using SQLAlchemy and map it to the domain model **without modifying domain/model.py**. The ORM depends on the domain, not the other way around.

**Key concepts:**
- **SQLAlchemy Core** — SQL expression language; you write `select(products).where(...)` instead of raw strings. Gives parameterized queries for free.
- **SQLAlchemy ORM** — adds object mapping on top of Core. You work with Python objects; SQLAlchemy generates SQL.
- **Inverted dependency (from Architecture Patterns Ch. 2):** "Normal" way couples ORM classes to the model. The cleaner way defines tables separately and uses `mapper_registry.map_imperatively()` to connect them — the domain class stays pure.
- **Session** — the unit of work. Tracks which objects are `transient` → `pending` → `persistent` → `detached`. Never share sessions across requests.

**Deliverable:** `src/adapters/orm.py` with table definitions and imperative mapping.

```python
# src/adapters/orm.py
import logging
from sqlalchemy import (
    Table, Column, Integer, String, DateTime, ForeignKey, MetaData,
)
from sqlalchemy.orm import registry, relationship
from src.domain.model import Product, StockMovement

logger = logging.getLogger(__name__)
mapper_registry = registry()
metadata = mapper_registry.metadata

products = Table(
    "products",
    metadata,
    Column("id", Integer, primary_key=True, autoincrement=True),
    Column("sku", String(50), unique=True, nullable=False),
    Column("name", String(200), nullable=False),
    Column("quantity", Integer, nullable=False, default=0),
)

stock_movements = Table(
    "stock_movements",
    metadata,
    Column("id", Integer, primary_key=True, autoincrement=True),
    Column("product_id", Integer, ForeignKey("products.id"), nullable=False),
    Column("quantity", Integer, nullable=False),
    Column("reason", String(200), nullable=False),
    Column("timestamp", DateTime, nullable=False),
)


def start_mappers() -> None:
    """Map ORM tables to domain classes. Call once at startup."""
    if mapper_registry.mappers:
        return
    movements_mapper = mapper_registry.map_imperatively(StockMovement, stock_movements)
    mapper_registry.map_imperatively(
        Product,
        products,
        properties={"movements": relationship(movements_mapper)},
    )
    logger.info("ORM mappers configured")
```

**Verify (interactive):**
```bash
python3 -c "
from sqlalchemy import create_engine
from src.adapters.orm import start_mappers, metadata

start_mappers()
engine = create_engine('sqlite:///test.db', echo=True)
metadata.create_all(engine)
print('Tables created:', metadata.tables.keys())
"
# Expected: dict_keys(['products', 'stock_movements'])
```

**Concept check before moving on:** What is the difference between `session.add(product)` and `session.commit()`? What happens if the process crashes between the two?

---

### Step 3: Alembic Migrations

**Goal:** Set up Alembic so schema changes are versioned and reproducible — never apply DDL by hand or call `metadata.create_all()` in production.

**Key concepts:**
- `create_all()` is for development only — it has no history and cannot roll back
- Alembic tracks schema state in a `alembic_version` table; each migration has an `upgrade` and `downgrade`
- `--autogenerate` compares your ORM metadata to the live DB and generates the diff — always review before applying
- **Never** edit a migration that has already been applied in any environment

**Setup:**
```bash
alembic init migrations
```

Edit `migrations/env.py` — replace the `target_metadata = None` line:
```python
from src.adapters.orm import metadata
target_metadata = metadata
```

Edit `alembic.ini` — set the DB URL:
```ini
sqlalchemy.url = sqlite:///inventory.db
```

**Generate and apply the first migration:**
```bash
alembic revision --autogenerate -m "create products and stock_movements tables"
alembic upgrade head
```

**Verify:**
```bash
alembic current
# Expected: <revision_id> (head)

sqlite3 inventory.db ".tables"
# Expected: alembic_version  products  stock_movements
```

**Add a column (practice):** Add `category: str = ""` to `Product.__init__` and add a `Column("category", String(100), nullable=False, server_default="")` to the `products` table in `orm.py`. Then:
```bash
alembic revision --autogenerate -m "add category to products"
alembic upgrade head
```

---

### Step 4: Repository Pattern

**Goal:** Create an abstract repository that defines the interface, a SQLAlchemy implementation, and a fake implementation for tests. The service layer will only ever see the abstract interface.

**Key concepts (Architecture Patterns Ch. 2):**
- The Repository is the only place that knows SQLAlchemy exists
- `AbstractRepository` defines the contract — `add(product)`, `get(sku)`
- `SqlAlchemyRepository` implements it using `session.add()` and `session.query()`
- `FakeRepository` implements it with a plain Python `set` — enables unit tests with zero DB
- "One aggregate = one repository" — don't build a repository per table

**Deliverable:** `src/adapters/repository.py`

```python
# src/adapters/repository.py
import abc
from typing import Optional
from sqlalchemy.orm import Session
from src.domain.model import Product


class AbstractRepository(abc.ABC):
    @abc.abstractmethod
    def add(self, product: Product) -> None: ...

    @abc.abstractmethod
    def get(self, sku: str) -> Optional[Product]: ...

    @abc.abstractmethod
    def list(self) -> list[Product]: ...


class SqlAlchemyRepository(AbstractRepository):
    def __init__(self, session: Session) -> None:
        self._session = session

    def add(self, product: Product) -> None:
        self._session.add(product)

    def get(self, sku: str) -> Optional[Product]:
        return self._session.query(Product).filter_by(sku=sku).first()

    def list(self) -> list[Product]:
        return self._session.query(Product).all()


class FakeRepository(AbstractRepository):
    def __init__(self, products: list[Product] | None = None) -> None:
        self._products: set[Product] = set(products or [])

    def add(self, product: Product) -> None:
        self._products.add(product)

    def get(self, sku: str) -> Optional[Product]:
        return next((p for p in self._products if p.sku == sku), None)

    def list(self) -> list[Product]:
        return list(self._products)
```

**Integration test** — `tests/integration/test_repository.py`:
```python
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from src.adapters.orm import start_mappers, metadata
from src.adapters.repository import SqlAlchemyRepository
from src.domain.model import Product


@pytest.fixture
def session():
    engine = create_engine("sqlite:///:memory:")
    start_mappers()
    metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    yield Session()


def test_repository_can_save_and_retrieve_product(session):
    repo = SqlAlchemyRepository(session)
    product = Product(sku="SKU-001", name="Widget", quantity=10)
    repo.add(product)
    session.commit()

    retrieved = repo.get("SKU-001")
    assert retrieved.name == "Widget"
    assert retrieved.quantity == 10


def test_repository_persists_stock_movements(session):
    repo = SqlAlchemyRepository(session)
    product = Product(sku="SKU-002", name="Gadget", quantity=5)
    product.adjust(3, "restock")
    repo.add(product)
    session.commit()

    retrieved = repo.get("SKU-002")
    assert len(retrieved.movements) == 1
    assert retrieved.movements[0].quantity == 3
```

**Verify:**
```bash
pytest tests/integration/test_repository.py -v
# Expected: 2 passed
```

---

### Step 5: Service Layer

**Goal:** Write the business orchestration layer. Service functions take a repository and primitive arguments — no SQLAlchemy, no Flask, no HTTP concepts.

**Key concepts (Architecture Patterns Ch. 4):**
- Service functions are the public API of your application — not Flask routes
- They receive a repository (not a session) — this is the key to testability
- Unit tests use `FakeRepository` and run in microseconds, with no DB
- Service functions raise domain exceptions; the HTTP layer translates them to status codes

**Deliverable:** `src/service_layer/services.py`

```python
# src/service_layer/services.py
import logging
from src.adapters.repository import AbstractRepository
from src.domain.model import Product

logger = logging.getLogger(__name__)


class ProductNotFound(Exception):
    pass


class DuplicateSku(Exception):
    pass


def add_product(sku: str, name: str, quantity: int, repo: AbstractRepository) -> Product:
    """Create a new product. Raises DuplicateSku if the SKU already exists."""
    if repo.get(sku) is not None:
        raise DuplicateSku(f"Product with SKU '{sku}' already exists")
    product = Product(sku=sku, name=name, quantity=quantity)
    repo.add(product)
    logger.info("Added product %s (%s)", sku, name)
    return product


def adjust_stock(sku: str, quantity: int, reason: str, repo: AbstractRepository) -> Product:
    """Apply a stock movement to a product. Raises ProductNotFound or ValueError."""
    product = repo.get(sku)
    if product is None:
        raise ProductNotFound(f"No product with SKU '{sku}'")
    product.adjust(quantity, reason)
    logger.info("Adjusted stock for %s by %d (%s)", sku, quantity, reason)
    return product


def get_product(sku: str, repo: AbstractRepository) -> Product:
    product = repo.get(sku)
    if product is None:
        raise ProductNotFound(f"No product with SKU '{sku}'")
    return product


def list_products(repo: AbstractRepository) -> list[Product]:
    return repo.list()
```

**Unit tests** — `tests/unit/test_services.py`:
```python
import pytest
from src.adapters.repository import FakeRepository
from src.domain.model import Product
from src.service_layer import services


def test_add_product_creates_and_stores():
    repo = FakeRepository()
    product = services.add_product("SKU-001", "Widget", 10, repo)
    assert repo.get("SKU-001") is product


def test_add_product_raises_on_duplicate_sku():
    repo = FakeRepository([Product(sku="SKU-001", name="Widget")])
    with pytest.raises(services.DuplicateSku):
        services.add_product("SKU-001", "Other", 0, repo)


def test_adjust_stock_updates_quantity():
    repo = FakeRepository([Product(sku="SKU-001", name="Widget", quantity=10)])
    product = services.adjust_stock("SKU-001", -3, "sale", repo)
    assert product.quantity == 7


def test_adjust_stock_raises_on_unknown_sku():
    repo = FakeRepository()
    with pytest.raises(services.ProductNotFound):
        services.adjust_stock("UNKNOWN", -1, "sale", repo)
```

**Verify:**
```bash
pytest tests/unit/test_services.py -v
# Expected: 4 passed — all run without touching the DB
```

---

### Step 6: Flask REST API

**Goal:** Wire a Flask app as a thin adapter over the service layer. Routes translate HTTP → service call → HTTP response. Zero business logic in routes.

**Key concepts:**
- Each request gets its own session, committed on success, rolled back on exception
- Service exceptions map to HTTP status codes: `ProductNotFound` → 404, `DuplicateSku` → 409, `ValueError` → 400
- Flask integration with SQLAlchemy uses `scoped_session` — session lifecycle tied to the request thread

**Deliverable:** `src/entrypoints/flask_app.py`

```python
# src/entrypoints/flask_app.py
import logging
from flask import Flask, jsonify, request
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, scoped_session
from src.adapters.orm import start_mappers
from src.adapters.repository import SqlAlchemyRepository
from src.service_layer import services

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

start_mappers()

app = Flask(__name__)
engine = create_engine("sqlite:///inventory.db")
Session = scoped_session(sessionmaker(bind=engine))


@app.teardown_appcontext
def remove_session(exc: Exception | None = None) -> None:
    Session.remove()


@app.post("/products")
def create_product():
    data = request.get_json()
    session = Session()
    repo = SqlAlchemyRepository(session)
    try:
        product = services.add_product(
            sku=data["sku"], name=data["name"],
            quantity=data.get("quantity", 0), repo=repo,
        )
        session.commit()
        return jsonify({"sku": product.sku, "name": product.name, "quantity": product.quantity}), 201
    except services.DuplicateSku as e:
        session.rollback()
        return jsonify({"error": str(e)}), 409
    except (ValueError, KeyError) as e:
        session.rollback()
        return jsonify({"error": str(e)}), 400


@app.patch("/products/<sku>/stock")
def adjust_stock(sku: str):
    data = request.get_json()
    session = Session()
    repo = SqlAlchemyRepository(session)
    try:
        product = services.adjust_stock(
            sku=sku, quantity=data["quantity"],
            reason=data.get("reason", ""), repo=repo,
        )
        session.commit()
        return jsonify({"sku": product.sku, "quantity": product.quantity})
    except services.ProductNotFound as e:
        session.rollback()
        return jsonify({"error": str(e)}), 404
    except (ValueError, KeyError) as e:
        session.rollback()
        return jsonify({"error": str(e)}), 400


@app.get("/products")
def list_products():
    session = Session()
    repo = SqlAlchemyRepository(session)
    products = services.list_products(repo)
    return jsonify([
        {"sku": p.sku, "name": p.name, "quantity": p.quantity}
        for p in products
    ])


@app.get("/products/<sku>")
def get_product(sku: str):
    session = Session()
    repo = SqlAlchemyRepository(session)
    try:
        product = services.get_product(sku, repo)
        return jsonify({"sku": product.sku, "name": product.name, "quantity": product.quantity,
                        "movements": [{"quantity": m.quantity, "reason": m.reason} for m in product.movements]})
    except services.ProductNotFound as e:
        return jsonify({"error": str(e)}), 404
```

**Verify:**
```bash
flask --app src.entrypoints.flask_app run --debug

# In a second terminal:
curl -X POST http://localhost:5000/products \
  -H "Content-Type: application/json" \
  -d '{"sku": "SKU-001", "name": "Widget", "quantity": 100}'
# Expected: {"name":"Widget","quantity":100,"sku":"SKU-001"} 201

curl -X PATCH http://localhost:5000/products/SKU-001/stock \
  -H "Content-Type: application/json" \
  -d '{"quantity": -25, "reason": "sale"}'
# Expected: {"quantity":75,"sku":"SKU-001"} 200

curl http://localhost:5000/products/SKU-001
# Expected: product with movements array showing the -25 adjustment
```

---

### Step 7: Standards Check

**Goal:** Verify the codebase meets the conventions from Hitchhiker's Guide Ch. 4.

**Checklist:**
- [ ] `logging` used everywhere — no `print()` in src/
- [ ] Type hints on all public function signatures
- [ ] Docstrings on all public functions in service_layer/ and adapters/
- [ ] `requirements.txt` pinned (`pip freeze > requirements.txt`)
- [ ] `.env` used for DB URL — not hardcoded in source
- [ ] PEP 8: run `pip install flake8 && flake8 src/ tests/`
- [ ] All tests pass: `pytest tests/ -v`

**Final verify:**
```bash
pip install flake8
flake8 src/ tests/ --max-line-length=100
pytest tests/ -v
# Expected: flake8 clean, all tests pass
```

---

## Testing

```bash
# Unit tests only (no DB, milliseconds)
pytest tests/unit/ -v

# Integration tests (SQLite in-memory)
pytest tests/integration/ -v

# Full suite with coverage
pip install pytest-cov
pytest tests/ -v --cov=src --cov-report=term-missing
```

## Deployment

- **Dev:** `flask --app src.entrypoints.flask_app run --debug` with `inventory.db` (SQLite)
- **Prod:** swap `create_engine("sqlite:///...")` for `create_engine(os.getenv("DATABASE_URL"))` pointing at PostgreSQL; run `alembic upgrade head` before deploying

## Resources

1. [Essential SQLAlchemy (O'Reilly)](docs/vdoc.pub_essential-sqlalchemy-mapping-python-to-databases.pdf) — Core, ORM, Alembic, Flask integration
2. [Architecture Patterns with Python (O'Reilly)](docs/Architecture-Patterns-with-Python.pdf) — Repository, Service Layer, Unit of Work, DI
3. [The Hitchhiker's Guide to Python (O'Reilly)](docs/000_The%20Hitchhiker%27s%20Guide%20to%20Python.pdf) — project structure, conventions, testing, logging
4. [SQLAlchemy 2.x docs](https://docs.sqlalchemy.org/en/20/) — ORM quick start, session API
5. [Alembic docs](https://alembic.sqlalchemy.org/en/latest/) — `autogenerate`, `upgrade`/`downgrade`, `env.py` config

## Skill coverage mapping

| Step | Primary source |
| ---- | -------------- |
| 1 | Hitchhiker's Ch. 4 (OOP idioms, conventions) + Architecture Patterns Ch. 1 (Domain Modeling) |
| 2 | Essential SQLAlchemy Part II (ORM) + Architecture Patterns Ch. 2 (inverted dependency) |
| 3 | Essential SQLAlchemy Part III (Alembic) |
| 4 | Architecture Patterns Ch. 2 (Repository Pattern) — ABC + inheritance in practice |
| 5 | Architecture Patterns Ch. 4 (Service Layer) + Ch. 5 (TDD) |
| 6 | Essential SQLAlchemy Ch. 14 (Flask integration) + Architecture Patterns Ch. 4 |
| 7 | Hitchhiker's Guide Ch. 4 (conventions, logging, testing) |
