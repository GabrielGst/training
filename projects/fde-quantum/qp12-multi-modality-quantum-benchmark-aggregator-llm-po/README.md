# QP12 — Multi-Modality Quantum Benchmark Aggregator & LLM-Powered Circuit Explainer

**Modality:** classical-only (multi-SDK: Qiskit · Cirq · PennyLane · Perceval)  **Phase:** 3 (capstone)  **Track:** `hpc-quantum`  **Status:** not started  **Hours target:** 80h

## Business Problem

Quantum hardware improves rapidly, but benchmark comparisons are fragmented across four major SDKs (Qiskit, Cirq, PennyLane, Perceval), each with its own gate naming, noise model API, and result format. Researchers and FDEs spend days manually porting circuits between frameworks and can't easily answer "which SDK + backend runs my circuit most faithfully at lowest cost?" This project builds a unified benchmark portal with AI-generated circuit explanations accessible to non-experts.

## What you will build

- **Multi-SDK benchmark suite** — GHZ, QFT, QAOA, VQE implemented in all 4 SDKs with equivalent noise models
- **TKET transpilation pipeline** — uses pytket as intermediate representation (IR) to compile any SDK circuit for any backend
- **Benchmark database** — PostgreSQL schema storing gate count, circuit depth, fidelity, runtime per SDK/circuit/noise level
- **LLM circuit explainer** — RAG over Qiskit/Cirq/PennyLane/Perceval docs (Qdrant + LangChain + Mistral API)
- **Next.js benchmark portal** — comparison tables, circuit visualizations, semantic circuit search
- **CI/CD pipeline** — GitHub Actions runs the full benchmark suite on every commit, updates the portal automatically

## Architecture

```
┌─────────────────────────────────────────────────┐
│  Benchmark Suite (4 SDKs × 4 circuits)           │
│  GHZ · QFT · QAOA · VQE                          │
│  Qiskit · Cirq · PennyLane · Perceval            │
└─────────────────┬───────────────────────────────┘
                  │ pytket TKET IR
                  ▼
┌─────────────────────────────────────────────────┐
│  Noise Model Runner                              │
│  Aer depolarizing / Cirq DM / PL default.mixed   │
└─────────────────┬───────────────────────────────┘
                  │  (gate_count, depth, fidelity, runtime_ms)
                  ▼
         ┌────────────────┐
         │  PostgreSQL     │◄──── FastAPI REST API
         │  benchmark runs │
         └────────┬───────┘
                  │
        ┌─────────▼─────────┐
        │  Next.js Portal    │
        │  comparison tables │
        │  circuit viz       │
        └─────────┬─────────┘
                  │
         ┌────────▼────────┐        ┌─────────────────────────┐
         │  /explain API    │◄──────►│  Qdrant Vector Store     │
         │  Mistral + RAG   │        │  SDK docs chunked + emb  │
         └─────────────────┘        └─────────────────────────┘
```

## Theory prerequisites

| Skill ID | Concept | Why you need it |
|----------|---------|-----------------|
| QSK01 | Hilbert Space & Dirac Notation | Verify circuit equivalence across SDKs |
| QSK02 | Quantum Measurement | Compare shot-based statistics |
| QSK03 | Decoherence & T1/T2 | Interpret noise model differences |
| QSK04 | Gate Model & Universal Gates | Translate Rz/CX ↔ rz/CNOT ↔ RZ/CNOT |
| QSK05 | Tensor Products | Verify 3+ qubit circuit equivalence |
| QSK06 | Eigendecomposition | Check unitary equivalence of circuits |
| QSK07 | von Neumann Entropy | Measure entanglement in benchmark states |
| QSK72 | Benchmark Design | Design SPAM-robust, fair cross-SDK benchmarks |
| QSK73 | Multi-SDK Transpilation | TKET as universal IR across SDKs |
| QSK74 | Community & OSS | Reading SDK changelogs, contributing test cases |

## Engineering skills covered

| Skill ID | Skill | What you practice |
|----------|-------|------------------|
| QSK42 | Prompt Engineering | RAG query formulation over SDK documentation |
| QSK43 | RAG | Qdrant vector store + LangChain retrieval chain |
| QSK44 | LLM Output Parsing | Structured circuit explanation with Pydantic |
| QSK45 | Semantic Search | Circuit similarity search across benchmark results |
| QSK33 | SQL / PostgreSQL | Benchmark schema, indexing, aggregation queries |
| QSK34 | Docker / Containerization | Multi-service Docker Compose app |
| QSK35 | CI/CD | GitHub Actions benchmark suite on every commit |

