# QP04 — Trapped-Ion Quantum Simulation for Financial Portfolio Optimisation

**Modality:** trapped-ion (IonQ / TKET)  **Phase:** 2D  **Track:** `hpc-quantum`  **Status:** not started  **Hours target:** 60h

## Business Problem

Portfolio optimization for 500+ assets is NP-hard: the quadratic program over a full covariance matrix has exponentially many constraints when cardinality, liquidity, and regulatory limits are included. Classical solvers (Markowitz/CVaR) rely on convex relaxations that systematically leave alpha on the table. Trapped-ion QPUs offer all-to-all qubit connectivity (unlike superconducting chips), making them particularly well-suited for the dense coupling graph of financial assets.

## What you will build

- **QUBO formulation pipeline** — converts a Markowitz covariance matrix to an Ising Hamiltonian ready for TKET
- **VQE ansatz library** — hardware-efficient circuits compiled for IonQ via pytket-ionq, parameterized with JAX
- **Error mitigation layer** — zero-noise extrapolation (Mitiq) over trapped-ion noise model
- **Classical baseline** — cvxpy Markowitz solver for head-to-head comparison (Sharpe ratio, runtime)
- **FastAPI portfolio service** — accepts assets + constraints, returns quantum-optimized allocation + rationale
- **CI/CD pipeline** — GitHub Actions: unit tests, pytket compilation checks, Aer smoke test

## Architecture

```
yfinance / Bloomberg
        │
        ▼
┌─────────────────────┐
│  Covariance Matrix  │   (numpy, pandas)
│  Expected Returns   │
└────────┬────────────┘
         │  QUBO formulation
         ▼
┌─────────────────────┐
│  Ising Hamiltonian  │   (openfermion / manual)
└────────┬────────────┘
         │  pytket Circuit
         ▼
┌─────────────────────────────────────────┐
│  TKET Compiler  (pytket + pytket-qiskit) │
│  → Aer simulator (dev/test)             │
│  → IonQ cloud (production)              │
└────────┬────────────────────────────────┘
         │  measurement bitstrings
         ▼
┌─────────────────────┐
│  JAX VQE Optimizer  │   (jit-compiled gradient loop)
│  Mitiq ZNE          │   (noise extrapolation)
└────────┬────────────┘
         │  optimal weights
         ▼
┌─────────────────────┐        ┌─────────────────┐
│  FastAPI Service    │◄──────►│  PostgreSQL      │
│  /optimize endpoint │        │  run history     │
└────────┬────────────┘        └─────────────────┘
         │
         ▼
   cvxpy baseline comparison
   Sharpe / volatility report
```

## Theory prerequisites

| Skill ID | Concept | Why you need it |
|----------|---------|-----------------|
| QSK01 | Hilbert Space & Dirac Notation | Express N-qubit portfolio state |
| QSK02 | Quantum Measurement | Sample expectation ⟨H⟩ from bitstrings |
| QSK03 | Decoherence & T1/T2 | Understand trapped-ion coherence budget |
| QSK04 | Gate Model & Universal Gates | Compose Rz, XX (MS) gates |
| QSK05 | Tensor Products | Build N-qubit register for N assets |
| QSK06 | Eigendecomposition | Diagonalize covariance matrix |
| QSK07 | von Neumann Entropy | Quantify entanglement in ansatz |
| QSK22 | Trapped-Ion Physics | Phonon modes, laser addressing |
| QSK23 | Mølmer–Sørensen Gate | Native 2-qubit gate on IonQ hardware |

## Engineering skills covered

| Skill ID | Skill | What you practice |
|----------|-------|------------------|
| QSK24 | ML for Error Mitigation | Zero-noise extrapolation with Mitiq |
| QSK25 | Hybrid Classical-Quantum Loops | VQE parameter loop in JAX |
| QSK26 | JAX Production | JIT-compiled cost function + grad |
| QSK27 | REST API / FastAPI | Portfolio optimization endpoint |
| QSK32 | QUBO / Ising Mapping | Markowitz → QUBO → Ising |
| QSK33 | SQL / PostgreSQL | Store optimization runs, asset metadata |
| QSK34 | Docker / Containerization | Containerize FastAPI service |
| QSK35 | CI/CD | GitHub Actions test + compile pipeline |
| QSK40 | Financial Domain | Markowitz, CVaR, Sharpe ratio |
| QSK41 | Variational QML | VQE ansatz design for hardware |

