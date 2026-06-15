# QP02 — Rydberg Neutral-Atom QAOA for Logistics Route Optimisation

**Modality:** Neutral-atom (Pasqal / Pulser SDK) **Phase:** 2B **Track:** `hpc-quantum` **Status:** not started **Hours target:** 40

## Business Problem

Last-mile delivery operations with 500+ stops per route face a combinatorial optimisation problem that scales exponentially: classical metaheuristics (simulated annealing, genetic algorithms) stall in quality as stop counts grow and cannot provide sub-second route updates during peak demand windows. Rydberg neutral-atom quantum processors offer a native mapping for Maximum Independent Set and QUBO problems via the Rydberg blockade mechanism — without requiring qubit-by-qubit gate decomposition. This project builds a QAOA pipeline on Pasqal hardware that accepts live delivery requests via REST, encodes vehicle routing constraints as a QUBO Hamiltonian, executes Pulser pulse sequences, and caches optimised routes in Redis for sub-100ms retrieval.

## What you will build

1. A QUBO encoder that translates vehicle routing constraints (capacity, time windows, depot return) into an Ising Hamiltonian and registers atom positions for Pulser register geometry
2. A Pulser SDK pulse sequence implementing QAOA with p=3 layers, tuned via JAX-based gradient optimisation of beta/gamma variational parameters
3. A Pasqal cloud API submission wrapper with job polling, result decoding, and fallback to the Pulser EMU-TN (tensor network) emulator
4. A FastAPI service accepting POST requests with delivery stop coordinates and returning ranked route proposals within a configurable timeout
5. A Redis route cache (TTL 300 s) that serves pre-computed routes for recurring stop patterns, bypassing the quantum circuit for known configurations
6. A Docker-composed production stack (API + Redis + PostgreSQL) with GitHub Actions CI running QAOA unit tests against the Pulser local emulator

## Architecture

```
Delivery request (stops + constraints)
     |
     v
[FastAPI /optimise endpoint]
     |
     v
[QUBO Encoder]
Vehicle routing constraints -> Ising/QUBO Hamiltonian
     |
     v
[Redis cache lookup]  --- HIT -->  cached route (< 5 ms)
     |
     MISS
     v
[Pulser Register Builder]
Stop coordinates -> neutral-atom register (2D positions in µm)
     |
     v
[QAOA Pulse Sequence (p=3)]
Problem Hamiltonian (Rydberg blockade) + Mixing Hamiltonian
     |
     |--- Pulser EMU-TN emulator (dev/staging) --> bitstring samples
     |--- Pasqal cloud QPU (production) --------> bitstring samples
     |
     v
[JAX Variational Optimiser]
Outer loop: optimise beta_i, gamma_i parameters
     |
     v
[Route Decoder]
Best bitstring -> ordered delivery sequence
     |
     v
[Redis cache WRITE + PostgreSQL audit log]
     |
     v
JSON: { route, total_distance, quantum_advantage_score }
```

## Theory prerequisites

| Skill ID | Concept | Why you need it |
|----------|---------|-----------------|
| QSK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notation) | Register states are superpositions over all possible route assignments; bra-ket encodes the blockade constraint |
| QSK02 | Quantum Measurement Theory (Born Rule) | Route proposals are sampled from the Born-rule distribution of the QAOA output state |
| QSK04 | Quantum Gate Model & Clifford+T Gate Sets | Pulser implements analog pulse sequences rather than digital gates; understanding gate model clarifies what QAOA replaces |
| QSK11 | Rydberg Atom Physics & Dipole Blockade | The blockade radius defines the constraint graph; atom spacing directly encodes problem structure |
| QSK12 | Optical Tweezer Trap Design & Manipulation | Pasqal registers are defined by tweezer positions; trap parameters constrain achievable atom spacings |
| QSK13 | Laser Cooling (Doppler & Sub-Doppler Mechanisms) | Ground-state cooling is required before every computation; heating rates limit circuit duration |
| QSK14 | QAOA Algorithm & Circuit Design | The QAOA ansatz alternates problem and mixing Hamiltonians; p layers determine approximation quality |
| QSK15 | Constraint Embedding for QUBO & Ising Models | Vehicle routing constraints (capacity, time windows) must be encoded as Ising penalty terms before mapping to blockade interactions |

## Engineering skills covered

| Skill ID | Skill | What you practice |
|----------|-------|------------------|
| QSK28 | AI-Assisted Circuit Optimisation | Use a PyTorch GNN to predict good beta/gamma initial parameters, reducing classical optimisation iterations |
| QSK29 | Real-Time Inference Acceleration | Meet sub-100 ms route update SLA via ONNX-exported parameter predictor and async FastAPI job submission |
| QSK30 | QUBO & Ising Model Formulation | Translate capacity constraints, binary stop-assignment variables, and distance objectives into QUBO penalty matrix |
| QSK35 | CI/CD & GitHub Actions | Workflow runs QAOA unit tests against Pulser EMU-MPS emulator; no Pasqal cloud credentials required |
| QSK36 | Distributed Systems & Caching (Redis) | Redis SETEX for route TTL, pub/sub for real-time dispatch notifications to delivery agents |
| QSK37 | Cache-Aware Algorithm Design | Batch incoming delivery requests to share register preparation cost; exploit spatial locality in stop clustering |

