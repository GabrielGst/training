# P01 — VC Due Diligence AI Analyst

**Domain:** Venture Capital / Deal Flow  **Track:** `fde-ai`  **Status:** not started  **Hours target:** 40

## Business Problem

VCs spend 40+ hours per deal analyzing pitch decks, cap tables, and market comparables manually. Decision cycles stretch weeks because analysts must read every document, extract key signals, and cross-reference market data by hand. This project automates extraction and scoring of deal viability signals — market size, team quality, traction — and surfaces risk/opportunity scores via an internal API dashboard, compressing first-pass analysis from days to minutes.

## What you will build

- A PDF ingestion pipeline that extracts structured signals from pitch decks using Mistral API and stores embeddings in Pinecone and pgvector
- A FastAPI backend exposing endpoints for deal submission, signal extraction, and scored output retrieval
- A vector retrieval layer querying a corpus of comparable exits to contextualize each new deal
- A Next.js / React dashboard displaying deal scores, extracted fields, and risk flags for analysts
- An AWS Lambda function triggered by S3 uploads to kick off async processing
- A GitHub Actions CI/CD pipeline with tests and automated deployment

## Architecture

```
Analyst uploads PDF
        |
        v
   AWS S3 bucket  ──────────────────────────────────────┐
        |                                                |
        v                                                |
  AWS Lambda (trigger)                                   |
        |                                                |
        v                                                |
  FastAPI ingestion worker                               |
   ├── PyMuPDF / pdfplumber (text extraction)           |
   ├── Mistral API (structured signal extraction)        |
   ├── LangChain embeddings → Pinecone (deal index)      |
   └── pgvector (comparable exits index)                 |
        |                                                |
        v                                                |
  PostgreSQL  ←────────── deal metadata + scores         |
        |                                                |
        v                                                |
  FastAPI query endpoints ──────────────────────────────┘
        |
        v
  Next.js / React dashboard
   ├── Deal list + scores
   ├── Signal extraction viewer
   └── Comparable exits panel
```

## Skills covered

| Skill ID | Skill Name | What you practice |
|----------|------------|------------------|
| SK01 | Requirements Discovery and Scoping | Translating VC analyst pain points into API contracts and acceptance criteria |
| SK02 | RAG Architecture Design | Designing the dual-index pipeline (Pinecone for deals, pgvector for exits) with chunking and reranking |
| SK03 | Prompt Engineering and System Design | Crafting structured extraction prompts for pitch deck fields (market size, team, traction) |
| SK04 | API Design and Contract Management | Designing FastAPI endpoints with Pydantic schemas, versioning, and OpenAPI docs |
| SK05 | Full-Stack Application Development | Building the complete React/Next.js dashboard backed by a FastAPI service |
| SK06 | Database Schema Design and Query Optimization | Designing the PostgreSQL schema for deals, signals, and embedding storage with pgvector |
| SK07 | Data Security and Privacy Compliance | Encrypting pitch deck storage in S3, enforcing access controls, and audit logging |
| SK12 | Customer Feedback Loops and Iteration | Instrumenting analyst interaction telemetry to improve extraction accuracy |
| SK14 | Semantic Search and Vector Store Optimization | Tuning HNSW indexes and chunking strategies for pitch deck retrieval |

## Tools & dependencies

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| LangChain | latest | LLM orchestration, document loaders, embedding pipelines | `pip install langchain langchain-community` |
| Mistral API | latest | LLM for structured signal extraction and reasoning | `pip install mistralai` |
| pgvector | 0.7+ | PostgreSQL extension for embedding storage and similarity search | PostgreSQL extension (see Step 2) |
| PostgreSQL | 15+ | Primary relational database for deals and metadata | `apt install postgresql` |
| FastAPI | 0.111+ | Async Python REST API framework | `pip install fastapi uvicorn` |
| AWS Lambda | N/A | Serverless trigger for S3 upload events | AWS Console / CDK |
| Next.js | 14+ | React full-stack framework for the analyst dashboard | `npx create-next-app@latest` |
| AWS S3 | N/A | Object storage for uploaded pitch deck PDFs | `pip install boto3` |
| React | 18+ | Component library (bundled with Next.js) | included with Next.js |
| Pinecone | 3+ | Managed vector database for deal index | `pip install pinecone-client` |
| GitHub Actions | N/A | CI/CD pipeline for tests and deployment | `.github/workflows/` |
| pdfplumber | 0.11+ | PDF text extraction | `pip install pdfplumber` |
| Pydantic | 2+ | Schema validation for API request/response models | `pip install pydantic` |

