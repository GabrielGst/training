# QP01 — Quantum-Enhanced Drug Molecule Screening via VQE

**Modality:** Superconducting (IBM Quantum / Qiskit) **Phase:** 2A **Track:** `hpc-quantum` **Status:** not started **Hours target:** 40

## Business Problem

Pharmaceutical pipelines must screen millions of candidate molecules to find viable drug leads, a process that currently consumes weeks of HPC time for each discovery campaign. Classical quantum chemistry methods (DFT, CCSD) break down in accuracy or cost when handling strongly-correlated electron systems — exactly the molecules most likely to be active drug candidates. This project builds a hybrid VQE pipeline that estimates molecular ground-state energies with quantum accuracy and exposes results through a production REST API, cutting screening time while surfacing the quantum-classical tradeoff for each molecular class.

## What you will build

1. A Qiskit VQE circuit with a hardware-efficient UCCSD ansatz for small molecules (H2, LiH, BeH2) using `qiskit-nature` for Hamiltonian generation
2. A PyTorch-based zero-noise extrapolation (ZNE) error mitigation layer that corrects shot noise from IBM Quantum QPU runs
3. A FastAPI microservice that accepts a SMILES string, submits a VQE job to IBM Quantum via `qiskit-ibm-runtime`, and returns ground-state energy + uncertainty
4. A PostgreSQL schema tracking job metadata (molecule id, ansatz depth, shots, backend, energy estimates, wall time)
5. A Docker-composed service stack (API + DB + Qiskit simulator) with a `.env`-driven IBM Quantum credential injection
6. A GitHub Actions CI pipeline running circuit unit tests against Qiskit Aer (statevector simulator) on every push

## Architecture

```
SMILES string
     |
     v
[RDKit / qiskit-nature]
Molecular Hamiltonian (Jordan-Wigner / Parity mapping)
     |
     v
[Qiskit VQE Circuit]                   <-- parametrised UCCSD ansatz
     |
     |--- Aer statevector (dev) ------> energy estimate (noise-free)
     |--- Aer noise model (staging) --> energy estimate (realistic)
     |--- IBM Quantum QPU (prod) -----> raw expectation values
     |
     v
[PyTorch ZNE Error Mitigator]
Noise-corrected ground-state energy
     |
     v
[FastAPI /estimate endpoint]
JSON: { molecule, energy_ha, uncertainty, backend, job_id }
     |
     v
[PostgreSQL]          [AWS Braket fallback]
Job metadata store    Multi-vendor QPU access
```

## Theory prerequisites

| Skill ID | Concept | Why you need it |
|----------|---------|-----------------|
| QSK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notation) | State vectors encode molecular orbital occupancies; bra-ket notation appears in every Qiskit API call |
| QSK02 | Quantum Measurement Theory (Born Rule) | Shot-based expectation values are Born-rule averages; shot count determines VQE precision |
| QSK03 | Quantum Decoherence & T1/T2 Relaxation | T1/T2 times constrain ansatz depth; Lindblad noise models feed into Aer noise simulation |
| QSK04 | Quantum Gate Model & Clifford+T Gate Sets | UCCSD excitation operators decompose into Clifford+T gates; circuit depth is the limiting NISQ metric |
| QSK05 | Complex Vector Spaces & Tensor Products | Multi-qubit molecular orbital space is the tensor product of single-qubit spaces |
| QSK06 | Eigendecomposition & Spectral Theorem | Ground-state energy is the minimum eigenvalue of the molecular Hamiltonian |
| QSK07 | Quantum Information Theory (von Neumann Entropy) | Entanglement entropy diagnoses whether a molecule needs quantum treatment or can be classically approximated |
| QSK08 | Quantum Error Correction — Stabiliser Formalism | Error correction theory motivates why ZNE is the practical NISQ alternative to full fault tolerance |
| QSK09 | NISQ-Era Limitations & Error Mitigation | Explains why circuit depth must stay under ~100 two-qubit gates on current IBM hardware |
| QSK10 | Variational Quantum Eigensolver (VQE) Algorithm | The core algorithm: parametrised ansatz + classical COBYLA/Adam minimisation of energy expectation value |

## Engineering skills covered

| Skill ID | Skill | What you practice |
|----------|-------|------------------|
| QSK24 | ML for Quantum Error Mitigation | Train a PyTorch MLP to predict ZNE-corrected energies from noisy expectation value sequences |
| QSK25 | Hybrid Classical-Quantum Loops | Implement the VQE parameter update loop: circuit execution → expectation value → gradient → optimizer step |
| QSK26 | PyTorch Production Patterns | Structure the error mitigator as a `torch.nn.Module`; checkpoint and serve via TorchServe |
| QSK27 | REST API Design & FastAPI | Async endpoint with Pydantic request/response models, OpenAPI docs, background job submission |
| QSK32 | Adiabatic Theorem & Quantum Tunnelling | Understand why the VQE landscape has local minima; compare to adiabatic ground state preparation |
| QSK33 | SQL Data Modelling (PostgreSQL) | Design normalized schema: `molecules`, `vqe_jobs`, `energy_estimates`, `error_metrics` tables |
| QSK34 | Container Orchestration (Docker) | Write multi-stage Dockerfile; `docker-compose` for API + PostgreSQL + Qiskit worker |
| QSK35 | CI/CD & GitHub Actions | Matrix test workflow: Aer simulator unit tests + API integration tests on every PR |

