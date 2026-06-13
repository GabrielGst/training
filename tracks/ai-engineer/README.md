# Track: AI Engineer

## Objective

Build production-grade AI engineering skills: training models, serving them as APIs, and integrating them into larger systems. By the end of this track, you can take a research model from a paper and turn it into a deployed, monitored API.

---

## Junior → Senior Progression

| Level | Can do |
|-------|--------|
| Junior | Write Python scripts, fine-tune pre-trained models via Keras/HF, build a basic FastAPI endpoint, use Scikit-learn pipelines |
| Mid | Train models from scratch in PyTorch, understand the training loop deeply, build async FastAPI with auth, evaluate models systematically |
| Senior | Design ML system architecture, optimize inference (quantization, ONNX, TorchServe), handle distributed training (DDP), monitor models in production (drift, latency, accuracy) |

---

## Modules

| # | Module | Key Skills | Status |
|---|--------|-----------|--------|
| 01 | [Python Foundations](01-python-foundations/) | Typed Python, OOP, packaging, pytest, ruff | ⏳ |
| 02 | [FastAPI](02-fastapi/) | REST API, Pydantic v2, async, middleware, OpenAPI | ⏳ |
| 03 | [Data Viz — Seaborn + Plotly](03-data-viz-seaborn-plotly/) | EDA, Seaborn, Plotly Express, interactive dashboards | ⏳ |
| 04 | [TensorFlow](04-tensorflow/) | Keras Sequential, callbacks, fine-tuning, TF datasets | ⏳ |
| 05 | [PyTorch](05-pytorch/) | Tensors, autograd, DataLoader, custom training loop, DDP | ⏳ |
| 06 | [Capstone: ML API](06-capstone-ml-api/) | PyTorch → FastAPI → Docker → deployed | ⏳ |

---

## Job Market Mapping

From [`skill-matrix.md`](../../doc/research/skill-matrix.md):

| Skill | JD Frequency | This Track Module |
|-------|------------|-------------------|
| Python (clean, typed) | **High** (71%) | 01-python-foundations |
| PyTorch | **High** (38%) | 05-pytorch |
| TensorFlow | **High** (33%) | 04-tensorflow |
| FastAPI | **High** (+5pp 2025) | 02-fastapi |
| Scikit-learn | **High** | 01-python-foundations |
| Hugging Face | **High** | 05-pytorch (advanced) |
| Docker | **High** | 06-capstone-ml-api |

---

## Resources

1. [fast.ai Practical Deep Learning](https://course.fast.ai) — Best top-down intro; start here
2. [Andrej Karpathy YouTube](https://www.youtube.com/@AndrejKarpathy) — Neural nets from first principles
3. [FastAPI documentation](https://fastapi.tiangolo.com) — Best API framework docs in the Python ecosystem

---

## Capstone

**Module 06 — ML Model Serving API**

Fine-tune a pre-trained Hugging Face model and serve it via FastAPI. The API accepts text/image input and returns predictions with confidence scores. Packaged as a Docker image. See [doc/roadmap/phase-3-capstones.md](../../doc/roadmap/phase-3-capstones.md#capstone-1-ml-model-serving-api-ai-engineer) for full spec.
