import abc
from typing import Optional
from sqlalchemy.orm import Session
from src.domain.model import Product


class AbstractRepository(abc.ABC):
    """Defines the interface every repository must implement.
    The service layer depends on this — never on a concrete implementation."""

    @abc.abstractmethod
    def add(self, product: Product) -> None: ...

    @abc.abstractmethod
    def get(self, sku: str) -> Optional[Product]: ...

    @abc.abstractmethod
    def list(self) -> list[Product]: ...


class SqlAlchemyRepository(AbstractRepository):
    """Real implementation — talks to the DB through a SQLAlchemy session."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def add(self, product: Product) -> None:
        self._session.add(product)          # stages in transaction — not written yet

    def get(self, sku: str) -> Optional[Product]:
        return self._session.query(Product).filter_by(sku=sku).first()

    def list(self) -> list[Product]:
        return self._session.query(Product).all()


class FakeRepository(AbstractRepository):
    """In-memory implementation for unit tests — no DB required."""

    def __init__(self, products: list[Product] | None = None) -> None:
        self._products: set[Product] = set(products or [])

    def add(self, product: Product) -> None:
        self._products.add(product)         # Product.__hash__ makes this work

    def get(self, sku: str) -> Optional[Product]:
        return next((p for p in self._products if p.sku == sku), None)

    def list(self) -> list[Product]:
        return list(self._products)
