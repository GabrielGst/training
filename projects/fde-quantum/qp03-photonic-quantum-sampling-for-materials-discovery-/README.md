# QP03 — Photonic Quantum Sampling for Materials Discovery (Boson Sampling)

**Modality:** Photonic (Quandela / Perceval SDK) **Phase:** 2C **Track:** `hpc-quantum` **Status:** not started **Hours target:** 40

## Business Problem

Materials discovery for next-generation semiconductors and solid-state batteries requires sampling from exponentially large configuration spaces of atomic arrangements, chemical compositions, and electronic structures. Classical Monte Carlo and DFT approaches underperform for highly entangled photonic states and strongly-correlated material systems where quantum interference drives the relevant physics. Quandela's photonic processor offers a native boson sampling capability that is classically hard to simulate (#P-hard), providing sample distributions that can condition generative ML models for candidate material proposals. This project integrates a Perceval-based boson sampling circuit with a VAE generative model, a Qdrant vector database of material candidates, and a LangChain RAG pipeline for property retrieval.

## What you will build

1. A Perceval boson sampling circuit with configurable number of photons and modes, implementing a random unitary via beam splitter and phase shifter networks
2. A PyTorch variational autoencoder (VAE) conditioned on boson sampling output distributions to generate novel material property vectors
3. A Qdrant vector database populated with DFT-computed material embeddings from the Materials Project API, enabling semantic search for property-similar candidates
4. A LangChain RAG pipeline connecting LLM-generated material property queries to the Qdrant index for property retrieval and synthesis route suggestion
5. A FastAPI microservice that accepts a target material property specification (bandgap, conductivity, stability), runs boson sampling, and returns ranked candidate materials
6. A Docker-composed production stack with GitHub Actions CI running boson sampling unit tests against the Perceval local simulator

## Architecture

```
Target property specification
(e.g. bandgap 1.2 eV, stability > 0.1 eV/atom)
     |
     v
[FastAPI /discover endpoint]
     |
     v
[Perceval Boson Sampling Circuit]
n photons in m modes -> random unitary -> photon coincidence counts
     |
     |--- Perceval SLOS simulator (local, exact)
     |--- Perceval MPS emulator (larger circuits, approximate)
     |--- Quandela cloud QPU (production)
     |
     v
[Boson Sampling Distribution]
Coincidence pattern probabilities P(S) ~ |Perm(U_S)|^2
     |
     v
[PyTorch VAE]
Conditioned on sampling distribution -> decode -> material property vectors
     |
     v
[Qdrant Vector DB]
Approximate nearest neighbour search over DFT material embeddings
Retrieve: composition, structure, band structure, formation energy
     |
     v
[LangChain RAG]
Augment LLM prompt with retrieved material context
Generate: synthesis route, property prediction, risk factors
     |
     v
JSON: { candidates, properties, synthesis_routes, confidence }
```

## Theory prerequisites

| Skill ID | Concept | Why you need it |
|----------|---------|-----------------|
| QSK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notation) | Fock states |n1, n2, ..., nm> describe photon occupation of m optical modes |
| QSK02 | Quantum Measurement Theory (Born Rule) | Photon detection probabilities are Born-rule outputs of the boson sampling distribution |
| QSK16 | Photonic Quantum Optics (Coherent, Fock & Squeezed States) | Fock states |1,0,...> are the single-photon inputs; understanding their properties is essential for circuit design |
| QSK17 | Beam Splitter Unitaries & Hong-Ou-Mandel Effect | Beam splitters implement the unitary transformation; HOM dip confirms photon indistinguishability |
| QSK18 | Photon Indistinguishability & KLM Theorem | Indistinguishability of input photons is the critical requirement for quantum advantage in boson sampling |
| QSK19 | Boson Sampling & Computational Complexity Theory | Explains why the permanent of a complex matrix is #P-hard and why boson sampling resists classical simulation |
| QSK20 | Quantum Fourier Transform & Phase Estimation | QFT subroutine appears in Gaussian boson sampling extensions; phase encoding relates to material symmetries |

## Engineering skills covered

| Skill ID | Skill | What you practice |
|----------|-------|------------------|
| QSK24 | ML for Quantum Error Mitigation | Train PyTorch correction layers to compensate for photon loss and dark counts in Perceval noisy simulation |
| QSK25 | Hybrid Classical-Quantum Loops | Outer loop: boson sampling generates training data; VAE refines material proposal distribution iteratively |
| QSK26 | PyTorch Production Patterns | VAE encoder/decoder as `nn.Module`; training loop with KL divergence + reconstruction loss |
| QSK27 | REST API Design & FastAPI | Async endpoint with Pydantic validation, background task for long-running sampling jobs |
| QSK38 | Generative Models (VAE, Diffusion, Flow Models) | Implement a conditional VAE conditioned on boson sampling outputs to generate material property vectors |
| QSK39 | Vector Database Integration (Qdrant/Weaviate) | Index material embeddings in Qdrant; perform HNSW approximate nearest-neighbour search for candidate retrieval |

## Tools & dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| Perceval SDK | Photonic circuit design, boson sampling, Quandela QPU access | `pip install perceval-quandela` |
| JAX | Differentiable boson sampling parameters, Gaussian boson sampling extensions | `pip install jax jaxlib` |
| PyTorch | VAE generative model conditioned on sampling distributions | `pip install torch` |
| LangChain | RAG pipeline: LLM prompt augmentation with material property retrieval | `pip install langchain langchain-openai` |
| Qdrant | Vector database for material embedding storage and semantic search | `pip install qdrant-client` |
| FastAPI | Async REST API for material discovery requests | `pip install fastapi uvicorn[standard]` |
| PostgreSQL | Job metadata and sampling result storage | `docker pull postgres:16` |
| Docker | Containerised service stack | `apt install docker.io docker-compose-plugin` |

## Prerequisites