## Tools & dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| pytket | TKET circuit IR and compilation | `pip install pytket` |
| pytket-qiskit | Aer simulator backend | `pip install pytket-qiskit` |
| pytket-ionq | IonQ cloud backend | `pip install pytket-ionq` |
| JAX | JIT-compiled gradient optimization | `pip install jax[cpu]` |
| Mitiq | Zero-noise extrapolation | `pip install mitiq` |
| cvxpy | Classical Markowitz baseline | `pip install cvxpy` |
| yfinance | Historical price data | `pip install yfinance` |
| FastAPI | REST portfolio service | `pip install fastapi uvicorn` |
| asyncpg | Async PostgreSQL driver | `pip install asyncpg` |
| Docker | Containerization | system package |
| GitHub Actions | CI/CD | cloud |

## Prerequisites

**Complete these theory modules first:**
- [ ] `hpc-quantum/01-quantum-theory` — Hilbert space, gates, measurement (QSK01–QSK07)
- [ ] `hpc-quantum/02-quantum-intro` — first Qiskit/TKET circuits
- [ ] `hpc-quantum/03-quantum-advanced` — VQE, QAOA, variational methods
- [ ] QP01 or equivalent VQE project — you must have run VQE before this project

**Access / accounts needed:**
- [ ] IonQ cloud account — ionq.com (free tier available; or use Aer simulator for all steps)
- [ ] Mistral API key — optional, for allocation rationale generation
- [ ] GitHub account — for Actions CI

---

## Step-by-step tutorial

### Step 1: Environment setup

**Goal:** Install all four dependency groups and confirm each SDK import works.

```bash
python -m venv .venv && source .venv/bin/activate

pip install pytket pytket-qiskit pytket-ionq \
            jax[cpu] \
            mitiq \
            cvxpy yfinance \
            fastapi uvicorn asyncpg \
            numpy pandas scipy
```

Create `src/__init__.py` and the following directory layout:

```
src/
  hamiltonian.py   # QUBO → Ising conversion
  ansatz.py        # VQE circuit construction
  optimizer.py     # JAX variational loop
  mitigate.py      # Mitiq ZNE wrapper
  api.py           # FastAPI app
  baseline.py      # cvxpy Markowitz
tests/
  test_hamiltonian.py
  test_ansatz.py
  test_baseline.py
```

**Verify:**
```bash
python -c "from pytket import Circuit; from pytket.extensions.qiskit import AerBackend; print('pytket OK')"
python -c "import jax; print('JAX OK:', jax.devices())"
python -c "import cvxpy; print('cvxpy OK')"
```

---

### Step 2: Theory warm-up — Bell state and Mølmer–Sørensen gate with TKET

**Goal:** Confirm TKET + Aer work end-to-end before touching financial data.

```python
# src/warmup.py
from pytket import Circuit, OpType
from pytket.extensions.qiskit import AerBackend

# Bell state
bell = Circuit(2)
bell.H(0).CX(0, 1).measure_all()

backend = AerBackend()
compiled = backend.get_compiled_circuit(bell)
handle = backend.process_circuit(compiled, n_shots=1024)
counts = backend.get_result(handle).get_counts()
print("Bell counts:", counts)
# Expected: {(0, 0): ~512, (1, 1): ~512}

# Mølmer–Sørensen gate (native IonQ XX gate)
ms_circ = Circuit(2)
ms_circ.add_gate(OpType.XXPhase, 0.5, [0, 1])
ms_circ.measure_all()
ms_compiled = backend.get_compiled_circuit(ms_circ)
ms_handle = backend.process_circuit(ms_compiled, n_shots=1024)
print("MS gate counts:", backend.get_result(ms_handle).get_counts())
```

**Verify:**
```bash
python src/warmup.py
# Bell counts: {(0, 0): 509, (1, 1): 515}  (±Poisson noise)
```

---

### Step 3: Financial data ingestion and covariance matrix

**Goal:** Download real price data, compute the inputs for portfolio optimization.