## Tools & dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| Pulser SDK | Rydberg atom pulse sequence design and emulation | `pip install pulser pulser-simulation` |
| JAX | Gradient-based optimisation of QAOA variational parameters | `pip install jax jaxlib optax` |
| FastAPI | Async REST API for delivery request intake | `pip install fastapi uvicorn[standard]` |
| Redis | Route cache, TTL management, pub/sub notifications | `pip install redis` |
| PostgreSQL | Audit log: job id, stops, route quality, QPU backend | `docker pull postgres:16` |
| Docker | Containerised service stack | `apt install docker.io docker-compose-plugin` |
| GitHub Actions | CI pipeline: QAOA unit tests on Pulser emulator | Configured in `.github/workflows/` |

## Prerequisites

**Complete these theory modules first:**
- [ ] `hpc-quantum/02-quantum-intro` — Quantum gates, circuits, variational algorithms
- [ ] `q-theory-01-hilbert-spaces` — Multi-qubit state representations
- [ ] `q-theory-11-rydberg-physics` — Blockade radius, Rabi frequencies, Rydberg states
- [ ] `q-theory-12-optical-tweezers` — Tweezer arrays, register geometry, trap depth
- [ ] `q-theory-14-qaoa` — QAOA ansatz, p-layer depth, approximation ratio
- [ ] `q-theory-15-qubo` — QUBO/Ising mapping, constraint penalties, variable encoding

**Access / accounts needed:**
- [ ] Pasqal cloud account (access via `cloud.pasqal.com`; free trial available for emulator access)
- [ ] Redis server (local via Docker: `docker run -p 6379:6379 redis:7`)
- [ ] Docker and Docker Compose installed

## Step-by-step tutorial

---

### Step 1: Environment setup (Python + Pulser SDK)

**Goal:** Install the Pulser SDK, verify the local emulator runs correctly, and confirm JAX autodiff works for parameter optimisation.

**Code:**
```bash
python -m venv .venv && source .venv/bin/activate

pip install "pulser>=0.18" pulser-simulation
pip install jax jaxlib optax   # CPU-only; use jax[cuda12] for GPU
pip install fastapi uvicorn[standard] redis sqlalchemy asyncpg psycopg2-binary

# Smoke test: simple two-atom register
python - <<'EOF'
import pulser
from pulser import Pulse, Sequence, Register
from pulser.devices import AnalogDevice
from pulser_simulation import QutipEmulator
import numpy as np

# Two-atom register separated by 5 µm
reg = Register.from_coordinates([(0, 0), (5, 0)], prefix="q")
seq = Sequence(reg, AnalogDevice)
seq.declare_channel("ryd_glob", "rydberg_global")

# Short resonant pulse (pi/2 rotation)
pulse = Pulse.ConstantPulse(duration=500, amplitude=np.pi, detuning=0, phase=0)
seq.add(pulse, "ryd_glob")
seq.measure("ground-rydberg")

sim = QutipEmulator.from_sequence(seq)
result = sim.run()
counts = result.sample_final_state(N_samples=500)
print("Counts:", dict(list(counts.items())[:4]))
print("Pulser version:", pulser.__version__)
EOF
```

**Verify:** Counts dictionary shows population split across ground/Rydberg states. Pulser version >= 0.18.

---

### Step 2: Theory warm-up — implement Rydberg blockade and Maximum Independent Set

**Goal:** Encode a 4-node graph as a Rydberg atom register and run a simple pulse sequence to demonstrate the blockade constraint. No two adjacent atoms (within blockade radius) can simultaneously be in the Rydberg state.

**Code:**
```python
# src/warmup/mis_blockade.py
"""
Demonstrate Maximum Independent Set via Rydberg blockade on a 4-node cycle graph.
Nodes placed so adjacent nodes are within blockade radius Rb ~ 7.5 um,
diagonal pairs are beyond Rb and can both be excited.
"""
import numpy as np
from pulser import Register, Sequence, Pulse
from pulser.devices import AnalogDevice
import pulser.waveforms as wf
from pulser_simulation import QutipEmulator

# 4-node cycle: square with 6 um sides
# Adjacent separation = 6 um < Rb; diagonal = 6*sqrt(2) ~ 8.5 um > Rb
coords = [(0, 0), (6, 0), (6, 6), (0, 6)]
reg = Register.from_coordinates(coords, prefix="q")

Rb = AnalogDevice.rydberg_blockade_radius(Omega=np.pi)
print(f"Blockade radius: {Rb:.2f} um")
print(f"Adjacent: 6.00 um < {Rb:.2f} -> BLOCKADED (no simultaneous excitation)")
print(f"Diagonal: {6*np.sqrt(2):.2f} um > {Rb:.2f} -> free")

# Adiabatic detuning sweep: ramp from negative (superposition) to positive (classical MIS)
duration = 4000  # ns
seq = Sequence(reg, AnalogDevice)
seq.declare_channel("ryd_glob", "rydberg_global")
seq.add(
    Pulse(
        amplitude=wf.ConstantWaveform(duration, np.pi),
        detuning=wf.RampWaveform(duration, -5 * np.pi, 5 * np.pi),
        phase=0,
    ),
    "ryd_glob",
)
seq.measure("ground-rydberg")

sim = QutipEmulator.from_sequence(seq)
result = sim.run()
counts = result.sample_final_state(N_samples=2000)

print("\nTop bitstring outcomes (r=Rydberg, g=ground):")
for state, cnt in sorted(counts.items(), key=lambda x: -x[1])[:6]:
    print(f"  {state}: {cnt}")
# MIS of 4-cycle: {0,2}='rgrg' and {1,3}='grgr' should dominate
```

