# Module Catalogue

> Complete module list across all tracks, phases, and both curriculum threads (general engineering + FDE/Quantum).
> Each module has a slug (used as folder name), learning objective, deliverable, and skill/tool tags.
> Source of truth for what to build and in what order.

---

## How to use this file

- **Slug** = folder name under `tracks/<track>/`
- **Hours** = rough target; log actual in the dashboard
- **Deliverable** = minimum shippable artifact to close the module
- **Skills** = IDs from `bridge.md` Part 1 (FDE/AI) or Part 2 (Quantum)
- **Tools** = IDs from `bridge.md` Part 1 or Part 2

---

## Track: AI Engineer

### Phase 1 — Foundations

| Slug | Hours | Objective | Deliverable | Skills | Tools |
|------|-------|-----------|-------------|--------|-------|
| `01-python-foundations` | 20 | Clean Python: type hints, OOP, packaging, pytest, ruff | Typed data-processing library with tests that pass ruff + pytest | — | Python, pytest, ruff |
| `02-fastapi` | 15 | Build async REST APIs with Pydantic, middleware, and OpenAPI docs | CRUD API with full validation, error handling, and auto-generated docs | SK04 | FastAPI (TL05) |
| `03-data-viz-seaborn-plotly` | 12 | Exploratory data analysis and interactive dashboards | EDA report on a real dataset with Seaborn + Plotly charts | — | seaborn, plotly |
| `04-tensorflow` | 15 | Keras Sequential models, fine-tuning, callbacks | Image classifier trained on CIFAR-10 | SK16 | TensorFlow/Keras |
| `05-pytorch` | 20 | Tensors, autograd, DataLoader, training loop from scratch | Custom CNN trained end-to-end | SK16, SK17 | PyTorch (TL35) |

### Phase 2 — Core modules

| Slug | Hours | Objective | Deliverable | Skills | Tools |
|------|-------|-----------|-------------|--------|-------|
| `06-langchain-rag` | 15 | RAG pipeline: document ingestion, embedding, retrieval, LLM augmentation | Q&A bot over local PDFs using LangChain + pgvector | SK02, SK03 | LangChain (TL01), pgvector (TL03), Postgres (TL04) |
| `07-vector-databases` | 10 | Embedding models, vector DB indexing (HNSW), search relevance tuning | Semantic search app comparing pgvector vs Qdrant | SK14, SK06 | Qdrant (TL10), pgvector (TL03) |
| `08-llm-prompt-engineering` | 10 | Prompt templates, chain-of-thought, structured output, few-shot examples | Prompt library with evaluation harness covering 5+ prompt patterns | SK03, SK11 | Mistral API (TL02), LangChain (TL01) |
| `09-ml-explainability` | 10 | SHAP values, feature importance, model debugging | Explainability dashboard for a trained XGBoost model | SK17 | SHAP (TL28), XGBoost (TL20) |
| `10-time-series-forecasting` | 15 | Prophet + LSTM hybrid, seasonality, trend decomposition | Demand forecast model with a held-out evaluation | SK16, SK17, SK21 | Prophet (TL34), PyTorch (TL35) |
| `11-streaming-ml` | 15 | Kafka event streams, Faust stateful processing, low-latency inference | Real-time feature pipeline feeding a fraud-score endpoint | SK15, SK18, SK19 | Kafka (TL18), Faust (TL19), Redis (TL23) |
| `12-mlops-cicd` | 12 | GitHub Actions CI/CD, ONNX export, model versioning | Automated pipeline: train → test → export ONNX → deploy | SK08, SK19 | GitHub Actions (TL26), ONNX Runtime (TL22) |

### Phase 3 — Capstone

| Slug | Hours | Objective | Deliverable |
|------|-------|-----------|-------------|
| `capstone-ml-api` | 40 | PyTorch model → FastAPI → Docker → Render/Railway | Deployable ML inference API with OpenAPI docs, tests, CI/CD, and live demo |

---

## Track: Software Engineer

### Phase 1 — Foundations

| Slug | Hours | Objective | Deliverable | Skills | Tools |
|------|-------|-----------|-------------|--------|-------|
| `01-shell-scripting` | 10 | Bash, pipes, error handling, cron, env management | Automation scripts for this repo (setup, lint, test) | — | bash, cron |
| `02-nodejs-fundamentals` | 15 | Node.js runtime, Express/Fastify, REST, streams | REST API for a simple CRUD service with tests | SK04 | Express.js (TL13), Node.js |
| `03-nextjs-basics` | 15 | App Router, RSC, SSR/SSG, TypeScript strict mode | Projects showcase site with at least 2 static routes | SK05 | Next.js (TL09), React (TL14) |

