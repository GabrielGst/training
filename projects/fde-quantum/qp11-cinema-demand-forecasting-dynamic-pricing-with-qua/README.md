# QP11 — Cinema Demand Forecasting & Dynamic Pricing with Quantum Optimisation

**Modality:** Annealing (D-Wave Ocean SDK)
**Phase:** 2E
**Track:** `fde-quantum`
**Status:** not started
**Hours target:** 55

---

## Business Problem

Cinemas today set ticket prices weeks in advance based on historical averages, losing an estimated 30-40% of potential revenue. A Thursday-night IMAX showing of a blockbuster opening weekend is systematically underpriced relative to demand; a Monday-afternoon screening of an older film is overpriced and sits half-empty.

The constraint structure of cinema pricing is naturally combinatorial: a multiplex with 20 screens and 8 daily showtimes per screen has 160 simultaneous pricing decisions, coupled by capacity constraints (screen occupancy), cross-screen substitution effects (same film on two screens), and temporal demand elasticity (showtimes within 2 hours compete). Classical solvers scale poorly for this problem at portfolio level.

D-Wave quantum annealing formulates this as a **Quadratic Unconstrained Binary Optimisation (QUBO)** problem, finding near-optimal price combinations across all showtimes simultaneously by exploiting quantum tunnelling to escape local minima in the revenue landscape.

---

## What You Will Build

1. **Demand forecasting LSTM** — PyTorch LSTM trained on synthetic (or real) historical ticketing data to predict per-showtime demand given candidate prices, day-of-week, film age, and local events.
2. **QUBO price optimisation** — D-Wave Ocean SDK formulation: binary price tier variables, revenue objective, and occupancy + substitution penalty terms. Solved via Leap hybrid solver.
3. **FastAPI orchestration** — REST endpoints to trigger pricing runs, receive real-time demand signals (via cinema POS API wrapper), and push new prices.
4. **Redis caching** — Price schedule cached with TTL; real-time demand spikes invalidate and trigger re-optimisation.
5. **LangChain rationale generator** — Mistral LLM explains each price decision to cinema operations staff in plain English.
6. **React/Next.js ops dashboard** — Real-time price board showing current prices, demand forecast, occupancy, and quantum solver status.
7. **PostgreSQL result store** — Pricing history, demand forecast audit trail, and revenue attribution.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│  Cinema POS API / Ticketing Data                                      │
│  (booking counts per showtime, updated every 15 minutes)             │
└──────────────────────────────┬───────────────────────────────────────┘
                               │ demand signals (JSON)
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│  FastAPI Service                                                       │
│                                                                        │
│  POST /pricing/run  ──► LSTM Demand Forecaster (PyTorch)             │
│                              │                                         │
│                    Predicted demand per (screen, time, price_tier)    │
│                              │                                         │
│                    QUBO Builder ──► D-Wave Leap Solver                │
│                              │                                         │
│                    Optimal price tier per showtime                     │
│                              │                                         │
│                    Redis cache (TTL = 15 min)                         │
│                    PostgreSQL audit log                                │
│                    LangChain rationale ──► ops staff email            │
└──────────────────────────────┬───────────────────────────────────────┘
                               │ prices + rationale
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│  React/Next.js Operations Dashboard                                   │
│  - Live price board (all showtimes)                                   │
│  - Demand forecast chart                                              │
│  - Occupancy heatmap                                                  │
│  - Quantum solver status + solve time                                 │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Theory Prerequisites

| Skill ID | Concept | Why you need it |
|----------|---------|-----------------|
| SK29 | Real-Time Inference Acceleration & Latency Optimisation | Pricing must update in under 5 seconds from demand signal to Redis cache; you profile and optimise the LSTM inference path |
| SK30 | QUBO & Ising Model Formulation | The entire pricing problem is encoded as a QUBO matrix H_Q = x^T Q x; you derive Q from revenue and constraint terms |
| SK31 | Spin Glass Physics & Adiabatic Evolution | Understanding why D-Wave can escape local revenue minima that classical hill-climbing cannot: tunnelling through energy barriers |
| SK32 | Adiabatic Theorem & Quantum Tunnelling | Annealing schedule design: slow enough evolution near the minimum gap for the system to reach the ground state |
| SK68 | LSTM Time-Series Forecasting | The demand forecaster is a multi-step LSTM predicting ticket sales for each of the next 3 days across all showtimes |
| SK15 | Constraint Embedding for QUBO | Capacity constraints and substitution effects become penalty terms added to the QUBO objective — you tune penalty weights |
| SK42 | Prompt Engineering & Chain-of-Thought | LangChain chain-of-thought prompt that generates coherent rationale for each price decision from structured solver output |
| SK43 | Retrieval-Augmented Generation (RAG) | Optional: retrieve similar past pricing scenarios for few-shot context in the rationale generator |
| SK44 | LLM Output Parsing & Safety | Parse Mistral's rationale into structured JSON for display in the ops dashboard; validate against price bounds |
| SK69 | Inventory Management & Constraint Optimisation | Showtime capacity as inventory; occupancy constraints in QUBO mirror inventory-demand coupling |
| SK70 | Revenue Management & Dynamic Pricing Theory | Yield management principles: price elasticity curves, demand segmentation (matinee vs. prime-time customers) |

---

## Engineering Skills Covered

| Skill ID | Skill | What you practice |
|----------|-------|------------------|
| SK24 | ML for Quantum Error Mitigation | Post-process D-Wave samples: filter low-energy solutions and apply energy-based reranking |
| SK25 | Hybrid Classical-Quantum Loops | FastAPI orchestrates LSTM → QUBO build → D-Wave submit → result retrieve → Redis update loop |
| SK26 | PyTorch Production Patterns | LSTM training, model checkpointing, ONNX export, TorchServe inference endpoint |
| SK27 | REST API Design & FastAPI | Design /pricing/run, /pricing/current, /forecast/{screen_id} endpoints |
| SK33 | SQL Data Modelling (PostgreSQL) | Schema: showtimes, pricing_history, demand_forecast, solver_runs, revenue_attribution |
| SK34 | Container Orchestration (Docker) | Multi-service compose: api, db, redis, lstm-worker, nextjs-dashboard |
| SK35 | CI/CD & GitHub Actions | Automated tests + linting on push; nightly demand forecast accuracy evaluation |
| SK36 | Distributed Systems & Caching (Redis) | Price schedule cache with TTL=15min; pub/sub for real-time demand spike notifications |