**Verify:** States `"rgrg"` and `"grgr"` (alternating pattern) dominate the output, confirming the blockade correctly enforces the independence constraint.

---

### Step 3: Problem formulation — vehicle routing to QUBO to Rydberg register

**Goal:** Encode a simplified Capacitated Vehicle Routing Problem (CVRP) with 6 stops as a QUBO, then map the interaction graph to a neutral-atom register.

**Code:**
```python
# src/qubo/routing_encoder.py
import numpy as np
from dataclasses import dataclass
from typing import List, Tuple

@dataclass
class DeliveryStop:
    id: int
    x: float    # km
    y: float    # km
    demand: float  # kg

def distance_matrix(stops: List[DeliveryStop]) -> np.ndarray:
    n = len(stops)
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            D[i, j] = np.sqrt((stops[i].x - stops[j].x)**2 +
                               (stops[i].y - stops[j].y)**2)
    return D

def build_cvrp_qubo(
    stops: List[DeliveryStop],
    vehicle_capacity: float,
    penalty_capacity: float = 10.0,
    penalty_visit_once: float = 10.0,
) -> Tuple[np.ndarray, List[str]]:
    """
    Encode CVRP as QUBO for a 2-vehicle, n-stop instance.
    Binary variable x_{i,k} = 1 if vehicle k visits stop i.
    Total variables: n_stops * n_vehicles.
    """
    n = len(stops)
    n_vehicles = 2
    n_vars = n * n_vehicles
    Q = np.zeros((n_vars, n_vars))
    D = distance_matrix(stops)

    def idx(i: int, k: int) -> int:
        return i + k * n

    # Objective: minimise total distance
    for k in range(n_vehicles):
        for i in range(n):
            for j in range(n):
                if i != j:
                    Q[idx(i, k), idx(j, k)] += D[i, j]

    # Constraint: each stop visited exactly once across all vehicles
    # (sum_k x_{i,k} - 1)^2 expanded
    for i in range(n):
        for k1 in range(n_vehicles):
            Q[idx(i, k1), idx(i, k1)] += penalty_visit_once * (-1)
            for k2 in range(n_vehicles):
                Q[idx(i, k1), idx(i, k2)] += penalty_visit_once

    # Constraint: vehicle capacity not exceeded
    for k in range(n_vehicles):
        for i in range(n):
            for j in range(n):
                coeff = penalty_capacity * stops[i].demand * stops[j].demand / vehicle_capacity**2
                Q[idx(i, k), idx(j, k)] += coeff

    var_names = [f"x_{i}_{k}" for k in range(n_vehicles) for i in range(n)]
    return Q, var_names

def qubo_to_register_positions(Q: np.ndarray, scale_um: float = 10.0) -> np.ndarray:
    """Map QUBO graph to 2D atom positions using spring layout."""
    import networkx as nx
    n = Q.shape[0]
    G = nx.from_numpy_array(np.abs(Q))
    pos = nx.spring_layout(G, seed=42, k=2.0)
    coords = np.array([[pos[i][0], pos[i][1]] for i in range(n)])
    coords *= scale_um
    return coords

if __name__ == "__main__":
    stops = [
        DeliveryStop(0, 0.0, 0.0, 5.0),
        DeliveryStop(1, 2.0, 1.0, 10.0),
        DeliveryStop(2, 3.5, 0.5, 8.0),
        DeliveryStop(3, 1.0, 3.0, 12.0),
        DeliveryStop(4, 4.0, 2.0, 9.0),
        DeliveryStop(5, 2.5, 4.0, 7.0),
    ]
    Q, names = build_cvrp_qubo(stops, vehicle_capacity=30.0)
    print(f"QUBO shape: {Q.shape}  (6 stops x 2 vehicles = 12x12)")
    print(f"Variables: {names}")
    coords = qubo_to_register_positions(Q)
    print(f"First 4 register positions (um):\n{coords[:4]}")
```

**Verify:** 12x12 QUBO matrix. Register coordinates within typical Pasqal device bounds (< 50 um spacing per atom pair).

---

### Step 4: Circuit design — QAOA pulse sequence with Pulser

