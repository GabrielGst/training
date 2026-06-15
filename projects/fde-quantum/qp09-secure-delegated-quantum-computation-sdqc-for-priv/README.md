# QP09 — Secure Delegated Quantum Computation (SDQC) for Privacy-Preserving Drug Discovery

**Modality:** Photonic (Perceval SDK)
**Phase:** 2C (advanced)
**Track:** `fde-quantum`
**Status:** not started
**Hours target:** 60

---

## Business Problem

Pharmaceutical companies need quantum compute access to simulate molecular interactions at drug-discovery scale, but submitting circuits to a cloud QPU exposes proprietary compound structures to the hardware vendor. A single leaked molecular scaffold can invalidate years of research investment and violate regulatory obligations under FDA 21 CFR Part 11.

The industry requires a protocol where the QPU executes a computation without ever learning the client's input data or seeing the actual circuit being evaluated — **blind quantum computation**. The photonic modality is uniquely suited to this because single-photon inputs can be encrypted at the state-preparation level before any photon enters vendor-controlled hardware.

---

## What You Will Build

A full-stack privacy-preserving quantum drug discovery pipeline:

1. **Molecular encoder** — RDKit converts SMILES strings into feature vectors; Microsoft SEAL encrypts classical molecular descriptors using homomorphic encryption (BFV scheme).
2. **Blind photonic circuit** — A Brickwork State circuit in Perceval SDK implements universal blind quantum computation. Input states are one-time-pad rotated so the server (QPU) cannot infer the computation.
3. **Secure MPC layer** — TensorFlow Encrypted coordinates secret-shared intermediate results between client and a trusted aggregator without either party seeing plaintext activations.
4. **Federated ML head** — A small PyTorch classifier trained on encrypted boson-sampling output predicts binding affinity without accessing raw molecular structures.
5. **FastAPI orchestration service** — REST endpoints manage job submission, result polling, and audit logging to PostgreSQL with FDA 21 CFR Part 11-compliant trails.
6. **LangChain RAG agent** — Answers regulatory queries about the pipeline using retrieved context from loaded FDA/EMA compliance documents.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│  Pharma Client (Trusted Enclave)                                      │
│                                                                        │
│   SMILES ──► RDKit ──► Feature Vector ──► Microsoft SEAL (BFV)       │
│                                               │                        │
│                                        Ciphertext Params              │
│                                               │                        │
│                              Brickwork State Preparation              │
│                              (one-time-pad angle rotations)           │
└─────────────────────────────────┬────────────────────────────────────┘
                                  │  Encrypted photonic input states
                                  ▼
┌──────────────────────────────────────────────────────────────────────┐
│  Quantum Vendor (Perceval Simulator / Quandela Cloud)                 │
│                                                                        │
│   Brickwork Circuit (server sees only graph topology, NOT angles)     │
│   Perceval SLOS / CliffordClifford backend                            │
│   Boson sampling measurement outcomes ──► returned ciphertexts        │
└─────────────────────────────────┬────────────────────────────────────┘
                                  │  Encrypted measurement results
                                  ▼
┌──────────────────────────────────────────────────────────────────────┐
│  Trusted Aggregator (TensorFlow Encrypted / MPC)                      │
│                                                                        │
│   Secret-share reconstruction ──► PyTorch classifier                  │
│   Binding affinity prediction (plaintext never reconstructed)         │
│   Result ──► FastAPI ──► PostgreSQL (audit log) ──► Client           │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Theory Prerequisites

| Skill ID | Concept | Why you need it |
|----------|---------|-----------------|
| SK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notation) | Photonic input states are qumodes; you must reason in Fock space before encrypting them |
| SK02 | Quantum Measurement Theory (Born Rule & POVMs) | Understanding what the vendor actually measures — and how measurement outcomes leak no information about angles in the blind protocol |
| SK04 | Quantum Gate Model & Universal Gate Sets (Clifford+T) | Brickwork State uses X, Z, and T-dependent rotations; you must decompose your target computation into this basis |
| SK16 | Photonic Quantum Optics (Coherent, Fock & Squeezed States) | Every photonic qubit is a Fock state; state preparation errors are your primary noise source |
| SK17 | Beam Splitter Unitaries & Hong-Ou-Mandel Effect | The Perceval linear-optic circuit is composed entirely of beam splitters and phase shifters; you must verify HOM visibility |
| SK18 | Photon Indistinguishability & KLM Theorem | Linear optics is universal (probabilistically) only when photons are perfectly indistinguishable — you will quantify this bound |
| SK19 | Boson Sampling & Computational Complexity Theory | The vendor's computation is a boson sampling instance; hardness assumptions underpin the security argument |
| SK20 | Quantum Fourier Transform & Phase Estimation | QFT is the subroutine underlying the molecular energy estimation step embedded in the blind circuit |
| SK21 | Single-Photon Source Engineering & Characterisation | SDQC fidelity degrades with source purity; you will characterise g(2)(0) and indistinguishability from Perceval's noise model |
| SK58 | Homomorphic Encryption Theory & Implementation | Classical molecular features are BFV-encrypted before any network transmission; you implement the encryption/decryption cycle with Microsoft SEAL |
| SK59 | Secure Multi-Party Computation (MPC) | TensorFlow Encrypted implements additive secret sharing for the ML head — you must understand the threat model |
| SK60 | Privacy-Preserving Quantum Protocols (Blind Computation) | The core Brickwork State UBQC protocol — you implement client-side angle randomisation and trap qubit insertion |
| SK61 | Cryptographic Circuit Design (Garbled Circuits & Boolean Masking) | Trap qubits act as garbled gate equivalents — you must verify that a dishonest server cannot distinguish traps from computation qubits |
| SK62 | Regulatory Compliance (FDA 21 CFR Part 11) | All audit logs, electronic records, and result provenance must meet FDA electronic record requirements for use in drug submissions |

