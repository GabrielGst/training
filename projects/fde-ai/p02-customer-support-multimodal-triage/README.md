# P02 — Customer Support Multimodal Triage

**Domain:** Customer Support / Service Operations  **Track:** `fde-ai`  **Status:** not started  **Hours target:** 35

## Business Problem

Support teams receive 500+ tickets per day across email, chat, phone, and video channels, and 50% are misrouted on first contact because agents manually read each one and guess the category. Escalation to specialists takes 2+ days and CSAT scores suffer. This project automates multimodal intake — transcribing calls with Whisper, extracting sentiment and intent with Mistral, classifying issue category, retrieving relevant knowledge-base articles via RAG, and either auto-drafting a resolution or escalating with full context pre-packaged for the specialist.

## What you will build

- A multimodal ingestion service that accepts audio uploads (Whisper transcription), email text, and chat logs via a single Express.js API
- A LangChain classification + RAG pipeline that extracts intent, sentiment, and category, then retrieves KB articles from Qdrant
- A Mistral-powered response drafter that either generates a resolution or escalates with structured context
- A GCP Cloud Run deployment wired to Pub/Sub for async ticket processing
- A Grafana dashboard tracking resolution rate, escalation rate, CSAT proxy, and per-category latency
- A Zendesk API integration that writes triage results back as ticket tags and internal notes

## Architecture

```
Incoming tickets (email / chat / audio)
            |
            v
  Express.js ingestion API  (Node.js, Docker)
   ├── Audio → Whisper (transcription + language detection)
   ├── Text → sanitize + normalize
   └── Publish to GCP Pub/Sub topic: "raw-tickets"
            |
            v
  GCP Cloud Run worker  (subscribes to Pub/Sub)
   ├── LangChain: sentiment extraction (Mistral API)
   ├── LangChain: intent classification (few-shot)
   ├── Qdrant: KB article retrieval (semantic search)
   └── Mistral API: draft response OR escalation summary
            |
        ┌───┴───┐
        v       v
  MongoDB       Qdrant
  (ticket       (KB article
   store)        embeddings)
        |
        v
  Zendesk API  ← write tags + internal notes
        |
        v
  Grafana dashboard  (metrics from Prometheus)
```

## Skills covered

| Skill ID | Skill Name | What you practice |
|----------|------------|------------------|
| SK02 | RAG Architecture Design | Building a KB article index in Qdrant with chunked documents, HNSW tuning, and metadata filtering |
| SK03 | Prompt Engineering and System Design | Few-shot classification prompts, sentiment prompts, and response-drafting system prompts for Mistral |
| SK08 | Observability and Production Debugging | Instrumenting the pipeline with Prometheus counters and Grafana panels for ticket-level tracing |
| SK09 | Cross-functional Stakeholder Engagement | Mapping support team workflows to system events and defining escalation criteria with the operations team |
| SK10 | Business Impact and ROI Quantification | Measuring % tickets auto-resolved, CSAT delta, and time-to-resolution before/after |
| SK11 | Structured Output Extraction and Parsing | Extracting JSON-structured triage results (category, sentiment score, intent) with Pydantic validation |
| SK12 | Customer Feedback Loops and Iteration | Building a feedback loop where agents rate auto-drafts to retrain classification prompts |
| SK13 | Agentic Workflows and Tool Use | Designing a multi-step LangChain agent that conditionally drafts or escalates based on confidence score |
| SK15 | Real-time Integration and Event Streaming | Using GCP Pub/Sub to decouple ingestion from processing and enable backpressure handling |
| SK16 | Feature Engineering and Model Architecture | Engineering features (ticket length, hour of day, channel type) for escalation routing heuristics |

## Tools & dependencies

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| LangChain | latest | LLM orchestration, chain building, KB retrieval | `pip install langchain langchain-community` |
| Mistral API | latest | Intent classification, sentiment extraction, response drafting | `pip install mistralai` |
| Whisper | latest | Audio-to-text transcription for phone and video tickets | `pip install openai-whisper` |
| Qdrant | 1.9+ | Vector database for KB article semantic search | `docker pull qdrant/qdrant` |
| MongoDB | 7+ | Document store for raw tickets and triage results | `docker pull mongo` |
| Express.js | 4+ | Node.js REST API for ticket ingestion | `npm install express multer` |
| Docker | 25+ | Container runtime for local development and GCP deployment | docker.com |
| GCP Cloud Run | N/A | Serverless container platform for the async worker | gcloud CLI |
| Pub/Sub | N/A | Managed message queue for async ticket dispatch | `pip install google-cloud-pubsub` |
| Grafana | 10+ | Dashboard for resolution metrics and latency | `docker pull grafana/grafana` |
| Zendesk API | v2 | Ticket management: read tickets, write tags and notes | `npm install node-zendesk` |
| Prometheus | 2+ | Metrics scraping for Grafana | `docker pull prom/prometheus` |
| Pydantic | 2+ | Structured output validation for triage results | `pip install pydantic` |