**Goal:** Implement a p=2 QAOA sequence using the atom register from Step 3. The sequence alternates problem Hamiltonian pulses (off-resonant detuning via blockade) with mixing Hamiltonian pulses (resonant Rabi drive).

**Code:**
```python
# src/qaoa/pulse_builder.py
import numpy as np
from pulser import Register, Sequence, Pulse
from pulser.devices import AnalogDevice
import pulser.waveforms as wf

def build_qaoa_sequence(
    atom_coords: np.ndarray,
    gammas: list[float],
    betas: list[float],
    omega: float = np.pi,
    pulse_duration_ns: int = 1000,
) -> Sequence:
    """
    Build a p-layer QAOA pulse sequence for neutral atoms.

    Problem unitary U_P(gamma): large-detuning pulse
      -> encodes Ising interactions via Rydberg blockade
    Mixing unitary U_M(beta): resonant Rabi drive with phase beta
      -> rotations on the Bloch sphere (acts like QAOA mixer H_B = sum_i X_i)
    """
    assert len(gammas) == len(betas), "Need matching gammas and betas"
    p = len(gammas)

    # Build register
    reg_dict = {f"q{i}": tuple(atom_coords[i]) for i in range(len(atom_coords))}
    reg = Register(reg_dict)

    seq = Sequence(reg, AnalogDevice)
    seq.declare_channel("ryd_glob", "rydberg_global")

    # Initialisation: global pi/2 pulse to create equal superposition
    seq.add(
        Pulse.ConstantPulse(pulse_duration_ns // 2, omega, 0, phase=0),
        "ryd_glob",
    )

    for layer in range(p):
        # Problem phase: off-resonant with large positive detuning (encodes H_C)
        delta_problem = 5 * omega * gammas[layer] / np.pi
        seq.add(
            Pulse.ConstantPulse(pulse_duration_ns, omega * 0.3, delta_problem, phase=0),
            "ryd_glob",
        )
        # Mixing phase: resonant drive, phase encodes beta (rotates around Z on Bloch sphere)
        seq.add(
            Pulse.ConstantPulse(pulse_duration_ns, omega, 0, phase=betas[layer]),
            "ryd_glob",
        )

    seq.measure("ground-rydberg")
    return seq

if __name__ == "__main__":
    from pulser_simulation import QutipEmulator

    coords = np.array([[0, 0], [6, 0], [12, 0], [18, 0]], dtype=float)
    gammas = [np.pi / 3, np.pi / 4]
    betas  = [np.pi / 4, np.pi / 6]
    seq = build_qaoa_sequence(coords, gammas, betas)
    print(seq.draw())

    sim = QutipEmulator.from_sequence(seq)
    result = sim.run()
    counts = result.sample_final_state(N_samples=1000)
    print("Top 5 bitstrings:")
    for s, c in sorted(counts.items(), key=lambda x: -x[1])[:5]:
        print(f"  {s}: {c}")
```

**Verify:** Sequence builds without error for p=2. Top outcomes on a 4-atom line instance are the alternating MIS states.

---

### Step 5: Classical optimizer / variational loop

**Goal:** Use JAX + Optax to optimise the QAOA variational parameters (gammas, betas) via finite-difference gradient estimates against the Pulser emulator cost function.

**Code:**
```python
# src/qaoa/jax_optimizer.py
import numpy as np
import optax

def evaluate_qaoa_cost(
    gammas: np.ndarray,
    betas: np.ndarray,
    atom_coords: np.ndarray,
    Q: np.ndarray,
    n_samples: int = 500,
) -> float:
    """Expected QUBO cost over QAOA bitstring samples."""
    from pulser_simulation import QutipEmulator
    from qaoa.pulse_builder import build_qaoa_sequence

    seq = build_qaoa_sequence(atom_coords, gammas.tolist(), betas.tolist())
    sim = QutipEmulator.from_sequence(seq)
    result = sim.run()
    counts = result.sample_final_state(N_samples=n_samples)

    total_cost, total_count = 0.0, 0
    for bitstring, count in counts.items():
        x = np.array([1 if c == "r" else 0 for c in bitstring[:Q.shape[0]]])
        total_cost += float(x @ Q @ x) * count
        total_count += count
    return total_cost / max(total_count, 1)

def optimize_qaoa(
    atom_coords: np.ndarray,
    Q: np.ndarray,
    p: int = 2,
    n_steps: int = 60,
    lr: float = 0.05,
    eps: float = 0.05,
) -> dict:
    """Finite-difference gradient descent with Optax Adam."""
    rng = np.random.default_rng(42)
    gammas = rng.uniform(0, np.pi, p)
    betas  = rng.uniform(0, np.pi, p)

    optimizer = optax.adam(lr)
    opt_state = optimizer.init({"gammas": gammas, "betas": betas})
    cost_history = []

    for step in range(n_steps):
        cost = evaluate_qaoa_cost(gammas, betas, atom_coords, Q)
        cost_history.append(cost)

        grad_g = np.zeros(p)
        grad_b = np.zeros(p)
        for i in range(p):
            gp = gammas.copy(); gp[i] += eps
            gm = gammas.copy(); gm[i] -= eps
            grad_g[i] = (evaluate_qaoa_cost(gp, betas, atom_coords, Q) -
                         evaluate_qaoa_cost(gm, betas, atom_coords, Q)) / (2 * eps)
            bp = betas.copy(); bp[i] += eps
            bm = betas.copy(); bm[i] -= eps
            grad_b[i] = (evaluate_qaoa_cost(gammas, bp, atom_coords, Q) -
                         evaluate_qaoa_cost(gammas, bm, atom_coords, Q)) / (2 * eps)

        grads = {"gammas": grad_g, "betas": grad_b}
        updates, opt_state = optimizer.update(grads, opt_state)
        params = optax.apply_updates({"gammas": gammas, "betas": betas}, updates)
        gammas, betas = params["gammas"], params["betas"]

        if step % 10 == 0:
            print(f"Step {step:3d} | Cost: {cost:.4f}")

    return {"optimal_gammas": gammas, "optimal_betas": betas, "cost_history": cost_history}
```

