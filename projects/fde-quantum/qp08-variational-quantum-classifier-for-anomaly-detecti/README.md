# QP08 — Variational Quantum Classifier for Anomaly Detection in Sensor Networks

**Modality:** superconducting (Qiskit + TKET) **Phase:** 2A (advanced) **Track:** `fde-quantum` **Status:** not started **Hours target:** 45

## Business Problem

Industrial IoT sensor networks generate millions of readings per day — vibration, temperature, pressure, current — from equipment that costs millions of dollars to replace. Classical anomaly detection (isolation forests, autoencoders) struggles with three compounding challenges: high-dimensional correlated sensor data, severe class imbalance (anomalies are rare), and hard latency constraints at the edge (sub-100ms inference on resource-constrained devices).

Variational Quantum Classifiers (VQC) offer a potential advantage: angle encoding maps high-dimensional sensor features into an exponentially large Hilbert space, allowing the quantum feature map to capture correlations that classical kernels miss. The key engineering challenge is exporting the trained VQC to edge-deployable formats (ONNX, TensorFlow Lite) so inference can run without a QPU at the edge.

## What You Will Build

A full QML anomaly detection pipeline that:

1. Trains a VQC with angle encoding on a multi-sensor anomaly dataset using Qiskit + PyTorch.
2. Compiles and optimises the circuit for IBM superconducting hardware using TKET.
3. Exports the trained quantum feature map to ONNX and converts to TensorFlow Lite for edge inference.
4. Ingests real-time sensor data from InfluxDB and triggers anomaly alerts via FastAPI.
5. Benchmarks VQC classification against a classical SVM baseline.
6. Monitors model drift and performance with Prometheus/InfluxDB.
7. Deploys with Docker and GitHub Actions CI.

## Architecture

```
  ┌────────────────────────────────────────────────────────────────┐
  │               IoT Sensor Data Ingestion                        │
  │   InfluxDB (time-series store) ← sensor telemetry streams      │
  └───────────────────────────────┬────────────────────────────────┘
                                  │
  ┌───────────────────────────────▼────────────────────────────────┐
  │              VQC Training Pipeline (offline)                    │
  │                                                                 │
  │  ┌─────────────────────────────────────────────────────────┐   │
  │  │ Angle Encoding Layer → VQC Ansatz → Measurement Layer   │   │
  │  │ Qiskit + TKET compilation → Qiskit Aer simulation        │   │
  │  │ PyTorch hybrid optimizer (parameter shift rule)          │   │
  │  └────────────────────────────────────────────────────────┘    │
  └───────────────────────────────┬────────────────────────────────┘
                                  │
  ┌───────────────────────────────▼────────────────────────────────┐
  │              Edge Deployment Pipeline                           │
  │   PyTorch → ONNX export → TensorFlow Lite conversion          │
  │   Edge device: VQC feature map runs classically via ONNX RT   │
  └───────────────────────────────┬────────────────────────────────┘
                                  │
  ┌───────────────────────────────▼────────────────────────────────┐
  │              FastAPI Inference Service                          │
  │   POST /predict-anomaly  GET /metrics                          │
  │   Prometheus metrics → Grafana drift monitoring                │
  └────────────────────────────────────────────────────────────────┘
```

## Theory Prerequisites

| Skill ID | Concept | Why you need it |
|----------|---------|-----------------|
| SK01 | Quantum State Representation — Hilbert Spaces & Bra-Ket Notation | Understanding how angle encoding maps classical features into quantum state vectors |
| SK02 | Quantum Measurement Theory — Born Rule | Interpreting VQC measurement expectation values as classification scores |
| SK03 | Quantum Decoherence & Relaxation — T1/T2, Lindblad | Understanding why VQC fidelity degrades with circuit depth on real hardware |
| SK04 | Quantum Gate Model & Universal Gate Sets | Designing the VQC ansatz with Ry, Rz rotations and CNOT entanglers |
| SK05 | Complex Vector Spaces & Tensor Products | Multi-qubit feature map state in the exponentially large Hilbert space |
| SK06 | Eigendecomposition & Matrix Decompositions | Deriving VQC operator expectation values from the observable Hamiltonian |
| SK07 | Quantum Information Theory — von Neumann Entropy | Quantifying entanglement in the VQC feature map and selecting expressive ansatz layers |
| SK08 | Quantum Error Correction — Stabiliser Formalism | Background for understanding the error rates that limit VQC depth on NISQ hardware |
| SK09 | NISQ-Era Limitations & Error Mitigation | Choosing circuit depth and qubit count within NISQ constraints; applying ZNE if needed |
| SK55 | Variational Quantum Machine Learning (QML) Circuits | Core VQC design: parametrised ansatz, trainable rotation gates, hardware-efficient layouts |
| SK56 | Angle Encoding for Feature Maps | Encoding the 8-dimensional sensor feature vector into qubit rotation angles |
| SK57 | Barren Plateaus & Variational Circuit Optimisation | Diagnosing and mitigating gradient vanishing during VQC training |

## Engineering Skills Covered

| Skill ID | Skill | What you practice |
|----------|-------|------------------|
| SK24 | ML for Quantum Error Mitigation | Post-processing noisy VQC measurement outcomes with classical ML correction layers |
| SK25 | Hybrid Classical-Quantum Loops & Orchestration | Parameter shift gradient loop: Qiskit circuit → PyTorch optimizer → updated parameters |
| SK26 | PyTorch Production Patterns | Implementing the hybrid quantum-classical training loop with autograd |
| SK27 | REST API Design & FastAPI | Building the `/predict-anomaly` endpoint with ONNX Runtime inference |
| SK33 | SQL Data Modelling — PostgreSQL | Storing anomaly detection results, model versions, and audit trail |
| SK34 | Container Orchestration — Docker | Packaging the VQC training and edge inference stack |
| SK35 | CI/CD & GitHub Actions | Automated VQC circuit construction tests and ONNX export validation |

