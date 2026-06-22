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
    assert len({a, b}) == 2


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