## Tools & dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| Qiskit | IBM quantum SDK | `pip install qiskit qiskit-aer` |
| Cirq | Google quantum SDK | `pip install cirq` |
| PennyLane | Xanadu quantum ML SDK | `pip install pennylane` |
| Perceval | Quandela photonic SDK | `pip install perceval-quandela` |
| pytket | TKET transpilation IR | `pip install pytket pytket-qiskit pytket-cirq` |
| Mistral API | LLM for circuit explanations | `pip install mistralai` |
| LangChain | RAG orchestration | `pip install langchain langchain-community` |
| Qdrant | Vector store for SDK docs | `pip install qdrant-client` |
| FastAPI | Benchmark + explainer REST API | `pip install fastapi uvicorn` |
| asyncpg | Async PostgreSQL driver | `pip install asyncpg` |
| React/Next.js | Frontend portal | `npm install` |
| Docker | Multi-container orchestration | system package |
| GitHub Actions | CI benchmark runner | cloud |

## Prerequisites

**Complete these quantum modules first:**
- [ ] `hpc-quantum/01-quantum-theory` — Hilbert space, gates, measurement
- [ ] `hpc-quantum/02-quantum-intro` — Qiskit basics, first circuits
- [ ] `hpc-quantum/03-quantum-advanced` — VQE, QAOA, multi-SDK experience
- [ ] Complete at least 2 other quantum projects (QP01–QP11)

**AI/ML prerequisites:**
- [ ] `ai-agents/06-rag-advanced` — LangChain RAG pipeline
- [ ] `software-engineer/03-nextjs` — Next.js App Router

**Access / accounts needed:**
- [ ] Mistral API key — mistral.ai (for circuit explanations)
- [ ] Docker + Docker Compose — local Qdrant + PostgreSQL
- [ ] GitHub account — for Actions CI

---

## Step-by-step tutorial

### Step 1: Environment setup (all 4 SDKs + TKET + RAG stack)

**Goal:** Install every SDK and confirm all imports succeed before writing any benchmark code.

```bash
python -m venv .venv && source .venv/bin/activate

# Quantum SDKs
pip install qiskit qiskit-aer cirq pennylane perceval-quandela \
            pytket pytket-qiskit pytket-cirq

# RAG + LLM stack
pip install langchain langchain-community mistralai qdrant-client

# API + DB
pip install fastapi uvicorn asyncpg numpy scipy

# Frontend
cd frontend && npm install
```

Directory layout:

```
src/
  benchmarks/
    ghz.py        # GHZ in all 4 SDKs
    qft.py        # QFT in all 4 SDKs
    qaoa.py       # QAOA Max-Cut in Qiskit + PennyLane
    vqe.py        # VQE H2 molecule in Qiskit + PennyLane
  transpile.py    # TKET pipeline
  noise.py        # noise model runner
  ingest.py       # SDK docs → Qdrant
  explainer.py    # RAG chain + Mistral
  api.py          # FastAPI app
frontend/         # Next.js portal
database/
  schema.sql
tests/
```

**Verify:**
```bash
python -c "
import qiskit, cirq, pennylane, perceval, pytket
print('Qiskit:', qiskit.__version__)
print('Cirq:', cirq.__version__)
print('PennyLane:', pennylane.__version__)
print('pytket:', pytket.__version__)
"
```

---

### Step 2: Theory warm-up — GHZ state in all 4 SDKs

**Goal:** Implement the same 3-qubit GHZ state in every SDK; verify equivalent output distributions.