## Prerequisites

**Track modules to complete first:**
- [ ] `ai-agents/01-llm-fundamentals` — token budgets, structured outputs, and few-shot prompting
- [ ] `ai-agents/02-langchain` — chains, output parsers, and document loaders
- [ ] `ai-agents/03-langgraph` — conditional branching and multi-step agentic workflows
- [ ] `software-engineer/05-orchestration` — Docker Compose, container networking, and GCP Cloud Run

**Accounts / API keys needed:**
- [ ] Mistral API key — mistral.ai
- [ ] GCP project with Cloud Run and Pub/Sub APIs enabled — console.cloud.google.com
- [ ] Zendesk account with API token — zendesk.com (sandbox available)
- [ ] OpenAI API key (optional) — Whisper can run locally without it

## Step-by-step tutorial

### Step 1: Environment setup

**Goal:** Stand up the full local stack with Docker Compose before writing any application code.

Create the project structure:

```
p02-customer-support-multimodal-triage/
├── ingestion/                   # Node.js Express API
│   ├── src/
│   │   ├── index.ts
│   │   ├── routes/tickets.ts
│   │   └── pubsub.ts
│   ├── package.json
│   └── Dockerfile
├── worker/                      # Python processing worker
│   ├── app/
│   │   ├── __init__.py
│   │   ├── consumer.py
│   │   ├── transcription.py
│   │   ├── triage.py
│   │   ├── retrieval.py
│   │   └── zendesk.py
│   ├── requirements.txt
│   └── Dockerfile
├── infra/
│   ├── docker-compose.yml
│   ├── prometheus.yml
│   └── grafana/
│       └── dashboards/triage.json
└── .env.example
```

Create `.env.example`:

```env
MISTRAL_API_KEY=your_key_here
QDRANT_HOST=localhost
QDRANT_PORT=6333
MONGODB_URI=mongodb://localhost:27017/support_triage
ZENDESK_SUBDOMAIN=yourcompany
ZENDESK_EMAIL=agent@yourcompany.com
ZENDESK_API_TOKEN=your_token_here
GCP_PROJECT_ID=your_project
PUBSUB_TOPIC=raw-tickets
PUBSUB_SUBSCRIPTION=worker-sub
```

Create `infra/docker-compose.yml`:

```yaml
version: "3.9"
services:
  qdrant:
    image: qdrant/qdrant:latest
    ports:
      - "6333:6333"
    volumes:
      - qdrant_storage:/qdrant/storage

  mongodb:
    image: mongo:7
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards

volumes:
  qdrant_storage:
  mongo_data:
  grafana_data:
```

**Verify:**

```bash
docker compose -f infra/docker-compose.yml up -d
curl http://localhost:6333/healthz
# Expected: {"title":"qdrant - vector search engine"}
```

### Step 2: Whisper transcription service

**Goal:** Accept audio file uploads and return clean transcriptions with detected language.

Install Python worker dependencies:

```bash
cd worker
python -m venv .venv && source .venv/bin/activate
pip install openai-whisper mistralai langchain langchain-community \
    qdrant-client pymongo pydantic python-dotenv \
    google-cloud-pubsub prometheus-client requests
pip freeze > requirements.txt
```

Create `worker/app/transcription.py`:

```python
import whisper
import tempfile
import os
from pathlib import Path
from dataclasses import dataclass

_model = None  # lazy-load to avoid startup delay


def get_model(size: str = "base") -> whisper.Whisper:
    global _model
    if _model is None:
        _model = whisper.load_model(size)
    return _model


@dataclass
class TranscriptionResult:
    text: str
    language: str
    duration_seconds: float


def transcribe_audio(audio_bytes: bytes, filename: str = "audio.wav") -> TranscriptionResult:
    """Transcribe audio bytes using Whisper and return structured result."""
    model = get_model("base")

    with tempfile.NamedTemporaryFile(suffix=Path(filename).suffix, delete=False) as f:
        f.write(audio_bytes)
        tmp_path = f.name

    try:
        result = model.transcribe(tmp_path, fp16=False)
        return TranscriptionResult(
            text=result["text"].strip(),
            language=result["language"],
            duration_seconds=result.get("duration", 0.0),
        )
    finally:
        os.unlink(tmp_path)
```