---

## Tools & Dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| Ocean SDK (D-Wave) | QUBO formulation, hybrid solver, D-Wave Leap cloud access | `pip install dwave-ocean-sdk` |
| PyTorch | LSTM demand forecaster training and inference | `pip install torch` |
| LangChain | Price rationale generation chain | `pip install langchain langchain-community` |
| Mistral API | LLM backend for rationale generation | `pip install mistralai` |
| FastAPI + uvicorn | Async REST orchestration service | `pip install fastapi uvicorn` |
| PostgreSQL / asyncpg | Pricing history and audit storage | `pip install asyncpg sqlalchemy[asyncio]` |
| Redis | Price schedule cache and pub/sub | `pip install redis` |
| React/Next.js | Operations dashboard frontend | `npx create-next-app@latest` |
| Docker / docker-compose | Multi-service container deployment | system package |
| pytest | Unit and integration tests | `pip install pytest` |

---

## Prerequisites

**Complete these theory modules first:**
- [ ] SK30 — QUBO Formulation: encode a simple 2-variable maximisation problem as QUBO by hand
- [ ] SK31 — Spin Glass Physics: read the D-Wave introduction to Ising models (docs.dwavesys.com)
- [ ] SK32 — Adiabatic Theorem: understand why the annealing schedule matters for solution quality
- [ ] SK68 — LSTM: implement a single-step LSTM in PyTorch on a toy time series before tackling multi-step demand forecasting
- [ ] SK70 — Revenue Management: read the Wikipedia Yield Management article and the American Airlines SABRE case study

**Access needed:**
- [ ] Python 3.11+ environment
- [ ] D-Wave Leap account (free tier available at `cloud.dwavesys.com`)
- [ ] Mistral API key (or local Ollama instance for cost-free development)
- [ ] Docker Engine installed
- [ ] Node.js 18+ for the Next.js dashboard

---

## Step-by-Step Tutorial

### Step 1: Environment Setup

**Goal:** Install all dependencies and verify D-Wave Ocean SDK and PyTorch are functional.

```bash
cd qp11-cinema-demand-forecasting-dynamic-pricing-with-qua

python -m venv .venv
source .venv/bin/activate

pip install dwave-ocean-sdk torch fastapi uvicorn asyncpg sqlalchemy \
            langchain langchain-community mistralai redis pytest

# Configure D-Wave credentials
dwave config create
# Follow prompts to enter your Leap token from cloud.dwavesys.com

# Verify Ocean SDK
python -c "from dwave.cloud import Client; print('Ocean SDK OK')"

# Verify PyTorch
python -c "import torch; print(f'PyTorch {torch.__version__}')"
```

**Verify:** `dwave ping` should return `200 OK` (requires Leap token).

---

### Step 2: Theory Warm-Up — QUBO Formulation for Cinema Pricing

**Goal:** Manually encode a tiny 2-screen, 3-price-tier pricing problem as a QUBO matrix and solve it classically to verify the formulation before submitting to D-Wave.

The pricing QUBO has variables `x_{s,t,p} ∈ {0,1}`, meaning "screen `s` at showtime `t` uses price tier `p`."

The objective is to **maximise** expected revenue:

```
Revenue = sum_{s,t,p} x_{s,t,p} * price_tier[p] * predicted_demand[s,t,p]
```

Subject to: exactly one price tier chosen per (screen, showtime):

```
sum_p x_{s,t,p} = 1   for all (s, t)
```

Constraints become penalty terms: `penalty_weight * (sum_p x_{s,t,p} - 1)^2`.

```python
# src/qubo_builder.py
import numpy as np
from typing import Optional


PRICE_TIERS = [8.0, 12.0, 16.0, 20.0]   # price options in EUR


def build_pricing_qubo(
    predicted_demand: np.ndarray,
    penalty_weight: float = 50.0,
) -> tuple:
    """
    Build QUBO matrix for cinema pricing optimisation.

    Args:
        predicted_demand: shape (num_screens, num_showtimes, num_price_tiers)
            Entry [s, t, p] = predicted tickets sold if screen s, showtime t uses price tier p.
        penalty_weight: weight for the one-hot constraint penalty.

    Returns:
        (Q, var_index): Q is the QUBO matrix (n_vars x n_vars),
                        var_index maps (s,t,p) -> linear index.
    """
    num_screens, num_showtimes, num_tiers = predicted_demand.shape
    n_vars = num_screens * num_showtimes * num_tiers

    def var_idx(s: int, t: int, p: int) -> int:
        return s * num_showtimes * num_tiers + t * num_tiers + p

    var_index = {
        (s, t, p): var_idx(s, t, p)
        for s in range(num_screens)
        for t in range(num_showtimes)
        for p in range(num_tiers)
    }

    Q = np.zeros((n_vars, n_vars))

    # Objective: maximise revenue => minimise negative revenue
    for s in range(num_screens):
        for t in range(num_showtimes):
            for p in range(num_tiers):
                revenue = PRICE_TIERS[p] * predicted_demand[s, t, p]
                i = var_idx(s, t, p)
                Q[i, i] -= revenue   # negate: QUBO minimises

    # One-hot constraint: exactly one price tier per (screen, showtime)
    for s in range(num_screens):
        for t in range(num_showtimes):
            indices = [var_idx(s, t, p) for p in range(num_tiers)]
            for i in indices:
                Q[i, i] += penalty_weight * (1 - 2 * 1)   # diagonal: -A*(2*1-1)
            for i in indices:
                for j in indices:
                    if i != j:
                        Q[i, j] += penalty_weight * 1

    return Q, var_index


def decode_qubo_solution(
    solution: dict,
    var_index: dict,
    num_screens: int,
    num_showtimes: int,
    num_tiers: int,
) -> np.ndarray:
    """
    Decode a binary solution vector into price assignments.
    Returns array of shape (num_screens, num_showtimes) with price tier index.
    """
    price_assignment = np.zeros((num_screens, num_showtimes), dtype=int)
    for (s, t, p), idx in var_index.items():
        if solution.get(idx, 0) == 1:
            price_assignment[s, t] = p
    return price_assignment


# Toy example: 2 screens, 2 showtimes, 4 price tiers
rng = np.random.default_rng(42)
demand = rng.uniform(10, 80, size=(2, 2, 4))   # tickets sold per config
Q, var_idx_map = build_pricing_qubo(demand, penalty_weight=50.0)

print(f"QUBO matrix shape: {Q.shape}")
print(f"Number of variables: {Q.shape[0]}")
print(f"QUBO diagonal (first 8 values): {np.diag(Q)[:8].round(2)}")
```