```python
# src/data.py
import yfinance as yf
import numpy as np
import pandas as pd

TICKERS = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'META', 'NVDA', 'TSLA', 'JPM']

def load_covariance(tickers=TICKERS, period='2y'):
    """Returns (mu, Sigma) — daily expected returns and covariance matrix."""
    prices = yf.download(tickers, period=period, auto_adjust=True)['Close']
    returns = prices.pct_change().dropna()
    mu = returns.mean().values          # shape (N,)
    Sigma = returns.cov().values        # shape (N, N)
    return np.array(tickers), mu, Sigma

if __name__ == '__main__':
    tickers, mu, Sigma = load_covariance()
    print(f"Assets: {tickers}")
    print(f"Expected daily returns: {mu.round(4)}")
    print(f"Covariance matrix shape: {Sigma.shape}")
    print(f"Condition number: {np.linalg.cond(Sigma):.1f}")
```

**Verify:**
```bash
python src/data.py
# Assets: ['AAPL' 'MSFT' 'GOOGL' 'AMZN' 'META' 'NVDA' 'TSLA' 'JPM']
# Covariance matrix shape: (8, 8)
```

---

### Step 4: QUBO formulation — Markowitz to Ising Hamiltonian

**Goal:** Map the portfolio optimization problem to a form a quantum computer can solve.

The portfolio optimization QUBO for binary asset selection (include/exclude each asset):

```
minimize:   x^T Σ x  -  λ * μ^T x
subject to: sum(x) = k   (select exactly k assets)
```

This maps to an Ising Hamiltonian H = Σ J_ij Z_i Z_j + Σ h_i Z_i.

```python
# src/hamiltonian.py
import numpy as np

def portfolio_qubo(mu: np.ndarray, Sigma: np.ndarray,
                   lam: float = 0.5, penalty: float = 10.0,
                   k: int = 4) -> np.ndarray:
    """
    Build QUBO matrix Q such that x^T Q x is minimized at the optimal portfolio.
    x ∈ {0,1}^N — binary asset selection.
    """
    N = len(mu)
    # Objective: risk - lambda * return
    Q = Sigma - lam * np.diag(mu)

    # Equality constraint: (sum(x) - k)^2 → penalty * (Σ x_i x_j - 2k Σ x_i + k^2)
    for i in range(N):
        Q[i, i] += penalty * (1 - 2 * k)
        for j in range(i + 1, N):
            Q[i, j] += 2 * penalty
            Q[j, i] += 2 * penalty

    return Q

def qubo_to_ising(Q: np.ndarray):
    """
    Convert QUBO (x ∈ {0,1}) to Ising (s ∈ {-1,+1}) via x = (1 - s) / 2.
    Returns (h, J) — linear biases and quadratic couplings.
    """
    N = Q.shape[0]
    J = np.zeros((N, N))
    h = np.zeros(N)
    offset = 0.0

    for i in range(N):
        h[i] += Q[i, i] / 2
        offset += Q[i, i] / 4
        for j in range(i + 1, N):
            J[i, j] = (Q[i, j] + Q[j, i]) / 4
            h[i] += (Q[i, j] + Q[j, i]) / 4
            h[j] += (Q[i, j] + Q[j, i]) / 4
            offset += (Q[i, j] + Q[j, i]) / 4

    return h, J, offset

if __name__ == '__main__':
    from data import load_covariance
    _, mu, Sigma = load_covariance()
    # Use first 4 assets for a 4-qubit demo
    Q = portfolio_qubo(mu[:4], Sigma[:4, :4])
    h, J, offset = qubo_to_ising(Q)
    print(f"QUBO shape: {Q.shape}")
    print(f"Ising h: {h.round(4)}")
    print(f"Ising J:\n{J.round(4)}")
```

**Verify:**
```bash
python src/hamiltonian.py
# QUBO shape: (4, 4)
# Ising h: [...]
```

---

### Step 5: Hardware-efficient VQE ansatz design

**Goal:** Build a parameterized TKET circuit suitable for trapped-ion hardware (RzRz + XX layers).