## Tools & Dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| Qiskit | VQC circuit definition, parameter binding, Clifford gates | `pip install qiskit qiskit-machine-learning` |
| TKET | Circuit compilation and optimisation for IBM superconducting hardware | `pip install pytket pytket-qiskit` |
| PyTorch | Hybrid quantum-classical training loop with parameter shift gradients | `pip install torch` |
| ONNX | Export trained VQC feature map for cross-platform deployment | `pip install onnx onnxruntime` |
| TensorFlow Lite | Edge device inference with quantised model | `pip install tensorflow` |
| FastAPI | REST API for real-time anomaly prediction | `pip install fastapi uvicorn` |
| PostgreSQL | Anomaly detection results and model version storage | `pip install psycopg2-binary sqlalchemy` |
| InfluxDB | Time-series sensor data ingestion and streaming | `pip install influxdb-client` |
| Docker | Full-stack containerised deployment | system install |
| GitHub Actions | CI/CD pipeline | `.github/workflows/` |
| Qiskit Aer | Noise-model simulation for VQC training and validation | `pip install qiskit-aer` |
| Scikit-learn | Classical SVM baseline and preprocessing | `pip install scikit-learn` |
| Matplotlib | VQC circuit visualisation and barren plateau diagnosis | `pip install matplotlib` |

## Prerequisites

**Complete these first:**
- [ ] SK01–SK04: Quantum foundations — complete Qiskit textbook chapters 1–4
- [ ] SK55: VQC circuits — read the Qiskit Machine Learning VQC tutorial
- [ ] SK56: Angle encoding — understand RY/RZ gate rotations and feature map expressibility
- [ ] SK57: Barren plateaus — read McClean et al. (2018) and the PennyLane barren plateau tutorial
- [ ] SK26: PyTorch basics — complete the PyTorch 60-minute blitz if not already done

**Access needed:**
- [ ] IBM Quantum account (optional for real hardware; Qiskit Aer covers all training steps)
- [ ] Docker Desktop or Docker Engine
- [ ] InfluxDB Cloud free tier or local Docker instance for sensor data

---

## Step-by-Step Tutorial

### Step 1: Environment Setup

**Goal:** Install all dependencies and verify Qiskit + TKET integration works.

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Fill in: DATABASE_URL, INFLUXDB_URL, INFLUXDB_TOKEN, INFLUXDB_ORG, INFLUXDB_BUCKET
```

```python
# src/check_setup.py
from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator
from pytket import Circuit as TKETCircuit
from pytket.extensions.qiskit import qiskit_to_tk, tk_to_qiskit
import onnxruntime as rt

def verify_tket_qiskit_interop() -> dict:
    """Verify Qiskit ↔ TKET circuit conversion round-trip."""
    qc = QuantumCircuit(2)
    qc.h(0)
    qc.cx(0, 1)
    qc.ry(0.5, 0)

    tk_circuit = qiskit_to_tk(qc)
    qc_back = tk_to_qiskit(tk_circuit)
    return {
        "qiskit_gates": len(qc.data),
        "tket_gates": tk_circuit.n_gates,
        "round_trip_ok": len(qc_back.data) > 0,
    }

if __name__ == "__main__":
    result = verify_tket_qiskit_interop()
    print(result)
    assert result["round_trip_ok"], "TKET-Qiskit interop failed"
    print("Setup verified.")
```

**Verify:** `python src/check_setup.py` prints `round_trip_ok: True`. No import errors.

---

### Step 2: Theory Warm-Up — Angle Encoding and Expressibility

**Goal:** Build and visualise angle encoding circuits for an 8-dimensional sensor feature vector. Understand how qubit count maps to feature dimensionality.

```python
# src/vqc/encoding.py
import numpy as np
from qiskit import QuantumCircuit
from qiskit.circuit import ParameterVector


def build_angle_encoding_layer(
    n_qubits: int,
    feature_vector: np.ndarray | None = None,
) -> QuantumCircuit:
    """
    Build a single-layer angle encoding circuit (ZZFeatureMap-style).

    Each qubit i receives RY(pi * x_i) followed by RZ(pi * x_i) rotations.
    This encodes n_qubits features per layer. For n_features > n_qubits,
    use multiple encoding repetitions or data re-uploading.

    Args:
        n_qubits: Number of qubits (= number of features per layer)
        feature_vector: Optional concrete values to bind immediately

    Returns:
        QuantumCircuit with feature parameters or bound values
    """
    x = ParameterVector("x", length=n_qubits)
    qc = QuantumCircuit(n_qubits, name="AngleEncoding")

    for i in range(n_qubits):
        qc.ry(np.pi * x[i], i)
        qc.rz(np.pi * x[i], i)

    # Entanglement layer: linear CNOT chain
    for i in range(n_qubits - 1):
        qc.cx(i, i + 1)

    if feature_vector is not None:
        if len(feature_vector) != n_qubits:
            raise ValueError(
                f"Feature vector length {len(feature_vector)} must equal n_qubits {n_qubits}"
            )
        param_dict = {x[i]: float(feature_vector[i]) for i in range(n_qubits)}
        qc = qc.assign_parameters(param_dict)

    return qc


