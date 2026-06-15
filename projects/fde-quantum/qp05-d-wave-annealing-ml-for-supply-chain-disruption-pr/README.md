# QP05 — D-Wave Annealing + ML for Supply Chain Disruption Prediction

**Modality:** annealing (D-Wave / Ocean SDK) **Phase:** 2E **Track:** `fde-quantum` **Status:** not started **Hours target:** 40

## Business Problem

Supply chain disruptions — port closures, supplier insolvencies, geopolitical shocks — cost enterprises over $1 billion per year in unplanned delays and emergency procurement. Classical ML models predict disruption probability well, but cannot simultaneously optimise the combinatorial re-routing problem: which alternative suppliers to activate, which logistics corridors to redirect, and how to minimise total cost while respecting capacity constraints.

A hybrid solution is required. Classical ML (fed by real-time news and historical data) produces disruption probability scores. A quantum annealer then solves the combinatorial supplier-route optimisation — expressed as a QUBO — that is infeasible for exact solvers at enterprise scale. A LangChain RAG pipeline over disruption news provides the situational awareness layer that feeds both the ML model and a human-readable explanation of the recommendation.

## What You Will Build

A production-grade supply chain risk API that:

1. Ingests disruption news via a LangChain + LlamaIndex RAG pipeline backed by Qdrant vector store.
2. Runs a JAX disruption probability model on structured supplier features.
3. Formulates supplier-route re-optimisation as a Constrained Quadratic Model (CQM) using Ocean SDK.
4. Submits the CQM to D-Wave Leap's hybrid cloud solver.
5. Post-processes the annealing sample set to extract the lowest-energy feasible route.
6. Exposes a FastAPI `/risk-score` endpoint returning risk level and recommended re-routing.
7. Persists job results to PostgreSQL and runs inside Docker with GitHub Actions CI.

## Architecture

```
                    ┌──────────────────────────────────────────┐
                    │             FastAPI Service               │
                    │         POST /risk-score                  │
                    └────────────────┬─────────────────────────┘
                                     │
         ┌───────────────────────────▼──────────────────────────────┐
         │                  Orchestration Layer                      │
         │                                                           │
┌────────▼──────────┐                          ┌────────────────────▼──┐
│    RAG Pipeline    │                          │   QUBO Formulation    │
│  LangChain +       │                          │   Ocean SDK CQM       │
│  LlamaIndex +      │──disruption severity──►  │   → D-Wave Leap       │
│  Qdrant (vector DB)│                          │   Hybrid CQM Solver   │
└────────┬──────────┘                          └────────────┬──────────┘
         │                                                   │
┌────────▼──────────┐                          ┌────────────▼──────────┐
│  Disruption Score  │                          │  Sample Set Analysis  │
│  JAX ensemble      │                          │  (lowest-energy       │
│  model             │                          │   feasible route)     │
└────────┬──────────┘                          └────────────┬──────────┘
         │                                                   │
         └──────────────────────┬────────────────────────────┘
                                │
                   ┌────────────▼───────────┐
                   │       PostgreSQL        │
                   │  (job results,          │
                   │   audit log,            │
                   │   supplier graph)       │
                   └────────────────────────┘
```

## Theory Prerequisites

| Skill ID | Concept | Why you need it |
|----------|---------|-----------------|
| SK01 | Quantum State Representation — Hilbert Spaces & Bra-Ket Notation | Foundation for understanding how annealer encodes binary variables as spin states |
| SK02 | Quantum Measurement Theory — Born Rule | Interpret annealing sample probabilities and energy distributions correctly |
| SK29 | Real-Time Inference Acceleration & Latency Optimisation | Meeting sub-100ms SLA for the FastAPI risk endpoint and ONNX model caching |
| SK30 | QUBO & Ising Model Formulation | Core skill — encoding supplier-route constraints as binary quadratic cost functions with penalty terms |
| SK31 | Spin Glass Physics & Adiabatic Evolution | Understanding why certain problem structures are hard for annealers and how energy landscape topology affects solution quality |
| SK32 | Adiabatic Theorem & Quantum Tunnelling | Theoretical grounding for when the annealer will find the ground state and how to tune annealing schedules |

## Engineering Skills Covered