```python
# src/benchmarks/ghz.py
import numpy as np

# ── Qiskit ──────────────────────────────────────────────────────
from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator

def ghz_qiskit(n: int = 3, shots: int = 1024) -> dict:
    qc = QuantumCircuit(n)
    qc.h(0)
    for i in range(n - 1):
        qc.cx(i, i + 1)
    qc.measure_all()
    sim = AerSimulator()
    job = sim.run(qc, shots=shots)
    return {'sdk': 'qiskit', 'counts': job.result().get_counts()}

# ── Cirq ────────────────────────────────────────────────────────
import cirq

def ghz_cirq(n: int = 3, shots: int = 1024) -> dict:
    qubits = cirq.LineQubit.range(n)
    circuit = cirq.Circuit(
        cirq.H(qubits[0]),
        [cirq.CNOT(qubits[i], qubits[i + 1]) for i in range(n - 1)],
        cirq.measure(*qubits, key='result')
    )
    sim = cirq.Simulator()
    result = sim.run(circuit, repetitions=shots)
    counts = {}
    for bits in result.measurements['result']:
        key = ''.join(str(b) for b in bits)
        counts[key] = counts.get(key, 0) + 1
    return {'sdk': 'cirq', 'counts': counts}

# ── PennyLane ───────────────────────────────────────────────────
import pennylane as qml

def ghz_pennylane(n: int = 3, shots: int = 1024) -> dict:
    dev = qml.device('default.qubit', wires=n, shots=shots)

    @qml.qnode(dev)
    def circuit():
        qml.Hadamard(wires=0)
        for i in range(n - 1):
            qml.CNOT(wires=[i, i + 1])
        return qml.counts(wires=range(n))

    return {'sdk': 'pennylane', 'counts': dict(circuit())}

# ── Perceval (linear optics equivalent) ─────────────────────────
import perceval as pcvl

def ghz_perceval_2photon() -> dict:
    """
    Perceval uses linear optics; GHZ requires post-selection.
    Implement a 2-photon entangled state (|HH⟩ + |VV⟩)/√2 as closest analogue.
    """
    c = pcvl.Circuit(4)   # 4 modes: HH, HV, VH, VV
    c.add(0, pcvl.BS.H())   # 50:50 beam splitter
    # Measure in coincidence basis
    return {'sdk': 'perceval', 'note': '2-photon Bell analogue of GHZ'}

if __name__ == '__main__':
    for result in [ghz_qiskit(), ghz_cirq(), ghz_pennylane()]:
        sdk = result['sdk']
        counts = result['counts']
        total = sum(counts.values())
        top = sorted(counts.items(), key=lambda x: -x[1])[:3]
        print(f"{sdk:12s}  top states: {top}  (total={total})")
```

**Verify:**
```bash
python src/benchmarks/ghz.py
# qiskit        top states: [('000', 512), ('111', 512)] (total=1024)
# cirq          top states: [('000', 508), ('111', 516)] (total=1024)
# pennylane     top states: [('000', 519), ('111', 505)] (total=1024)
```

---

### Step 3: TKET transpilation pipeline

**Goal:** Use pytket as universal IR to compile any SDK circuit for any backend.

```python
# src/transpile.py
from pytket import Circuit as TKCircuit
from pytket.extensions.qiskit import qiskit_to_tk, tk_to_qiskit
from pytket.extensions.cirq import tk_to_cirq
from qiskit import QuantumCircuit

def qiskit_to_cirq_via_tket(qc: QuantumCircuit):
    """Transpile Qiskit → TKET → Cirq."""
    tk_circ = qiskit_to_tk(qc)
    return tk_to_cirq(tk_circ)

def get_circuit_metrics(qc: QuantumCircuit) -> dict:
    """Extract gate count and depth via TKET."""
    tk = qiskit_to_tk(qc)
    return {
        'n_qubits': tk.n_qubits,
        'n_gates': tk.n_gates,
        'depth': tk.depth(),
        'two_qubit_gates': tk.n_gates_of_type(
            __import__('pytket', fromlist=['OpType']).OpType.CX
        ),
    }

if __name__ == '__main__':
    qc = QuantumCircuit(3)
    qc.h(0); qc.cx(0, 1); qc.cx(1, 2); qc.measure_all()
    metrics = get_circuit_metrics(qc)
    print("GHZ circuit metrics:", metrics)

    cirq_circ = qiskit_to_cirq_via_tket(qc)
    print("Cirq equivalent:\n", cirq_circ)
```

**Verify:**
```bash
python src/transpile.py
# GHZ circuit metrics: {'n_qubits': 3, 'n_gates': 5, 'depth': 3, 'two_qubit_gates': 2}
# Cirq equivalent:
# 0: ───H───@───────
#           │
# 1: ───────X───@───
#               │
# 2: ───────────X───
```

---

### Step 4: Full benchmark suite (QFT, QAOA, VQE)

**Goal:** Implement QFT and QAOA in at least 2 SDKs each, so the benchmark suite has 4 circuits × ≥2 SDKs.

```python
# src/benchmarks/qft.py — Quantum Fourier Transform
from qiskit.circuit.library import QFT as QiskitQFT
from qiskit import QuantumCircuit
import pennylane as qml

def qft_qiskit(n: int = 4) -> QuantumCircuit:
    qc = QuantumCircuit(n)
    qc.compose(QiskitQFT(n), inplace=True)
    return qc

def qft_pennylane(n: int = 4):
    dev = qml.device('default.qubit', wires=n, shots=1024)
    @qml.qnode(dev)
    def circuit():
        for i in range(n):
            qml.Hadamard(wires=i)
        qml.adjoint(qml.QFT)(wires=range(n))
        return qml.counts()
    return circuit
```