**Verify:** QUBO matrix shape should be `(16, 16)` for 2 screens x 2 showtimes x 4 tiers. Diagonal values should be negative (revenue maximisation encoded as minimisation).

---

### Step 3: D-Wave Leap Solver Integration

**Goal:** Submit the pricing QUBO to D-Wave Leap hybrid solver and retrieve the solution.

```python
# src/dwave_solver.py
import numpy as np
from dimod import BinaryQuadraticModel
from dwave.system import LeapHybridSampler
from src.qubo_builder import build_pricing_qubo, decode_qubo_solution, PRICE_TIERS


def solve_pricing_qubo(
    predicted_demand: np.ndarray,
    penalty_weight: float = 50.0,
    time_limit: int = 5,   # seconds
) -> dict:
    """
    Submit pricing QUBO to D-Wave Leap hybrid solver.

    Args:
        predicted_demand: (num_screens, num_showtimes, num_tiers)
        penalty_weight: one-hot constraint penalty weight
        time_limit: maximum Leap solve time in seconds

    Returns:
        dict with 'price_assignment', 'revenue', 'energy', 'solve_time_ms'
    """
    num_screens, num_showtimes, num_tiers = predicted_demand.shape

    Q, var_index = build_pricing_qubo(predicted_demand, penalty_weight)

    # Convert to BinaryQuadraticModel
    bqm = BinaryQuadraticModel.from_qubo(
        {(i, j): float(Q[i, j]) for i in range(Q.shape[0]) for j in range(i, Q.shape[1]) if Q[i, j] != 0}
    )

    sampler = LeapHybridSampler()

    import time
    t0 = time.perf_counter()
    sampleset = sampler.sample(bqm, time_limit=time_limit)
    solve_time_ms = (time.perf_counter() - t0) * 1000

    best = sampleset.first
    solution = dict(best.sample)
    energy = float(best.energy)

    price_assignment = decode_qubo_solution(
        solution, var_index, num_screens, num_showtimes, num_tiers
    )

    # Compute actual revenue from the assignment
    revenue = 0.0
    for s in range(num_screens):
        for t in range(num_showtimes):
            p = price_assignment[s, t]
            revenue += PRICE_TIERS[p] * predicted_demand[s, t, p]

    return {
        "price_assignment": price_assignment.tolist(),
        "assigned_prices": [
            [PRICE_TIERS[price_assignment[s, t]] for t in range(num_showtimes)]
            for s in range(num_screens)
        ],
        "expected_revenue": round(revenue, 2),
        "qubo_energy": round(energy, 4),
        "solve_time_ms": round(solve_time_ms, 1),
        "num_vars": bqm.num_variables,
    }


# Simulated classical fallback (for offline development without Leap token)
def solve_pricing_classical(predicted_demand: np.ndarray) -> dict:
    """
    Greedy classical fallback: for each (screen, showtime), pick the price tier
    that maximises expected revenue.
    """
    num_screens, num_showtimes, num_tiers = predicted_demand.shape
    price_assignment = np.zeros((num_screens, num_showtimes), dtype=int)

    for s in range(num_screens):
        for t in range(num_showtimes):
            revenues = [PRICE_TIERS[p] * predicted_demand[s, t, p] for p in range(num_tiers)]
            price_assignment[s, t] = int(np.argmax(revenues))

    revenue = sum(
        PRICE_TIERS[price_assignment[s, t]] * predicted_demand[s, t, price_assignment[s, t]]
        for s in range(num_screens)
        for t in range(num_showtimes)
    )

    return {
        "price_assignment": price_assignment.tolist(),
        "assigned_prices": [
            [PRICE_TIERS[price_assignment[s, t]] for t in range(num_showtimes)]
            for s in range(num_screens)
        ],
        "expected_revenue": round(revenue, 2),
        "method": "classical_greedy",
    }


# Test with classical fallback
rng = np.random.default_rng(42)
demand = rng.uniform(10, 80, size=(3, 6, 4))
result = solve_pricing_classical(demand)
print(f"Classical solution revenue: EUR {result['expected_revenue']:.2f}")
print(f"Assigned prices (screen 0): {result['assigned_prices'][0]}")
```

**Verify:** Classical fallback should return a valid price assignment with positive revenue. When Leap is available, swap to `solve_pricing_qubo` and verify energy is negative (revenue maximisation).

---

### Step 4: LSTM Demand Forecaster

**Goal:** Build and train a multi-step LSTM that predicts per-showtime ticket demand given price, day-of-week, and film metadata.