**Verify:**

```bash
python -c "
from app.transcription import transcribe_audio
# Create a silent test WAV (requires scipy or soundfile)
import numpy as np, soundfile as sf, io
buf = io.BytesIO()
sf.write(buf, np.zeros(16000), 16000, format='WAV')
result = transcribe_audio(buf.getvalue(), 'test.wav')
print(f'Language: {result.language}, Text: \"{result.text}\"')
"
```

### Step 3: Qdrant KB article index

**Goal:** Load knowledge-base articles into Qdrant with Mistral embeddings so the triage worker can retrieve relevant solutions.

Create `worker/app/retrieval.py`:

```python
from qdrant_client import QdrantClient
from qdrant_client.models import (
    Distance, VectorParams, PointStruct, Filter, FieldCondition, MatchValue
)
from mistralai import Mistral
from typing import List, Dict
import os
import uuid

mistral = Mistral(api_key=os.environ["MISTRAL_API_KEY"])
qdrant = QdrantClient(
    host=os.environ.get("QDRANT_HOST", "localhost"),
    port=int(os.environ.get("QDRANT_PORT", 6333)),
)

COLLECTION_NAME = "kb_articles"
EMBED_MODEL = "mistral-embed"
EMBED_DIM = 1024


def ensure_collection():
    existing = [c.name for c in qdrant.get_collections().collections]
    if COLLECTION_NAME not in existing:
        qdrant.create_collection(
            collection_name=COLLECTION_NAME,
            vectors_config=VectorParams(size=EMBED_DIM, distance=Distance.COSINE),
        )


def embed_texts(texts: List[str]) -> List[List[float]]:
    response = mistral.embeddings.create(model=EMBED_MODEL, inputs=texts)
    return [item.embedding for item in response.data]


def index_kb_articles(articles: List[Dict]) -> int:
    """
    articles: list of dicts with keys: title, content, category, tags
    Returns count of indexed articles.
    """
    ensure_collection()

    texts = [f"{a['title']}\n\n{a['content']}" for a in articles]
    embeddings = embed_texts(texts)

    points = [
        PointStruct(
            id=str(uuid.uuid4()),
            vector=emb,
            payload={
                "title": a["title"],
                "content": a["content"][:500],
                "category": a["category"],
                "tags": a.get("tags", []),
            },
        )
        for a, emb in zip(articles, embeddings)
    ]

    qdrant.upsert(collection_name=COLLECTION_NAME, points=points)
    return len(points)


def retrieve_kb_articles(
    query: str,
    category_filter: str | None = None,
    top_k: int = 3,
) -> List[Dict]:
    query_emb = embed_texts([query])[0]

    search_filter = None
    if category_filter:
        search_filter = Filter(
            must=[FieldCondition(key="category", match=MatchValue(value=category_filter))]
        )

    results = qdrant.search(
        collection_name=COLLECTION_NAME,
        query_vector=query_emb,
        query_filter=search_filter,
        limit=top_k,
        with_payload=True,
    )

    return [
        {
            "title": r.payload["title"],
            "content": r.payload["content"],
            "category": r.payload["category"],
            "score": r.score,
        }
        for r in results
    ]
```

Seed the index with sample KB data:

```python
# worker/scripts/seed_kb.py
import os, sys
sys.path.insert(0, "..")
from app.retrieval import index_kb_articles

SAMPLE_ARTICLES = [
    {
        "title": "Reset password via email",
        "content": "Go to Settings > Account > Reset Password. Enter your email and click Send Reset Link. Check spam folder if not received within 5 minutes.",
        "category": "account",
        "tags": ["password", "login", "access"],
    },
    {
        "title": "Billing dispute process",
        "content": "For unauthorized charges, navigate to Billing > Dispute Charge. Provide transaction ID and description. Resolution within 3-5 business days.",
        "category": "billing",
        "tags": ["charge", "refund", "invoice"],
    },
    {
        "title": "API rate limit exceeded error",
        "content": "HTTP 429 means you've exceeded your plan limits. Check your current usage in the developer dashboard. Upgrade your plan or implement exponential backoff.",
        "category": "technical",
        "tags": ["api", "rate-limit", "429", "developer"],
    },
]

count = index_kb_articles(SAMPLE_ARTICLES)
print(f"Indexed {count} KB articles")
```

**Verify:**