**Verify:** Cost decreases over 60 steps. Final cost should be 10-30% lower than random parameters.

---

### Step 6: Error mitigation

**Goal:** Apply readout error mitigation using a per-atom calibration matrix to correct for Rydberg state detection errors (typical fidelity 97% on Pasqal hardware).

**Code:**
```python
# src/mitigation/readout_correction.py
import numpy as np

def build_readout_calibration(n_atoms: int, single_qubit_fidelity: float = 0.97) -> np.ndarray:
    """
    Build 2^n x 2^n calibration matrix assuming independent per-atom readout errors.
    Cal[j, i] = P(observe j | prepared i).
    """
    n_states = 2 ** n_atoms
    p_err = 1 - single_qubit_fidelity
    cal = np.zeros((n_states, n_states))
    for i in range(n_states):
        for j in range(n_states):
            n_flips = bin(i ^ j).count('1')
            cal[j, i] = (single_qubit_fidelity ** (n_atoms - n_flips)) * (p_err ** n_flips)
    return cal

def apply_readout_correction(
    raw_counts: dict[str, int],
    cal: np.ndarray,
    n_atoms: int,
) -> dict[str, float]:
    """Return corrected probability distribution."""
    n_states = 2 ** n_atoms
    raw_vec = np.zeros(n_states)
    total = sum(raw_counts.values())

    for bs, cnt in raw_counts.items():
        idx = int("".join("1" if c == "r" else "0" for c in bs[:n_atoms]), 2)
        raw_vec[idx] = cnt / total

    corrected = np.linalg.lstsq(cal, raw_vec, rcond=None)[0]
    corrected = np.clip(corrected, 0, None)
    if corrected.sum() > 0:
        corrected /= corrected.sum()

    result = {}
    for idx in range(n_states):
        if corrected[idx] > 1e-4:
            bs = "".join("r" if b == "1" else "g" for b in format(idx, f"0{n_atoms}b"))
            result[bs] = float(corrected[idx])
    return result

if __name__ == "__main__":
    cal = build_readout_calibration(4, single_qubit_fidelity=0.97)
    # Noisy counts: true MIS states diluted by readout error
    raw = {"rgrg": 420, "grgr": 400, "rrrg": 80, "ggrg": 60, "gggg": 40}
    corrected = apply_readout_correction(raw, cal, 4)
    print("Corrected probabilities:")
    for s, p in sorted(corrected.items(), key=lambda x: -x[1])[:5]:
        print(f"  {s}: {p:.4f}")
```

**Verify:** After correction, `"rgrg"` and `"grgr"` probabilities increase (spurious states reduced). Corrected distribution sums to 1.0.

---

### Step 7: Hardware execution (Pulser emulator first, then Pasqal cloud QPU)

**Goal:** Execute the optimised QAOA sequence on (1) the local QuTiP emulator, (2) Pasqal cloud EMU-TN tensor-network emulator, and (3) submit to Pasqal Fresnel-1 QPU.

