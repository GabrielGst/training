# Skills & Tools Bridge

> Cross-reference of every skill and tool across both tracks — FDE/AI (10 projects) and Quantum (12 projects).
> Use this to plan study sessions, identify overlaps, and track coverage.
> Source: `doc/roadmap/resources/fde_ai_bridge.csv` and `doc/roadmap/resources/fde_quantum_bridge.csv`

---

## How to read this document

Each section lists the skills or tools for one track, with the projects they appear in. Cells marked **[gap]** identify areas where honest self-assessment flags a learning deficit. Cross-track entries appear in both sections — one column per track — to make overlap visible at a glance.

---

## Part 1 — FDE / AI Track

### 1.1 Skills

| ID | Skill | Category | Projects |
|----|-------|----------|---------|
| SK01 | Requirements Discovery and Scoping Workshops | Product & Business | P01, P04, P05, P06, P07, P08, P09, P10 |
| SK02 | RAG Architecture Design | AI/ML & LLM | P01, P02, P06, P08 |
| SK03 | Prompt Engineering and System Design | AI/ML & LLM | P01, P02, P03, P04, P05, P06, P07, P09, P10 |
| SK04 | API Design and Contract Management | Full-Stack & APIs | P01–P10 (all) |
| SK05 | Full-Stack Application Development | Full-Stack & APIs | P01–P10 (all) |
| SK06 | Database Schema Design and Query Optimization | Data & Infra | P01–P10 (all) |
| SK07 | Data Security and Privacy Compliance | Enterprise Integration | P01, P08 |
| SK08 | Observability and Production Debugging | MLOps/LLMOps | P01–P10 (all) |
| SK09 | Cross-functional Stakeholder Engagement | Product & Business | P01, P04, P05, P08 |
| SK10 | Business Impact and ROI Quantification | Product & Business | P01, P04, P05, P09, P10 |
| SK11 | Structured Output Extraction and Parsing | AI/ML & LLM | P01, P02 |
| SK12 | Customer Feedback Loops and Iteration | Product & Business | P01, P02, P05, P06, P10 |
| SK13 | Agentic Workflows and Tool Use | AI/ML & LLM | P02, P07 |
| SK14 | Semantic Search and Vector Store Optimization | Data & Infra | P02 |
| SK15 | Real-time Integration and Event Streaming | Enterprise Integration | P02 |
| SK16 | Feature Engineering and Model Architecture | AI/ML & LLM | P03, P04, P09, P10 |
| SK17 | Model Evaluation and Ablation Testing | AI/ML & LLM | P03, P04, P09, P10 |
| SK18 | Feedback Loop Design and Active Learning | MLOps/LLMOps | P03, P04, P05, P10 |
| SK19 | Pipeline Orchestration and Automation | MLOps/LLMOps | P03, P04, P08, P10 |
| SK20 | Cost Optimization and Resource Allocation | Data & Infra | P03, P04, P06, P07, P09, P10 |
| SK21 | Time Series Forecasting and Trend Analysis | AI/ML & LLM | P04, P09 |
| SK22 | Experimentation and A/B Testing Frameworks | Product & Business | P05, P09, P10 |
| SK23 | Data Privacy and Compliance at Scale | Enterprise Integration | P05 |
| SK24 | IDE Integration and Developer UX | Full-Stack & APIs | P06 |
| SK25 | Context Window Management and Prompt Optimization | AI/ML & LLM | P06, P07 |
| SK26 | Codebase Indexing and Semantic Search | AI/ML & LLM | P06 |
| SK27 | Geospatial Data and Location Services | Data & Infra | P07 |
| SK28 | Mobile App Integration and Real-time Sync | Full-Stack & APIs | P07 |
| SK29 | HIPAA and Healthcare Compliance | Enterprise Integration | P08 |
| SK30 | Voice/Audio Processing and Transcription | Full-Stack & APIs | P08 |
| SK31 | Statistical Modeling and Causal Inference | AI/ML & LLM | P10 |
| SK32 | Marketing Analytics and Attribution | Product & Business | P09 |
| SK33 | Executive Reporting and Data Storytelling | Product & Business | P09 |
| SK34 | Revenue Management and Pricing Strategy | Product & Business | P10 |
| SK35 | Business Model Innovation | Product & Business | P10 |