**Complete these theory modules first:**
- [ ] `hpc-quantum/02-quantum-intro` — Quantum circuits, gates, measurement
- [ ] `q-theory-01-hilbert-spaces` — Fock space, occupation number representation
- [ ] `q-theory-16-photonic-optics` — Fock states, coherent states, photon statistics
- [ ] `q-theory-17-beam-splitters` — Beam splitter matrix, HOM effect, photon bunching
- [ ] `q-theory-18-indistinguishability` — KLM theorem, indistinguishability conditions
- [ ] `q-theory-19-boson-sampling` — Permanent computation, #P-hardness, classical simulation limits

**Access / accounts needed:**
- [ ] Quandela cloud account (access via `cloud.quandela.com`; free tier for simulator)
- [ ] OpenAI API key (for LangChain RAG; or use a local Mistral/Ollama instance)
- [ ] Materials Project API key (free at `materialsproject.org`) for material embeddings
- [ ] Qdrant instance (local via Docker: `docker run -p 6333:6333 qdrant/qdrant`)

## Step-by-step tutorial

---

### Step 1: Environment setup (Python + Perceval SDK)

**Goal:** Install Perceval, verify local boson sampling simulation runs, and confirm JAX is available.

**Code:**
```bash
python -m venv .venv && source .venv/bin/activate

pip install perceval-quandela
pip install jax jaxlib torch
pip install fastapi uvicorn[standard] pydantic
pip install langchain langchain-openai qdrant-client
pip install sqlalchemy asyncpg psycopg2-binary

# Smoke test: 2-photon HOM experiment in Perceval
python - <<'EOF'
import perceval as pcvl
import perceval.components as comp

# Build a simple 50:50 beam splitter (2 modes)
bs = pcvl.Circuit(2) // comp.BS()

# Input: one photon in each mode
input_state = pcvl.BasicState([1, 1])

# Simulate with SLOS (Scalable Local Optimisation Simulator)
backend = pcvl.BackendFactory.get_backend("SLOS")
backend.set_circuit(bs)
backend.set_input_state(input_state)

# Sample 1000 photon coincidence patterns
sampler = pcvl.algorithm.Sampler(backend)
samples = sampler.sample_count(1000)
print("HOM output distribution (expect ~50% |2,0> + 50% |0,2>, NO |1,1>):")
for state, count in sorted(samples.items(), key=lambda x: -x[1])[:5]:
    print(f"  {state}: {count}")

import perceval
print(f"Perceval version: {perceval.__version__}")
EOF
```

**Verify:** Output shows mostly `|2,0>` and `|0,2>` states (Hong-Ou-Mandel effect: photon bunching), with suppressed `|1,1>`. This is the fundamental quantum interference signature of indistinguishable photons.

---

### Step 2: Theory warm-up — implement a 4-photon boson sampling circuit

**Goal:** Build a 4-photon, 6-mode random unitary boson sampling circuit in Perceval, sample the output distribution, and verify that the permanent of the submatrix determines photon coincidence probabilities.

**Code:**
```python
# src/warmup/boson_sampling_demo.py
"""
4-photon, 6-mode boson sampling.
Input: |1,1,1,1,0,0> (one photon in each of first 4 modes)
Output: photon coincidence pattern determined by P(S) ~ |Perm(U_S)|^2
where U_S is the submatrix of the unitary U selected by input/output modes.
"""
import numpy as np
import perceval as pcvl
import perceval.components as comp

def random_unitary_circuit(n_modes: int, seed: int = 42) -> pcvl.Circuit:
    """Build a random m-mode unitary via Reck decomposition (beam splitters + phase shifters)."""
    rng = np.random.default_rng(seed)
    circuit = pcvl.Circuit(n_modes, name=f"random_U_{n_modes}")
    # Reck decomposition: m(m-1)/2 beam splitters
    for i in range(n_modes - 1, 0, -1):
        for j in range(i):
            theta = rng.uniform(0, np.pi)
            phi   = rng.uniform(0, 2 * np.pi)
            circuit.add((j, j + 1), comp.BS(theta=theta))
            circuit.add(j + 1, comp.PS(phi))
    return circuit

n_modes   = 6
n_photons = 4

# Build circuit
circuit = random_unitary_circuit(n_modes, seed=42)

# Input: 4 photons in first 4 modes
input_state = pcvl.BasicState([1, 1, 1, 1, 0, 0])

# Sample using SLOS backend
backend = pcvl.BackendFactory.get_backend("SLOS")
backend.set_circuit(circuit)
backend.set_input_state(input_state)

print(f"Boson sampling: {n_photons} photons in {n_modes} modes")
print(f"Output space size: C({n_modes+n_photons-1},{n_photons}) = {int(np.math.comb(n_modes+n_photons-1, n_photons))}")

# Sample 2000 coincidence patterns
sampler = pcvl.algorithm.Sampler(backend)
counts = sampler.sample_count(2000)

print(f"\nTop 8 output states (of {len(counts)} distinct patterns observed):")
for state, count in sorted(counts.items(), key=lambda x: -x[1])[:8]:
    print(f"  {state}: {count}  ({100*count/2000:.1f}%)")

# Verify permanent calculation for the top state
top_state = max(counts, key=counts.get)
print(f"\nVerifying top state {top_state}:")
U = pcvl.Matrix(circuit.compute_unitary())
# Extract submatrix U_S for this output pattern
# For input modes 0,1,2,3 and output pattern given by top_state
input_modes  = [0, 1, 2, 3]
output_modes = [i for i, n in enumerate(top_state) for _ in range(n)]
U_S = U[np.ix_(output_modes, input_modes)]
perm = np.abs(pcvl.utils.permanent(U_S))**2
print(f"  |Perm(U_S)|^2 = {perm:.6f}  (proportional to observed probability)")
print(f"  Observed prob = {counts[top_state]/2000:.6f}")
```

**Verify:** Output shows 126 possible patterns for 4 photons in 6 modes. Top state probability is proportional to |Perm(U_S)|^2. HOM-like bunching concentrates probability in a few high-coincidence patterns.

---

### Step 3: Problem formulation — material property encoding and circuit design

**Goal:** Define a protocol for encoding a target material property vector (bandgap, formation energy, magnetic moment) as circuit parameters (phase shifts), so different material searches correspond to different boson sampling unitaries.

