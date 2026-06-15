# QP10 — Tensor Network Classical Simulation + ML for Quantum Circuit Benchmarking

**Modality:** Superconducting (classical simulation — no QPU required)
**Phase:** 2A (tensor network)
**Track:** `fde-quantum`
**Status:** not started
**Hours target:** 50

---

## Business Problem

Benchmarking quantum circuits requires simulating their output, but full statevector simulation is exponentially expensive: a 50-qubit circuit requires `2^50 ≈ 10^15` complex amplitudes — far beyond classical RAM. This makes systematic benchmarking of quantum hardware proposals impractical for researchers and vendors.

Tensor network contraction provides an efficient classical approximation for circuits with low entanglement, contracting the network in an order that avoids ever constructing the full state. However, finding the optimal contraction order is itself NP-hard. The business need: a benchmark dashboard that can evaluate circuit families at scale using tensor network simulation, accelerated by a graph neural network that predicts contraction cost before simulation begins.

---

## What You Will Build

1. **Tensor network simulator** — QuTiP and `opt_einsum` for MPS-based circuit simulation with automatic contraction order optimisation.
2. **JAX-accelerated gradient contraction** — JAX `jit` and `vmap` for batched tensor operations with GPU support.
3. **PyTorch Geometric GNN** — A graph neural network trained on circuit graphs (nodes = qubits, edges = gates) to predict simulation cost and fidelity before running contraction.
4. **Benchmark suite** — Quantum Volume, CLOPS, and custom fidelity metrics across circuit families (random Clifford, QAOA, VQE ansatz, GHZ).
5. **Flask dashboard** — Interactive visualisation of benchmark results with circuit family comparison charts.
6. **PostgreSQL result store** — Persistent benchmark history with schema for multi-dimensional circuit metadata.
7. **GitHub Actions CI** — Automated nightly benchmark runs against a fixed circuit library.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  Circuit Library (OpenQASM 2.0 files + custom generators)        │
│  Random Clifford  |  QAOA depth-p  |  VQE ansatz  |  GHZ        │
└───────────────────────────┬────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  GNN Cost Predictor (PyTorch Geometric)                          │
│  Circuit DAG → node/edge features → predicted runtime (ms)       │
│  Trained offline on {circuit, actual_runtime} pairs             │
└───────────────────────────┬────────────────────────────────────┘
                            │  If predicted cost < threshold
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Tensor Network Simulator                                         │
│                                                                   │
│  QuTiP: build MPS state, apply gate tensors layer by layer       │
│  opt_einsum: find near-optimal contraction path                  │
│  JAX jit: execute contraction with GPU acceleration              │
│                                                                   │
│  Output: fidelity estimate, QV score, CLOPS rate                 │
└───────────────────────────┬────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  PostgreSQL (benchmark_runs table)                                │
│  circuit_name | num_qubits | depth | fidelity | runtime_ms | ... │
└───────────────────────────┬────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Flask Dashboard                                                  │
│  - Fidelity vs circuit depth scatter plot                         │
│  - Runtime comparison across backends                            │
│  - GNN prediction vs actual correlation                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Theory Prerequisites

| Skill ID | Concept | Why you need it |
|----------|---------|-----------------|
| SK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notation) | Tensor network nodes represent quantum state tensors; you reason in bra-ket notation to construct MPS |
| SK02 | Quantum Measurement Theory (Born Rule & POVMs) | Fidelity estimation requires computing overlap of simulated and ideal output distributions |
| SK04 | Quantum Gate Model & Universal Gate Sets (Clifford+T) | The circuit library spans Clifford circuits, T gates, and CNOT layers — you must classify their contraction cost |
| SK05 | Complex Vector Spaces & Tensor Products | MPS bonds represent tensor product structure; Kronecker products determine bond dimension growth |
| SK06 | Eigendecomposition & Matrix Decompositions (SVD, QR) | SVD truncates bond dimensions in MPS after each gate application; you control fidelity via truncation threshold |
| SK63 | Tensor Network Theory (MPS, PEPS, MERA) | Core theory: MPS for 1D circuits; bond dimension chi controls accuracy vs. cost trade-off |
| SK64 | Graph Neural Networks (GNNs) for Quantum Circuits | Circuit-as-graph: nodes are qubits, directed edges are gates. GNN learns to predict contraction cost |
| SK65 | Classical Tensor Contraction & opt_einsum | opt_einsum finds the near-optimal einsum path; you must understand path complexity (FLOPs vs. memory) |
| SK66 | Quantum Circuit Benchmarking & Metrics | Quantum Volume, CLOPS, cross-entropy benchmarking — the quantities the dashboard displays |
| SK67 | High-Performance Computing (HPC) Optimisation | JAX jit + GPU memory hierarchy; vectorising tensor contractions across a batch of circuits |
| SK68 | LSTM Time-Series Forecasting | LSTM baseline for predicting benchmark regression over time across nightly runs |

---

## Engineering Skills Covered