### 1.2 Tools

| ID | Tool | Category | Projects |
|----|------|----------|---------|
| TL01 | LangChain | AI/ML & LLM | P01, P02, P05, P06, P08, P10 |
| TL02 | Mistral API | AI/ML & LLM | P01, P02, P05, P06, P08, P10 |
| TL03 | pgvector | Data & Infra | P01 |
| TL04 | Postgres | Data & Infra | P01, P03, P04, P05, P06, P07, P08, P09, P10 |
| TL05 | FastAPI | Full-Stack & APIs | P01, P05, P08, P10 |
| TL06 | Flask | Full-Stack & APIs | P04, P07, P09 |
| TL07 | Whisper | AI/ML & LLM | P02 |
| TL08 | AWS Lambda | Data & Infra | P01, P10 |
| TL09 | Next.js | Full-Stack & APIs | P01, P05, P06, P10 |
| TL10 | Qdrant | Data & Infra | P02 |
| TL11 | MongoDB | Data & Infra | P02 |
| TL12 | S3 | Data & Infra | P01, P04, P05, P06, P07, P09, P10 |
| TL13 | Express.js | Full-Stack & APIs | P02, P07, P09 |
| TL14 | React | Full-Stack & APIs | P01 |
| TL15 | Docker | Data & Infra | P02 |
| TL16 | GCP Cloud Run | Data & Infra | P02 |
| TL17 | Pub/Sub | Data & Infra | P02 |
| TL18 | Kafka | Data & Infra | P03 |
| TL19 | Faust | Data & Infra | P03 |
| TL20 | XGBoost | AI/ML & LLM | P03, P08 |
| TL22 | ONNX Runtime | MLOps/LLMOps | P03 |
| TL23 | Redis | Data & Infra | P03, P07, P08, P10 |
| TL24 | Grafana | MLOps/LLMOps | P02, P03, P08 |
| TL25 | PagerDuty | MLOps/LLMOps | P03 |
| TL26 | GitHub Actions | MLOps/LLMOps | P01, P04, P06, P09, P10 |
| TL27 | dbt | Data & Infra | P03, P04, P09 |
| TL28 | SHAP | MLOps/LLMOps | P03, P08 |
| TL29 | Stripe | Product & Business | P05, P10 |
| TL30 | SendGrid | Enterprise Integration | P05 |
| TL31 | Make | Enterprise Integration | P05 |
| TL32 | Pinecone | Data & Infra | P01 |
| TL33 | Zendesk API | Enterprise Integration | P02 |
| TL34 | Prophet | AI/ML & LLM | P04 |
| TL35 | PyTorch | AI/ML & LLM | P04 |
| TL36 | Salesforce API | Enterprise Integration | P05 |
| TL37 | Looker | Product & Business | P04, P08, P09 |
| TL38 | Tree-sitter | Full-Stack & APIs | P06 |
| TL39 | LSP | Full-Stack & APIs | P06 |
| TL40 | VS Code | Full-Stack & APIs | P06 |
| TL41 | OR-Tools | AI/ML & LLM | P07 |
| TL42 | PostGIS | Data & Infra | P07 |
| TL43 | Twilio | Enterprise Integration | P07, P10 |
| TL44 | spaCy | AI/ML & LLM | P08 |
| TL45 | Auth0 | Enterprise Integration | P08 |
| TL46 | HL7 FHIR | Enterprise Integration | P08 |
| TL47 | Snowflake | Data & Infra | P09 |
| TL48 | Google Analytics API | Enterprise Integration | P09 |
| TL49 | React Native | Full-Stack & APIs | P07 |
| TL50 | Slack API | Enterprise Integration | P05 |
| TL52 | Google Maps API | Enterprise Integration | P07 |

### 1.3 Project index