**Code:**
```python
# src/qaoa/hardware_runner.py
from enum import Enum

class PasqalBackend(str, Enum):
    LOCAL_EMU  = "pulser_qutip"
    CLOUD_EMU  = "pasqal_emu_tn"
    CLOUD_QPU  = "pasqal_fresnel1"

def run_qaoa_on_backend(
    sequence,
    backend: PasqalBackend,
    n_samples: int = 1000,
) -> dict[str, int]:
    """Execute sequence and return raw bitstring counts."""

    # --- Local: QuTiP emulator (no credentials needed) ---
    if backend == PasqalBackend.LOCAL_EMU:
        from pulser_simulation import QutipEmulator
        sim = QutipEmulator.from_sequence(sequence)
        result = sim.run()
        return dict(result.sample_final_state(N_samples=n_samples))

    # --- Cloud: Pasqal EMU-TN tensor-network emulator ---
    elif backend == PasqalBackend.CLOUD_EMU:
        import os, time
        from pasqal_cloud import SDK, EmulatorType

        sdk = SDK(
            username=os.environ["PASQAL_USERNAME"],
            password=os.environ["PASQAL_PASSWORD"],
            project_id=os.environ["PASQAL_PROJECT_ID"],
        )
        batch = sdk.create_batch(
            serialized_sequence=sequence.to_abstract_repr(),
            jobs=[{"runs": n_samples, "variables": {}}],
            emulator=EmulatorType.EMU_TN,
        )
        print(f"EMU-TN batch submitted: {batch.id}")
        while batch.status not in ("DONE", "ERROR", "CANCELED"):
            time.sleep(10)
            batch.refresh()
            print(f"  Status: {batch.status}")
        if batch.status != "DONE":
            raise RuntimeError(f"Batch failed: {batch.status}")
        counts: dict[str, int] = {}
        for run in batch.jobs[0].result:
            for state, count in run.items():
                counts[state] = counts.get(state, 0) + count
        return counts

    # --- Real QPU: Pasqal Fresnel-1 ---
    elif backend == PasqalBackend.CLOUD_QPU:
        import os, time
        from pasqal_cloud import SDK
        from pulser.devices import Fresnel

        sdk = SDK(
            username=os.environ["PASQAL_USERNAME"],
            password=os.environ["PASQAL_PASSWORD"],
            project_id=os.environ["PASQAL_PROJECT_ID"],
        )
        # Adapt sequence to Fresnel-1 device constraints
        seq_qpu = sequence.switch_device(Fresnel, strict=False)
        batch = sdk.create_batch(
            serialized_sequence=seq_qpu.to_abstract_repr(),
            jobs=[{"runs": n_samples, "variables": {}}],
        )
        print(f"Fresnel-1 QPU batch submitted: {batch.id}")
        while batch.status not in ("DONE", "ERROR", "CANCELED"):
            time.sleep(30)
            batch.refresh()
            print(f"  Status: {batch.status}")
        counts: dict[str, int] = {}
        for run in batch.jobs[0].result:
            for state, count in run.items():
                counts[state] = counts.get(state, 0) + count
        return counts

if __name__ == "__main__":
    import numpy as np
    from qaoa.pulse_builder import build_qaoa_sequence

    coords = np.array([[0, 0], [6, 0], [12, 0], [18, 0]], dtype=float)
    seq = build_qaoa_sequence(coords, gammas=[np.pi/3], betas=[np.pi/4])
    counts = run_qaoa_on_backend(seq, PasqalBackend.LOCAL_EMU, 500)
    print("Local results:", dict(list(sorted(counts.items(), key=lambda x: -x[1]))[:5]))
```

**Verify:** Local emulator finishes in < 30 seconds for 4 atoms. EMU-TN finishes in < 10 minutes. QPU requires Pasqal account and may queue for hours.

---

### Step 8: Classical post-processing and result interpretation

**Goal:** Decode QAOA bitstring samples into route proposals, rank by total distance and constraint violations, and compute approximation ratio versus brute-force optimal.

**Code:**
```python
# src/routing/decoder.py
import numpy as np
from dataclasses import dataclass
from typing import List

@dataclass
class RouteProposal:
    vehicle_0_stops: List[int]
    vehicle_1_stops: List[int]
    total_distance: float
    constraint_violations: int

def decode_bitstring(
    bitstring: str,
    stops,
    n_vehicles: int = 2,
) -> RouteProposal:
    n = len(stops)
    x = [1 if c == "r" else 0 for c in bitstring[:n * n_vehicles]]

    from qubo.routing_encoder import distance_matrix
    D = distance_matrix(stops)

    vehicle_stops = []
    for k in range(n_vehicles):
        vehicle_stops.append([i for i in range(n) if x[i + k * n] == 1])

    total_dist = 0.0
    for k in range(n_vehicles):
        route = vehicle_stops[k]
        for j in range(len(route) - 1):
            total_dist += D[route[j], route[j + 1]]

    violations = sum(
        1 for i in range(n)
        if sum(x[i + k * n] for k in range(n_vehicles)) != 1
    )
    return RouteProposal(vehicle_stops[0], vehicle_stops[1], total_dist, violations)

def rank_routes(
    counts: dict[str, int],
    stops,
    top_k: int = 5,
) -> List[RouteProposal]:
    proposals = []
    for bs, cnt in sorted(counts.items(), key=lambda x: -x[1])[:50]:
        proposals.append((decode_bitstring(bs, stops), cnt))
    proposals.sort(key=lambda x: (x[0].constraint_violations, x[0].total_distance))
    return [p for p, _ in proposals[:top_k]]

if __name__ == "__main__":
    from qubo.routing_encoder import DeliveryStop
    stops = [DeliveryStop(i, float(i), 0.0, 5.0) for i in range(4)]
    counts = {"rgrgrgrg": 200, "grgrgrg": 180, "rrrrgrgr": 50}
    routes = rank_routes(counts, stops)
    for i, r in enumerate(routes):
        print(f"Route {i+1}: V0={r.vehicle_0_stops} V1={r.vehicle_1_stops} "
              f"dist={r.total_distance:.2f} violations={r.constraint_violations}")
```

