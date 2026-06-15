# Quantum Projects Catalogue

> Source: `fde_quantum_projects.csv`. All 12 FDE/Quantum portfolio projects.
> Project IDs are prefixed QP to avoid collision with AI project IDs (QP01–QP12).
> All projects belong to the `hpc-quantum` track.

---

## QP01 (P01) — Quantum-Enhanced Drug Molecule Screening via VQE

**Domain:** Pharma & Life Sciences  
**Quantum modality:** superconducting  
**Phase:** Phase 2A  
**Quantum-AI synergy:** Quantum-enhanced optimisation  
**Skill IDs:** SK01,SK02,SK03,SK04,SK05,SK06,SK07,SK08,SK09,SK10,SK24,SK25,SK26,SK27,SK32,SK33,SK34,SK35  
**Tool IDs:** TL01,TL02,TL03,TL04,TL05,TL06,TL07,TL08  

### Business Problem
Pharmaceutical research pipelines screen millions of candidate molecules, consuming weeks of HPC time. Current classical methods achieve limited chemical accuracy at scale.

### Solution Architecture
Deploy a hybrid VQE+PyTorch pipeline integrating with IBM Quantum cloud, combining variational ansatz tuning with ML-based error mitigation. Candidate constructs the classical orchestration layer (REST API, job queuing, result aggregation) while leveraging pre-built VQE kernels.

### Tech Stack
Qiskit, Qiskit Aer, PyTorch, FastAPI, PostgreSQL, AWS Braket, Docker, GitHub Actions

### Infrastructure
IBM Quantum cloud QPU access or AWS Braket; PostgreSQL for metadata; containerised classical backend on AWS Lambda; CI/CD via GitHub Actions for circuit parameter updates.

### Integration Targets
Pharma LIMS (electronic lab notebook integration), molecular simulation software (GROMACS output ingestion), HPC job schedulers (SLURM).

### Skill Gaps to Close
PyTorch production patterns, VQE algorithm customisation, noise-aware circuit design, NISQ-era limitations management.

### Portfolio Value
Demonstrates FDE capability: translates vague molecular optimisation problem into concrete VQE+AI architecture. Optical tweezer background (precision instrumentation) maps to quantum state preparation and calibration. Shows full-stack from QPU to REST endpoint.