| Skill ID | Skill | What you practice |
|----------|-------|------------------|
| SK42 | Prompt Engineering & Chain-of-Thought Reasoning | Designing prompts that extract structured disruption events from raw news text |
| SK43 | Retrieval-Augmented Generation (RAG) Architecture | Indexing historical disruption reports into Qdrant, retrieving context for LLM reasoning |
| SK44 | LLM Output Parsing & Safety | Parsing Mistral disruption assessments into validated Pydantic schemas with guardrails |
| SK45 | Semantic Search & Vector Embeddings | Embedding disruption news with sentence-transformers, cosine similarity retrieval from Qdrant |
| SK46 | NIST PQC Standards — awareness | Understanding cryptographic threats relevant to supply chain data in transit |
| SK47 | Cryptographic Protocol Design — awareness | Secure transport patterns for sensitive supplier and route data |
| SK24 | ML for Quantum Error Mitigation | Applying post-processing to filter noisy annealing samples and estimate solution quality |
| SK25 | Hybrid Classical-Quantum Loops & Orchestration | Orchestrating the classical ML → QUBO → annealer → post-process feedback loop |
| SK26 | PyTorch / JAX Production Patterns | Training and serving the disruption probability model with JAX and optax |
| SK27 | REST API Design & FastAPI | Building the production `/risk-score` endpoint with Pydantic validation |
| SK33 | SQL Data Modelling — PostgreSQL | Persisting annealing job metadata and supplier network graphs |
| SK34 | Container Orchestration — Docker | Packaging the full stack for reproducible deployment |
| SK35 | CI/CD & GitHub Actions | Automated test and lint pipeline |

## Tools & Dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| Ocean SDK (D-Wave) | QUBO/CQM formulation, sampler abstraction, D-Wave Leap submission | `pip install dwave-ocean-sdk` |
| JAX | Disruption probability model (gradient-boosted via optax) | `pip install jax[cpu]` |
| LangChain | RAG orchestration, prompt templates, LLM chains | `pip install langchain langchain-community` |
| LlamaIndex | Document ingestion and indexing pipeline for disruption reports | `pip install llama-index` |
| Qdrant | Vector store for semantic search over disruption news embeddings | `pip install qdrant-client` |
| FastAPI | REST API layer for real-time risk scoring | `pip install fastapi uvicorn` |
| PostgreSQL | Job result persistence and supplier graph storage | `pip install psycopg2-binary sqlalchemy` |
| Docker | Containerised deployment of the full stack | system install |
| GitHub Actions | CI/CD pipeline | `.github/workflows/` |
| Scikit-learn | Feature engineering and baseline ML models | `pip install scikit-learn` |
| Pydantic | Request/response validation and LLM output parsing | included with FastAPI |

## Prerequisites

**Complete these first:**
- [ ] SK30: QUBO & Ising Model Formulation — read the Ocean SDK QUBO guide and work through `dimod` examples
- [ ] SK31: Spin Glass Physics — skim D-Wave documentation on annealing schedules and energy landscapes
- [ ] SK32: Adiabatic Theorem — understand tunnelling gap and ground-state probability under time evolution
- [ ] SK42–SK45: LangChain quickstart tutorial — build a minimal RAG chain before attempting this project

**Access needed:**
- [ ] D-Wave Leap account (free tier available at `leap.dwavesys.com` — includes QPU and hybrid solver minutes)
- [ ] Mistral API key or OpenAI API key (for LLM reasoning in the RAG pipeline)
- [ ] Docker Desktop or Docker Engine installed locally

---

## Step-by-Step Tutorial

### Step 1: Environment Setup

**Goal:** Install all dependencies and validate Ocean SDK connectivity to D-Wave Leap.

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env and fill in:
#   DWAVE_API_TOKEN=...
#   MISTRAL_API_KEY=...
#   QDRANT_URL=http://localhost:6333
#   DATABASE_URL=postgresql://postgres:postgres@localhost:5432/supply_chain
```

```python
# src/check_connectivity.py
import os
from dwave.cloud import Client

def check_dwave_connection() -> dict:
    """Verify D-Wave Leap connectivity and list available solvers."""
    token = os.environ["DWAVE_API_TOKEN"]
    with Client.from_config(token=token) as client:
        solvers = client.get_solvers()
        solver_names = [s.name for s in solvers]
    return {"status": "connected", "solvers": solver_names}

if __name__ == "__main__":
    result = check_dwave_connection()
    print(result)
