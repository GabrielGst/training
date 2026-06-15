# Skill Matrix — Field-Deployment Engineer (AI + Quantum)

> Synthesized from: `fde_ai_skills.csv`, `fde_ai_tools.csv`, `fde_ai_projects.csv`, `fde_ai_bridge.csv`,
> `fde_quantum_skills.csv`, `fde_quantum_tools.csv`, `fde_quantum_projects.csv`, `fde_quantum_bridge.csv`.
> Stack Overflow Developer Survey 2025, roadmap.sh, IBM Quantum Learning, Anthropic docs, Pasqal/Quandela docs.
> Last updated: 2026-06-15. Refresh annually.

---

## How to read this document

| Column / Field | Meaning |
|----------------|---------|
| **Frequency** | How often the skill appears in relevant JDs or project stacks (High ≥ 60 % / Medium 30–59 % / Low < 30 %) |
| **Junior floor** | Minimum expected at entry level |
| **Senior ceiling** | Expected at 4–6 YoE level |
| **Gap?** | Whether this is an identified candidate gap that needs closing |
| **Phase** | Learning phase (Phase 1 = Foundation · Phase 2 = FDE Track · Phase 3 = Quantum-AI Specialist) |
| **Tier** | P1 = block everything else · P2 = high value · P3 = differentiator |
| **Projects** | Project IDs where the skill is exercised (AI: P01–P10 · Quantum: Q-P01–Q-P12) |

**Two parallel track systems:**
- **AI FDE Track** (P01–P10): 10 production AI projects targeting roles at companies like Mistral AI, Anthropic, and AI-native startups.
- **Quantum FDE Track** (Q-P01–Q-P12): 12 quantum-AI hybrid projects targeting Pasqal, Quandela, IonQ/Quantinuum, D-Wave, and similar.

---

## Part A — AI FDE Track

### A1. Core AI/ML Skills

| Skill | Category | Frequency | Junior Floor | Senior Ceiling | Gap? | Tier | Projects |
|-------|----------|-----------|--------------|----------------|------|------|----------|
| RAG Architecture Design | AI/ML & LLM | **High** | Basic chunking + retrieval pipeline, pgvector setup | Advanced RAG (re-ranking, query rewriting, HyDE), multi-modal ingestion | No | P1 | P01, P02, P06 |
| Prompt Engineering & System Design | AI/ML & LLM | **High** | Craft prompts for structured output, few-shot, CoT | System prompt design, iterative refinement, token budget management | No | P1 | P01–P10 |
| LLM Integration & Orchestration | AI/ML & LLM | **High** | LangChain chains, basic memory, tool calling | Custom callbacks, LangSmith tracing, streaming, cost optimization | No | P1 | P01–P10 |
| Structured Output Extraction | AI/ML & LLM | **Medium** | Pydantic validation, json.loads, retry logic | Output parsers, fallback strategies, schema evolution | No | P2 | P01, P02 |
| Feature Engineering & Model Architecture | AI/ML & LLM | **High** | Sklearn pipelines, XGBoost basics | Ensemble stacking, custom transformers, ablation studies | No | P1 | P03, P04, P09, P10 |
| Model Evaluation & Ablation Testing | AI/ML & LLM | **High** | Train/test split, cross-val, confusion matrix | Holdout evaluation, ablation frameworks, calibration curves | No | P1 | P03, P04, P09, P10 |
| Time-Series Forecasting | AI/ML & LLM | **Medium** | Prophet basics, ARIMA, LSTM intro | Hybrid Prophet+LSTM, seasonal decomposition, anomaly detection | No | P2 | P04, P09, P10 |
| Statistical Modeling & Causal Inference | AI/ML & LLM | **Medium** | Basic Shapley attribution, A/B test design | DoWhy, propensity scoring, counterfactual reasoning | No | P2 | P10 |
| Semantic Search & Vector Store Optimization | Data & Infra | **High** | Embed + store + retrieve, cosine similarity | ANN indexing (HNSW), metadata filtering, hybrid search | No | P1 | P02 |
| Multimodal AI (Audio/Video/Text) | AI/ML & LLM | **Medium** | Whisper transcription, basic NLP pipeline | Intent classification, fine-tuned classifiers, sentiment fusion | No | P2 | P02, P06, P08 |

---

### A2. Full-Stack & API Skills

| Skill | Category | Frequency | Junior Floor | Senior Ceiling | Gap? | Tier | Projects |
|-------|----------|-----------|--------------|----------------|------|------|----------|
| Full-Stack Application Development | Full-Stack & APIs | **High** | React components, FastAPI endpoints, Postgres CRUD | RSC, streaming, auth, SSR, performance optimization | No | P1 | P01–P10 |
| API Design & Contract Management | Full-Stack & APIs | **High** | REST CRUD, Pydantic schemas, basic error handling | Versioning, rate limiting, contract testing, OpenAPI docs | No | P1 | P01–P10 |
| IDE Integration & Developer UX | Full-Stack & APIs | **Medium** | VSCode extension basics, JSON-RPC | LSP server, Tree-sitter parsing, low-latency UX | No | P2 | P06 |
| Context Window Management | AI/ML & LLM | **Medium** | Token counting, basic summarization | Prompt compression, hierarchical prompting, document chunking | No | P2 | P06, P07 |
| Codebase Indexing & Semantic Search | AI/ML & LLM | **Medium** | Tree-sitter basics, code embedding | Code2Vec, semantic code retrieval at scale | No | P3 | P06 |
| Mobile App Integration & Real-time Sync | Full-Stack & APIs | **Low** | React Native basics, Firebase | WebSocket, offline-first design, mobile perf | No | P3 | P07 |
| Geospatial Data & Location Services | Data & Infra | **Low** | PostGIS basics, lat/lng queries | Spatial indexing, OR-Tools VRP, routing algorithms | No | P3 | P07 |
| Voice/Audio Processing & Transcription | Full-Stack & APIs | **Low** | Whisper API integration | WebRTC, audio streaming, real-time transcription | No | P3 | P08 |