---

## Engineering Skills Covered

| Skill ID | Skill | What you practice |
|----------|-------|------------------|
| SK24 | ML for Quantum Error Mitigation | Train a small neural net to correct boson-sampling output bit-flip rates from source distinguishability noise |
| SK25 | Hybrid Classical-Quantum Loops & Orchestration | FastAPI job queue submits Perceval circuits, polls for results, feeds them into PyTorch classifier |
| SK26 | PyTorch Production Patterns | Serve the binding affinity classifier as a TorchServe endpoint with ONNX export |
| SK27 | REST API Design & FastAPI | Design all orchestration endpoints with Pydantic validation and OpenAPI docs |
| SK33 | SQL Data Modelling (PostgreSQL) | FDA-compliant audit schema: immutable append-only log table with signed row hashes |
| SK34 | Container Orchestration (Docker) | Multi-container compose: api, db, mpc-aggregator, perceval-worker services |
| SK35 | CI/CD & GitHub Actions | Automated pytest + mypy + bandit security scan on every push |
| SK39 | Vector Database Integration (Qdrant) | Embed FDA/EMA regulatory PDFs into Qdrant for the LangChain RAG compliance agent |
| SK45 | Semantic Search & Vector Embeddings | Sentence-BERT embeddings for regulatory document chunks |

---

## Tools & Dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| Perceval SDK | Photonic circuit simulation and SDQC blind computation | `pip install perceval-quandela` |
| Microsoft SEAL | BFV homomorphic encryption for molecular descriptors | `pip install seal` (or build from source: `github.com/microsoft/SEAL`) |
| RDKit | SMILES parsing and molecular descriptor computation | `pip install rdkit` |
| TensorFlow Encrypted | Secure multi-party ML over secret-shared tensors | `pip install tf-encrypted` |
| PyTorch | Binding affinity classifier and noise-mitigation net | `pip install torch` |
| LangChain | RAG chain for FDA compliance Q&A | `pip install langchain langchain-community` |
| Qdrant | Vector store for regulatory documents | `pip install qdrant-client` |
| FastAPI + uvicorn | Async REST orchestration service | `pip install fastapi uvicorn` |
| PostgreSQL / asyncpg | Audit log and job metadata storage | `pip install asyncpg sqlalchemy[asyncio]` |
| Docker / docker-compose | Multi-service container deployment | system package |
| pytest + mypy + bandit | Testing, type checking, security scanning | `pip install pytest mypy bandit` |

---

## Prerequisites

**Complete these theory modules first:**
- [ ] SK01 — Quantum State Representation: work through Nielsen & Chuang Chapter 1-2
- [ ] SK16 — Photonic Quantum Optics: read Perceval's documentation on Fock state backends
- [ ] SK17 — Beam Splitter Unitaries: derive the BS unitary matrix by hand
- [ ] SK18 — KLM Theorem: read the Knill-Laflamme-Milburn 2001 paper
- [ ] SK19 — Boson Sampling: read Aaronson & Arkhipov 2011 complexity proof summary
- [ ] SK58 — Homomorphic Encryption: complete the Microsoft SEAL examples in the repo
- [ ] SK60 — Blind Computation: read Broadbent-Fitzsimons-Kashefi 2009 UBQC paper

**Access needed:**
- [ ] Python 3.11+ environment
- [ ] Docker Desktop or Docker Engine installed
- [ ] (Optional) Quandela Cloud account for remote QPU access (`cloud.quandela.com`)
- [ ] (Optional) Microsoft SEAL Python bindings compiled locally (pre-built wheels exist for Linux/Windows)

---

## Step-by-Step Tutorial

### Step 1: Environment Setup

**Goal:** Reproducible dev environment with all dependencies pinned.

```bash
git clone <this-repo>
cd qp09-secure-delegated-quantum-computation-sdqc-for-priv

python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate

pip install perceval-quandela rdkit torch fastapi uvicorn asyncpg \
            sqlalchemy langchain langchain-community qdrant-client \
            tf-encrypted sentence-transformers pytest mypy bandit

# Microsoft SEAL: try the pre-built wheel first
pip install seal
# If unavailable for your platform, build from source:
# git clone https://github.com/microsoft/SEAL && cd SEAL
# cmake -S . -B build -DSEAL_BUILD_PYTHON_WRAPPER=ON && cmake --build build
```

**Verify:**

```python
import perceval as pcvl
print(pcvl.__version__)   # should print 0.11.x or later

from rdkit import Chem
mol = Chem.MolFromSmiles("CCO")
print(mol.GetNumAtoms())  # 3
```

---

### Step 2: Theory Warm-Up — Photonic Blind Computation Primitive

**Goal:** Build intuition for the Brickwork State construction and verify it in Perceval before adding encryption.