## Prerequisites

**Track modules to complete first:**
- [ ] `ai-agents/01-llm-fundamentals` — prompt engineering basics, token limits, and structured outputs
- [ ] `ai-agents/02-langchain` — chains, document loaders, and LangChain LCEL syntax
- [ ] `ai-agents/06-rag-advanced` — chunking strategies, embedding models, reranking, and pgvector
- [ ] `ai-engineer/02-fastapi` — REST API patterns, Pydantic, async handlers, dependency injection
- [ ] `data-engineer/01-postgresql` — schema design, indexing, and query optimization

**Accounts / API keys needed:**
- [ ] Mistral API key — mistral.ai (free tier available)
- [ ] Pinecone API key — pinecone.io (free starter tier)
- [ ] AWS account with S3 and Lambda access — aws.amazon.com
- [ ] GitHub account for Actions CI/CD

## Step-by-step tutorial

### Step 1: Environment setup

**Goal:** Create a reproducible Python + Node environment with all dependencies pinned.

Create the project structure:

```
p01-vc-due-diligence-ai-analyst/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py
│   │   ├── models.py
│   │   ├── ingestion.py
│   │   ├── extraction.py
│   │   ├── retrieval.py
│   │   └── api/
│   │       ├── deals.py
│   │       └── health.py
│   ├── tests/
│   │   ├── test_extraction.py
│   │   └── test_api.py
│   ├── requirements.txt
│   └── .env.example
├── frontend/
│   ├── src/app/
│   │   ├── page.tsx
│   │   ├── deals/[id]/page.tsx
│   │   └── api/deals/route.ts
│   └── package.json
├── infra/
│   ├── lambda_trigger.py
│   └── docker-compose.yml
└── .github/workflows/ci.yml
```

```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install fastapi uvicorn pydantic langchain langchain-community \
    mistralai pinecone-client boto3 pdfplumber psycopg2-binary \
    pgvector python-dotenv pytest httpx

pip freeze > requirements.txt
```

Create `backend/.env.example`:

```env
MISTRAL_API_KEY=your_key_here
PINECONE_API_KEY=your_key_here
PINECONE_INDEX=vc-deals
DATABASE_URL=postgresql://postgres:password@localhost:5432/vc_diligence
AWS_REGION=us-east-1
S3_BUCKET=vc-pitch-decks
```

**Verify:**

```bash
python -c "import fastapi, langchain, mistralai, pinecone; print('OK')"
# Expected: OK
```

### Step 2: Database and vector store setup

**Goal:** Provision PostgreSQL with the pgvector extension and create the schema for deals, signals, and embeddings.

```bash
# Start PostgreSQL with pgvector via Docker
docker run -d \
  --name vc-postgres \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=vc_diligence \
  -p 5432:5432 \
  ankane/pgvector:latest
```

Create `backend/app/schema.sql`:

```sql
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE deals (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT NOT NULL,
    s3_key      TEXT NOT NULL,
    status      TEXT NOT NULL DEFAULT 'pending',  -- pending|processing|scored|failed
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE deal_signals (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    deal_id         UUID NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    market_size_usd BIGINT,
    team_score      NUMERIC(3,2),   -- 0.00 to 1.00
    traction_mrr    BIGINT,
    stage           TEXT,           -- pre-seed|seed|series-a|...
    sector          TEXT,
    risk_flags      JSONB,
    opportunity_score NUMERIC(3,2),
    raw_extraction  JSONB,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE deal_chunks (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    deal_id     UUID NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    chunk_index INT NOT NULL,
    content     TEXT NOT NULL,
    embedding   vector(1024),       -- Mistral embed-english-v3.0 dimension
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE comparable_exits (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company     TEXT NOT NULL,
    sector      TEXT,
    exit_type   TEXT,               -- acquisition|ipo|merger
    exit_value_usd BIGINT,
    summary     TEXT,
    embedding   vector(1024),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- HNSW index for fast ANN search
CREATE INDEX ON deal_chunks USING hnsw (embedding vector_cosine_ops);
CREATE INDEX ON comparable_exits USING hnsw (embedding vector_cosine_ops);
CREATE INDEX ON deals (status);
CREATE INDEX ON deal_signals (deal_id);
```