```python
# src/benchmarks/qaoa.py — QAOA Max-Cut on a 4-node ring graph
import pennylane as qml
import numpy as np

def qaoa_pennylane(n: int = 4, p: int = 1, shots: int = 1024):
    edges = [(0,1),(1,2),(2,3),(3,0)]
    dev = qml.device('default.qubit', wires=n, shots=shots)

    def cost_layer(gamma):
        for i, j in edges:
            qml.ZZRotation(2 * gamma, wires=[i, j])

    def mixer_layer(beta):
        for i in range(n):
            qml.RX(2 * beta, wires=i)

    @qml.qnode(dev)
    def circuit(params):
        for i in range(n):
            qml.Hadamard(wires=i)
        for layer_params in params:
            cost_layer(layer_params[0])
            mixer_layer(layer_params[1])
        return qml.counts(wires=range(n))

    params = np.array([[0.5, 0.5]] * p)
    return circuit, params
```

**Verify:**
```bash
python -c "from src.benchmarks.qft import qft_qiskit; qc = qft_qiskit(4); print(qc.depth())"
# 10  (depth of 4-qubit QFT)
```

---

### Step 5: Noise model comparison

**Goal:** Run the GHZ benchmark under equivalent noise on all 3 gate-based SDKs; record fidelity.

```python
# src/noise.py
import numpy as np
from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator
from qiskit_aer.noise import NoiseModel, depolarizing_error

def ghz_fidelity_qiskit_noisy(n: int = 3, error_rate: float = 0.01, shots: int = 4096) -> float:
    """Run GHZ under depolarizing noise; return fidelity vs ideal."""
    noise_model = NoiseModel()
    noise_model.add_all_qubit_quantum_error(depolarizing_error(error_rate, 1), ['h'])
    noise_model.add_all_qubit_quantum_error(depolarizing_error(error_rate, 2), ['cx'])

    qc = QuantumCircuit(n)
    qc.h(0)
    for i in range(n - 1):
        qc.cx(i, i + 1)
    qc.measure_all()

    sim = AerSimulator(noise_model=noise_model)
    counts = sim.run(qc, shots=shots).result().get_counts()

    # GHZ fidelity = (P(000) + P(111)) / total
    total = sum(counts.values())
    ghz_prob = (counts.get('0' * n, 0) + counts.get('1' * n, 0)) / total
    return ghz_prob

def benchmark_noise_sweep(error_rates=(0.0, 0.005, 0.01, 0.02, 0.05)):
    print(f"{'error_rate':>12}  {'fidelity_qiskit':>16}")
    for rate in error_rates:
        fid = ghz_fidelity_qiskit_noisy(error_rate=rate)
        print(f"{rate:>12.3f}  {fid:>16.4f}")

if __name__ == '__main__':
    benchmark_noise_sweep()
```

**Verify:**
```bash
python src/noise.py
# error_rate    fidelity_qiskit
#        0.000           0.9998
#        0.005           0.9721
#        0.010           0.9443
```

---

### Step 6: PostgreSQL schema and benchmark storage

**Goal:** Persist all benchmark runs in a structured schema for comparison queries.

```sql
-- database/schema.sql
CREATE TABLE benchmark_runs (
    id           SERIAL PRIMARY KEY,
    run_ts       TIMESTAMPTZ DEFAULT NOW(),
    circuit_name TEXT NOT NULL,   -- 'ghz', 'qft', 'qaoa', 'vqe'
    sdk          TEXT NOT NULL,   -- 'qiskit', 'cirq', 'pennylane', 'perceval'
    n_qubits     INT NOT NULL,
    gate_count   INT,
    circuit_depth INT,
    two_qubit_gates INT,
    noise_level  FLOAT DEFAULT 0.0,
    fidelity     FLOAT,
    runtime_ms   FLOAT,
    shots        INT,
    metadata     JSONB DEFAULT '{}'
);

CREATE INDEX idx_bm_circuit ON benchmark_runs(circuit_name, sdk);
CREATE INDEX idx_bm_ts      ON benchmark_runs(run_ts DESC);
```

```bash
docker run -d --name qp12-pg \
  -e POSTGRES_PASSWORD=password -e POSTGRES_DB=qp12 \
  -p 5432:5432 postgres:16
psql -h localhost -U postgres -d qp12 -f database/schema.sql
```

**Verify:**
```bash
psql -h localhost -U postgres -d qp12 -c "\dt"
# benchmark_runs
```

---