| Skill ID | Skill | What you practice |
|----------|-------|------------------|
| SK24 | ML for Quantum Error Mitigation | Train noise-correction head to predict zero-noise fidelity via Richardson extrapolation |
| SK25 | Hybrid Classical-Quantum Loops & Orchestration | Flask + PostgreSQL orchestration: submit circuit, tensor simulate, store result, update dashboard |
| SK26 | PyTorch Production Patterns | GNN training loop with PyTorch Geometric, model checkpointing, inference serving |
| SK27 | REST API Design & FastAPI | Expose `/benchmark` endpoint for programmatic circuit submission |
| SK33 | SQL Data Modelling (PostgreSQL) | Multi-dimensional benchmark schema: circuit metadata, run history, hardware comparison |
| SK34 | Container Orchestration (Docker) | Docker compose stack: flask, postgres, optional GPU worker |
| SK35 | CI/CD & GitHub Actions | Nightly benchmark regression: run fixed circuit library, fail CI if fidelity drops more than 5% |
| SK67 | HPC Optimisation | Profile contraction on CPU vs. GPU; reduce peak memory via optimal path selection |
| SK68 | LSTM Time Series | Forecast benchmark regression: LSTM trained on nightly fidelity time series |

---

## Tools & Dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| QuTiP | Quantum system simulation, MPS state construction | `pip install qutip` |
| JAX | GPU-accelerated tensor contraction with JIT compilation | `pip install jax jaxlib` |
| opt_einsum | Optimal tensor contraction path finding | `pip install opt_einsum` |
| PyTorch Geometric | GNN for circuit cost prediction | `pip install torch torch-geometric` |
| Flask | Benchmark dashboard web server | `pip install flask` |
| PostgreSQL / psycopg2 | Benchmark result persistent storage | `pip install psycopg2-binary sqlalchemy` |
| Docker | Container packaging | system package |
| GitHub Actions | CI/CD and nightly benchmark runs | GitHub-hosted |
| pytest | Unit and integration tests | `pip install pytest` |
| matplotlib / plotly | Benchmark visualisation charts | `pip install matplotlib plotly` |

---

## Prerequisites

**Complete these theory modules first:**
- [ ] SK01 — Quantum State Representation: work through bra-ket notation for multi-qubit states
- [ ] SK05 — Tensor Products: derive the 2-qubit CX gate tensor from Kronecker product by hand
- [ ] SK06 — SVD: implement a manual MPS truncation using `numpy.linalg.svd`
- [ ] SK63 — Tensor Network Theory: read the Orus 2014 tensor network review (arXiv:1306.2164)
- [ ] SK65 — opt_einsum: run the opt_einsum quickstart examples

**Access needed:**
- [ ] Python 3.11+ environment
- [ ] Docker Engine installed
- [ ] (Optional) NVIDIA GPU + CUDA 12+ for JAX GPU acceleration
- [ ] PostgreSQL 16 (or use the Docker compose service)

---

## Step-by-Step Tutorial

### Step 1: Environment Setup

**Goal:** Install all dependencies and verify QuTiP and JAX are functional.

```bash
cd qp10-tensor-network-classical-simulation-ml-for-quantum

python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate

pip install qutip jax jaxlib opt_einsum torch torch-geometric \
            flask psycopg2-binary sqlalchemy matplotlib plotly \
            pytest networkx

# Verify JAX device
python -c "import jax; print(jax.devices())"
# CPU-only output: [CpuDevice(id=0)]

# Verify QuTiP
python -c "import qutip as qt; print(qt.__version__)"
```

**Verify:** Both imports succeed without errors and QuTiP version is 4.7+.

---

### Step 2: Theory Warm-Up — MPS Simulation of a GHZ Circuit

**Goal:** Build a GHZ state as a Matrix Product State using QuTiP and verify fidelity against the exact statevector.

A **Matrix Product State** represents an n-qubit state as a chain of tensors:

```
|psi> = sum_{s0..s(n-1)} A[0]^{s0} . A[1]^{s1} . ... . A[n-1]^{s(n-1)} |s0 s1 ... s(n-1)>
```

where each `A[i]` has shape `(chi_{i-1}, chi_i)` and `chi` is the bond dimension controlling accuracy.

