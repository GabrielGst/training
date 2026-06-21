# P0.1 — Setting up a local LLM using Ollama

**Domain:** AI Agents / AI Engineer **Track:** `fde-extra` **Status:** started **Hours target:** 4

## Business Problem

Corporations and developers struggle implementing AI because of the related heavy cost per token, as well as data privacy. One solution is to work offline, or on a local network, to keep data private, but that requires using a local AI model. Ollama is an inference platform that can download models, but also handles quantization format, memory allocation, and GPU offloading automatically. Using Ollama to run LLMs locally answers three rationales: cost, privacy, offline.

## What you will build

- A chatbot with flexible models and a custom Modelfile persona
- An offline RAG pipeline: upload a PDF, query it locally, no cloud involved

## Architecture

```
User prompt (terminal / Python script)
        |
        v  HTTP REST on localhost:11434
 Ollama daemon (background service)
   ├── Model loading & memory management
   ├── GPU / CPU layer offloading
   └── Quantized weights  (~/.ollama/models)
        |
        v
 Response (streaming tokens or full JSON)
        |
        v
 Terminal output / Flask API

── RAG layer (Step 12) ──────────────────────────────────
 PDF upload → LangChain splitter → OllamaEmbeddings
        |
        v
 ChromaDB (local vector store)
        |
        v  similarity search
 Retrieved chunks → LLM prompt → answer
```

## Skills covered

| Skill | What you practice |
| ----- | ----------------- |
| Local LLM inference | Installing and operating an inference runtime; pulling and managing quantized models |
| REST API consumption | Calling Ollama's HTTP API with `curl` and parsing JSON responses |
| Python LLM integration | Using the `ollama` Python SDK; streaming responses; listing models programmatically |
| Prompt engineering | System prompts, temperature, context window tuning, Modelfiles |
| Docker deployment | Containerising the Ollama service with GPU passthrough and Open WebUI |
| Performance optimisation | Choosing quantization levels; GPU offloading; memory and concurrency settings |
| Model evaluation | A/B testing multiple models on the same prompt with latency and token metrics |
| RAG architecture | Chunking, embedding, vector retrieval, context injection |
| LangChain orchestration | LCEL chains, MultiQueryRetriever, ChatOllama, PromptTemplate |

## Tools & dependencies

| Tool | Version | Purpose | Install |
| ---- | ------- | ------- | ------- |
| Ollama | 0.13.x | Local LLM inference runtime | `curl -fsSL https://ollama.com/install.sh \| sh` |
| ollama (Python) | 0.6.2 | Python SDK for the Ollama API | `pip install ollama==0.6.2` |
| langchain | latest | LLM orchestration framework | `pip install langchain langchain-community` |
| chromadb | latest | Local vector database | `pip install chromadb` |
| flask | latest | REST API server for RAG | `pip install flask` |
| python-dotenv | latest | Environment variable management | `pip install python-dotenv` |
| Python | 3.10+ | Chatbot and comparison scripts | pre-installed |
| curl | any | REST API testing (Step 4) | pre-installed |
| Docker | 24+ | Containerised deployment (Step 8) | `apt install docker.io` |

---

## Session Plan — 3 hours

> Steps 1–6 are complete. This session covers Steps 7–11 and the RAG feature.
> Mentor pace: max 5–6 exchanges per step. Issues are batched, not one-at-a-time.

| Block | Time | Scope |
| ----- | ---- | ----- |
| A | 0:00–0:25 | Step 7 — Modelfiles |
| B | 0:25–0:45 | Step 8 — Docker (read + config only, no deep dive) |
| C | 0:45–1:00 | Step 9 — Performance & quantization |
| D | 1:00–1:20 | Step 10 — Dev tool integrations |
| E | 1:20–1:40 | Step 11 — A/B testing script |
| F | 1:40–2:00 | RAG concepts + architecture design |
| G | 2:00–2:30 | RAG implementation — embed + vector DB |
| H | 2:30–3:00 | RAG implementation — query + Flask + end-to-end test |

---

## Step-by-step tutorial

### Step 1–6: Complete ✓

See `src/chatbot.py` — CLI chatbot with streaming, history persistence, command handling, model switching.

---

### Step 7: Create Custom Models with Modelfiles

**Goal:** Define a custom model variant with a baked-in system prompt and generation parameters.