Apply the schema:

```bash
psql postgresql://postgres:password@localhost:5432/vc_diligence < backend/app/schema.sql
```

**Verify:**

```bash
psql postgresql://postgres:password@localhost:5432/vc_diligence -c "\dt"
# Expected: deals, deal_signals, deal_chunks, comparable_exits
```

### Step 3: PDF ingestion pipeline

**Goal:** Extract text from pitch decks, chunk intelligently, embed with Mistral, and store in Pinecone + pgvector.

Create `backend/app/ingestion.py`:

```python
import pdfplumber
import boto3
from langchain.text_splitter import RecursiveCharacterTextSplitter
from mistralai import Mistral
from pinecone import Pinecone
import psycopg2
import json
import uuid
import os
from typing import List, Tuple

client = Mistral(api_key=os.environ["MISTRAL_API_KEY"])
pc = Pinecone(api_key=os.environ["PINECONE_API_KEY"])
s3 = boto3.client("s3")

SPLITTER = RecursiveCharacterTextSplitter(
    chunk_size=800,
    chunk_overlap=100,
    separators=["\n\n", "\n", ". ", " "],
)


def download_pdf_from_s3(bucket: str, key: str) -> bytes:
    response = s3.get_object(Bucket=bucket, Key=key)
    return response["Body"].read()


def extract_text_from_pdf(pdf_bytes: bytes) -> str:
    import io
    with pdfplumber.open(io.BytesIO(pdf_bytes)) as pdf:
        pages = [page.extract_text() or "" for page in pdf.pages]
    return "\n\n".join(pages)


def embed_texts(texts: List[str]) -> List[List[float]]:
    response = client.embeddings.create(
        model="mistral-embed",
        inputs=texts,
    )
    return [item.embedding for item in response.data]


def ingest_deal(deal_id: str, s3_key: str, db_conn) -> None:
    bucket = os.environ["S3_BUCKET"]
    pdf_bytes = download_pdf_from_s3(bucket, s3_key)
    full_text = extract_text_from_pdf(pdf_bytes)

    chunks = SPLITTER.split_text(full_text)
    embeddings = embed_texts(chunks)

    # Store in pgvector
    with db_conn.cursor() as cur:
        for i, (chunk, emb) in enumerate(zip(chunks, embeddings)):
            cur.execute(
                """INSERT INTO deal_chunks (id, deal_id, chunk_index, content, embedding)
                   VALUES (%s, %s, %s, %s, %s)""",
                (str(uuid.uuid4()), deal_id, i, chunk, emb),
            )
        db_conn.commit()

    # Store in Pinecone
    index = pc.Index(os.environ["PINECONE_INDEX"])
    vectors = [
        {"id": f"{deal_id}_{i}", "values": emb, "metadata": {"deal_id": deal_id, "chunk": chunk[:200]}}
        for i, (chunk, emb) in enumerate(zip(chunks, embeddings))
    ]
    index.upsert(vectors=vectors)
```

**Verify:**

```bash
cd backend
python -c "
from app.ingestion import embed_texts
result = embed_texts(['test pitch deck content'])
print(f'Embedding dim: {len(result[0])}')
# Expected: Embedding dim: 1024
"
```

### Step 4: Structured signal extraction with Mistral

**Goal:** Use Mistral with a structured prompt to extract deal signals (market size, team score, traction, risk flags) as validated Pydantic models.

Create `backend/app/extraction.py`:

```python
from mistralai import Mistral
from pydantic import BaseModel, Field
import json
import os
import re
from typing import Optional, List

client = Mistral(api_key=os.environ["MISTRAL_API_KEY"])


class DealSignals(BaseModel):
    market_size_usd: Optional[int] = Field(None, description="TAM in USD")
    team_score: float = Field(..., ge=0.0, le=1.0, description="Team quality 0-1")
    traction_mrr: Optional[int] = Field(None, description="MRR in USD if available")
    stage: str = Field(..., description="Funding stage: pre-seed|seed|series-a|series-b|later")
    sector: str = Field(..., description="Industry sector")
    risk_flags: List[str] = Field(default_factory=list)
    opportunity_score: float = Field(..., ge=0.0, le=1.0, description="Overall opportunity 0-1")
    reasoning: str = Field(..., description="Brief rationale for scores")


EXTRACTION_SYSTEM_PROMPT = """You are a senior venture capital analyst. Extract structured signals from pitch deck text.

Return ONLY valid JSON matching this schema:
{
  "market_size_usd": <integer or null>,
  "team_score": <float 0.0-1.0>,
  "traction_mrr": <integer or null>,
  "stage": "<pre-seed|seed|series-a|series-b|later>",
  "sector": "<industry>",
  "risk_flags": ["<flag1>", "<flag2>"],
  "opportunity_score": <float 0.0-1.0>,
  "reasoning": "<2-3 sentence rationale>"
}

Scoring guidance:
- team_score: 0.9+ = serial founders with exits; 0.7 = strong domain experts; 0.5 = first-time founders
- opportunity_score: weighted average of market size (40%), team (30%), traction (30%)
- risk_flags: e.g. "no revenue", "crowded market", "single founder", "regulatory risk"
"""


def extract_signals(pitch_text: str) -> DealSignals:
    # Truncate to ~8k tokens to fit context
    truncated = pitch_text[:12000]

    response = client.chat.complete(
        model="mistral-large-latest",
        messages=[
            {"role": "system", "content": EXTRACTION_SYSTEM_PROMPT},
            {"role": "user", "content": f"Extract signals from this pitch deck:\n\n{truncated}"},
        ],
        temperature=0.1,
    )

    raw = response.choices[0].message.content.strip()

    # Strip markdown code fences if present
    raw = re.sub(r"^```(?:json)?\s*", "", raw)
    raw = re.sub(r"\s*```$", "", raw)

    data = json.loads(raw)
    return DealSignals(**data)
```

**Verify:**

```bash
python -c "
import os; os.environ['MISTRAL_API_KEY'] = 'your_key'
from app.extraction import extract_signals
result = extract_signals('Acme Corp is a B2B SaaS company targeting a \$50B market. Founded by ex-Google engineers with 2 previous exits. MRR: \$45,000.')
print(result.model_dump_json(indent=2))
"
```

### Step 5: RAG retrieval — comparable exits

**Goal:** Given a new deal, retrieve semantically similar exits from the pgvector index to provide market context and score calibration.

Create `backend/app/retrieval.py`:

```python
import psycopg2
from psycopg2.extras import RealDictCursor
from mistralai import Mistral
from typing import List, Dict
import os

client = Mistral(api_key=os.environ["MISTRAL_API_KEY"])


def get_db_conn():
    return psycopg2.connect(os.environ["DATABASE_URL"])


def embed_query(text: str) -> List[float]:
    response = client.embeddings.create(model="mistral-embed", inputs=[text])
    return response.data[0].embedding


def retrieve_comparable_exits(deal_summary: str, top_k: int = 5) -> List[Dict]:
    """Find comparable exits using cosine similarity."""
    query_emb = embed_query(deal_summary)

    conn = get_db_conn()
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT company, sector, exit_type, exit_value_usd, summary,
                   1 - (embedding <=> %s::vector) AS similarity
            FROM comparable_exits
            ORDER BY embedding <=> %s::vector
            LIMIT %s
            """,
            (query_emb, query_emb, top_k),
        )
        results = cur.fetchall()
    conn.close()
    return [dict(r) for r in results]


def build_context_for_llm(deal_signals: dict, comparables: List[Dict]) -> str:
    comp_text = "\n".join(
        f"- {c['company']} ({c['sector']}): {c['exit_type']} at ${c['exit_value_usd']:,} | {c['summary']}"
        for c in comparables
    )
    return f"""Deal signals:
{deal_signals}