**Verify:** Top-ranked route has 0 constraint violations. Approximation ratio (quantum/classical optimal) between 0.7 and 1.0 for small instances.

---

### Step 9: REST API wrapper

**Goal:** FastAPI service that accepts delivery stops, checks Redis cache, submits QAOA job, and returns ranked routes.

**Code:**
```python
# src/api/main.py
from fastapi import FastAPI, HTTPException, BackgroundTasks
from pydantic import BaseModel, Field
from typing import List, Optional
import uuid, datetime, json, os
import redis.asyncio as aioredis

app = FastAPI(title="QAOA Logistics API", version="0.1.0")
redis_client = aioredis.from_url(os.environ.get("REDIS_URL", "redis://localhost:6379"))
CACHE_TTL = 300

class Stop(BaseModel):
    id: int
    x: float
    y: float
    demand: float = Field(..., ge=0)

class RouteRequest(BaseModel):
    stops: List[Stop] = Field(..., min_length=2, max_length=12)
    vehicle_capacity: float = Field(default=30.0, ge=1.0)
    qaoa_layers: int = Field(default=2, ge=1, le=5)
    backend: str = Field(default="pulser_qutip")

class RouteResponse(BaseModel):
    job_id: str
    status: str
    cache_hit: bool = False
    routes: Optional[list] = None
    submitted_at: str

_jobs: dict[str, dict] = {}

@app.post("/optimise", response_model=RouteResponse, status_code=202)
async def optimise(req: RouteRequest, bg: BackgroundTasks):
    cache_key = f"route:{','.join(str(s.id) for s in sorted(req.stops, key=lambda s: s.id))}:{req.vehicle_capacity}"
    cached = await redis_client.get(cache_key)
    if cached:
        return RouteResponse(job_id="cached", status="completed", cache_hit=True,
                             routes=json.loads(cached),
                             submitted_at=datetime.datetime.utcnow().isoformat())
    job_id = str(uuid.uuid4())
    _jobs[job_id] = {"status": "submitted", "routes": None}
    bg.add_task(_run_job, job_id, req, cache_key)
    return RouteResponse(job_id=job_id, status="submitted",
                         submitted_at=datetime.datetime.utcnow().isoformat())

async def _run_job(job_id: str, req: RouteRequest, cache_key: str):
    import numpy as np
    from qubo.routing_encoder import DeliveryStop, build_cvrp_qubo, qubo_to_register_positions
    from qaoa.jax_optimizer import optimize_qaoa
    from qaoa.pulse_builder import build_qaoa_sequence
    from qaoa.hardware_runner import run_qaoa_on_backend, PasqalBackend
    from routing.decoder import rank_routes

    _jobs[job_id]["status"] = "running"
    stops = [DeliveryStop(s.id, s.x, s.y, s.demand) for s in req.stops]
    Q, _ = build_cvrp_qubo(stops, req.vehicle_capacity)
    coords = qubo_to_register_positions(Q)
    opt = optimize_qaoa(coords, Q, p=req.qaoa_layers, n_steps=30)
    seq = build_qaoa_sequence(coords, opt["optimal_gammas"].tolist(), opt["optimal_betas"].tolist())
    counts = run_qaoa_on_backend(seq, PasqalBackend(req.backend), 500)
    routes = rank_routes(counts, stops)
    route_data = [
        {"vehicle_0": r.vehicle_0_stops, "vehicle_1": r.vehicle_1_stops,
         "distance": r.total_distance, "violations": r.constraint_violations}
        for r in routes
    ]
    await redis_client.setex(cache_key, CACHE_TTL, json.dumps(route_data))
    _jobs[job_id] = {"status": "completed", "routes": route_data}

@app.get("/jobs/{job_id}")
async def get_job(job_id: str):
    if job_id not in _jobs:
        raise HTTPException(404, "Job not found")
    return _jobs[job_id]

@app.get("/health")
async def health():
    return {"status": "ok"}
```

**Verify:** `POST /optimise` returns 202. A second identical POST returns `"cache_hit": true`. `GET /jobs/{id}` shows `"status": "completed"` with routes after optimisation finishes.

---

### Step 10: Testing and benchmarking

