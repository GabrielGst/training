# Skill Matrix — Full-Stack / AI Engineer

> Synthesized from: Stack Overflow Developer Survey 2025, roadmap.sh, dbt Labs blog, DataQuest,
> HeroHunt.ai, NovelVista, 365DataScience, WeCloudData, DEV.to, and LinkedIn job posting patterns.
> Last updated: 2026-06-13. Refresh annually.

---

## How to read this table

| Column | Meaning |
|--------|---------|
| **Frequency** | How often the skill appears in relevant JDs (High ≥ 60 % / Medium 30–59 % / Low < 30 %) |
| **Junior floor** | Minimum expected at entry level |
| **Senior ceiling** | Expected at 4–6 YoE level |
| **P-tier** | P1 = block everything else · P2 = high value · P3 = differentiator |

---

## 1. AI Engineer Track

| Skill | Domain | Frequency | Junior | Senior | Resources (top 3) | Est. Hours | Tier |
|-------|--------|-----------|--------|--------|-------------------|-----------|------|
| Python (clean, typed) | AI Eng | **High** (71 %) | Scripts, notebooks, OOP basics | Async, packaging, profiling, testable design | fast.ai Practical DL · Real Python · Python Docs | 80 | P1 |
| PyTorch | AI Eng | **High** (38 %) | Tensor ops, autograd, simple CNN | Custom datasets, distributed training, ONNX export | PyTorch docs · d2l.ai · fast.ai | 120 | P1 |
| TensorFlow / Keras | AI Eng | **High** (33 %) | Keras Sequential API, fine-tuning | SavedModel, TFX pipelines, TF Serving | TF official tutorials · Aurélien Géron book · Coursera DL Spec | 100 | P1 |
| FastAPI | AI Eng | **High** (+5 pp in 2025) | CRUD endpoints, Pydantic models | Background tasks, middleware, auth, OpenAPI docs | FastAPI docs · testdriven.io · ArjanCodes YouTube | 40 | P1 |
| Seaborn / Matplotlib | AI Eng | **Medium** | Basic plots, heatmaps | Publication-quality figures, custom themes | Seaborn docs · Python Graph Gallery · Kaggle notebooks | 20 | P2 |
| Plotly / Dash | AI Eng | **Medium** | Interactive charts, px API | Dash callbacks, layout composition, deployment | Plotly docs · Charming Data YouTube · Real Python | 25 | P2 |
| Scikit-learn | AI Eng | **High** | Pipelines, cross-val, metrics | Custom transformers, model selection, feature importance | Sklearn docs · Hands-On ML (Géron) · Kaggle | 50 | P1 |
| Docker (for ML) | AI Eng | **High** | Build image, run container | Multi-stage builds, GPU passthrough, Compose | Docker docs · TechWorld with Nana YouTube | 30 | P1 |
| MLflow / experiment tracking | AI Eng | **Medium** | Log params/metrics | Model registry, artifact management | MLflow docs · DVC docs | 20 | P2 |
| Hugging Face Transformers | AI Eng | **High** | Load & fine-tune pre-trained models | Custom Trainer, PEFT/LoRA, ONNX | HF docs · fast.ai NLP · Andrej Karpathy YouTube | 60 | P1 |

---

## 2. Full-Stack Software Engineer Track

| Skill | Domain | Frequency | Junior | Senior | Resources (top 3) | Est. Hours | Tier |
|-------|--------|-----------|--------|--------|-------------------|-----------|------|
| JavaScript / TypeScript | SWE | **High** (66 % JS, TS growing) | ES6+, async/await, basic TS types | Generics, decorators, strict mode, complex type inference | The Odin Project · TypeScript Deep Dive · Execute Program | 80 | P1 |
| React | SWE | **High** (43 %) | Hooks, component composition, state | Performance (memo, virtualization), patterns, testing | React docs · Josh Comeau blog · Theo Browne YouTube | 80 | P1 |
| Next.js (App Router) | SWE | **High** | Pages, routing, basic SSR/SSG | RSC, streaming, edge runtime, ISR, turbopack | Next.js docs · Lee Robinson blog · Jack Herrington YouTube | 60 | P1 |
| Node.js | SWE | **High** | Express/Fastify basics, REST API | Streams, event loop, clustering, perf profiling | Node.js docs · Hussein Nasser YouTube · roadmap.sh | 50 | P1 |
| Shell scripting (Bash) | SWE | **Medium** | Basic automation, file manipulation | Complex pipelines, error handling, CI integration | The Linux Command Line (book) · Explainshell.com | 30 | P2 |
| Docker / Docker Compose | SWE | **High** | Run containers, write Dockerfile | Networking, volumes, multi-service apps | Docker docs · TechWorld with Nana YouTube | 30 | P1 |
| GitHub Actions / CI-CD | SWE | **High** | Basic workflow, lint + test | Matrix builds, caching, secrets, reusable workflows | GH Actions docs · devops.college | 25 | P1 |
| PostgreSQL (from SWE angle) | SWE | **High** | Basic queries, joins, indexes | Query planning, transactions, connection pooling | Postgres docs · pgexercises.com | 40 | P1 |
| Testing (Jest / Vitest / Playwright) | SWE | **High** | Unit tests, basic integration | E2E, coverage gates, mocking strategy | Testing Library docs · Kent C. Dodds blog | 40 | P1 |
| Kubernetes basics | SWE | **Medium** | Pods, services, deploy via kubectl | Helm, ingress, HPA, multi-env management | k8s docs · TechWorld with Nana YouTube · KodeKloud | 40 | P3 |