```python
# src/mps_simulator.py
import numpy as np
import qutip as qt


def ghz_state_exact(num_qubits: int) -> qt.Qobj:
    """Build exact GHZ state (|00...0> + |11...1>) / sqrt(2) using QuTiP."""
    zero = qt.basis(2, 0)
    one = qt.basis(2, 1)
    all_zeros = zero
    all_ones = one
    for _ in range(num_qubits - 1):
        all_zeros = qt.tensor(all_zeros, zero)
        all_ones = qt.tensor(all_ones, one)
    return (all_zeros + all_ones).unit()


def apply_hadamard_mps(tensors: list, qubit: int) -> list:
    """Apply Hadamard gate to qubit in MPS representation."""
    H = np.array([[1, 1], [1, -1]]) / np.sqrt(2)
    tensor = tensors[qubit]   # shape: (chi_left, 2, chi_right)
    tensors[qubit] = np.einsum("sp,asb->apb", H, tensor)
    return tensors


def apply_cnot_mps(
    tensors: list,
    control: int,
    target: int,
    max_bond_dim: int = 64,
    svd_cutoff: float = 1e-10,
) -> list:
    """
    Apply CNOT between adjacent qubits using SVD-based bond update.
    Nearest-neighbour only in this implementation.
    """
    assert target == control + 1, "Only nearest-neighbour CNOT supported"

    A = tensors[control]    # (chi_l, 2, chi_m)
    B = tensors[target]     # (chi_m, 2, chi_r)
    chi_l = A.shape[0]
    chi_r = B.shape[2]

    # Contract A and B into a 4-index tensor
    theta = np.einsum("asb,btc->astc", A, B)   # (chi_l, 2, 2, chi_r)

    # Apply CNOT: |00>->|00>, |01>->|01>, |10>->|11>, |11>->|10>
    CNOT = np.array([[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]], dtype=complex)
    CNOT = CNOT.reshape(2, 2, 2, 2)   # (s0', s1', s0, s1)
    theta = np.einsum("pqst,astc->apqc", CNOT, theta)   # (chi_l, 2, 2, chi_r)

    # SVD to split back into two MPS tensors
    theta_mat = theta.reshape(chi_l * 2, 2 * chi_r)
    U, S, Vt = np.linalg.svd(theta_mat, full_matrices=False)

    keep = min(np.sum(S > svd_cutoff), max_bond_dim)
    tensors[control] = U[:, :keep].reshape(chi_l, 2, keep)
    tensors[target] = (np.diag(S[:keep]) @ Vt[:keep, :]).reshape(keep, 2, chi_r)
    return tensors


def build_ghz_mps(num_qubits: int) -> list:
    """Build GHZ state as MPS: H on qubit 0, then CNOT chain."""
    # Initialise product state |000...0> in MPS form
    tensors = []
    for i in range(num_qubits):
        t = np.zeros((1, 2, 1), dtype=complex)
        t[0, 0, 0] = 1.0   # |0>
        tensors.append(t)

    tensors = apply_hadamard_mps(tensors, qubit=0)
    for i in range(num_qubits - 1):
        tensors = apply_cnot_mps(tensors, control=i, target=i + 1)
    return tensors


def mps_to_statevector(tensors: list) -> np.ndarray:
    """Contract the full MPS into a statevector (only for small n < 20)."""
    result = tensors[0][0, :, :]   # (2, chi_right)
    for i in range(1, len(tensors)):
        result = np.einsum("...a,apb->...pb", result, tensors[i])
    return result.flatten()


# Verify: compare MPS GHZ to exact QuTiP GHZ
n = 4
tensors = build_ghz_mps(n)
sv_mps = mps_to_statevector(tensors)
ghz_exact = ghz_state_exact(n).full().flatten()
fidelity = abs(np.vdot(ghz_exact, sv_mps)) ** 2
print(f"GHZ MPS fidelity vs exact (n={n}): {fidelity:.6f}")
assert fidelity > 0.9999
print("MPS construction: PASSED")
```

**Verify:** Fidelity should be `> 0.9999` for a 4-qubit GHZ state with exact SVD (no truncation needed).

---

### Step 3: Tensor Contraction with opt_einsum

**Goal:** Use `opt_einsum` to find the optimal contraction path and measure the FLOP reduction versus greedy contraction.

```python
# src/contraction_optimizer.py
import opt_einsum as oe
import numpy as np
import time
import string


def build_circuit_einsum(num_qubits: int, depth: int):
    """
    Build a random brick-layer circuit as an einsum tensor network.
    Returns (operands, subscripts) ready for opt_einsum.
    """
    rng = np.random.default_rng(seed=42)
    idx = list(string.ascii_lowercase + string.ascii_uppercase)

    qubit_bonds = list(idx[:num_qubits])
    operands = []
    subscript_parts = []
    free_idx = num_qubits

    # Initial state tensors |0> for each qubit
    for i in range(num_qubits):
        operands.append(np.array([1.0, 0.0], dtype=complex))
        subscript_parts.append(qubit_bonds[i])

    # Alternating brick layers of random 2-qubit unitaries
    for d in range(depth):
        start = d % 2
        for i in range(start, num_qubits - 1, 2):
            if free_idx + 2 > len(idx):
                break
            U = np.linalg.qr(
                rng.standard_normal((4, 4)) + 1j * rng.standard_normal((4, 4))
            )[0].reshape(2, 2, 2, 2)
            operands.append(U)

            a_in, b_in = qubit_bonds[i], qubit_bonds[i + 1]
            a_out, b_out = idx[free_idx], idx[free_idx + 1]
            subscript_parts.append(f"{a_in}{b_in}{a_out}{b_out}")
            qubit_bonds[i], qubit_bonds[i + 1] = a_out, b_out
            free_idx += 2

    output_str = "".join(qubit_bonds)
    subscripts = ",".join(subscript_parts) + "->" + output_str
    return operands, subscripts


def compare_contraction_strategies(num_qubits: int = 6, depth: int = 3):
    """Compare greedy vs DP-optimal contraction paths by FLOP count."""
    operands, subscripts = build_circuit_einsum(num_qubits, depth)

    print(f"Circuit: {num_qubits} qubits, depth {depth}")

    # Greedy path
    _, info_greedy = oe.contract_path(subscripts, *operands, optimize="greedy")
    print(f"Greedy FLOPs:   {info_greedy.opt_cost:.3e}")
    print(f"Greedy largest: {info_greedy.largest_intermediate:.3e}")

    # DP-optimal path
    _, info_dp = oe.contract_path(subscripts, *operands, optimize="dp")
    print(f"DP-opt FLOPs:   {info_dp.opt_cost:.3e}")
    print(f"DP-opt largest: {info_dp.largest_intermediate:.3e}")

    speedup = info_greedy.opt_cost / max(info_dp.opt_cost, 1)
    print(f"FLOP reduction (greedy -> DP): {speedup:.2f}x")

    # Execute with optimal path and measure time
    t0 = time.perf_counter()
    result = oe.contract(subscripts, *operands, optimize="dp")
    t_exec = (time.perf_counter() - t0) * 1000
    print(f"Execution time: {t_exec:.2f} ms")
    print(f"Output tensor shape: {result.shape}")
    return result


compare_contraction_strategies(num_qubits=6, depth=3)
```