### Phase 2 — Core modules

| Slug | Hours | Objective | Deliverable | Skills | Tools |
|------|-------|-----------|-------------|--------|-------|
| `04-nextjs-advanced` | 15 | API routes, server actions, auth (NextAuth), middleware | Auth-protected dashboard with SSR data fetching | SK04, SK05 | Next.js (TL09), Auth0 (TL45) |
| `05-orchestration` | 15 | Docker Compose, GitHub Actions, k8s intro | CI/CD pipeline for a Node app with automated tests and deploy step | SK08, SK19 | Docker (TL15), GitHub Actions (TL26) |
| `06-testing-deep-dive` | 12 | Unit, integration, e2e testing; coverage; mocking | Test suite achieving 80%+ coverage on an existing project | SK08 | vitest, playwright, jest |
| `07-performance-optimization` | 10 | Profiling, caching, query optimization, bundle analysis | Before/after perf report with measurable improvements | SK06, SK20 | Lighthouse, webpack-bundle-analyzer |

### Phase 3 — Capstone

| Slug | Hours | Objective | Deliverable |
|------|-------|-----------|-------------|
| `capstone-fullstack-app` | 50 | Full-stack task management app | Next.js + Node.js + Postgres on Vercel + Railway with auth, tests, CI/CD |

---

## Track: Data Engineer

### Phase 1 — Foundations

| Slug | Hours | Objective | Deliverable | Skills | Tools |
|------|-------|-----------|-------------|--------|-------|
| `01-postgresql` | 12 | Advanced SQL: CTEs, window functions, partitioning, indexing | Analytics queries on a real dataset with explain plans | SK06 | Postgres (TL04) |
| `02-django-orm` | 15 | Models, migrations, querysets, signals, admin | Django app with a complex relational schema and seed data | SK06 | Django, Postgres (TL04) |
| `03-mysql-mariadb` | 10 | MySQL vs Postgres differences, replication concepts | Port a Postgres schema to MySQL with noted trade-offs | SK06 | MySQL |

### Phase 2 — Core modules

| Slug | Hours | Objective | Deliverable | Skills | Tools |
|------|-------|-----------|-------------|--------|-------|
| `04-data-pipelines-airflow` | 15 | Airflow DAGs, operators, sensors, scheduling | End-to-end ETL pipeline: CSV source → Postgres → transform | SK19 | Airflow |
| `05-dbt-transformations` | 12 | dbt models, sources, tests, documentation, lineage | dbt project with at least 3 models, tests, and generated docs | SK06, SK19 | dbt (TL27), Postgres (TL04) |
| `06-data-warehouse` | 12 | Snowflake concepts, OLAP vs OLTP, ELT patterns | Star schema on Snowflake loaded from Postgres via dbt | SK06, SK19 | Snowflake (TL47), dbt (TL27) |
| `07-observability-monitoring` | 10 | Prometheus metrics, Grafana dashboards, alerting | Monitoring stack for an existing service with 3+ meaningful alerts | SK08 | Grafana (TL24), PagerDuty (TL25) |

### Phase 3 — Capstone

| Slug | Hours | Objective | Deliverable |
|------|-------|-----------|-------------|
| `capstone-data-platform` | 45 | Full data platform: ETL → warehouse → dbt → dashboard | Airflow + dbt + Postgres + Looker stack on Docker with live data |

---

## Track: AI Agents

### Phase 1 — Foundations

| Slug | Hours | Objective | Deliverable | Skills | Tools |
|------|-------|-----------|-------------|--------|-------|
| `01-llm-fundamentals` | 12 | Prompt engineering, token limits, RAG concepts, evaluation | Prompt library + manual evaluation harness for 5 prompt patterns | SK03, SK11 | Mistral API (TL02) |
| `02-langchain` | 12 | Chains, memory, output parsers, document loaders | Q&A bot over local documents using LCEL | SK02, SK03 | LangChain (TL01), Qdrant (TL10) |

### Phase 2 — Core modules