```

**Verify:** `python src/check_connectivity.py` prints `{"status": "connected", "solvers": [...]}` with at least one hybrid CQM solver listed (e.g., `hybrid_constrained_quadratic_model_version1`).

---

### Step 2: Theory Warm-Up — QUBO Formulation Basics

**Goal:** Encode a minimal supplier selection problem as a QUBO and solve it on the `dimod` exact solver to confirm the formulation is correct before touching the QPU.

A QUBO minimises $x^T Q x$ where $x \in \{0,1\}^n$ are binary decision variables (e.g., "activate supplier $i$?") and $Q$ encodes both the objective (costs) and constraint penalties.

```python
# src/qubo_warmup.py
import dimod

def build_supplier_selection_qubo(
    costs: list[float],
    max_budget: float,
    penalty_strength: float = 10.0,
) -> dimod.BinaryQuadraticModel:
    """
    Select the cheapest subset of suppliers whose total cost does not exceed
    max_budget, encoded as a QUBO penalty formulation.

    Variables: x_i in {0,1} — 1 means supplier i is activated.
    Objective: minimise sum(costs[i] * x_i)
    Constraint: sum(costs[i] * x_i) <= max_budget  (soft penalty term)
    """
    n = len(costs)
    bqm = dimod.BinaryQuadraticModel(vartype="BINARY")

    # Linear terms: direct activation cost
    for i, c in enumerate(costs):
        bqm.add_variable(f"x_{i}", c)

    # Penalty for pairs that jointly exceed budget:
    # P * 2 * c_i * c_j * x_i * x_j
    for i in range(n):
        for j in range(i + 1, n):
            coupling = penalty_strength * 2.0 * costs[i] * costs[j] / (max_budget ** 2)
            bqm.add_interaction(f"x_{i}", f"x_{j}", coupling)

    return bqm


def solve_on_exact_solver(bqm: dimod.BinaryQuadraticModel) -> dict:
    """Enumerate all solutions with ExactSolver (only feasible for n <= 20)."""
    sampler = dimod.ExactSolver()
    sample_set = sampler.sample(bqm)
    best = sample_set.first
    selected = [var for var, val in best.sample.items() if val == 1]
    return {"selected_suppliers": selected, "energy": best.energy}


if __name__ == "__main__":
    costs = [120.0, 85.0, 200.0, 60.0, 95.0]
    bqm = build_supplier_selection_qubo(costs, max_budget=200.0)
    result = solve_on_exact_solver(bqm)
    print(result)
    # Expected: selects the cheapest combination below $200
```

**Verify:** The solver returns a subset with combined cost below $200. Energy is negative (objective minimised). Check that `len(selected_suppliers) >= 1`.

---

### Step 3: Problem Formulation — Supplier-Route Network as CQM

**Goal:** Model the full supplier-route network as an Ocean SDK `ConstrainedQuadraticModel` with hard capacity constraints.

```python
# src/qubo_network.py
import dimod
from dataclasses import dataclass

@dataclass
class Supplier:
    id: str
    cost: float            # unit procurement cost (USD)
    capacity: float        # units per week
    disruption_risk: float # probability [0,1] from ML model

@dataclass
class Route:
    supplier_id: str
    port_id: str
    transit_days: int
    cost_per_unit: float

def build_network_cqm(
    suppliers: list[Supplier],
    routes: list[Route],
    demand: float,
) -> dimod.ConstrainedQuadraticModel:
    """
    Build a CQM for supplier-route selection.

    Variables:
      x_{s.id}       in {0,1} — activate supplier s
      y_{s_id}_{p}   in {0,1} — use route from supplier s through port p

    Objective: minimise total weighted cost (procurement + transport * disruption_risk)
    Constraints:
      - Capacity must meet demand: sum(x_s * capacity_s) >= demand
      - Route must have active supplier: y_{s,p} <= x_s  for all (s,p)
    """
    cqm = dimod.ConstrainedQuadraticModel()

    # Create binary variables
    x = {s.id: dimod.Binary(f"x_{s.id}") for s in suppliers}
    y = {
        (r.supplier_id, r.port_id): dimod.Binary(f"y_{r.supplier_id}_{r.port_id}")
        for r in routes
    }

    # Objective: risk-weighted total cost
    risk_weighted_cost = sum(
        s.cost * (1.0 + s.disruption_risk) * x[s.id]
        for s in suppliers
    ) + sum(
        r.cost_per_unit * r.transit_days * y[(r.supplier_id, r.port_id)]
        for r in routes
    )
    cqm.set_objective(risk_weighted_cost)

    # Constraint 1: total capacity >= demand
    capacity_expr = sum(s.capacity * x[s.id] for s in suppliers)
    cqm.add_constraint(capacity_expr >= demand, label="demand_coverage")

    # Constraint 2: can only use route if supplier is active
    for r in routes:
        cqm.add_constraint(
            y[(r.supplier_id, r.port_id)] - x[r.supplier_id] <= 0,
            label=f"route_supplier_link_{r.supplier_id}_{r.port_id}",
        )

    return cqm