```python
# src/demand_forecaster.py
import torch
import torch.nn as nn
import numpy as np
from typing import Optional


class DemandLSTM(nn.Module):
    """
    LSTM demand forecaster for cinema ticketing.
    Input features per timestep:
      [price_tier, day_of_week_sin, day_of_week_cos, film_age_days,
       hour_of_day_sin, hour_of_day_cos, is_weekend, is_holiday]
    """
    INPUT_SIZE = 8
    OUTPUT_SIZE = 4   # demand for each of the 4 price tiers

    def __init__(self, hidden_size: int = 64, num_layers: int = 2):
        super().__init__()
        self.lstm = nn.LSTM(
            self.INPUT_SIZE, hidden_size, num_layers,
            batch_first=True, dropout=0.2
        )
        self.head = nn.Sequential(
            nn.Linear(hidden_size, 32),
            nn.ReLU(),
            nn.Linear(32, self.OUTPUT_SIZE),
            nn.Softplus(),   # demand must be non-negative
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: (batch, seq_len, INPUT_SIZE)
        out, _ = self.lstm(x)
        return self.head(out[:, -1, :])   # predict from last timestep


def generate_synthetic_demand_data(
    num_showtimes: int = 1000,
    sequence_length: int = 14,
) -> tuple:
    """
    Generate synthetic cinema demand dataset.
    Returns (X, y) where X: (N, seq_len, 8) and y: (N, 4).
    """
    rng = np.random.default_rng(42)
    X, y = [], []

    for _ in range(num_showtimes):
        # Random showtime features over a 14-day history window
        seq = []
        for day in range(sequence_length):
            dow = rng.integers(0, 7)
            hour = rng.integers(10, 23)
            film_age = rng.integers(0, 60)
            price_tier = rng.integers(0, 4)
            is_weekend = float(dow >= 5)
            is_holiday = float(rng.random() < 0.05)

            features = [
                price_tier / 3.0,
                np.sin(2 * np.pi * dow / 7),
                np.cos(2 * np.pi * dow / 7),
                film_age / 60.0,
                np.sin(2 * np.pi * hour / 24),
                np.cos(2 * np.pi * hour / 24),
                is_weekend,
                is_holiday,
            ]
            seq.append(features)

        X.append(seq)

        # Demand model: higher on weekends, declines with film age, sensitive to price
        base = 60 * (1 - film_age / 120) * (1 + 0.3 * is_weekend)
        demands = [
            max(0, base * 1.2 + rng.normal(0, 5)),   # tier 0: EUR 8
            max(0, base * 1.0 + rng.normal(0, 5)),   # tier 1: EUR 12
            max(0, base * 0.7 + rng.normal(0, 5)),   # tier 2: EUR 16
            max(0, base * 0.4 + rng.normal(0, 5)),   # tier 3: EUR 20
        ]
        y.append(demands)

    return np.array(X, dtype=np.float32), np.array(y, dtype=np.float32)


def train_demand_lstm(num_epochs: int = 60) -> DemandLSTM:
    """Train LSTM demand forecaster on synthetic data."""
    X, y = generate_synthetic_demand_data()
    split = 800

    X_train = torch.FloatTensor(X[:split])
    y_train = torch.FloatTensor(y[:split])
    X_val = torch.FloatTensor(X[split:])
    y_val = torch.FloatTensor(y[split:])

    model = DemandLSTM(hidden_size=64, num_layers=2)
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
    loss_fn = nn.MSELoss()

    for epoch in range(num_epochs):
        model.train()
        # Mini-batch training
        for i in range(0, len(X_train), 32):
            batch_x = X_train[i:i+32]
            batch_y = y_train[i:i+32]
            optimizer.zero_grad()
            pred = model(batch_x)
            loss = loss_fn(pred, batch_y)
            loss.backward()
            optimizer.step()

        if epoch % 15 == 0:
            model.eval()
            with torch.no_grad():
                val_loss = loss_fn(model(X_val), y_val).item()
            print(f"Epoch {epoch:3d}: val_loss={val_loss:.2f} (demand in tickets)")

    torch.save(model.state_dict(), "models/demand_lstm.pt")
    print("LSTM saved to models/demand_lstm.pt")
    return model


model = train_demand_lstm(60)

# Sample prediction for a prime-time Friday
import torch
test_input = torch.zeros(1, 14, 8)
test_input[0, :, 1] = np.sin(2 * np.pi * 4 / 7)   # Friday
test_input[0, :, 4] = np.sin(2 * np.pi * 20 / 24)  # 20:00

model.eval()
with torch.no_grad():
    demand_pred = model(test_input).squeeze().numpy()

print("\nPredicted demand by price tier (Friday 20:00 prime-time):")
for p, (price, demand) in enumerate(zip([8, 12, 16, 20], demand_pred)):
    print(f"  EUR {price:2d}: {demand:.0f} tickets")
```

**Verify:** The model should predict higher demand for EUR 8 than EUR 20, and the val loss should decrease over training. A Friday 20:00 prime-time slot should show 40+ tickets at EUR 8.

---

### Step 5: FastAPI Orchestration Service

**Goal:** Wire LSTM forecaster and QUBO solver into REST endpoints.