| Slug | Hours | Objective | Deliverable | Skills | Tools |
|------|-------|-----------|-------------|--------|-------|
| `03-langgraph` | 15 | State graphs, supervisor patterns, streaming, human-in-the-loop | Multi-step research agent that browses + summarises | SK03, SK13 | LangChain (TL01), LangGraph |
| `04-crewai` | 12 | Agents, tasks, crews, custom tools, memory | Market research crew with 3 agents and a custom web-search tool | SK03, SK13 | CrewAI, LangChain (TL01) |
| `05-mcp-tool-use` | 15 | MCP protocol, custom MCP servers, tool schemas, Claude Desktop | Custom MCP server exposing PostgreSQL data to Claude | SK04, SK13 | MCP SDK, Postgres (TL04) |
| `06-rag-advanced` | 12 | Reranking, hybrid search, chunking strategies, eval metrics | RAG system with BM25 + vector hybrid and RAGAS evaluation | SK02, SK14 | LangChain (TL01), Qdrant (TL10), pgvector (TL03) |

### Phase 3 — Capstone

| Slug | Hours | Objective | Deliverable |
|------|-------|-----------|-------------|
| `capstone-agent-system` | 50 | Multi-agent research assistant with memory, tools, and RAG | LangGraph + MCP + RAG + Streamlit on Streamlit Cloud with demo |

---

## Track: GPU Monitoring

### Phase 1 — Foundations

| Slug | Hours | Objective | Deliverable | Skills | Tools |
|------|-------|-----------|-------------|--------|-------|
| `01-cuda-setup` | 8 | CUDA install, driver compatibility, Docker GPU passthrough | Verified CUDA setup on Windows machine; docker run --gpus all test passing | — | CUDA, nvidia-smi, Docker |
| `02-nvidia-smi-nvtop` | 8 | GPU monitoring: utilization, memory, temperature, power draw | Monitoring script with configurable Slack/email alert thresholds | SK08 | nvidia-smi, nvtop |

### Phase 2 — Core modules

| Slug | Hours | Objective | Deliverable | Skills | Tools |
|------|-------|-----------|-------------|--------|-------|
| `03-remote-training-bridge` | 12 | SSH tunneling, rsync, remote PyTorch execution, tmux sessions | Remote training workflow: local → remote push → train → pull artifacts | SK20 | SSH, rsync, PyTorch (TL35) |
| `04-training-dashboard` | 12 | Real-time training metrics, TensorBoard, wandb integration | Dashboard showing loss/accuracy curves for a live training run | SK08 | TensorBoard, wandb, nvidia-smi |

### Phase 3 — Capstone

| Slug | Hours | Objective | Deliverable |
|------|-------|-----------|-------------|
| `capstone-gpu-monitor` | 30 | Remote training CLI + monitoring dashboard | Python CLI tool + web dashboard showing live GPU stats from remote machine |

---

## Track: HPC & Quantum (General)

### Phase 1 — HPC Foundations

| Slug | Hours | Objective | Deliverable | Skills | Tools |
|------|-------|-----------|-------------|--------|-------|
| `01-hpc-intro` | 15 | Slurm sbatch, job arrays, resource requests, MPI intro | Parallel Python job running on a simulated HPC cluster (local Slurm or NIST) | — | Slurm, MPI |
| `02-quantum-intro` | 15 | Qiskit circuits, gates, simulation, measurement, basic algorithms | Bell state + Grover's algorithm implementation with noise simulation | SK01-Q, SK04-Q | Qiskit (TL01-Q), Qiskit Aer (TL02-Q) |

### Phase 3 — Capstone

| Slug | Hours | Objective | Deliverable |
|------|-------|-----------|-------------|
| `capstone-quantum-hpc` | 40 | Hybrid quantum-classical optimization problem | Qiskit VQE + Python + Slurm on IBM Quantum + local HPC |

---

## Track: FDE / AI (Freelance Field Deployment Engineering)

> These modules correspond to the 10-project FDE portfolio in `bridge.md` Part 1.
> Each module is a full project build, not a learning exercise.
> Sequence: tackle projects roughly in order of increasing specialisation.

### Phase 1 — Foundation projects