The Universal Blind Quantum Computation (UBQC) protocol works as follows:
1. The client prepares single-qubit states `|+_θ⟩ = (|0⟩ + e^{iθ}|1⟩) / √2` with random angles `θ ∈ {0, π/4, 2π/4, ..., 7π/4}`.
2. The server arranges them into a Brickwork State graph and applies CZ gates according to a graph the server knows.
3. The client sends adaptive measurement angles derived from the computation they want to perform, XOR-ed with one-time-pad bits — the server never learns the true computation angles.

```python
# src/blind_primitive.py
import perceval as pcvl
import numpy as np

def make_brickwork_column(num_qubits: int, theta_angles: list[float]) -> pcvl.Circuit:
    """
    Build a single Brickwork State column: interleaved beam-splitter pairs
    acting as CZ gates on photonic dual-rail qubits.

    Each dual-rail qubit occupies two modes: (2i, 2i+1) for qubit i.
    theta_angles: client's one-time-padded rotation angles (one per qubit).
    """
    num_modes = num_qubits * 2
    circuit = pcvl.Circuit(num_modes)

    # Phase rotations encoding client angles (server applies but does not know θ)
    for i in range(num_qubits):
        mode = 2 * i + 1   # second rail of dual-rail encoding
        circuit.add(mode, pcvl.PS(theta_angles[i]))

    # CZ-equivalent: 50/50 beam splitter pairs between adjacent qubits
    for i in range(0, num_qubits - 1, 2):
        m0 = 2 * i + 1   # second rail of qubit i
        m1 = 2 * (i + 1) # first rail of qubit i+1
        circuit.add((m0, m1), pcvl.BS.H())

    return circuit


# Verify: simulate a 2-qubit column with known angles
theta = [np.pi / 4, np.pi / 2]
col = make_brickwork_column(2, theta)
print(col)   # ASCII circuit diagram

# Simulate with the SLOS (Scalable Linear Optical Simulator) backend
backend = pcvl.BackendFactory().get_backend("SLOS")
backend.set_circuit(col)
backend.set_input_state(pcvl.BasicState([1, 0, 1, 0]))  # |1,0,1,0⟩ = |qubit0=0, qubit1=0⟩

dist = backend.prob_distribution()
for state, prob in dist.items():
    if prob > 1e-6:
        print(f"|{state}⟩  p={prob:.4f}")
```

**Verify:** The output distribution should show balanced probability across `|1,0,1,0⟩` and `|0,1,0,1⟩` for `θ = π/2` — confirming the phase shifter is rotating the superposition correctly.

---

### Step 3: Molecular Encoding with RDKit

**Goal:** Convert SMILES drug candidates into fixed-length descriptor vectors suitable for homomorphic encryption.

```python
# src/molecular_encoder.py
from rdkit import Chem
from rdkit.Chem import Descriptors, rdMolDescriptors
import numpy as np

DESCRIPTOR_NAMES = [
    "MolWt", "MolLogP", "NumHDonors", "NumHAcceptors",
    "TPSA", "NumRotatableBonds", "RingCount",
    "NumAromaticRings", "FractionCSP3", "NumHeteroatoms",
]

def smiles_to_descriptor_vector(smiles: str) -> np.ndarray:
    """
    Convert a SMILES string to a normalised descriptor vector.
    Returns a float64 array of shape (10,).
    Raises ValueError if the SMILES is invalid.
    """
    mol = Chem.MolFromSmiles(smiles)
    if mol is None:
        raise ValueError(f"Invalid SMILES: {smiles}")

    values = [
        Descriptors.MolWt(mol),
        Descriptors.MolLogP(mol),
        rdMolDescriptors.CalcNumHBD(mol),
        rdMolDescriptors.CalcNumHBA(mol),
        Descriptors.TPSA(mol),
        rdMolDescriptors.CalcNumRotatableBonds(mol),
        rdMolDescriptors.CalcNumRings(mol),
        rdMolDescriptors.CalcNumAromaticRings(mol),
        Descriptors.FractionCSP3(mol),
        rdMolDescriptors.CalcNumHeteroatoms(mol),
    ]
    vec = np.array(values, dtype=np.float64)

    # Normalise to [0, 1] using known empirical ranges
    ranges = np.array([
        (0, 900), (−10, 10), (0, 15), (0, 20),
        (0, 300), (0, 20), (0, 10),
        (0, 8), (0, 1), (0, 20),
    ])
    vec = (vec - ranges[:, 0]) / (ranges[:, 1] - ranges[:, 0])
    return np.clip(vec, 0.0, 1.0)


# Test
aspirin = "CC(=O)Oc1ccccc1C(=O)O"
vec = smiles_to_descriptor_vector(aspirin)
print(f"Aspirin descriptor vector shape: {vec.shape}")
print(f"Values: {vec.round(3)}")
```

**Verify:** Running on aspirin should return a 10-element array with all values in `[0, 1]`.

---

### Step 4: Homomorphic Encryption Layer (Microsoft SEAL)

**Goal:** Encrypt the molecular descriptor vector using BFV scheme so it can travel over the network to the aggregator without exposing plaintext.