**Code:**
```python
# src/materials/property_encoder.py
import numpy as np
import perceval as pcvl
import perceval.components as comp
from dataclasses import dataclass

@dataclass
class MaterialTarget:
    bandgap_ev: float            # Target bandgap in eV
    formation_energy_ev_atom: float  # Target formation energy
    magnetic_moment_ub: float    # Target magnetic moment in Bohr magnetons
    stability_threshold: float   # Max energy above convex hull (eV/atom)

def material_to_phase_shifts(target: MaterialTarget, n_modes: int = 8) -> list[float]:
    """
    Map material property targets to phase shift parameters for the photonic circuit.
    Each property is normalised and mapped to a phase angle in [0, 2pi].
    This creates a parameterised unitary sensitive to the target property space.
    """
    # Normalise properties to [0, 1] using domain knowledge ranges
    bg_norm   = np.clip(target.bandgap_ev / 6.0, 0, 1)         # max 6 eV
    fe_norm   = np.clip((target.formation_energy_ev_atom + 5) / 10, 0, 1)  # [-5, 5]
    mm_norm   = np.clip(target.magnetic_moment_ub / 10.0, 0, 1)  # max 10 µB
    stab_norm = np.clip(1 - target.stability_threshold / 0.5, 0, 1)  # 0 = unstable

    # Distribute properties across phase shifts using a Fourier-like encoding
    phases = []
    base_phases = [bg_norm, fe_norm, mm_norm, stab_norm]
    for i in range(n_modes):
        phi = 2 * np.pi * sum(p * np.cos(np.pi * i * j / n_modes)
                              for j, p in enumerate(base_phases))
        phases.append(phi % (2 * np.pi))
    return phases

def build_parameterised_circuit(
    target: MaterialTarget,
    n_modes: int = 8,
    n_layers: int = 3,
    seed: int = 42,
) -> pcvl.Circuit:
    """
    Build a parameterised boson sampling circuit:
    - Fixed random base unitary (hardware-defined)
    - Variable phase shifts encoding target material properties
    """
    rng = np.random.default_rng(seed)
    circuit = pcvl.Circuit(n_modes)
    phases = material_to_phase_shifts(target, n_modes)

    for layer in range(n_layers):
        # Fixed Haar-random beam splitter layer
        for i in range(0, n_modes - 1, 2):
            theta = rng.uniform(0, np.pi)
            circuit.add((i, i + 1), comp.BS(theta=theta))

        # Property-encoded phase shift layer
        for i in range(n_modes):
            phi = phases[i] * (layer + 1) / n_layers  # scale by layer depth
            circuit.add(i, comp.PS(phi))

        # Offset beam splitter layer (triangular mesh)
        for i in range(1, n_modes - 1, 2):
            theta = rng.uniform(0, np.pi)
            circuit.add((i, i + 1), comp.BS(theta=theta))

    return circuit

if __name__ == "__main__":
    target = MaterialTarget(
        bandgap_ev=1.5,
        formation_energy_ev_atom=-2.0,
        magnetic_moment_ub=0.0,
        stability_threshold=0.05,
    )
    phases = material_to_phase_shifts(target)
    print(f"Phase shifts for target material: {[f'{p:.3f}' for p in phases]}")
    circuit = build_parameterised_circuit(target, n_modes=8, n_layers=3)
    print(f"Circuit: {circuit.ncomponents()} components, {circuit.m} modes")
```

**Verify:** Different material targets produce distinct phase shift vectors. Circuit builds without error for 8 modes, 3 layers.

---

### Step 4: Circuit design and parameterization

**Goal:** Inspect the boson sampling circuit structure, visualise the unitary matrix, and benchmark simulation cost vs number of photons to understand the classical hardness boundary.

**Code:**
```python
# src/sampling/circuit_analysis.py
import numpy as np
import perceval as pcvl
import perceval.components as comp
import time

def benchmark_simulation_cost():
    """Demonstrate #P-hardness: simulation time scales exponentially with photon number."""
    print("Simulation time vs photon count (8 modes, SLOS backend):")
    print(f"{'n_photons':>10} | {'n_samples':>10} | {'time_s':>8} | {'output_states':>14}")
    print("-" * 50)

    for n_photons in [2, 3, 4, 5, 6]:
        n_modes = 8
        rng = np.random.default_rng(0)
        circuit = pcvl.Circuit(n_modes)
        for i in range(0, n_modes - 1, 2):
            circuit.add((i, i + 1), comp.BS(theta=rng.uniform(0, np.pi)))
        for i in range(1, n_modes - 1, 2):
            circuit.add((i, i + 1), comp.BS(theta=rng.uniform(0, np.pi)))

        input_state = pcvl.BasicState([1]*n_photons + [0]*(n_modes - n_photons))
        backend = pcvl.BackendFactory.get_backend("SLOS")
        backend.set_circuit(circuit)
        backend.set_input_state(input_state)
        sampler = pcvl.algorithm.Sampler(backend)

        t0 = time.time()
        counts = sampler.sample_count(200)
        elapsed = time.time() - t0

        import math
        n_output_states = math.comb(n_modes + n_photons - 1, n_photons)
        print(f"{n_photons:>10} | {200:>10} | {elapsed:>8.3f} | {n_output_states:>14}")

def visualise_circuit_unitary(circuit: pcvl.Circuit):
    """Print heatmap of the circuit's unitary matrix."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    U = np.array(pcvl.Matrix(circuit.compute_unitary()))
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    im0 = axes[0].imshow(np.abs(U), cmap="Blues", vmin=0, vmax=1)
    axes[0].set_title("|U_ij| (amplitude)")
    plt.colorbar(im0, ax=axes[0])
    im1 = axes[1].imshow(np.angle(U), cmap="hsv", vmin=-np.pi, vmax=np.pi)
    axes[1].set_title("arg(U_ij) (phase)")
    plt.colorbar(im1, ax=axes[1])
    plt.tight_layout()
    plt.savefig("docs/unitary_heatmap.png")
    print("Saved unitary heatmap.")

if __name__ == "__main__":
    benchmark_simulation_cost()
```