**Verify:** DP-optimal path should show at least 2x fewer FLOPs than greedy for depth-3 circuits with 6 qubits.

---

### Step 4: JAX-Accelerated Statevector Simulation

**Goal:** Port statevector simulation to JAX for JIT compilation and benchmark the speedup.

```python
# src/jax_simulator.py
import jax
import jax.numpy as jnp
import numpy as np
import time

jax.config.update("jax_enable_x64", True)


def make_gate_apply_fn(num_qubits: int):
    """
    Returns a JIT-compiled function that applies a 2-qubit gate
    to a statevector at positions (q0, q1).
    """
    @jax.jit
    def apply_gate(state: jnp.ndarray, gate: jnp.ndarray, q0: int, q1: int) -> jnp.ndarray:
        """Apply 4x4 unitary to qubits q0, q1 in a 2^n statevector."""
        n = num_qubits
        s = state.reshape([2] * n)
        # Bring target qubits to front
        axes = [q0, q1] + [i for i in range(n) if i not in (q0, q1)]
        s = jnp.transpose(s, axes)
        s = jnp.einsum("ij,j...->i...", gate.reshape(4, 4), s.reshape(4, -1)).reshape([2] * n)
        # Undo permutation
        inv_axes = [0] * n
        for new_pos, old_pos in enumerate(axes):
            inv_axes[old_pos] = new_pos
        return jnp.transpose(s, inv_axes).reshape(-1)

    return apply_gate


def simulate_random_circuit_jax(num_qubits: int, depth: int, seed: int = 42) -> jnp.ndarray:
    """
    Simulate a random brick-layer circuit using JAX.
    Returns the final statevector.
    """
    rng = np.random.default_rng(seed)
    apply_gate = make_gate_apply_fn(num_qubits)

    # Initial state |00...0>
    state = jnp.zeros(2 ** num_qubits, dtype=jnp.complex128)
    state = state.at[0].set(1.0)

    for d in range(depth):
        start = d % 2
        for q in range(start, num_qubits - 1, 2):
            U_np = np.linalg.qr(
                rng.standard_normal((4, 4)) + 1j * rng.standard_normal((4, 4))
            )[0].astype(np.complex128)
            gate = jnp.array(U_np)
            state = apply_gate(state, gate, q, q + 1)

    return state


# Warm up JIT
print("Warming up JIT compilation...")
sv = simulate_random_circuit_jax(num_qubits=6, depth=3)
sv.block_until_ready()

# Benchmark
t0 = time.perf_counter()
for _ in range(5):
    sv = simulate_random_circuit_jax(num_qubits=6, depth=3)
    sv.block_until_ready()
t_avg = (time.perf_counter() - t0) / 5

print(f"JAX simulation (6 qubits, depth 3): {t_avg*1000:.2f} ms/run")
print(f"Norm of final state: {float(jnp.linalg.norm(sv)):.6f}")
assert abs(float(jnp.linalg.norm(sv)) - 1.0) < 1e-6, "State not normalised"
print("JAX simulation: PASSED")
```

**Verify:** The final statevector norm should be `1.000000` and the run time should be under 100 ms for 6 qubits after JIT warm-up.

---

### Step 5: GNN for Circuit Contraction Cost Prediction

**Goal:** Build and train a GNN that predicts simulation runtime from the circuit DAG.