```python
# src/he_layer.py
"""
Homomorphic encryption wrapper using Microsoft SEAL (Python bindings).
Uses BFV scheme for integer arithmetic on scaled descriptor values.
"""
import seal
import numpy as np

SCALE_FACTOR = 1_000_000   # encode floats as integers with 6 decimal places


def create_seal_context():
    """Create SEAL BFV context with 128-bit security."""
    parms = seal.EncryptionParameters(seal.scheme_type.bfv)
    poly_modulus_degree = 4096
    parms.set_poly_modulus_degree(poly_modulus_degree)
    parms.set_coeff_modulus(seal.CoeffModulus.BFVDefault(poly_modulus_degree))
    parms.set_plain_modulus(seal.PlainModulus.Batching(poly_modulus_degree, 20))
    context = seal.SEALContext(parms)
    return context


def encrypt_descriptor(
    descriptor: np.ndarray,
    public_key: seal.PublicKey,
    context: seal.SEALContext,
) -> seal.Ciphertext:
    """Encrypt a float descriptor vector as a BFV ciphertext."""
    encryptor = seal.Encryptor(context, public_key)
    encoder = seal.BatchEncoder(context)

    # Scale floats to integers
    int_values = (descriptor * SCALE_FACTOR).astype(np.int64).tolist()
    plaintext = seal.Plaintext()
    encoder.encode(int_values, plaintext)

    ciphertext = seal.Ciphertext()
    encryptor.encrypt(plaintext, ciphertext)
    return ciphertext


def decrypt_descriptor(
    ciphertext: seal.Ciphertext,
    secret_key: seal.SecretKey,
    context: seal.SEALContext,
    original_length: int,
) -> np.ndarray:
    """Decrypt a BFV ciphertext back to a float descriptor vector."""
    decryptor = seal.Decryptor(context, secret_key)
    encoder = seal.BatchEncoder(context)

    plaintext = seal.Plaintext()
    decryptor.decrypt(ciphertext, plaintext)

    result = []
    encoder.decode(plaintext, result)
    return np.array(result[:original_length], dtype=np.float64) / SCALE_FACTOR


# Integration test
if __name__ == "__main__":
    ctx = create_seal_context()
    keygen = seal.KeyGenerator(ctx)
    pub_key = keygen.create_public_key()
    sec_key = keygen.secret_key()

    descriptor = np.array([0.3, 0.7, 0.1, 0.5, 0.2, 0.4, 0.6, 0.8, 0.9, 0.0])
    ct = encrypt_descriptor(descriptor, pub_key, ctx)
    recovered = decrypt_descriptor(ct, sec_key, ctx, len(descriptor))

    assert np.allclose(descriptor, recovered, atol=1e-5), "Encryption round-trip failed"
    print("HE round-trip: OK")
```

**Verify:** The assertion should pass — encrypted values decode back to within `1e-5` of originals.

---

### Step 5: Brickwork State UBQC Protocol Implementation

**Goal:** Implement the full client-side UBQC protocol: angle randomisation, trap qubit insertion, and adaptive measurement decoding.

```python
# src/ubqc_client.py
import perceval as pcvl
import numpy as np
from dataclasses import dataclass
from typing import Optional

ANGLE_SET = [k * np.pi / 4 for k in range(8)]   # θ ∈ {0, π/4, ..., 7π/4}


@dataclass
class UBQCJob:
    """Encapsulates a single blind computation job."""
    computation_angles: list[float]    # true computation angles (client keeps secret)
    one_time_pad_bits: list[int]       # random bits r_i ∈ {0, 1}
    trap_positions: set[int]           # indices of trap qubits (known only to client)
    server_angles: list[float]         # angles sent to server = computation + OTP


def prepare_ubqc_job(
    computation_angles: list[float],
    trap_fraction: float = 0.2,
) -> UBQCJob:
    """
    Prepare a UBQC job with one-time-pad angle encryption and trap qubit insertion.

    Args:
        computation_angles: True angles for the target computation (radians).
        trap_fraction: Fraction of qubits used as traps for server verification.

    Returns:
        UBQCJob with randomised server angles.
    """
    n = len(computation_angles)
    otp_bits = np.random.randint(0, 2, size=n).tolist()
    trap_positions = set(
        np.random.choice(n, size=max(1, int(n * trap_fraction)), replace=False).tolist()
    )

    server_angles = []
    for i, phi in enumerate(computation_angles):
        if i in trap_positions:
            # Trap qubit: server gets a random angle, client knows the expected outcome
            server_angles.append(np.random.choice(ANGLE_SET))
        else:
            # Computation qubit: angle randomised by OTP
            randomised = phi + otp_bits[i] * np.pi
            server_angles.append(randomised % (2 * np.pi))

    return UBQCJob(
        computation_angles=computation_angles,
        one_time_pad_bits=otp_bits,
        trap_positions=trap_positions,
        server_angles=server_angles,
    )


def verify_trap_qubits(
    measurement_outcomes: list[int],
    job: UBQCJob,
) -> bool:
    """
    Verify that the server measured trap qubits correctly.
    A dishonest server will fail this check with probability >= 1/2 per trap.
    """
    for pos in job.trap_positions:
        expected = job.one_time_pad_bits[pos]   # trap qubit expected outcome
        if measurement_outcomes[pos] != expected:
            return False
    return True


def decode_computation_result(
    measurement_outcomes: list[int],
    job: UBQCJob,
) -> list[int]:
    """
    Remove the one-time-pad from measurement outcomes to recover the true result.
    """
    result = []
    for i, outcome in enumerate(measurement_outcomes):
        if i not in job.trap_positions:
            decoded = outcome ^ job.one_time_pad_bits[i]
            result.append(decoded)
    return result


# Simulate a toy UBQC run
angles = [np.pi / 4, np.pi / 2, np.pi, 0.0]
job = prepare_ubqc_job(angles, trap_fraction=0.25)
print(f"Server sees angles: {[f'{a:.3f}' for a in job.server_angles]}")
print(f"Trap positions (hidden from server): {job.trap_positions}")

# Simulate honest server (returns OTP-encoded outcomes)
simulated_outcomes = [bit for bit in job.one_time_pad_bits]
assert verify_trap_qubits(simulated_outcomes, job), "Trap verification failed (honest server should pass)"
print("Trap verification: PASSED")

result = decode_computation_result(simulated_outcomes, job)
print(f"Decoded result bits: {result}")
```