**Key concepts:**
- `FROM` — base model to extend
- `SYSTEM` — prompt baked in at `ollama create` time, not passed per-call
- `PARAMETER temperature` — 0 = deterministic, 1 = creative
- `PARAMETER num_ctx` — context window in tokens (default: 2048; raise for long documents)
- `PARAMETER top_p` — nucleus sampling cutoff

**Deliverable:** Create `Modelfile` in project root. Build and verify the custom model. Update `DEFAULT_MODEL` in `chatbot.py` to use it.

```bash
# Save as Modelfile
FROM llama3.1:latest
SYSTEM """<your persona here>"""
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER num_ctx 4096

# Build
ollama create my-chatbot -f Modelfile

# Verify
ollama run my-chatbot "Hello, who are you?"
ollama list  # should show my-chatbot
```

**Verify:** `ollama list` shows your custom model. `chatbot.py` uses it by default and the system prompt no longer needs to be injected in `main()`.

---

### Step 8: Deploy Ollama with Docker

**Goal:** Run Ollama and Open WebUI as a Docker Compose stack with GPU passthrough.

**Key concepts:**
- `OLLAMA_HOST=0.0.0.0` — expose Ollama to other containers
- `deploy.resources.reservations.devices` — Docker GPU passthrough syntax
- Open WebUI — ChatGPT-like interface, runs locally on port 3000
- Volumes: model weights persist in `ollama_data` across container restarts

**Deliverable:** `docker-compose.yml` in project root. Stack runs, `curl http://localhost:11434/api/tags` responds, Open WebUI accessible at `http://localhost:3000`.

```bash
docker compose up -d
docker exec -it ollama ollama pull llama3.1:latest
curl http://localhost:11434/api/tags
```

**Skip criterion:** If Docker is not installed and time is short, read the compose config, understand the GPU passthrough syntax, and move on. This step is infrastructure, not Python.

---

### Step 9: Optimize Performance and Memory Usage

**Goal:** Understand quantization trade-offs and apply the right settings for your hardware.

**Key concepts:**

| Quantization | Bits | Llama 3.1 8B size | Quality loss | Speed (tokens/s) |
| ------------ | ---- | ----------------- | ------------ | ---------------- |
| F16 | 16 | 16 GB | None | 25–40 |
| Q8_0 | 8 | 8.5 GB | Negligible | 45–70 |
| Q4_K_M | 4 | 4.9 GB | Slight | 70–110 |
| Q4_0 | 4 | 4.7 GB | Slight | 75–120 |

- `num_ctx` vs RAM: 8192-token context on an 8B model adds ~1 GB RAM
- `OLLAMA_NUM_PARALLEL` — concurrent requests (default: 1)
- GPU offloading: `ollama ps` shows processor column; CPU-only = very slow

**Deliverable:** Pull `llama3.1:8b-instruct-q4_K_M` and benchmark it vs `llama3.1:latest`.

```bash
ollama pull llama3.1:8b-instruct-q4_K_M
ollama ps  # confirm GPU usage
```

---

### Step 10: Set Up Ollama as a Development Tool

**Goal:** Wire Ollama into your dev workflow via the Continue VSCode extension and a shell helper.

**Key concepts:**
- Continue extension (`continue.dev`) — tab completion + inline chat powered by local model
- `ollama run <model> "<prompt>"` is pipeable — any shell output can be fed to the LLM

**Deliverable:** Install Continue. Add the `ai-commit` shell function to `~/.bashrc`. Stage a change and run it.

```bash
# ~/.bashrc
ai-commit() {
  local diff=$(git diff --cached)
  [ -z "$diff" ] && echo "No staged changes." && return 1
  local msg=$(echo "$diff" | ollama run llama3.1:latest \
    "Generate a concise git commit message (max 72 chars) for this diff:")
  echo "Suggested: $msg"
  read -p "Use? (y/n) " choice
  [ "$choice" = "y" ] && git commit -m "$msg"
}
```

**Verify:** `ai-commit` runs after `git add` and suggests a message.

---

### Step 11: Run Multiple Models and A/B Test Responses

**Goal:** Write a benchmarking script that queries multiple models and compares latency and output.

**Key concepts:**
- `response['eval_count']` — token count from Ollama response dict
- `response['eval_duration']` — nanoseconds; divide by `1e9` for seconds
- LLM-as-judge pattern: use a third model to score the outputs automatically

**Deliverable:** `src/compare_models.py` — runs the same prompt across all installed models, prints response + tokens/s.

```python
# src/compare_models.py
import ollama, time

PROMPT = "..."  # your test prompt
MODELS = [m.model for m in ollama.list().models]
```