```python
# src/gnn_cost_predictor.py
import torch
import torch.nn.functional as F
from torch_geometric.data import Data, DataLoader
from torch_geometric.nn import GCNConv, global_mean_pool
import numpy as np


def circuit_to_pyg_graph(num_qubits: int, gates: list) -> Data:
    """
    Convert a gate list to a PyTorch Geometric graph.
    Node features: [qubit_index_norm, qubit_degree_norm]
    Edge features: [0=single-qubit, 1=two-qubit]
    """
    degree = [0] * num_qubits
    edge_index = []
    edge_attr = []

    for gate in gates:
        gate_type = gate[0]
        q0 = gate[1]
        degree[q0] += 1
        edge_index.append([q0, q0])   # self-loop
        edge_attr.append(0.0)
        if len(gate) > 2:
            q1 = gate[2]
            degree[q1] += 1
            edge_index.append([q0, q1])
            edge_index.append([q1, q0])
            edge_attr.extend([1.0, 1.0])

    max_degree = max(degree) if degree else 1
    x = torch.tensor(
        [[i / num_qubits, degree[i] / max_degree] for i in range(num_qubits)],
        dtype=torch.float,
    )

    if not edge_index:
        edge_index = [[0, 0]]
        edge_attr = [0.0]

    return Data(
        x=x,
        edge_index=torch.tensor(edge_index, dtype=torch.long).t().contiguous(),
        edge_attr=torch.tensor(edge_attr, dtype=torch.float).unsqueeze(1),
    )


class CircuitCostGNN(torch.nn.Module):
    """3-layer GCN predicting log10(runtime_ms) from circuit graph."""

    def __init__(self, hidden: int = 64):
        super().__init__()
        self.conv1 = GCNConv(2, hidden)
        self.conv2 = GCNConv(hidden, hidden)
        self.conv3 = GCNConv(hidden, hidden // 2)
        self.head = torch.nn.Linear(hidden // 2, 1)

    def forward(self, data):
        x, ei, b = data.x, data.edge_index, data.batch
        x = F.relu(self.conv1(x, ei))
        x = F.relu(self.conv2(x, ei))
        x = F.relu(self.conv3(x, ei))
        x = global_mean_pool(x, b)
        return self.head(x).squeeze(-1)


def generate_training_dataset(num_samples: int = 300) -> list:
    """Generate synthetic (circuit_graph, log_runtime) training pairs."""
    rng = np.random.default_rng(42)
    dataset = []

    for _ in range(num_samples):
        n = int(rng.integers(3, 12))
        depth = int(rng.integers(1, 8))
        gates = []
        for d in range(depth):
            for q in range(n - 1):
                if rng.random() < 0.4:
                    gates.append(("H", q))
                if rng.random() < 0.5:
                    gates.append(("CNOT", q, q + 1))

        # Proxy target: log10 of estimated FLOPs (2^n * depth)
        log_runtime = float(np.log10(max(2 ** n * depth, 1)) + rng.normal(0, 0.05))

        graph = circuit_to_pyg_graph(n, gates)
        graph.y = torch.tensor([log_runtime], dtype=torch.float)
        dataset.append(graph)

    return dataset


def train_gnn(num_epochs: int = 60) -> CircuitCostGNN:
    """Train the GNN cost predictor with 80/20 train/val split."""
    dataset = generate_training_dataset(300)
    split = 240
    train_loader = DataLoader(dataset[:split], batch_size=16, shuffle=True)
    val_loader = DataLoader(dataset[split:], batch_size=16)

    model = CircuitCostGNN(hidden=64)
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)

    for epoch in range(num_epochs):
        model.train()
        total_loss = 0.0
        for batch in train_loader:
            optimizer.zero_grad()
            loss = F.mse_loss(model(batch), batch.y.squeeze())
            loss.backward()
            optimizer.step()
            total_loss += loss.item()

        if epoch % 15 == 0:
            model.eval()
            val_losses = [F.mse_loss(model(b), b.y.squeeze()).item() for b in val_loader]
            val_loss = sum(val_losses) / len(val_losses)
            print(f"Epoch {epoch:3d}: train={total_loss/len(train_loader):.4f}  val={val_loss:.4f}")

    torch.save(model.state_dict(), "models/circuit_cost_gnn.pt")
    print("Model saved to models/circuit_cost_gnn.pt")
    return model


model = train_gnn(60)
```

**Verify:** Validation loss should fall below `0.5` (MSE on log10 scale) by epoch 60.

---

### Step 6: Quantum Volume Benchmark

**Goal:** Implement the QV protocol: generate random circuits, compute Heavy Output Probability, determine pass/fail.

```python
# src/qv_benchmark.py
import numpy as np
from typing import Optional


def generate_qv_circuit(num_qubits: int, depth: Optional[int] = None, seed: int = 0) -> list:
    """
    Generate a QV random circuit with `depth` layers of random SU(4) gates.
    Returns list of (gate_type, q0, q1, unitary_matrix) tuples.
    """
    if depth is None:
        depth = num_qubits
    rng = np.random.default_rng(seed)
    circuit = []

    for d in range(depth):
        perm = rng.permutation(num_qubits)
        for i in range(0, num_qubits - 1, 2):
            q0, q1 = int(perm[i]), int(perm[i + 1])
            U = np.linalg.qr(
                rng.standard_normal((4, 4)) + 1j * rng.standard_normal((4, 4))
            )[0]
            circuit.append(("SU4", q0, q1, U))

    return circuit


def simulate_qv_circuit(circuit: list, num_qubits: int) -> np.ndarray:
    """
    Simulate circuit to produce ideal probability distribution.
    Uses full statevector (exponential cost — keep num_qubits <= 12).
    """
    dim = 2 ** num_qubits
    state = np.zeros(dim, dtype=complex)
    state[0] = 1.0

    for gate_type, q0, q1, U in circuit:
        state = state.reshape([2] * num_qubits)
        axes = [q0, q1] + [i for i in range(num_qubits) if i not in (q0, q1)]
        state = np.transpose(state, axes)
        state = (U @ state.reshape(4, -1)).reshape([2] * num_qubits)
        inv_axes = [0] * num_qubits
        for new_pos, old_pos in enumerate(axes):
            inv_axes[old_pos] = new_pos
        state = np.transpose(state, inv_axes).reshape(-1)

    return np.abs(state) ** 2


def compute_hop(ideal_probs: np.ndarray, sampled_counts: dict, num_samples: int) -> float:
    """Compute Heavy Output Probability: fraction of samples above median ideal probability."""
    median_prob = np.median(ideal_probs)
    heavy_set = set(np.where(ideal_probs > median_prob)[0])
    heavy_samples = sum(c for idx, c in sampled_counts.items() if idx in heavy_set)
    return heavy_samples / num_samples if num_samples > 0 else 0.0


def run_qv_benchmark(num_qubits: int, num_trials: int = 50, noise_level: float = 0.02) -> dict:
    """
    Full QV benchmark run. Returns QV score, mean HOP, pass/fail.
    Noise model: depolarising with probability = noise_level * num_qubits.
    """
    dim = 2 ** num_qubits
    hops = []

    for trial in range(num_trials):
        circuit = generate_qv_circuit(num_qubits, seed=trial)
        ideal_probs = simulate_qv_circuit(circuit, num_qubits)

        # Depolarising noise
        noise = noise_level * num_qubits
        noisy_probs = (1 - noise) * ideal_probs + noise / dim
        noisy_probs /= noisy_probs.sum()

        sampled = np.random.default_rng(trial).multinomial(1000, noisy_probs)
        counts = {i: int(c) for i, c in enumerate(sampled) if c > 0}
        hops.append(compute_hop(ideal_probs, counts, 1000))

    mean_hop = float(np.mean(hops))
    passed = mean_hop > 2 / 3

    return {
        "num_qubits": num_qubits,
        "quantum_volume": 2 ** num_qubits if passed else 2 ** (num_qubits - 1),
        "mean_hop": round(mean_hop, 4),
        "std_hop": round(float(np.std(hops)), 4),
        "passed": passed,
    }


# Run QV benchmark for qubit counts 2 through 5
for n in [2, 3, 4, 5]:
    result = run_qv_benchmark(n, num_trials=30)
    status = "PASS" if result["passed"] else "FAIL"
    print(f"n={n}: QV={result['quantum_volume']:2d}  HOP={result['mean_hop']:.3f}  [{status}]")
```