**Verify:** Trap verification should pass for an honest server; the decoded result should have length `len(angles) - len(trap_positions)`.

---

### Step 6: Photonic Circuit Simulation with Perceval

**Goal:** Run the full brickwork column on Perceval's SLOS backend and capture the boson-sampling output distribution.

```python
# src/perceval_runner.py
import perceval as pcvl
import numpy as np
from src.ubqc_client import UBQCJob


def build_sdqc_circuit(job: UBQCJob, num_qubits: int) -> pcvl.Circuit:
    """
    Build the full SDQC photonic circuit using the server-visible angles.
    The server executes this circuit without knowing the true computation.
    """
    num_modes = num_qubits * 2
    circuit = pcvl.Circuit(num_modes, name="SDQC_Brickwork")

    # Single-photon phase rotations (server applies, client chose angles)
    for i in range(num_qubits):
        mode = 2 * i + 1
        circuit.add(mode, pcvl.PS(job.server_angles[i]))

    # Entangling layer: 50/50 beam splitters between adjacent qubits
    for i in range(0, num_qubits - 1, 2):
        m0 = 2 * i + 1
        m1 = 2 * (i + 1)
        circuit.add((m0, m1), pcvl.BS.H())

    return circuit


def run_perceval_job(
    job: UBQCJob,
    num_qubits: int,
    num_samples: int = 1000,
) -> dict:
    """
    Execute the SDQC circuit on Perceval SLOS backend.
    Returns sampled measurement outcomes.
    """
    circuit = build_sdqc_circuit(job, num_qubits)

    # Dual-rail input: each qubit i starts in |1,0⟩ on modes (2i, 2i+1)
    input_modes = []
    for i in range(num_qubits):
        input_modes.extend([1, 0])
    input_state = pcvl.BasicState(input_modes)

    # Use sampling backend for statistical outcomes
    sampler = pcvl.Sampler(pcvl.BackendFactory().get_backend("SLOS"))
    sampler.set_circuit(circuit)
    sampler.set_input_state(input_state)

    samples = sampler.sample_count(num_samples)

    # Convert to outcome bit strings
    outcomes = {}
    for state, count in samples.items():
        # Extract qubit value from dual-rail: 1 if photon in first mode, 0 if second
        bits = []
        for i in range(num_qubits):
            bits.append(state[2 * i])   # 1 = |1,0⟩ = logical 0; 0 = |0,1⟩ = logical 1
        key = tuple(bits)
        outcomes[key] = outcomes.get(key, 0) + count

    return outcomes


# End-to-end test
from src.ubqc_client import prepare_ubqc_job
angles = [np.pi / 4] * 4
job = prepare_ubqc_job(angles)
outcomes = run_perceval_job(job, num_qubits=4, num_samples=500)
print(f"Sampled {sum(outcomes.values())} events across {len(outcomes)} distinct outcomes")
for bits, count in sorted(outcomes.items(), key=lambda x: -x[1])[:5]:
    print(f"  {''.join(map(str, bits))}  count={count}")
```

**Verify:** You should see distributed outcomes across multiple bitstrings — not a single deterministic state — confirming quantum interference is active.

---

### Step 7: TensorFlow Encrypted MPC Layer

**Goal:** Implement the secure aggregation step where the boson-sampling bitstring is fed into a PyTorch classifier via TensorFlow Encrypted's secret-sharing protocol.