---

### A3. Data & Infrastructure Skills

| Skill | Category | Frequency | Junior Floor | Senior Ceiling | Gap? | Tier | Projects |
|-------|----------|-----------|--------------|----------------|------|------|----------|
| Database Schema Design & Query Optimization | Data & Infra | **High** | DDL, DML, indexes, basic joins | Window functions, CTEs, query planning, partitioning | No | P1 | P01–P10 |
| ETL Pipeline Design | Data & Infra | **High** | Extract-transform-load basics, dbt models | Incremental loads, CDC, idempotency, backfills | No | P1 | P01–P10 |
| Pipeline Orchestration & Automation | MLOps/LLMOps | **High** | Airflow DAGs, GitHub Actions workflows | Custom operators, Kubernetes executor, CI/CD triggers | No | P1 | P03, P04, P08, P10 |
| Real-time Integration & Event Streaming | Enterprise Integration | **Medium** | Pub/Sub basics, Kafka consumer | Stateful streaming (Faust), CDC, low-latency feature engineering | No | P2 | P02 |
| Cost Optimization & Resource Allocation | Data & Infra | **Medium** | Identify redundant queries, basic caching | Spot instances, query cost analysis, batch vs real-time tradeoffs | No | P2 | P03, P04, P06, P07, P09, P10 |

---

### A4. MLOps & Observability Skills

| Skill | Category | Frequency | Junior Floor | Senior Ceiling | Gap? | Tier | Projects |
|-------|----------|-----------|--------------|----------------|------|------|----------|
| Observability & Production Debugging | MLOps/LLMOps | **High** | Grafana dashboards, basic logging | Distributed tracing (Jaeger), alerting runbooks, root-cause analysis | No | P1 | P01–P10 |
| Feedback Loop Design & Active Learning | MLOps/LLMOps | **Medium** | Basic annotation workflow, manual labels | Uncertainty sampling, Snorkel weak labels, retraining pipelines | No | P2 | P03, P04, P05, P10 |
| Agent Evaluation | AI/ML & LLM | **Medium** | Manual testing, basic evals | LLM-as-judge, automated eval harnesses, LangSmith | No | P2 | P01–P10 |

---

### A5. Product & Business Skills

| Skill | Category | Frequency | Junior Floor | Senior Ceiling | Gap? | Tier | Projects |
|-------|----------|-----------|--------------|----------------|------|------|----------|
| Requirements Discovery & Scoping Workshops | Product & Business | **High** | User story mapping, acceptance criteria | RICE prioritization, ambiguous problem translation, stakeholder facilitation | No | P1 | P01, P04, P05, P08 |
| Cross-functional Stakeholder Engagement | Product & Business | **High** | RACI mapping, structured communication | Executive alignment, expectation management, retrospectives | No | P1 | P01, P04, P05, P08 |
| Business Impact & ROI Quantification | Product & Business | **High** | Basic KPI definition, time-saved metric | Shapley attribution, A/B test design, financial modeling | No | P1 | P01, P04, P05, P09, P10 |
| Customer Feedback Loops & Iteration | Product & Business | **Medium** | Surveys, usage analytics | Segment + Amplitude, telemetry-driven decisions | No | P2 | P01, P02, P05, P06, P10 |
| Experimentation & A/B Testing | Product & Business | **Medium** | Basic test design, significance testing | Power calculations, feature flags (LaunchDarkly), Bayesian A/B | No | P2 | P05, P09, P10 |

---

### A6. Enterprise Integration Skills

| Skill | Category | Frequency | Junior Floor | Senior Ceiling | Gap? | Tier | Projects |
|-------|----------|-----------|--------------|----------------|------|------|----------|
| Data Security & Privacy Compliance | Enterprise Integration | **Medium** | Auth0 basics, at-rest encryption | VPC isolation, audit logging, GDPR/HIPAA controls | No | P2 | P01, P08 |
| HIPAA & Healthcare Compliance | Enterprise Integration | **Low** | PHI encryption, basic access control | HL7 FHIR, audit trails, BAA management, PrivateLink | No | P3 | P08 |
| Data Privacy & Compliance at Scale | Enterprise Integration | **Low** | PII redaction, anonymization basics | CCPA/GDPR frameworks, responsible AI policies | No | P3 | P05 |

---

### A7. AI FDE Tool Stack

The following tools are exercised across the 10 AI FDE projects. Coverage indicates how many of the 10 projects use the tool.