def check_expressibility(n_qubits: int, n_samples: int = 500) -> dict:
    """
    Estimate circuit expressibility by sampling random parameter sets and
    computing the Haar random deviation (simplified version).

    A highly expressible circuit covers the Hilbert space more uniformly.
    """
    from qiskit_aer import AerSimulator
    from qiskit.quantum_info import state_fidelity, Statevector

    simulator = AerSimulator(method="statevector")
    x = ParameterVector("x", n_qubits)
    qc = build_angle_encoding_layer(n_qubits)

    fidelities = []
    for _ in range(n_samples // 2):
        v1 = np.random.uniform(0, 1, n_qubits)
        v2 = np.random.uniform(0, 1, n_qubits)
        sv1 = Statevector(qc.assign_parameters({x[i]: v1[i] for i in range(n_qubits)}))
        sv2 = Statevector(qc.assign_parameters({x[i]: v2[i] for i in range(n_qubits)}))
        fidelities.append(float(state_fidelity(sv1, sv2)))

    return {
        "n_qubits": n_qubits,
        "mean_fidelity": float(np.mean(fidelities)),
        "std_fidelity": float(np.std(fidelities)),
        "haar_expected": 1.0 / (2 ** n_qubits + 1),
    }


if __name__ == "__main__":
    import numpy as np
    features = np.array([0.1, 0.5, 0.9, 0.2, 0.7, 0.3, 0.6, 0.8])
    qc = build_angle_encoding_layer(n_qubits=8, feature_vector=features)
    print(qc.draw())
    expr = check_expressibility(n_qubits=4, n_samples=100)
    print(f"Expressibility (mean fidelity): {expr['mean_fidelity']:.4f}")
```

**Verify:** The circuit diagram shows 8 qubits with RY, RZ pairs followed by CNOT chain. `check_expressibility` mean fidelity decreases as qubit count increases (more expressive).

---

### Step 3: VQC Ansatz Design

**Goal:** Build the full VQC — encoding layer + variational ansatz + measurement — with trainable parameters.

```python
# src/vqc/ansatz.py
import numpy as np
from qiskit import QuantumCircuit
from qiskit.circuit import ParameterVector
from src.vqc.encoding import build_angle_encoding_layer


def build_vqc_circuit(
    n_qubits: int = 8,
    n_layers: int = 3,
    reuploading: bool = True,
) -> QuantumCircuit:
    """
    Build a full Variational Quantum Classifier circuit.

    Structure (per layer):
      1. Angle encoding of input features (data re-uploading if reuploading=True)
      2. Variational block: Ry(theta) on each qubit + CNOT entanglement ring

    The output qubit (qubit 0) is measured in the Z basis.
    Classification: E[Z_0] > 0 → class 1 (anomaly), else class 0 (normal)

    Args:
        n_qubits: Number of qubits (= feature dimension)
        n_layers: Number of variational layers
        reuploading: If True, re-apply angle encoding at each layer (data re-uploading trick)

    Returns:
        QuantumCircuit with parameters x (features) and theta (variational)
    """
    x = ParameterVector("x", length=n_qubits)
    theta = ParameterVector("theta", length=n_qubits * n_layers)

    qc = QuantumCircuit(n_qubits, 1, name="VQC")

    param_idx = 0
    for layer in range(n_layers):
        # Data encoding (always for layer 0; optionally for subsequent layers)
        if layer == 0 or reuploading:
            for i in range(n_qubits):
                qc.ry(np.pi * x[i], i)
                qc.rz(np.pi * x[i], i)
            for i in range(n_qubits - 1):
                qc.cx(i, i + 1)

        # Variational block
        for i in range(n_qubits):
            qc.ry(theta[param_idx], i)
            param_idx += 1

        # Entanglement ring
        for i in range(n_qubits - 1):
            qc.cx(i, i + 1)
        qc.cx(n_qubits - 1, 0)  # close the ring

        if layer < n_layers - 1:
            qc.barrier()

    # Measure output qubit
    qc.measure(0, 0)

    return qc


def count_parameters(circuit: QuantumCircuit) -> dict:
    """Return parameter count and circuit depth statistics."""
    return {
        "n_parameters": circuit.num_parameters,
        "circuit_depth": circuit.depth(),
        "n_qubits": circuit.num_qubits,
        "gate_counts": dict(circuit.count_ops()),
    }


if __name__ == "__main__":
    vqc = build_vqc_circuit(n_qubits=8, n_layers=3)
    stats = count_parameters(vqc)
    print(f"VQC: {stats}")
    print(vqc.draw(fold=100))
```

**Verify:** `count_parameters` returns `n_parameters = 8*3 + 8 = 32` (theta + x). `circuit_depth` is reasonable (under 100 for 8 qubits, 3 layers). Gate counts show Ry, Rz, and CX operations.

---

### Step 4: TKET Circuit Compilation and Optimisation

**Goal:** Compile the VQC for IBM superconducting hardware topology using TKET to reduce gate count and circuit depth.

```python
# src/vqc/compilation.py
import numpy as np
from qiskit import QuantumCircuit
from qiskit.circuit import ParameterVector
from pytket import Circuit as TKETCircuit
from pytket.extensions.qiskit import qiskit_to_tk, tk_to_qiskit
from pytket.passes import (
    FullPeepholeOptimise,
    CommuteThroughMultis,
    CliffordSimp,
    SequencePass,
)
from pytket.backends.backendinfo import BackendInfo


def compile_vqc_with_tket(
    qiskit_circuit: QuantumCircuit,
    optimisation_level: int = 2,
) -> tuple[QuantumCircuit, dict]:
    """
    Compile a Qiskit VQC circuit using TKET's optimisation passes.

    TKET specialises in:
    - Gate cancellation (CommuteThroughMultis)
    - Clifford simplification (CliffordSimp)
    - Peephole optimisation (FullPeepholeOptimise)

    Args:
        qiskit_circuit: Input VQC circuit from build_vqc_circuit()
        optimisation_level: 0 (none), 1 (light), 2 (full)

    Returns:
        (optimised_qiskit_circuit, compilation_stats)
    """
    # Convert to TKET
    tk_circuit = qiskit_to_tk(qiskit_circuit)

    depth_before = tk_circuit.depth()
    gates_before = tk_circuit.n_gates

    if optimisation_level >= 1:
        CommuteThroughMultis().apply(tk_circuit)

    if optimisation_level >= 2:
        FullPeepholeOptimise().apply(tk_circuit)

    depth_after = tk_circuit.depth()
    gates_after = tk_circuit.n_gates

    # Convert back to Qiskit
    optimised_qc = tk_to_qiskit(tk_circuit)

    stats = {
        "depth_before": depth_before,
        "depth_after": depth_after,
        "depth_reduction_pct": (1 - depth_after / depth_before) * 100,
        "gates_before": gates_before,
        "gates_after": gates_after,
        "gate_reduction_pct": (1 - gates_after / gates_before) * 100,
    }
    return optimised_qc, stats


if __name__ == "__main__":
    from src.vqc.ansatz import build_vqc_circuit
    vqc = build_vqc_circuit(n_qubits=4, n_layers=2)
    optimised, stats = compile_vqc_with_tket(vqc, optimisation_level=2)
    print(f"Compilation stats: {stats}")
```

**Verify:** `depth_reduction_pct > 10` for a 4-qubit, 2-layer VQC. The compiled circuit maintains the same number of parameters (`ParameterVector` bindings are preserved).

---

### Step 5: Hybrid Quantum-Classical Training Loop

**Goal:** Train the VQC using the parameter shift rule for gradients and PyTorch's Adam optimizer.

```python
# src/training/trainer.py
import numpy as np
import torch
import torch.nn as nn
from qiskit import QuantumCircuit
from qiskit.circuit import ParameterVector
from qiskit_aer import AerSimulator
from qiskit_aer.noise import NoiseModel
from qiskit_ibm_runtime.fake_provider import FakeNairobi
from src.vqc.ansatz import build_vqc_circuit


def expectation_value(
    circuit: QuantumCircuit,
    theta_vals: np.ndarray,
    x_vals: np.ndarray,
    shots: int = 512,
    noisy: bool = False,
) -> float:
    """
    Estimate E[Z_0] for the VQC with given parameters.

    Uses Born rule: E[Z] = P(0) - P(1) from measurement statistics.
    """
    x_params = circuit.parameters
    feature_params = [p for p in x_params if p.name.startswith("x")]
    theta_params = [p for p in x_params if p.name.startswith("theta")]

    param_dict = {}
    for i, p in enumerate(sorted(feature_params, key=lambda p: p.index)):
        param_dict[p] = float(x_vals[i])
    for i, p in enumerate(sorted(theta_params, key=lambda p: p.index)):
        param_dict[p] = float(theta_vals[i])

    bound_circuit = circuit.assign_parameters(param_dict)

    if noisy:
        backend = FakeNairobi()
        noise_model = NoiseModel.from_backend(backend)
        simulator = AerSimulator(noise_model=noise_model)
    else:
        simulator = AerSimulator()

    job = simulator.run(bound_circuit, shots=shots)
    counts = job.result().get_counts()
    total = sum(counts.values())
    p0 = counts.get("0", 0) / total
    p1 = counts.get("1", 0) / total
    return p0 - p1  # Z expectation: +1 for |0>, -1 for |1>


def parameter_shift_gradient(
    circuit: QuantumCircuit,
    theta: np.ndarray,
    x: np.ndarray,
    param_idx: int,
    shift: float = np.pi / 2,
    shots: int = 512,
) -> float:
    """
    Compute gradient of E[Z_0] w.r.t. theta[param_idx] using parameter shift rule:
    dE/dtheta_i = [E(theta_i + pi/2) - E(theta_i - pi/2)] / 2
    """
    theta_plus = theta.copy()
    theta_plus[param_idx] += shift
    theta_minus = theta.copy()
    theta_minus[param_idx] -= shift

    e_plus = expectation_value(circuit, theta_plus, x, shots=shots)
    e_minus = expectation_value(circuit, theta_minus, x, shots=shots)
    return (e_plus - e_minus) / 2.0


class VQCClassifier:
    """
    Hybrid quantum-classical VQC classifier.

    The quantum circuit acts as a non-linear feature map; the output
    expectation value is the classifier score. Training uses the parameter
    shift rule for gradients.
    """

    def __init__(
        self,
        n_qubits: int = 8,
        n_layers: int = 3,
        lr: float = 0.01,
        shots: int = 256,
    ):
        self.n_qubits = n_qubits
        self.n_layers = n_layers
        self.n_params = n_qubits * n_layers
        self.lr = lr
        self.shots = shots
        self.circuit = build_vqc_circuit(n_qubits=n_qubits, n_layers=n_layers)
        self.theta = np.random.uniform(-np.pi, np.pi, self.n_params)

    def predict_score(self, x: np.ndarray) -> float:
        """Return raw E[Z_0] score in [-1, 1]. Positive = anomaly."""
        return expectation_value(self.circuit, self.theta, x, shots=self.shots)

    def predict(self, x: np.ndarray, threshold: float = 0.0) -> int:
        """Return binary prediction: 1 = anomaly, 0 = normal."""
        return 1 if self.predict_score(x) > threshold else 0

    def train_step(self, X: np.ndarray, y: np.ndarray) -> float:
        """
        One gradient step over a batch using parameter shift gradients.

        Loss: binary cross-entropy between sigmoid(E[Z_0]) and y in {0,1}
        """
        # Convert labels: 0 → -1, 1 → +1 for Z-expectation loss
        y_signed = 2.0 * y - 1.0

        total_loss = 0.0
        grad_accumulator = np.zeros(self.n_params)

        for xi, yi in zip(X, y_signed):
            score = expectation_value(self.circuit, self.theta, xi, shots=self.shots)
            # Hinge loss: max(0, 1 - yi * score)
            loss = max(0.0, 1.0 - yi * score)
            total_loss += loss

            if loss > 0:
                for idx in range(self.n_params):
                    grad = parameter_shift_gradient(
                        self.circuit, self.theta, xi, idx, shots=self.shots
                    )
                    grad_accumulator[idx] -= yi * grad  # gradient of hinge loss

        # Adam-style update (simplified: gradient descent)
        self.theta -= self.lr * grad_accumulator / len(X)
        return total_loss / len(X)

    def evaluate(self, X: np.ndarray, y: np.ndarray) -> dict:
        """Evaluate accuracy and F1 score."""
        predictions = [self.predict(xi) for xi in X]
        correct = sum(p == yi for p, yi in zip(predictions, y))
        tp = sum(p == 1 and yi == 1 for p, yi in zip(predictions, y))
        fp = sum(p == 1 and yi == 0 for p, yi in zip(predictions, y))
        fn = sum(p == 0 and yi == 1 for p, yi in zip(predictions, y))
        precision = tp / (tp + fp + 1e-8)
        recall = tp / (tp + fn + 1e-8)
        f1 = 2 * precision * recall / (precision + recall + 1e-8)
        return {
            "accuracy": correct / len(y),
            "precision": precision,
            "recall": recall,
            "f1": f1,
        }
```

**Verify:** Run 5 training steps on a 4-qubit VQC with 20 synthetic samples. Loss decreases. `evaluate` returns `accuracy > 0.5` after 10 epochs.

---

### Step 6: Barren Plateau Diagnosis

**Goal:** Detect barren plateaus by measuring gradient variance as a function of qubit count and circuit depth.

```python
# src/vqc/barren_plateau_check.py
import numpy as np
from src.vqc.training.trainer import parameter_shift_gradient, expectation_value
from src.vqc.ansatz import build_vqc_circuit


def gradient_variance_scan(
    qubit_counts: list[int] = None,
    n_samples: int = 30,
    n_layers: int = 2,
    shots: int = 128,
) -> dict:
    """
    Estimate gradient variance for each qubit count.

    Barren plateau signature: variance decreases exponentially with n_qubits.
    Threshold: if variance < 1e-4 for n_qubits > 10, barren plateau is likely.
    """
    if qubit_counts is None:
        qubit_counts = [2, 4, 6, 8]

    results = {}
    for n_q in qubit_counts:
        circuit = build_vqc_circuit(n_qubits=n_q, n_layers=n_layers)
        n_params = n_q * n_layers
        grads = []

        for _ in range(n_samples):
            theta = np.random.uniform(-np.pi, np.pi, n_params)
            x = np.random.uniform(0, 1, n_q)
            idx = np.random.randint(0, n_params)
            g = parameter_shift_gradient(circuit, theta, x, idx, shots=shots)
            grads.append(g)

        results[n_q] = {
            "mean_gradient": float(np.mean(grads)),
            "gradient_variance": float(np.var(grads)),
            "barren_plateau_risk": "HIGH" if np.var(grads) < 1e-3 else "LOW",
        }

    return results


if __name__ == "__main__":
    results = gradient_variance_scan(qubit_counts=[2, 4], n_samples=10, shots=64)
    for n_q, stats in results.items():
        print(f"{n_q} qubits: variance={stats['gradient_variance']:.6f}, "
              f"risk={stats['barren_plateau_risk']}")
```

**Verify:** For n_qubits=2, gradient variance is relatively large (> 0.01). For n_qubits=8+, variance should be noticeably smaller. Document findings to justify chosen n_layers and ansatz structure.

---

### Step 7: ONNX Export and TensorFlow Lite Conversion

**Goal:** Export the trained VQC as an ONNX model (using the classically-simulated feature map) for edge inference.

```python
# src/export/onnx_export.py
import numpy as np
import torch
import torch.nn as nn
import onnx
import onnxruntime as rt
from src.training.trainer import VQCClassifier


class VQCClassifierNN(nn.Module):
    """
    Classical neural network approximation of the trained VQC for ONNX export.

    In production, this can be:
    a) A direct classical approximation trained to mimic VQC outputs.
    b) A lookup/interpolation table of the quantum feature map.
    c) A tensor-network simulation of the VQC (for shallow circuits).
    """

    def __init__(self, n_features: int = 8, hidden_dim: int = 32):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(n_features, hidden_dim),
            nn.Tanh(),
            nn.Linear(hidden_dim, hidden_dim),
            nn.Tanh(),
            nn.Linear(hidden_dim, 1),
            nn.Tanh(),  # Output in [-1, 1] to mimic E[Z_0]
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.net(x)


def distil_vqc_to_nn(
    vqc_classifier: VQCClassifier,
    n_train_samples: int = 500,
    n_features: int = 8,
    epochs: int = 100,
) -> VQCClassifierNN:
    """
    Train a classical NN to approximate the VQC's input-output mapping.

    This is the 'knowledge distillation' approach for edge deployment:
    the NN is trained on (random_inputs, vqc_outputs) pairs.
    """
    nn_model = VQCClassifierNN(n_features=n_features)
    optimizer = torch.optim.Adam(nn_model.parameters(), lr=1e-3)
    loss_fn = nn.MSELoss()

    # Generate training data from VQC (slow — this is the offline distillation step)
    X_train = np.random.uniform(0, 1, (n_train_samples, n_features))
    y_train = np.array([vqc_classifier.predict_score(x) for x in X_train])

    X_tensor = torch.tensor(X_train, dtype=torch.float32)
    y_tensor = torch.tensor(y_train, dtype=torch.float32).unsqueeze(1)

    for epoch in range(epochs):
        optimizer.zero_grad()
        preds = nn_model(X_tensor)
        loss = loss_fn(preds, y_tensor)
        loss.backward()
        optimizer.step()
        if epoch % 20 == 0:
            print(f"Distillation epoch {epoch}: MSE={loss.item():.4f}")

    return nn_model


def export_to_onnx(
    nn_model: VQCClassifierNN,
    n_features: int = 8,
    output_path: str = "models/vqc_classifier.onnx",
) -> str:
    """Export the distilled VQC model to ONNX format."""
    nn_model.eval()
    dummy_input = torch.randn(1, n_features)
    torch.onnx.export(
        nn_model,
        dummy_input,
        output_path,
        input_names=["sensor_features"],
        output_names=["anomaly_score"],
        dynamic_axes={
            "sensor_features": {0: "batch_size"},
            "anomaly_score": {0: "batch_size"},
        },
        opset_version=17,
    )
    return output_path


def verify_onnx_inference(onnx_path: str, n_features: int = 8) -> dict:
    """Verify the exported ONNX model produces correct output shapes."""
    session = rt.InferenceSession(onnx_path)
    input_name = session.get_inputs()[0].name
    dummy_batch = np.random.rand(4, n_features).astype(np.float32)
    outputs = session.run(None, {input_name: dummy_batch})
    return {
        "output_shape": list(outputs[0].shape),
        "output_range": [float(outputs[0].min()), float(outputs[0].max())],
        "inference_ok": outputs[0].shape == (4, 1),
    }


if __name__ == "__main__":
    import os
    os.makedirs("models", exist_ok=True)
    # For quick testing: use a tiny VQC
    vqc = VQCClassifier(n_qubits=4, n_layers=1, shots=64)
    nn_model = distil_vqc_to_nn(vqc, n_train_samples=50, n_features=4, epochs=20)
    path = export_to_onnx(nn_model, n_features=4, output_path="models/vqc_tiny.onnx")
    result = verify_onnx_inference(path, n_features=4)
    print(result)
```

**Verify:** `verify_onnx_inference` returns `inference_ok: True`. The ONNX file is created at `models/vqc_classifier.onnx`. ONNX Runtime inference latency is under 10ms for a single sample.

---

### Step 8: InfluxDB Sensor Data Integration

**Goal:** Read sensor telemetry from InfluxDB, preprocess it into VQC feature vectors, and generate anomaly predictions.

```python
# src/data/influxdb_reader.py
import os
import numpy as np
from datetime import datetime, timedelta
from influxdb_client import InfluxDBClient
from influxdb_client.client.query_api import QueryApi

SENSOR_FIELDS = [
    "vibration_rms",
    "temperature_c",
    "pressure_bar",
    "current_a",
    "voltage_v",
    "rpm",
    "acoustic_db",
    "humidity_pct",
]


def get_influxdb_client() -> InfluxDBClient:
    return InfluxDBClient(
        url=os.environ["INFLUXDB_URL"],
        token=os.environ["INFLUXDB_TOKEN"],
        org=os.environ["INFLUXDB_ORG"],
    )


def fetch_sensor_window(
    device_id: str,
    window_minutes: int = 5,
    bucket: str = None,
) -> np.ndarray | None:
    """
    Fetch the latest sensor readings for a device and return as a feature vector.

    Aggregates mean values over the specified time window.
    Returns None if insufficient data is available.
    """
    bucket = bucket or os.environ.get("INFLUXDB_BUCKET", "sensors")
    client = get_influxdb_client()
    query_api = client.query_api()

    field_filters = " or ".join([f'r["_field"] == "{f}"' for f in SENSOR_FIELDS])
    query = f"""
    from(bucket: "{bucket}")
      |> range(start: -{window_minutes}m)
      |> filter(fn: (r) => r["device_id"] == "{device_id}")
      |> filter(fn: (r) => {field_filters})
      |> aggregateWindow(every: {window_minutes}m, fn: mean, createEmpty: false)
      |> last()
    """
    tables = query_api.query(query)
    client.close()

    readings: dict[str, float] = {}
    for table in tables:
        for record in table.records:
            readings[record["_field"]] = record["_value"]

    if len(readings) < len(SENSOR_FIELDS):
        return None

    # Normalise to [0, 1] using min-max scaling from historical bounds
    # In production: load these bounds from a PostgreSQL calibration table
    BOUNDS = {
        "vibration_rms": (0.0, 10.0),
        "temperature_c": (20.0, 120.0),
        "pressure_bar": (0.0, 10.0),
        "current_a": (0.0, 50.0),
        "voltage_v": (0.0, 480.0),
        "rpm": (0.0, 3600.0),
        "acoustic_db": (40.0, 120.0),
        "humidity_pct": (0.0, 100.0),
    }
    features = []
    for field in SENSOR_FIELDS:
        lo, hi = BOUNDS[field]
        val = np.clip(readings.get(field, lo), lo, hi)
        features.append((val - lo) / (hi - lo))

    return np.array(features, dtype=np.float32)
```

**Verify:** After starting InfluxDB locally (`docker run -p 8086:8086 influxdb:2.7`) and writing synthetic sensor data, `fetch_sensor_window("device_001")` returns a numpy array of shape `(8,)` with values in [0, 1].

---

### Step 9: FastAPI Anomaly Detection Endpoint

**Goal:** Expose the VQC anomaly detector as a production FastAPI service backed by ONNX Runtime inference.

```python
# src/api/main.py
import os
import numpy as np
import onnxruntime as rt
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from prometheus_client import Gauge, Counter, start_http_server
from src.data.influxdb_reader import fetch_sensor_window

app = FastAPI(
    title="VQC Anomaly Detection API",
    description="Quantum-classical hybrid anomaly detection for IoT sensor networks",
    version="1.0.0",
)

# Prometheus metrics
ANOMALY_SCORE = Gauge("vqc_anomaly_score", "VQC anomaly score [-1,1]", ["device_id"])
ANOMALY_COUNTER = Counter("anomalies_detected_total", "Total anomalies detected", ["device_id"])
INFERENCE_LATENCY = Gauge("onnx_inference_latency_ms", "ONNX inference latency in ms")

# Lazy-loaded ONNX session
_ORT_SESSION: rt.InferenceSession | None = None


def get_ort_session() -> rt.InferenceSession:
    global _ORT_SESSION
    if _ORT_SESSION is None:
        model_path = os.environ.get("ONNX_MODEL_PATH", "models/vqc_classifier.onnx")
        if not os.path.exists(model_path):
            raise RuntimeError(f"ONNX model not found at {model_path}. Run training first.")
        _ORT_SESSION = rt.InferenceSession(model_path)
    return _ORT_SESSION


class SensorReading(BaseModel):
    device_id: str
    features: list[float] = Field(
        min_length=8,
        max_length=8,
        description="8 normalised sensor features [0,1]: vibration, temp, pressure, "
                    "current, voltage, rpm, acoustic, humidity",
    )


class AnomalyResponse(BaseModel):
    device_id: str
    anomaly_score: float = Field(description="VQC score in [-1,1]. Positive = anomaly.")
    is_anomaly: bool
    confidence: float = Field(description="Confidence = |anomaly_score|, range [0,1]")
    threshold: float = 0.0


@app.on_event("startup")
async def startup():
    start_http_server(port=9090)


@app.post("/predict-anomaly", response_model=AnomalyResponse)
async def predict_anomaly(reading: SensorReading) -> AnomalyResponse:
    """
    Run VQC anomaly detection on a sensor feature vector.

    The ONNX model is a classically-distilled approximation of the trained VQC,
    enabling sub-millisecond edge inference without a QPU.
    """
    session = get_ort_session()
    features = np.array(reading.features, dtype=np.float32).reshape(1, -1)

    input_name = session.get_inputs()[0].name
    import time
    t0 = time.perf_counter()
    outputs = session.run(None, {input_name: features})
    latency_ms = (time.perf_counter() - t0) * 1000

    score = float(outputs[0][0, 0])
    is_anomaly = score > 0.0
    confidence = abs(score)

    # Update Prometheus metrics
    ANOMALY_SCORE.labels(device_id=reading.device_id).set(score)
    INFERENCE_LATENCY.set(latency_ms)
    if is_anomaly:
        ANOMALY_COUNTER.labels(device_id=reading.device_id).inc()

    return AnomalyResponse(
        device_id=reading.device_id,
        anomaly_score=score,
        is_anomaly=is_anomaly,
        confidence=confidence,
    )


@app.post("/predict-from-influxdb")
async def predict_from_influxdb(device_id: str) -> AnomalyResponse:
    """
    Fetch the latest sensor window from InfluxDB and run anomaly detection.
    """
    features = fetch_sensor_window(device_id)
    if features is None:
        raise HTTPException(
            status_code=404,
            detail=f"Insufficient sensor data for device {device_id}",
        )
    reading = SensorReading(device_id=device_id, features=features.tolist())
    return await predict_anomaly(reading)


@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}
```

**Verify:** `uvicorn src.api.main:app --reload` starts. `POST /predict-anomaly` with 8 normalised features returns 200 with `is_anomaly` bool and `confidence` in [0,1]. Latency logged by `INFERENCE_LATENCY` is under 10ms.

---

### Step 10: Monitoring and CI/CD

**Goal:** Add CI with VQC circuit construction tests and a docker-compose stack with InfluxDB + Prometheus.

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
          POSTGRES_DB: anomaly_detection
        ports:
          - "5432:5432"
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      influxdb:
        image: influxdb:2.7
        ports:
          - "8086:8086"
        env:
          DOCKER_INFLUXDB_INIT_MODE: setup
          DOCKER_INFLUXDB_INIT_USERNAME: admin
          DOCKER_INFLUXDB_INIT_PASSWORD: password123
          DOCKER_INFLUXDB_INIT_ORG: test-org
          DOCKER_INFLUXDB_INIT_BUCKET: sensors
          DOCKER_INFLUXDB_INIT_ADMIN_TOKEN: test-token
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install -r requirements.txt
      - run: pytest tests/ -v --tb=short -x
        env:
          DATABASE_URL: postgresql://postgres:test@localhost:5432/anomaly_detection
          INFLUXDB_URL: http://localhost:8086
          INFLUXDB_TOKEN: test-token
          INFLUXDB_ORG: test-org
          INFLUXDB_BUCKET: sensors
```