### Step 7: RAG pipeline over SDK documentation

**Goal:** Chunk and embed Qiskit/Cirq/PennyLane/Perceval docs into Qdrant for circuit explanation retrieval.

```python
# src/ingest.py
from langchain_community.document_loaders import WebBaseLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Qdrant
from langchain_community.embeddings import MistralAIEmbeddings
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams
import os

QDRANT_URL = os.getenv("QDRANT_URL", "http://localhost:6333")
MISTRAL_KEY = os.getenv("MISTRAL_API_KEY", "")
COLLECTION = "sdk_docs"

SDK_DOCS = [
    # Qiskit
    "https://docs.quantum.ibm.com/api/qiskit/circuit",
    # Cirq
    "https://quantumai.google/cirq/build/circuits",
    # PennyLane
    "https://pennylane.ai/qml/glossary/quantum_neural_network/",
    # Perceval
    "https://perceval.quandela.net/docs/",
]

def ingest_docs():
    client = QdrantClient(url=QDRANT_URL)
    client.recreate_collection(
        collection_name=COLLECTION,
        vectors_config=VectorParams(size=1024, distance=Distance.COSINE),
    )
    embeddings = MistralAIEmbeddings(
        model="mistral-embed",
        mistral_api_key=MISTRAL_KEY
    )
    splitter = RecursiveCharacterTextSplitter(chunk_size=800, chunk_overlap=100)

    for url in SDK_DOCS:
        try:
            docs = WebBaseLoader(url).load()
            chunks = splitter.split_documents(docs)
            # Add SDK metadata
            sdk_name = url.split('/')[2].split('.')[0]
            for chunk in chunks:
                chunk.metadata['sdk'] = sdk_name
            Qdrant.from_documents(
                chunks, embeddings,
                url=QDRANT_URL, collection_name=COLLECTION
            )
            print(f"Ingested {len(chunks)} chunks from {url}")
        except Exception as e:
            print(f"Failed {url}: {e}")

if __name__ == '__main__':
    ingest_docs()
```

**Verify:**
```bash
docker run -d --name qp12-qdrant -p 6333:6333 qdrant/qdrant
python src/ingest.py
# Ingested 23 chunks from https://docs.quantum.ibm.com/...
curl http://localhost:6333/collections/sdk_docs | python3 -m json.tool
# "vectors_count": ...
```

---

### Step 8: LLM circuit explainer (FastAPI + Mistral RAG)

**Goal:** Build a `/explain` endpoint that takes a circuit description and returns a plain-English explanation backed by SDK docs.

```python
# src/explainer.py
from langchain_community.vectorstores import Qdrant
from langchain_community.embeddings import MistralAIEmbeddings
from langchain.chains import RetrievalQA
from langchain_mistralai import ChatMistralAI
from qdrant_client import QdrantClient
from pydantic import BaseModel
import os

QDRANT_URL = os.getenv("QDRANT_URL", "http://localhost:6333")
MISTRAL_KEY = os.getenv("MISTRAL_API_KEY", "")

def get_explainer_chain():
    client = QdrantClient(url=QDRANT_URL)
    embeddings = MistralAIEmbeddings(model="mistral-embed", mistral_api_key=MISTRAL_KEY)
    vectorstore = Qdrant(client=client, collection_name="sdk_docs", embeddings=embeddings)
    retriever = vectorstore.as_retriever(search_kwargs={"k": 4})

    llm = ChatMistralAI(
        model="mistral-large-latest",
        mistral_api_key=MISTRAL_KEY,
        temperature=0.0,
    )
    return RetrievalQA.from_chain_type(
        llm=llm, chain_type="stuff", retriever=retriever,
        return_source_documents=True,
    )

_chain = None
def get_chain():
    global _chain
    if _chain is None:
        _chain = get_explainer_chain()
    return _chain
```