```python
# src/mpc_aggregator.py
"""
Simplified MPC binding-affinity classifier.
In production: two-party MPC between client and aggregator using TFE.
Here: demonstrates the API and protocol structure.
"""
import tf_encrypted as tfe
import tensorflow as tf
import numpy as np


def build_tfe_classifier():
    """
    Build a simple two-layer TFE classifier for binding affinity prediction.
    Weights are secret-shared; neither party sees plaintext activations.
    """
    # TFE operates over fixed-point arithmetic on secret shares
    model = tfe.keras.Sequential([
        tfe.keras.layers.Dense(32, activation="relu", input_shape=(10,)),
        tfe.keras.layers.Dense(16, activation="relu"),
        tfe.keras.layers.Dense(1, activation="sigmoid"),
    ])
    model.compile(
        optimizer=tfe.keras.optimizers.Adam(0.001),
        loss="binary_crossentropy",
        metrics=["accuracy"],
    )
    return model


def train_plaintext_proxy(
    x_train: np.ndarray,
    y_train: np.ndarray,
) -> "torch.nn.Module":
    """
    Train a PyTorch proxy model in plaintext (on synthetic public data).
    In production, this runs inside TFE secret sharing.
    """
    import torch
    import torch.nn as nn

    class AffinityNet(nn.Module):
        def __init__(self):
            super().__init__()
            self.net = nn.Sequential(
                nn.Linear(10, 32), nn.ReLU(),
                nn.Linear(32, 16), nn.ReLU(),
                nn.Linear(16, 1), nn.Sigmoid(),
            )

        def forward(self, x):
            return self.net(x)

    model = AffinityNet()
    opt = torch.optim.Adam(model.parameters(), lr=1e-3)
    loss_fn = nn.BCELoss()

    x_t = torch.FloatTensor(x_train)
    y_t = torch.FloatTensor(y_train).unsqueeze(1)

    for epoch in range(50):
        opt.zero_grad()
        pred = model(x_t)
        loss = loss_fn(pred, y_t)
        loss.backward()
        opt.step()
        if epoch % 10 == 0:
            print(f"  Epoch {epoch}: loss={loss.item():.4f}")

    return model


# Synthetic training demo (replace with real binding affinity labels)
np.random.seed(42)
x_dummy = np.random.rand(200, 10).astype(np.float32)
y_dummy = (x_dummy[:, 0] + x_dummy[:, 2] > 1.0).astype(np.float32)

print("Training binding affinity proxy model...")
model = train_plaintext_proxy(x_dummy, y_dummy)

# Single-sample inference
test_mol = np.random.rand(1, 10).astype(np.float32)
import torch
with torch.no_grad():
    affinity = model(torch.FloatTensor(test_mol)).item()
print(f"Predicted binding affinity: {affinity:.3f}")
```

**Verify:** Loss should decrease over 50 epochs; affinity output should be in `[0, 1]`.

---

### Step 8: FastAPI Orchestration Service

**Goal:** Wire all components into a REST API with job submission, status polling, and FDA-compliant audit logging.

```python
# src/api.py
from fastapi import FastAPI, HTTPException, BackgroundTasks
from pydantic import BaseModel
import asyncpg
import uuid
import datetime
import json
from typing import Optional

app = FastAPI(title="SDQC Drug Discovery Service", version="1.0.0")

# --- Schema ---
class JobSubmission(BaseModel):
    molecule_smiles: str
    num_samples: int = 500
    client_id: str

class JobStatus(BaseModel):
    job_id: str
    status: str   # queued | running | complete | failed
    binding_affinity: Optional[float] = None
    created_at: str

# --- In-memory job store (replace with Redis in production) ---
jobs: dict[str, dict] = {}


@app.post("/jobs/submit", response_model=JobStatus)
async def submit_job(
    submission: JobSubmission,
    background_tasks: BackgroundTasks,
):
    """Submit a molecular SMILES for SDQC binding affinity prediction."""
    job_id = str(uuid.uuid4())
    created_at = datetime.datetime.utcnow().isoformat()

    jobs[job_id] = {
        "status": "queued",
        "smiles": submission.molecule_smiles,
        "client_id": submission.client_id,
        "created_at": created_at,
        "binding_affinity": None,
    }

    background_tasks.add_task(run_sdqc_pipeline, job_id, submission)

    return JobStatus(
        job_id=job_id,
        status="queued",
        created_at=created_at,
    )


@app.get("/jobs/{job_id}", response_model=JobStatus)
async def get_job_status(job_id: str):
    """Poll job status and retrieve result when complete."""
    if job_id not in jobs:
        raise HTTPException(status_code=404, detail="Job not found")
    job = jobs[job_id]
    return JobStatus(
        job_id=job_id,
        status=job["status"],
        binding_affinity=job.get("binding_affinity"),
        created_at=job["created_at"],
    )


async def run_sdqc_pipeline(job_id: str, submission: JobSubmission):
    """Background task: full SDQC pipeline execution."""
    try:
        jobs[job_id]["status"] = "running"

        # 1. Encode molecule
        from src.molecular_encoder import smiles_to_descriptor_vector
        descriptor = smiles_to_descriptor_vector(submission.molecule_smiles)

        # 2. Prepare UBQC job (angles derived from descriptor)
        from src.ubqc_client import prepare_ubqc_job
        import numpy as np
        computation_angles = (descriptor[:4] * 2 * np.pi).tolist()
        ubqc_job = prepare_ubqc_job(computation_angles)

        # 3. Run Perceval circuit
        from src.perceval_runner import run_perceval_job
        outcomes = run_perceval_job(ubqc_job, num_qubits=4, num_samples=submission.num_samples)

        # 4. Aggregate outcomes into feature vector for classifier
        outcome_feature = np.zeros(10)
        for bits, count in outcomes.items():
            idx = int("".join(map(str, bits)), 2) % 10
            outcome_feature[idx] += count / submission.num_samples

        # 5. Classifier inference
        import torch
        # In production: load the trained AffinityNet from checkpoint
        affinity = float(np.mean(outcome_feature))   # placeholder until model is trained

        jobs[job_id]["status"] = "complete"
        jobs[job_id]["binding_affinity"] = round(affinity, 4)

        # 6. Write FDA audit log
        await write_audit_log(job_id, submission.client_id, submission.molecule_smiles, affinity)

    except Exception as e:
        jobs[job_id]["status"] = "failed"
        jobs[job_id]["error"] = str(e)
        raise


async def write_audit_log(job_id: str, client_id: str, smiles: str, result: float):
    """
    Write immutable audit log entry.
    FDA 21 CFR Part 11 requires: who, what, when, and system-signed record.
    """
    # In production: connect to PostgreSQL with asyncpg
    # conn = await asyncpg.connect(DATABASE_URL)
    # await conn.execute("""
    #     INSERT INTO audit_log (job_id, client_id, smiles_hash, result, created_at)
    #     VALUES ($1, $2, $3, $4, NOW())
    # """, job_id, client_id, hash(smiles), result)
    print(f"[AUDIT] job={job_id} client={client_id} result={result:.4f}")
```