| Slug | Hours | Project | Domain | Core skills unlocked | Key tools |
|------|-------|---------|--------|---------------------|-----------|
| `fde-p01-vc-due-diligence` | 60 | VC Due Diligence AI Analyst | Venture Capital | SK01, SK02, SK03, SK04, SK05, SK06, SK07, SK08 | LangChain, Mistral API, pgvector, FastAPI, Next.js, S3, Pinecone |
| `fde-p02-customer-support` | 60 | Customer Support Multimodal Triage | Customer Support | SK02, SK03, SK08, SK11, SK13, SK14, SK15 | LangChain, Whisper, Qdrant, MongoDB, Docker, GCP Cloud Run, Grafana |
| `fde-p05-sales-gtm` | 55 | Sales GTM Playbook and Automation | Sales / GTM | SK03, SK04, SK05, SK06, SK08, SK10, SK12, SK18, SK22, SK23 | LangChain, Mistral API, FastAPI, Next.js, Stripe, SendGrid, Make, Salesforce API, Slack API |

### Phase 2 — Vertical specialisation projects

| Slug | Hours | Project | Domain | Core skills unlocked | Key tools |
|------|-------|---------|--------|---------------------|-----------|
| `fde-p03-fraud-detection` | 65 | Fintech Fraud Detection Real-Time | Financial Services | SK03, SK06, SK08, SK16, SK17, SK18, SK19 | Kafka, Faust, XGBoost, ONNX Runtime, Redis, Grafana, dbt, SHAP |
| `fde-p04-supply-chain` | 60 | Supply Chain Demand Forecasting | Supply Chain | SK03, SK06, SK08, SK10, SK16, SK17, SK21 | Flask, Prophet, PyTorch, Looker, dbt |
| `fde-p06-eng-copilot` | 60 | Engineering Productivity AI Copilot | Developer Tools | SK03, SK05, SK08, SK12, SK20, SK24, SK25, SK26 | LangChain, Tree-sitter, LSP, VS Code, GitHub Actions |
| `fde-p07-field-service` | 60 | Field Service Optimization and Routing | Field Services | SK03, SK05, SK06, SK08, SK20, SK27, SK28 | OR-Tools, PostGIS, Redis, React Native, Google Maps API |

### Phase 3 — Regulated and complex-domain projects

| Slug | Hours | Project | Domain | Core skills unlocked | Key tools |
|------|-------|---------|--------|---------------------|-----------|
| `fde-p08-healthcare` | 65 | Healthcare Patient Outcome Prediction | Healthcare | SK03, SK06, SK08, SK07, SK16, SK17, SK19, SK29, SK30 | XGBoost, spaCy, Auth0, HL7 FHIR, Looker, Grafana |
| `fde-p09-marketing` | 55 | Marketing Performance Attribution | Marketing Analytics | SK03, SK06, SK08, SK10, SK16, SK17, SK19, SK21, SK22, SK32, SK33 | Snowflake, dbt, Looker, Google Analytics API |
| `fde-p10-cinema` | 60 | Cinema Revenue Optimization and Pricing | Media & Entertainment | SK03, SK05, SK06, SK08, SK10, SK16, SK17, SK22, SK31, SK34, SK35 | LangChain, Mistral API, FastAPI, Next.js, Redis, Stripe, Twilio, AWS Lambda |

---

## Track: FDE / Quantum (Quantum Field Deployment Engineering)

> These modules correspond to the 12-project Quantum portfolio in `bridge.md` Part 2.
> Prerequisite: complete Quantum intro module (`hpc-quantum/02-quantum-intro`) before starting P01.
> Phase labels refer to the quantum learning curve, not the general training phases.

### Phase 1 — Quantum theory bootcamp (parallel with first FDE builds)

| Slug | Hours | Objective | Deliverable | Skills |
|------|-------|-----------|-------------|--------|
| `q-theory-01-hilbert-spaces` | 8 | Hilbert spaces, bra-ket notation, computational basis | 10 exercises: state vectors, inner products, tensor products solved in NumPy | SK01-Q, SK05-Q |
| `q-theory-02-measurement` | 6 | Born rule, projective measurements, POVMs | Simulation of measurement outcomes for 2-qubit states | SK02-Q |
| `q-theory-03-gate-model` | 8 | Clifford+T gates, circuit depth, universality | Implement H, CNOT, T gate circuits in Qiskit; verify unitarity | SK04-Q |
| `q-theory-04-decoherence` | 6 | T1/T2 times, Lindblad master equation, noise models | Noise model applied to a Qiskit circuit; decoherence effect visible in fidelity | SK03-Q, SK09-Q |
| `q-theory-05-error-correction` | 8 | Stabiliser formalism, CSS codes, surface code intro | Implement 3-qubit bit-flip code in Qiskit Aer | SK08-Q |
| `q-theory-06-information-theory` | 6 | von Neumann entropy, entanglement, mutual information | Entanglement entropy calculation for Bell states in NumPy | SK07-Q |