| ID | Project | Domain | Key skills | Key tools |
|----|---------|--------|-----------|-----------|
| P01 | VC Due Diligence AI Analyst | Venture Capital | SK01, SK02, SK03, SK04, SK05, SK06, SK07, SK08, SK09, SK10, SK11, SK12 | LangChain, Mistral API, pgvector, Postgres, FastAPI, Next.js, S3, Pinecone, GitHub Actions |
| P02 | Customer Support Multimodal Triage | Customer Support | SK02, SK03, SK08, SK11, SK12, SK13, SK14, SK15 | LangChain, Mistral API, Whisper, Qdrant, MongoDB, Express.js, Docker, GCP Cloud Run, Grafana |
| P03 | Fintech Fraud Detection Real-Time | Financial Services | SK03, SK06, SK08, SK16, SK17, SK18, SK19 | Kafka, Faust, XGBoost, ONNX Runtime, Redis, Grafana, dbt, SHAP, Postgres |
| P04 | Supply Chain Demand Forecasting | Supply Chain | SK03, SK05, SK06, SK08, SK10, SK16, SK17, SK18, SK19, SK20, SK21 | Flask, Prophet, PyTorch, Postgres, S3, Looker, GitHub Actions, dbt |
| P05 | Sales GTM Playbook and Automation | Sales | SK03, SK04, SK05, SK06, SK08, SK10, SK12, SK18, SK22, SK23 | LangChain, Mistral API, Postgres, FastAPI, Next.js, S3, Stripe, SendGrid, Make, Salesforce API, Slack API |
| P06 | Engineering Productivity AI Copilot | Developer Tools | SK03, SK04, SK05, SK06, SK08, SK12, SK20, SK24, SK25, SK26 | LangChain, Mistral API, Postgres, Next.js, S3, GitHub Actions, Tree-sitter, LSP, VS Code |
| P07 | Field Service Optimization and Routing | Field Services | SK03, SK04, SK05, SK06, SK08, SK20, SK25, SK27, SK28 | Postgres, Flask, S3, Redis, OR-Tools, PostGIS, Twilio, React Native, Google Maps API, Express.js |
| P08 | Healthcare Patient Outcome Prediction | Healthcare | SK03, SK04, SK05, SK06, SK07, SK08, SK16, SK17, SK19, SK20, SK29, SK30 | LangChain, Mistral API, FastAPI, XGBoost, Redis, Grafana, SHAP, Looker, spaCy, Auth0, HL7 FHIR, Postgres |
| P09 | Marketing Performance Attribution | Marketing | SK03, SK04, SK05, SK06, SK08, SK10, SK12, SK16, SK17, SK19, SK20, SK21, SK22, SK32, SK33 | Postgres, Flask, S3, GitHub Actions, dbt, Looker, Snowflake, Google Analytics API, Express.js |
| P10 | Cinema Revenue Optimization and Pricing | Media & Entertainment | SK03, SK04, SK05, SK06, SK08, SK10, SK12, SK16, SK17, SK18, SK19, SK20, SK22, SK31, SK34, SK35 | LangChain, Mistral API, Postgres, FastAPI, Next.js, S3, Redis, GitHub Actions, Stripe, Twilio, AWS Lambda |

---

## Part 2 — Quantum / FDE Track

### 2.1 Skills

#### Phase 1 — Theory foundations (all modalities)

| ID | Skill | Category | Gap | Projects |
|----|-------|----------|-----|---------|
| SK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notation) | Physics & Mathematics | yes | P01–P10, P12 |
| SK02 | Quantum Measurement Theory (Projective Measurements, POVMs & Born Rule) | Physics & Mathematics | yes | P01–P10, P12 |
| SK03 | Quantum Decoherence & Relaxation Theory (T1/T2 Times, Lindblad) | Physics & Mathematics | yes | P01, P04, P06, P08 |
| SK04 | Quantum Gate Model & Universal Gate Sets (Clifford+T, Gate Depth) | Quantum Computing | yes | P01, P02, P04, P06, P07, P08, P10 |
| SK05 | Complex Vector Spaces & Inner Products (Tensor Products, Kronecker) | Physics & Mathematics | yes | P01, P04, P06, P08, P10 |
| SK06 | Eigendecomposition & Matrix Decompositions (SVD, QR, Spectral) | Physics & Mathematics | yes | P01, P04, P06, P08, P10 |
| SK07 | Quantum Information Theory (von Neumann Entropy, Mutual Information) | Physics & Mathematics | yes | P01 |
| SK08 | Quantum Error Correction Theory (Stabiliser Formalism, CSS Codes) | Quantum Computing | yes | P01 |
| SK09 | NISQ-Era Limitations & Error Mitigation Strategies | Quantum Computing | yes | P01, P08 |
| SK10 | Variational Quantum Eigensolver (VQE) Algorithm | Quantum Computing | yes | P01 |