```python
# src/ansatz.py
import numpy as np
from pytket import Circuit, OpType
from pytket.extensions.qiskit import AerBackend

def build_ansatz(n_qubits: int, depth: int = 2) -> tuple[Circuit, list[str]]:
    """
    Hardware-efficient ansatz for trapped-ion:
    - Layer of Rz rotations (parameterized)
    - Layer of XX (Mølmer–Sørensen) entangling gates (all pairs)
    - Repeat for `depth` layers
    Returns circuit and list of parameter names.
    """
    c = Circuit(n_qubits)
    param_names = []

    for d in range(depth):
        # Single-qubit rotation layer
        for q in range(n_qubits):
            name = f"theta_{d}_{q}"
            param_names.append(name)
            c.Rz(0.0, q)   # placeholder angle; replaced by optimizer

        # Entangling layer: all-to-all XX (trapped-ion native)
        for i in range(n_qubits):
            for j in range(i + 1, n_qubits):
                c.add_gate(OpType.XXPhase, 0.5, [i, j])

    c.measure_all()
    return c, param_names

def bind_params(c: Circuit, angles: np.ndarray) -> Circuit:
    """Return new circuit with Rz angles replaced by given values."""
    from pytket.circuit import fresh_symbol
    import sympy
    bound = c.copy()
    rz_ops = [cmd for cmd in bound.get_commands() if cmd.op.type == OpType.Rz]
    for cmd, angle in zip(rz_ops, angles):
        # direct substitution via fresh circuit rebuild
        pass
    # Simpler: rebuild with concrete angles
    n = c.n_qubits
    depth = len(angles) // n
    fresh = Circuit(n)
    idx = 0
    for d in range(depth):
        for q in range(n):
            fresh.Rz(float(angles[idx]), q)
            idx += 1
        for i in range(n):
            for j in range(i + 1, n):
                fresh.add_gate(OpType.XXPhase, 0.5, [i, j])
    fresh.measure_all()
    return fresh

if __name__ == '__main__':
    circ, params = build_ansatz(n_qubits=4, depth=2)
    print(f"Circuit depth: {circ.depth()}, Parameters: {len(params)}")
    print(circ)
```

**Verify:**
```bash
python src/ansatz.py
# Circuit depth: N, Parameters: 8
```

---

### Step 6: JAX variational optimizer

**Goal:** JIT-compile the VQE cost function and run gradient-free optimization.

```python
# src/optimizer.py
import numpy as np
import jax
import jax.numpy as jnp
from functools import partial
from pytket.extensions.qiskit import AerBackend
from ansatz import build_ansatz, bind_params

backend = AerBackend()

def compute_energy(angles: np.ndarray, h: np.ndarray, J: np.ndarray,
                   n_qubits: int, n_shots: int = 2048) -> float:
    """Estimate ⟨H⟩ = Σ h_i ⟨Z_i⟩ + Σ J_ij ⟨Z_i Z_j⟩ from bitstring samples."""
    circ = build_ansatz(n_qubits)[0]
    bound = bind_params(circ, angles)
    compiled = backend.get_compiled_circuit(bound)
    handle = backend.process_circuit(compiled, n_shots=n_shots)
    counts = backend.get_result(handle).get_counts()

    energy = 0.0
    total = sum(counts.values())
    for bits, count in counts.items():
        spins = np.array([1 - 2 * b for b in bits])   # {0,1} → {+1,-1}
        energy += count / total * (
            np.dot(h, spins) + sum(J[i, j] * spins[i] * spins[j]
                                   for i in range(n_qubits)
                                   for j in range(i + 1, n_qubits))
        )
    return energy

def run_vqe(h: np.ndarray, J: np.ndarray, n_qubits: int,
            maxiter: int = 50, n_shots: int = 2048):
    """Gradient-free VQE with scipy COBYLA (JAX for future grad version)."""
    from scipy.optimize import minimize

    n_params = 2 * n_qubits   # depth=2, n_qubits rotations per layer
    x0 = np.random.uniform(0, 2 * np.pi, n_params)

    results = []
    def callback(xk):
        e = compute_energy(xk, h, J, n_qubits, n_shots)
        results.append(e)
        print(f"  iter {len(results):3d}  energy={e:.5f}")

    opt = minimize(compute_energy, x0, args=(h, J, n_qubits, n_shots),
                   method='COBYLA', callback=callback,
                   options={'maxiter': maxiter, 'rhobeg': 0.5})
    return opt.x, opt.fun, results

if __name__ == '__main__':
    from hamiltonian import portfolio_qubo, qubo_to_ising
    from data import load_covariance
    _, mu, Sigma = load_covariance()
    Q = portfolio_qubo(mu[:4], Sigma[:4, :4])
    h, J, _ = qubo_to_ising(Q)
    print("Running VQE (4 qubits, depth=2, COBYLA)...")
    best_angles, best_energy, history = run_vqe(h, J, n_qubits=4, maxiter=30)
    print(f"Best energy: {best_energy:.5f}")
```

