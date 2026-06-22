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
    """Apply a stock movement. Raises ProductNotFound or ValueError."""
    product = repo.get(sku)
    if product is None:
        raise ProductNotFound(f"No product with SKU '{sku}'")
    product.adjust(quantity, reason)
    logger.info("Adjusted stock for %s by %d (%s)", sku, quantity, reason)
    return product


def get_product(sku: str, repo: AbstractRepository) -> Product:
    """Fetch a single product. Raises ProductNotFound if missing."""
    product = repo.get(sku)
    if product is None:
        raise ProductNotFound(f"No product with SKU '{sku}'")
    return product


def list_products(repo: AbstractRepository) -> list[Product]:
    return repo.list()