#### Phase 1 — Modality-specific physics

| ID | Skill | Category | Gap | Modality | Projects |
|----|-------|----------|-----|----------|---------|
| SK11 | Rydberg Atom Physics & Dipole Blockade | Physics & Mathematics | yes | neutral-atom | P02 |
| SK12 | Optical Tweezer Trap Design & Manipulation | Physics & Mathematics | partial | neutral-atom | P02 |
| SK13 | Laser Cooling (Doppler & Sub-Doppler Mechanisms) | Physics & Mathematics | partial | neutral-atom | P02 |
| SK14 | QAOA Algorithm & Circuit Design | Quantum Computing | yes | neutral-atom | P02 |
| SK15 | Constraint Embedding for QUBO & Ising Models | Quantum Computing | yes | neutral-atom, annealing | P02, P05, P11 |
| SK16 | Photonic Quantum Optics (Coherent, Fock & Squeezed States) | Physics & Mathematics | yes | photonic | P03, P09 |
| SK17 | Beam Splitter Unitaries & Hong-Ou-Mandel Effect | Physics & Mathematics | yes | photonic | P03, P09 |
| SK18 | Photon Indistinguishability & KLM Theorem | Physics & Mathematics | yes | photonic | P03, P09 |
| SK19 | Boson Sampling & Computational Complexity Theory | Physics & Mathematics | yes | photonic | P03, P09 |
| SK20 | Quantum Fourier Transform & Phase Estimation | Physics & Mathematics | yes | photonic | P03, P09 |
| SK21 | Single-Photon Source Engineering & Characterisation | Physics & Mathematics | yes | photonic | P03, P09 |
| SK22 | Trapped-Ion Physics (Paul & Penning Traps, Laser-Matter Interaction) | Physics & Mathematics | yes | trapped-ion | P04 |
| SK23 | Mølmer–Sørensen Gate Mechanism (Entangling Gate Design) | Physics & Mathematics | yes | trapped-ion | P04 |
| SK29 | Adiabatic Theorem & Quantum Tunnelling | Physics & Mathematics | yes | annealing | P05, P07, P11 |
| SK30 | QUBO & Ising Model Formulation | Quantum Computing | yes | annealing | P05, P07, P11 |
| SK31 | Spin Glass Physics & Adiabatic Evolution | Physics & Mathematics | yes | annealing | P05, P11 |

#### Phase 2 — Quantum-AI hybrid skills

| ID | Skill | Category | Gap | Projects |
|----|-------|----------|-----|---------|
| SK24 | ML for Quantum Error Mitigation (Neural Networks for Noise) | Quantum-AI Hybrid | yes | P01–P10, P12 |
| SK25 | Hybrid Classical-Quantum Loops & Orchestration | Quantum-AI Hybrid | yes | P01–P10, P12 |
| SK26 | PyTorch Production Patterns (Distributed Training, Model Serving) | Quantum-AI Hybrid | partial | P01–P10, P12 |
| SK28 | AI-Assisted Circuit Optimisation (NN-Guided Transpilation) | Quantum-AI Hybrid | yes | P02, P05, P07 |
| SK29 | Real-Time Inference Acceleration & Latency Optimisation | AI/ML & LLM | partial | P02, P07 |
| SK41 | Variational Quantum Machine Learning (QML) | Quantum-AI Hybrid | yes | P04 |
| SK42 | Prompt Engineering & Chain-of-Thought Reasoning | AI/ML & LLM | no | P05, P07, P11, P12 |
| SK43 | Retrieval-Augmented Generation (RAG) Architecture | AI/ML & LLM | no | P05, P07, P11, P12 |
| SK44 | LLM Output Parsing & Safety | AI/ML & LLM | no | P05, P07, P11, P12 |
| SK45 | Semantic Search & Vector Embeddings | AI/ML & LLM | no | P07, P12 |
| SK50 | Reinforcement Learning for Hardware Control | AI/ML & LLM | yes | P06 |
| SK55 | Variational QML Circuits | Quantum-AI Hybrid | yes | P08 |
| SK56 | Angle Encoding for Feature Maps | Quantum-AI Hybrid | yes | P08 |
| SK57 | Barren Plateaus & Variational Circuit Optimisation | Physics & Mathematics | yes | P08 |
| SK60 | Privacy-Preserving Quantum Protocols (Blind Computation) | Quantum-AI Hybrid | yes | P09 |
| SK64 | Graph Neural Networks (GNNs) for Quantum Circuits | AI/ML & LLM | yes | P10 |
| SK68 | LSTM Time-Series Forecasting | AI/ML & LLM | partial | P11 |