## Tools & dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| Qiskit | Gate model circuits, IBM Quantum backend access | `pip install qiskit qiskit-ibm-runtime` |
| Qiskit Aer | High-performance local simulator with noise models | `pip install qiskit-aer` |
| qiskit-nature | Molecular Hamiltonian generation, Jordan-Wigner mapping | `pip install qiskit-nature[pyscf]` |
| PyTorch | Zero-noise extrapolation neural network | `pip install torch` |
| FastAPI | Async REST API with OpenAPI docs | `pip install fastapi uvicorn[standard]` |
| PostgreSQL | Job metadata and result storage | `docker pull postgres:16` |
| AWS Braket | Multi-vendor QPU fallback access | `pip install amazon-braket-sdk` |
| Docker | Reproducible containerized service stack | `apt install docker.io docker-compose-plugin` |
| GitHub Actions | CI pipeline: lint, test, build | Configured in `.github/workflows/` |
| mitiq | Reference ZNE implementation for comparison | `pip install mitiq` |

## Prerequisites

**Complete these theory modules first:**
- [ ] `hpc-quantum/02-quantum-intro` — Qiskit basics: circuits, gates, simulators
- [ ] `q-theory-01-hilbert-spaces` — Bra-ket notation, computational basis, multi-qubit states
- [ ] `q-theory-02-measurement` — Born rule, expectation values, shot noise
- [ ] `q-theory-03-decoherence` — T1/T2, Lindblad master equation, Aer NoiseModel
- [ ] `q-theory-04-gate-model` — Clifford gates, gate depth, two-qubit gate fidelity
- [ ] `q-theory-09-nisq` — NISQ constraints, ZNE, probabilistic error cancellation
- [ ] `q-theory-10-vqe` — VQE algorithm derivation, ansatz families, convergence

**Access / accounts needed:**
- [ ] IBM Quantum account (free tier sufficient for H2/LiH; `ibm_nairobi` or similar 7-qubit device)
- [ ] AWS account (optional Braket fallback; `us-east-1` region, SV1 on-demand simulator)
- [ ] Docker Hub account for image registry
- [ ] GitHub repository with Actions enabled

## Step-by-step tutorial

---

### Step 1: Environment setup (Python + Qiskit)

**Goal:** Reproducible Python environment with all quantum and classical dependencies installed and IBM Quantum credentials configured.

**Code:**
```bash
# Create and activate virtual environment
python -m venv .venv && source .venv/bin/activate

# Install quantum stack
pip install qiskit qiskit-aer qiskit-ibm-runtime "qiskit-nature[pyscf]"

# Install classical ML and API stack
pip install torch fastapi uvicorn[standard] pydantic sqlalchemy asyncpg psycopg2-binary mitiq

# Configure IBM Quantum credentials (one-time)
python - <<'EOF'
from qiskit_ibm_runtime import QiskitRuntimeService
QiskitRuntimeService.save_account(
    channel="ibm_quantum",
    token="YOUR_IBM_QUANTUM_TOKEN",  # from quantum.ibm.com
    overwrite=True
)
EOF

# Smoke test
python - <<'EOF'
from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator

qc = QuantumCircuit(2, 2)
qc.h(0)
qc.cx(0, 1)
qc.measure([0, 1], [0, 1])

sim = AerSimulator()
result = sim.run(qc, shots=1024).result()
print(result.get_counts())   # expect ~{'00': 512, '11': 512}
EOF
```

**Verify:** Bell state counts appear with roughly equal probability for `'00'` and `'11'`. IBM Quantum account loads without error.

---

### Step 2: Theory warm-up — implement a simple VQE on a 2-qubit Hamiltonian

**Goal:** Build intuition for the VQE loop before tackling molecular Hamiltonians. Minimize the energy of a hand-crafted 2-qubit Ising Hamiltonian.

**Code:**
```python
# src/warmup/simple_vqe.py
import numpy as np
from qiskit import QuantumCircuit
from qiskit.primitives import StatevectorEstimator
from qiskit.quantum_info import SparsePauliOp
from scipy.optimize import minimize

# Define H = -Z⊗Z + 0.5*(X⊗I + I⊗X)
hamiltonian = SparsePauliOp.from_list([
    ("ZZ", -1.0),
    ("XI",  0.5),
    ("IX",  0.5),
])

def make_ansatz(theta: list[float]) -> QuantumCircuit:
    """Hardware-efficient 2-qubit ansatz with 4 parameters."""
    qc = QuantumCircuit(2)
    qc.ry(theta[0], 0)
    qc.ry(theta[1], 1)
    qc.cx(0, 1)
    qc.ry(theta[2], 0)
    qc.ry(theta[3], 1)
    return qc

estimator = StatevectorEstimator()

def energy(theta: np.ndarray) -> float:
    qc = make_ansatz(theta.tolist())
    pub = (qc, hamiltonian)
    result = estimator.run([pub]).result()
    return float(result[0].data.evs)

# Classical optimizer: COBYLA
theta0 = np.random.uniform(-np.pi, np.pi, 4)
result = minimize(energy, theta0, method="COBYLA",
                  options={"maxiter": 300, "rhobeg": 0.5})
print(f"VQE ground energy: {result.fun:.6f}")

# Exact diagonalization for comparison
import numpy.linalg as la
H_mat = hamiltonian.to_matrix()
exact = la.eigvalsh(H_mat)[0]
print(f"Exact ground energy: {exact:.6f}")
print(f"Error: {abs(result.fun - exact)*1000:.2f} mHa")
```

**Verify:** VQE energy converges within 5 mHa of the exact diagonalisation result within 300 iterations. You now understand the core VQE loop: parametrised circuit → expectation value → classical minimiser → repeat.

---

### Step 3: Problem formulation — molecular Hamiltonian to VQE circuit