| Tool | Category | Coverage | Gap? | Key Projects |
|------|----------|----------|------|--------------|
| LangChain | AI/ML & LLM | 6/10 | No | P01, P02, P05, P06, P08, P10 |
| Mistral API | AI/ML & LLM | 6/10 | No | P01, P02, P05, P06, P08, P10 |
| Postgres | Data & Infra | 9/10 | No | P01, P03–P10 |
| FastAPI | Full-Stack & APIs | 4/10 | No | P01, P05, P08, P10 |
| Next.js | Full-Stack & APIs | 4/10 | No | P01, P05, P06, P10 |
| S3 (AWS) | Data & Infra | 7/10 | No | P01, P04–P07, P09, P10 |
| GitHub Actions | MLOps/LLMOps | 5/10 | No | P01, P04, P06, P09, P10 |
| Redis | Data & Infra | 4/10 | No | P03, P07, P08, P10 |
| Grafana | MLOps/LLMOps | 3/10 | No | P02, P03, P08 |
| dbt | Data & Infra | 3/10 | No | P03, P04, P09 |
| Looker | Product & Business | 3/10 | No | P04, P08, P09 |
| XGBoost | AI/ML & LLM | 2/10 | No | P03, P08 |
| Kafka / Faust | Data & Infra | 1/10 | No | P03 |
| Qdrant | Data & Infra | 1/10 | No | P02 |
| pgvector | Data & Infra | 1/10 | No | P01 |
| Whisper | AI/ML & LLM | 1/10 | No | P02 |
| OR-Tools | AI/ML & LLM | 1/10 | No | P07 |
| spaCy | AI/ML & LLM | 1/10 | No | P08 |
| SHAP | MLOps/LLMOps | 2/10 | No | P03, P08 |
| ONNX Runtime | MLOps/LLMOps | 1/10 | No | P03 |
| Snowflake | Data & Infra | 1/10 | No | P09 |
| React Native | Full-Stack & APIs | 1/10 | No | P07 |
| PostGIS | Data & Infra | 1/10 | No | P07 |

---

## Part B — Quantum FDE Track

### B1. Quantum Physics Foundations

| Skill | Category | Phase | Gap? | Type | Tier | Projects |
|-------|----------|-------|------|------|------|----------|
| Quantum State Representation (Hilbert Spaces & Bra-Ket) | Physics & Mathematics | Phase 1 | Yes | Theory | P1 | Q-P01–Q-P12 |
| Quantum Measurement Theory (Born Rule, POVMs) | Physics & Mathematics | Phase 1 | Yes | Theory | P1 | Q-P01–Q-P10 |
| Quantum Gate Model & Clifford+T Gate Sets | Physics & Mathematics | Phase 1 | Yes | Theory | P1 | Q-P01–Q-P06, Q-P08–Q-P10, Q-P12 |
| Complex Vector Spaces & Tensor Products | Physics & Mathematics | Phase 1 | No | Theory | P1 | Q-P01, Q-P02, Q-P04, Q-P06, Q-P08, Q-P10 |
| Eigendecomposition & Matrix Decompositions (SVD, QR) | Physics & Mathematics | Phase 1 | No | Theory | P1 | Q-P01, Q-P04, Q-P06, Q-P08, Q-P10 |
| Quantum Decoherence & Relaxation (T1/T2, Lindblad) | Physics & Mathematics | Phase 2 | Yes | Theory | P2 | Q-P01, Q-P04, Q-P06, Q-P08 |
| Quantum Information Theory (von Neumann Entropy) | Physics & Mathematics | Phase 2 | Yes | Theory | P2 | Q-P01, Q-P08 |
| Quantum Error Correction (Stabiliser Formalism, Surface Codes) | Physics & Mathematics | Phase 3 | Yes | Theory | P3 | Q-P01, Q-P08 |

---

### B2. Neutral-Atom (Rydberg) Skills

| Skill | Category | Phase | Gap? | Type | Tier | Projects |
|-------|----------|-------|------|------|------|----------|
| Rydberg Atom Physics & Dipole Blockade | Physics & Mathematics | Phase 2 | Yes | Theory | P2 | Q-P02 |
| Optical Tweezer Trap Design & Manipulation | Physics & Mathematics | Phase 1 | No | Theory | P1 | Q-P02 |
| Laser Cooling (Doppler & Sub-Doppler) | Physics & Mathematics | Phase 1 | No | Theory | P1 | Q-P02 |

**Note:** Optical tweezer and laser cooling skills are identified as candidate strengths (no gap) from McGill / Institut d'Optique background. These are direct hire signals for Pasqal/Quandela roles.

---

### B3. Photonic Quantum Skills

| Skill | Category | Phase | Gap? | Type | Tier | Projects |
|-------|----------|-------|------|------|------|----------|
| Photonic Quantum Optics (Coherent, Fock & Squeezed States) | Physics & Mathematics | Phase 2 | No | Theory | P2 | Q-P03, Q-P09 |
| Beam Splitter Unitaries & Hong-Ou-Mandel Effect | Physics & Mathematics | Phase 2 | No | Theory | P2 | Q-P03, Q-P09 |
| Photon Indistinguishability & KLM Theorem | Physics & Mathematics | Phase 3 | Yes | Theory | P3 | Q-P03, Q-P09 |
| Boson Sampling & Computational Complexity Theory | Physics & Mathematics | Phase 3 | Yes | Theory | P3 | Q-P03, Q-P09 |
| Quantum Fourier Transform & Phase Estimation | Physics & Mathematics | Phase 2 | Yes | Theory | P2 | Q-P03, Q-P09 |
| Single-Photon Source Engineering & Characterisation | Physics & Mathematics | Phase 3 | Yes | Engineering | P3 | Q-P03, Q-P09 |