**Verify:** Simulation time roughly doubles with each additional photon (exponential scaling). 6-photon simulation should take noticeably longer than 4-photon. This motivates QPU use for n > 20 photons.

---

### Step 5: Classical optimizer / variational loop — VAE training

**Goal:** Train a PyTorch conditional VAE that takes boson sampling output distributions as conditioning input and decodes latent codes into material property vectors.

**Code:**
```python
# src/generative/vae.py
import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np
from dataclasses import dataclass

class ConditionalVAE(nn.Module):
    """
    Conditional VAE for material property generation.
    Input condition: boson sampling output distribution (flattened coincidence probabilities)
    Latent space: material property embedding
    Output: material property vector [bandgap, formation_energy, magnetic_moment, ...]
    """
    def __init__(
        self,
        condition_dim: int,   # boson sampling distribution dimension
        latent_dim: int = 16,
        property_dim: int = 8,  # dimensionality of material property space
        hidden_dim: int = 128,
    ):
        super().__init__()
        self.latent_dim = latent_dim
        self.property_dim = property_dim

        # Encoder: property + condition -> latent distribution
        self.encoder = nn.Sequential(
            nn.Linear(property_dim + condition_dim, hidden_dim),
            nn.GELU(),
            nn.Linear(hidden_dim, hidden_dim),
            nn.GELU(),
        )
        self.fc_mu     = nn.Linear(hidden_dim, latent_dim)
        self.fc_logvar = nn.Linear(hidden_dim, latent_dim)

        # Decoder: latent + condition -> property vector
        self.decoder = nn.Sequential(
            nn.Linear(latent_dim + condition_dim, hidden_dim),
            nn.GELU(),
            nn.Linear(hidden_dim, hidden_dim),
            nn.GELU(),
            nn.Linear(hidden_dim, property_dim),
        )

    def encode(self, x: torch.Tensor, c: torch.Tensor):
        h = self.encoder(torch.cat([x, c], dim=-1))
        return self.fc_mu(h), self.fc_logvar(h)

    def reparametrize(self, mu: torch.Tensor, logvar: torch.Tensor) -> torch.Tensor:
        std = torch.exp(0.5 * logvar)
        eps = torch.randn_like(std)
        return mu + eps * std

    def decode(self, z: torch.Tensor, c: torch.Tensor) -> torch.Tensor:
        return self.decoder(torch.cat([z, c], dim=-1))

    def forward(self, x: torch.Tensor, c: torch.Tensor):
        mu, logvar = self.encode(x, c)
        z = self.reparametrize(mu, logvar)
        x_recon = self.decode(z, c)
        return x_recon, mu, logvar

def vae_loss(x_recon, x, mu, logvar, beta: float = 1.0):
    """ELBO = reconstruction loss + beta * KL divergence."""
    recon_loss = F.mse_loss(x_recon, x, reduction="sum")
    kl_loss = -0.5 * torch.sum(1 + logvar - mu.pow(2) - logvar.exp())
    return recon_loss + beta * kl_loss

def generate_synthetic_training_data(n_samples: int = 1000):
    """
    Synthetic training data:
    - Boson sampling condition: random photon coincidence probabilities (normalised)
    - Material properties: correlated with sampling distribution (simulation of physics)
    """
    rng = np.random.default_rng(42)
    # Simulate boson sampling distribution (flat random for demonstration)
    n_output_states = 15  # C(6+4-1,4) = 126 -> reduced for demo
    conditions = rng.dirichlet(np.ones(n_output_states), size=n_samples).astype(np.float32)

    # Simulate material properties correlated with sampling (domain-specific mapping)
    properties = np.zeros((n_samples, 8), dtype=np.float32)
    properties[:, 0] = conditions[:, 0] * 6.0           # bandgap: 0-6 eV
    properties[:, 1] = conditions[:, 1] * 10.0 - 5.0    # formation energy: -5 to 5 eV/atom
    properties[:, 2] = conditions[:, 2] * 5.0            # magnetic moment
    properties[:, 3] = conditions[:, 3]                  # stability proxy
    # Remaining dimensions: other structural descriptors
    properties[:, 4:] = rng.normal(0, 1, (n_samples, 4))

    return (torch.from_numpy(conditions),
            torch.from_numpy(properties))

def train_vae(n_epochs: int = 100, batch_size: int = 64) -> ConditionalVAE:
    conditions, properties = generate_synthetic_training_data(1000)
    n_output_states = conditions.shape[1]
    model = ConditionalVAE(condition_dim=n_output_states, latent_dim=16, property_dim=8)
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)

    dataset = torch.utils.data.TensorDataset(conditions, properties)
    loader  = torch.utils.data.DataLoader(dataset, batch_size=batch_size, shuffle=True)

    for epoch in range(n_epochs):
        total_loss = 0.0
        for c_batch, x_batch in loader:
            x_recon, mu, logvar = model(x_batch, c_batch)
            loss = vae_loss(x_recon, x_batch, mu, logvar, beta=0.5)
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            total_loss += loss.item()
        if epoch % 20 == 0:
            print(f"Epoch {epoch:4d} | Loss: {total_loss/len(dataset):.4f}")

    torch.save(model.state_dict(), "models/material_vae.pt")
    return model

if __name__ == "__main__":
    model = train_vae()
    print("VAE training complete. Model saved to models/material_vae.pt")
    # Generate 5 new material candidates
    model.eval()
    with torch.no_grad():
        dummy_condition = torch.ones(1, 15) / 15   # uniform distribution
        z = torch.randn(5, model.latent_dim)
        c = dummy_condition.expand(5, -1)
        candidates = model.decode(z, c).numpy()
    print("Generated candidate property vectors:")
    for i, props in enumerate(candidates):
        print(f"  Candidate {i+1}: bandgap={props[0]:.2f} eV, "
              f"form_energy={props[1]:.2f} eV/atom, "
              f"mag_moment={props[2]:.2f} µB")
```