#### Phase 2 — Engineering & MLOps skills

| ID | Skill | Category | Gap | Projects |
|----|-------|----------|-----|---------|
| SK27 | REST API Design & FastAPI | Full-Stack & APIs | no | P01–P12 |
| SK32 | ML for Quantum Error Mitigation | Quantum-AI Hybrid | yes | P01–P12 |
| SK33 | SQL Data Modelling (PostgreSQL, Schema Design) | Data & Infra | no | P01–P12 |
| SK34 | Container Orchestration (Docker & Kubernetes) | MLOps/LLMOps | yes | P01–P12 |
| SK35 | CI/CD & GitHub Actions | MLOps/LLMOps | yes | P01–P12 |
| SK36 | Distributed Systems & Caching (Redis, Memcached) | Data & Infra | yes | P02 |
| SK37 | Cache-Aware Algorithm Design & Optimisation | Data & Infra | yes | P02 |
| SK39 | Vector Database Integration (Qdrant/Weaviate) | Data & Infra | yes | P03, P09 |
| SK51 | Randomised Benchmarking Protocol Design | Quantum Computing | yes | P06 |
| SK52 | Distributed ML Training (Ray/Spark, Parameter Servers) | MLOps/LLMOps | yes | P06 |
| SK53 | MLOps & Continuous Retraining Pipelines | MLOps/LLMOps | yes | P06 |
| SK54 | Prometheus/Grafana Monitoring & Alerting | MLOps/LLMOps | yes | P06, P07 |
| SK65 | Classical Tensor Contraction & opt_einsum | Quantum Computing | yes | P10 |
| SK66 | Quantum Circuit Benchmarking & Metrics | Quantum Computing | yes | P10 |
| SK67 | High-Performance Computing (HPC) Optimization | Data & Infra | yes | P10 |

#### Phase 3 — Specialised domain skills

| ID | Skill | Category | Gap | Projects |
|----|-------|----------|-----|---------|
| SK38 | Generative Models (VAE, Diffusion) | AI/ML & LLM | yes | P03 |
| SK40 | Financial Domain Integration (Risk Metrics, Portfolio Theory) | Enterprise Integration | partial | P04 |
| SK46 | NIST PQC Standards (Kyber, Dilithium, Falcon) | Enterprise Integration | yes | P07 |
| SK47 | Cryptographic Protocol Design & Implementation | Enterprise Integration | yes | P07 |
| SK48 | Key Lifecycle Management | Enterprise Integration | yes | P07 |
| SK49 | Hardware Security Module (HSM) Integration | Enterprise Integration | yes | P07 |
| SK53 | MLOps & Continuous Retraining Pipelines | MLOps/LLMOps | yes | P06 |
| SK58 | Homomorphic Encryption Theory & Implementation | Enterprise Integration | yes | P09 |
| SK59 | Secure Multi-Party Computation (MPC) | Enterprise Integration | yes | P09 |
| SK61 | Cryptographic Circuit Design | Enterprise Integration | yes | P09 |
| SK62 | Regulatory Compliance (FDA 21 CFR Part 11, EMA GMP) | Enterprise Integration | yes | P09 |
| SK63 | Tensor Network Theory (MPS, PEPS, MERA) | Quantum Computing | yes | P10 |
| SK69 | Inventory Management & Constraint Optimization | Enterprise Integration | partial | P11 |
| SK70 | Revenue Management & Dynamic Pricing Theory | Enterprise Integration | partial | P11 |
| SK71 | Technical Documentation & Developer Experience | Product & Business | no | P12 |
| SK72 | Benchmark Design & Evaluation Metrics | Quantum Computing | yes | P12 |
| SK73 | Multi-SDK Integration & Circuit Transpilation | Quantum Computing | yes | P12 |
| SK74 | Community & Open-Source Engagement | Product & Business | no | P12 |