```

**Verify:** `cqm.constraints` has `1 + len(routes)` entries. `cqm.num_variables()` equals `len(suppliers) + len(routes)`.

---

### Step 4: D-Wave Leap Submission and Sample Retrieval

**Goal:** Submit the CQM to D-Wave Leap's hybrid solver and extract the best feasible route combination.

```python
# src/dwave_solver.py
import os
import dimod
from dwave.system import LeapHybridCQMSampler

def solve_on_leap(
    cqm: dimod.ConstrainedQuadraticModel,
    time_limit: int = 10,
) -> dict:
    """
    Submit a CQM to the D-Wave Leap hybrid solver.

    Args:
        cqm: Constrained Quadratic Model from build_network_cqm()
        time_limit: Wall-clock seconds for the hybrid solver (minimum 3)

    Returns:
        dict with selected variables, energy, feasibility, and timing
    """
    sampler = LeapHybridCQMSampler(token=os.environ["DWAVE_API_TOKEN"])
    sample_set = sampler.sample_cqm(cqm, time_limit=time_limit)

    # Filter to feasible solutions (all hard constraints satisfied)
    feasible = sample_set.filter(lambda d: d.is_feasible)

    if len(feasible) == 0:
        return {
            "status": "no_feasible_solution",
            "num_samples": len(sample_set),
            "energy": None,
        }

    best = feasible.first
    active_vars = {v: int(val) for v, val in best.sample.items() if val > 0.5}

    return {
        "status": "feasible",
        "active_variables": active_vars,
        "energy": best.energy,
        "num_feasible": len(feasible),
        "timing": sample_set.info.get("timing", {}),
    }
```

**Verify:** Job submits without `SolverNotFoundError`. Response contains `"status": "feasible"` and `active_variables` is non-empty for a well-formed small problem (2 suppliers, 3 routes, demand = 100).

---

### Step 5: RAG Pipeline — Disruption News Indexing

**Goal:** Index supply chain disruption news into Qdrant and retrieve structured disruption assessments using LangChain + Mistral.

```python
# src/rag/indexer.py
from langchain_community.document_loaders import WebBaseLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import Qdrant as LangchainQdrant
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams

COLLECTION_NAME = "disruption_news"
EMBED_MODEL = "sentence-transformers/all-MiniLM-L6-v2"
VECTOR_DIM = 384


def ensure_collection(client: QdrantClient) -> None:
    existing = {c.name for c in client.get_collections().collections}
    if COLLECTION_NAME not in existing:
        client.create_collection(
            collection_name=COLLECTION_NAME,
            vectors_config=VectorParams(size=VECTOR_DIM, distance=Distance.COSINE),
        )


def index_disruption_urls(urls: list[str], qdrant_url: str) -> int:
    """
    Load URLs, split into 512-token chunks, embed with MiniLM, upsert to Qdrant.

    Returns:
        Number of chunks indexed.
    """
    docs = WebBaseLoader(urls).load()
    chunks = RecursiveCharacterTextSplitter(
        chunk_size=512, chunk_overlap=64
    ).split_documents(docs)

    embeddings = HuggingFaceEmbeddings(model_name=EMBED_MODEL)
    client = QdrantClient(url=qdrant_url)
    ensure_collection(client)

    store = LangchainQdrant(
        client=client,
        collection_name=COLLECTION_NAME,
        embeddings=embeddings,
    )
    store.add_documents(chunks)
    return len(chunks)
```

```python
# src/rag/retriever.py
import os
from pydantic import BaseModel, Field
from langchain_community.vectorstores import Qdrant as LangchainQdrant
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.llms import MistralAI
from langchain.output_parsers import PydanticOutputParser
from langchain.prompts import PromptTemplate
from langchain.chains import RetrievalQA
from qdrant_client import QdrantClient