---

## 3. Data Engineer Track

| Skill | Domain | Frequency | Junior | Senior | Resources (top 3) | Est. Hours | Tier |
|-------|--------|-----------|--------|--------|-------------------|-----------|------|
| PostgreSQL | Data Eng | **High** | DDL, DML, basic queries, indexes | Window functions, CTEs, query planning, partitioning | Postgres docs · pgexercises.com · "Learning PostgreSQL" book | 60 | P1 |
| SQL (advanced) | Data Eng | **High** | Joins, aggregations, subqueries | Window funcs, recursive CTEs, performance tuning | Mode SQL tutorial · StrataScratch · LeetCode SQL | 50 | P1 |
| Python for data (pandas/polars) | Data Eng | **High** | DataFrames, basic EDA | Memory-efficient ops, Polars for large sets | pandas docs · Polars docs · Matt Harrison book | 40 | P1 |
| dbt | Data Eng | **High** (standard in 2025) | Models, sources, tests, docs | Snapshots, macros, packages, incremental models | dbt docs · dbt Learn platform · Jaffle Shop tutorial | 40 | P1 |
| Apache Airflow | Data Eng | **High** | DAGs, operators, scheduling | XComs, custom operators, Kubernetes executor | Airflow docs · Astronomer Academy | 40 | P2 |
| Django ORM | Data Eng | **Medium** | Models, querysets, migrations | Select_related, prefetch_related, raw SQL, signals | Django docs · Django Girls tutorial · Two Scoops of Django | 40 | P2 |
| MySQL / MariaDB | Data Eng | **Medium** | CRUD, basic schema design | Replication, storage engines, performance schema | MySQL docs · "Learning MySQL" O'Reilly | 25 | P2 |
| Cloud data warehouses (Snowflake/BigQuery/Redshift) | Data Eng | **High** | Loading data, basic queries | Clustering, partitioning, cost optimization | Each provider's free tier + docs | 30 | P2 |
| ETL pipeline design | Data Eng | **High** | Understand extract-transform-load | Incremental loads, CDC, idempotency, backfills | Data Engineering with Python (O'Reilly) · Fundamentals of DE (book) | 50 | P1 |
| Data quality & testing | Data Eng | **Medium** | Basic assertions, row counts | Great Expectations, dbt tests, data contracts | GE docs · dbt test docs | 20 | P2 |

---

## 4. AI Agent Engineer Track

| Skill | Domain | Frequency | Junior | Senior | Resources (top 3) | Est. Hours | Tier |
|-------|--------|-----------|--------|--------|-------------------|-----------|------|
| LLM fundamentals | AI Agents | **High** | Prompt engineering, token limits, system prompts | Fine-tuning, RAG architecture, context management, cost optimization | Andrej Karpathy YouTube · Anthropic docs · OpenAI cookbook | 30 | P1 |
| LangChain | AI Agents | **High** | Chains, prompts, memory | Custom chains, callbacks, LangSmith tracing | LangChain docs · Harrison Chase YouTube | 40 | P1 |
| LangGraph | AI Agents | **High** (leading framework 2025–26) | State graphs, nodes, edges | Supervisor patterns, sub-graphs, streaming, persistence | LangGraph docs · LangChain blog | 50 | P1 |
| CrewAI | AI Agents | **Medium** | Agents, tasks, crews | Custom tools, hierarchical process, memory | CrewAI docs · DeepLearning.AI short course | 30 | P2 |
| MCP (Model Context Protocol) | AI Agents | **High** (2026 hiring checklist) | Understand protocol, use existing MCP servers | Build custom MCP servers, tool schema design | Anthropic MCP docs · Claude docs | 30 | P1 |
| Vector databases (Chroma/Pinecone/Weaviate) | AI Agents | **High** | Embed + store + retrieve | ANN indexing, metadata filtering, hybrid search | Each provider's docs · Langchain VDB integrations | 25 | P2 |
| RAG design | AI Agents | **High** | Basic chunking + retrieval pipeline | Advanced RAG (re-ranking, query rewriting, HyDE) | LlamaIndex docs · Anthropic cookbook | 40 | P1 |
| Agent evaluation | AI Agents | **Medium** | Manual testing, basic evals | LLM-as-judge, automated eval harnesses, LangSmith | RAGAS docs · Braintrust docs | 20 | P2 |
| Production observability for agents | AI Agents | **Medium** | Log prompts/responses | Cost tracking, latency dashboards, failure analysis | LangSmith · Langfuse | 15 | P2 |
| Guardrails / safety | AI Agents | **Medium** | Prompt injection awareness | Input/output filters, constitutional AI principles | OWASP LLM Top 10 · NeMo Guardrails | 15 | P3 |

---

## 5. GPU Monitoring & Remote Training Track

| Skill | Domain | Frequency | Junior | Senior | Resources (top 3) | Est. Hours | Tier |
|-------|--------|-----------|--------|--------|-------------------|-----------|------|
| CUDA setup | GPU | **Medium** | Install CUDA toolkit, verify with nvidia-smi | CUDA versions, driver compat matrix, Docker GPU passthrough | NVIDIA CUDA install guide · Lambda GPU Cloud blog | 15 | P2 |
| nvidia-smi / nvtop | GPU | **Medium** | Read GPU utilization, memory, temp | Scripting monitoring, alerting, multi-GPU views | NVIDIA docs · nvtop GitHub | 10 | P2 |
| PyTorch GPU training | GPU | **High** (for ML roles) | `.to(device)`, basic DataLoader | Mixed precision (AMP), gradient checkpointing, multi-GPU DDP | PyTorch docs · fast.ai | 30 | P1 |
| Remote GPU bridge (SSH) | GPU | **Medium** | SSH key auth, port forwarding | VSCode Remote SSH, rsync workflows, tmux sessions | VSCode Remote docs · SSH man page | 15 | P2 |
| Docker GPU passthrough | GPU | **Medium** | NVIDIA Container Toolkit setup | GPU-enabled Compose services | NVIDIA Container Toolkit docs | 10 | P2 |

---

## 6. HPC & Quantum Computing Track

| Skill | Domain | Frequency | Junior | Senior | Resources (top 3) | Est. Hours | Tier |
|-------|--------|-----------|--------|--------|-------------------|-----------|------|
| Slurm basics | HPC | **Low** (niche, academic/research HPC) | sbatch, squeue, resource requests | Job arrays, dependencies, GPU partitions | Slurm docs · NERSC tutorials | 20 | P3 |
| MPI (mpi4py) | HPC | **Low** | Send/receive, broadcast | Collective operations, non-blocking comms | mpi4py docs · LLNL tutorials | 25 | P3 |
| Qiskit | Quantum | **Low** (emerging) | Quantum gates, circuits, simulation | Error mitigation, Qiskit Runtime, hybrid algorithms | IBM Quantum Learning · Qiskit docs · Qiskit Summer School | 40 | P3 |
| Quantum concepts | Quantum | **Low** | Superposition, entanglement, measurement | Grover's, Shor's, VQE basics | "Quantum Computing: An Applied Approach" (Hidary) · IBM Learning | 30 | P3 |

---

## Summary: Priority Tiers

### P1 — Foundation (do first, no excuses)
Python, PyTorch, TensorFlow, FastAPI, React, Next.js, Node.js, PostgreSQL, SQL, dbt, LangGraph, MCP, RAG, LLM fundamentals, Docker, GitHub Actions, TypeScript, ETL design, Hugging Face Transformers, Scikit-learn, pytest/testing.

### P2 — High Value (build in parallel with P1)
Seaborn/Plotly, MLflow, Bash scripting, Django ORM, Airflow, MySQL/MariaDB, CrewAI, vector DBs, GPU monitoring tools, CUDA setup, Kubernetes basics.

### P3 — Differentiators (once P1+P2 solid)
Kubernetes (deep), Slurm, MPI, Qiskit, quantum fundamentals, guardrails/safety, advanced observability.

---

## Estimated Total Hours to Employable Level

| Track | P1 Hours | P2 Hours | Total |
|-------|----------|----------|-------|
| AI Engineer | ~550 | ~120 | ~670 |
| Full-Stack SWE | ~405 | ~70 | ~475 |
| Data Engineer | ~340 | ~175 | ~515 |
| AI Agents | ~215 | ~100 | ~315 |
| GPU Monitoring | ~55 | ~35 | ~90 |
| HPC / Quantum | ~0 | ~0 | ~115 (all P3) |
| **Total** | | | **~2,180** |

At 3 hours/day: ~24 months. At 6 hours/day (intensive): ~12 months. Tracks run in parallel, so real elapsed time is shorter.

---

*Sources: Stack Overflow Developer Survey 2025 · roadmap.sh · dbt Labs Blog · DataQuest · 365DataScience · WeCloudData · NovelVista Agentic AI Guide · DEV.to Agent Frameworks Comparison 2025 · IBM Quantum Learning*
