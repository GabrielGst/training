# Phase 3 — Capstones (Weeks 21–28)

## Requirements for Every Capstone

1. Public GitHub repository with complete README (purpose, setup, architecture, screenshots)
2. Live demo or reproducible demo script
3. CI passing (lint + tests)
4. Written case study: what it does, key technical decisions, what you'd do differently at scale
5. No console.log debugging left in production code

---

## Capstone 1: ML Model Serving API (AI Engineer)

**What:** Fine-tune a pre-trained Hugging Face model (e.g., DistilBERT for text classification or ResNet for image classification) and serve it via a FastAPI REST API.

**Stack:** Python 3.12, PyTorch, Hugging Face Transformers, FastAPI, Pydantic v2, Docker, pytest

**Architecture:**
```
Client → FastAPI (Docker) → PyTorch model (loaded at startup) → JSON response
                         ↑
              MLflow experiment tracking (training phase)
```

**Endpoints:**
- `POST /predict` — accepts text/image, returns prediction + confidence
- `GET /health` — liveness + model loaded status
- `GET /model-info` — model card metadata

**Success criteria:**
- Inference latency < 200ms for a single request (CPU)
- Model accuracy documented in README
- Docker image < 2GB
- Full OpenAPI spec generated automatically

---

## Capstone 2: Full-Stack Task Management App (Software Engineer)

**What:** A task management app with real-time updates, user-facing UI, and a proper backend API.

**Stack:** Next.js 14 (App Router), TypeScript, Tailwind CSS, Node.js (API routes), PostgreSQL, Docker, Playwright (E2E)

**Features:**
- Create / edit / delete tasks with labels and due dates
- Drag-and-drop Kanban board (not started → in progress → done)
- Optimistic UI updates
- Server components for initial data fetch, client components for interactivity

**Success criteria:**
- E2E tests for the golden path (create → move → complete task)
- Lighthouse score > 90 on all metrics
- Deployed to Vercel (frontend) + Railway (database)

---

## Capstone 3: End-to-End Data Platform (Data Engineer)

**What:** A complete ELT pipeline: ingest raw data, load to PostgreSQL warehouse, transform with dbt, visualize with Metabase or a custom dashboard.

**Stack:** Python, Apache Airflow, dbt, PostgreSQL 16, Docker Compose

**Pipeline:**
```
Source API (public dataset) → Python extractor → PostgreSQL (raw layer)
  → dbt models (staging → intermediate → mart) → Metabase / custom viz
```

**Orchestration:** Airflow DAG runs daily, with retry logic and alerting

**Success criteria:**
- Idempotent pipeline (re-running produces same result)
- dbt tests pass (not_null, unique, relationships)
- Data lineage documented in dbt docs
- Pipeline runs end-to-end in < 5 minutes for sample dataset

---

## Capstone 4: Multi-Agent Research Assistant (AI Agents)

**What:** A multi-agent system that accepts a research question, decomposes it into sub-tasks, assigns agents, and produces a structured report with cited sources.

**Stack:** Python, LangGraph (supervisor + worker pattern), Claude API (via MCP), Chroma (vector store), Streamlit (UI)

**Architecture:**
```
User question → Supervisor agent → [Search agent, Analysis agent, Writer agent]
                                             ↑
                              MCP tools: web_search, read_url, query_vectordb
```

**Success criteria:**
- Handles multi-step research questions reliably
- Sources cited with URLs
- Gracefully handles sub-agent timeout / tool failure
- LangSmith tracing enabled for observability

---

## Capstone 5: Remote GPU Training CLI (GPU Monitoring)

**What:** A CLI tool and workflow for launching, monitoring, and retrieving results from PyTorch training jobs on a remote NVIDIA Windows machine.

**Stack:** Python (Typer for CLI), Paramiko (SSH), rsync, PyTorch, nvidia-smi

**Commands:**
```bash
train launch --script train.py --config config.yaml  # push + run remotely
train status                                          # live GPU util + loss
train logs --follow                                   # stream training logs
train pull --output ./checkpoints                    # rsync results back
```

**Success criteria:**
- Works end-to-end from Ubuntu to Windows over SSH
- Shows live GPU utilization during training
- Documented setup in `doc/environment/gpu-bridge.md`

---

## Capstone 6: Hybrid Quantum-Classical Optimization (HPC/Quantum)

**What:** Implement the Variational Quantum Eigensolver (VQE) algorithm for a simple molecular energy estimation, comparing quantum simulation vs classical approximation.

**Stack:** Python, Qiskit, Qiskit Aer (simulator), NumPy, Matplotlib

**What it demonstrates:**
- Quantum circuit construction and execution
- Parameter optimization loop (classical optimizer + quantum circuit)
- Results visualization with energy convergence plot
- Comparison of simulation vs exact diagonalization

**Success criteria:**
- VQE converges for H2 molecule (simplest case)
- Results match expected ground state energy within tolerance
- Code is commented explaining the quantum operations for a classical audience
- Slurm job script included for running on an HPC cluster