**Verify:** Qubit counts 2 and 3 should pass (HOP > 0.667); higher qubit counts may fail due to the simulated noise model.

---

### Step 7: PostgreSQL Benchmark Schema

**Goal:** Design and apply the benchmark results database schema.

```sql
-- migrations/001_benchmark_schema.sql
CREATE TABLE IF NOT EXISTS benchmark_runs (
    id              SERIAL PRIMARY KEY,
    circuit_name    TEXT NOT NULL,
    circuit_family  TEXT NOT NULL,
    num_qubits      INT NOT NULL,
    circuit_depth   INT NOT NULL,
    gate_count      INT NOT NULL,
    bond_dim_max    INT,
    fidelity        FLOAT8,
    quantum_volume  INT,
    hop_score       FLOAT8,
    runtime_ms      FLOAT8 NOT NULL,
    flop_count      FLOAT8,
    gnn_predicted_ms FLOAT8,
    backend         TEXT NOT NULL DEFAULT 'mps',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    git_sha         TEXT
);

CREATE INDEX idx_bench_family ON benchmark_runs(circuit_family, num_qubits, created_at DESC);
CREATE INDEX idx_bench_date   ON benchmark_runs(created_at DESC);

CREATE VIEW v_daily_summary AS
SELECT
    DATE(created_at)    AS run_date,
    circuit_family,
    num_qubits,
    AVG(fidelity)       AS avg_fidelity,
    MIN(fidelity)       AS min_fidelity,
    AVG(runtime_ms)     AS avg_runtime_ms,
    COUNT(*)            AS num_runs
FROM benchmark_runs
GROUP BY DATE(created_at), circuit_family, num_qubits
ORDER BY run_date DESC, circuit_family, num_qubits;
```

**Verify:** Connect with `psql` and run `\d benchmark_runs` — all 15 columns should appear.

---

### Step 8: Flask Benchmark Dashboard

**Goal:** Build a Flask dashboard that renders benchmark results with Plotly charts.

```python
# src/dashboard.py
from flask import Flask, render_template_string, jsonify
import sqlalchemy as sa
import os

app = Flask(__name__)
engine = sa.create_engine(os.environ.get("DATABASE_URL", "postgresql://bench:password@localhost:5432/benchmarks"))

TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
  <title>Quantum Benchmark Dashboard</title>
  <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
  <style>body{background:#0d1117;color:#e6edf3;font-family:monospace;padding:2rem}</style>
</head>
<body>
  <h1>Tensor Network Benchmark Dashboard</h1>
  <div id="fidelity_chart" style="height:400px"></div>
  <div id="runtime_chart"  style="height:400px"></div>
  <script>
    fetch('/api/data').then(r => r.json()).then(data => {
      Plotly.newPlot('fidelity_chart', data.fidelity_traces, {
        title: 'MPS Fidelity vs Qubit Count',
        paper_bgcolor: '#0d1117', plot_bgcolor: '#161b22',
        font: {color: '#e6edf3'},
        xaxis: {title: 'Num Qubits'}, yaxis: {title: 'Avg Fidelity', range:[0,1]}
      });
      Plotly.newPlot('runtime_chart', data.runtime_traces, {
        title: 'Simulation Runtime vs Qubit Count',
        paper_bgcolor: '#0d1117', plot_bgcolor: '#161b22',
        font: {color: '#e6edf3'},
        xaxis: {title: 'Num Qubits'}, yaxis: {title: 'Runtime (ms)'},
        barmode: 'group'
      });
    });
  </script>
</body>
</html>
"""

@app.route("/")
def index():
    return render_template_string(TEMPLATE)


@app.route("/api/data")
def api_data():
    try:
        with engine.connect() as conn:
            rows = conn.execute(sa.text("""
                SELECT circuit_family, num_qubits,
                       AVG(fidelity) AS avg_fidelity,
                       AVG(runtime_ms) AS avg_runtime
                FROM benchmark_runs
                WHERE created_at > NOW() - INTERVAL '7 days'
                GROUP BY circuit_family, num_qubits
                ORDER BY circuit_family, num_qubits
            """)).fetchall()
    except Exception:
        rows = []

    families = list(dict.fromkeys(r[0] for r in rows))
    palette = ["#58a6ff", "#3fb950", "#d29922", "#f85149"]

    fidelity_traces = []
    runtime_traces = []
    for i, family in enumerate(families):
        fr = [r for r in rows if r[0] == family]
        fidelity_traces.append({
            "type": "scatter", "mode": "lines+markers",
            "name": family, "x": [r[1] for r in fr], "y": [r[2] for r in fr],
            "line": {"color": palette[i % len(palette)]},
        })
        runtime_traces.append({
            "type": "bar",
            "name": family, "x": [r[1] for r in fr], "y": [r[3] for r in fr],
            "marker": {"color": palette[i % len(palette)]},
        })

    return jsonify({"fidelity_traces": fidelity_traces, "runtime_traces": runtime_traces})


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
```