**Goal:** Use `qiskit-nature` + PySCF to convert an H2 molecule (STO-3G basis) into a qubit Hamiltonian via the Jordan-Wigner transformation, then build a UCCSD ansatz.

**Code:**
```python
# src/chemistry/hamiltonian.py
from qiskit_nature.second_q.drivers import PySCFDriver
from qiskit_nature.second_q.mappers import JordanWignerMapper
from qiskit_nature.second_q.circuit.library import UCCSD, HartreeFock

# Step 3a: generate molecular Hamiltonian
driver = PySCFDriver(
    atom="H 0 0 0; H 0 0 0.735",   # H-H bond length 0.735 Å
    basis="sto3g",
    charge=0,
    spin=0,
)
problem = driver.run()
hamiltonian = problem.hamiltonian
fermionic_op = hamiltonian.second_q_op()

# Step 3b: map to qubit Hamiltonian (4 qubits for STO-3G H2)
mapper = JordanWignerMapper()
qubit_op = mapper.map(fermionic_op)
print(f"Number of qubits: {qubit_op.num_qubits}")        # 4
print(f"Number of Pauli terms: {len(qubit_op)}")          # 15 for H2/STO-3G

# Step 3c: build UCCSD ansatz with Hartree-Fock initial state
num_particles = problem.num_particles            # (1, 1) for H2
num_spatial_orbitals = problem.num_spatial_orbitals  # 2

hf_state = HartreeFock(
    num_spatial_orbitals=num_spatial_orbitals,
    num_particles=num_particles,
    qubit_mapper=mapper,
)
ansatz = UCCSD(
    num_spatial_orbitals=num_spatial_orbitals,
    num_particles=num_particles,
    qubit_mapper=mapper,
    initial_state=hf_state,
)
print(f"Ansatz depth: {ansatz.decompose().depth()}")
print(f"Number of variational parameters: {ansatz.num_parameters}")

# Step 3d: verify Hartree-Fock energy as starting point
from qiskit.primitives import StatevectorEstimator
import numpy as np

estimator = StatevectorEstimator()
hf_params = np.zeros(ansatz.num_parameters)
bound_ansatz = ansatz.assign_parameters(hf_params)
result = estimator.run([(bound_ansatz, qubit_op)]).result()
hf_energy = float(result[0].data.evs)
nuclear_repulsion = problem.nuclear_repulsion_energy
print(f"HF electronic energy: {hf_energy:.6f} Ha")
print(f"HF total energy: {hf_energy + nuclear_repulsion:.6f} Ha")
# Expected: ~-1.1175 Ha for H2 STO-3G HF
```

**Verify:** 4-qubit Hamiltonian with 15 Pauli terms. Hartree-Fock energy approximately -1.1175 Ha. UCCSD ansatz has 3 variational parameters for H2/STO-3G.

---

### Step 4: Circuit design and parameterization

**Goal:** Inspect and visualise the UCCSD ansatz circuit, understand the parameter space, and implement a hardware-efficient alternative for shallower depth on NISQ devices.

**Code:**
```python
# src/chemistry/circuit_design.py
from qiskit import transpile
from qiskit_aer import AerSimulator
from qiskit.visualization import circuit_drawer
from qiskit.circuit.library import RealAmplitudes
from chemistry.hamiltonian import ansatz, qubit_op, mapper

# 4a: Draw the UCCSD circuit
print(ansatz.decompose().draw(output="text", fold=80))

# 4b: Transpile to IBM Quantum native gates (ECR, SX, RZ, X)
backend = AerSimulator()
transpiled = transpile(ansatz, backend=backend, optimization_level=3)
print(f"Transpiled depth: {transpiled.depth()}")
print(f"Two-qubit gate count: {transpiled.count_ops().get('ecr', 0)}")

# 4c: Hardware-efficient alternative for shallower circuits
# Use RealAmplitudes (Ry + CNOT layers) when depth budget is tight
efficient_ansatz = RealAmplitudes(
    num_qubits=qubit_op.num_qubits,
    reps=2,
    entanglement="linear",
)
print(f"\nHardware-efficient ansatz:")
print(f"  Parameters: {efficient_ansatz.num_parameters}")
efficient_transpiled = transpile(efficient_ansatz, backend=backend, optimization_level=3)
print(f"  Transpiled depth: {efficient_transpiled.depth()}")

# 4d: Parameter landscape — scan one parameter to see energy profile
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from qiskit.primitives import StatevectorEstimator

estimator = StatevectorEstimator()
base_params = np.zeros(ansatz.num_parameters)
theta_range = np.linspace(-np.pi, np.pi, 50)
energies = []
for t in theta_range:
    params = base_params.copy()
    params[0] = t
    bound = ansatz.assign_parameters(params)
    res = estimator.run([(bound, qubit_op)]).result()
    energies.append(float(res[0].data.evs))

plt.figure(figsize=(8, 4))
plt.plot(theta_range, energies)
plt.xlabel("theta[0] (rad)")
plt.ylabel("Energy (Ha)")
plt.title("VQE Energy Landscape — First UCCSD Parameter")
plt.tight_layout()
plt.savefig("docs/energy_landscape.png")
print("Saved energy landscape plot.")
```

**Verify:** UCCSD circuit depth under 30 gates (before transpilation). The 1D energy landscape scan shows a smooth sinusoidal curve — no barren plateau for 4-qubit H2.

---

### Step 5: Classical optimizer / variational loop

**Goal:** Run a complete VQE optimisation on H2 using `qiskit-ibm-runtime` Primitives API (Estimator), with COBYLA as the classical optimizer and convergence tracking.