class DisruptionAssessment(BaseModel):
    affected_region: str = Field(description="Geographic region affected")
    disruption_type: str = Field(
        description="One of: port_closure, supplier_failure, geopolitical, weather"
    )
    severity_score: float = Field(ge=0.0, le=1.0, description="Disruption severity 0-1")
    affected_goods: list[str] = Field(description="Product categories impacted")
    recommended_action: str = Field(description="Short mitigation recommendation")


def get_disruption_assessment(query: str, qdrant_url: str) -> DisruptionAssessment:
    """
    Retrieve top-5 relevant news chunks from Qdrant, then use Mistral to produce
    a structured DisruptionAssessment via LangChain output parsing.
    """
    embeddings = HuggingFaceEmbeddings(
        model_name="sentence-transformers/all-MiniLM-L6-v2"
    )
    client = QdrantClient(url=qdrant_url)
    store = LangchainQdrant(
        client=client,
        collection_name="disruption_news",
        embeddings=embeddings,
    )
    retriever = store.as_retriever(search_kwargs={"k": 5})

    parser = PydanticOutputParser(pydantic_object=DisruptionAssessment)
    prompt = PromptTemplate(
        input_variables=["context", "question"],
        template=(
            "You are a supply chain risk analyst.\n"
            "News excerpts:\n{context}\n\n"
            "Query: {question}\n\n"
            "Return JSON:\n{format_instructions}"
        ),
        partial_variables={"format_instructions": parser.get_format_instructions()},
    )

    llm = MistralAI(
        model="mistral-small",
        api_key=os.environ["MISTRAL_API_KEY"],
        temperature=0.0,
    )
    chain = RetrievalQA.from_chain_type(
        llm=llm,
        retriever=retriever,
        chain_type_kwargs={"prompt": prompt},
    )
    raw = chain.run(query)
    return parser.parse(raw)
```

**Verify:** After indexing at least 3 URLs, `get_disruption_assessment("Suez Canal closure impact on semiconductor supply", qdrant_url)` returns a `DisruptionAssessment` with `severity_score` in [0,1] and `disruption_type` matching one of the allowed values.

---

### Step 6: Classical ML — Disruption Probability Model with JAX

**Goal:** Train a two-layer JAX MLP on structured supplier features to produce a disruption probability score that feeds QUBO penalty weights.

```python
# src/ml/disruption_model.py
from dataclasses import dataclass
import jax
import jax.numpy as jnp
import optax
import numpy as np


@dataclass
class DisruptionFeatures:
    news_severity_score: float       # from RAG assessment [0,1]
    port_congestion_index: float     # external data feed [0,1]
    supplier_financial_health: float # 0=distressed, 1=healthy
    geopolitical_risk_index: float   # regional risk index [0,1]
    days_since_last_disruption: int  # recency feature


FEATURE_DIM = 5


def init_params(key: jax.Array, hidden: int = 16) -> tuple:
    k1, k2 = jax.random.split(key)
    return (
        jax.random.normal(k1, (FEATURE_DIM, hidden)) * 0.1,  # W1
        jnp.zeros(hidden),                                     # b1
        jax.random.normal(k2, (hidden, 1)) * 0.1,             # W2
        jnp.zeros(1),                                          # b2
    )


def forward(params, x: jax.Array) -> jax.Array:
    """Single-sample forward pass returning disruption probability in (0,1)."""
    w1, b1, w2, b2 = params
    h = jax.nn.relu(x @ w1 + b1)
    return jax.nn.sigmoid((h @ w2 + b2)).squeeze()