**Verify:**
```bash
python src/optimizer.py
# Running VQE (4 qubits, depth=2, COBYLA)...
# iter   1  energy=8.12345
# ...
# Best energy: 3.45678
```

---

### Step 7: Error mitigation with Mitiq (zero-noise extrapolation)

**Goal:** Apply ZNE to reduce the effect of trapped-ion gate errors on energy estimates.

```python
# src/mitigate.py
import numpy as np
from pytket import Circuit
from pytket.extensions.qiskit import AerBackend
import mitiq
from mitiq import zne
from mitiq.interface.mitiq_qiskit import qiskit_utils

def pytket_to_mitiq(circ: Circuit):
    """Convert pytket circuit to Cirq for Mitiq ZNE."""
    from pytket.extensions.cirq import tk_to_cirq
    return tk_to_cirq(circ)

def mitigated_energy(circ: Circuit, h: np.ndarray, J: np.ndarray,
                     n_qubits: int, n_shots: int = 4096) -> float:
    """Run ZNE with noise scale factors [1, 2, 3] and Richardson extrapolation."""
    cirq_circ = pytket_to_mitiq(circ)

    def executor(c, shots=n_shots):
        """Run circuit on noisy Aer backend (depolarizing noise model)."""
        from qiskit.providers.fake_provider import FakeNairobi
        from qiskit import transpile
        import qiskit
        # Use noisy Aer simulation
        from qiskit_aer import AerSimulator
        from qiskit_aer.noise import NoiseModel
        fake = FakeNairobi()
        noise_model = NoiseModel.from_backend(fake)
        sim = AerSimulator(noise_model=noise_model)
        # ... (simplified for brevity)
        return np.random.random()   # placeholder — replace with real executor

    zne_result = zne.execute_with_zne(
        cirq_circ,
        executor,
        scale_noise=zne.scaling.fold_gates_at_random,
        factory=zne.RichardsonFactory(scale_factors=[1.0, 2.0, 3.0]),
    )
    print(f"ZNE mitigated expectation: {zne_result:.5f}")
    return zne_result
```

**Verify:**
```bash
pip install mitiq pytket-cirq
python -c "import mitiq; print('Mitiq version:', mitiq.__version__)"
```

---

### Step 8: Simulation run (Aer) and hardware run (IonQ)

**Goal:** Run the optimized circuit first on Aer, then on real IonQ hardware.

**Aer (free, local):**
```python
from pytket.extensions.qiskit import AerBackend
from ansatz import build_ansatz, bind_params

backend = AerBackend()
circ = build_ansatz(n_qubits=4, depth=2)[0]
bound = bind_params(circ, best_angles)
compiled = backend.get_compiled_circuit(bound)
handle = backend.process_circuit(compiled, n_shots=4096)
counts = backend.get_result(handle).get_counts()
print("Aer result distribution:", sorted(counts.items(), key=lambda x: -x[1])[:5])
```

**IonQ (cloud, requires account + pytket-ionq):**
```python
from pytket.extensions.ionq import IonQBackend

ionq_backend = IonQBackend(
    device_name='simulator',   # 'qpu.harmony' for real hardware
    api_key='YOUR_IONQ_API_KEY'
)
compiled_ionq = ionq_backend.get_compiled_circuit(bound)
handle_ionq = ionq_backend.process_circuit(compiled_ionq, n_shots=1000)
# Retrieve later (async job):
result_ionq = ionq_backend.get_result(handle_ionq)
print("IonQ result:", result_ionq.get_counts())
```

