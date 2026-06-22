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
Session = scoped_session(sessionmaker(bind=engine))  # one session per request thread


@app.teardown_appcontext
def remove_session(exc: Exception | None = None) -> None:
    Session.remove()  # closes the session (and its transaction) at end of request


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
        return jsonify({"sku": product.sku, "name": product.name, "quantity": product.quantity}), 201  # noqa: E501
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
    return jsonify([{"sku": p.sku, "name": p.name, "quantity": p.quantity} for p in products])


@app.get("/products/<sku>")
def get_product(sku: str):
    session = Session()
    repo = SqlAlchemyRepository(session)
    try:
        product = services.get_product(sku, repo)
        return jsonify({
            "sku": product.sku, "name": product.name, "quantity": product.quantity,
            "movements": [{"quantity": m.quantity, "reason": m.reason} for m in product.movements],
        })
    except services.ProductNotFound as e:
        return jsonify({"error": str(e)}), 404