def train(
    X: np.ndarray,
    y: np.ndarray,
    epochs: int = 300,
    lr: float = 1e-3,
) -> tuple:
    """
    Train the disruption probability model.

    Args:
        X: Feature matrix of shape (N, FEATURE_DIM)
        y: Binary labels of shape (N,) — 1 means disruption occurred

    Returns:
        (forward_fn, trained_params)
    """
    params = init_params(jax.random.PRNGKey(0))
    optimizer = optax.adam(lr)
    opt_state = optimizer.init(params)

    X_j = jnp.array(X, dtype=jnp.float32)
    y_j = jnp.array(y, dtype=jnp.float32)

    @jax.jit
    def loss_fn(p):
        preds = jax.vmap(lambda x: forward(p, x))(X_j)
        return optax.losses.sigmoid_binary_cross_entropy(preds, y_j).mean()

    @jax.jit
    def step(p, s):
        loss, grads = jax.value_and_grad(loss_fn)(p)
        updates, s = optimizer.update(grads, s)
        p = optax.apply_updates(p, updates)
        return p, s, loss

    for epoch in range(epochs):
        params, opt_state, loss = step(params, opt_state)
        if epoch % 100 == 0:
            print(f"Epoch {epoch:4d} | loss={loss:.4f}")

    return forward, params


def predict(model_fn, params, features: DisruptionFeatures) -> float:
    """Return disruption probability [0,1] for a single supplier."""
    x = jnp.array([
        features.news_severity_score,
        features.port_congestion_index,
        1.0 - features.supplier_financial_health,  # invert: higher = riskier
        features.geopolitical_risk_index,
        min(features.days_since_last_disruption / 365.0, 1.0),
    ])
    return float(model_fn(params, x))
```

**Verify:** After training on 200 synthetic samples, `predict` returns values in (0,1) with values monotonically increasing when `news_severity_score` increases from 0 to 1.

---

### Step 7: Full Hybrid Orchestration

**Goal:** Wire the JAX disruption scores into the CQM penalty weights, submit to D-Wave, and return the optimal re-routing.

```python
# src/orchestrator.py
import os
from src.qubo_network import Supplier, Route, build_network_cqm
from src.dwave_solver import solve_on_leap
from src.rag.retriever import get_disruption_assessment, DisruptionAssessment
from src.ml.disruption_model import DisruptionFeatures, predict


def run_supply_chain_optimisation(
    suppliers: list[Supplier],
    routes: list[Route],
    demand: float,
    news_query: str,
    qdrant_url: str,
    model_fn,
    model_params,
) -> dict:
    """
    End-to-end quantum-classical pipeline:
    1. RAG → structured disruption assessment
    2. JAX ML model → per-supplier disruption probability
    3. Build risk-weighted CQM
    4. Submit to D-Wave Leap
    5. Return optimal re-routing recommendation
    """
    # Step 1: situational awareness via RAG
    assessment: DisruptionAssessment = get_disruption_assessment(
        news_query, qdrant_url
    )

    # Step 2: update each supplier's disruption_risk from ML model
    updated: list[Supplier] = []
    for s in suppliers:
        features = DisruptionFeatures(
            news_severity_score=assessment.severity_score,
            port_congestion_index=0.55,
            supplier_financial_health=s.disruption_risk,
            geopolitical_risk_index=0.40,
            days_since_last_disruption=30,
        )
        ml_risk = predict(model_fn, model_params, features)
        updated.append(
            Supplier(
                id=s.id,
                cost=s.cost,
                capacity=s.capacity,
                disruption_risk=ml_risk,
            )
        )

    # Step 3–4: build CQM and solve on D-Wave
    cqm = build_network_cqm(updated, routes, demand)
    result = solve_on_leap(cqm, time_limit=10)

    active_vars = result.get("active_variables", {})
    recommended_suppliers = [
        v.replace("x_", "") for v in active_vars if v.startswith("x_")
    ]
    recommended_routes = [
        v.replace("y_", "") for v in active_vars if v.startswith("y_")
    ]

    return {
        "status": result["status"],
        "disruption_assessment": assessment.dict(),
        "recommended_suppliers": recommended_suppliers,
        "recommended_routes": recommended_routes,
        "qubo_energy": result.get("energy"),
        "solver_timing": result.get("timing", {}),
    }
```

**Verify:** Running the orchestrator with 3 suppliers, 4 routes, and demand=100 produces `status: feasible` and at least one active supplier.

---

### Step 8: Sample Set Post-Processing

**Goal:** Analyse the full annealing sample set to assess robustness and identify degenerate solutions.

```python
# src/postprocess.py
import dimod
import numpy as np