**Verify:** Script runs, prints per-model output and tokens/s metric.

---

### Step 12: RAG — Retrieval-Augmented Generation

**Goal:** Build a Flask API that lets users upload a PDF, embed it into ChromaDB, and query it locally using LangChain + Ollama. No cloud, no external APIs.

**Why RAG, not fine-tuning?**
- Fine-tuning requires GPU hours, labeled data, and retraining on every update.
- RAG retrieves relevant chunks at query time — zero retraining, always up-to-date, domain-specific.

**Architecture:**
```
POST /embed  →  PDF → split chunks → OllamaEmbeddings → ChromaDB
POST /query  →  question → MultiQueryRetriever → top-k chunks → LLM → answer
```

**Key concepts:**
- `RecursiveCharacterTextSplitter(chunk_size=7500, chunk_overlap=100)` — splits text into overlapping chunks to preserve context at boundaries
- `OllamaEmbeddings(model="nomic-embed-text")` — converts text to vectors locally
- `Chroma` — persists vectors to disk; no external DB needed
- `MultiQueryRetriever` — rephrases the question 5 ways to improve recall
- LCEL chain: `{"context": retriever, "question": RunnablePassthrough()} | prompt | llm | StrOutputParser()`

**Dependencies to install:**
```bash
pip install langchain langchain-community chromadb flask python-dotenv werkzeug unstructured
ollama pull nomic-embed-text
```

**Project structure:**
```
src/
├── chatbot.py          # Step 6 — CLI chatbot (done)
├── compare_models.py   # Step 11 — A/B tester
├── app.py              # Step 12 — Flask API server
├── embed.py            # Step 12 — PDF ingestion + embedding
├── query.py            # Step 12 — retrieval + LLM answer
└── get_vector_db.py    # Step 12 — ChromaDB initializer
_temp/                  # uploaded PDFs (temp storage)
chroma/                 # ChromaDB persisted vectors
.env                    # TEMP_FOLDER, CHROMA_PATH, LLM_MODEL, TEXT_EMBEDDING_MODEL
```

**Environment variables (`.env`):**
```
TEMP_FOLDER=./_temp
CHROMA_PATH=chroma
COLLECTION_NAME=rag-local
LLM_MODEL=llama3.1:latest
TEXT_EMBEDDING_MODEL=nomic-embed-text
```

**Verify:**
```bash
# Start server
python3 src/app.py

# Embed a PDF
curl -X POST http://localhost:8080/embed \
  -F "file=@docs/How to Run LLMs Locally with Ollama in 11 Steps [2026].pdf"
# Expected: {"message": "File embedded successfully"}

# Query it
curl -X POST http://localhost:8080/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What quantization level gives the best quality-speed trade-off?"}'
# Expected: answer grounded in the PDF content
```

---

## Testing

```bash
# Run placeholder tests
pytest tests/

# Manual RAG test (after embedding a PDF)
curl -X POST http://localhost:8080/query \
  -H "Content-Type: application/json" \
  -d '{"query": "Summarize the main steps to install Ollama"}'
```

## Deployment

- **Local CLI:** `python3 src/chatbot.py`
- **Docker stack:** `docker compose up -d` (Step 8)
- **RAG server:** `python3 src/app.py` (port 8080)

## Resources

1. [Ollama GitHub](https://github.com/ollama/ollama) — source, issue tracker, and release notes
2. [Ollama model library](https://ollama.com/library) — all available models with pull counts and sizes
3. [Ollama REST API reference](https://github.com/ollama/ollama/blob/main/docs/api.md) — full endpoint documentation
4. [Ollama Python SDK](https://github.com/ollama/ollama-python) — source and examples for the `ollama` package
5. [Open WebUI](https://github.com/open-webui/open-webui) — the ChatGPT-like web UI used in Step 8
6. [LangChain Ollama integration](https://python.langchain.com/docs/integrations/llms/ollama/) — LCEL chains + Ollama
7. [ChromaDB docs](https://docs.trychroma.com/) — vector store API reference

## Skill coverage mapping

| Step | Primary skill |
| ---- | ------------- |
| 1–3 | Local LLM inference |
| 4 | REST API consumption |
| 5 | Python LLM integration |
| 6 | Python LLM integration + prompt engineering |
| 7 | Prompt engineering (Modelfiles) |
| 8 | Docker deployment |
| 9 | Performance optimisation |
| 10 | Python LLM integration (dev tooling) |
| 11 | Model evaluation |
| 12 | RAG architecture + LangChain orchestration |