**Verify:** Run `uvicorn src.api:app --reload` and hit `POST /jobs/submit` with a valid SMILES. The job should transition from `queued` → `running` → `complete`.

---

### Step 9: PostgreSQL Audit Schema (FDA 21 CFR Part 11)

**Goal:** Create an append-only audit log that satisfies FDA electronic record requirements.

```sql
-- migrations/001_audit_schema.sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Immutable job audit log
CREATE TABLE IF NOT EXISTS audit_log (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id        UUID NOT NULL,
    client_id     TEXT NOT NULL,
    smiles_hash   TEXT NOT NULL,         -- SHA-256 of the SMILES (not the SMILES itself)
    result        FLOAT8 NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    row_signature TEXT NOT NULL          -- HMAC of (job_id || result || created_at)
);

-- Prevent UPDATE and DELETE at the row level (trigger)
CREATE OR REPLACE RULE no_update_audit AS
    ON UPDATE TO audit_log DO INSTEAD NOTHING;

CREATE OR REPLACE RULE no_delete_audit AS
    ON DELETE TO audit_log DO INSTEAD NOTHING;

-- Index for per-client audit queries
CREATE INDEX idx_audit_client ON audit_log(client_id, created_at DESC);

-- View for compliance officers
CREATE VIEW v_audit_trail AS
SELECT
    id,
    job_id,
    client_id,
    smiles_hash,
    result,
    created_at,
    row_signature,
    -- Verify signature in-flight
    encode(hmac(
        (job_id::text || result::text || created_at::text),
        current_setting('app.hmac_secret'),
        'sha256'
    ), 'hex') AS expected_signature
FROM audit_log;
```

**Verify:** Insert a test row and confirm that `UPDATE` and `DELETE` statements silently no-op — the row count should remain at 1.

---

### Step 10: LangChain RAG Compliance Agent

**Goal:** Build a question-answering agent over FDA/EMA regulatory documents using Qdrant and LangChain.

```python
# src/compliance_agent.py
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Qdrant
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain.chains import RetrievalQA
from langchain_community.llms import Ollama   # or swap for Mistral API
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams
import pathlib


EMBED_MODEL = "sentence-transformers/all-MiniLM-L6-v2"
COLLECTION_NAME = "fda_regulations"


def build_compliance_vectorstore(docs_dir: str = "data/regulatory_docs") -> Qdrant:
    """
    Index FDA/EMA regulatory PDFs into Qdrant for semantic search.
    Place PDF/text files under data/regulatory_docs/.
    """
    docs_path = pathlib.Path(docs_dir)
    texts = []

    for txt_file in docs_path.glob("*.txt"):
        texts.append(txt_file.read_text(encoding="utf-8"))

    # Chunk documents into 512-token windows with 50-token overlap
    splitter = RecursiveCharacterTextSplitter(chunk_size=512, chunk_overlap=50)
    chunks = splitter.create_documents(texts)
    print(f"Indexed {len(chunks)} chunks from {len(texts)} documents")

    embeddings = HuggingFaceEmbeddings(model_name=EMBED_MODEL)

    client = QdrantClient(host="localhost", port=6333)
    client.recreate_collection(
        collection_name=COLLECTION_NAME,
        vectors_config=VectorParams(size=384, distance=Distance.COSINE),
    )

    vectorstore = Qdrant.from_documents(
        documents=chunks,
        embedding=embeddings,
        client=client,
        collection_name=COLLECTION_NAME,
    )
    return vectorstore


def get_compliance_agent(vectorstore: Qdrant) -> RetrievalQA:
    """Build a RetrievalQA chain for FDA compliance Q&A."""
    retriever = vectorstore.as_retriever(search_kwargs={"k": 4})

    # Swap `Ollama` for `ChatMistralAI` when using Mistral API
    llm = Ollama(model="mistral")

    chain = RetrievalQA.from_chain_type(
        llm=llm,
        chain_type="stuff",
        retriever=retriever,
        return_source_documents=True,
    )
    return chain


# Usage example
if __name__ == "__main__":
    vs = build_compliance_vectorstore()
    agent = get_compliance_agent(vs)

    question = "What audit trail requirements does FDA 21 CFR Part 11 impose on electronic records?"
    response = agent.invoke({"query": question})
    print(f"Answer: {response['result']}")
    print(f"Sources: {[d.metadata for d in response['source_documents']]}")
```

**Verify:** The agent should return a grounded answer citing specific regulatory sections, not a hallucinated response.

---