Comparable exits (top {len(comparables)}):
{comp_text}
"""
```

### Step 6: FastAPI backend

**Goal:** Expose REST endpoints for deal upload, status polling, and scored results retrieval with full OpenAPI documentation.

Create `backend/app/main.py`:

```python
from fastapi import FastAPI, UploadFile, File, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uuid
import boto3
import os
from app.models import DealResponse, DealStatus
from app.ingestion import ingest_deal, extract_text_from_pdf
from app.extraction import extract_signals
from app.retrieval import retrieve_comparable_exits, build_context_for_llm, get_db_conn

app = FastAPI(title="VC Due Diligence API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_methods=["*"],
    allow_headers=["*"],
)

s3 = boto3.client("s3")


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/deals/upload", status_code=202)
async def upload_deal(
    file: UploadFile = File(...),
    background_tasks: BackgroundTasks = None,
):
    if not file.filename.endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files accepted")

    deal_id = str(uuid.uuid4())
    s3_key = f"deals/{deal_id}/{file.filename}"

    # Upload to S3
    content = await file.read()
    s3.put_object(Bucket=os.environ["S3_BUCKET"], Key=s3_key, Body=content)

    # Record deal in DB
    conn = get_db_conn()
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO deals (id, name, s3_key, status) VALUES (%s, %s, %s, 'pending')",
            (deal_id, file.filename, s3_key),
        )
        conn.commit()
    conn.close()

    background_tasks.add_task(process_deal, deal_id, s3_key, content)
    return {"deal_id": deal_id, "status": "processing"}


async def process_deal(deal_id: str, s3_key: str, pdf_bytes: bytes):
    conn = get_db_conn()
    try:
        # Update status
        with conn.cursor() as cur:
            cur.execute("UPDATE deals SET status='processing' WHERE id=%s", (deal_id,))
            conn.commit()

        # Extract text and ingest
        import io, pdfplumber
        with pdfplumber.open(io.BytesIO(pdf_bytes)) as pdf:
            text = "\n\n".join(p.extract_text() or "" for p in pdf.pages)

        ingest_deal(deal_id, s3_key, conn)
        signals = extract_signals(text)
        comparables = retrieve_comparable_exits(f"{signals.sector} {signals.stage}")

        # Store signals
        with conn.cursor() as cur:
            cur.execute(
                """INSERT INTO deal_signals
                   (deal_id, market_size_usd, team_score, traction_mrr, stage,
                    sector, risk_flags, opportunity_score, raw_extraction)
                   VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                (deal_id, signals.market_size_usd, signals.team_score,
                 signals.traction_mrr, signals.stage, signals.sector,
                 signals.risk_flags, signals.opportunity_score,
                 signals.model_dump_json()),
            )
            cur.execute("UPDATE deals SET status='scored' WHERE id=%s", (deal_id,))
            conn.commit()
    except Exception as e:
        with conn.cursor() as cur:
            cur.execute("UPDATE deals SET status='failed' WHERE id=%s", (deal_id,))
            conn.commit()
        raise
    finally:
        conn.close()


@app.get("/deals/{deal_id}", response_model=DealResponse)
async def get_deal(deal_id: str):
    conn = get_db_conn()
    with conn.cursor() as cur:
        cur.execute(
            """SELECT d.id, d.name, d.status, d.created_at,
                      s.market_size_usd, s.team_score, s.traction_mrr,
                      s.stage, s.sector, s.risk_flags, s.opportunity_score
               FROM deals d
               LEFT JOIN deal_signals s ON s.deal_id = d.id
               WHERE d.id = %s""",
            (deal_id,),
        )
        row = cur.fetchone()
    conn.close()
    if not row:
        raise HTTPException(status_code=404, detail="Deal not found")
    return DealResponse.from_row(row)


@app.get("/deals")
async def list_deals():
    conn = get_db_conn()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT id, name, status, created_at FROM deals ORDER BY created_at DESC LIMIT 50"
        )
        rows = cur.fetchall()
    conn.close()
    return [{"id": r[0], "name": r[1], "status": r[2], "created_at": str(r[3])} for r in rows]
```

**Verify:**

```bash
cd backend && uvicorn app.main:app --reload --port 8000
# In another terminal:
curl http://localhost:8000/health
# Expected: {"status":"ok"}
curl http://localhost:8000/docs  # should show Swagger UI
```

### Step 7: Next.js dashboard

**Goal:** Build an analyst-facing dashboard showing deal list, scores, extracted signals, and comparable exits.

```bash
cd frontend
npx create-next-app@latest . --typescript --tailwind --app --src-dir
npm install @tanstack/react-query axios
```

Create `frontend/src/app/page.tsx`:

```tsx
"use client";
import { useEffect, useState } from "react";
import axios from "axios";
import Link from "next/link";

interface Deal {
  id: string;
  name: string;
  status: string;
  created_at: string;
}