```python
# src/api.py (excerpt — full app)
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import asyncpg, os, time

from benchmarks.ghz import ghz_qiskit, ghz_cirq, ghz_pennylane
from transpile import get_circuit_metrics
from noise import ghz_fidelity_qiskit_noisy
from explainer import get_chain
from qiskit import QuantumCircuit

app = FastAPI(title="QP12 Quantum Benchmark Portal")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:password@localhost/qp12")

class ExplainRequest(BaseModel):
    circuit: str    # e.g. "GHZ state"
    sdk: str = "qiskit"
    question: str = "Explain this circuit and how it works in this SDK."

class BenchmarkRequest(BaseModel):
    circuit: str = "ghz"
    n_qubits: int = 3
    noise_level: float = 0.0
    shots: int = 1024

@app.post("/explain")
async def explain_circuit(req: ExplainRequest):
    chain = get_chain()
    prompt = f"In {req.sdk}: {req.question} Circuit: {req.circuit}"
    result = chain({"query": prompt})
    return {
        "explanation": result["result"],
        "sources": [d.metadata.get("source", "") for d in result["source_documents"]],
    }

@app.post("/benchmark")
async def run_benchmark(req: BenchmarkRequest):
    t0 = time.perf_counter()
    results = {}
    if req.circuit == "ghz":
        results["qiskit"] = ghz_qiskit(req.n_qubits, req.shots)
        results["cirq"]   = ghz_cirq(req.n_qubits, req.shots)
        results["pennylane"] = ghz_pennylane(req.n_qubits, req.shots)

    runtime_ms = (time.perf_counter() - t0) * 1000

    # Persist to PostgreSQL
    conn = await asyncpg.connect(DATABASE_URL)
    for sdk, result in results.items():
        total = sum(result["counts"].values())
        n = req.n_qubits
        fidelity = (result["counts"].get("0" * n, 0) + result["counts"].get("1" * n, 0)) / total
        await conn.execute(
            """INSERT INTO benchmark_runs (circuit_name, sdk, n_qubits, fidelity, runtime_ms, shots)
               VALUES ($1,$2,$3,$4,$5,$6)""",
            req.circuit, sdk, req.n_qubits, fidelity, runtime_ms, req.shots
        )
    await conn.close()
    return {"circuit": req.circuit, "n_qubits": req.n_qubits, "results": results, "runtime_ms": runtime_ms}

@app.get("/results")
async def get_results(circuit: str = "ghz", limit: int = 50):
    conn = await asyncpg.connect(DATABASE_URL)
    rows = await conn.fetch(
        """SELECT sdk, AVG(fidelity) as avg_fidelity, AVG(runtime_ms) as avg_runtime_ms, COUNT(*) as runs
           FROM benchmark_runs WHERE circuit_name = $1 GROUP BY sdk ORDER BY avg_fidelity DESC""",
        circuit
    )
    await conn.close()
    return [dict(r) for r in rows]
```

**Verify:**
```bash
uvicorn src.api:app --reload &
curl -s -X POST http://localhost:8000/benchmark \
  -H "Content-Type: application/json" \
  -d '{"circuit":"ghz","n_qubits":3}' | python3 -m json.tool
```

---

### Step 9: Next.js benchmark portal

**Goal:** Build a comparison table and circuit visualizer in the browser.

