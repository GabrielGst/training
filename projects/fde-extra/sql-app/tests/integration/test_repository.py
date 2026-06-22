import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from src.adapters.orm import start_mappers, metadata
from src.adapters.repository import SqlAlchemyRepository
from src.domain.model import Product


@pytest.fixture
def session():
    engine = create_engine("sqlite:///:memory:")  # in-memory DB, gone after test
    start_mappers()
    metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    yield Session()


def test_repository_can_save_and_retrieve_product(session):
    repo = SqlAlchemyRepository(session)
    product = Product(sku="SKU-001", name="Widget", quantity=10)
    repo.add(product)
    session.commit()                        # transaction committed — now on disk

    retrieved = repo.get("SKU-001")
    assert retrieved.name == "Widget"
    assert retrieved.quantity == 10


def test_repository_persists_stock_movements(session):
    repo = SqlAlchemyRepository(session)
    product = Product(sku="SKU-002", name="Gadget", quantity=5)
    product.adjust(3, "restock")           # records a StockMovement
    repo.add(product)
    session.commit()

    retrieved = repo.get("SKU-002")
    assert len(retrieved.movements) == 1
    assert retrieved.movements[0].quantity == 3