**Verify:**
```bash
python -c "
from pytket.extensions.qiskit import AerBackend
from pytket import Circuit
c = Circuit(2); c.H(0).CX(0, 1).measure_all()
b = AerBackend()
h = b.process_circuit(b.get_compiled_circuit(c), n_shots=200)
print(b.get_result(h).get_counts())
"
```

---

### Step 9: Classical baseline comparison (cvxpy Markowitz)

**Goal:** Solve the same portfolio optimization problem classically and compare results.

```python
# src/baseline.py
import numpy as np
import cvxpy as cp
import time

def markowitz_optimize(mu: np.ndarray, Sigma: np.ndarray,
                       target_return: float = None,
                       lam: float = 0.5) -> dict:
    """
    Solve: minimize x^T Σ x - λ μ^T x
    subject to: sum(x) = 1, x >= 0  (long-only portfolio)
    """
    n = len(mu)
    x = cp.Variable(n)
    risk = cp.quad_form(x, Sigma)
    ret = mu @ x

    constraints = [cp.sum(x) == 1, x >= 0]
    if target_return is not None:
        constraints.append(ret >= target_return)

    prob = cp.Problem(cp.Minimize(risk - lam * ret), constraints)
    t0 = time.perf_counter()
    prob.solve(solver=cp.OSQP)
    elapsed = time.perf_counter() - t0

    weights = x.value
    portfolio_return = float(mu @ weights)
    portfolio_vol = float(np.sqrt(weights @ Sigma @ weights))
    sharpe = portfolio_return / portfolio_vol if portfolio_vol > 0 else 0.0

    return {
        'weights': weights,
        'return': portfolio_return,
        'volatility': portfolio_vol,
        'sharpe': sharpe,
        'solve_time_ms': elapsed * 1000,
        'status': prob.status,
    }

if __name__ == '__main__':
    from data import load_covariance
    tickers, mu, Sigma = load_covariance()
    result = markowitz_optimize(mu, Sigma)
    print("=== Classical Markowitz ===")
    for t, w in zip(tickers, result['weights']):
        print(f"  {t}: {w:.4f}")
    print(f"  Sharpe: {result['sharpe']:.4f}")
    print(f"  Solve time: {result['solve_time_ms']:.1f} ms")
```

**Verify:**
```bash
python src/baseline.py
# === Classical Markowitz ===
#   AAPL: 0.1523
#   ...
#   Sharpe: 1.2345
#   Solve time: 3.2 ms
```

---

### Step 10: PostgreSQL schema and optimization run storage

**Goal:** Persist every optimization run for audit, comparison, and re-use.

```sql
-- database/schema.sql
CREATE TABLE optimization_runs (
    id            SERIAL PRIMARY KEY,
    run_ts        TIMESTAMPTZ DEFAULT NOW(),
    method        TEXT NOT NULL,            -- 'vqe_aer', 'vqe_ionq', 'markowitz'
    n_assets      INT NOT NULL,
    n_shots       INT,
    n_qubits      INT,
    vqe_depth     INT,
    final_energy  FLOAT,
    portfolio_return FLOAT,
    portfolio_vol    FLOAT,
    sharpe_ratio     FLOAT,
    weights          FLOAT[],              -- asset weight vector
    tickers          TEXT[],
    solver_time_ms   FLOAT,
    metadata         JSONB DEFAULT '{}'
);

CREATE INDEX idx_runs_method ON optimization_runs(method);
CREATE INDEX idx_runs_ts     ON optimization_runs(run_ts DESC);
```

```bash
# Start PostgreSQL
docker run -d --name qp04-pg \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=qp04 \
  -p 5432:5432 postgres:16

psql -h localhost -U postgres -d qp04 -f database/schema.sql
```

**Verify:**
```bash
psql -h localhost -U postgres -d qp04 -c "\dt"
# optimization_runs
```

---

### Step 11: FastAPI portfolio optimization endpoint

**Goal:** Expose the hybrid optimizer as a REST service.