export default function HomePage() {
  const [deals, setDeals] = useState<Deal[]>([]);
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    axios.get("http://localhost:8000/deals").then((r) => setDeals(r.data));
  }, []);

  async function handleUpload(e: React.ChangeEvent<HTMLInputElement>) {
    if (!e.target.files?.[0]) return;
    setUploading(true);
    const form = new FormData();
    form.append("file", e.target.files[0]);
    await axios.post("http://localhost:8000/deals/upload", form);
    setUploading(false);
    const updated = await axios.get("http://localhost:8000/deals");
    setDeals(updated.data);
  }

  const statusColor: Record<string, string> = {
    pending: "text-yellow-600",
    processing: "text-blue-600",
    scored: "text-green-600",
    failed: "text-red-600",
  };

  return (
    <main className="max-w-4xl mx-auto p-8">
      <h1 className="text-3xl font-bold mb-6">VC Deal Pipeline</h1>

      <label className="block mb-6 cursor-pointer">
        <span className="bg-blue-600 text-white px-4 py-2 rounded">
          {uploading ? "Uploading..." : "Upload Pitch Deck (PDF)"}
        </span>
        <input type="file" accept=".pdf" className="hidden" onChange={handleUpload} />
      </label>

      <table className="w-full border-collapse">
        <thead>
          <tr className="bg-gray-100">
            <th className="p-3 text-left">Deal</th>
            <th className="p-3 text-left">Status</th>
            <th className="p-3 text-left">Uploaded</th>
            <th className="p-3 text-left">Actions</th>
          </tr>
        </thead>
        <tbody>
          {deals.map((deal) => (
            <tr key={deal.id} className="border-b">
              <td className="p-3">{deal.name}</td>
              <td className={`p-3 font-medium ${statusColor[deal.status] ?? ""}`}>
                {deal.status}
              </td>
              <td className="p-3 text-sm text-gray-500">
                {new Date(deal.created_at).toLocaleDateString()}
              </td>
              <td className="p-3">
                <Link href={`/deals/${deal.id}`} className="text-blue-600 underline">
                  View
                </Link>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </main>
  );
}
```

Create `frontend/src/app/deals/[id]/page.tsx`:

```tsx
"use client";
import { useEffect, useState } from "react";
import axios from "axios";
import { useParams } from "next/navigation";

export default function DealPage() {
  const { id } = useParams();
  const [deal, setDeal] = useState<any>(null);

  useEffect(() => {
    const poll = setInterval(async () => {
      const r = await axios.get(`http://localhost:8000/deals/${id}`);
      setDeal(r.data);
      if (r.data.status === "scored" || r.data.status === "failed") {
        clearInterval(poll);
      }
    }, 3000);
    return () => clearInterval(poll);
  }, [id]);

  if (!deal) return <div className="p-8">Loading...</div>;

  return (
    <main className="max-w-3xl mx-auto p-8">
      <h1 className="text-2xl font-bold mb-2">{deal.name}</h1>
      <span className="text-sm text-gray-500">Status: {deal.status}</span>

      {deal.status === "scored" && (
        <div className="mt-6 grid grid-cols-2 gap-4">
          <Metric label="Opportunity Score" value={`${(deal.opportunity_score * 100).toFixed(0)}%`} />
          <Metric label="Team Score" value={`${(deal.team_score * 100).toFixed(0)}%`} />
          <Metric label="Market Size" value={deal.market_size_usd ? `$${(deal.market_size_usd / 1e9).toFixed(1)}B` : "N/A"} />
          <Metric label="Monthly Revenue" value={deal.traction_mrr ? `$${deal.traction_mrr.toLocaleString()}` : "N/A"} />
          <div className="col-span-2">
            <h3 className="font-semibold mb-1">Risk Flags</h3>
            <ul className="list-disc pl-4 text-red-700">
              {deal.risk_flags?.map((f: string) => <li key={f}>{f}</li>)}
            </ul>
          </div>
        </div>
      )}
    </main>
  );
}

function Metric({ label, value }: { label: string; value: string }) {
  return (
    <div className="border rounded p-4">
      <div className="text-sm text-gray-500">{label}</div>
      <div className="text-2xl font-bold mt-1">{value}</div>
    </div>
  );
}
```

**Verify:**

```bash
cd frontend && npm run dev
# Open http://localhost:3000 — should see the deal list page
```

### Step 8: AWS Lambda trigger

**Goal:** Wire up an S3 event notification to automatically kick off deal processing when a PDF lands in the bucket.

Create `infra/lambda_trigger.py`:

```python
import json
import boto3
import urllib.parse
import os

# This function is deployed as an AWS Lambda and triggered by S3 PutObject events.

API_BASE = os.environ["API_BASE_URL"]  # e.g. https://your-fastapi.example.com


def handler(event, context):
    import urllib.request

    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

        if not key.startswith("deals/") or not key.endswith(".pdf"):
            print(f"Skipping non-deal key: {key}")
            continue

        # Extract deal_id from key pattern: deals/<deal_id>/<filename>.pdf
        parts = key.split("/")
        if len(parts) < 3:
            continue
        deal_id = parts[1]

        # Notify FastAPI to start processing
        payload = json.dumps({"deal_id": deal_id, "s3_key": key}).encode()
        req = urllib.request.Request(
            f"{API_BASE}/deals/{deal_id}/process",
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(req) as resp:
            print(f"Triggered processing for {deal_id}: {resp.status}")

    return {"statusCode": 200}
```

Create `infra/s3_notification.json`:

```json
{
  "LambdaFunctionConfigurations": [
    {
      "LambdaFunctionArn": "arn:aws:lambda:us-east-1:ACCOUNT_ID:function:vc-deal-trigger",
      "Events": ["s3:ObjectCreated:Put"],
      "Filter": {
        "Key": {
          "FilterRules": [
            {"Name": "prefix", "Value": "deals/"},
            {"Name": "suffix", "Value": ".pdf"}
          ]
        }
      }
    }
  ]
}
```

**Verify:**

```bash
aws lambda invoke \
  --function-name vc-deal-trigger \
  --payload '{"Records":[{"s3":{"bucket":{"name":"vc-pitch-decks"},"object":{"key":"deals/test-id/test.pdf"}}}]}' \
  /tmp/response.json && cat /tmp/response.json
# Expected: {"statusCode": 200}
```

### Step 9: Testing

**Goal:** Cover the extraction, retrieval, and API layers with unit and integration tests.

Create `backend/tests/test_extraction.py`:

```python
import pytest
from unittest.mock import patch, MagicMock
from app.extraction import extract_signals, DealSignals

SAMPLE_PITCH = """
Acme AI is a Series A B2B SaaS company in the legal tech sector.
Market size: $12B TAM. Founded by three ex-Palantir engineers, two with prior exits.
MRR: $85,000, growing 15% month-over-month.
"""


@patch("app.extraction.client")
def test_extract_signals_happy_path(mock_client):
    mock_response = MagicMock()
    mock_response.choices[0].message.content = """{
        "market_size_usd": 12000000000,
        "team_score": 0.88,
        "traction_mrr": 85000,
        "stage": "series-a",
        "sector": "legal tech",
        "risk_flags": ["enterprise sales cycle"],
        "opportunity_score": 0.82,
        "reasoning": "Strong team with prior exits, solid MRR growth in large market."
    }"""
    mock_client.chat.complete.return_value = mock_response

    result = extract_signals(SAMPLE_PITCH)

    assert isinstance(result, DealSignals)
    assert result.team_score == 0.88
    assert result.traction_mrr == 85000
    assert result.opportunity_score == 0.82
    assert "enterprise sales cycle" in result.risk_flags


def test_extract_signals_validates_scores():
    with pytest.raises(Exception):
        DealSignals(
            team_score=1.5,  # invalid: > 1.0
            opportunity_score=0.5,
            stage="seed",
            sector="fintech",
            reasoning="test",
        )
```

Create `backend/tests/test_api.py`:

```python
import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, AsyncMock
import io

# Import after setting env vars
import os
os.environ["MISTRAL_API_KEY"] = "test"
os.environ["PINECONE_API_KEY"] = "test"
os.environ["PINECONE_INDEX"] = "test"
os.environ["DATABASE_URL"] = "postgresql://postgres:password@localhost:5432/vc_diligence"
os.environ["AWS_REGION"] = "us-east-1"
os.environ["S3_BUCKET"] = "test-bucket"

from app.main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


@patch("app.main.s3")
@patch("app.main.get_db_conn")
def test_upload_deal(mock_conn, mock_s3):
    mock_conn.return_value.__enter__ = mock_conn
    mock_conn.return_value.__exit__ = MagicMock(return_value=False)

    pdf_content = b"%PDF-1.4 test content"
    response = client.post(
        "/deals/upload",
        files={"file": ("pitch.pdf", io.BytesIO(pdf_content), "application/pdf")},
    )
    assert response.status_code == 202
    assert "deal_id" in response.json()
```

Run tests:

```bash
cd backend
pytest tests/ -v --tb=short
# Expected: all tests pass
```

### Step 10: CI/CD and deployment

**Goal:** Automate testing and Docker-based deployment with GitHub Actions.

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  backend-test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: ankane/pgvector:latest
        env:
          POSTGRES_PASSWORD: password
          POSTGRES_DB: vc_diligence_test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - name: Install dependencies
        run: pip install -r backend/requirements.txt
      - name: Apply schema
        run: psql postgresql://postgres:password@localhost:5432/vc_diligence_test < backend/app/schema.sql
        env:
          DATABASE_URL: postgresql://postgres:password@localhost:5432/vc_diligence_test
      - name: Run tests
        run: cd backend && pytest tests/ -v
        env:
          DATABASE_URL: postgresql://postgres:password@localhost:5432/vc_diligence_test
          MISTRAL_API_KEY: ${{ secrets.MISTRAL_API_KEY }}
          PINECONE_API_KEY: ${{ secrets.PINECONE_API_KEY }}
          PINECONE_INDEX: vc-deals-test
          S3_BUCKET: test-bucket
          AWS_REGION: us-east-1

  frontend-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
      - run: npm ci
        working-directory: frontend
      - run: npm run build
        working-directory: frontend
```

Create `infra/docker-compose.yml`:

```yaml
version: "3.9"
services:
  postgres:
    image: ankane/pgvector:latest
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_DB: vc_diligence
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./backend/app/schema.sql:/docker-entrypoint-initdb.d/schema.sql

  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://postgres:password@postgres:5432/vc_diligence
    env_file:
      - ./backend/.env
    depends_on:
      - postgres

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend

volumes:
  pgdata:
```

**Verify:**

```bash
docker compose -f infra/docker-compose.yml up --build
curl http://localhost:8000/health
# Expected: {"status":"ok"}
```

## Testing

```bash
# Backend unit + integration tests
cd backend && pytest tests/ -v --cov=app --cov-report=term-missing

# Frontend type check
cd frontend && npx tsc --noEmit

# End-to-end: upload a sample PDF and poll for scoring
curl -X POST http://localhost:8000/deals/upload \
  -F "file=@sample_pitch.pdf" | jq .deal_id

# Poll until scored
DEAL_ID=<deal_id_from_above>
until curl -s http://localhost:8000/deals/$DEAL_ID | grep -q '"status":"scored"'; do
  sleep 5
done
curl http://localhost:8000/deals/$DEAL_ID | jq .
```

## Deployment

1. **Build and push Docker images** to ECR or Docker Hub
2. **Deploy FastAPI** on AWS ECS Fargate or EC2 with an Application Load Balancer
3. **Deploy Next.js** on Vercel (connect GitHub repo, set `NEXT_PUBLIC_API_URL` env var)
4. **Create S3 bucket** with versioning enabled and attach Lambda trigger via Console or CDK
5. **Run database migrations** against the production PostgreSQL instance (RDS recommended)
6. **Configure secrets** in AWS Secrets Manager and reference in ECS task definition

## Resources

1. [Mistral AI documentation](https://docs.mistral.ai/) — API reference for chat completion and embeddings
2. [LangChain text splitters](https://python.langchain.com/docs/modules/data_connection/document_transformers/) — chunking strategies for RAG
3. [pgvector README](https://github.com/pgvector/pgvector) — HNSW index tuning parameters
4. [Pinecone quickstart](https://docs.pinecone.io/guides/get-started/quickstart) — index creation and upsert patterns
5. [FastAPI background tasks](https://fastapi.tiangolo.com/tutorial/background-tasks/) — async processing without a separate queue
6. [pdfplumber](https://github.com/jsvine/pdfplumber) — table and text extraction from complex PDFs

## Skill coverage mapping

Refer to: `doc/research/skill-matrix.md` and `doc/roadmap/bridge.md`

Bridge entries for this project: `P01_SK01`, `P01_SK02`, `P01_SK03`, `P01_SK04`, `P01_SK05`, `P01_SK06`, `P01_SK07`, `P01_SK12`, `P01_SK14`

Tool entries: `P01_TL01` (LangChain), `P01_TL02` (Mistral API), `P01_TL03` (pgvector), `P01_TL04` (Postgres), `P01_TL05` (FastAPI), `P01_TL08` (AWS Lambda), `P01_TL09` (Next.js), `P01_TL12` (S3), `P01_TL14` (React), `P01_TL32` (Pinecone), `P01_TL26` (GitHub Actions)