```python
# src/api.py
from fastapi import FastAPI, HTTPException, BackgroundTasks
from pydantic import BaseModel
import asyncio
import uuid
import datetime
import numpy as np
import redis.asyncio as aioredis
import json
import os

app = FastAPI(title="Cinema Dynamic Pricing API", version="1.0.0")
redis_client: aioredis.Redis = None


@app.on_event("startup")
async def startup():
    global redis_client
    redis_client = aioredis.from_url(
        os.environ.get("REDIS_URL", "redis://localhost:6379"),
        decode_responses=True,
    )


class PricingRequest(BaseModel):
    num_screens: int = 3
    num_showtimes: int = 6
    date: str   # "2026-06-15"
    force_refresh: bool = False


class PricingResponse(BaseModel):
    run_id: str
    date: str
    assigned_prices: list    # (num_screens, num_showtimes) price matrix
    expected_revenue: float
    solve_method: str
    solve_time_ms: float
    cached: bool


@app.post("/pricing/run", response_model=PricingResponse)
async def run_pricing(req: PricingRequest, background_tasks: BackgroundTasks):
    """
    Trigger a full pricing optimisation run for the given date.
    Returns cached result if available and force_refresh=False.
    """
    cache_key = f"pricing:{req.date}:{req.num_screens}:{req.num_showtimes}"

    if not req.force_refresh:
        cached = await redis_client.get(cache_key)
        if cached:
            data = json.loads(cached)
            data["cached"] = True
            return PricingResponse(**data)

    run_id = str(uuid.uuid4())

    # 1. Generate demand forecasts (in production: use LSTM model)
    rng = np.random.default_rng(hash(req.date) % 2**32)
    predicted_demand = rng.uniform(10, 80, size=(req.num_screens, req.num_showtimes, 4))

    # 2. Solve pricing QUBO (use classical fallback for offline dev)
    import time
    t0 = time.perf_counter()
    from src.qubo_builder import PRICE_TIERS

    # Classical greedy (swap for solve_pricing_qubo() when Leap is available)
    price_assignment = np.zeros((req.num_screens, req.num_showtimes), dtype=int)
    for s in range(req.num_screens):
        for t in range(req.num_showtimes):
            revenues = [PRICE_TIERS[p] * predicted_demand[s, t, p] for p in range(4)]
            price_assignment[s, t] = int(np.argmax(revenues))

    revenue = sum(
        PRICE_TIERS[price_assignment[s, t]] * predicted_demand[s, t, price_assignment[s, t]]
        for s in range(req.num_screens)
        for t in range(req.num_showtimes)
    )
    solve_time_ms = (time.perf_counter() - t0) * 1000

    assigned_prices = [
        [PRICE_TIERS[price_assignment[s, t]] for t in range(req.num_showtimes)]
        for s in range(req.num_screens)
    ]

    result = {
        "run_id": run_id,
        "date": req.date,
        "assigned_prices": assigned_prices,
        "expected_revenue": round(revenue, 2),
        "solve_method": "classical_greedy",
        "solve_time_ms": round(solve_time_ms, 1),
        "cached": False,
    }

    # Cache for 15 minutes
    await redis_client.setex(cache_key, 900, json.dumps(result))

    # Background: store to PostgreSQL
    background_tasks.add_task(store_pricing_run, result)

    return PricingResponse(**result)


@app.get("/pricing/current")
async def current_prices():
    """Return all cached pricing schedules."""
    keys = await redis_client.keys("pricing:*")
    results = []
    for key in keys:
        data = await redis_client.get(key)
        if data:
            results.append(json.loads(data))
    return {"schedules": results, "count": len(results)}


async def store_pricing_run(result: dict):
    """Write pricing run to PostgreSQL audit log."""
    # In production: use asyncpg connection
    print(f"[AUDIT] Stored pricing run {result['run_id']}: revenue={result['expected_revenue']}")
```

**Verify:** `uvicorn src.api:app --reload` and `POST /pricing/run` with `{"date":"2026-06-15","num_screens":3,"num_showtimes":6}` — should return a valid pricing matrix in under 2 seconds.

---

### Step 6: LangChain Rationale Generator

**Goal:** Generate plain-English price rationale for cinema operations staff using Mistral API.

```python
# src/rationale_generator.py
from langchain.prompts import ChatPromptTemplate
from langchain_community.chat_models import ChatOllama   # swap for ChatMistralAI in production
from langchain.output_parsers import PydanticOutputParser
from pydantic import BaseModel, Field
from typing import Optional


class PriceRationale(BaseModel):
    screen_id: int
    showtime_index: int
    assigned_price: float
    summary: str = Field(description="One-sentence explanation of why this price was chosen")
    demand_outlook: str = Field(description="Brief demand forecast narrative")
    revenue_impact: str = Field(description="Expected revenue impact vs. flat pricing")


RATIONALE_PROMPT = ChatPromptTemplate.from_template("""
You are a cinema revenue management analyst explaining pricing decisions to operations staff.

Given the following context, explain the pricing decision in plain English.

Screen: {screen_id}
Showtime: {showtime_label}
Assigned price: EUR {assigned_price}
Predicted demand at this price: {predicted_demand:.0f} tickets
Predicted demand at flat EUR 12: {baseline_demand:.0f} tickets
Expected revenue at assigned price: EUR {expected_revenue:.0f}
Expected revenue at flat price: EUR {baseline_revenue:.0f}
Day of week: {day_of_week}
Film: {film_name} (age: {film_age_days} days)

Provide a concise, professional explanation.
{format_instructions}
""")


def generate_price_rationale(
    screen_id: int,
    showtime_label: str,
    assigned_price: float,
    predicted_demand: float,
    baseline_demand: float,
    day_of_week: str,
    film_name: str,
    film_age_days: int,
) -> PriceRationale:
    """Generate a structured price rationale using Mistral (or local Ollama)."""
    parser = PydanticOutputParser(pydantic_object=PriceRationale)

    # Use Ollama locally (swap `model="mistral"` for `ChatMistralAI(model="mistral-large-latest")`)
    llm = ChatOllama(model="mistral", temperature=0.3)

    chain = RATIONALE_PROMPT | llm | parser

    baseline_price = 12.0
    response = chain.invoke({
        "screen_id": screen_id,
        "showtime_label": showtime_label,
        "assigned_price": assigned_price,
        "predicted_demand": predicted_demand,
        "baseline_demand": baseline_demand,
        "expected_revenue": assigned_price * predicted_demand,
        "baseline_revenue": baseline_price * baseline_demand,
        "day_of_week": day_of_week,
        "film_name": film_name,
        "film_age_days": film_age_days,
        "format_instructions": parser.get_format_instructions(),
    })

    return response


# Example usage
rationale = generate_price_rationale(
    screen_id=1,
    showtime_label="Friday 20:15",
    assigned_price=20.0,
    predicted_demand=45.0,
    baseline_demand=72.0,
    day_of_week="Friday",
    film_name="Blockbuster Movie",
    film_age_days=3,
)
print(f"Summary: {rationale.summary}")
print(f"Demand outlook: {rationale.demand_outlook}")
print(f"Revenue impact: {rationale.revenue_impact}")
```