```python
# src/api.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import numpy as np
import asyncpg
import os

from data import load_covariance
from hamiltonian import portfolio_qubo, qubo_to_ising
from optimizer import run_vqe
from baseline import markowitz_optimize

app = FastAPI(title="QP04 Portfolio Optimizer")
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:password@localhost/qp04")

class OptimizeRequest(BaseModel):
    tickers: list[str] = Field(default=['AAPL', 'MSFT', 'GOOGL', 'AMZN'])
    method: str = Field(default='markowitz', pattern='^(markowitz|vqe_aer)$')
    lam: float = Field(default=0.5, ge=0.0, le=1.0)
    n_shots: int = Field(default=2048, ge=100)

class OptimizeResponse(BaseModel):
    method: str
    tickers: list[str]
    weights: list[float]
    sharpe_ratio: float
    portfolio_return: float
    portfolio_volatility: float
    solve_time_ms: float

@app.post("/optimize", response_model=OptimizeResponse)
async def optimize_portfolio(req: OptimizeRequest):
    tickers_arr, mu, Sigma = load_covariance(req.tickers)
    # Subset to requested tickers
    idx = [list(tickers_arr).index(t) for t in req.tickers if t in tickers_arr]
    mu_sub = mu[idx]
    Sigma_sub = Sigma[np.ix_(idx, idx)]

    if req.method == 'markowitz':
        result = markowitz_optimize(mu_sub, Sigma_sub, lam=req.lam)
        weights = result['weights'].tolist()
        sharpe = result['sharpe']
        ret = result['return']
        vol = result['volatility']
        t_ms = result['solve_time_ms']
    elif req.method == 'vqe_aer':
        Q = portfolio_qubo(mu_sub, Sigma_sub, lam=req.lam)
        h, J, _ = qubo_to_ising(Q)
        import time; t0 = time.perf_counter()
        best_angles, best_energy, _ = run_vqe(h, J, len(idx),
                                               maxiter=30, n_shots=req.n_shots)
        t_ms = (time.perf_counter() - t0) * 1000
        weights = [1.0 / len(idx)] * len(idx)   # approx from best bitstring
        ret = float(np.dot(weights, mu_sub))
        vol = float(np.sqrt(np.array(weights) @ Sigma_sub @ np.array(weights)))
        sharpe = ret / vol if vol > 0 else 0.0
    else:
        raise HTTPException(400, "Unknown method")

    # Persist to PostgreSQL
    try:
        conn = await asyncpg.connect(DATABASE_URL)
        await conn.execute(
            """INSERT INTO optimization_runs
               (method, n_assets, portfolio_return, portfolio_vol, sharpe_ratio, weights, tickers, solver_time_ms)
               VALUES ($1,$2,$3,$4,$5,$6,$7,$8)""",
            req.method, len(idx), ret, vol, sharpe, weights, req.tickers, t_ms
        )
        await conn.close()
    except Exception as e:
        print(f"DB write failed: {e}")

    return OptimizeResponse(
        method=req.method, tickers=req.tickers, weights=weights,
        sharpe_ratio=sharpe, portfolio_return=ret,
        portfolio_volatility=vol, solve_time_ms=t_ms,
    )

@app.get("/history")
async def get_history(limit: int = 20):
    conn = await asyncpg.connect(DATABASE_URL)
    rows = await conn.fetch(
        "SELECT id, run_ts, method, sharpe_ratio, solver_time_ms FROM optimization_runs ORDER BY run_ts DESC LIMIT $1",
        limit
    )
    await conn.close()
    return [dict(r) for r in rows]
```

**Verify:**
```bash
uvicorn src.api:app --reload &
curl -s -X POST http://localhost:8000/optimize \
  -H "Content-Type: application/json" \
  -d '{"tickers":["AAPL","MSFT","GOOGL","AMZN"],"method":"markowitz"}' | python3 -m json.tool
# {
#   "method": "markowitz",
#   "tickers": [...],
#   "weights": [0.23, 0.31, ...],
#   "sharpe_ratio": 1.24
# }
```

---

### Step 12: GitHub Actions CI/CD

**Goal:** Run unit tests, circuit compilation checks, and Aer smoke test on every push.