```bash
python scripts/seed_kb.py
# Expected: Indexed 3 KB articles

python -c "
from app.retrieval import retrieve_kb_articles
results = retrieve_kb_articles('I forgot my password and cannot log in')
for r in results:
    print(f'{r[\"score\"]:.3f} | {r[\"title\"]}')
# Expected top result: Reset password via email
"
```

### Step 4: Triage pipeline — classification, sentiment, and response drafting

**Goal:** Build the LangChain pipeline that classifies intent, extracts sentiment, retrieves KB context, and generates a structured triage result.

Create `worker/app/triage.py`:

```python
from mistralai import Mistral
from langchain_core.prompts import ChatPromptTemplate
from pydantic import BaseModel, Field
from typing import List, Optional
import json
import os
import re

mistral = Mistral(api_key=os.environ["MISTRAL_API_KEY"])


class TriageResult(BaseModel):
    category: str = Field(..., description="billing|technical|account|shipping|other")
    intent: str = Field(..., description="Short phrase describing what the user wants")
    sentiment: str = Field(..., description="positive|neutral|frustrated|angry")
    sentiment_score: float = Field(..., ge=-1.0, le=1.0)
    confidence: float = Field(..., ge=0.0, le=1.0)
    suggested_response: Optional[str] = None
    escalate: bool = False
    escalation_reason: Optional[str] = None
    kb_articles_used: List[str] = Field(default_factory=list)


TRIAGE_SYSTEM = """You are a customer support triage AI. Analyze the ticket and respond with ONLY valid JSON.

Categories: billing, technical, account, shipping, other
Sentiment: positive, neutral, frustrated, angry
Sentiment score: -1.0 (very negative) to 1.0 (very positive)
Confidence: how confident you are in the classification (0.0-1.0)
Escalate: true if the issue requires human specialist (angry customer, legal threat, complex billing dispute, data breach concern)

Return JSON:
{
  "category": "<category>",
  "intent": "<what the user wants in 5-10 words>",
  "sentiment": "<sentiment>",
  "sentiment_score": <float>,
  "confidence": <float>,
  "escalate": <bool>,
  "escalation_reason": "<reason if escalate=true, else null>"
}"""

DRAFT_SYSTEM = """You are a helpful customer support agent. Using the ticket context and relevant KB articles,
draft a clear, empathetic response. If you cannot resolve fully from the KB, acknowledge the issue and
explain next steps. Keep responses under 150 words."""


def classify_ticket(text: str) -> TriageResult:
    response = mistral.chat.complete(
        model="mistral-large-latest",
        messages=[
            {"role": "system", "content": TRIAGE_SYSTEM},
            {"role": "user", "content": f"Ticket:\n{text[:3000]}"},
        ],
        temperature=0.1,
    )
    raw = response.choices[0].message.content.strip()
    raw = re.sub(r"^```(?:json)?\s*", "", raw)
    raw = re.sub(r"\s*```$", "", raw)
    data = json.loads(raw)
    return TriageResult(**data)


def draft_response(ticket_text: str, triage: TriageResult, kb_articles: list) -> str:
    kb_context = "\n".join(
        f"- [{a['title']}]: {a['content']}" for a in kb_articles
    ) or "No relevant KB articles found."

    response = mistral.chat.complete(
        model="mistral-large-latest",
        messages=[
            {"role": "system", "content": DRAFT_SYSTEM},
            {
                "role": "user",
                "content": (
                    f"Customer ticket (category: {triage.category}, intent: {triage.intent}):\n"
                    f"{ticket_text[:2000]}\n\n"
                    f"Relevant KB articles:\n{kb_context}"
                ),
            },
        ],
        temperature=0.4,
    )
    return response.choices[0].message.content.strip()


def full_triage_pipeline(ticket_text: str) -> TriageResult:
    from app.retrieval import retrieve_kb_articles

    # Step 1: classify
    triage = classify_ticket(ticket_text)

    # Step 2: retrieve KB articles using category filter for precision
    kb = retrieve_kb_articles(ticket_text, category_filter=triage.category, top_k=3)

    # Step 3: draft response only if not escalating
    if not triage.escalate:
        triage.suggested_response = draft_response(ticket_text, triage, kb)
        triage.kb_articles_used = [a["title"] for a in kb]

    return triage