### Phase 2A — Superconducting / gate-model track

| Slug | Hours | Project | Key skills gap-filled | Tools |
|------|-------|---------|----------------------|-------|
| `q-p01-vqe-drug-screening` | 80 | Quantum-Enhanced Drug Molecule Screening via VQE | SK09-Q, SK10-Q, SK24-Q, SK25-Q, SK26-Q | Qiskit (TL01-Q), Qiskit Aer (TL02-Q), PyTorch (TL03-Q), FastAPI (TL04-Q), AWS Braket (TL08-Q) |
| `q-p06-circuit-calibration` | 80 | AI-Assisted Quantum Circuit Calibration for Multi-Qubit Gates | SK24-Q, SK25-Q, SK50-Q, SK51-Q, SK52-Q, SK53-Q, SK54-Q | Qiskit Pulse (TL21-Q), Ray (TL22-Q), Prometheus (TL23-Q), Grafana (TL24-Q) |
| `q-p08-qml-anomaly` | 80 | Variational Quantum Classifier for Anomaly Detection | SK55-Q, SK56-Q, SK57-Q | Qiskit (TL01-Q), TKET (TL16-Q), PyTorch (TL03-Q), ONNX (TL28-Q), TFLite (TL29-Q), InfluxDB (TL30-Q) |
| `q-p10-tensor-networks` | 80 | Tensor Network Classical Simulation + ML for Circuit Benchmarking | SK63-Q, SK64-Q, SK65-Q, SK66-Q, SK67-Q | QuTiP (TL34-Q), PyTorch Geometric (TL35-Q), JAX (TL10-Q) |

### Phase 2B — Neutral-atom (Pasqal/Rydberg) track

| Slug | Hours | Prerequisite theory | Project | Key skills gap-filled | Tools |
|------|-------|--------------------|---------|-----------------------|-------|
| `q-theory-rydberg` | 10 | Phase 1 theory complete | Rydberg blockade, QAOA circuit design for neutral atoms | SK11-Q, SK12-Q, SK13-Q, SK14-Q, SK15-Q | Pulser SDK (TL09-Q) |
| `q-p02-qaoa-logistics` | 80 | q-theory-rydberg | Rydberg Neutral-Atom QAOA for Logistics Route Optimisation | SK14-Q, SK15-Q, SK28-Q, SK29-Q | Pulser SDK (TL09-Q), JAX (TL10-Q), Redis (TL11-Q), FastAPI (TL04-Q) |

### Phase 2C — Photonic track

| Slug | Hours | Prerequisite theory | Project | Key skills gap-filled | Tools |
|------|-------|--------------------|---------|-----------------------|-------|
| `q-theory-photonic` | 12 | Phase 1 theory complete | Coherent/Fock states, beam splitter unitaries, Hong-Ou-Mandel, boson sampling | SK16-Q, SK17-Q, SK18-Q, SK19-Q, SK20-Q, SK21-Q | Perceval SDK (TL12-Q) |
| `q-p03-boson-sampling` | 80 | q-theory-photonic | Photonic Quantum Sampling for Materials Discovery | SK38-Q, SK39-Q | Perceval SDK (TL12-Q), JAX (TL10-Q), Qdrant (TL14-Q), CUDA-Q (TL41-Q) |
| `q-p09-sdqc-drug-discovery` | 80 | q-theory-photonic, q-p03 | Secure Delegated Quantum Computation for Privacy-Preserving Drug Discovery | SK58-Q, SK59-Q, SK60-Q, SK61-Q, SK62-Q | Perceval SDK (TL12-Q), Microsoft SEAL (TL31-Q), RDKit (TL32-Q), TF Encrypted (TL33-Q) |

### Phase 2D — Trapped-ion track

| Slug | Hours | Prerequisite theory | Project | Key skills gap-filled | Tools |
|------|-------|--------------------|---------|-----------------------|-------|
| `q-theory-trapped-ion` | 10 | Phase 1 theory complete | Paul/Penning traps, laser-matter interaction, Mølmer–Sørensen gate | SK22-Q, SK23-Q | TKET (TL16-Q), Pytket (TL17-Q) |
| `q-p04-portfolio-optimisation` | 80 | q-theory-trapped-ion | Trapped-Ion Quantum Simulation for Financial Portfolio Optimisation | SK40-Q, SK41-Q | TKET (TL16-Q), Pytket (TL17-Q), JAX (TL10-Q), Kubernetes (TL18-Q) |