**Verify:** `python src/dashboard.py` then `curl -s localhost:5000/api/data | python -m json.tool` returns valid JSON with `fidelity_traces` and `runtime_traces` keys.

---

### Step 9: LSTM Benchmark Regression Detector

**Goal:** Train an LSTM to detect fidelity drift across nightly benchmark runs, and flag regressions automatically.

```python
# src/lstm_regression.py
import torch
import torch.nn as nn
import numpy as np


class BenchmarkLSTM(nn.Module):
    """LSTM that forecasts next-day fidelity from a 14-day history window."""

    def __init__(self, input_size: int = 3, hidden_size: int = 32, num_layers: int = 2):
        super().__init__()
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers,
                            batch_first=True, dropout=0.2)
        self.head = nn.Linear(hidden_size, 1)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: (batch, seq_len, input_size)
        out, _ = self.lstm(x)
        return self.head(out[:, -1, :]).squeeze(-1)


def generate_nightly_history(num_days: int = 90, drift_start: int = 70) -> np.ndarray:
    """
    Simulate nightly benchmark log: stable fidelity until drift_start, then degrading.
    Feature columns: [avg_fidelity, min_fidelity, runtime_ms_normalised].
    """
    rng = np.random.default_rng(42)
    data = []
    for day in range(num_days):
        base = 0.99 - max(0, day - drift_start) * 0.005
        avg_fid = float(base + rng.normal(0, 0.003))
        min_fid = float(avg_fid - rng.uniform(0.01, 0.03))
        rt_norm = float(0.5 + rng.normal(0, 0.05))
        data.append([avg_fid, min_fid, rt_norm])
    return np.array(data, dtype=np.float32)


def train_regression_lstm(history: np.ndarray, window: int = 14, epochs: int = 100):
    """Sliding-window LSTM training: predict next-day avg_fidelity."""
    X = np.stack([history[i:i + window] for i in range(len(history) - window)])
    y = history[window:, 0]

    X_t = torch.FloatTensor(X)
    y_t = torch.FloatTensor(y)

    model = BenchmarkLSTM()
    opt = torch.optim.Adam(model.parameters(), lr=1e-3)

    for epoch in range(epochs):
        opt.zero_grad()
        pred = model(X_t)
        loss = nn.MSELoss()(pred, y_t)
        loss.backward()
        opt.step()
        if epoch % 25 == 0:
            print(f"  Epoch {epoch}: loss={loss.item():.6f}")

    return model


history = generate_nightly_history()
model = train_regression_lstm(history)

# Predict next day from last 14-day window
last_window = torch.FloatTensor(history[-14:]).unsqueeze(0)
with torch.no_grad():
    predicted = model(last_window).item()
actual = history[-1, 0]
print(f"Predicted next-day fidelity: {predicted:.4f}")
print(f"Last actual fidelity:        {actual:.4f}")
print(f"Drift detected: {'YES' if predicted < 0.95 else 'NO'}")
```

**Verify:** The predicted fidelity near the drift region (days 70-90) should fall below 0.97, while early days predict near 0.99.

---

### Step 10: Docker Compose Deployment

**Goal:** Package simulator, dashboard, and database into a reproducible stack.

```yaml
# docker-compose.yml
version: "3.9"

services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: benchmarks
      POSTGRES_USER: bench
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./migrations:/docker-entrypoint-initdb.d

  dashboard:
    build: .
    command: python src/dashboard.py
    environment:
      DATABASE_URL: postgresql://bench:${POSTGRES_PASSWORD}@db:5432/benchmarks
    depends_on: [db]
    ports: ["5000:5000"]

  benchmark_worker:
    build: .
    command: python src/run_benchmarks.py --circuits ghz,qv --max-qubits 8
    environment:
      DATABASE_URL: postgresql://bench:${POSTGRES_PASSWORD}@db:5432/benchmarks
    depends_on: [db]
    restart: on-failure

volumes:
  postgres_data:
```

```dockerfile
# Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
```

**Verify:** `docker compose up --build` starts three services. `docker compose ps` shows all running.

---

### Step 11: GitHub Actions Nightly CI

**Goal:** Automate nightly benchmark runs with fidelity regression detection.