```

**Verify:**

```bash
python -c "
from app.triage import full_triage_pipeline
result = full_triage_pipeline('Hi, I was charged twice for my subscription this month and I need a refund immediately. This is unacceptable!')
print(result.model_dump_json(indent=2))
# Expected: category=billing, sentiment=frustrated, escalate likely False with draft response
"
```

### Step 5: Express.js ingestion API

**Goal:** Accept tickets from email, chat, and audio channels and publish them to Pub/Sub for async processing.

```bash
cd ingestion
npm init -y
npm install express multer @google-cloud/pubsub mongodb dotenv typescript ts-node @types/node @types/express @types/multer
npx tsc --init
```

Create `ingestion/src/index.ts`:

```typescript
import express from "express";
import multer from "multer";
import { publishTicket } from "./pubsub";
import { MongoClient } from "mongodb";
import { v4 as uuidv4 } from "uuid";

const app = express();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 25 * 1024 * 1024 } });
app.use(express.json());

const mongo = new MongoClient(process.env.MONGODB_URI!);
let tickets: any;

mongo.connect().then(() => {
  tickets = mongo.db("support_triage").collection("tickets");
  console.log("MongoDB connected");
});

// POST /tickets/text — email or chat text
app.post("/tickets/text", async (req, res) => {
  const { body: content, channel = "email", subject = "" } = req.body;
  if (!content) return res.status(400).json({ error: "body required" });

  const ticketId = uuidv4();
  const doc = {
    _id: ticketId,
    channel,
    subject,
    raw_text: content,
    status: "pending",
    created_at: new Date(),
  };

  await tickets.insertOne(doc);
  await publishTicket({ ticket_id: ticketId, channel, text: content });

  res.status(202).json({ ticket_id: ticketId });
});

// POST /tickets/audio — phone or video recording
app.post("/tickets/audio", upload.single("file"), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: "file required" });

  const ticketId = uuidv4();
  const doc = {
    _id: ticketId,
    channel: "audio",
    audio_filename: req.file.originalname,
    audio_bytes_base64: req.file.buffer.toString("base64"),
    status: "pending",
    created_at: new Date(),
  };

  await tickets.insertOne(doc);
  await publishTicket({
    ticket_id: ticketId,
    channel: "audio",
    audio_b64: req.file.buffer.toString("base64"),
    filename: req.file.originalname,
  });

  res.status(202).json({ ticket_id: ticketId });
});

// GET /tickets/:id — poll for triage results
app.get("/tickets/:id", async (req, res) => {
  const doc = await tickets.findOne({ _id: req.params.id });
  if (!doc) return res.status(404).json({ error: "not found" });
  res.json(doc);
});

app.get("/health", (_, res) => res.json({ status: "ok" }));

app.listen(4000, () => console.log("Ingestion API listening on :4000"));
```

Create `ingestion/src/pubsub.ts`:

```typescript
import { PubSub } from "@google-cloud/pubsub";

const pubsub = new PubSub({ projectId: process.env.GCP_PROJECT_ID });
const topicName = process.env.PUBSUB_TOPIC || "raw-tickets";

export async function publishTicket(payload: object): Promise<string> {
  const topic = pubsub.topic(topicName);
  const data = Buffer.from(JSON.stringify(payload));
  const messageId = await topic.publishMessage({ data });
  return messageId;
}
```

**Verify:**

```bash
cd ingestion && npx ts-node src/index.ts &
curl -X POST http://localhost:4000/tickets/text \
  -H "Content-Type: application/json" \
  -d '{"body": "I cannot log in to my account since yesterday", "channel": "email"}'
# Expected: {"ticket_id":"<uuid>"}
```

### Step 6: Pub/Sub consumer worker

**Goal:** Subscribe to the Pub/Sub topic, process each ticket through the full triage pipeline, and write results to MongoDB and Zendesk.

Create `worker/app/consumer.py`:

```python
from google.cloud import pubsub_v1
from pymongo import MongoClient
import json
import base64
import os
from app.transcription import transcribe_audio
from app.triage import full_triage_pipeline
from prometheus_client import Counter, Histogram, start_http_server
import time

# Prometheus metrics
tickets_processed = Counter("tickets_processed_total", "Total tickets processed", ["category", "escalated"])
triage_latency = Histogram("triage_latency_seconds", "Triage pipeline latency")
transcription_latency = Histogram("transcription_latency_seconds", "Whisper transcription latency")

mongo = MongoClient(os.environ["MONGODB_URI"])
db = mongo["support_triage"]
tickets_col = db["tickets"]

subscriber = pubsub_v1.SubscriberClient()
subscription_path = subscriber.subscription_path(
    os.environ["GCP_PROJECT_ID"],
    os.environ["PUBSUB_SUBSCRIPTION"],
)