**Verify:** The rationale should mention the Friday opening-weekend premium, acknowledge demand reduction at EUR 20, and confirm positive net revenue impact.

---

### Step 7: PostgreSQL Schema

**Goal:** Design the full pricing and demand database schema.

```sql
-- migrations/001_cinema_schema.sql

CREATE TABLE IF NOT EXISTS showtimes (
    id              SERIAL PRIMARY KEY,
    screen_id       INT NOT NULL,
    showtime_label  TEXT NOT NULL,
    film_name       TEXT NOT NULL,
    film_age_days   INT NOT NULL,
    show_date       DATE NOT NULL,
    show_hour       INT NOT NULL,
    capacity        INT NOT NULL DEFAULT 180,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pricing_runs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    run_date        DATE NOT NULL,
    num_screens     INT NOT NULL,
    num_showtimes   INT NOT NULL,
    solve_method    TEXT NOT NULL,
    solve_time_ms   FLOAT8,
    expected_revenue FLOAT8,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pricing_history (
    id              SERIAL PRIMARY KEY,
    run_id          UUID REFERENCES pricing_runs(id),
    screen_id       INT NOT NULL,
    showtime_index  INT NOT NULL,
    assigned_price  FLOAT8 NOT NULL,
    predicted_demand FLOAT8,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS demand_forecasts (
    id              SERIAL PRIMARY KEY,
    screen_id       INT NOT NULL,
    showtime_index  INT NOT NULL,
    forecast_date   DATE NOT NULL,
    price_tier      INT NOT NULL,
    predicted_demand FLOAT8 NOT NULL,
    actual_demand   FLOAT8,           -- filled in post-show
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Revenue attribution view
CREATE VIEW v_revenue_attribution AS
SELECT
    p.run_date,
    p.screen_id,
    p.showtime_index,
    p.assigned_price,
    p.predicted_demand,
    p.assigned_price * p.predicted_demand AS expected_revenue,
    (p.assigned_price - 12.0) * p.predicted_demand AS uplift_vs_flat
FROM pricing_history p
ORDER BY p.run_id, p.screen_id, p.showtime_index;
```

**Verify:** `psql -c "\d pricing_history"` shows all columns; the view `v_revenue_attribution` is queryable.

---

### Step 8: Redis Caching & Real-Time Demand Updates

**Goal:** Implement Redis-backed price cache with demand-spike invalidation.

```python
# src/cache_manager.py
import redis.asyncio as aioredis
import json
import asyncio
import os

REDIS_URL = os.environ.get("REDIS_URL", "redis://localhost:6379")
PRICE_CACHE_TTL = 900   # 15 minutes
DEMAND_SPIKE_THRESHOLD = 0.20   # 20% demand increase triggers re-optimisation


class PriceCacheManager:
    """Manages price schedule caching and demand-spike invalidation."""

    def __init__(self):
        self.client: aioredis.Redis = None

    async def connect(self):
        self.client = aioredis.from_url(REDIS_URL, decode_responses=True)

    async def get_price_schedule(self, date: str, screen_id: int) -> dict | None:
        """Retrieve cached price schedule for a screen on a date."""
        key = f"price:{date}:screen:{screen_id}"
        data = await self.client.get(key)
        return json.loads(data) if data else None

    async def set_price_schedule(self, date: str, screen_id: int, schedule: dict):
        """Cache price schedule with TTL."""
        key = f"price:{date}:screen:{screen_id}"
        await self.client.setex(key, PRICE_CACHE_TTL, json.dumps(schedule))

    async def invalidate_and_republish(self, date: str, screen_id: int):
        """Invalidate cached schedule and publish re-optimisation request."""
        key = f"price:{date}:screen:{screen_id}"
        await self.client.delete(key)
        channel = "repricing_requests"
        await self.client.publish(channel, json.dumps({
            "date": date,
            "screen_id": screen_id,
            "reason": "demand_spike",
        }))
        print(f"[CACHE] Invalidated {key} and published re-pricing request")

    async def monitor_demand_spikes(self, baseline_demand: dict, current_demand: dict):
        """
        Compare current demand to baseline. If any screen exceeds threshold,
        invalidate its price cache and trigger re-optimisation.
        """
        for (date, screen_id), base in baseline_demand.items():
            current = current_demand.get((date, screen_id), base)
            if base > 0 and (current - base) / base > DEMAND_SPIKE_THRESHOLD:
                print(f"[SPIKE] Screen {screen_id} on {date}: {base:.0f} -> {current:.0f} tickets")
                await self.invalidate_and_republish(date, screen_id)


# Usage demonstration
async def demo():
    cache = PriceCacheManager()
    await cache.connect()

    # Store a schedule
    schedule = {"prices": [12.0, 16.0, 20.0, 12.0, 16.0, 8.0], "method": "quantum_qubo"}
    await cache.set_price_schedule("2026-06-20", screen_id=1, schedule=schedule)

    # Retrieve it
    retrieved = await cache.get_price_schedule("2026-06-20", screen_id=1)
    print(f"Retrieved schedule: {retrieved}")

    # Simulate demand spike
    baseline = {("2026-06-20", 1): 50.0}
    current = {("2026-06-20", 1): 65.0}   # 30% spike
    await cache.monitor_demand_spikes(baseline, current)

asyncio.run(demo())
```

**Verify:** The schedule retrieval should return the stored JSON. The spike check should print the invalidation message for the 30% demand increase.

---

### Step 9: React/Next.js Operations Dashboard

**Goal:** Build the operations price board frontend.