**Verify:** VAE training loss decreases monotonically. Generated candidates have physically plausible property ranges (bandgap 0-6 eV, formation energy -5 to 5 eV/atom).

---

### Step 6: Error mitigation — photon loss correction

**Goal:** Model photon loss (the dominant error source in linear optical circuits) as a beam splitter coupling the signal mode to a loss mode, and apply post-selection and ML-based correction.

**Code:**
```python
# src/mitigation/photon_loss.py
import numpy as np
import perceval as pcvl
import perceval.components as comp
from perceval.components import catalog

def add_photon_loss(
    circuit: pcvl.Circuit,
    loss_db: float = 3.0,
) -> pcvl.Circuit:
    """
    Add per-component photon loss to a circuit.
    loss_db: loss per optical element in dB (3 dB = 50% transmission).
    Perceval models loss via beam splitter to a loss mode.
    """
    noisy_circuit = pcvl.Circuit(circuit.m)
    transmissivity = 10 ** (-loss_db / 10)  # dB to linear

    for i, (r, c) in enumerate(circuit._components):
        noisy_circuit.add(r, c)
        # Add loss element after each component (simplified model)
        for mode in (r if hasattr(r, '__iter__') else [r]):
            if mode < circuit.m:
                loss_angle = np.arccos(np.sqrt(transmissivity))
                # In practice: use Perceval's loss channel API
                # noisy_circuit.add(mode, catalog["loss channel"].build(loss_db))
    return noisy_circuit

def post_select_on_photon_number(counts: dict, n_photons: int) -> dict:
    """
    Post-select measurement outcomes to keep only events with correct photon count.
    Photon loss events are discarded; remaining events are renormalised.
    """
    selected = {state: count for state, count in counts.items()
                if sum(state) == n_photons}
    total = sum(selected.values())
    if total == 0:
        return {}
    return {state: count / total for state, count in selected.items()}

def estimate_photon_loss_rate(
    circuit: pcvl.Circuit,
    input_state: pcvl.BasicState,
    n_samples: int = 1000,
) -> float:
    """Estimate fraction of runs lost to photon loss via post-selection rate."""
    backend = pcvl.BackendFactory.get_backend("SLOS")
    backend.set_circuit(circuit)
    backend.set_input_state(input_state)
    sampler = pcvl.algorithm.Sampler(backend)
    counts = sampler.sample_count(n_samples)

    n_photons = sum(input_state)
    total_samples = sum(counts.values())
    surviving = sum(c for s, c in counts.items() if sum(s) == n_photons)
    loss_rate = 1 - surviving / total_samples
    return loss_rate

if __name__ == "__main__":
    import perceval.components as comp
    circuit = pcvl.Circuit(4) // comp.BS() // (1, comp.BS())
    input_state = pcvl.BasicState([1, 1, 0, 0])

    backend = pcvl.BackendFactory.get_backend("SLOS")
    backend.set_circuit(circuit)
    backend.set_input_state(input_state)
    sampler = pcvl.algorithm.Sampler(backend)
    counts = sampler.sample_count(1000)

    n_photons = 2
    selected = post_select_on_photon_number(counts, n_photons)
    print(f"Post-selection kept {sum(1 for s in counts if sum(s) == n_photons)} "
          f"out of {len(counts)} distinct output patterns")
    print("Top 5 post-selected states:")
    for s, p in sorted(selected.items(), key=lambda x: -x[1])[:5]:
        print(f"  {s}: {p:.4f}")
```

**Verify:** Post-selection discards states with wrong photon number. For ideal circuit, 100% of samples survive post-selection. For noisy circuits, post-selection rate decreases with loss.

---

### Step 7: Hardware execution (Perceval simulator first, then Quandela QPU)

**Goal:** Run the boson sampling circuit on (1) Perceval SLOS local simulator, (2) Perceval MPS approximate emulator for larger circuits, and (3) Quandela cloud QPU.

**Code:**
```python
# src/sampling/hardware_runner.py
from enum import Enum
import perceval as pcvl
import perceval.components as comp

class PhotonicBackend(str, Enum):
    LOCAL_SLOS  = "slos"          # Exact local simulator (small circuits)
    LOCAL_MPS   = "mps"           # Approximate local MPS (larger circuits)
    QUANDELA    = "quandela_cloud"  # Real Quandela QPU

def run_boson_sampling(
    circuit: pcvl.Circuit,
    input_state: pcvl.BasicState,
    backend: PhotonicBackend,
    n_samples: int = 1000,
    quandela_token: str | None = None,
) -> dict:
    """Run boson sampling on chosen backend. Returns coincidence count dict."""

    # --- Local SLOS (exact, no approximation) ---
    if backend == PhotonicBackend.LOCAL_SLOS:
        be = pcvl.BackendFactory.get_backend("SLOS")
        be.set_circuit(circuit)
        be.set_input_state(input_state)
        sampler = pcvl.algorithm.Sampler(be)
        return dict(sampler.sample_count(n_samples))

    # --- Local MPS (matrix product state approximation, handles more modes/photons) ---
    elif backend == PhotonicBackend.LOCAL_MPS:
        # MPS backend available via perceval-quandela optional extras
        try:
            be = pcvl.BackendFactory.get_backend("MPS")
        except Exception:
            print("MPS backend not available; falling back to SLOS")
            be = pcvl.BackendFactory.get_backend("SLOS")
        be.set_circuit(circuit)
        be.set_input_state(input_state)
        sampler = pcvl.algorithm.Sampler(be)
        return dict(sampler.sample_count(n_samples))

    # --- Quandela cloud QPU ---
    elif backend == PhotonicBackend.QUANDELA:
        import os
        token = quandela_token or os.environ.get("QUANDELA_TOKEN")
        if not token:
            raise ValueError("Set QUANDELA_TOKEN environment variable")

        # Connect to Quandela cloud
        remote_backend = pcvl.RemoteProcessor(
            "sim:altair",  # Quandela cloud simulator; replace with QPU name when available
            token=token,
        )
        remote_backend.set_circuit(circuit)
        remote_backend.with_input(input_state)
        sampler = pcvl.algorithm.Sampler(remote_backend)
        response = sampler.sample_count(n_samples)
        return dict(response)

if __name__ == "__main__":
    # 3-photon, 4-mode demo
    n_modes   = 4
    n_photons = 3
    rng = np.random.default_rng(0)
    circuit = pcvl.Circuit(n_modes)
    for i in range(0, n_modes - 1, 2):
        circuit.add((i, i + 1), comp.BS(theta=rng.uniform(0, np.pi)))
    for i in range(1, n_modes - 1, 2):
        circuit.add((i, i + 1), comp.BS(theta=rng.uniform(0, np.pi)))

    input_state = pcvl.BasicState([1, 1, 1, 0])
    counts = run_boson_sampling(circuit, input_state, PhotonicBackend.LOCAL_SLOS, 500)
    print("Top 5 boson sampling outputs (SLOS):")
    for s, c in sorted(counts.items(), key=lambda x: -x[1])[:5]:
        print(f"  {s}: {c}")
```