### 2.2 Tools

| ID | Tool | Category | Gap | Modality | Projects |
|----|------|----------|-----|----------|---------|
| TL01 | Qiskit | Quantum SDK | yes | superconducting | P01, P04, P06, P08, P12 |
| TL02 | Qiskit Aer | Quantum Simulation | yes | superconducting | P01, P06, P08 |
| TL03 | PyTorch | AI/ML & LLM | no | classical | P01–P10 |
| TL04 | FastAPI | Full-Stack & APIs | no | classical | P01–P12 |
| TL05 | PostgreSQL | Data & Infra | no | classical | P01–P11 |
| TL06 | Docker | MLOps/LLMOps | yes | classical | P01–P12 |
| TL07 | GitHub Actions | MLOps/LLMOps | yes | classical | P01–P12 |
| TL08 | AWS Braket | Quantum SDK | yes | all | P01, P02, P08 |
| TL09 | Pulser SDK | Quantum SDK | yes | neutral-atom | P02 |
| TL10 | JAX | AI/ML & LLM | yes | classical | P02, P03, P04, P05, P10 |
| TL11 | Redis | Data & Infra | yes | classical | P02, P05, P08, P11 |
| TL12 | Perceval SDK | Quantum SDK | yes | photonic | P03, P09, P12 |
| TL13 | LangChain | AI/ML & LLM | yes | classical | P03, P05, P07, P11, P12 |
| TL14 | Qdrant | Data & Infra | yes | classical | P03, P05, P09, P12 |
| TL15 | LlamaIndex | AI/ML & LLM | yes | classical | P03, P09, P12 |
| TL16 | TKET | Quantum SDK | yes | trapped-ion | P04 |
| TL17 | Pytket | Quantum SDK | yes | trapped-ion | P04 |
| TL18 | Kubernetes | MLOps/LLMOps | yes | classical | P04, P06, P07, P08, P10 |
| TL19 | Ocean SDK (D-Wave) | Quantum SDK | yes | annealing | P05, P11 |
| TL20 | Scikit-learn | AI/ML & LLM | no | classical | P05 |
| TL21 | Qiskit Pulse | Quantum SDK | yes | superconducting | P06 |
| TL22 | Ray (Distributed Computing) | MLOps/LLMOps | yes | classical | P06 |
| TL23 | Prometheus | MLOps/LLMOps | yes | classical | P06, P07 |
| TL24 | Grafana | MLOps/LLMOps | yes | classical | P06 |
| TL25 | liboqs (OpenQuantumSafe) | Quantum SDK | yes | classical-only | P07 |
| TL26 | Mistral API | AI/ML & LLM | yes | classical | P05, P07, P11, P12 |
| TL27 | Vault (HashiCorp) | Data & Infra | yes | classical | P07 |
| TL28 | ONNX | AI/ML & LLM | yes | classical | P08 |
| TL29 | TensorFlow Lite | AI/ML & LLM | yes | classical | P08 |
| TL30 | InfluxDB | Data & Infra | yes | classical | P08 |
| TL31 | Microsoft SEAL | Quantum SDK | yes | classical-only | P09 |
| TL32 | RDKit | AI/ML & LLM | yes | classical | P09 |
| TL33 | TensorFlow Encrypted | AI/ML & LLM | yes | classical | P09 |
| TL34 | QuTiP | Quantum Simulation | yes | all | P10 |
| TL35 | PyTorch Geometric | AI/ML & LLM | yes | classical | P10 |
| TL36 | Flask | Full-Stack & APIs | no | classical | P10 |
| TL37 | Cinema POS API Wrapper | Enterprise Integration | yes | classical | P11 |
| TL38 | Cirq (Google) | Quantum SDK | yes | superconducting | P12 |
| TL39 | PennyLane (Xanadu) | Quantum SDK | yes | photonic | P12 |
| TL40 | React/Next.js | Full-Stack & APIs | no | classical | P12 |
| TL41 | CUDA-Q (NVIDIA) | Quantum SDK | yes | all | P03 |