```yaml
# docker-compose.yml
version: "3.9"
services:
  api:
    build: .
    ports:
      - "8000:8000"
      - "9090:9090"    # Prometheus metrics
    environment:
      DATABASE_URL: postgresql://postgres:postgres@db:5432/anomaly_detection
      INFLUXDB_URL: http://influxdb:8086
      INFLUXDB_TOKEN: ${INFLUXDB_TOKEN}
      INFLUXDB_ORG: ${INFLUXDB_ORG}
      INFLUXDB_BUCKET: sensors
      ONNX_MODEL_PATH: /app/models/vqc_classifier.onnx
    volumes:
      - ./models:/app/models
    depends_on:
      - db
      - influxdb

  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: anomaly_detection
    volumes:
      - pgdata:/var/lib/postgresql/data

  influxdb:
    image: influxdb:2.7
    ports:
      - "8086:8086"
    environment:
      DOCKER_INFLUXDB_INIT_MODE: setup
      DOCKER_INFLUXDB_INIT_USERNAME: admin
      DOCKER_INFLUXDB_INIT_PASSWORD: ${INFLUXDB_PASSWORD:-password123}
      DOCKER_INFLUXDB_INIT_ORG: ${INFLUXDB_ORG:-myorg}
      DOCKER_INFLUXDB_INIT_BUCKET: sensors
      DOCKER_INFLUXDB_INIT_ADMIN_TOKEN: ${INFLUXDB_TOKEN}
    volumes:
      - influxdata:/var/lib/influxdb2

volumes:
  pgdata:
  influxdata:
```