---

### B4. Trapped-Ion Skills

| Skill | Category | Phase | Gap? | Type | Tier | Projects |
|-------|----------|-------|------|------|------|----------|
| Trapped-Ion Physics (Paul & Penning Traps) | Physics & Mathematics | Phase 2 | Yes | Theory | P2 | Q-P04 |
| Mølmer-Sørensen Gate Mechanism | Physics & Mathematics | Phase 2 | Yes | Theory | P2 | Q-P04 |

---

### B5. Annealing / QUBO Skills

| Skill | Category | Phase | Gap? | Type | Tier | Projects |
|-------|----------|-------|------|------|------|----------|
| QUBO & Ising Model Formulation | Quantum Computing | Phase 2 | Yes | Hybrid | P2 | Q-P05, Q-P11 |
| Adiabatic Theorem & Quantum Tunnelling | Physics & Mathematics | Phase 2 | Yes | Theory | P2 | Q-P05, Q-P07, Q-P11 |
| Spin Glass Physics & Adiabatic Evolution | Physics & Mathematics | Phase 2 | Yes | Theory | P2 | Q-P05, Q-P11 |
| Constraint Embedding for QUBO & Ising Models | Quantum Computing | Phase 2 | Yes | Engineering | P2 | Q-P02, Q-P04, Q-P05, Q-P11 |

---

### B6. Quantum Algorithms

| Skill | Category | Phase | Gap? | Type | Tier | Projects |
|-------|----------|-------|------|------|------|----------|
| NISQ-Era Limitations & Error Mitigation Strategies | Quantum Computing | Phase 2 | Yes | Hybrid | P1 | Q-P01, Q-P06, Q-P08 |
| Variational Quantum Eigensolver (VQE) | Quantum Computing | Phase 2 | Yes | Hybrid | P1 | Q-P01, Q-P04 |
| QAOA Algorithm & Circuit Design | Quantum Computing | Phase 2 | Yes | Hybrid | P1 | Q-P02, Q-P04, Q-P05 |
| Variational Quantum Machine Learning (QML) | Quantum-AI Hybrid | Phase 2 | Yes | Hybrid | P2 | Q-P08 |
| Angle Encoding for Feature Maps | Quantum-AI Hybrid | Phase 2 | Yes | Hybrid | P2 | Q-P08 |
| Barren Plateaus & Variational Circuit Optimisation | Physics & Mathematics | Phase 3 | Yes | Theory | P3 | Q-P08 |
| Quantum Circuit Benchmarking & Metrics | Quantum Computing | Phase 2 | Yes | Engineering | P2 | Q-P10, Q-P12 |

---

### B7. Quantum-AI Hybrid Skills

| Skill | Category | Phase | Gap? | Type | Tier | Projects |
|-------|----------|-------|------|------|------|----------|
| ML for Quantum Error Mitigation | Quantum-AI Hybrid | Phase 2 | Yes | Hybrid | P1 | Q-P01–Q-P10 |
| Hybrid Classical-Quantum Loops & Orchestration | Quantum-AI Hybrid | Phase 2 | Yes | Engineering | P1 | Q-P01–Q-P12 |
| AI-Assisted Circuit Optimisation (GNN-Guided Transpilation) | Quantum-AI Hybrid | Phase 2 | Yes | Hybrid | P2 | Q-P02, Q-P05 |
| Reinforcement Learning for Hardware Control | AI/ML & LLM | Phase 2 | Yes | Engineering | P2 | Q-P06 |
| Randomised Benchmarking Protocol Design | Quantum Computing | Phase 2 | Yes | Engineering | P2 | Q-P06 |
| Tensor Network Theory (MPS, PEPS, MERA) | Physics & Mathematics | Phase 3 | Yes | Theory | P3 | Q-P10 |
| Graph Neural Networks (GNNs) for Quantum Circuits | AI/ML & LLM | Phase 2 | Yes | Engineering | P2 | Q-P10 |
| Classical Tensor Contraction & opt_einsum | Quantum Computing | Phase 2 | Yes | Engineering | P2 | Q-P10 |

---

### B8. Classical Engineering (Required for Quantum FDE)

