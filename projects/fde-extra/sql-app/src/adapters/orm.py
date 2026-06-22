import logging
from sqlalchemy import Table, Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import registry, relationship
from src.domain.model import Product, StockMovement

logger = logging.getLogger(__name__)

# registry holds the mapping metadata and the imperative mapper
mapper_registry = registry()
metadata = mapper_registry.metadata

# ── Table definitions (SQLAlchemy Core) ──────────────────────────────────────
# These define the schema. They know nothing about the domain classes yet.

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


# ── Imperative mapping ────────────────────────────────────────────────────────
# This is called once at startup. It tells SQLAlchemy which Python class maps
# to which table — without touching the domain class itself.

def start_mappers() -> None:
    """Map ORM tables to domain classes. Call once at startup."""
    if mapper_registry.mappers:
        return  # guard against being called twice (e.g. in tests)
    movements_mapper = mapper_registry.map_imperatively(StockMovement, stock_movements)
    mapper_registry.map_imperatively(
        Product,
        products,
        properties={"movements": relationship(movements_mapper)},
        # relationship() wires Product.movements → stock_movements via product_id FK
    )
    logger.info("ORM mappers configured")