**Code:**
```python
# src/vqe/optimizer.py
import numpy as np
from qiskit.primitives import StatevectorEstimator
from scipy.optimize import minimize
from dataclasses import dataclass, field
from typing import List

@dataclass
class VQEResult:
    energy: float
    parameters: np.ndarray
    num_iterations: int
    energy_history: List[float] = field(default_factory=list)
    converged: bool = False

def run_vqe(
    ansatz,
    hamiltonian,
    initial_params: np.ndarray | None = None,
    max_iter: int = 500,
    tol: float = 1e-6,
    use_runtime: bool = False,
    backend_name: str = "ibm_nairobi",
) -> VQEResult:
    """Run VQE with either statevector estimator or IBM Quantum runtime."""

    if use_runtime:
        from qiskit_ibm_runtime import QiskitRuntimeService, EstimatorV2, Session
        service = QiskitRuntimeService()
        backend = service.backend(backend_name)
        session = Session(backend=backend)
        estimator = EstimatorV2(mode=session)
    else:
        estimator = StatevectorEstimator()

    energy_history: List[float] = []
    iteration_count = [0]

    def cost_fn(params: np.ndarray) -> float:
        bound = ansatz.assign_parameters(params)
        pub = (bound, hamiltonian)
        result = estimator.run([pub]).result()
        energy = float(result[0].data.evs)
        energy_history.append(energy)
        iteration_count[0] += 1
        if iteration_count[0] % 50 == 0:
            print(f"  Iter {iteration_count[0]:4d} | E = {energy:.8f} Ha")
        return energy

    if initial_params is None:
        rng = np.random.default_rng(42)
        initial_params = rng.uniform(-np.pi, np.pi, ansatz.num_parameters)

    print(f"Starting VQE with {ansatz.num_parameters} parameters...")
    opt_result = minimize(
        cost_fn,
        initial_params,
        method="COBYLA",
        options={"maxiter": max_iter, "rhobeg": 0.5, "catol": tol},
    )

    if use_runtime:
        session.close()

    return VQEResult(
        energy=opt_result.fun,
        parameters=opt_result.x,
        num_iterations=iteration_count[0],
        energy_history=energy_history,
        converged=opt_result.success,
    )

if __name__ == "__main__":
    from chemistry.hamiltonian import ansatz, qubit_op
    import numpy as np

    # Zero initialisation (near Hartree-Fock)
    theta0 = np.zeros(ansatz.num_parameters)
    vqe_result = run_vqe(ansatz, qubit_op, initial_params=theta0)
    nuclear_repulsion = -1.1374657  # H2 STO-3G
    total_energy = vqe_result.energy + nuclear_repulsion
    print(f"\nVQE total energy:  {total_energy:.6f} Ha")
    print(f"FCI reference:     -1.137270 Ha")
    print(f"Error:             {abs(total_energy + 1.137270) * 1000:.2f} mHa")
```

**Verify:** VQE converges to H2 ground state within 2 mHa of the FCI reference (-1.137270 Ha) in under 200 iterations.

---

### Step 6: Error mitigation

**Goal:** Implement Zero-Noise Extrapolation (ZNE) using `mitiq` and a custom PyTorch MLP that learns the noise correction from simulated noisy runs.

**Code:**
```python
# src/mitigation/zne.py
import numpy as np
import torch
import torch.nn as nn
from qiskit_aer import AerSimulator
from qiskit_aer.noise import NoiseModel, depolarizing_error
from qiskit.primitives import StatevectorEstimator
from qiskit_ibm_runtime.fake_provider import FakeNairobi
import mitiq

def build_noise_model(error_rate: float = 0.01) -> NoiseModel:
    """Simple depolarising noise model."""
    noise_model = NoiseModel()
    depol_1q = depolarizing_error(error_rate, 1)
    depol_2q = depolarizing_error(error_rate * 10, 2)
    noise_model.add_all_qubit_quantum_error(depol_1q, ["u1", "u2", "u3"])
    noise_model.add_all_qubit_quantum_error(depol_2q, ["cx"])
    return noise_model

def run_noisy_estimator(circuit, hamiltonian, noise_scale: float = 1.0):
    """Run circuit with scaled noise for ZNE."""
    from qiskit_aer.noise import NoiseModel
    from qiskit_ibm_runtime.fake_provider import FakeNairobi

    fake_backend = FakeNairobi()
    noise_model = NoiseModel.from_backend(fake_backend)
    backend = AerSimulator(noise_model=noise_model)

    from qiskit import transpile
    from qiskit.primitives import BackendEstimatorV2
    transpiled = transpile(circuit, backend=backend, optimization_level=1)
    # Scale noise via gate folding (mitiq approach)
    folded = mitiq.zne.scaling.fold_gates_at_random(transpiled, scale_factor=noise_scale)
    estimator = BackendEstimatorV2(backend=backend)
    result = estimator.run([(folded, hamiltonian)]).result()
    return float(result[0].data.evs)

def zne_extrapolate(circuit, hamiltonian, scale_factors=(1.0, 2.0, 3.0)) -> float:
    """Richardson extrapolation across noise scale factors."""
    noisy_values = [run_noisy_estimator(circuit, hamiltonian, s) for s in scale_factors]
    # Linear extrapolation to zero noise
    coeffs = np.polyfit(scale_factors, noisy_values, deg=len(scale_factors) - 1)
    extrapolated = np.polyval(coeffs, 0.0)
    print(f"  Noisy values at scales {scale_factors}: {[f'{v:.6f}' for v in noisy_values]}")
    print(f"  ZNE extrapolated: {extrapolated:.6f}")
    return float(extrapolated)

# PyTorch MLP for learned error mitigation
class NoiseMitigatorMLP(nn.Module):
    """Learns to map noisy expectation values to mitigated values."""
    def __init__(self, input_dim: int = 3, hidden_dim: int = 64):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(input_dim, hidden_dim),
            nn.GELU(),
            nn.Linear(hidden_dim, hidden_dim),
            nn.GELU(),
            nn.Linear(hidden_dim, 1),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.net(x).squeeze(-1)

def train_mitigator(n_samples: int = 500) -> NoiseMitigatorMLP:
    """Generate synthetic training data and train the MLP mitigator."""
    from chemistry.hamiltonian import ansatz, qubit_op
    from qiskit.primitives import StatevectorEstimator

    noiseless_estimator = StatevectorEstimator()
    model = NoiseMitigatorMLP()
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
    rng = np.random.default_rng(0)

    X, y = [], []
    for _ in range(n_samples):
        params = rng.uniform(-np.pi, np.pi, ansatz.num_parameters)
        bound = ansatz.assign_parameters(params)
        # Noiseless reference
        noiseless = float(noiseless_estimator.run([(bound, qubit_op)]).result()[0].data.evs)
        # Noisy values at 3 scales
        noisy_3 = [run_noisy_estimator(bound, qubit_op, s) for s in (1.0, 2.0, 3.0)]
        X.append(noisy_3)
        y.append(noiseless)

    X_t = torch.tensor(X, dtype=torch.float32)
    y_t = torch.tensor(y, dtype=torch.float32)

    for epoch in range(200):
        pred = model(X_t)
        loss = nn.functional.mse_loss(pred, y_t)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        if epoch % 50 == 0:
            print(f"Epoch {epoch}: loss = {loss.item():.6f}")

    torch.save(model.state_dict(), "models/noise_mitigator.pt")
    return model
```