def process_message(message: pubsub_v1.subscriber.message.Message) -> None:
    data = json.loads(message.data.decode("utf-8"))
    ticket_id = data["ticket_id"]
    channel = data.get("channel", "text")

    try:
        # Transcribe audio if needed
        if channel == "audio":
            t0 = time.time()
            audio_bytes = base64.b64decode(data["audio_b64"])
            transcription = transcribe_audio(audio_bytes, data.get("filename", "audio.wav"))
            text = transcription.text
            transcription_latency.observe(time.time() - t0)
        else:
            text = data.get("text", "")

        if not text.strip():
            tickets_col.update_one(
                {"_id": ticket_id},
                {"$set": {"status": "failed", "error": "empty text"}},
            )
            message.ack()
            return

        # Run triage pipeline
        t0 = time.time()
        triage = full_triage_pipeline(text)
        triage_latency.observe(time.time() - t0)

        # Update MongoDB
        tickets_col.update_one(
            {"_id": ticket_id},
            {
                "$set": {
                    "status": "triaged",
                    "triage": triage.model_dump(),
                    "processed_at": __import__("datetime").datetime.utcnow(),
                }
            },
        )

        tickets_processed.labels(
            category=triage.category,
            escalated=str(triage.escalate),
        ).inc()

        message.ack()

    except Exception as e:
        print(f"Error processing ticket {ticket_id}: {e}")
        tickets_col.update_one(
            {"_id": ticket_id},
            {"$set": {"status": "failed", "error": str(e)}},
        )
        message.nack()


def run():
    # Expose Prometheus metrics on :8001
    start_http_server(8001)
    print(f"Subscribing to {subscription_path}")
    streaming_pull = subscriber.subscribe(subscription_path, callback=process_message)
    print("Worker running. Press Ctrl+C to exit.")
    try:
        streaming_pull.result()
    except KeyboardInterrupt:
        streaming_pull.cancel()


if __name__ == "__main__":
    run()
```

**Verify:**

```bash
cd worker && python -m app.consumer &
# Then publish a test message via the ingestion API
curl -X POST http://localhost:4000/tickets/text \
  -H "Content-Type: application/json" \
  -d '{"body": "My API keeps returning 429 errors", "channel": "chat"}'
# Poll MongoDB for the result:
sleep 10
python -c "
from pymongo import MongoClient
import os
c = MongoClient(os.environ['MONGODB_URI'])
doc = c['support_triage']['tickets'].find_one(sort=[('created_at', -1)])
print(doc.get('triage', {}).get('category'), doc.get('status'))
# Expected: technical triaged
"
```

### Step 7: Zendesk integration

**Goal:** Write triage results back to Zendesk tickets as tags and internal notes so agents see context immediately.

Create `worker/app/zendesk.py`:

```python
import requests
import os
from typing import Optional

BASE_URL = f"https://{os.environ['ZENDESK_SUBDOMAIN']}.zendesk.com/api/v2"
AUTH = (
    f"{os.environ['ZENDESK_EMAIL']}/token",
    os.environ["ZENDESK_API_TOKEN"],
)


def add_triage_to_zendesk(zendesk_ticket_id: int, triage: dict) -> bool:
    """Add triage category as tag and post internal note with full results."""

    # Add tags
    tags_url = f"{BASE_URL}/tickets/{zendesk_ticket_id}/tags.json"
    tags = [triage["category"], f"sentiment-{triage['sentiment']}"]
    if triage.get("escalate"):
        tags.append("escalate-required")

    resp = requests.put(tags_url, json={"tags": tags}, auth=AUTH)
    if resp.status_code not in (200, 201):
        print(f"Failed to set tags: {resp.status_code} {resp.text}")
        return False

    # Post internal note
    note_body = f"""**AI Triage Results**
- Category: {triage['category']}
- Intent: {triage['intent']}
- Sentiment: {triage['sentiment']} ({triage['sentiment_score']:.2f})
- Confidence: {triage['confidence']:.0%}
- Escalate: {'YES — ' + triage.get('escalation_reason', '') if triage['escalate'] else 'No'}

**Suggested Response:**
{triage.get('suggested_response') or '(escalation — no draft generated)'}

**KB Articles Used:**
{chr(10).join('- ' + a for a in triage.get('kb_articles_used', [])) or 'None'}
"""

    comment_url = f"{BASE_URL}/tickets/{zendesk_ticket_id}.json"
    payload = {
        "ticket": {
            "comment": {
                "body": note_body,
                "public": False,  # internal note only
            }
        }
    }
    resp = requests.put(comment_url, json=payload, auth=AUTH)
    return resp.status_code in (200, 201)