**Code:**
```python
# tests/test_qubo.py
import numpy as np
from qubo.routing_encoder import DeliveryStop, build_cvrp_qubo

def test_qubo_shape():
    stops = [DeliveryStop(i, float(i), 0.0, 5.0) for i in range(4)]
    Q, _ = build_cvrp_qubo(stops, vehicle_capacity=20.0)
    assert Q.shape == (8, 8)

def test_qubo_symmetry():
    stops = [DeliveryStop(i, float(i), 0.0, 5.0) for i in range(3)]
    Q, _ = build_cvrp_qubo(stops, vehicle_capacity=15.0)
    assert np.allclose(Q, Q.T)

# tests/test_qaoa.py
def test_pulse_sequence_builds():
    import numpy as np
    from qaoa.pulse_builder import build_qaoa_sequence
    coords = np.array([[0, 0], [6, 0], [12, 0]], dtype=float)
    seq = build_qaoa_sequence(coords, [np.pi/4], [np.pi/4])
    assert seq is not None

def test_local_emulator_samples():
    import numpy as np
    from qaoa.pulse_builder import build_qaoa_sequence
    from qaoa.hardware_runner import run_qaoa_on_backend, PasqalBackend
    coords = np.array([[0, 0], [6, 0], [12, 0]], dtype=float)
    seq = build_qaoa_sequence(coords, [np.pi/4], [np.pi/4])
    counts = run_qaoa_on_backend(seq, PasqalBackend.LOCAL_EMU, 100)
    assert sum(counts.values()) == 100

# tests/test_api.py
from fastapi.testclient import TestClient
from api.main import app
client = TestClient(app)

def test_health():
    assert client.get("/health").status_code == 200

def test_submit_route():
    payload = {"stops": [
        {"id": 0, "x": 0.0, "y": 0.0, "demand": 5.0},
        {"id": 1, "x": 2.0, "y": 1.0, "demand": 10.0},
        {"id": 2, "x": 3.0, "y": 0.5, "demand": 8.0},
    ], "vehicle_capacity": 20.0, "qaoa_layers": 1, "backend": "pulser_qutip"}
    r = client.post("/optimise", json=payload)
    assert r.status_code == 202
    assert "job_id" in r.json()
```

```bash
pytest tests/ -v --tb=short
```

**Verify:** All tests pass in < 3 minutes.

---

### Step 11: CI/CD and containerization

**Code:**

`Dockerfile`:
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ ./src/
ENV PYTHONPATH=/app/src
EXPOSE 8000
CMD ["uvicorn", "src.api.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

`docker-compose.yml`:
```yaml
version: "3.9"
services:
  api:
    build: .
    ports: ["8000:8000"]
    environment:
      - REDIS_URL=redis://redis:6379
      - DATABASE_URL=postgresql+asyncpg://qaoa:qaoa@db:5432/qaoadb
    depends_on: [redis, db]
  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]
  db:
    image: postgres:16
    environment:
      POSTGRES_USER: qaoa
      POSTGRES_PASSWORD: qaoa
      POSTGRES_DB: qaoadb
```

`.github/workflows/ci.yml`:
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      redis:
        image: redis:7
        ports: ["6379:6379"]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install -r requirements.txt
      - run: pip install ruff && ruff check src/ tests/
      - run: pytest tests/ -v -k "not pasqal_cloud"
```

**Verify:** `docker-compose up` starts all services. CI passes without Pasqal credentials.

---

### Step 12: Observability

**Goal:** Prometheus metrics for cache hit rate, QAOA job latency, and best-route constraint violations.

**Code:**
```python
# src/api/observability.py
from prometheus_client import Counter, Histogram, Gauge, make_asgi_app

route_requests = Counter("route_requests_total", "Total route requests", ["backend"])
cache_hits = Counter("route_cache_hits_total", "Cache hits")
qaoa_duration = Histogram("qaoa_duration_seconds", "QAOA job duration",
                           buckets=[1, 5, 30, 60, 120, 300])
best_violations = Gauge("best_route_violations", "Constraint violations in best decoded route")

def setup_metrics(app):
    app.mount("/metrics", make_asgi_app())
```

**Verify:** `curl http://localhost:8000/metrics | grep route_requests` increments with each API call.

---

## Testing

```bash
# Unit and integration tests (no cloud required)
pytest tests/ -v -k "not pasqal_cloud"

# Cloud tests (requires Pasqal credentials)
PASQAL_USERNAME=... PASQAL_PASSWORD=... pytest tests/ -v -m pasqal_cloud
```

## Deployment notes

- Set `PASQAL_USERNAME`, `PASQAL_PASSWORD`, `PASQAL_PROJECT_ID` as GitHub Actions secrets
- Redis TTL of 300 s is appropriate for delivery windows; reduce to 60 s during peak hours
- QAOA with p=3 on 12-stop instances takes ~5 minutes on EMU-TN; design API with async polling
- Fresnel-1 QPU register: maximum 100 atoms, minimum spacing 4 µm between any pair
- Apply QUBO variable fixing (set high-confidence classical assignments before quantum encoding) to reduce required qubit count for large instances

## Resources

1. [Pulser SDK Documentation](https://pulser.readthedocs.io/) — Register, Sequence, Pulse API reference
2. [Pasqal Cloud Documentation](https://docs.pasqal.com/) — SDK authentication, EMU-TN and QPU submission
3. [Ebadi et al. (2022) — Quantum optimization with neutral atoms](https://www.nature.com/articles/s41586-022-04992-8) — Nature, MIS on Rydberg hardware
4. [Farhi et al. (2014) — A Quantum Approximate Optimization Algorithm](https://arxiv.org/abs/1411.4028) — Original QAOA paper
5. [Pelofske et al. (2023) — Quantum Annealing vs QAOA comparison](https://arxiv.org/abs/2301.06395) — Benchmark study
6. [Optax documentation](https://optax.readthedocs.io/) — JAX-compatible gradient optimisation for QAOA parameter tuning
