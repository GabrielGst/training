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