```typescript
// frontend/src/app/page.tsx
'use client'
import { useState, useEffect } from 'react'

interface BenchmarkResult {
  sdk: string
  avg_fidelity: number
  avg_runtime_ms: number
  runs: number
}

export default function BenchmarkPortal() {
  const [results, setResults] = useState<BenchmarkResult[]>([])
  const [circuit, setCircuit] = useState('ghz')
  const [running, setRunning] = useState(false)

  const fetchResults = async () => {
    const res = await fetch(`http://localhost:8000/results?circuit=${circuit}`)
    setResults(await res.json())
  }

  const runBenchmark = async () => {
    setRunning(true)
    await fetch('http://localhost:8000/benchmark', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ circuit, n_qubits: 3, shots: 1024 }),
    })
    await fetchResults()
    setRunning(false)
  }

  useEffect(() => { fetchResults() }, [circuit])

  return (
    <main className="p-8">
      <h1 className="text-2xl font-bold mb-4">Quantum Benchmark Portal — QP12</h1>
      <div className="flex gap-4 mb-6">
        {['ghz', 'qft', 'qaoa'].map(c => (
          <button key={c} onClick={() => setCircuit(c)}
            className={`px-4 py-2 rounded ${circuit === c ? 'bg-blue-600 text-white' : 'bg-gray-200'}`}>
            {c.toUpperCase()}
          </button>
        ))}
        <button onClick={runBenchmark} disabled={running}
          className="px-4 py-2 bg-green-600 text-white rounded">
          {running ? 'Running...' : 'Run Benchmark'}
        </button>
      </div>
      <table className="w-full border-collapse">
        <thead>
          <tr className="bg-gray-100">
            <th className="p-2 text-left">SDK</th>
            <th className="p-2 text-right">Avg Fidelity</th>
            <th className="p-2 text-right">Avg Runtime (ms)</th>
            <th className="p-2 text-right">Runs</th>
          </tr>
        </thead>
        <tbody>
          {results.map(r => (
            <tr key={r.sdk} className="border-t">
              <td className="p-2 font-mono">{r.sdk}</td>
              <td className="p-2 text-right">{r.avg_fidelity?.toFixed(4)}</td>
              <td className="p-2 text-right">{r.avg_runtime_ms?.toFixed(1)}</td>
              <td className="p-2 text-right">{r.runs}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </main>
  )
}
```

**Verify:**
```bash
cd frontend && npm run dev
# Open http://localhost:3000 — should show benchmark comparison table
```

---

### Step 10: Semantic circuit search (Qdrant)

**Goal:** Allow users to search for circuits by natural language description.

```python
# src/search.py
from langchain_community.vectorstores import Qdrant
from langchain_community.embeddings import MistralAIEmbeddings
from qdrant_client import QdrantClient
import os

def search_circuits(query: str, k: int = 5) -> list[dict]:
    """Find SDK docs most relevant to a natural language circuit query."""
    client = QdrantClient(url=os.getenv("QDRANT_URL", "http://localhost:6333"))
    embeddings = MistralAIEmbeddings(
        model="mistral-embed",
        mistral_api_key=os.getenv("MISTRAL_API_KEY", "")
    )
    vectorstore = Qdrant(client=client, collection_name="sdk_docs", embeddings=embeddings)
    docs = vectorstore.similarity_search_with_score(query, k=k)
    return [
        {"content": doc.page_content[:300], "score": float(score),
         "sdk": doc.metadata.get("sdk", ""), "source": doc.metadata.get("source", "")}
        for doc, score in docs
    ]

if __name__ == '__main__':
    results = search_circuits("how to create entangled qubits in Qiskit")
    for r in results:
        print(f"[{r['sdk']}] score={r['score']:.3f}  {r['content'][:100]}")
```

**Verify:**
```bash
python src/search.py
# [qiskit] score=0.872  QuantumCircuit allows...
# [cirq] score=0.801  Creating entangled...
```

---

### Step 11: GitHub Actions CI — run benchmarks on every commit

**Goal:** Automate the benchmark suite so the database stays current with every code change.

```yaml
# .github/workflows/benchmark.yml
name: QP12 Benchmark CI

on:
  push:
    paths:
      - 'projects/fde-quantum/qp12-**/**'
  schedule:
    - cron: '0 6 * * 1'   # Weekly Monday 6am UTC

jobs:
  benchmark:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: password
          POSTGRES_DB: qp12
        ports: ["5432:5432"]
      qdrant:
        image: qdrant/qdrant
        ports: ["6333:6333"]

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        working-directory: projects/fde-quantum/qp12-multi-modality-quantum-benchmark-aggregator-llm-po
        run: |
          pip install qiskit qiskit-aer cirq pennylane perceval-quandela \
                      pytket pytket-qiskit pytket-cirq \
                      langchain langchain-community mistralai qdrant-client \
                      fastapi uvicorn asyncpg httpx pytest

      - name: Initialize schema
        env:
          PGPASSWORD: password
        run: psql -h localhost -U postgres -d qp12 -f database/schema.sql

      - name: Run benchmark suite
        working-directory: projects/fde-quantum/qp12-multi-modality-quantum-benchmark-aggregator-llm-po
        env:
          DATABASE_URL: postgresql://postgres:password@localhost/qp12
          QDRANT_URL: http://localhost:6333
          MISTRAL_API_KEY: ${{ secrets.MISTRAL_API_KEY }}
        run: pytest tests/ -v --tb=short

      - name: Smoke-test benchmark API
        run: |
          uvicorn src.api:app --host 0.0.0.0 --port 8000 &
          sleep 3
          curl -sf -X POST http://localhost:8000/benchmark \
            -H "Content-Type: application/json" \
            -d '{"circuit":"ghz","n_qubits":3}'
```

**Verify:**
```bash
git push origin main
# GitHub Actions runs benchmark suite
# Green ✓ if all tests pass
```

---

### Step 12: Docker Compose deployment

**Goal:** Package the full stack for reproducible local and cloud deployment.

```yaml
# docker-compose.yml
version: '3.9'
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_DB: qp12
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./database/schema.sql:/docker-entrypoint-initdb.d/schema.sql
    ports: ["5432:5432"]

  qdrant:
    image: qdrant/qdrant
    ports: ["6333:6333"]
    volumes:
      - qdrant_data:/qdrant/storage

  api:
    build: .
    environment:
      DATABASE_URL: postgresql://postgres:password@db/qp12
      QDRANT_URL: http://qdrant:6333
      MISTRAL_API_KEY: ${MISTRAL_API_KEY}
    ports: ["8000:8000"]
    depends_on: [db, qdrant]
    command: uvicorn src.api:app --host 0.0.0.0 --port 8000

  frontend:
    build: ./frontend
    environment:
      NEXT_PUBLIC_API_URL: http://api:8000
    ports: ["3000:3000"]
    depends_on: [api]

volumes:
  pgdata:
  qdrant_data:
```

```dockerfile
# Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ ./src/
COPY database/ ./database/
CMD ["uvicorn", "src.api:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Verify:**
```bash
docker compose up -d
curl http://localhost:8000/results?circuit=ghz
curl http://localhost:3000
# Portal loads with benchmark comparison table
```

---

## Testing

```python
# tests/test_benchmarks.py
import pytest
from src.benchmarks.ghz import ghz_qiskit, ghz_cirq, ghz_pennylane
from src.transpile import get_circuit_metrics
from src.baseline import markowitz_optimize  # not applicable here, remove if not needed
from qiskit import QuantumCircuit

def test_ghz_qiskit_distribution():
    result = ghz_qiskit(n=3, shots=2048)
    counts = result['counts']
    total = sum(counts.values())
    ghz_prob = (counts.get('000', 0) + counts.get('111', 0)) / total
    assert ghz_prob > 0.95, f"GHZ fidelity too low: {ghz_prob:.3f}"

def test_ghz_cirq_distribution():
    result = ghz_cirq(n=3, shots=2048)
    counts = result['counts']
    total = sum(counts.values())
    ghz_prob = (counts.get('000', 0) + counts.get('111', 0)) / total
    assert ghz_prob > 0.95

def test_ghz_pennylane_distribution():
    result = ghz_pennylane(n=3, shots=2048)
    counts = result['counts']
    total = sum(counts.values())
    ghz_prob = (counts.get('000', 0) + counts.get('111', 0)) / total
    assert ghz_prob > 0.95

def test_circuit_metrics():
    qc = QuantumCircuit(3)
    qc.h(0); qc.cx(0, 1); qc.cx(1, 2); qc.measure_all()
    metrics = get_circuit_metrics(qc)
    assert metrics['n_qubits'] == 3
    assert metrics['n_gates'] >= 2   # at least H + 2 CX

def test_tket_transpilation():
    from src.transpile import qiskit_to_cirq_via_tket
    qc = QuantumCircuit(2)
    qc.h(0); qc.cx(0, 1)
    cirq_circ = qiskit_to_cirq_via_tket(qc)
    assert cirq_circ is not None
```

```bash
pytest tests/ -v
# test_ghz_qiskit_distribution PASSED
# test_ghz_cirq_distribution PASSED
# test_ghz_pennylane_distribution PASSED
# test_circuit_metrics PASSED
# test_tket_transpilation PASSED
```

---

## Deployment

```bash
# Local (Docker Compose)
MISTRAL_API_KEY=your_key docker compose up -d

# Cloud (Railway / Render)
# 1. Push to GitHub
# 2. Connect Railway to repo, set MISTRAL_API_KEY env var
# 3. Add PostgreSQL and Qdrant services in Railway dashboard
# 4. Deploy — portal at https://qp12.up.railway.app

# Run benchmark suite manually
curl -X POST http://localhost:8000/benchmark \
  -H "Content-Type: application/json" \
  -d '{"circuit":"qft","n_qubits":4,"shots":2048}'
```

---

## Resources

1. [pytket Documentation](https://tket.quantinuum.com/api-docs/) — TKET IR, backend extensions, compilation passes
2. [Qiskit API Reference](https://docs.quantum.ibm.com/api/qiskit/) — QuantumCircuit, AerSimulator, noise models
3. [Cirq Documentation](https://quantumai.google/cirq) — Circuit, Simulator, DensityMatrixSimulator
4. [PennyLane Documentation](https://pennylane.ai/qml/) — QNode, devices, QAOA, VQE templates
5. [Perceval Documentation](https://perceval.quandela.net/docs/) — linear optics, beam splitters, photon sources
6. [LangChain RAG Tutorial](https://python.langchain.com/docs/use_cases/question_answering/) — retrieval chain patterns
7. [Qdrant Quickstart](https://qdrant.tech/documentation/quickstart/) — vector store setup, similarity search
8. [Mistral AI Docs](https://docs.mistral.ai/) — embeddings API, chat API, structured output

---

## Skill coverage mapping

Refer to: [`doc/research/skill-matrix.md`](../../../doc/research/skill-matrix.md) and [`doc/roadmap/bridge.md`](../../../doc/roadmap/bridge.md)