**Verify:** ZNE extrapolation recovers energy within 5 mHa of noiseless value. MLP training loss converges below 1e-4.

---

### Step 7: Hardware execution (simulator first, then real QPU)

**Goal:** Run the VQE on Aer statevector (noise-free), then Aer QASM with noise model (realistic), then submit to IBM Quantum QPU.

**Code:**
```python
# src/vqe/hardware_runner.py
from enum import Enum
from dataclasses import dataclass

class Backend(str, Enum):
    STATEVECTOR = "aer_statevector"
    NOISY_SIM   = "aer_noisy"
    IBM_QPU     = "ibm_quantum"

def run_on_backend(ansatz, hamiltonian, params, backend: Backend, shots: int = 4096):
    import numpy as np

    # --- Simulator: noise-free statevector ---
    if backend == Backend.STATEVECTOR:
        from qiskit.primitives import StatevectorEstimator
        estimator = StatevectorEstimator()
        bound = ansatz.assign_parameters(params)
        result = estimator.run([(bound, hamiltonian)]).result()
        return {"energy": float(result[0].data.evs), "backend": "aer_statevector", "shots": None}

    # --- Simulator: realistic noise model from FakeNairobi ---
    elif backend == Backend.NOISY_SIM:
        from qiskit_aer import AerSimulator
        from qiskit_aer.noise import NoiseModel
        from qiskit_ibm_runtime.fake_provider import FakeNairobi
        from qiskit.primitives import BackendEstimatorV2
        from qiskit import transpile

        fake_backend = FakeNairobi()
        noise_model = NoiseModel.from_backend(fake_backend)
        sim = AerSimulator(noise_model=noise_model)
        bound = ansatz.assign_parameters(params)
        transpiled = transpile(bound, sim, optimization_level=3)
        estimator = BackendEstimatorV2(backend=sim, options={"default_shots": shots})
        result = estimator.run([(transpiled, hamiltonian)]).result()
        return {"energy": float(result[0].data.evs), "backend": "aer_noisy", "shots": shots}

    # --- Real QPU: IBM Quantum via Qiskit Runtime ---
    elif backend == Backend.IBM_QPU:
        from qiskit_ibm_runtime import QiskitRuntimeService, EstimatorV2, Session
        from qiskit_ibm_runtime.options import EstimatorOptions
        from qiskit import transpile

        service = QiskitRuntimeService()
        # Choose least-busy 7+ qubit backend
        ibm_backend = service.least_busy(min_num_qubits=7, simulator=False, operational=True)
        print(f"Submitting to QPU: {ibm_backend.name}")

        options = EstimatorOptions()
        options.resilience_level = 1        # ZNE enabled
        options.dynamical_decoupling.enable = True

        with Session(backend=ibm_backend) as session:
            estimator = EstimatorV2(mode=session, options=options)
            bound = ansatz.assign_parameters(params)
            transpiled = transpile(bound, ibm_backend, optimization_level=3)
            result = estimator.run([(transpiled, hamiltonian)]).result()
            job_id = result.job_id  # Save for PostgreSQL record
        return {"energy": float(result[0].data.evs), "backend": ibm_backend.name,
                "shots": shots, "job_id": job_id}

# Demo: compare all three backends
if __name__ == "__main__":
    from chemistry.hamiltonian import ansatz, qubit_op
    import numpy as np

    # Use optimized parameters from Step 5
    optimal_params = np.load("models/optimal_params.npy")

    for b in [Backend.STATEVECTOR, Backend.NOISY_SIM]:
        r = run_on_backend(ansatz, qubit_op, optimal_params, b)
        print(f"{r['backend']:20s}: {r['energy']:.6f} Ha")
    # Only uncomment when IBM Quantum queue is short:
    # r = run_on_backend(ansatz, qubit_op, optimal_params, Backend.IBM_QPU)
    # print(f"{r['backend']:20s}: {r['energy']:.6f} Ha  (job: {r['job_id']})")
```