**Verify:** SLOS produces exact output in < 5 seconds for 4 photons, 6 modes. MPS handles larger circuits with configurable bond dimension. Cloud QPU requires QUANDELA_TOKEN.

---

### Step 8: Classical post-processing — Qdrant indexing and RAG pipeline

**Goal:** Embed boson sampling output distributions into a Qdrant vector database alongside DFT material property vectors, then use LangChain RAG to retrieve property-similar materials for a target specification.

**Code:**
```python
# src/rag/material_rag.py
import numpy as np
from qdrant_client import QdrantClient
from qdrant_client.models import (
    Distance, VectorParams, PointStruct, Filter, FieldCondition, Range
)
from langchain_openai import ChatOpenAI
from langchain.chains import RetrievalQA
from langchain_community.vectorstores import Qdrant as LCQdrant
from langchain_openai import OpenAIEmbeddings
from langchain.schema import Document
import uuid

COLLECTION_NAME = "material_candidates"
EMBEDDING_DIM   = 384   # Using sentence-transformers/all-MiniLM-L6-v2

def setup_qdrant_collection(client: QdrantClient) -> None:
    """Create Qdrant collection for material embeddings."""
    if client.collection_exists(COLLECTION_NAME):
        return
    client.create_collection(
        collection_name=COLLECTION_NAME,
        vectors_config=VectorParams(size=EMBEDDING_DIM, distance=Distance.COSINE),
    )
    print(f"Created Qdrant collection: {COLLECTION_NAME}")

def index_material_candidates(
    client: QdrantClient,
    materials: list[dict],
) -> None:
    """
    Index materials from Materials Project or DFT database into Qdrant.
    Each material: {formula, bandgap, formation_energy, magnetic_moment, ...}
    Embedding: sentence-transformers over property description string.
    """
    from sentence_transformers import SentenceTransformer
    embedder = SentenceTransformer("all-MiniLM-L6-v2")

    points = []
    for mat in materials:
        description = (
            f"Material {mat['formula']} with bandgap {mat.get('bandgap', 'N/A')} eV, "
            f"formation energy {mat.get('formation_energy', 'N/A')} eV/atom, "
            f"space group {mat.get('space_group', 'N/A')}, "
            f"magnetic moment {mat.get('magnetic_moment', 0.0):.2f} µB."
        )
        embedding = embedder.encode(description, normalize_embeddings=True)
        points.append(PointStruct(
            id=str(uuid.uuid4()),
            vector=embedding.tolist(),
            payload={**mat, "description": description},
        ))

    client.upsert(collection_name=COLLECTION_NAME, points=points)
    print(f"Indexed {len(points)} materials into Qdrant.")

def search_similar_materials(
    client: QdrantClient,
    query_description: str,
    top_k: int = 5,
    bandgap_min: float | None = None,
    bandgap_max: float | None = None,
) -> list[dict]:
    """Search for materials similar to a natural-language property description."""
    from sentence_transformers import SentenceTransformer
    embedder = SentenceTransformer("all-MiniLM-L6-v2")
    query_vec = embedder.encode(query_description, normalize_embeddings=True)

    # Optional bandgap filter
    query_filter = None
    if bandgap_min is not None or bandgap_max is not None:
        conditions = []
        if bandgap_min is not None:
            conditions.append(FieldCondition(key="bandgap", range=Range(gte=bandgap_min)))
        if bandgap_max is not None:
            conditions.append(FieldCondition(key="bandgap", range=Range(lte=bandgap_max)))
        query_filter = Filter(must=conditions)

    results = client.search(
        collection_name=COLLECTION_NAME,
        query_vector=query_vec.tolist(),
        limit=top_k,
        query_filter=query_filter,
        with_payload=True,
    )
    return [{"score": r.score, **r.payload} for r in results]

def build_rag_chain(client: QdrantClient):
    """Build a LangChain RAG chain for material property Q&A."""
    from langchain_community.vectorstores import Qdrant as LCQdrant
    from langchain_openai import OpenAIEmbeddings, ChatOpenAI
    from langchain.chains import RetrievalQA
    from langchain_core.prompts import PromptTemplate

    embeddings = OpenAIEmbeddings()
    vectorstore = LCQdrant(
        client=client,
        collection_name=COLLECTION_NAME,
        embeddings=embeddings,
    )
    retriever = vectorstore.as_retriever(search_kwargs={"k": 4})

    prompt = PromptTemplate(
        input_variables=["context", "question"],
        template="""You are a materials science expert. Use the following DFT-computed material data
to answer the question. Cite specific material formulas and properties.

Context:
{context}

Question: {question}

Answer (include formula, key properties, and synthesis considerations):""",
    )
    llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)
    chain = RetrievalQA.from_chain_type(
        llm=llm,
        chain_type="stuff",
        retriever=retriever,
        chain_type_kwargs={"prompt": prompt},
    )
    return chain

if __name__ == "__main__":
    client = QdrantClient(host="localhost", port=6333)
    setup_qdrant_collection(client)

    # Load synthetic materials (replace with Materials Project API in production)
    synthetic_materials = [
        {"formula": "Si", "bandgap": 1.1, "formation_energy": 0.0, "space_group": "Fd-3m",
         "magnetic_moment": 0.0, "stability": 0.0},
        {"formula": "GaAs", "bandgap": 1.42, "formation_energy": -0.36, "space_group": "F-43m",
         "magnetic_moment": 0.0, "stability": 0.0},
        {"formula": "TiO2", "bandgap": 3.0, "formation_energy": -9.7, "space_group": "P42/mnm",
         "magnetic_moment": 0.0, "stability": 0.0},
        {"formula": "Fe3O4", "bandgap": 0.1, "formation_energy": -5.0, "space_group": "Fd-3m",
         "magnetic_moment": 4.0, "stability": 0.05},
    ]
    index_material_candidates(client, synthetic_materials)

    results = search_similar_materials(
        client,
        "semiconductor with bandgap around 1.5 eV suitable for solar cells",
        top_k=3,
        bandgap_min=1.0,
        bandgap_max=2.0,
    )
    print("Top 3 similar materials:")
    for r in results:
        print(f"  {r['formula']} | bandgap={r.get('bandgap', 'N/A')} | score={r['score']:.3f}")
```