```yaml
# .github/workflows/nightly_benchmark.yml
name: Nightly Benchmark

on:
  schedule:
    - cron: "0 2 * * *"
  workflow_dispatch:

jobs:
  benchmark:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_DB: benchmarks
          POSTGRES_USER: bench
          POSTGRES_PASSWORD: test
        ports: ["5432:5432"]
        options: >-
          --health-cmd pg_isready
          --health-interval 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: {python-version: "3.11"}

      - run: pip install -r requirements.txt

      - name: Apply migrations
        run: psql postgresql://bench:test@localhost:5432/benchmarks -f migrations/001_benchmark_schema.sql

      - name: Run benchmark suite
        run: python src/run_benchmarks.py --circuits ghz,qv --max-qubits 8
        env:
          DATABASE_URL: postgresql://bench:test@localhost:5432/benchmarks

      - name: Fidelity regression check
        run: |
          python -c "
          import sqlalchemy as sa, sys, os
          engine = sa.create_engine(os.environ['DATABASE_URL'])
          with engine.connect() as c:
              row = c.execute(sa.text(
                  \"SELECT AVG(fidelity) FROM benchmark_runs WHERE created_at > NOW() - INTERVAL '1 day'\"
              )).fetchone()
              fid = row[0] or 0
              print(f'Mean fidelity: {fid:.4f}')
              sys.exit(0 if fid >= 0.90 else 1)
          "
        env:
          DATABASE_URL: postgresql://bench:test@localhost:5432/benchmarks
```

**Verify:** Manually trigger `workflow_dispatch` from the GitHub Actions tab — the pipeline should pass.

---

### Step 12: Full Test Suite

**Goal:** Unit and integration tests covering the simulator, benchmarks, and GNN.

```python
# tests/test_mps_simulator.py
import numpy as np
import pytest
from src.mps_simulator import build_ghz_mps, mps_to_statevector, ghz_state_exact


def test_ghz_fidelity_4_qubits():
    tensors = build_ghz_mps(4)
    sv = mps_to_statevector(tensors)
    exact = ghz_state_exact(4).full().flatten()
    fidelity = abs(np.vdot(exact, sv)) ** 2
    assert fidelity > 0.9999


def test_mps_state_is_normalised():
    tensors = build_ghz_mps(5)
    sv = mps_to_statevector(tensors)
    assert abs(np.linalg.norm(sv) - 1.0) < 1e-6


def test_ghz_has_two_dominant_amplitudes():
    tensors = build_ghz_mps(4)
    sv = mps_to_statevector(tensors)
    probs = np.abs(sv) ** 2
    assert np.sum(probs > 0.01) == 2


# tests/test_qv_benchmark.py
from src.qv_benchmark import generate_qv_circuit, compute_hop, run_qv_benchmark
import numpy as np


def test_qv_circuit_not_empty():
    circuit = generate_qv_circuit(4)
    assert len(circuit) > 0


def test_hop_perfect_prediction():
    ideal = np.zeros(8)
    ideal[3] = 1.0
    hop = compute_hop(ideal, {3: 500}, 500)
    assert hop == 1.0


def test_hop_uniform_distribution():
    n = 3
    ideal = np.ones(2 ** n) / 2 ** n
    counts = {i: 1 for i in range(2 ** n)}
    hop = compute_hop(ideal, counts, 2 ** n)
    assert 0.4 < hop < 0.6


def test_qv_benchmark_2_qubits_passes():
    result = run_qv_benchmark(num_qubits=2, num_trials=20)
    assert result["passed"] is True
```

**Verify:** `pytest tests/ -v` — all 7 tests green in under 60 seconds.

---

## Testing

```bash
# Unit + integration tests
pytest tests/ -v --tb=short

# Type checking
mypy src/ --ignore-missing-imports

# Manual benchmark run (no Docker needed)
python src/run_benchmarks.py --circuits ghz --max-qubits 6

# Launch dashboard locally (requires PostgreSQL)
python src/dashboard.py
```

---

## Deployment

```bash
cp .env.example .env   # set POSTGRES_PASSWORD
docker compose up -d --build

# Apply migrations
docker compose exec db psql -U bench benchmarks -f /docker-entrypoint-initdb.d/001_benchmark_schema.sql

# Open dashboard
open http://localhost:5000
```

---

## Resources

1. [Orus (2014) — A Practical Introduction to Tensor Networks](https://arxiv.org/abs/1306.2164) — Canonical MPS/PEPS/MERA review
2. [QuTiP Documentation](https://qutip.org/docs/latest/) — Quantum Toolbox in Python reference
3. [opt_einsum Documentation](https://optimized-einsum.readthedocs.io/) — Contraction path optimisation
4. [PyTorch Geometric Documentation](https://pytorch-geometric.readthedocs.io/) — GNN library reference
5. [JAX Documentation](https://jax.readthedocs.io/) — JIT compilation and vmap guide
6. [Cross et al. (2019) — Validating Quantum Computers Using Randomized Model Circuits](https://arxiv.org/abs/1811.12926) — Quantum Volume protocol
7. [Villalonga et al. (2019) — Flexible Tensor Network Simulation of Google's Supremacy Circuit](https://www.nature.com/articles/s41534-019-0196-1) — Industrial tensor contraction reference
8. [QASMBench](https://github.com/pnnl/QASMBench) — Reference quantum circuit benchmark library