**Verify:** Statevector energy matches Step 5 result. Noisy sim energy deviates by 10–50 mHa depending on circuit depth. QPU job appears in IBM Quantum dashboard under "Jobs".

---

### Step 8: Classical post-processing and result interpretation

**Goal:** Convert raw VQE energy to physically meaningful units, apply nuclear repulsion correction, compare against classical baselines (HF, MP2), and compute uncertainty.

**Code:**
```python
# src/chemistry/postprocess.py
import numpy as np
from dataclasses import dataclass

HA_TO_KCAL = 627.5094740631      # 1 Hartree = 627.5 kcal/mol
HA_TO_EV   = 27.211386245988     # 1 Hartree = 27.21 eV

@dataclass
class MoleculeEnergyReport:
    molecule: str
    vqe_electronic_energy_ha: float
    nuclear_repulsion_ha: float
    vqe_total_energy_ha: float
    hf_total_energy_ha: float        # Hartree-Fock reference
    fci_total_energy_ha: float       # Full CI (exact) reference
    correlation_energy_ha: float     # VQE - HF (captures electron correlation)
    chemical_accuracy: bool          # |VQE - FCI| < 1.6 mHa (1 kcal/mol)
    uncertainty_ha: float            # Shot noise estimate from bootstrap

    def __str__(self) -> str:
        return (
            f"\n{'='*55}\n"
            f"Molecule: {self.molecule}\n"
            f"{'='*55}\n"
            f"VQE total energy:     {self.vqe_total_energy_ha:+.6f} Ha\n"
            f"HF total energy:      {self.hf_total_energy_ha:+.6f} Ha\n"
            f"FCI total energy:     {self.fci_total_energy_ha:+.6f} Ha\n"
            f"Correlation energy:   {self.correlation_energy_ha*1000:+.2f} mHa\n"
            f"Error vs FCI:         {abs(self.vqe_total_energy_ha - self.fci_total_energy_ha)*1000:.2f} mHa\n"
            f"Chemical accuracy:    {'YES' if self.chemical_accuracy else 'NO'} (< 1.6 mHa)\n"
            f"Uncertainty:          {self.uncertainty_ha*1000:.2f} mHa\n"
            f"{'='*55}"
        )

def compute_report(
    molecule: str,
    vqe_electronic: float,
    nuclear_repulsion: float,
    hf_total: float,
    fci_total: float,
    energy_samples: list[float] | None = None,
) -> MoleculeEnergyReport:
    total = vqe_electronic + nuclear_repulsion
    corr = total - hf_total
    error = abs(total - fci_total)
    uncertainty = float(np.std(energy_samples)) if energy_samples else 0.0
    return MoleculeEnergyReport(
        molecule=molecule,
        vqe_electronic_energy_ha=vqe_electronic,
        nuclear_repulsion_ha=nuclear_repulsion,
        vqe_total_energy_ha=total,
        hf_total_energy_ha=hf_total,
        fci_total_energy_ha=fci_total,
        correlation_energy_ha=corr,
        chemical_accuracy=error < 1.6e-3,
        uncertainty_ha=uncertainty,
    )

if __name__ == "__main__":
    # H2 STO-3G reference values
    report = compute_report(
        molecule="H2 (STO-3G)",
        vqe_electronic=-1.8572,     # example VQE result
        nuclear_repulsion=0.7199,
        hf_total=-1.1175,
        fci_total=-1.1373,
    )
    print(report)
```

**Verify:** Report prints chemical accuracy status. H2 VQE should achieve chemical accuracy (< 1.6 mHa error). LiH may require deeper ansatz.

---

### Step 9: REST API wrapper

**Goal:** Build a FastAPI service that accepts a SMILES string, builds the VQE circuit asynchronously, submits to the configured backend, and returns the energy report.