| Skill | Category | Phase | Gap? | Type | Tier | Projects |
|-------|----------|-------|------|------|------|----------|
| PyTorch Production Patterns (Distributed Training, Model Serving) | AI/ML & LLM | Phase 2 | No | Engineering | P1 | Q-P01–Q-P11 |
| REST API Design & FastAPI | Full-Stack & APIs | Phase 1 | No | Engineering | P1 | Q-P01–Q-P12 |
| SQL Data Modelling (PostgreSQL, Schema Design) | Data & Infra | Phase 1 | No | Engineering | P1 | Q-P01–Q-P11 |
| Container Orchestration (Docker & Kubernetes) | MLOps/LLMOps | Phase 1 | Yes | Engineering | P1 | Q-P01–Q-P12 |
| CI/CD & GitHub Actions | MLOps/LLMOps | Phase 1 | Yes | Engineering | P1 | Q-P01–Q-P12 |
| Distributed Systems & Caching (Redis) | Data & Infra | Phase 2 | Yes | Engineering | P2 | Q-P02, Q-P05, Q-P06, Q-P08, Q-P11 |
| Cache-Aware Algorithm Design | Data & Infra | Phase 2 | Yes | Engineering | P2 | Q-P02 |
| Distributed ML Training (Ray / Spark) | MLOps/LLMOps | Phase 2 | Yes | Engineering | P2 | Q-P06 |
| MLOps & Continuous Retraining Pipelines | MLOps/LLMOps | Phase 2 | Yes | Engineering | P2 | Q-P06 |
| Prometheus / Grafana Monitoring | MLOps/LLMOps | Phase 1 | Yes | Engineering | P2 | Q-P06 |
| Real-Time Inference Acceleration & Latency Optimisation | AI/ML & LLM | Phase 2 | Yes | Engineering | P2 | Q-P02, Q-P05 |
| High-Performance Computing (HPC) Optimization | Data & Infra | Phase 2 | Yes | Engineering | P2 | Q-P10 |
| Generative Models (VAE, Diffusion, Flow Models) | AI/ML & LLM | Phase 2 | Yes | Engineering | P2 | Q-P03 |
| Vector Database Integration (Qdrant / Weaviate) | Data & Infra | Phase 2 | Yes | Engineering | P2 | Q-P03, Q-P05, Q-P09, Q-P12 |
| LSTM Time-Series Forecasting | AI/ML & LLM | Phase 1 | No | Engineering | P1 | Q-P08, Q-P11 |

---

### B9. LLM Skills (Applied in Quantum Context)

| Skill | Category | Phase | Gap? | Type | Tier | Projects |
|-------|----------|-------|------|------|------|----------|
| Prompt Engineering & Chain-of-Thought Reasoning | AI/ML & LLM | Phase 2 | Yes | Engineering | P1 | Q-P05, Q-P07, Q-P11, Q-P12 |
| Retrieval-Augmented Generation (RAG) Architecture | AI/ML & LLM | Phase 2 | Yes | Engineering | P1 | Q-P05, Q-P07, Q-P11, Q-P12 |
| LLM Output Parsing & Safety | AI/ML & LLM | Phase 2 | Yes | Engineering | P2 | Q-P05, Q-P07, Q-P11, Q-P12 |
| Semantic Search & Vector Embeddings | AI/ML & LLM | Phase 2 | Yes | Engineering | P2 | Q-P05, Q-P07, Q-P09, Q-P12 |

---

### B10. Security & Privacy Skills

| Skill | Category | Phase | Gap? | Type | Tier | Projects |
|-------|----------|-------|------|------|------|----------|
| NIST PQC Standards (Kyber, Dilithium, CRYSTALS) | Enterprise Integration | Phase 2 | Yes | Engineering | P2 | Q-P07 |
| Cryptographic Protocol Design & Implementation | Enterprise Integration | Phase 2 | Yes | Engineering | P2 | Q-P07 |
| Key Lifecycle Management (Generation, Rotation, Revocation) | Enterprise Integration | Phase 2 | Yes | Engineering | P2 | Q-P07 |
| Hardware Security Module (HSM) Integration | Enterprise Integration | Phase 2 | Yes | Engineering | P3 | Q-P07 |
| Homomorphic Encryption Theory & Implementation | Enterprise Integration | Phase 3 | Yes | Hybrid | P3 | Q-P09 |
| Secure Multi-Party Computation (MPC) | Enterprise Integration | Phase 3 | Yes | Hybrid | P3 | Q-P09 |
| Privacy-Preserving Quantum Protocols (Blind Computation) | Quantum-AI Hybrid | Phase 3 | Yes | Hybrid | P3 | Q-P09 |
| Regulatory Compliance (FDA 21 CFR Part 11 / EMA GMP Annex 11) | Enterprise Integration | Phase 2 | Yes | Engineering | P3 | Q-P09 |

---

### B11. Domain & Developer Experience Skills

| Skill | Category | Phase | Gap? | Type | Tier | Projects |
|-------|----------|-------|------|------|------|----------|
| Financial Domain Integration (Risk Metrics, Portfolio Theory) | Enterprise Integration | Phase 2 | Yes | Engineering | P2 | Q-P04 |
| Inventory Management & Constraint Optimization | Enterprise Integration | Phase 2 | Yes | Engineering | P2 | Q-P11 |
| Revenue Management & Dynamic Pricing Theory | Enterprise Integration | Phase 2 | Yes | Engineering | P2 | Q-P11 |
| Technical Documentation & Developer Experience | Product & Business | Phase 1 | No | Engineering | P1 | Q-P12 |
| Benchmark Design & Evaluation Metrics | Quantum Computing | Phase 2 | Yes | Engineering | P2 | Q-P12 |
| Multi-SDK Integration & Circuit Transpilation | Quantum Computing | Phase 2 | Yes | Engineering | P2 | Q-P12 |
| Community & Open-Source Engagement | Product & Business | Phase 1 | No | Engineering | P2 | Q-P12 |

---

### B12. Quantum FDE Tool Stack