```typescript
// dashboard/src/app/page.tsx
"use client";
import { useState, useEffect } from "react";

type PriceSchedule = {
  run_id: string;
  date: string;
  assigned_prices: number[][];
  expected_revenue: number;
  solve_method: string;
  solve_time_ms: number;
  cached: boolean;
};

export default function PricingDashboard() {
  const [schedules, setSchedules] = useState<PriceSchedule[]>([]);
  const [loading, setLoading] = useState(false);
  const [lastUpdated, setLastUpdated] = useState<string | null>(null);

  const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";

  async function fetchPrices() {
    setLoading(true);
    const res = await fetch(`${API_URL}/pricing/current`);
    const data = await res.json();
    setSchedules(data.schedules ?? []);
    setLastUpdated(new Date().toLocaleTimeString());
    setLoading(false);
  }

  async function triggerPricingRun(date: string) {
    setLoading(true);
    await fetch(`${API_URL}/pricing/run`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ date, num_screens: 3, num_showtimes: 6, force_refresh: true }),
    });
    await fetchPrices();
  }

  useEffect(() => {
    fetchPrices();
    const interval = setInterval(fetchPrices, 60_000);   // refresh every minute
    return () => clearInterval(interval);
  }, []);

  const today = new Date().toISOString().split("T")[0];

  return (
    <main style={{ background: "#0d1117", minHeight: "100vh", color: "#e6edf3", padding: "2rem", fontFamily: "monospace" }}>
      <h1 style={{ color: "#58a6ff" }}>Cinema Dynamic Pricing Dashboard</h1>
      <p style={{ color: "#8b949e" }}>
        Last updated: {lastUpdated ?? "—"}
        {loading && " (refreshing...)"}
      </p>

      <button
        onClick={() => triggerPricingRun(today)}
        style={{ background: "#238636", color: "white", border: "none", padding: "0.5rem 1rem", cursor: "pointer", marginBottom: "1rem" }}
      >
        Run Quantum Pricing for Today
      </button>

      {schedules.length === 0 && <p>No pricing schedules cached. Run pricing first.</p>}

      {schedules.map((schedule) => (
        <div key={schedule.run_id} style={{ background: "#161b22", border: "1px solid #30363d", borderRadius: "6px", padding: "1rem", marginBottom: "1rem" }}>
          <h2>{schedule.date}</h2>
          <p style={{ color: "#8b949e" }}>
            Revenue: <strong style={{ color: "#3fb950" }}>EUR {schedule.expected_revenue.toFixed(2)}</strong>
            {" | "}Method: {schedule.solve_method}
            {" | "}Solve time: {schedule.solve_time_ms.toFixed(0)} ms
            {schedule.cached && " | [CACHED]"}
          </p>

          <table style={{ width: "100%", borderCollapse: "collapse", marginTop: "0.5rem" }}>
            <thead>
              <tr style={{ color: "#8b949e" }}>
                <th style={{ textAlign: "left", padding: "4px 8px" }}>Screen</th>
                {[...Array(schedule.assigned_prices[0]?.length ?? 0)].map((_, t) => (
                  <th key={t} style={{ padding: "4px 8px" }}>Show {t + 1}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {schedule.assigned_prices.map((row, s) => (
                <tr key={s}>
                  <td style={{ padding: "4px 8px", color: "#8b949e" }}>Screen {s + 1}</td>
                  {row.map((price, t) => (
                    <td key={t} style={{
                      padding: "4px 8px",
                      textAlign: "center",
                      color: price >= 16 ? "#f85149" : price >= 12 ? "#d29922" : "#3fb950",
                      fontWeight: "bold",
                    }}>
                      EUR {price}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ))}
    </main>
  );
}
```

**Verify:** `npm run dev` in `dashboard/` then open `http://localhost:3000` — clicking "Run Quantum Pricing" should populate the price board with colour-coded prices.

---

### Step 10: Docker Compose Deployment

**Goal:** Package all services into a reproducible multi-container stack.

```yaml
# docker-compose.yml
version: "3.9"

services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: cinema
      POSTGRES_USER: cinema
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./migrations:/docker-entrypoint-initdb.d

  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]

  api:
    build: .
    command: uvicorn src.api:app --host 0.0.0.0 --port 8000
    environment:
      DATABASE_URL: postgresql://cinema:${POSTGRES_PASSWORD}@db:5432/cinema
      REDIS_URL: redis://redis:6379
      DWAVE_API_TOKEN: ${DWAVE_API_TOKEN}
    depends_on: [db, redis]
    ports: ["8000:8000"]

  dashboard:
    build: ./dashboard
    environment:
      NEXT_PUBLIC_API_URL: http://localhost:8000
    ports: ["3000:3000"]
    depends_on: [api]

volumes:
  postgres_data:
```

**Verify:** `docker compose up -d` starts four services. `docker compose ps` shows all healthy.

---

### Step 11: QUBO Constraint Tuning & Penalty Weight Optimisation

**Goal:** Systematically tune the penalty weight `lambda` to balance constraint satisfaction vs. revenue optimisation.