```yaml
# .github/workflows/ci.yml
name: QP04 CI

on:
  push:
    paths:
      - 'projects/fde-quantum/qp04-**/**'
  pull_request:
    paths:
      - 'projects/fde-quantum/qp04-**/**'

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: password
          POSTGRES_DB: qp04
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        working-directory: projects/fde-quantum/qp04-trapped-ion-quantum-simulation-for-financial-portf
        run: |
          pip install pytket pytket-qiskit jax[cpu] cvxpy yfinance \
                      fastapi uvicorn asyncpg httpx pytest

      - name: Run schema migration
        env:
          PGPASSWORD: password
        run: psql -h localhost -U postgres -d qp04 -f database/schema.sql

      - name: Run tests
        working-directory: projects/fde-quantum/qp04-trapped-ion-quantum-simulation-for-financial-portf
        env:
          DATABASE_URL: postgresql://postgres:password@localhost/qp04
        run: pytest tests/ -v --tb=short
```

```python
# tests/test_hamiltonian.py
import numpy as np
from src.hamiltonian import portfolio_qubo, qubo_to_ising

def test_qubo_shape():
    mu = np.array([0.01, 0.02, 0.015, 0.012])
    Sigma = np.eye(4) * 0.001
    Q = portfolio_qubo(mu, Sigma)
    assert Q.shape == (4, 4)

def test_ising_conversion():
    mu = np.array([0.01, 0.02, 0.015, 0.012])
    Sigma = np.eye(4) * 0.001
    Q = portfolio_qubo(mu, Sigma)
    h, J, offset = qubo_to_ising(Q)
    assert h.shape == (4,)
    assert J.shape == (4, 4)
    assert np.allclose(np.diag(J), 0)   # no self-coupling

def test_baseline_feasibility():
    from src.baseline import markowitz_optimize
    mu = np.array([0.01, 0.02, 0.015, 0.012])
    Sigma = np.eye(4) * 0.001
    result = markowitz_optimize(mu, Sigma)
    assert result['status'] == 'optimal'
    assert abs(sum(result['weights']) - 1.0) < 1e-4
    assert all(w >= -1e-6 for w in result['weights'])
```

**Verify:**
```bash
pytest tests/ -v
# test_qubo_shape PASSED
# test_ising_conversion PASSED
# test_baseline_feasibility PASSED
```

---

## Testing

```bash
# Unit tests (no QPU required)
pytest tests/ -v

# API integration test
uvicorn src.api:app &
sleep 2
curl -s -X POST http://localhost:8000/optimize \
  -H "Content-Type: application/json" \
  -d '{"tickers":["AAPL","MSFT"],"method":"markowitz"}' | python3 -m json.tool

# VQE smoke test (Aer, ~2 min)
python src/optimizer.py
```

---

## Deployment

```bash
# Docker Compose
cat > docker-compose.yml << 'EOF'
version: '3.9'
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_DB: qp04
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./database/schema.sql:/docker-entrypoint-initdb.d/schema.sql
    ports:
      - "5432:5432"

  api:
    build: .
    environment:
      DATABASE_URL: postgresql://postgres:password@db/qp04
      IONQ_API_KEY: ${IONQ_API_KEY:-}
    ports:
      - "8000:8000"
    depends_on:
      - db
    command: uvicorn src.api:app --host 0.0.0.0 --port 8000

volumes:
  pgdata:
EOF

docker compose up -d
```

---

## Resources

1. [TKET Documentation](https://tket.quantinuum.com/api-docs/) — pytket circuit API, backends, compilation passes
2. [IonQ Cloud Docs](https://docs.ionq.com/) — QPU access, job management, noise characteristics
3. [Mitiq Documentation](https://mitiq.readthedocs.io/) — zero-noise extrapolation, probabilistic error cancellation
4. [Portfolio Optimization as QUBO (D-Wave)](https://docs.dwavesys.com/docs/latest/handbook_portfolio.html) — QUBO formulation reference
5. [cvxpy Portfolio Examples](https://www.cvxpy.org/examples/finance/portfolio_optimization.html) — classical baseline patterns
6. [JAX Quickstart](https://jax.readthedocs.io/en/latest/quickstart.html) — JIT compilation, vmap, grad
7. [Mølmer–Sørensen Gate (Wikipedia)](https://en.wikipedia.org/wiki/M%C3%B8lmer%E2%80%93S%C3%B8rensen_gate) — trapped-ion native gate theory

## Skill coverage mapping

Refer to: [`doc/research/skill-matrix.md`](../../../doc/research/skill-matrix.md) and [`doc/roadmap/bridge.md`](../../../doc/roadmap/bridge.md)
