from __future__ import annotations
from dataclasses import dataclass, field
from datetime import datetime
from typing import List


@dataclass
class StockMovement:
    """Value object: a single stock event. Identity comes from its data, not an id."""
    quantity: int   # positive = stock in, negative = stock out
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

    def __repr__(self) -> str:
        return f"Product(sku={self.sku!r}, name={self.name!r}, qty={self.quantity})"

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Product):
            return NotImplemented
        return self.sku == other.sku   # identity by business key, not memory address

    def __hash__(self) -> int:
        return hash(self.sku)          # required: defining __eq__ silences __hash__ in Python 3

    @property
    def is_low_stock(self) -> bool:
        """True when quantity is below the reorder threshold."""
        return self.quantity < self.LOW_STOCK_THRESHOLD

    @classmethod
    def from_dict(cls, data: dict) -> Product:
        """Build a Product from a raw dict (e.g. a JSON payload or a DB row)."""
        return cls(
            sku=data["sku"],
            name=data["name"],
            quantity=data.get("quantity", 0),
        )

    def adjust(self, quantity: int, reason: str) -> None:
        """Apply a stock movement. Raises ValueError if stock would go negative."""
        if self.quantity + quantity < 0:
            raise ValueError(
                f"Insufficient stock: have {self.quantity}, adjusting by {quantity}"
            )
        self.quantity += quantity
        self.movements.append(StockMovement(quantity=quantity, reason=reason))