```python
# src/penalty_tuning.py
import numpy as np
from src.qubo_builder import build_pricing_qubo, decode_qubo_solution, PRICE_TIERS


def evaluate_qubo_solution(
    solution: np.ndarray,
    predicted_demand: np.ndarray,
    penalty_weight: float,
) -> dict:
    """
    Evaluate a QUBO solution for constraint violations and revenue.
    Returns constraint violation count and expected revenue.
    """
    num_screens, num_showtimes, num_tiers = predicted_demand.shape
    # Reconstruct binary vector
    n_vars = num_screens * num_showtimes * num_tiers

    violations = 0
    revenue = 0.0
    for s in range(num_screens):
        for t in range(num_showtimes):
            tier_sum = sum(1 for p in range(num_tiers) if solution[s, t] == p)
            # One-hot check: exactly one tier assigned per (s, t)
            assigned = int(solution[s, t])
            if not (0 <= assigned < num_tiers):
                violations += 1
            else:
                revenue += PRICE_TIERS[assigned] * predicted_demand[s, t, assigned]

    return {"violations": violations, "revenue": round(revenue, 2)}


def tune_penalty_weight(predicted_demand: np.ndarray, lambdas: list = None) -> dict:
    """
    Grid search over penalty weights using classical greedy (proxy for D-Wave).
    Returns the lambda that minimises violations while maximising revenue.
    """
    if lambdas is None:
        lambdas = [1.0, 5.0, 10.0, 20.0, 50.0, 100.0]

    results = []
    num_screens, num_showtimes, num_tiers = predicted_demand.shape

    for lam in lambdas:
        Q, var_index = build_pricing_qubo(predicted_demand, penalty_weight=lam)

        # Classical greedy proxy: pick argmin Q diagonal per (s,t) group
        assignment = np.zeros((num_screens, num_showtimes), dtype=int)
        for s in range(num_screens):
            for t in range(num_showtimes):
                # Pick tier with lowest QUBO diagonal = highest revenue
                diag_vals = [Q[var_index[(s, t, p)], var_index[(s, t, p)]] for p in range(num_tiers)]
                assignment[s, t] = int(np.argmin(diag_vals))

        metrics = evaluate_qubo_solution(assignment, predicted_demand, lam)
        results.append({"lambda": lam, **metrics})
        print(f"  lambda={lam:6.1f}: violations={metrics['violations']}, revenue=EUR {metrics['revenue']:.2f}")

    best = min(results, key=lambda r: (r["violations"], -r["revenue"]))
    print(f"\nBest lambda: {best['lambda']} (violations={best['violations']}, revenue={best['revenue']})")
    return best


rng = np.random.default_rng(42)
demand = rng.uniform(10, 80, size=(3, 4, 4))
print("Penalty weight grid search:")
best = tune_penalty_weight(demand)
```

**Verify:** Higher penalty weights should reduce violations to 0; the function should identify the smallest lambda that achieves zero violations.

---

### Step 12: Full Test Suite & CI

**Goal:** Comprehensive tests covering QUBO builder, demand forecaster, cache, and API.

```python
# tests/test_qubo_builder.py
import numpy as np
import pytest
from src.qubo_builder import build_pricing_qubo, decode_qubo_solution, PRICE_TIERS


def test_qubo_matrix_shape():
    demand = np.ones((2, 2, 4))
    Q, _ = build_pricing_qubo(demand)
    assert Q.shape == (16, 16)


def test_qubo_diagonal_is_negative():
    demand = np.ones((2, 2, 4)) * 50.0
    Q, _ = build_pricing_qubo(demand, penalty_weight=0.0)
    # Without penalty, diagonal should be all negative (revenue maximisation)
    assert np.all(np.diag(Q) <= 0)


def test_decode_solution_shape():
    demand = np.ones((2, 3, 4))
    _, var_index = build_pricing_qubo(demand)
    # Solution that selects tier 0 for all (screen, showtime)
    solution = {idx: 1 if (s, t, 0) in var_index and var_index[(s, t, 0)] == idx else 0
                for (s, t, p), idx in var_index.items()}
    assignment = decode_qubo_solution(solution, var_index, 2, 3, 4)
    assert assignment.shape == (2, 3)


# tests/test_demand_forecaster.py
import torch
import numpy as np
from src.demand_forecaster import DemandLSTM


def test_lstm_output_shape():
    model = DemandLSTM()
    x = torch.zeros(4, 14, 8)
    y = model(x)
    assert y.shape == (4, 4)


def test_lstm_output_nonnegative():
    model = DemandLSTM()
    x = torch.rand(8, 14, 8)
    y = model(x)
    assert torch.all(y >= 0)
```

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: {python-version: "3.11"}
      - run: pip install -r requirements.txt pytest mypy bandit
      - run: mypy src/ --ignore-missing-imports
      - run: bandit -r src/ -ll
      - run: pytest tests/ -v --tb=short
```

**Verify:** `pytest tests/ -v` — all 5 tests pass. `mypy src/` returns no errors.

---

## Testing

```bash
# Unit tests
pytest tests/ -v

# Type checking
mypy src/ --ignore-missing-imports

# API smoke test (requires running services)
uvicorn src.api:app --reload &
curl -X POST localhost:8000/pricing/run \
     -H "Content-Type: application/json" \
     -d '{"date":"2026-06-20","num_screens":3,"num_showtimes":6}'

# D-Wave connectivity test (requires Leap token)
dwave ping
```

---

## Deployment

```bash
cp .env.example .env
# Fill in: POSTGRES_PASSWORD, DWAVE_API_TOKEN, MISTRAL_API_KEY

docker compose up -d --build

# Apply database schema
docker compose exec db psql -U cinema -d cinema -f /docker-entrypoint-initdb.d/001_cinema_schema.sql

# Open dashboard
open http://localhost:3000
```

---

## Resources

1. [D-Wave Ocean SDK Documentation](https://docs.dwavesys.com/docs/latest/) — QUBO formulation and Leap solver reference
2. [D-Wave Leap Cloud](https://cloud.dwavesys.com/) — Free-tier QPU and hybrid solver access
3. [Kochenberger et al. (2014) — The Unconstrained Binary Quadratic Programming Problem](https://link.springer.com/article/10.1007/s10479-014-1694-7) — Comprehensive QUBO formulation guide
4. [Glover, Kochenberger & Du (2019) — A Tutorial on Formulating and Using QUBO Models](https://arxiv.org/abs/1811.11538) — Practical QUBO formulation tutorial
5. [PyTorch LSTM Documentation](https://pytorch.org/docs/stable/generated/torch.nn.LSTM.html) — LSTM API reference
6. [LangChain Mistral Integration](https://python.langchain.com/docs/integrations/chat/mistralai) — LangChain + Mistral API setup
7. [Redis Documentation — Pub/Sub](https://redis.io/docs/manual/pubsub/) — Real-time demand spike notifications
8. [Next.js Documentation](https://nextjs.org/docs) — React dashboard framework