```

**Verify:**

```bash
python -c "
from app.zendesk import add_triage_to_zendesk
ok = add_triage_to_zendesk(1, {
    'category': 'billing',
    'intent': 'request refund for duplicate charge',
    'sentiment': 'frustrated',
    'sentiment_score': -0.6,
    'confidence': 0.91,
    'escalate': False,
    'suggested_response': 'We understand your concern...',
    'kb_articles_used': ['Billing dispute process'],
})
print('Success:', ok)
"
```

### Step 8: Grafana observability dashboard

**Goal:** Visualize ticket throughput, auto-resolution rate, escalation rate, and per-category latency in Grafana.

Create `infra/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "triage_worker"
    static_configs:
      - targets: ["host.docker.internal:8001"]
```

Create `infra/grafana/dashboards/triage.json` (key panels):

```json
{
  "title": "Support Triage Dashboard",
  "panels": [
    {
      "title": "Tickets Processed / min",
      "type": "timeseries",
      "targets": [
        { "expr": "rate(tickets_processed_total[1m]) * 60" }
      ]
    },
    {
      "title": "Auto-Resolution Rate",
      "type": "stat",
      "targets": [
        {
          "expr": "sum(tickets_processed_total{escalated='False'}) / sum(tickets_processed_total)"
        }
      ]
    },
    {
      "title": "Triage Latency P95",
      "type": "stat",
      "targets": [
        { "expr": "histogram_quantile(0.95, rate(triage_latency_seconds_bucket[5m]))" }
      ]
    },
    {
      "title": "Tickets by Category",
      "type": "piechart",
      "targets": [
        { "expr": "sum by (category) (tickets_processed_total)" }
      ]
    }
  ]
}
```

**Verify:**

```bash
# Open Grafana
open http://localhost:3001  # admin / admin
# Import the triage.json dashboard
# Send 10 test tickets and confirm metrics appear
for i in {1..10}; do
  curl -sX POST http://localhost:4000/tickets/text \
    -H "Content-Type: application/json" \
    -d "{\"body\": \"Test ticket $i\", \"channel\": \"chat\"}" > /dev/null
done
# Expected: Grafana shows ~10 tickets processed
```

### Step 9: Testing

**Goal:** Unit test the classification, retrieval, and transcription layers; integration test the full pipeline.

Create `worker/tests/test_triage.py`:

```python
import pytest
from unittest.mock import patch, MagicMock
from app.triage import classify_ticket, TriageResult


BILLING_TICKET = "I was charged $99 twice this month and need a refund."
TECHNICAL_TICKET = "My API returns 429 Too Many Requests on every call."
ANGRY_TICKET = "This is a complete scam! I'm calling my bank to dispute every charge. Legal action!"


@patch("app.triage.mistral")
def test_classify_billing(mock_mistral):
    mock_resp = MagicMock()
    mock_resp.choices[0].message.content = """{
        "category": "billing",
        "intent": "request refund for duplicate charge",
        "sentiment": "frustrated",
        "sentiment_score": -0.5,
        "confidence": 0.93,
        "escalate": false,
        "escalation_reason": null
    }"""
    mock_mistral.chat.complete.return_value = mock_resp

    result = classify_ticket(BILLING_TICKET)
    assert result.category == "billing"
    assert result.sentiment == "frustrated"
    assert not result.escalate


@patch("app.triage.mistral")
def test_escalation_flag(mock_mistral):
    mock_resp = MagicMock()
    mock_resp.choices[0].message.content = """{
        "category": "billing",
        "intent": "legal threat and chargeback",
        "sentiment": "angry",
        "sentiment_score": -0.95,
        "confidence": 0.88,
        "escalate": true,
        "escalation_reason": "legal threat mentioned"
    }"""
    mock_mistral.chat.complete.return_value = mock_resp

    result = classify_ticket(ANGRY_TICKET)
    assert result.escalate is True
    assert result.escalation_reason is not None


def test_triage_result_validates_scores():
    with pytest.raises(Exception):
        TriageResult(
            category="billing",
            intent="test",
            sentiment="neutral",
            sentiment_score=2.0,  # invalid: > 1.0
            confidence=0.9,
        )
```

```bash
cd worker && pytest tests/ -v --tb=short
# Expected: all tests pass
```

### Step 10: Docker build and GCP Cloud Run deployment

**Goal:** Containerize the worker and deploy to GCP Cloud Run with Pub/Sub trigger.

Create `worker/Dockerfile`:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y ffmpeg && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

CMD ["python", "-m", "app.consumer"]
```