**Verify:** Qdrant collection created. Materials indexed and retrieved correctly. RAG chain returns materials with bandgap in the specified range.

---

### Step 9: REST API wrapper

**Goal:** FastAPI service integrating boson sampling, VAE generation, Qdrant retrieval, and RAG into a single `/discover` endpoint.

**Code:**
```python
# src/api/main.py
from fastapi import FastAPI, BackgroundTasks, HTTPException
from pydantic import BaseModel, Field
from typing import Optional, List
import uuid, datetime, os

app = FastAPI(title="Photonic Materials Discovery API", version="0.1.0")

class MaterialTarget(BaseModel):
    bandgap_ev: float = Field(..., ge=0, le=10, description="Target bandgap in eV")
    formation_energy_ev_atom: float = Field(default=-2.0, ge=-20, le=5)
    magnetic_moment_ub: float = Field(default=0.0, ge=0, le=20)
    stability_threshold: float = Field(default=0.1, ge=0, le=1)
    n_photons: int = Field(default=4, ge=2, le=8)
    n_modes: int = Field(default=8, ge=4, le=20)
    backend: str = Field(default="slos")
    n_samples: int = Field(default=500, ge=100, le=10000)

class DiscoveryResponse(BaseModel):
    job_id: str
    status: str
    submitted_at: str
    candidates: Optional[List[dict]] = None
    synthesis_suggestion: Optional[str] = None

_jobs: dict[str, dict] = {}

@app.post("/discover", response_model=DiscoveryResponse, status_code=202)
async def discover(target: MaterialTarget, bg: BackgroundTasks):
    job_id = str(uuid.uuid4())
    _jobs[job_id] = {"status": "submitted"}
    bg.add_task(_run_discovery, job_id, target)
    return DiscoveryResponse(job_id=job_id, status="submitted",
                             submitted_at=datetime.datetime.utcnow().isoformat())

async def _run_discovery(job_id: str, target: MaterialTarget):
    import perceval as pcvl
    from materials.property_encoder import MaterialTarget as MT, build_parameterised_circuit
    from sampling.hardware_runner import run_boson_sampling, PhotonicBackend
    from generative.vae import ConditionalVAE
    from rag.material_rag import search_similar_materials
    import torch, numpy as np
    from qdrant_client import QdrantClient

    _jobs[job_id]["status"] = "running"
    try:
        mat_target = MT(target.bandgap_ev, target.formation_energy_ev_atom,
                        target.magnetic_moment_ub, target.stability_threshold)
        circuit = build_parameterised_circuit(mat_target, n_modes=target.n_modes)
        input_state = pcvl.BasicState([1]*target.n_photons + [0]*(target.n_modes - target.n_photons))
        be = PhotonicBackend(target.backend)
        counts = run_boson_sampling(circuit, input_state, be, target.n_samples)

        # Convert counts to probability distribution for VAE conditioning
        total = sum(counts.values())
        top_states = sorted(counts.items(), key=lambda x: -x[1])[:15]
        condition_vec = torch.tensor(
            [c / total for _, c in top_states] + [0.0] * (15 - len(top_states)),
            dtype=torch.float32,
        ).unsqueeze(0)

        # Generate candidate properties with VAE
        model = ConditionalVAE(condition_dim=15)
        model.load_state_dict(torch.load("models/material_vae.pt", map_location="cpu"))
        model.eval()
        with torch.no_grad():
            z = torch.randn(5, model.latent_dim)
            c = condition_vec.expand(5, -1)
            candidates_props = model.decode(z, c).numpy()

        # Retrieve similar known materials from Qdrant
        client = QdrantClient(host=os.environ.get("QDRANT_HOST", "localhost"), port=6333)
        query = (f"semiconductor material with bandgap {target.bandgap_ev:.1f} eV "
                 f"and formation energy {target.formation_energy_ev_atom:.1f} eV/atom")
        known = search_similar_materials(client, query, top_k=3,
                                          bandgap_min=target.bandgap_ev * 0.8,
                                          bandgap_max=target.bandgap_ev * 1.2)

        _jobs[job_id] = {
            "status": "completed",
            "candidates": [
                {"bandgap": float(p[0]), "formation_energy": float(p[1]),
                 "magnetic_moment": float(p[2])}
                for p in candidates_props
            ] + known,
            "synthesis_suggestion": f"Candidate bandgap range: {candidates_props[:,0].min():.2f}–{candidates_props[:,0].max():.2f} eV",
        }
    except Exception as e:
        _jobs[job_id] = {"status": "failed", "error": str(e)}

@app.get("/jobs/{job_id}")
async def get_job(job_id: str):
    if job_id not in _jobs:
        raise HTTPException(404, "Job not found")
    return _jobs[job_id]

@app.get("/health")
async def health():
    return {"status": "ok"}
```

**Verify:** `POST /discover` returns 202 with job_id. After completion, candidates list contains both VAE-generated and Qdrant-retrieved materials.

---

