# Track: AI Engineer

## Objective

Build production-grade AI engineering skills: training models, serving them as APIs, and integrating them into larger systems. By the end of this track, you can take a research model from a paper and turn it into a deployed, monitored API — and anchor that knowledge in real FDE portfolio projects.

---

## Junior → Senior Progression

| Level | Can do |
|-------|--------|
| Junior | Write Python scripts, fine-tune pre-trained models via Keras/HF, build a basic FastAPI endpoint, use Scikit-learn pipelines |
| Mid | Train models from scratch in PyTorch, understand the training loop deeply, build async FastAPI with auth, evaluate models systematically |
| Senior | Design ML system architecture, optimize inference (quantization, ONNX, TorchServe), handle distributed training (DDP), monitor models in production (drift, latency, accuracy) |

---

## Modules

### Phase 1 — Foundations

| # | Slug | Key Skills | Hours | Status |
|---|------|-----------|-------|--------|
| 01 | [01-python-foundations](01-python-foundations/) | Typed Python, OOP, packaging, pytest, ruff | 20 | ⏳ |
| 02 | [02-fastapi](02-fastapi/) | REST API, Pydantic v2, async, middleware, OpenAPI | 15 | ⏳ |
| 03 | [03-data-viz-seaborn-plotly](03-data-viz-seaborn-plotly/) | EDA, Seaborn, Plotly Express, interactive dashboards | 12 | ⏳ |
| 04 | [04-tensorflow](04-tensorflow/) | Keras Sequential, callbacks, fine-tuning, TF datasets | 15 | ⏳ |
| 05 | [05-pytorch](05-pytorch/) | Tensors, autograd, DataLoader, custom training loop, DDP | 20 | ⏳ |

### Phase 2 — Core Modules

| # | Slug | Key Skills | Hours | Anchor Project | Status |
|---|------|-----------|-------|---------------|--------|
| 06 | [06-langchain-rag](06-langchain-rag/) | RAG pipeline, document ingestion, embeddings, pgvector | 15 | P01 VC Analyst | ⏳ |
| 07 | [07-vector-databases](07-vector-databases/) | HNSW indexing, pgvector vs Qdrant, hybrid search | 10 | P02 Customer Support | ⏳ |
| 08 | [08-llm-prompt-engineering](08-llm-prompt-engineering/) | Prompt templates, CoT, structured output, few-shot | 10 | P06 AI Copilot | ⏳ |
| 09 | [09-ml-explainability](09-ml-explainability/) | SHAP values, feature importance, model debugging | 10 | P03 Fraud Detection | ⏳ |
| 10 | [10-time-series-forecasting](10-time-series-forecasting/) | Prophet, LSTM, seasonality, trend decomposition | 15 | P04 Supply Chain | ⏳ |
| 11 | [11-streaming-ml](11-streaming-ml/) | Kafka, Faust stateful processing, low-latency inference | 15 | P03 Fraud Detection | ⏳ |
| 12 | [12-mlops-cicd](12-mlops-cicd/) | GitHub Actions CI/CD, ONNX export, model versioning | 12 | P10 Cinema Pricing | ⏳ |

### Phase 3 — Capstone

| Slug | Description | Hours | Status |
|------|-------------|-------|--------|
| [capstone-ml-api](capstone-ml-api/) | PyTorch model → FastAPI → Docker → Render/Railway with CI/CD | 40 | ⏳ |

---

## FDE Portfolio Projects (anchored in this track)

| Project | Domain | Key Skills | Modules Required |
|---------|--------|-----------|-----------------|
| [P03 Fraud Detection](../../doc/roadmap/projects/ai-projects.md#p03) | Fintech | SK16, SK17, SK18, SK19 | 05, 09, 11, 12 |
| [P04 Supply Chain](../../doc/roadmap/projects/ai-projects.md#p04) | Supply Chain | SK16, SK17, SK21 | 05, 10 |
| [P08 Healthcare](../../doc/roadmap/projects/ai-projects.md#p08) | Healthcare | SK16, SK17, SK29, SK30 | 05, 09, 12 |
| [P10 Cinema Pricing](../../doc/roadmap/projects/ai-projects.md#p10) | Media | SK16, SK17, SK21, SK22 | 05, 10, 12 |

---

## Job Market Mapping

From [`skill-matrix.md`](../../doc/research/skill-matrix.md):

| Skill ID | Skill | JD Frequency | Tier | Module |
|----------|-------|------------|------|--------|
| — | Python (clean, typed) | **High** (71%) | P1 | 01-python-foundations |
| — | PyTorch | **High** (38%) | P1 | 05-pytorch |
| — | TensorFlow / Keras | **High** (33%) | P1 | 04-tensorflow |
| SK04 | API Design & Contract Management | **High** | P1 | 02-fastapi |
| SK16 | Feature Engineering & Model Architecture | **High** | P1 | 05-pytorch, 09-ml-explainability |
| SK17 | Model Evaluation & Ablation Testing | **High** | P1 | 09-ml-explainability |
| SK19 | Pipeline Orchestration & Automation | **High** | P1 | 12-mlops-cicd |
| SK21 | Time-Series Forecasting | **Medium** | P2 | 10-time-series-forecasting |
| SK08 | Observability & Production Debugging | **High** | P1 | 12-mlops-cicd |

---

## Resources

1. [fast.ai Practical Deep Learning](https://course.fast.ai) — Best top-down intro; start here
2. [Andrej Karpathy YouTube](https://www.youtube.com/@AndrejKarpathy) — Neural nets from first principles
3. [FastAPI documentation](https://fastapi.tiangolo.com) — Best API framework docs in the Python ecosystem
4. [LangChain + pgvector guide](https://python.langchain.com/docs/integrations/vectorstores/pgvector/) — For Phase 2 RAG modules

---

## Capstone

**`capstone-ml-api` — ML Model Serving API**

Fine-tune a pre-trained Hugging Face model and serve it via FastAPI. The API accepts text/image input and returns predictions with confidence scores. Packaged as a Docker image with CI/CD via GitHub Actions. Deployed to Render or Railway.

Full spec: [doc/roadmap/phase-3-capstones.md](../../doc/roadmap/phase-3-capstones.md#capstone-1-ml-model-serving-api-ai-engineer)