**Code:**
```python
# src/api/main.py
from fastapi import FastAPI, BackgroundTasks, HTTPException
from pydantic import BaseModel, Field
from typing import Literal, Optional
import uuid, asyncio, datetime
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

app = FastAPI(
    title="VQE Drug Screening API",
    description="Quantum-enhanced molecular energy estimation via VQE",
    version="0.1.0",
)

class MoleculeRequest(BaseModel):
    smiles: str = Field(..., example="[H][H]", description="SMILES string of molecule")
    backend: Literal["aer_statevector", "aer_noisy", "ibm_quantum"] = "aer_statevector"
    shots: int = Field(default=4096, ge=100, le=100_000)
    max_vqe_iter: int = Field(default=300, ge=50, le=2000)

class EnergyResponse(BaseModel):
    job_id: str
    status: Literal["submitted", "running", "completed", "failed"]
    molecule_smiles: str
    backend: str
    energy_hartree: Optional[float] = None
    energy_kcal_mol: Optional[float] = None
    uncertainty_hartree: Optional[float] = None
    chemical_accuracy: Optional[bool] = None
    submitted_at: str
    completed_at: Optional[str] = None

# In-memory job store (replace with PostgreSQL in production)
_jobs: dict[str, EnergyResponse] = {}

async def run_vqe_job(job_id: str, request: MoleculeRequest):
    """Background task: build Hamiltonian, run VQE, update job record."""
    from chemistry.hamiltonian import molecule_from_smiles
    from vqe.optimizer import run_vqe
    from chemistry.postprocess import compute_report
    from vqe.hardware_runner import run_on_backend, Backend

    _jobs[job_id].status = "running"
    try:
        ansatz, hamiltonian, nuclear_repulsion, hf_energy, fci_energy = \
            molecule_from_smiles(request.smiles)
        vqe_result = run_vqe(ansatz, hamiltonian, max_iter=request.max_vqe_iter)
        report = compute_report(
            molecule=request.smiles,
            vqe_electronic=vqe_result.energy,
            nuclear_repulsion=nuclear_repulsion,
            hf_total=hf_energy,
            fci_total=fci_energy,
            energy_samples=vqe_result.energy_history[-50:],
        )
        _jobs[job_id].status = "completed"
        _jobs[job_id].energy_hartree = report.vqe_total_energy_ha
        _jobs[job_id].energy_kcal_mol = report.vqe_total_energy_ha * 627.5094
        _jobs[job_id].chemical_accuracy = report.chemical_accuracy
        _jobs[job_id].uncertainty_hartree = report.uncertainty_ha
        _jobs[job_id].completed_at = datetime.datetime.utcnow().isoformat()
    except Exception as exc:
        _jobs[job_id].status = "failed"
        raise

@app.post("/estimate", response_model=EnergyResponse, status_code=202)
async def estimate_energy(request: MoleculeRequest, background_tasks: BackgroundTasks):
    """Submit a molecule for VQE energy estimation."""
    job_id = str(uuid.uuid4())
    job = EnergyResponse(
        job_id=job_id,
        status="submitted",
        molecule_smiles=request.smiles,
        backend=request.backend,
        submitted_at=datetime.datetime.utcnow().isoformat(),
    )
    _jobs[job_id] = job
    background_tasks.add_task(run_vqe_job, job_id, request)
    return job

@app.get("/jobs/{job_id}", response_model=EnergyResponse)
async def get_job(job_id: str):
    if job_id not in _jobs:
        raise HTTPException(status_code=404, detail="Job not found")
    return _jobs[job_id]

@app.get("/health")
async def health():
    return {"status": "ok", "version": "0.1.0"}
```

```bash
# Run the API locally
uvicorn src.api.main:app --host 0.0.0.0 --port 8000 --reload

# Test with curl
curl -X POST http://localhost:8000/estimate \
  -H "Content-Type: application/json" \
  -d '{"smiles": "[H][H]", "backend": "aer_statevector"}'
# Returns: {"job_id": "...", "status": "submitted", ...}
```

**Verify:** `GET /health` returns 200. `POST /estimate` with `[H][H]` SMILES returns a job ID. Polling `GET /jobs/{id}` eventually shows `"status": "completed"` with energy around -1.137 Ha.

---

### Step 10: Testing and benchmarking

**Goal:** Write pytest unit and integration tests covering the Hamiltonian generation, VQE convergence, API endpoints, and benchmark throughput.

**Code:**
```python
# tests/test_hamiltonian.py
import pytest
import numpy as np

def test_h2_hamiltonian_qubit_count():
    from chemistry.hamiltonian import molecule_from_smiles
    ansatz, hamiltonian, _, _, _ = molecule_from_smiles("[H][H]")
    assert hamiltonian.num_qubits == 4, "H2 STO-3G should require 4 qubits"

def test_h2_hamiltonian_pauli_terms():
    from chemistry.hamiltonian import molecule_from_smiles
    ansatz, hamiltonian, _, _, _ = molecule_from_smiles("[H][H]")
    assert len(hamiltonian) == 15, "H2 STO-3G JW mapping: 15 Pauli terms"

def test_hf_energy_h2():
    """Hartree-Fock initial energy should be close to -1.1175 Ha."""
    from chemistry.hamiltonian import molecule_from_smiles
    from qiskit.primitives import StatevectorEstimator
    ansatz, hamiltonian, nuclear_repulsion, hf_energy, _ = molecule_from_smiles("[H][H]")
    assert abs(hf_energy - (-1.1175)) < 0.01, f"HF energy {hf_energy} too far from expected"

# tests/test_vqe.py
def test_vqe_chemical_accuracy_h2():
    """VQE must achieve chemical accuracy (< 1.6 mHa) on H2 STO-3G."""
    from chemistry.hamiltonian import molecule_from_smiles
    from vqe.optimizer import run_vqe
    ansatz, hamiltonian, nuclear_repulsion, _, fci = molecule_from_smiles("[H][H]")
    result = run_vqe(ansatz, hamiltonian, max_iter=300)
    total = result.energy + nuclear_repulsion
    error = abs(total - fci)
    assert error < 1.6e-3, f"Chemical accuracy not reached: error = {error*1000:.2f} mHa"

# tests/test_api.py
from fastapi.testclient import TestClient
from api.main import app

client = TestClient(app)

def test_health_endpoint():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"

def test_estimate_submission():
    r = client.post("/estimate", json={"smiles": "[H][H]", "backend": "aer_statevector"})
    assert r.status_code == 202
    body = r.json()
    assert body["status"] == "submitted"
    assert "job_id" in body

def test_invalid_smiles_raises():
    r = client.post("/estimate", json={"smiles": "INVALID_SMILES"})
    assert r.status_code in (400, 422, 500)
```

```bash
# Run all tests
pytest tests/ -v --tb=short

# Benchmark: time 10 H2 VQE runs
python -c "
import time
from chemistry.hamiltonian import molecule_from_smiles
from vqe.optimizer import run_vqe

ansatz, h, nr, _, _ = molecule_from_smiles('[H][H]')
times = []
for i in range(3):
    t0 = time.time()
    run_vqe(ansatz, h, max_iter=200)
    times.append(time.time() - t0)
print(f'Mean VQE time: {sum(times)/len(times):.1f}s')
"
```