| Tool | Category | Stack | Gap? | Key Projects |
|------|----------|-------|------|--------------|
| Qiskit | Quantum SDK | Superconducting | Yes | Q-P01, Q-P04, Q-P06, Q-P08, Q-P10, Q-P12 |
| Qiskit Aer | Quantum Simulation | Superconducting | Yes | Q-P01, Q-P06, Q-P08 |
| Qiskit Pulse | Quantum SDK | Superconducting | Yes | Q-P06 |
| Pulser SDK | Quantum SDK | Neutral-atom | Yes | Q-P02 |
| Perceval SDK | Quantum SDK | Photonic | Yes | Q-P03, Q-P09, Q-P12 |
| TKET / Pytket | Quantum SDK | Trapped-ion | Yes | Q-P04, Q-P08 |
| Ocean SDK (D-Wave) | Quantum SDK | Annealing | Yes | Q-P05, Q-P11 |
| PennyLane | Quantum SDK | Cross-platform | Yes | Q-P12 |
| Cirq | Quantum SDK | Superconducting | Yes | Q-P12 |
| QuTiP | Quantum Simulation | All | Yes | Q-P10 |
| AWS Braket | Quantum SDK | All | Yes | Q-P01, Q-P02, Q-P08 |
| CUDA-Q (NVIDIA) | Quantum SDK | All | Yes | Q-P03 |
| PyTorch | AI/ML & LLM | Classical | No | Q-P01–Q-P11 |
| JAX | AI/ML & LLM | Classical | Yes | Q-P02–Q-P05, Q-P10 |
| PyTorch Geometric | AI/ML & LLM | Classical | Yes | Q-P10 |
| FastAPI | Full-Stack & APIs | Classical | No | Q-P01–Q-P12 |
| PostgreSQL | Data & Infra | Classical | No | Q-P01–Q-P11 |
| Docker | MLOps/LLMOps | Classical | Yes | Q-P01–Q-P12 |
| Kubernetes | MLOps/LLMOps | Classical | Yes | Q-P04, Q-P06–Q-P08, Q-P10 |
| GitHub Actions | MLOps/LLMOps | Classical | Yes | Q-P01–Q-P07, Q-P10–Q-P12 |
| Redis | Data & Infra | Classical | Yes | Q-P02, Q-P05, Q-P08, Q-P11 |
| Ray (Distributed Computing) | MLOps/LLMOps | Classical | Yes | Q-P06 |
| Prometheus | MLOps/LLMOps | Classical | Yes | Q-P06, Q-P07 |
| Grafana | MLOps/LLMOps | Classical | Yes | Q-P06 |
| LangChain | AI/ML & LLM | Classical | Yes | Q-P03, Q-P05, Q-P07, Q-P11, Q-P12 |
| Mistral API | AI/ML & LLM | Classical | Yes | Q-P07, Q-P11, Q-P12 |
| Qdrant | Data & Infra | Classical | Yes | Q-P03, Q-P05, Q-P09, Q-P12 |
| liboqs (OpenQuantumSafe) | Quantum SDK | Classical | Yes | Q-P07 |
| Vault (HashiCorp) | Data & Infra | Classical | Yes | Q-P07 |
| Microsoft SEAL | Quantum SDK | Classical | Yes | Q-P09 |
| ONNX | AI/ML & LLM | Classical | Yes | Q-P08 |
| InfluxDB | Data & Infra | Classical | Yes | Q-P08 |
| Bloomberg API | Enterprise Integration | Classical | Yes | Q-P04 |
| mitiq | Quantum Simulation | All | Yes | Q-P01, Q-P06 |

---

## Part C — Skill Overlap: Where AI FDE and Quantum FDE Converge

The following skills appear in **both** the AI FDE and Quantum FDE skill systems and should be prioritized first — learning them once covers both tracks:

| Shared Skill | AI Projects | Quantum Projects |
|--------------|-------------|-----------------|
| PyTorch / deep learning production patterns | P04 | Q-P01–Q-P11 |
| FastAPI REST API design | P01, P05, P08, P10 | Q-P01–Q-P12 |
| PostgreSQL schema design & query optimization | P01–P10 | Q-P01–Q-P11 |
| Docker containerization | P02 | Q-P01–Q-P12 |
| GitHub Actions CI/CD | P01, P04, P06, P09, P10 | Q-P01–Q-P12 |
| Prompt engineering & LLM integration | P01–P10 | Q-P05, Q-P07, Q-P11, Q-P12 |
| RAG architecture design | P01, P02, P06 | Q-P05, Q-P07, Q-P11, Q-P12 |
| Redis caching | P03, P07, P08, P10 | Q-P02, Q-P05, Q-P08, Q-P11 |
| Observability (Prometheus / Grafana) | P02, P03, P08 | Q-P06 |
| LangChain orchestration | P01, P02, P05, P06, P08, P10 | Q-P03, Q-P05, Q-P07, Q-P11, Q-P12 |
| Mistral API | P01, P02, P05, P06, P08, P10 | Q-P07, Q-P11, Q-P12 |
| Vector databases (Qdrant / pgvector) | P01, P02 | Q-P03, Q-P05, Q-P09, Q-P12 |

**These 12 shared skill clusters form the non-negotiable core. Build them first.**

---

## Part D — Priority Tiers

### P1 — Foundation (do first, no excuses)