**Verify:** `docker compose up --build` starts all three services. `curl http://localhost:8000/health` returns `{"status":"ok"}`. `curl http://localhost:9090/metrics` returns Prometheus text with `vqc_anomaly_score` gauge.

---

## Testing

```bash
# Unit tests — no QPU required
pytest tests/unit/test_angle_encoding.py -v      # Encoding circuit construction
pytest tests/unit/test_ansatz.py -v              # VQC parameter counts and circuit depth
pytest tests/unit/test_barren_plateau.py -v      # Gradient variance check on 2-qubit VQC
pytest tests/unit/test_onnx_export.py -v         # ONNX export and round-trip inference

# Integration tests — requires InfluxDB
pytest tests/integration/test_influxdb_reader.py -v
pytest tests/integration/test_api_predict.py -v

# Full training smoke test (4-qubit VQC for speed)
python -c "
from src.training.trainer import VQCClassifier
import numpy as np
vqc = VQCClassifier(n_qubits=4, n_layers=1, shots=64)
X = np.random.rand(10, 4)
y = np.array([0,1,0,1,0,1,0,1,0,1])
loss = vqc.train_step(X, y)
print(f'Training loss: {loss:.4f}')
assert loss >= 0
print('Training smoke test: PASSED')
"
```

Key test cases:
- `build_vqc_circuit(8, 3)` has exactly `8*3 = 24` theta parameters and 8 x parameters
- `build_angle_encoding_layer(8, feature_vector)` raises `ValueError` when `len(feature_vector) != 8`
- ONNX export produces a model that accepts `(batch_size, 8)` input and returns `(batch_size, 1)` output
- `parameter_shift_gradient` returns 0 when the circuit is constant w.r.t. that parameter
- FastAPI `POST /predict-anomaly` with feature list length 7 returns 422
- Barren plateau check: gradient variance for 2-qubit VQC is larger than for 8-qubit VQC