```bash
# Build and push to GCP Artifact Registry
gcloud auth configure-docker us-central1-docker.pkg.dev

docker build -t us-central1-docker.pkg.dev/YOUR_PROJECT/support/triage-worker:latest worker/
docker push us-central1-docker.pkg.dev/YOUR_PROJECT/support/triage-worker:latest

# Deploy to Cloud Run
gcloud run deploy triage-worker \
  --image us-central1-docker.pkg.dev/YOUR_PROJECT/support/triage-worker:latest \
  --region us-central1 \
  --platform managed \
  --no-allow-unauthenticated \
  --set-env-vars "MISTRAL_API_KEY=YOUR_KEY,QDRANT_HOST=YOUR_QDRANT_IP,GCP_PROJECT_ID=YOUR_PROJECT,PUBSUB_SUBSCRIPTION=worker-sub,MONGODB_URI=YOUR_MONGO_URI"

# Create Pub/Sub push subscription to Cloud Run
gcloud pubsub subscriptions create worker-sub \
  --topic raw-tickets \
  --push-endpoint https://triage-worker-HASH-uc.a.run.app/_pubsub \
  --ack-deadline 300
```

**Verify:**

```bash
gcloud run services describe triage-worker --region us-central1 --format="value(status.url)"
# POST a ticket and watch Cloud Run logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=triage-worker" \
  --limit 20 --format json | jq '.[].textPayload'
```

## Testing

```bash
# Full Python test suite
cd worker && pytest tests/ -v --cov=app --cov-report=term-missing

# Integration test: post audio ticket, wait, verify MongoDB result
curl -F "file=@tests/fixtures/sample_call.wav" http://localhost:4000/tickets/audio

# Load test with 50 concurrent tickets
pip install httpx
python -c "
import asyncio, httpx, json

async def post_ticket(client, i):
    resp = await client.post('http://localhost:4000/tickets/text',
        json={'body': f'Test ticket {i}: I need help with my billing', 'channel': 'chat'})
    return resp.json()

async def main():
    async with httpx.AsyncClient() as c:
        results = await asyncio.gather(*[post_ticket(c, i) for i in range(50)])
    print(f'Submitted {len(results)} tickets')

asyncio.run(main())
"
```

## Deployment

1. **Qdrant** — use Qdrant Cloud (cloud.qdrant.io) for managed vector storage; set `QDRANT_HOST` to your cluster URL
2. **MongoDB** — use MongoDB Atlas (cloud.mongodb.com) free tier; replace `MONGODB_URI` with the Atlas connection string
3. **Ingestion API** — deploy the Express.js service to GCP Cloud Run using the same pattern as the worker
4. **Worker** — Cloud Run with min-instances=1 to avoid cold start latency on Pub/Sub
5. **Secrets** — store all API keys in GCP Secret Manager and bind via Cloud Run `--set-secrets` flags
6. **Grafana** — deploy Grafana Cloud (grafana.com) and configure it to scrape the Cloud Run Prometheus endpoint via VPC connector

## Resources

1. [Whisper model sizes](https://github.com/openai/whisper#available-models-and-languages) — trade-offs between `tiny`, `base`, `small`, and `large` for accuracy vs latency
2. [Qdrant filtering documentation](https://qdrant.tech/documentation/concepts/filtering/) — payload filters for category-scoped retrieval
3. [GCP Pub/Sub push subscriptions](https://cloud.google.com/pubsub/docs/push) — wiring Cloud Run to a Pub/Sub topic
4. [LangChain output parsers](https://python.langchain.com/docs/modules/model_io/output_parsers/) — Pydantic and JSON output parsing
5. [Prometheus Python client](https://github.com/prometheus/client_python) — Counter, Histogram, and exposition server
6. [Zendesk REST API v2](https://developer.zendesk.com/api-reference/) — ticket tags and comment endpoints

## Skill coverage mapping

Refer to: `doc/research/skill-matrix.md` and `doc/roadmap/bridge.md`

Bridge entries for this project: `P02_SK01`, `P02_SK02`, `P02_SK03`, `P02_SK08`, `P02_SK09`, `P02_SK10`, `P02_SK12`, `P02_SK13`, `P02_SK15`, `P02_SK16`

Tool entries: `P02_TL01` (LangChain), `P02_TL02` (Mistral API), `P02_TL07` (Whisper), `P02_TL10` (Qdrant), `P02_TL11` (MongoDB), `P02_TL13` (Express.js), `P02_TL15` (Docker), `P02_TL16` (GCP Cloud Run), `P02_TL17` (Pub/Sub), `P02_TL24` (Grafana), `P02_TL33` (Zendesk API)