**AI FDE:** Prompt engineering, RAG design, LLM orchestration (LangChain), FastAPI, React/Next.js, PostgreSQL, Docker, GitHub Actions, ETL / pipeline design, observability (Grafana), requirements discovery, business impact quantification.

**Quantum FDE:** Quantum state representation (Hilbert spaces), quantum gate model (Clifford+T), VQE algorithm, NISQ-era limitations, ML for quantum error mitigation, hybrid classical-quantum loops, FastAPI, PostgreSQL, Docker, GitHub Actions, PyTorch production patterns.

**Both simultaneously:** FastAPI, PostgreSQL, Docker, GitHub Actions, PyTorch, LangChain / Mistral API, Redis, observability.

---

### P2 — High Value (build in parallel with P1)

**AI FDE:** Feature engineering, model evaluation, time-series forecasting, Kafka/event streaming, cost optimization, customer feedback loops, A/B testing, multimodal AI.

**Quantum FDE:** QAOA, QUBO / Ising models, quantum error mitigation (mitiq, ZNE), Qiskit / Pulser / Perceval SDKs, JAX, Kubernetes, Redis, Ray, Prometheus/Grafana, vector databases, generative models (VAE/diffusion), LLM prompt engineering for quantum context, PQC standards (Kyber/Dilithium).

---

### P3 — Differentiators (once P1+P2 solid)

**AI FDE:** Codebase semantic search (Tree-sitter/LSP), geospatial operations (OR-Tools/PostGIS), mobile deployment (React Native), HIPAA compliance, voice/audio processing.

**Quantum FDE:** Quantum error correction (surface codes), barren plateau mitigation, homomorphic encryption, SDQC (blind computation), secure MPC, FDA 21 CFR Part 11 compliance, boson sampling complexity theory, single-photon source engineering, tensor network theory.

---

## Part E — Project Portfolio Summary

### AI FDE Projects (P01–P10)

| ID | Project | Domain | Key AI Skills | Key Tools |
|----|---------|--------|---------------|-----------|
| P01 | VC Due Diligence AI Analyst | Venture Capital | RAG, prompt engineering, LLM orchestration | LangChain, Mistral, pgvector, FastAPI, Next.js |
| P02 | Customer Support Multimodal Triage | Customer Support | Multimodal ingestion, RAG, async pipelines | LangChain, Mistral, Whisper, Qdrant, Docker |
| P03 | Fintech Fraud Detection Real-Time | Financial Services | Streaming features, XGBoost, ONNX inference | Kafka, Faust, XGBoost, Redis, Grafana |
| P04 | Supply Chain Demand Forecasting | Operations | Time-series (Prophet+LSTM), REST API | Flask, Prophet, PyTorch, Postgres, Looker |
| P05 | Sales GTM Playbook & Automation | Sales / GTM | LLM playbooks, CRM integration, A/B testing | LangChain, Mistral, FastAPI, Next.js, Salesforce API |
| P06 | Engineering Productivity AI Copilot | Developer Tools | IDE/LSP integration, code indexing, fine-tuning | LangChain, Tree-sitter, LSP, VS Code |
| P07 | Field Service Optimization & Routing | Operations | VRP optimization, geospatial, mobile | OR-Tools, PostGIS, Redis, React Native |
| P08 | Healthcare Patient Outcome Prediction | Healthcare | HIPAA pipeline, clinical NLP, SHAP | XGBoost, spaCy, Auth0, HL7 FHIR, FastAPI |
| P09 | Marketing Performance Attribution | Marketing / Analytics | Shapley attribution, dbt, multi-touch | dbt, Snowflake, Looker, Google Analytics API |
| P10 | Cinema Revenue Optimization & Pricing | Media & Entertainment | Demand forecasting, dynamic pricing, LLM buzz analysis | LangChain, Mistral, FastAPI, Next.js, Redis |

### Quantum FDE Projects (Q-P01–Q-P12)

| ID | Project | Modality | Quantum Skill | Classical Stack |
|----|---------|----------|---------------|-----------------|
| Q-P01 | Drug Molecule Screening via VQE | Superconducting | VQE, error mitigation, noise modeling | Qiskit, PyTorch, FastAPI, AWS Braket |
| Q-P02 | Rydberg QAOA for Logistics Routing | Neutral-atom | QAOA, Rydberg physics, pulse design | Pulser SDK, JAX, FastAPI, Redis |
| Q-P03 | Photonic Boson Sampling for Materials | Photonic | Boson sampling, KLM theorem, generative models | Perceval SDK, JAX, LangChain, Qdrant |
| Q-P04 | Trapped-Ion Financial Portfolio Opt. | Trapped-ion | Mølmer-Sørensen gates, TKET compilation | TKET/Pytket, Qiskit, FastAPI, Bloomberg API |
| Q-P05 | D-Wave Annealing + ML Supply Chain | Annealing | QUBO formulation, Ising models, LLM alerts | Ocean SDK, LangChain, FastAPI, Qdrant |
| Q-P06 | AI-Assisted Quantum Circuit Calibration | Superconducting | RL for hardware, randomised benchmarking | Qiskit Pulse, Ray, Prometheus, Grafana |
| Q-P07 | Post-Quantum Cryptography Migration | Classical-only | NIST PQC (Kyber/Dilithium), HSM, key lifecycle | liboqs, Vault, LangChain, FastAPI |
| Q-P08 | Variational Quantum Classifier (IoT) | Superconducting | QML, angle encoding, barren plateaus | Qiskit, TKET, PyTorch, ONNX, InfluxDB |
| Q-P09 | SDQC for Privacy-Preserving Drug Discovery | Photonic | Homomorphic encryption, blind computation | Perceval SDK, Microsoft SEAL, RDKit |
| Q-P10 | Tensor Network + ML Circuit Benchmarking | Superconducting | MPS/PEPS, GNNs, tensor contraction | QuTiP, JAX, PyTorch Geometric, Qiskit |
| Q-P11 | Cinema Dynamic Pricing with Quantum Opt. | Annealing | QUBO pricing, LSTM forecasting | Ocean SDK, LangChain, FastAPI, Redis |
| Q-P12 | Multi-Modality Quantum Benchmark Portal | Classical-only | Multi-SDK transpilation, LLM circuit explainer | Qiskit, Cirq, PennyLane, Perceval, Mistral API |