### Skills Required
| Skill ID | Skill Name | Phase |
|----------|------------|-------|
| QSK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notat | Phase 1 — Foundation |
| QSK02 | Quantum Measurement Theory (Projective Measurements, POVMs & | Phase 1 — Foundation |
| QSK03 | Quantum Decoherence & Relaxation Theory (T1/T2 Times, Lindbl | Phase 2 — FDE Track |
| QSK04 | Quantum Gate Model & Universal Gate Sets (Clifford+T, Gate D | Phase 1 — Foundation |
| QSK05 | Complex Vector Spaces & Inner Products (Tensor Products, Kro | Phase 1 — Foundation |
| QSK06 | Eigendecomposition & Matrix Decompositions (SVD, QR, Spectra | Phase 1 — Foundation |
| QSK07 | Quantum Information Theory (von Neumann Entropy, Mutual Info | Phase 2 — FDE Track |
| QSK08 | Quantum Error Correction Theory (Stabiliser Formalism, CSS C | Phase 3 — Quantum-AI |
| QSK09 | NISQ-Era Limitations & Error Mitigation Strategies | Phase 2 — FDE Track |
| QSK10 | Variational Quantum Eigensolver (VQE) Algorithm | Phase 2 — FDE Track |
| QSK24 | ML for Quantum Error Mitigation (Neural Networks for Noise C | Phase 2 — FDE Track |
| QSK25 | Hybrid Classical-Quantum Loops & Orchestration | Phase 2 — FDE Track |
| QSK26 | PyTorch Production Patterns (Distributed Training, Model Ser | Phase 2 — FDE Track |
| QSK27 | REST API Design & FastAPI | Phase 1 — Foundation |
| QSK32 | Adiabatic Theorem & Quantum Tunnelling | Phase 2 — FDE Track |
| QSK33 | SQL Data Modelling (PostgreSQL, Schema Design) | Phase 1 — Foundation |
| QSK34 | Container Orchestration (Docker & Kubernetes) | Phase 1 — Foundation |
| QSK35 | CI/CD & GitHub Actions (Automated Testing & Deployment) | Phase 1 — Foundation |

---

## QP02 (P02) — Rydberg Neutral-Atom QAOA for Logistics Route Optimisation

**Domain:** Logistics & Supply Chain  
**Quantum modality:** neutral-atom  
**Phase:** Phase 2B  
**Quantum-AI synergy:** Quantum-enhanced optimisation  
**Skill IDs:** SK01,SK02,SK04,SK11,SK12,SK13,SK14,SK15,SK28,SK29,SK30,SK31,SK32,SK35,SK36,SK37  
**Tool IDs:** TL09,TL10,TL04,TL11,TL05,TL06,TL07,TL08  

### Business Problem
Last-mile delivery networks with 500+ stops require combinatorial optimisation; classical metaheuristics stall at scale. Logistics operators need sub-second route updates during peak demand.

### Solution Architecture
Architect a Pulser-based QAOA circuit targeting Rydberg blockade on Pasqal hardware. Candidate designs the problem embedding (vehicle constraints → QUBO), orchestrates Pulser pulse sequences, and builds a real-time REST wrapper that accepts live delivery requests and returns optimised routes within SLA.

### Tech Stack
Pulser SDK, JAX, FastAPI, Redis, Postgres, Docker, GitHub Actions, Pasqal cloud API

### Infrastructure
Pasqal's remote Rydberg hardware accessed via cloud API; Redis for real-time route cache; Postgres for historical performance metrics; edge deployment on logistics partner's servers.

### Integration Targets
Route planning software (OSRM, VROOM), fleet tracking systems (Samsara, Geotab), ERP demand forecasting modules.

### Skill Gaps to Close
Pulser SDK mastery, Rydberg atom physics deep-dive, QAOA circuit design for constrained optimisation, real-time inference optimisation.

### Portfolio Value
Core Pasqal/Quandela FDE skill: demonstrates neutral-atom hardware intuition and problem-to-pulse translation. Optical tweezers → Rydberg atoms (same family, laser control). Shows ability to ship production quantum+classical hybrid under tight SLA.

### Skills Required
| Skill ID | Skill Name | Phase |
|----------|------------|-------|
| QSK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notat | Phase 1 — Foundation |
| QSK02 | Quantum Measurement Theory (Projective Measurements, POVMs & | Phase 1 — Foundation |
| QSK04 | Quantum Gate Model & Universal Gate Sets (Clifford+T, Gate D | Phase 1 — Foundation |
| QSK11 | Rydberg Atom Physics & Dipole Blockade | Phase 2 — FDE Track |
| QSK12 | Optical Tweezer Trap Design & Manipulation | Phase 1 — Foundation |
| QSK13 | Laser Cooling (Doppler & Sub-Doppler Mechanisms) | Phase 1 — Foundation |
| QSK14 | QAOA (Quantum Approximate Optimisation Algorithm) & Circuit  | Phase 2 — FDE Track |
| QSK15 | Constraint Embedding for QUBO & Ising Models | Phase 2 — FDE Track |
| QSK28 | AI-Assisted Circuit Optimisation (Neural Network-Guided Tran | Phase 2 — FDE Track |
| QSK29 | Real-Time Inference Acceleration & Latency Optimisation | Phase 2 — FDE Track |
| QSK30 | QUBO & Ising Model Formulation | Phase 2 — FDE Track |
| QSK31 | Spin Glass Physics & Adiabatic Evolution | Phase 2 — FDE Track |
| QSK32 | Adiabatic Theorem & Quantum Tunnelling | Phase 2 — FDE Track |
| QSK35 | CI/CD & GitHub Actions (Automated Testing & Deployment) | Phase 1 — Foundation |
| QSK36 | Distributed Systems & Caching (Redis, Memcached) | Phase 2 — FDE Track |
| QSK37 | Cache-Aware Algorithm Design & Optimisation | Phase 2 — FDE Track |

---

## QP03 (P03) — Photonic Quantum Sampling for Materials Discovery (Boson Sampling)

**Domain:** Materials Science & Deep Tech  
**Quantum modality:** photonic  
**Phase:** Phase 2C  
**Quantum-AI synergy:** Quantum simulation for AI training data  
**Skill IDs:** SK01,SK02,SK16,SK17,SK18,SK19,SK20,SK21,SK24,SK25,SK26,SK27,SK32,SK33,SK34,SK38,SK39  
**Tool IDs:** TL12,TL10,TL04,TL13,TL14,TL15,TL04,TL06,TL07  

### Business Problem
Materials chemists perform expensive lab experiments to identify novel crystal structures; classical simulators cannot model photonic scattering signatures at sufficient fidelity. Boson sampling offers exponential speedup for sampling exotic material properties.

### Solution Architecture
Leverage Quandela's Perceval SDK to design and execute boson sampling circuits on photonic hardware (or emulation). Build an AI pipeline that ingests boson sampling output, trains a generative model to interpolate sampled distributions, and predicts material properties for unseen crystal configurations.

### Tech Stack
Perceval SDK, PyTorch, JAX, LangChain, Qdrant (vector DB), FastAPI, Docker, CUDA-Q

### Infrastructure
Quandela cloud access for photonic QPU or high-fidelity emulator; Qdrant vector database for embedding boson samples; training on GPU (NVIDIA A100 or cloud equivalent); model serving via FastAPI.

### Integration Targets
Materials research LIMS, crystallography databases (ICSD), computational chemistry software (VASP, SIESTA output import).

### Skill Gaps to Close
Perceval SDK depth, photon indistinguishability and KLM theorem, boson sampling complexity theory, generative model training (VAE/diffusion).

### Portfolio Value
Quandela specialisation: bridges candidate's optical background (fiber optics, photonic principles from Institut d'Optique) with quantum sampling. Shows ability to translate domain science into hybrid AI+quantum pipeline. Demonstrates SDQC readiness (privacy-preserving sampling over remote QPU).

### Skills Required
| Skill ID | Skill Name | Phase |
|----------|------------|-------|
| QSK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notat | Phase 1 — Foundation |
| QSK02 | Quantum Measurement Theory (Projective Measurements, POVMs & | Phase 1 — Foundation |
| QSK16 | Photonic Quantum Optics (Coherent, Fock & Squeezed States) | Phase 2 — FDE Track |
| QSK17 | Beam Splitter Unitaries & Hong-Ou-Mandel Effect | Phase 2 — FDE Track |
| QSK18 | Photon Indistinguishability & KLM Theorem (Linear Optics Qua | Phase 3 — Quantum-AI |
| QSK19 | Boson Sampling & Computational Complexity Theory | Phase 3 — Quantum-AI |
| QSK20 | Quantum Fourier Transform & Phase Estimation | Phase 2 — FDE Track |
| QSK21 | Single-Photon Source Engineering & Characterisation | Phase 3 — Quantum-AI |
| QSK24 | ML for Quantum Error Mitigation (Neural Networks for Noise C | Phase 2 — FDE Track |
| QSK25 | Hybrid Classical-Quantum Loops & Orchestration | Phase 2 — FDE Track |
| QSK26 | PyTorch Production Patterns (Distributed Training, Model Ser | Phase 2 — FDE Track |
| QSK27 | REST API Design & FastAPI | Phase 1 — Foundation |
| QSK32 | Adiabatic Theorem & Quantum Tunnelling | Phase 2 — FDE Track |
| QSK33 | SQL Data Modelling (PostgreSQL, Schema Design) | Phase 1 — Foundation |
| QSK34 | Container Orchestration (Docker & Kubernetes) | Phase 1 — Foundation |
| QSK38 | Generative Models (VAE, Diffusion, Flow Models) | Phase 2 — FDE Track |
| QSK39 | Vector Database Integration (Qdrant/Weaviate) | Phase 2 — FDE Track |

---

## QP04 (P04) — Trapped-Ion Quantum Simulation for Financial Portfolio Optimisation

**Domain:** Finance & Risk Management  
**Quantum modality:** trapped-ion  
**Phase:** Phase 2D  
**Quantum-AI synergy:** Quantum-enhanced optimisation  
**Skill IDs:** SK01,SK02,SK03,SK04,SK22,SK23,SK24,SK25,SK26,SK27,SK32,SK33,SK34,SK40,SK41  
**Tool IDs:** TL16,TL17,TL01,TL10,TL04,TL05,TL06,TL18,TL07  

### Business Problem
Portfolio managers optimise allocations across thousands of assets subject to risk, liquidity, and regulatory constraints. Current quadratic programming solvers handle 100–500 assets; quantum advantage emerges at 1000+.

### Solution Architecture
Design TKET-compiled circuits for IonQ/Quantinuum trapped-ion hardware encoding portfolio constraints. Candidate builds orchestration layer (constraint translation, circuit compilation via Pytket, risk metric aggregation) and integrates with Bloomberg/Reuters feeds for real-time rebalancing suggestions.

### Tech Stack
TKET, Pytket, Qiskit, JAX, FastAPI, PostgreSQL, Bloomberg API wrapper, Docker, Kubernetes

### Infrastructure
IonQ or Quantinuum cloud QPU access; PostgreSQL for portfolio metadata and historical returns; FastAPI service for constraint ingestion; Kubernetes for autoscaling during market hours.

### Integration Targets
Bloomberg Terminal, Reuters Eikon, risk management systems (MSCI RiskMetrics), order execution platforms (Bloomberg Execution Services).

### Skill Gaps to Close
TKET/Pytket workflow, trapped-ion gate fidelity and all-to-all connectivity exploitation, high-dimensional constraint encoding, financial domain knowledge (risk metrics, portfolio theory).

### Portfolio Value
Quantinuum/IonQ enterprise FDE play. Demonstrates ability to work with high-fidelity trapped-ion platforms (Mølmer–Sørensen gates, long coherence times). Shows financial domain translation and production-grade real-time system design.

### Skills Required
| Skill ID | Skill Name | Phase |
|----------|------------|-------|
| QSK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notat | Phase 1 — Foundation |
| QSK02 | Quantum Measurement Theory (Projective Measurements, POVMs & | Phase 1 — Foundation |
| QSK03 | Quantum Decoherence & Relaxation Theory (T1/T2 Times, Lindbl | Phase 2 — FDE Track |
| QSK04 | Quantum Gate Model & Universal Gate Sets (Clifford+T, Gate D | Phase 1 — Foundation |
| QSK22 | Trapped-Ion Physics (Paul & Penning Traps, Laser-Matter Inte | Phase 2 — FDE Track |
| QSK23 | Mølmer–Sørensen Gate Mechanism (Entangling Gate Design) | Phase 2 — FDE Track |
| QSK24 | ML for Quantum Error Mitigation (Neural Networks for Noise C | Phase 2 — FDE Track |
| QSK25 | Hybrid Classical-Quantum Loops & Orchestration | Phase 2 — FDE Track |
| QSK26 | PyTorch Production Patterns (Distributed Training, Model Ser | Phase 2 — FDE Track |
| QSK27 | REST API Design & FastAPI | Phase 1 — Foundation |
| QSK32 | Adiabatic Theorem & Quantum Tunnelling | Phase 2 — FDE Track |
| QSK33 | SQL Data Modelling (PostgreSQL, Schema Design) | Phase 1 — Foundation |
| QSK34 | Container Orchestration (Docker & Kubernetes) | Phase 1 — Foundation |
| QSK40 | Financial Domain Integration (Risk Metrics, Portfolio Theory | Phase 2 — FDE Track |
| QSK41 | Variational Quantum Machine Learning (QML) | Phase 2 — FDE Track |

---

## QP05 (P05) — D-Wave Annealing + ML for Supply Chain Disruption Prediction

**Domain:** Enterprise AI & Operations  
**Quantum modality:** annealing  
**Phase:** Phase 2E  
**Quantum-AI synergy:** AI-assisted error mitigation  
**Skill IDs:** SK01,SK02,SK29,SK30,SK31,SK42,SK43,SK44,SK32,SK33,SK34,SK45,SK46,SK47  
**Tool IDs:** TL19,TL10,TL20,TL13,TL04,TL05,TL14,TL06,TL07  

### Business Problem
Supply chain visibility systems must detect cascading disruptions (supplier failures, logistics delays) in real-time. Classical ML inference lags; hybrid quantum-classical can pre-screen QUBO-encoded scenarios faster.

### Solution Architecture
Candidate builds a feature pipeline (supply chain graph → QUBO embeddings) and deploys D-Wave Ocean SDK annealing jobs in parallel with classical random forest predictions. An LLM-powered dashboard synthesises both outputs into actionable alerts for operations teams.

### Tech Stack
Ocean SDK, PyTorch, Scikit-learn, LangChain, FastAPI, PostgreSQL, Qdrant, Docker, GitHub Actions

### Infrastructure
D-Wave Leap cloud annealing service; PostgreSQL for supply chain graph; Qdrant for embedding historical disruption patterns; LLM API (Mistral or OpenAI) for alert generation; edge deployment on customer's enterprise network.

### Integration Targets
Supply chain visibility platforms (Fourkites, Flexport), ERP systems (SAP, Oracle), incident ticketing (Jira Service Desk).

### Skill Gaps to Close
Ocean SDK QUBO formulation, annealing-specific hyperparameter tuning, LLM prompt engineering for domain alerts, supply chain domain knowledge.

### Portfolio Value
Demonstrates enterprise FDE breadth: quantum annealing is complementary to gate-model approaches. Shows practical hybrid QC+AI design for real operational constraints. Establishes credibility with enterprise customers (AMI Labs deployment profile).

### Skills Required
| Skill ID | Skill Name | Phase |
|----------|------------|-------|
| QSK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notat | Phase 1 — Foundation |
| QSK02 | Quantum Measurement Theory (Projective Measurements, POVMs & | Phase 1 — Foundation |
| QSK29 | Real-Time Inference Acceleration & Latency Optimisation | Phase 2 — FDE Track |
| QSK30 | QUBO & Ising Model Formulation | Phase 2 — FDE Track |
| QSK31 | Spin Glass Physics & Adiabatic Evolution | Phase 2 — FDE Track |
| QSK42 | Prompt Engineering & Chain-of-Thought Reasoning | Phase 2 — FDE Track |
| QSK43 | Retrieval-Augmented Generation (RAG) Architecture | Phase 2 — FDE Track |
| QSK44 | LLM Output Parsing & Safety (Structured Output Extraction) | Phase 2 — FDE Track |
| QSK32 | Adiabatic Theorem & Quantum Tunnelling | Phase 2 — FDE Track |
| QSK33 | SQL Data Modelling (PostgreSQL, Schema Design) | Phase 1 — Foundation |
| QSK34 | Container Orchestration (Docker & Kubernetes) | Phase 1 — Foundation |
| QSK45 | Semantic Search & Vector Embeddings | Phase 2 — FDE Track |
| QSK46 | NIST PQC Standards (Kyber, Dilithium, CRYSTALS) | Phase 2 — FDE Track |
| QSK47 | Cryptographic Protocol Design & Implementation | Phase 2 — FDE Track |

---

## QP06 (P06) — AI-Assisted Quantum Circuit Calibration for Multi-Qubit Gates

**Domain:** Quantum Hardware Engineering  
**Quantum modality:** superconducting  
**Phase:** Phase 2A  
**Quantum-AI synergy:** AI-assisted error mitigation  
**Skill IDs:** SK01,SK02,SK03,SK04,SK05,SK06,SK24,SK25,SK26,SK27,SK48,SK49,SK50,SK51,SK52  
**Tool IDs:** TL01,TL02,TL21,TL10,TL22,TL23,TL24,TL04,TL06  

### Business Problem
Quantum hardware vendors face hardware calibration drift; two-qubit gate fidelities degrade over hours. Manual re-tuning is labour-intensive; automated ML-driven calibration is urgent.

### Solution Architecture
Candidate designs a reinforcement learning loop: measure two-qubit gate fidelities via randomised benchmarking, train a neural network to predict optimal pulse parameters, and update the Qiskit Pulse compiler in real-time. Integrates telemetry dashboards for hardware operations teams.

### Tech Stack
Qiskit, Qiskit Aer, Qiskit Pulse, PyTorch, Ray (distributed ML), Prometheus, Grafana, FastAPI, Docker

### Infrastructure
On-premises or cloud QPU telemetry; centralised ML training on GPU cluster; Prometheus for metrics collection; Grafana dashboards for ops visibility; automated recompilation trigger via GitHub Actions.

### Integration Targets
Quantum hardware control systems (QCS), cryogenic dilution fridges, classical control electronics firmware.

### Skill Gaps to Close
Qiskit Pulse low-level control, reinforcement learning for hardware tuning, randomised benchmarking protocol design, distributed ML infrastructure (Ray).

### Portfolio Value
Premium FDE vertical: hardware calibration work is high-value, low-volume. Shows deep quantum hardware intuition and MLOps credibility. Candidate's instrumentation background (optical tweezers at McGill, DGA simulation) transfers directly to pulse-level tuning.

### Skills Required
| Skill ID | Skill Name | Phase |
|----------|------------|-------|
| QSK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notat | Phase 1 — Foundation |
| QSK02 | Quantum Measurement Theory (Projective Measurements, POVMs & | Phase 1 — Foundation |
| QSK03 | Quantum Decoherence & Relaxation Theory (T1/T2 Times, Lindbl | Phase 2 — FDE Track |
| QSK04 | Quantum Gate Model & Universal Gate Sets (Clifford+T, Gate D | Phase 1 — Foundation |
| QSK05 | Complex Vector Spaces & Inner Products (Tensor Products, Kro | Phase 1 — Foundation |
| QSK06 | Eigendecomposition & Matrix Decompositions (SVD, QR, Spectra | Phase 1 — Foundation |
| QSK24 | ML for Quantum Error Mitigation (Neural Networks for Noise C | Phase 2 — FDE Track |
| QSK25 | Hybrid Classical-Quantum Loops & Orchestration | Phase 2 — FDE Track |
| QSK26 | PyTorch Production Patterns (Distributed Training, Model Ser | Phase 2 — FDE Track |
| QSK27 | REST API Design & FastAPI | Phase 1 — Foundation |
| QSK48 | Key Lifecycle Management (Generation, Storage, Rotation, Rev | Phase 2 — FDE Track |
| QSK49 | Hardware Security Module (HSM) Integration | Phase 2 — FDE Track |
| QSK50 | Reinforcement Learning for Hardware Control | Phase 2 — FDE Track |
| QSK51 | Randomised Benchmarking Protocol Design | Phase 2 — FDE Track |
| QSK52 | Distributed ML Training (Ray/Spark, Parameter Servers) | Phase 2 — FDE Track |

---

## QP07 (P07) — Post-Quantum Cryptography Migration with AI-Powered Key Management

**Domain:** Cybersecurity & Enterprise Defense  
**Quantum modality:** classical-only  
**Phase:** Phase 2F / Phase 3  
**Quantum-AI synergy:** Post-quantum cryptography (PQC) + AI  
**Skill IDs:** SK01,SK42,SK43,SK44,SK32,SK33,SK34,SK45,SK46,SK47,SK53,SK54,SK55,SK56  
**Tool IDs:** TL25,TL04,TL05,TL26,TL13,TL27,TL06,TL18  

### Business Problem
Enterprises face urgent mandate to migrate from RSA/ECDSA to NIST PQC standards (Kyber, Dilithium) before quantum computers render legacy encryption obsolete. Key rotation at scale is operationally complex.

### Solution Architecture
Candidate builds an AI-assisted PQC migration pipeline: ingests enterprise certificate inventory, uses an LLM to flag risky key dependencies, automates NIST algorithm selection (Kyber for KEM, Dilithium for signatures), orchestrates key generation and distribution via secure hardware modules (HSMs), and deploys monitoring to detect anomalous key usage.

### Tech Stack
liboqs (NIST PQC library), FastAPI, PostgreSQL, Mistral API, LangChain, Vault (secrets management), Docker, Kubernetes, Prometheus

### Infrastructure
NIST-certified PQC library (liboqs) integration; Vault for key lifecycle; HSM integration for secure key generation; enterprise PKI systems (EJBCA, Dogtag); audit logging via ELK stack.

### Integration Targets
PKI/HSM infrastructure, enterprise TLS/SSL stacks, certificate authorities (DigiCert, Let's Encrypt automation), API gateways (Kong, Apigee).

### Skill Gaps to Close
NIST PQC standards (Kyber, Dilithium, Falcon), HSM integration, certificate lifecycle management, LLM-based security policy reasoning, compliance audit trails (SOC 2, FedRAMP).

### Portfolio Value
Forward-looking security FDE play. Demonstrates quantum-readiness design patterns even though classical-only. Shows defense sector credibility (Pasqal/Mistral customers often DARPA-funded). Establishes differentiation: FDE who understands quantum threat timeline.

### Skills Required
| Skill ID | Skill Name | Phase |
|----------|------------|-------|
| QSK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notat | Phase 1 — Foundation |
| QSK42 | Prompt Engineering & Chain-of-Thought Reasoning | Phase 2 — FDE Track |
| QSK43 | Retrieval-Augmented Generation (RAG) Architecture | Phase 2 — FDE Track |
| QSK44 | LLM Output Parsing & Safety (Structured Output Extraction) | Phase 2 — FDE Track |
| QSK32 | Adiabatic Theorem & Quantum Tunnelling | Phase 2 — FDE Track |
| QSK33 | SQL Data Modelling (PostgreSQL, Schema Design) | Phase 1 — Foundation |
| QSK34 | Container Orchestration (Docker & Kubernetes) | Phase 1 — Foundation |
| QSK45 | Semantic Search & Vector Embeddings | Phase 2 — FDE Track |
| QSK46 | NIST PQC Standards (Kyber, Dilithium, CRYSTALS) | Phase 2 — FDE Track |
| QSK47 | Cryptographic Protocol Design & Implementation | Phase 2 — FDE Track |
| QSK53 | MLOps & Continuous Retraining Pipelines | Phase 2 — FDE Track |
| QSK54 | Prometheus/Grafana Monitoring & Alerting | Phase 1 — Foundation |
| QSK55 | Variational Quantum Machine Learning (QML) Circuits | Phase 2 — FDE Track |
| QSK56 | Angle Encoding for Feature Maps | Phase 2 — FDE Track |

---

## QP08 (P08) — Variational Quantum Classifier for Anomaly Detection in Sensor Networks

**Domain:** IoT & Industrial Monitoring  
**Quantum modality:** superconducting  
**Phase:** Phase 2A  
**Quantum-AI synergy:** QML / Variational circuits  
**Skill IDs:** SK01,SK02,SK03,SK04,SK05,SK06,SK07,SK08,SK09,SK24,SK25,SK26,SK27,SK32,SK33,SK34,SK57,SK58,SK59  
**Tool IDs:** TL01,TL16,TL10,TL28,TL29,TL04,TL30,TL06,TL18  

### Business Problem
Industrial plants deploy thousands of sensors (vibration, temperature, pressure); anomaly detection must run at edge with sub-100ms latency. Classical neural networks struggle with streaming, imbalanced fault signatures.

### Solution Architecture
Design a hybrid quantum machine learning classifier: embed sensor time-series into quantum circuits using angle encoding, train a variational ansatz on historical fault data (PyTorch+Qiskit), compile to NISQ-friendly depth via TKET, and deploy on edge devices via quantised ONNX export.

### Tech Stack
Qiskit, TKET, PyTorch, ONNX, Edge ML runtime (TensorFlow Lite / ONNX Runtime), FastAPI, InfluxDB, Docker, Kubernetes

### Infrastructure
Hybrid cloud + edge: cloud trains variational circuit; edge devices run compiled inference. InfluxDB time-series storage; Kubernetes orchestration for model versioning and A/B testing.

### Integration Targets
Industrial IoT platforms (Predix, MindSphere), SCADA systems (Ignition), historians (OSIsoft PI).

### Skill Gaps to Close
Variational QML architecture design, angle encoding for time-series, NISQ circuit depth constraints, edge quantisation/compression, streaming anomaly detection theory.

### Portfolio Value
Demonstrates QML specialist credentials. Bridges FDE and AI ML expertise (core candidate strength in PyTorch). Shows industrial deployment rigour: latency budgets, model versioning, A/B testing. Credential for Mistral/AMI Labs transition.

### Skills Required
| Skill ID | Skill Name | Phase |
|----------|------------|-------|
| QSK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notat | Phase 1 — Foundation |
| QSK02 | Quantum Measurement Theory (Projective Measurements, POVMs & | Phase 1 — Foundation |
| QSK03 | Quantum Decoherence & Relaxation Theory (T1/T2 Times, Lindbl | Phase 2 — FDE Track |
| QSK04 | Quantum Gate Model & Universal Gate Sets (Clifford+T, Gate D | Phase 1 — Foundation |
| QSK05 | Complex Vector Spaces & Inner Products (Tensor Products, Kro | Phase 1 — Foundation |
| QSK06 | Eigendecomposition & Matrix Decompositions (SVD, QR, Spectra | Phase 1 — Foundation |
| QSK07 | Quantum Information Theory (von Neumann Entropy, Mutual Info | Phase 2 — FDE Track |
| QSK08 | Quantum Error Correction Theory (Stabiliser Formalism, CSS C | Phase 3 — Quantum-AI |
| QSK09 | NISQ-Era Limitations & Error Mitigation Strategies | Phase 2 — FDE Track |
| QSK24 | ML for Quantum Error Mitigation (Neural Networks for Noise C | Phase 2 — FDE Track |
| QSK25 | Hybrid Classical-Quantum Loops & Orchestration | Phase 2 — FDE Track |
| QSK26 | PyTorch Production Patterns (Distributed Training, Model Ser | Phase 2 — FDE Track |
| QSK27 | REST API Design & FastAPI | Phase 1 — Foundation |
| QSK32 | Adiabatic Theorem & Quantum Tunnelling | Phase 2 — FDE Track |
| QSK33 | SQL Data Modelling (PostgreSQL, Schema Design) | Phase 1 — Foundation |
| QSK34 | Container Orchestration (Docker & Kubernetes) | Phase 1 — Foundation |
| QSK57 | Barren Plateaus & Variational Circuit Optimisation | Phase 3 — Quantum-AI |
| QSK58 | Homomorphic Encryption Theory & Implementation | Phase 3 — Quantum-AI |
| QSK59 | Secure Multi-Party Computation (MPC) | Phase 3 — Quantum-AI |

---

## QP09 (P09) — Secure Delegated Quantum Computation (SDQC) for Privacy-Preserving Drug Discovery

**Domain:** Pharma & Biotechnology  
**Quantum modality:** photonic  
**Phase:** Phase 2C  
**Quantum-AI synergy:** Secure delegated quantum computation (SDQC)  
**Skill IDs:** SK01,SK02,SK16,SK17,SK18,SK19,SK20,SK21,SK60,SK61,SK62,SK24,SK25,SK26,SK27,SK32,SK33,SK34,SK63,SK64  
**Tool IDs:** TL12,TL31,TL32,TL10,TL04,TL06,TL33  

### Business Problem
Biotech firms outsource molecular simulations to quantum vendors but must protect proprietary compound structures. Standard QPU APIs expose circuit details; SDQC protocols hide inputs/outputs via blind computation.

### Solution Architecture
Implement Quandela's SDQC protocol: candidate blinds molecular descriptors via homomorphic encryption, submits to Quandela's remote photonic QPU, receives encrypted boson-sampled results, and decrypts locally. Integrates with drug discovery pipelines (RDKit, ChemAxon) for seamless proprietary data protection.

### Tech Stack
Perceval SDK, Homomorphic Encryption library (Microsoft SEAL or Lattigo), RDKit, PyTorch, FastAPI, Docker, TensorFlow Encrypted

### Infrastructure
Quandela cloud SDQC endpoint; client-side HE key management; secure enclave for decryption (optional Intel SGX); audit logging for compliance (FDA 21 CFR Part 11).

### Integration Targets
Drug discovery software (Schrödinger, MOE), biotech lab management systems (LIMS), regulatory reporting (FDA eCopy audits).

### Skill Gaps to Close
Homomorphic encryption theory and implementation, Quandela SDQC protocol specifics, cryptographic circuit design, regulatory compliance (FDA, EMA).

### Portfolio Value
Cutting-edge Quandela differentiation: SDQC is unique IP. Demonstrates security-first quantum architecture thinking. Shows ability to bridge cryptography + quantum + biotech domains. Premium positioning for pharma FDE roles.

### Skills Required
| Skill ID | Skill Name | Phase |
|----------|------------|-------|
| QSK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notat | Phase 1 — Foundation |
| QSK02 | Quantum Measurement Theory (Projective Measurements, POVMs & | Phase 1 — Foundation |
| QSK16 | Photonic Quantum Optics (Coherent, Fock & Squeezed States) | Phase 2 — FDE Track |
| QSK17 | Beam Splitter Unitaries & Hong-Ou-Mandel Effect | Phase 2 — FDE Track |
| QSK18 | Photon Indistinguishability & KLM Theorem (Linear Optics Qua | Phase 3 — Quantum-AI |
| QSK19 | Boson Sampling & Computational Complexity Theory | Phase 3 — Quantum-AI |
| QSK20 | Quantum Fourier Transform & Phase Estimation | Phase 2 — FDE Track |
| QSK21 | Single-Photon Source Engineering & Characterisation | Phase 3 — Quantum-AI |
| QSK60 | Privacy-Preserving Quantum Protocols (Blind Computation) | Phase 3 — Quantum-AI |
| QSK61 | Cryptographic Circuit Design (Garbled Circuits, Boolean Mask | Phase 3 — Quantum-AI |
| QSK62 | Regulatory Compliance (FDA 21 CFR Part 11, EMA GMP Annex 11) | Phase 2 — FDE Track |
| QSK24 | ML for Quantum Error Mitigation (Neural Networks for Noise C | Phase 2 — FDE Track |
| QSK25 | Hybrid Classical-Quantum Loops & Orchestration | Phase 2 — FDE Track |
| QSK26 | PyTorch Production Patterns (Distributed Training, Model Ser | Phase 2 — FDE Track |
| QSK27 | REST API Design & FastAPI | Phase 1 — Foundation |
| QSK32 | Adiabatic Theorem & Quantum Tunnelling | Phase 2 — FDE Track |
| QSK33 | SQL Data Modelling (PostgreSQL, Schema Design) | Phase 1 — Foundation |
| QSK34 | Container Orchestration (Docker & Kubernetes) | Phase 1 — Foundation |
| QSK63 | Tensor Network Theory (MPS, PEPS, MERA) | Phase 3 — Quantum-AI |
| QSK64 | Graph Neural Networks (GNNs) for Quantum Circuits | Phase 2 — FDE Track |

---

## QP10 (P10) — Tensor Network Classical Simulation + ML for Quantum Circuit Benchmarking

**Domain:** Quantum Software Engineering & Research  
**Quantum modality:** superconducting  
**Phase:** Phase 2A  
**Quantum-AI synergy:** Quantum-enhanced optimisation  
**Skill IDs:** SK01,SK02,SK04,SK05,SK06,SK65,SK66,SK67,SK24,SK25,SK26,SK27,SK32,SK33,SK34,SK68,SK69  
**Tool IDs:** TL34,TL10,TL35,TL01,TL36,TL06,TL18,TL07  

### Business Problem
Quantum hardware vendors need classical simulators to validate circuits up to ~20 qubits before deploying to physical hardware. Standard simulators (Qiskit Aer statevector) don't scale; tensor networks offer efficient compression.

### Solution Architecture
Candidate deploys a tensor network simulator (MPS/PEPS backends) via QuTiP and JAX, trains a GNN to predict circuit depth reductions and optimal contraction ordering, and integrates into Qiskit's simulator selection logic via a Flask microservice.

### Tech Stack
QuTiP, JAX, PyTorch Geometric (GNNs), Qiskit, Flask, Docker, Kubernetes, GitHub Actions

### Infrastructure
Distributed tensor network computation on GPU cluster; caching of precomputed contractions in Redis; A/B testing framework for GNN contraction policy validation.

### Integration Targets
Qiskit simulator ecosystem, cloud quantum compute platforms (AWS Braket, Azure Quantum), benchmarking suites (QASMBench).

### Skill Gaps to Close
Tensor network theory (MPS/PEPS), graph neural networks (GNNs), JAX functional programming, high-performance tensor contraction libraries (opt_einsum).

### Portfolio Value
Research-grade FDE credential. Demonstrates ability to ship advanced quantum algorithms (tensor networks) + AI (GNNs) in production. Signals maturity for Quantum Solutions Engineer tracks at Pasqal, Quandela post-2027.

### Skills Required
| Skill ID | Skill Name | Phase |
|----------|------------|-------|
| QSK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notat | Phase 1 — Foundation |
| QSK02 | Quantum Measurement Theory (Projective Measurements, POVMs & | Phase 1 — Foundation |
| QSK04 | Quantum Gate Model & Universal Gate Sets (Clifford+T, Gate D | Phase 1 — Foundation |
| QSK05 | Complex Vector Spaces & Inner Products (Tensor Products, Kro | Phase 1 — Foundation |
| QSK06 | Eigendecomposition & Matrix Decompositions (SVD, QR, Spectra | Phase 1 — Foundation |
| QSK65 | Classical Tensor Contraction & opt_einsum | Phase 2 — FDE Track |
| QSK66 | Quantum Circuit Benchmarking & Metrics | Phase 2 — FDE Track |
| QSK67 | High-Performance Computing (HPC) Optimization | Phase 2 — FDE Track |
| QSK24 | ML for Quantum Error Mitigation (Neural Networks for Noise C | Phase 2 — FDE Track |
| QSK25 | Hybrid Classical-Quantum Loops & Orchestration | Phase 2 — FDE Track |
| QSK26 | PyTorch Production Patterns (Distributed Training, Model Ser | Phase 2 — FDE Track |
| QSK27 | REST API Design & FastAPI | Phase 1 — Foundation |
| QSK32 | Adiabatic Theorem & Quantum Tunnelling | Phase 2 — FDE Track |
| QSK33 | SQL Data Modelling (PostgreSQL, Schema Design) | Phase 1 — Foundation |
| QSK34 | Container Orchestration (Docker & Kubernetes) | Phase 1 — Foundation |
| QSK68 | LSTM Time-Series Forecasting | Phase 1 — Foundation |
| QSK69 | Inventory Management & Constraint Optimization | Phase 2 — FDE Track |

---

## QP11 (P11) — Cinema Demand Forecasting & Dynamic Pricing with Quantum Optimisation

**Domain:** Media & Entertainment  
**Quantum modality:** annealing  
**Phase:** Phase 2E  
**Quantum-AI synergy:** Quantum-enhanced optimisation  
**Skill IDs:** SK01,SK02,SK29,SK30,SK31,SK42,SK43,SK44,SK24,SK25,SK26,SK27,SK32,SK33,SK34,SK70,SK71  
**Tool IDs:** TL19,TL10,TL13,TL04,TL05,TL11,TL37,TL06,TL07  

### Business Problem
Multiplex cinemas adjust ticket pricing per screen per timeslot based on predicted demand; manual pricing stalls as venue portfolios scale to 50+ screens. Quantum-assisted revenue optimisation can handle combinatorial pricing strategies.

### Solution Architecture
Candidate builds a revenue management system: ML models forecast demand (PyTorch LSTM on historical bookings), encode pricing constraints as QUBO (inventory, cannibalization, margin floors), submit to D-Wave annealing, and deploy prices via cinema POS APIs. Real-time dashboards track yield vs forecast.

### Tech Stack
Ocean SDK, PyTorch, LangChain (for strategic reasoning), FastAPI, PostgreSQL, Redis, Cinema POS API wrappers, Docker, GitHub Actions

### Infrastructure
D-Wave Leap access; PostgreSQL for booking history; Redis for real-time price cache; edge deployment at multiplex headquarters; hourly reoptimisation triggered by demand forecast updates.

### Integration Targets
Cinema management systems (Premiere Global, Movio), ticketing platforms (Ticketmaster), business intelligence (Tableau, Looker).

### Skill Gaps to Close
QUBO formulation for pricing constraints, inventory+cannibalization modelling, revenue management domain depth, annealing hyperparameter tuning.

### Portfolio Value
Wildcard domain showcasing portfolio breadth: cinema business model deep-dive (candidate's stated interest). Demonstrates FDE can adapt quantum+AI to any vertical. Signals consulting upside and corporate development credibility.

### Skills Required
| Skill ID | Skill Name | Phase |
|----------|------------|-------|
| QSK01 | Quantum State Representation (Hilbert Spaces & Bra-Ket Notat | Phase 1 — Foundation |
| QSK02 | Quantum Measurement Theory (Projective Measurements, POVMs & | Phase 1 — Foundation |
| QSK29 | Real-Time Inference Acceleration & Latency Optimisation | Phase 2 — FDE Track |
| QSK30 | QUBO & Ising Model Formulation | Phase 2 — FDE Track |
| QSK31 | Spin Glass Physics & Adiabatic Evolution | Phase 2 — FDE Track |
| QSK42 | Prompt Engineering & Chain-of-Thought Reasoning | Phase 2 — FDE Track |
| QSK43 | Retrieval-Augmented Generation (RAG) Architecture | Phase 2 — FDE Track |
| QSK44 | LLM Output Parsing & Safety (Structured Output Extraction) | Phase 2 — FDE Track |
| QSK24 | ML for Quantum Error Mitigation (Neural Networks for Noise C | Phase 2 — FDE Track |
| QSK25 | Hybrid Classical-Quantum Loops & Orchestration | Phase 2 — FDE Track |
| QSK26 | PyTorch Production Patterns (Distributed Training, Model Ser | Phase 2 — FDE Track |
| QSK27 | REST API Design & FastAPI | Phase 1 — Foundation |
| QSK32 | Adiabatic Theorem & Quantum Tunnelling | Phase 2 — FDE Track |
| QSK33 | SQL Data Modelling (PostgreSQL, Schema Design) | Phase 1 — Foundation |
| QSK34 | Container Orchestration (Docker & Kubernetes) | Phase 1 — Foundation |
| QSK70 | Revenue Management & Dynamic Pricing Theory | Phase 2 — FDE Track |
| QSK71 | Technical Documentation & Developer Experience (DevEx) | Phase 1 — Foundation |

---

## QP12 (P12) — Multi-Modality Quantum Benchmark Aggregator & LLM-Powered Circuit Explainer

**Domain:** Quantum Education & Developer Tools  
**Quantum modality:** classical-only  
**Phase:** Phase 2F / Phase 3  
**Quantum-AI synergy:** none  
**Skill IDs:** SK32,SK33,SK34,SK42,SK43,SK44,SK45,SK46,SK47,SK72,SK73,SK74  
**Tool IDs:** TL01,TL38,TL39,TL12,TL26,TL13,TL14,TL05,TL40,TL06,TL07  

### Business Problem
Quantum developers struggle to compare performance across Qiskit, Cirq, PennyLane, Perceval—each has different benchmarks, metrics, documentation. No unified resource; learning curve steep.

### Solution Architecture
Candidate builds a unified quantum circuit benchmark portal: aggregates public benchmark suites (QASMBench, Quantum Benchmarks, Quandela's photonic benchmarks), stores results in Postgres with multi-dimensional indexing (hardware, circuit family, depth, width), and deploys an LLM-powered assistant (Mistral API) that explains circuit results in plain English and suggests optimisation strategies.

### Tech Stack
Qiskit, Cirq, PennyLane, Perceval, Mistral API, LangChain, FastAPI, PostgreSQL, Qdrant, React/Next.js, Docker, GitHub Actions

### Infrastructure
Cloud-hosted benchmark portal; automated weekly benchmark runs on public QPU access (AWS Braket free tier); vector embedding of benchmark descriptions for semantic search; frontend React spa.

### Integration Targets
Quantum developer communities (Qiskit Slack, Cirq GitHub), cloud quantum platforms (AWS Braket, Azure Quantum, IBM Quantum), educational platforms (Coursera, Udacity).

### Skill Gaps to Close
LLM prompt engineering for technical explanations, multi-library circuit transpilation, benchmark data schema design, community developer engagement.

### Portfolio Value
Developer relations + open-source credibility. Showcases solo-buildable full-stack capacity (React frontend, FastAPI backend, ML integration, community tooling). Strong signal for Mistral/AMI Labs culture fit (developer-first, open ecosystem). Establishes thought leadership in quantum DevEx.

### Skills Required
| Skill ID | Skill Name | Phase |
|----------|------------|-------|
| QSK32 | Adiabatic Theorem & Quantum Tunnelling | Phase 2 — FDE Track |
| QSK33 | SQL Data Modelling (PostgreSQL, Schema Design) | Phase 1 — Foundation |
| QSK34 | Container Orchestration (Docker & Kubernetes) | Phase 1 — Foundation |
| QSK42 | Prompt Engineering & Chain-of-Thought Reasoning | Phase 2 — FDE Track |
| QSK43 | Retrieval-Augmented Generation (RAG) Architecture | Phase 2 — FDE Track |
| QSK44 | LLM Output Parsing & Safety (Structured Output Extraction) | Phase 2 — FDE Track |
| QSK45 | Semantic Search & Vector Embeddings | Phase 2 — FDE Track |
| QSK46 | NIST PQC Standards (Kyber, Dilithium, CRYSTALS) | Phase 2 — FDE Track |
| QSK47 | Cryptographic Protocol Design & Implementation | Phase 2 — FDE Track |
| QSK72 | Benchmark Design & Evaluation Metrics | Phase 2 — FDE Track |
| QSK73 | Multi-SDK Integration & Circuit Transpilation | Phase 2 — FDE Track |
| QSK74 | Community & Open-Source Engagement | Phase 1 — Foundation |

---