def analyse_sample_set(sample_set: dimod.SampleSet) -> dict:
    """
    Summarise annealing sample set statistics to assess solution quality.

    Returns:
        dict with energy statistics, feasibility rate, and variable activation probabilities
    """
    energies = [s.energy for s in sample_set.data()]
    total = len(energies)

    if total == 0:
        return {"error": "empty sample set"}

    min_energy = min(energies)
    ground_state_count = sum(1 for e in energies if abs(e - min_energy) < 1e-6)
    feasible_count = sum(
        1 for d in sample_set.data() if hasattr(d, "is_feasible") and d.is_feasible
    )

    # Variable activation frequency across all samples
    var_counts: dict[str, int] = {}
    for s in sample_set.data():
        for var, val in s.sample.items():
            if val > 0.5:
                var_counts[var] = var_counts.get(var, 0) + 1
    var_probs = {v: c / total for v, c in var_counts.items()}

    return {
        "num_samples": total,
        "min_energy": min_energy,
        "mean_energy": float(np.mean(energies)),
        "ground_state_degeneracy": ground_state_count,
        "energy_std": float(np.std(energies)),
        "feasible_count": feasible_count,
        "feasible_fraction": feasible_count / total,
        "variable_activation_probability": var_probs,
    }
```

**Verify:** For a small well-formed CQM solved with `dimod.ExactSolver`, `analyse_sample_set` returns `feasible_fraction = 1.0` and `min_energy` matches the analytically expected minimum.

---

### Step 9: FastAPI Risk Score Endpoint

**Goal:** Expose the full pipeline via a production-ready FastAPI endpoint with Pydantic validation, structured error handling, and OpenAPI documentation.

```python
# src/api/main.py
import os
import uuid
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from src.qubo_network import Supplier, Route
from src.orchestrator import run_supply_chain_optimisation

app = FastAPI(
    title="Supply Chain Risk API",
    description="D-Wave quantum annealing + RAG for real-time supply chain risk scoring",
    version="1.0.0",
)

# Lazy-loaded model (replace with proper DI / lifespan in production)
_MODEL_FN = None
_MODEL_PARAMS = None


class SupplierInput(BaseModel):
    id: str
    cost: float = Field(gt=0)
    capacity: float = Field(gt=0)
    disruption_risk: float = Field(ge=0.0, le=1.0)


class RouteInput(BaseModel):
    supplier_id: str
    port_id: str
    transit_days: int = Field(gt=0)
    cost_per_unit: float = Field(gt=0)


class RiskRequest(BaseModel):
    suppliers: list[SupplierInput]
    routes: list[RouteInput]
    demand: float = Field(gt=0, description="Units of demand to satisfy")
    news_query: str = Field(
        min_length=5, description="Description of the disruption scenario"
    )


class RiskResponse(BaseModel):
    job_id: str
    status: str
    disruption_assessment: dict
    recommended_suppliers: list[str]
    recommended_routes: list[str]
    qubo_energy: float | None


@app.post("/risk-score", response_model=RiskResponse)
async def risk_score(request: RiskRequest) -> RiskResponse:
    """
    Run the quantum-classical supply chain optimisation pipeline.

    Pipeline:
    1. RAG disruption assessment from news_query
    2. ML disruption probability per supplier
    3. QUBO CQM formulation with risk-weighted costs
    4. D-Wave Leap hybrid solver
    5. Return lowest-energy feasible re-routing
    """
    global _MODEL_FN, _MODEL_PARAMS
    if _MODEL_FN is None:
        from src.ml.disruption_model import train
        import numpy as np
        # Synthetic pre-training (replace with persisted weights in production)
        np.random.seed(42)
        X = np.random.rand(200, 5).astype(np.float32)
        y = (X[:, 0] + X[:, 3] > 1.0).astype(np.float32)
        _MODEL_FN, _MODEL_PARAMS = train(X, y, epochs=200)

    suppliers = [Supplier(**s.dict()) for s in request.suppliers]
    routes = [Route(**r.dict()) for r in request.routes]
    qdrant_url = os.environ.get("QDRANT_URL", "http://localhost:6333")

    try:
        result = run_supply_chain_optimisation(
            suppliers=suppliers,
            routes=routes,
            demand=request.demand,
            news_query=request.news_query,
            qdrant_url=qdrant_url,
            model_fn=_MODEL_FN,
            model_params=_MODEL_PARAMS,
        )
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))

    return RiskResponse(
        job_id=str(uuid.uuid4()),
        status=result["status"],
        disruption_assessment=result["disruption_assessment"],
        recommended_suppliers=result.get("recommended_suppliers", []),
        recommended_routes=result.get("recommended_routes", []),
        qubo_energy=result.get("qubo_energy"),
    )