---

## Part F — Estimated Hours to Employable Level

### AI FDE Track

| Skill Cluster | P1 Hours | P2 Hours | P3 Hours | Total |
|---------------|----------|----------|----------|-------|
| LLM / RAG / Prompt Engineering | 80 | 40 | 0 | 120 |
| Full-Stack (React, Next.js, FastAPI, Node.js) | 100 | 30 | 20 | 150 |
| Data & Infra (Postgres, dbt, ETL) | 80 | 50 | 0 | 130 |
| MLOps (Docker, CI/CD, Grafana) | 60 | 30 | 0 | 90 |
| ML Core (XGBoost, sklearn, time-series) | 80 | 40 | 0 | 120 |
| Product & Business Skills | 40 | 20 | 0 | 60 |
| Domain-specific (healthcare, fintech, etc.) | 0 | 30 | 20 | 50 |
| **AI FDE Total** | **~440** | **~240** | **~40** | **~720** |

### Quantum FDE Track (additional hours above AI FDE)

| Skill Cluster | Phase 1 | Phase 2 | Phase 3 | Total |
|---------------|---------|---------|---------|-------|
| Quantum Foundations (theory) | 80 | 0 | 0 | 80 |
| Gate model, VQE, QAOA | 60 | 80 | 0 | 140 |
| NISQ / error mitigation | 20 | 40 | 20 | 80 |
| Modality-specific (Rydberg, photonic, trapped-ion, annealing) | 30 | 80 | 40 | 150 |
| Hybrid loops & quantum MLOps | 20 | 60 | 0 | 80 |
| Quantum SDKs (Qiskit, Pulser, Perceval, Ocean) | 40 | 60 | 0 | 100 |
| Advanced QML / tensor networks / PQC | 0 | 40 | 60 | 100 |
| **Quantum FDE Additional Total** | **~250** | **~360** | **~120** | **~730** |

**Combined Full FDE Stack: ~1,450 hours**

At 3 hours/day: ~16 months. At 6 hours/day (intensive): ~8 months. Tracks overlap significantly — shared classical skills count toward both.

---

## Part G — Candidate Gap Analysis

Gaps flagged `Yes` in the tables above are summarized here by urgency:

### Urgent (block Q-FDE employment)

- Docker / Kubernetes production experience
- GitHub Actions CI/CD production pipelines
- Qiskit (all layers: circuit, Aer, Pulse)
- Quantum state representation & gate model (bra-ket notation)
- VQE & QAOA algorithm design
- NISQ-era error mitigation (ZNE, PEC, mitiq)
- ML for quantum error mitigation (PyTorch + Qiskit Aer)
- Hybrid classical-quantum orchestration loops

### High Priority (needed within 6 months)

- JAX functional ML framework
- Redis production deployment
- Pulser SDK (Pasqal / neutral-atom)
- Perceval SDK (Quandela / photonic)
- QUBO formulation & Ocean SDK (D-Wave)
- LangChain + RAG in quantum context
- Prometheus / Grafana observability
- Prompt engineering for technical / quantum domains

### Medium Priority (Phase 3 specialist)

- Tensor network theory (MPS/PEPS, QuTiP)
- Graph neural networks (PyTorch Geometric)
- NIST PQC standards (liboqs)
- Homomorphic encryption (Microsoft SEAL)
- RL for hardware control (Ray/RLlib)
- Boson sampling complexity theory
- Barren plateau mitigation

### Strengths (no gap — leverage immediately)

- PyTorch production patterns (ESA project)
- Flask / FastAPI REST API design (ESA project)
- Optical tweezer physics (McGill lab)
- Laser cooling & AMO physics (Institut d'Optique)
- Fiber optics & photonic principles (Institut d'Optique)
- Signal processing & instrumentation (DGA / McGill)
- Eigendecomposition & linear algebra (Institut d'Optique coursework)
- LSTM time-series (signal processing background)
- Technical documentation & developer UX (INSEAD / startup)

---

*Sources: fde_ai_skills.csv · fde_ai_tools.csv · fde_ai_projects.csv · fde_ai_bridge.csv · fde_quantum_skills.csv · fde_quantum_tools.csv · fde_quantum_projects.csv · fde_quantum_bridge.csv · Stack Overflow Developer Survey 2025 · IBM Quantum Learning · Pasqal Documentation · Quandela Documentation · Anthropic Docs · NIST PQC Standards*