### 2.3 Project index

| ID | Project | Domain | Modality | Synergy vector |
|----|---------|--------|----------|----------------|
| P01 | Quantum-Enhanced Drug Molecule Screening via VQE | Pharma & Life Sciences | superconducting | Quantum-enhanced optimisation |
| P02 | Rydberg Neutral-Atom QAOA for Logistics Route Optimisation | Logistics & Supply Chain | neutral-atom | Quantum-enhanced optimisation |
| P03 | Photonic Quantum Sampling for Materials Discovery | Materials Science | photonic | Quantum simulation for AI training data |
| P04 | Trapped-Ion Quantum Simulation for Financial Portfolio Optimisation | Finance & Risk | trapped-ion | Quantum-enhanced optimisation |
| P05 | D-Wave Annealing + ML for Supply Chain Disruption Prediction | Enterprise AI | annealing | AI-assisted error mitigation |
| P06 | AI-Assisted Quantum Circuit Calibration for Multi-Qubit Gates | Quantum Hardware | superconducting | AI-assisted error mitigation |
| P07 | Post-Quantum Cryptography Migration with AI-Powered Key Management | Cybersecurity | classical-only | Post-quantum cryptography + AI |
| P08 | Variational Quantum Classifier for Anomaly Detection in Sensor Networks | IoT & Industrial | superconducting | QML / Variational circuits |
| P09 | Secure Delegated Quantum Computation (SDQC) for Privacy-Preserving Drug Discovery | Pharma & Biotech | photonic | Secure delegated quantum computation |
| P10 | Tensor Network Classical Simulation + ML for Quantum Circuit Benchmarking | Quantum Software | superconducting | Quantum-enhanced optimisation |
| P11 | Cinema Demand Forecasting & Dynamic Pricing with Quantum Optimisation | Media & Entertainment | annealing | Quantum-enhanced optimisation |
| P12 | Multi-Modality Quantum Benchmark Aggregator & LLM-Powered Circuit Explainer | Quantum Education | classical-only | none |

---

## Part 3 — Cross-track overlap

Skills and tools that appear in **both** the FDE/AI track and the Quantum track.

### Shared skills

| Skill area | FDE/AI | Quantum |
|-----------|--------|---------|
| Prompt engineering / RAG | SK03, SK02, SK11 | SK42, SK43, SK44 |
| REST API design | SK04 | SK27 |
| Full-stack development | SK05 | SK34 (Docker/k8s) |
| Database schema design | SK06 | SK33 |
| Observability & monitoring | SK08 | SK54 |
| Time-series forecasting | SK21 | SK68 |
| Revenue management | SK34 | SK70 |
| CI/CD pipelines | SK08 (via observability) | SK35 |
| Vector databases | SK14, SK26 | SK39 |

### Shared tools

| Tool | FDE/AI ID | Quantum ID | Notes |
|------|-----------|------------|-------|
| Postgres / PostgreSQL | TL04 | TL05 | Same database, different IDs — functionally identical |
| FastAPI | TL05 | TL04 | Same framework, different IDs — same technology |
| Docker | TL15 | TL06 | Same runtime |
| GitHub Actions | TL26 | TL07 | Same CI/CD platform |
| PyTorch | TL35 | TL03 | Same framework; FDE uses via Prophet+LSTM, Quantum uses for hybrid loops |
| Redis | TL23 | TL11 | Same in-memory store |
| Grafana | TL24 | TL24 | Identical |
| Mistral API | TL02 | TL26 | Same API provider |
| LangChain | TL01 | TL13 | Same framework |
| Qdrant | TL10 | TL14 | Same vector DB |
| React/Next.js | TL09, TL14 | TL40 | Same frontend stack |

> Every hour spent on Postgres, FastAPI, Docker, GitHub Actions, or PyTorch counts for both tracks simultaneously. These are the highest-leverage training targets.