### Phase 2E — Annealing (D-Wave) track

| Slug | Hours | Prerequisite theory | Project | Key skills gap-filled | Tools |
|------|-------|--------------------|---------|-----------------------|-------|
| `q-theory-annealing` | 8 | Phase 1 theory complete | Adiabatic theorem, quantum tunnelling, QUBO/Ising formulation, spin glass physics | SK29-Q, SK30-Q, SK31-Q | Ocean SDK (TL19-Q) |
| `q-p05-supply-chain-annealing` | 75 | q-theory-annealing | D-Wave Annealing + ML for Supply Chain Disruption Prediction | SK42-Q, SK43-Q, SK44-Q, SK45-Q | Ocean SDK (TL19-Q), LangChain (TL13-Q), Qdrant (TL14-Q) |
| `q-p11-cinema-pricing` | 75 | q-theory-annealing | Cinema Demand Forecasting & Dynamic Pricing with Quantum Optimisation | SK68-Q, SK69-Q, SK70-Q | Ocean SDK (TL19-Q), PyTorch (TL03-Q), LangChain (TL13-Q) |

### Phase 2F — Post-quantum cryptography track

| Slug | Hours | Project | Key skills gap-filled | Tools |
|------|-------|---------|----------------------|-------|
| `q-p07-pqc-migration` | 75 | Post-Quantum Cryptography Migration with AI-Powered Key Management | SK46-Q, SK47-Q, SK48-Q, SK49-Q | liboqs (TL25-Q), Vault (TL27-Q), Mistral API (TL26-Q), Kubernetes (TL18-Q) |

### Phase 3 — Multi-modality capstone

| Slug | Hours | Project | Scope |
|------|-------|---------|-------|
| `q-p12-benchmark-portal` | 80 | Multi-Modality Quantum Benchmark Aggregator & LLM-Powered Circuit Explainer | Qiskit + Cirq + PennyLane + Perceval + Mistral API + RAG + React/Next.js portal |

---

## Module dependency graph (summary)

```
Phase 1 foundations (all tracks)
  └── AI Engineer track (python → fastapi → pytorch → langchain → capstone)
  └── Software Engineer track (shell → node → nextjs → orchestration → capstone)
  └── Data Engineer track (postgres → django → airflow → dbt → capstone)
  └── AI Agents track (llm-fundamentals → langchain → langgraph → crewai → mcp → capstone)
  └── GPU Monitoring track (cuda → nvidia-smi → remote-bridge → capstone)
  └── HPC & Quantum track (hpc-intro → quantum-intro → capstone)
      │
      └── FDE/AI track [10 projects] (P01 → P02 → P05 → P03 → P04 → P06 → P07 → P08 → P09 → P10)
      │
      └── FDE/Quantum track [12 projects]
            ├── q-theory-01 through q-theory-06 (parallel with FDE/AI P01–P02)
            ├── Phase 2A: superconducting (q-p01 → q-p06 → q-p08 → q-p10)
            ├── Phase 2B: neutral-atom (q-theory-rydberg → q-p02)
            ├── Phase 2C: photonic (q-theory-photonic → q-p03 → q-p09)
            ├── Phase 2D: trapped-ion (q-theory-trapped-ion → q-p04)
            ├── Phase 2E: annealing (q-theory-annealing → q-p05 → q-p11)
            ├── Phase 2F: post-quantum (q-p07)
            └── Phase 3: q-p12 benchmark portal (requires 2A + 2C at minimum)
```

---

## Hour estimates by track

| Track | Phase 1 | Phase 2 | Phase 3 | Total |
|-------|---------|---------|---------|-------|
| AI Engineer | 82 | 92 | 40 | 214 |
| Software Engineer | 40 | 52 | 50 | 142 |
| Data Engineer | 37 | 49 | 45 | 131 |
| AI Agents | 24 | 54 | 50 | 128 |
| GPU Monitoring | 16 | 24 | 30 | 70 |
| HPC & Quantum (general) | 30 | — | 40 | 70 |
| FDE / AI (10 projects) | 175 | 240 | 120 | 535 |
| FDE / Quantum (12 projects) | 52 (theory) | 660 (projects) | 80 | 792 |
| **Total** | | | | **~2,082** |

> Total aligns with ROADMAP.md estimate of ~2,180 hours. Variance is within 5% — rounding on per-module estimates.