@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}
```

**Verify:** `uvicorn src.api.main:app --reload` starts on port 8000. `GET /health` returns 200. `GET /docs` shows OpenAPI schema with `POST /risk-score` documented. Submit a minimal payload with 2 suppliers and 2 routes and confirm the response matches `RiskResponse`.

---

### Step 10: Monitoring and CI/CD

**Goal:** Add GitHub Actions CI with Qdrant and PostgreSQL service containers, and a `docker-compose.yml` for local reproducible deployment.

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_DB: supply_chain
        ports:
          - "5432:5432"
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      qdrant:
        image: qdrant/qdrant:latest
        ports:
          - "6333:6333"
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install -r requirements.txt
      - run: pytest tests/ -v --tb=short
        env:
          DATABASE_URL: postgresql://postgres:test@localhost:5432/supply_chain
          QDRANT_URL: http://localhost:6333
          DWAVE_API_TOKEN: ${{ secrets.DWAVE_API_TOKEN }}
          MISTRAL_API_KEY: ${{ secrets.MISTRAL_API_KEY }}
```

```yaml
# docker-compose.yml
version: "3.9"
services:
  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      DWAVE_API_TOKEN: ${DWAVE_API_TOKEN}
      MISTRAL_API_KEY: ${MISTRAL_API_KEY}
      DATABASE_URL: postgresql://postgres:postgres@db:5432/supply_chain
      QDRANT_URL: http://qdrant:6333
    depends_on:
      db:
        condition: service_healthy
      qdrant:
        condition: service_started

  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: supply_chain
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  qdrant:
    image: qdrant/qdrant:latest
    ports:
      - "6333:6333"
    volumes:
      - qdrant_data:/qdrant/storage

volumes:
  pgdata:
  qdrant_data:
```

**Verify:** `docker compose up --build` starts all three services without error. `curl http://localhost:8000/health` returns `{"status":"ok"}`. GitHub Actions pipeline passes on push.

---

## Testing

```bash
# Unit tests — run without D-Wave credentials
pytest tests/unit/test_qubo.py -v           # QUBO/CQM formulation correctness
pytest tests/unit/test_postprocess.py -v    # sample set analysis
pytest tests/unit/test_ml_model.py -v       # JAX model training and predict

# Integration tests — requires Qdrant and PostgreSQL running
pytest tests/integration/test_api.py -v --tb=short
pytest tests/integration/test_rag.py -v --tb=short

# Smoke test against D-Wave simulator (no QPU credits consumed)
python src/qubo_warmup.py
```

Key test cases:
- QUBO with known 3-supplier optimal solution verified by `dimod.ExactSolver`
- CQM feasibility checker returns correct flag for infeasible over-constrained input
- `DisruptionAssessment` Pydantic parser raises `ValidationError` on missing `severity_score`
- FastAPI endpoint returns 200 with valid `RiskResponse` on a mocked orchestrator
- JAX model `predict` output is in (0,1) for all input feature ranges

---

## Deployment

```bash
# Build Docker image
docker build -t supply-chain-risk-api:latest .

# Run database migrations
docker compose run --rm api alembic upgrade head

# Start all services
docker compose up -d

# View logs
docker compose logs -f api
```

---

## Resources

1. [D-Wave Ocean SDK Documentation](https://docs.ocean.dwavesys.com/) — QUBO/CQM formulation, sampler API reference
2. [D-Wave Leap Cloud Platform](https://cloud.dwavesys.com/leap/) — Free-tier QPU and hybrid solver access
3. [dimod CQM API Reference](https://docs.ocean.dwavesys.com/en/stable/docs_dimod/reference/cqm.html) — Constrained Quadratic Model data structure
4. [Lucas (2014) — Ising Formulations of Many NP Problems](https://arxiv.org/abs/1302.5843) — Canonical QUBO encoding reference
5. [LangChain RAG Quickstart](https://python.langchain.com/docs/use_cases/question_answering/) — RAG pipeline construction
6. [Qdrant Documentation](https://qdrant.tech/documentation/) — Vector store setup and HNSW indexing
7. [JAX Documentation](https://jax.readthedocs.io/) — Functional ML and JIT compilation
8. [FastAPI Deployment Guide](https://fastapi.tiangolo.com/deployment/) — Production async API patterns