**Verify:** All pytest tests pass. VQE benchmark completes in under 30 seconds per run on a modern CPU (statevector simulator).

---

### Step 11: CI/CD and containerization

**Goal:** Write a multi-stage Dockerfile and a GitHub Actions workflow that runs the test suite against Aer simulator on every push.

**Code:**

`Dockerfile`:
```dockerfile
# Stage 1: builder
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: runtime
FROM python:3.11-slim AS runtime
WORKDIR /app
COPY --from=builder /install /usr/local
COPY src/ ./src/
COPY tests/ ./tests/
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
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql+asyncpg://vqe:vqe@db:5432/vqedb
      - IBM_QUANTUM_TOKEN=${IBM_QUANTUM_TOKEN}
    depends_on:
      - db
  db:
    image: postgres:16
    environment:
      POSTGRES_USER: vqe
      POSTGRES_PASSWORD: vqe
      POSTGRES_DB: vqedb
    volumes:
      - pgdata:/var/lib/postgresql/data
volumes:
  pgdata:
```

`.github/workflows/ci.yml`:
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.11"]

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Cache pip
        uses: actions/cache@v4
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Lint
        run: |
          pip install ruff
          ruff check src/ tests/

      - name: Run tests (Aer simulator only)
        env:
          VQE_BACKEND: aer_statevector
        run: pytest tests/ -v --tb=short -k "not ibm_quantum"

      - name: Build Docker image
        run: docker build -t vqe-api:ci .
```

**Verify:** `docker-compose up` starts API and PostgreSQL. GitHub Actions workflow passes on a fresh push. `docker run vqe-api:ci python -c "import qiskit; print('ok')"` succeeds.

---

### Step 12: Observability

**Goal:** Add structured logging, Prometheus metrics (job count, energy values, latency), and a basic alerting rule for failed QPU jobs.

**Code:**
```python
# src/api/observability.py
import logging
import time
from prometheus_client import Counter, Histogram, Gauge, make_asgi_app
from fastapi import FastAPI, Request

# Metrics
vqe_jobs_total = Counter("vqe_jobs_total", "Total VQE jobs submitted", ["backend", "status"])
vqe_energy_gauge = Gauge("vqe_latest_energy_ha", "Most recent VQE energy in Hartree")
vqe_latency = Histogram(
    "vqe_job_duration_seconds",
    "VQE job wall time",
    buckets=[1, 5, 10, 30, 60, 120, 300, 600],
)

def setup_observability(app: FastAPI) -> None:
    """Mount Prometheus metrics endpoint and configure structured logging."""
    logging.basicConfig(
        format='{"time":"%(asctime)s","level":"%(levelname)s","msg":"%(message)s"}',
        level=logging.INFO,
    )
    # Mount /metrics endpoint
    metrics_app = make_asgi_app()
    app.mount("/metrics", metrics_app)

    @app.middleware("http")
    async def track_latency(request: Request, call_next):
        start = time.time()
        response = await call_next(request)
        elapsed = time.time() - start
        if request.url.path == "/estimate":
            vqe_latency.observe(elapsed)
        return response
```

```yaml
# prometheus/alert_rules.yml
groups:
  - name: vqe_alerts
    rules:
      - alert: HighVQEJobFailureRate
        expr: rate(vqe_jobs_total{status="failed"}[5m]) > 0.1
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "VQE job failure rate above 10%"
          description: "Check IBM Quantum service status and noise model configuration."
```

**Verify:** `curl http://localhost:8000/metrics` returns Prometheus-formatted metrics. After submitting a job, `vqe_jobs_total` counter increments.

---

## Testing

```bash
# Unit tests (no hardware required)
pytest tests/test_hamiltonian.py tests/test_vqe.py -v

# Integration tests (requires local API)
uvicorn src.api.main:app &
pytest tests/test_api.py -v
pkill -f uvicorn

# Hardware tests (requires IBM Quantum account)
pytest tests/ -v -m "ibm_quantum"

# Coverage report
pytest tests/ --cov=src --cov-report=term-missing
```

## Deployment notes

- Set `IBM_QUANTUM_TOKEN` as a GitHub Actions secret and inject via `docker-compose.yml` environment variable
- Use `DATABASE_URL` with `postgresql+asyncpg://` scheme for async SQLAlchemy
- IBM Quantum free tier limits: 10 minutes QPU time per month; run the Aer noisy sim for development
- Increase `shots` to 8192+ for QPU runs to reduce shot noise below 5 mHa
- Use `optimization_level=3` in Qiskit transpile for maximum gate cancellation on NISQ hardware
- For molecules larger than 8 qubits, enable qubit reduction (two-qubit reduction, active space) in `qiskit-nature`

## Resources

1. [Qiskit Nature Documentation](https://qiskit-community.github.io/qiskit-nature/) — Molecular Hamiltonian generation, UCCSD ansatz reference
2. [Peruzzo et al. (2014) — Original VQE paper](https://www.nature.com/articles/ncomms5213) — Nature Communications, photonic VQE
3. [Qiskit IBM Runtime Primitives](https://docs.quantum.ibm.com/api/qiskit-ibm-runtime) — EstimatorV2, Session, resilience levels
4. [mitiq ZNE documentation](https://mitiq.readthedocs.io/en/stable/guide/zne.html) — Zero-noise extrapolation theory and implementation
5. [Cerezo et al. (2021) — Variational Quantum Algorithms review](https://www.nature.com/articles/s42254-021-00348-9) — Nature Reviews Physics, VQE and QAOA overview
6. [IBM Quantum Learning — Qiskit patterns](https://learning.quantum.ibm.com/catalog/patterns) — End-to-end quantum workflow tutorials