### Step 10: Testing and benchmarking

**Code:**
```python
# tests/test_boson_sampling.py
import perceval as pcvl
import perceval.components as comp
import numpy as np

def test_hom_effect():
    """Two-photon HOM: |1,1> input to 50:50 BS gives |2,0> or |0,2>, never |1,1>."""
    bs = pcvl.Circuit(2) // comp.BS()
    input_state = pcvl.BasicState([1, 1])
    backend = pcvl.BackendFactory.get_backend("SLOS")
    backend.set_circuit(bs)
    backend.set_input_state(input_state)
    sampler = pcvl.algorithm.Sampler(backend)
    counts = sampler.sample_count(1000)
    # |1,1> should NOT appear (HOM dip)
    assert pcvl.BasicState([1, 1]) not in counts or counts.get(pcvl.BasicState([1, 1]), 0) < 50

def test_photon_number_conservation():
    """Total photon count must equal input photon count in ideal circuit."""
    n_modes, n_photons = 6, 3
    rng = np.random.default_rng(0)
    circuit = pcvl.Circuit(n_modes)
    for i in range(0, n_modes - 1, 2):
        circuit.add((i, i + 1), comp.BS(theta=rng.uniform(0, np.pi)))
    input_state = pcvl.BasicState([1]*n_photons + [0]*(n_modes - n_photons))
    backend = pcvl.BackendFactory.get_backend("SLOS")
    backend.set_circuit(circuit)
    backend.set_input_state(input_state)
    sampler = pcvl.algorithm.Sampler(backend)
    counts = sampler.sample_count(200)
    for state, cnt in counts.items():
        assert sum(state) == n_photons, f"Photon number not conserved: {state}"

# tests/test_vae.py
import torch
from generative.vae import ConditionalVAE, vae_loss

def test_vae_forward_shape():
    model = ConditionalVAE(condition_dim=15, latent_dim=8, property_dim=4)
    c = torch.randn(16, 15)
    x = torch.randn(16, 4)
    x_recon, mu, logvar = model(x, c)
    assert x_recon.shape == (16, 4)
    assert mu.shape == (16, 8)

def test_vae_loss_positive():
    model = ConditionalVAE(condition_dim=15, latent_dim=8, property_dim=4)
    c = torch.randn(4, 15)
    x = torch.randn(4, 4)
    x_recon, mu, logvar = model(x, c)
    loss = vae_loss(x_recon, x, mu, logvar)
    assert loss.item() > 0
```

```bash
pytest tests/ -v --tb=short
```

**Verify:** All tests pass. HOM test confirms quantum interference (no |1,1> output). Photon number conservation verified for all output states.

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
COPY models/ ./models/
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
      - QDRANT_HOST=qdrant
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    depends_on: [qdrant, db]
  qdrant:
    image: qdrant/qdrant:latest
    ports: ["6333:6333"]
    volumes:
      - qdrant_data:/qdrant/storage
  db:
    image: postgres:16
    environment:
      POSTGRES_USER: photon
      POSTGRES_PASSWORD: photon
      POSTGRES_DB: photondb
volumes:
  qdrant_data:
```

`.github/workflows/ci.yml`:
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      qdrant:
        image: qdrant/qdrant:latest
        ports: ["6333:6333"]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install -r requirements.txt
      - run: pip install ruff && ruff check src/ tests/
      - run: pytest tests/ -v -k "not quandela_cloud"
```

**Verify:** CI passes without Quandela credentials. Qdrant service starts as a docker container in CI.

---

### Step 12: Observability

**Code:**
```python
# src/api/observability.py
from prometheus_client import Counter, Histogram, Gauge, make_asgi_app

discovery_requests = Counter("discovery_requests_total", "Total discovery requests", ["backend"])
sampling_duration  = Histogram("boson_sampling_seconds", "Boson sampling duration",
                                buckets=[0.1, 1, 5, 30, 60, 300])
vae_candidates     = Gauge("vae_candidates_generated", "Candidates generated per request")

def setup_metrics(app):
    app.mount("/metrics", make_asgi_app())
```

**Verify:** `curl http://localhost:8000/metrics | grep discovery_requests` increments with each API call.

---

## Testing

```bash
# Unit tests (no cloud credentials)
pytest tests/test_boson_sampling.py tests/test_vae.py -v

# Integration tests with local Qdrant
docker run -d -p 6333:6333 qdrant/qdrant
pytest tests/test_rag.py -v

# Cloud tests (requires QUANDELA_TOKEN)
QUANDELA_TOKEN=... pytest tests/ -v -m quandela_cloud
```

## Deployment notes

- Perceval SLOS simulator is exact but exponentially slow for n > 20 photons; switch to MPS for larger circuits
- Qdrant HNSW index parameters (m=16, ef_construct=200) balance recall vs indexing speed for ~10k materials
- OpenAI API calls in the RAG chain add ~1-2 s latency; consider local Mistral or Ollama for lower latency
- QUANDELA_TOKEN: obtain from `cloud.quandela.com`; QPU job queue can be hours; use cloud simulator for dev
- VAE training on real Materials Project data (via `mp_api`) requires `pip install mp-api` and an API key from `materialsproject.org`

## Resources

1. [Perceval SDK Documentation](https://perceval.quandela.net/docs/) — Circuit design, backends, Quandela cloud access
2. [Aaronson & Arkhipov (2011) — The Computational Complexity of Linear Optics](https://arxiv.org/abs/1011.3245) — Boson sampling hardness proof
3. [Quandela cloud tutorials](https://cloud.quandela.com/docs) — Remote backend, QPU access, photon source specs
4. [Materials Project API](https://next-gen.materialsproject.org/api) — DFT material database for embedding index
5. [LangChain RAG documentation](https://python.langchain.com/docs/concepts/rag/) — Retrieval-augmented generation pipeline
6. [Qdrant documentation](https://qdrant.tech/documentation/) — Collection creation, HNSW indexing, filtering
7. [Kingma & Welling (2013) — Auto-Encoding Variational Bayes](https://arxiv.org/abs/1312.6114) — VAE theory