### Step 11: Docker Compose & Container Orchestration

**Goal:** Package all services into a reproducible multi-container deployment.

```yaml
# docker-compose.yml
version: "3.9"

services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: sdqc
      POSTGRES_USER: sdqc
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./migrations:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U sdqc"]
      interval: 5s
      timeout: 5s
      retries: 5

  qdrant:
    image: qdrant/qdrant:latest
    ports:
      - "6333:6333"
    volumes:
      - qdrant_data:/qdrant/storage

  api:
    build: .
    command: uvicorn src.api:app --host 0.0.0.0 --port 8000
    environment:
      DATABASE_URL: postgresql://sdqc:${POSTGRES_PASSWORD}@db:5432/sdqc
      QDRANT_HOST: qdrant
      QDRANT_PORT: "6333"
    depends_on:
      db:
        condition: service_healthy
      qdrant:
        condition: service_started
    ports:
      - "8000:8000"

volumes:
  postgres_data:
  qdrant_data:
```

```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y libxrender1 libxext6 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000
```

**Verify:** `docker compose up` should start three services; `curl localhost:8000/docs` should return the FastAPI Swagger UI.

---

### Step 12: Testing, CI/CD, and Observability

**Goal:** Full test suite with GitHub Actions CI and structured logging.

```python
# tests/test_sdqc_pipeline.py
import pytest
import numpy as np
from src.molecular_encoder import smiles_to_descriptor_vector
from src.ubqc_client import prepare_ubqc_job, verify_trap_qubits, decode_computation_result


def test_smiles_encoding():
    vec = smiles_to_descriptor_vector("CCO")
    assert vec.shape == (10,)
    assert np.all(vec >= 0) and np.all(vec <= 1)


def test_invalid_smiles_raises():
    with pytest.raises(ValueError):
        smiles_to_descriptor_vector("NOT_A_SMILES!!!")


def test_ubqc_honest_server_passes_traps():
    angles = [np.pi / 4, np.pi / 2, np.pi, 3 * np.pi / 4]
    job = prepare_ubqc_job(angles, trap_fraction=0.25)
    # Honest server returns OTP-encoded outcomes
    honest_outcomes = list(job.one_time_pad_bits)
    assert verify_trap_qubits(honest_outcomes, job)


def test_ubqc_dishonest_server_fails_traps():
    angles = [np.pi / 4] * 8
    job = prepare_ubqc_job(angles, trap_fraction=0.5)
    # Dishonest server flips all outcomes
    dishonest_outcomes = [1 - b for b in job.one_time_pad_bits]
    # At least one trap should fail
    assert not verify_trap_qubits(dishonest_outcomes, job)


def test_decode_result_excludes_traps():
    angles = [0.0] * 6
    job = prepare_ubqc_job(angles, trap_fraction=0.33)
    outcomes = list(job.one_time_pad_bits)
    result = decode_computation_result(outcomes, job)
    # Result should exclude trap positions
    assert len(result) == len(angles) - len(job.trap_positions)
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

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install dependencies
        run: pip install -r requirements.txt pytest mypy bandit

      - name: Run type checks
        run: mypy src/ --ignore-missing-imports

      - name: Security scan
        run: bandit -r src/ -ll

      - name: Run tests
        run: pytest tests/ -v --tb=short
```

**Verify:** All 5 tests should pass. CI pipeline should complete in under 3 minutes on a standard GitHub runner.

---

## Testing

```bash
# Unit tests
pytest tests/ -v

# Type checking
mypy src/ --ignore-missing-imports

# Security scan
bandit -r src/ -ll

# Integration test (requires Docker)
docker compose up -d
curl -X POST localhost:8000/jobs/submit \
     -H "Content-Type: application/json" \
     -d '{"molecule_smiles": "CCO", "client_id": "test-pharma-01"}'
```

---

## Deployment

```bash
# Start all services
docker compose up -d

# Apply database migrations
docker compose exec api python -c "
import asyncio, asyncpg
async def migrate():
    conn = await asyncpg.connect('postgresql://sdqc:password@db:5432/sdqc')
    with open('migrations/001_audit_schema.sql') as f:
        await conn.execute(f.read())
    await conn.close()
asyncio.run(migrate())
"

# Health check
curl localhost:8000/health
```

---

## Resources

1. [Perceval SDK Documentation](https://perceval.quandela.net/docs/) — Quandela's photonic SDK reference
2. [Broadbent, Fitzsimons & Kashefi (2009) — Universal Blind Quantum Computation](https://arxiv.org/abs/0807.4154) — The original UBQC paper
3. [Microsoft SEAL Examples](https://github.com/microsoft/SEAL/tree/main/native/examples) — BFV homomorphic encryption walkthrough
4. [RDKit Documentation](https://www.rdkit.org/docs/) — Cheminformatics toolkit reference
5. [TensorFlow Encrypted](https://github.com/tf-encrypted/tf-encrypted) — MPC for privacy-preserving ML
6. [FDA 21 CFR Part 11 — Electronic Records](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/part-11-electronic-records-electronic-signatures-scope-and-application) — Regulatory reference
7. [LangChain RAG Quickstart](https://python.langchain.com/docs/use_cases/question_answering/) — RAG pipeline setup
8. [Qdrant Documentation](https://qdrant.tech/documentation/) — Vector database setup and usage