---

## Deployment

```bash
# 1. Train VQC and distil to ONNX (offline step)
python src/training/trainer.py        # Train VQC on anomaly dataset
python src/export/onnx_export.py      # Export to models/vqc_classifier.onnx

# 2. Build and deploy
docker build -t vqc-anomaly-api:latest .
docker compose up -d

# 3. Verify inference
curl -X POST http://localhost:8000/predict-anomaly \
  -H "Content-Type: application/json" \
  -d '{"device_id": "pump-001", "features": [0.1, 0.5, 0.3, 0.7, 0.4, 0.8, 0.2, 0.6]}'
```

---

## Resources

1. [Qiskit Machine Learning — VQC Tutorial](https://qiskit-community.github.io/qiskit-machine-learning/tutorials/02a_training_a_quantum_model_on_a_real_dataset.html) — Official VQC training guide
2. [TKET Documentation](https://tket.quantinuum.com/api-docs/) — Circuit compilation and optimisation passes
3. [PyTKET-Qiskit Extension](https://tket.quantinuum.com/extensions/pytket-qiskit/) — Qiskit ↔ TKET conversion
4. [McClean et al. (2018) — Barren Plateaus in Training of Quantum Neural Networks](https://www.nature.com/articles/s41467-018-07090-4) — Barren plateau theory
5. [Pérez-Salinas et al. (2020) — Data Re-uploading for a Universal Quantum Classifier](https://quantum-journal.org/papers/q-2020-02-06-226/) — Data re-uploading technique
6. [ONNX Runtime Documentation](https://onnxruntime.ai/docs/) — Edge inference setup
7. [InfluxDB Python Client](https://github.com/influxdata/influxdb-client-python) — Time-series data ingestion
8. [Parameter Shift Rule](https://pennylane.ai/qml/glossary/parameter_shift/) — Analytic gradient computation for VQCs
