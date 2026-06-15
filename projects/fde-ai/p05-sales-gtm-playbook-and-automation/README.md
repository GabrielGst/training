# P05 — Sales GTM Playbook and Automation

**Domain:** Sales / Go-To-Market  **Track:** `fde-ai`  **Status:** not started  **Hours target:** 45

## Business Problem

Sales representatives at B2B companies spend approximately 60% of their time on non-selling activities: researching prospects, drafting outreach emails, updating CRM records, and chasing deal status. This project builds an AI system that automates the full top-of-funnel workflow — prospect enrichment, ML-based lead scoring, personalized email sequence generation via Mistral, automated SendGrid delivery, Salesforce CRM sync, and attribution tracking via Stripe — so that reps focus exclusively on closing.

## What you will build

- A **LangChain agent** that researches prospects from web sources, extracts company signals (headcount, funding stage, tech stack), and scores leads using a trained ML model
- A **personalized email sequence generator** using Mistral API with per-prospect context injection, producing 3-touch outreach campaigns stored in PostgreSQL
- A **FastAPI backend** with endpoints for lead ingestion, sequence triggering, delivery status webhooks from SendGrid, and CRM sync operations
- A **Next.js dashboard** displaying pipeline health, sequence performance (open rate, reply rate), and attribution by channel
- A **Make.com automation layer** that responds to CRM events (deal stage change) and triggers downstream actions (Slack alert, sequence pause, Stripe invoice)
- A full **A/B testing framework** for email subject lines and call-to-action variants, with statistical significance tracking

## Architecture

```
Lead Sources                      Enrichment Agent
(CSV upload / webhook)            (LangChain + web search)
        |                                 |
        +---------> Lead Intake API ------+
                    (FastAPI)
                         |
                   Lead Scoring ML
                   (scikit-learn,
                    trained on CRM history)
                         |
              +----------+----------+
              |                     |
         Score < 60            Score >= 60
         (discard /            Personalized Email
          nurture)             Generator
                               (Mistral API +
                                LangChain prompt)
                                    |
                             Sequence Store
                             (Postgres:
                              sequences table)
                                    |
                              SendGrid API
                          (3-touch email delivery)
                                    |
                    +---------------+---------------+
                    |                               |
             Delivery Webhooks              Reply Detection
             (open, click, bounce)          (webhook → pause)
                    |                               |
               Postgres:                    Salesforce API
             email_events                  (lead update,
                                           opportunity sync)
                    |
              Make.com
          (CRM event → Slack alert
           → Stripe invoice trigger)
                    |
             Next.js Dashboard
          (pipeline health, A/B stats,
           attribution by source)
```

## Skills covered

| Skill ID | Skill Name | What you practice |
|----------|------------|------------------|
| SK02 | RAG Architecture Design | Embedding prospect summaries and retrieving similar successful deals as few-shot examples for email generation |
| SK03 | Prompt Engineering and System Design | Designing system prompts for the research agent and email generator; few-shot templates per industry vertical |
| SK04 | API Design and Contract Management | Designing FastAPI endpoints with Pydantic schemas, versioning (`/v1/`), and OpenAPI documentation |
| SK05 | Full-Stack Application Development | Building the Next.js dashboard with server components, API routes, and real-time sequence status updates |
| SK06 | Database Schema Design and Query Optimization | Normalized schema for leads, sequences, email events, and A/B variants with proper indexing |
| SK07 | Data Security and Privacy Compliance | PII handling for prospect data; audit log for all CRM writes; encryption of email content at rest |
| SK10 | Business Impact and ROI Quantification | Tracking time-saved per rep, deal velocity improvement, and revenue attribution by email variant |
| SK12 | Customer Feedback Loops and Iteration | Collecting reply sentiment, A/B test results, and rep override signals to retrain the lead scorer |
| SK13 | Agentic Workflows and Tool Use | Multi-step LangChain agent: search → extract → score → draft → send → sync CRM |
| SK16 | Feature Engineering and Model Architecture | Engineering lead scoring features (company size, tech stack match, engagement signals) |
| SK22 | Experimentation and A/B Testing Frameworks | Subject line A/B tests with chi-squared significance testing and automated winner selection |
| SK23 | Data Privacy and Compliance at Scale | GDPR-compliant unsubscribe handling, data retention policies, PII redaction in logs |

## Tools & dependencies

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| LangChain | 0.2.x | Orchestrating the prospect research and email generation agent | `pip install langchain langchain-community` |
| Mistral API | latest | LLM for personalized email generation and prospect summarization | `pip install mistralai` |
| FastAPI | 0.111.x | REST API backend for lead ingestion, webhook handling, CRM sync | `pip install fastapi uvicorn` |
| Next.js | 14.x | Dashboard frontend with server components and API routes | `npx create-next-app@14` |
| PostgreSQL | 15.x | Primary database for leads, sequences, and email events | Docker or managed RDS |
| AWS S3 | — | Storing exported prospect lists and email content archives | `pip install boto3` |
| Stripe | latest | Attribution tracking and invoice triggering via Make.com | `pip install stripe` |
| SendGrid | latest | Transactional email delivery for outreach sequences | `pip install sendgrid` |
| Salesforce API (simple-salesforce) | 1.12.x | CRM sync: lead creation, opportunity updates | `pip install simple-salesforce` |
| Slack API (slack-sdk) | 3.x | Alerting reps when a prospect replies or a deal advances | `pip install slack-sdk` |
| Make.com | cloud | Low-code automation: CRM events → Slack → Stripe | Make.com account |
| scikit-learn | 1.4.x | Lead scoring ML model (gradient boosting classifier) | `pip install scikit-learn` |
| pandas | 2.x | Feature engineering for lead scoring | `pip install pandas` |

## Prerequisites

**Track modules to complete first:**

- [ ] `ai-agents/03-langgraph` — multi-step agent state machines and conditional branching used in the research + score + send workflow
- [ ] `ai-agents/04-crewai` — multi-agent orchestration patterns useful for separating the enrichment agent from the email drafting agent
- [ ] `ai-engineer/02-fastapi` — FastAPI dependency injection, Pydantic schemas, and background tasks used throughout the backend
- [ ] `software-engineer/03-nextjs` — Next.js server components, route handlers, and real-time UI patterns used in the dashboard

**Accounts / API keys needed:**

- [ ] Mistral AI — LLM API for email generation (`MISTRAL_API_KEY`)
- [ ] SendGrid — transactional email delivery (`SENDGRID_API_KEY`, verified sender domain)
- [ ] Salesforce Developer Edition (free) — CRM integration (`SF_USERNAME`, `SF_PASSWORD`, `SF_SECURITY_TOKEN`)
- [ ] Slack App — rep notification bot (`SLACK_BOT_TOKEN`, `SLACK_CHANNEL_ID`)
- [ ] Stripe — attribution and billing events (`STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`)
- [ ] Make.com — scenario orchestration (free tier sufficient for development)
- [ ] AWS account — S3 bucket for prospect list storage

---

## Step-by-step tutorial

### Step 1: Environment setup

**Goal:** Initialize the monorepo with a Python backend and Next.js frontend, wire up Docker, and load all API credentials.

**Backend setup:**

```bash
python -m venv .venv && source .venv/bin/activate
pip install fastapi uvicorn langchain langchain-community mistralai \
    simple-salesforce sendgrid stripe slack-sdk psycopg2-binary \
    scikit-learn pandas boto3 python-dotenv pydantic
```

**Frontend setup:**

```bash
cd frontend
npx create-next-app@14 . --typescript --tailwind --app --src-dir
npm install swr recharts @radix-ui/react-dialog
```

**Docker Compose:**

```yaml
# docker-compose.yml
version: "3.9"
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: gtm
      POSTGRES_USER: gtmuser
      POSTGRES_PASSWORD: gtmpassword
    ports: ["5432:5432"]
    volumes:
      - pgdata:/var/lib/postgresql/data

  api:
    build: .
    ports: ["8000:8000"]
    environment:
      DATABASE_URL: postgresql://gtmuser:gtmpassword@postgres:5432/gtm
    depends_on: [postgres]
    volumes: ["./src:/app/src"]

volumes:
  pgdata:
```

**`.env` template:**

```bash
DATABASE_URL=postgresql://gtmuser:gtmpassword@localhost:5432/gtm
MISTRAL_API_KEY=your_key_here
SENDGRID_API_KEY=your_key_here
SENDGRID_FROM_EMAIL=outreach@yourcompany.com
SF_USERNAME=your@sf.com
SF_PASSWORD=yourpassword
SF_SECURITY_TOKEN=yourtoken
SLACK_BOT_TOKEN=xoxb-...
SLACK_CHANNEL_ID=C0123456789
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
S3_BUCKET=gtm-prospect-lists
```

**File structure:**

```
p05-sales-gtm-playbook-and-automation/
├── src/
│   ├── api/
│   │   └── main.py
│   ├── agents/
│   │   └── research_agent.py
│   ├── models/
│   │   └── lead_scorer.py
│   ├── services/
│   │   ├── email_generator.py
│   │   ├── sendgrid_service.py
│   │   ├── salesforce_service.py
│   │   └── slack_service.py
│   └── db/
│       └── schema.sql
├── frontend/
│   └── src/app/
├── tests/
├── docker-compose.yml
└── .env
```

**Verify:**

```bash
docker compose up -d postgres
psql postgresql://gtmuser:gtmpassword@localhost:5432/gtm -c "SELECT version();"
```

---

### Step 2: Database schema

**Goal:** Design a normalized schema for leads, sequences, email events, A/B variants, and audit logs.

**Create `src/db/schema.sql`:**

```sql
-- Lead profiles
CREATE TABLE leads (
    id              BIGSERIAL PRIMARY KEY,
    email           VARCHAR(256) UNIQUE NOT NULL,
    first_name      VARCHAR(128),
    last_name       VARCHAR(128),
    company         VARCHAR(256),
    title           VARCHAR(256),
    company_size    INTEGER,
    industry        VARCHAR(128),
    linkedin_url    VARCHAR(512),
    tech_stack      JSONB,          -- e.g. {"tools": ["Salesforce", "HubSpot"]}
    funding_stage   VARCHAR(64),    -- seed, series_a, series_b, etc.
    lead_score      NUMERIC(5,2),   -- 0-100 from ML model
    score_version   VARCHAR(16),    -- model version tag
    source          VARCHAR(64),    -- csv_upload, webhook, manual
    sf_lead_id      VARCHAR(64),    -- Salesforce Lead ID after sync
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_leads_score ON leads (lead_score DESC);
CREATE INDEX idx_leads_company ON leads (company);

-- Email sequences (3-touch campaigns per lead)
CREATE TABLE sequences (
    id          BIGSERIAL PRIMARY KEY,
    lead_id     BIGINT REFERENCES leads(id) ON DELETE CASCADE,
    variant     CHAR(1) DEFAULT 'A',   -- A/B test variant
    status      VARCHAR(32) DEFAULT 'pending',  -- pending, active, paused, completed
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Individual emails within a sequence
CREATE TABLE sequence_emails (
    id              BIGSERIAL PRIMARY KEY,
    sequence_id     BIGINT REFERENCES sequences(id) ON DELETE CASCADE,
    touch_number    INTEGER NOT NULL CHECK (touch_number BETWEEN 1 AND 5),
    subject         TEXT NOT NULL,
    body_html       TEXT NOT NULL,
    body_text       TEXT NOT NULL,
    send_at         TIMESTAMPTZ,
    sent_at         TIMESTAMPTZ,
    sg_message_id   VARCHAR(256),   -- SendGrid message ID for webhook correlation
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Delivery and engagement events from SendGrid webhooks
CREATE TABLE email_events (
    id              BIGSERIAL PRIMARY KEY,
    sg_message_id   VARCHAR(256)    NOT NULL,
    event_type      VARCHAR(64)     NOT NULL,  -- delivered, open, click, bounce, reply
    event_data      JSONB,
    occurred_at     TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_email_events_msg ON email_events (sg_message_id);

-- A/B test configuration
CREATE TABLE ab_tests (
    id              BIGSERIAL PRIMARY KEY,
    test_name       VARCHAR(128) NOT NULL,
    variant_a_desc  TEXT,
    variant_b_desc  TEXT,
    start_date      DATE,
    end_date        DATE,
    winner          CHAR(1),   -- A or B, set when significance reached
    p_value         NUMERIC(8,6),
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Audit log for CRM writes (GDPR compliance)
CREATE TABLE audit_log (
    id          BIGSERIAL PRIMARY KEY,
    actor       VARCHAR(128) NOT NULL,  -- 'system' or user email
    action      VARCHAR(64)  NOT NULL,  -- 'sf_lead_create', 'lead_score', etc.
    entity_type VARCHAR(64),
    entity_id   BIGINT,
    payload     JSONB,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
```

```bash
psql postgresql://gtmuser:gtmpassword@localhost:5432/gtm -f src/db/schema.sql
```

**Verify:**

```bash
psql postgresql://gtmuser:gtmpassword@localhost:5432/gtm -c "\dt"
# Expected: audit_log, ab_tests, email_events, leads, sequence_emails, sequences
```

---

### Step 3: Prospect research agent

**Goal:** Build a LangChain agent that accepts a prospect name + company and returns an enriched profile.

**Create `src/agents/research_agent.py`:**

```python
import os
from langchain_community.utilities import DuckDuckGoSearchAPIWrapper
from langchain.agents import create_react_agent, AgentExecutor
from langchain.tools import Tool
from langchain_mistralai import ChatMistral
from langchain_core.prompts import ChatPromptTemplate
from pydantic import BaseModel
from typing import Optional

MISTRAL_API_KEY = os.getenv("MISTRAL_API_KEY")


class ProspectProfile(BaseModel):
    company_summary: str
    recent_news: list[str]
    estimated_size: Optional[int]
    tech_stack_signals: list[str]
    funding_stage: Optional[str]
    pain_points: list[str]


RESEARCH_SYSTEM_PROMPT = """You are a B2B sales research assistant. Given a prospect's name and company, 
you research them using web search and extract structured signals relevant to a software sales conversation.

Focus on:
1. What the company does (2-sentence summary)
2. Recent news (funding, product launches, leadership changes)
3. Likely tech stack based on job postings and public data
4. Company size (headcount estimate)
5. Likely pain points that your product could address

Always cite your sources. Be concise and factual."""


def build_research_agent() -> AgentExecutor:
    llm = ChatMistral(
        model="mistral-large-latest",
        mistral_api_key=MISTRAL_API_KEY,
        temperature=0.1,
    )

    search = DuckDuckGoSearchAPIWrapper(max_results=5)
    tools = [
        Tool(
            name="web_search",
            func=search.run,
            description="Search the web for information about a company or person.",
        )
    ]

    prompt = ChatPromptTemplate.from_messages([
        ("system", RESEARCH_SYSTEM_PROMPT),
        ("human", "{input}"),
        ("placeholder", "{agent_scratchpad}"),
    ])

    agent = create_react_agent(llm, tools, prompt)
    return AgentExecutor(agent=agent, tools=tools, verbose=True, max_iterations=5)


def enrich_prospect(first_name: str, last_name: str, company: str) -> str:
    """Run the research agent for a single prospect. Returns a text summary."""
    executor = build_research_agent()
    query = (
        f"Research {first_name} {last_name} at {company}. "
        f"Find: company summary, recent news, tech stack, company size, and pain points."
    )
    result = executor.invoke({"input": query})
    return result["output"]
```

**Verify:**

```bash
python - <<'EOF'
from src.agents.research_agent import enrich_prospect
summary = enrich_prospect("Jane", "Smith", "Acme Corp")
print(summary[:500])
EOF
# Expected: multi-paragraph summary with company info, news, and pain points
```

---

### Step 4: Lead scoring model

**Goal:** Train a gradient boosting classifier on historical CRM data to score new leads 0-100.

**Create `src/models/lead_scorer.py`:**

```python
import os
import pickle
import numpy as np
import pandas as pd
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import cross_val_score
from sklearn.metrics import roc_auc_score
from typing import Tuple
import boto3


FEATURES = [
    "company_size_log",
    "title_seniority_score",
    "industry_match_score",
    "has_funding",
    "tech_stack_overlap",
    "days_since_last_activity",
]

TITLE_SENIORITY = {
    "ceo": 5, "cto": 5, "coo": 5, "vp": 4, "director": 3,
    "manager": 2, "engineer": 1, "analyst": 1,
}

TARGET_INDUSTRIES = {"saas", "fintech", "healthcare", "ecommerce"}


def engineer_features(df: pd.DataFrame) -> pd.DataFrame:
    """Transform raw lead fields into model features."""
    out = pd.DataFrame()

    out["company_size_log"] = np.log1p(df["company_size"].fillna(50))

    out["title_seniority_score"] = df["title"].str.lower().apply(
        lambda t: max((TITLE_SENIORITY.get(word, 0) for word in str(t).split()), default=1)
    )

    out["industry_match_score"] = df["industry"].str.lower().apply(
        lambda ind: 1 if any(t in str(ind) for t in TARGET_INDUSTRIES) else 0
    )

    out["has_funding"] = df["funding_stage"].notna().astype(int)

    # tech_stack is a list stored as JSONB; score by overlap with our target stack
    TARGET_TOOLS = {"salesforce", "hubspot", "slack", "jira", "github"}
    def stack_overlap(stack):
        if not stack:
            return 0
        tools = {t.lower() for t in (stack.get("tools") or [])}
        return len(tools & TARGET_TOOLS) / max(len(TARGET_TOOLS), 1)

    out["tech_stack_overlap"] = df["tech_stack"].apply(stack_overlap)
    out["days_since_last_activity"] = df.get("days_since_activity", pd.Series([30] * len(df)))

    return out[FEATURES]


def train_scorer(df: pd.DataFrame, labels: np.ndarray) -> Tuple[Pipeline, dict]:
    """
    Train gradient boosting classifier.
    df: raw lead DataFrame, labels: 1=converted, 0=not converted
    """
    X = engineer_features(df)

    pipeline = Pipeline([
        ("scaler", StandardScaler()),
        ("clf", GradientBoostingClassifier(
            n_estimators=200, max_depth=4,
            learning_rate=0.05, subsample=0.8,
            random_state=42,
        )),
    ])

    cv_scores = cross_val_score(pipeline, X, labels, cv=5, scoring="roc_auc")
    pipeline.fit(X, labels)

    metrics = {
        "auc_mean": float(cv_scores.mean()),
        "auc_std": float(cv_scores.std()),
        "n_train": len(labels),
    }
    return pipeline, metrics


def score_lead(pipeline: Pipeline, lead: dict) -> float:
    """Return a 0-100 score for a single lead dict."""
    df = pd.DataFrame([lead])
    X  = engineer_features(df)
    prob = pipeline.predict_proba(X)[0, 1]
    return round(prob * 100, 2)


def save_model(pipeline: Pipeline, path: str = "models/lead_scorer.pkl") -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as f:
        pickle.dump(pipeline, f)


def load_model(path: str = "models/lead_scorer.pkl") -> Pipeline:
    with open(path, "rb") as f:
        return pickle.load(f)
```

**Verify:**

```bash
python - <<'EOF'
import numpy as np, pandas as pd
from src.models.lead_scorer import train_scorer, score_lead

# Synthetic training data
np.random.seed(42)
n = 200
df = pd.DataFrame({
    "company_size": np.random.randint(10, 5000, n),
    "title": np.random.choice(["VP Sales", "Engineer", "Director", "CEO"], n),
    "industry": np.random.choice(["SaaS", "Retail", "FinTech", "Healthcare"], n),
    "funding_stage": np.random.choice(["seed", "series_a", None], n),
    "tech_stack": [{"tools": ["Salesforce"]} if i % 3 == 0 else None for i in range(n)],
})
labels = np.random.binomial(1, 0.25, n)

pipeline, metrics = train_scorer(df, labels)
print("AUC:", metrics["auc_mean"])

test_lead = {"company_size": 500, "title": "VP Sales", "industry": "SaaS",
             "funding_stage": "series_a", "tech_stack": {"tools": ["Salesforce", "Slack"]}}
print("Score:", score_lead(pipeline, test_lead))
EOF
# Expected: AUC > 0.5, score between 0-100
```

---

### Step 5: Email sequence generator

**Goal:** Use Mistral API with LangChain to generate a personalized 3-touch email campaign from prospect context.

**Create `src/services/email_generator.py`:**

```python
import os
from langchain_mistralai import ChatMistral
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import JsonOutputParser
from pydantic import BaseModel
from typing import List

MISTRAL_API_KEY = os.getenv("MISTRAL_API_KEY")


class EmailTouch(BaseModel):
    touch_number: int
    subject: str
    body_text: str
    body_html: str


class EmailSequence(BaseModel):
    touches: List[EmailTouch]


SEQUENCE_PROMPT = ChatPromptTemplate.from_messages([
    ("system", """You are an expert B2B sales copywriter. Generate a 3-touch email sequence 
for the given prospect. Each email must be:
- Concise (under 150 words body text)
- Personalized to their company context and pain points
- Value-first (no aggressive pitching on touch 1)
- Different angle per touch: (1) insight/question, (2) case study, (3) direct ask

Return a JSON object with this structure:
{{
  "touches": [
    {{"touch_number": 1, "subject": "...", "body_text": "...", "body_html": "..."}},
    {{"touch_number": 2, "subject": "...", "body_text": "...", "body_html": "..."}},
    {{"touch_number": 3, "subject": "...", "body_text": "...", "body_html": "..."}}
  ]
}}"""),
    ("human", """Prospect: {first_name} {last_name}, {title} at {company}
Company summary: {company_summary}
Pain points: {pain_points}
Variant: {variant}"""),
])


def generate_sequence(
    first_name: str,
    last_name: str,
    title: str,
    company: str,
    company_summary: str,
    pain_points: str,
    variant: str = "A",
) -> List[dict]:
    """Generate a 3-touch personalized email sequence. Returns list of touch dicts."""
    llm = ChatMistral(
        model="mistral-large-latest",
        mistral_api_key=MISTRAL_API_KEY,
        temperature=0.3,
    )
    parser = JsonOutputParser(pydantic_object=EmailSequence)
    chain  = SEQUENCE_PROMPT | llm | parser

    result = chain.invoke({
        "first_name": first_name,
        "last_name": last_name,
        "title": title,
        "company": company,
        "company_summary": company_summary,
        "pain_points": pain_points,
        "variant": variant,
    })
    return result.get("touches", [])
```

**Verify:**

```bash
python - <<'EOF'
from src.services.email_generator import generate_sequence

touches = generate_sequence(
    first_name="Jane", last_name="Smith",
    title="VP Sales", company="Acme Corp",
    company_summary="Acme is a 500-person SaaS company that sells CRM software to SMBs.",
    pain_points="Manual lead qualification, long ramp time for new reps",
    variant="A",
)
for t in touches:
    print(f"Touch {t['touch_number']}: {t['subject']}")
    print(t['body_text'][:100], "\n")
EOF
# Expected: 3 touches with distinct subjects and non-empty body_text
```

---

### Step 6: SendGrid delivery service

**Goal:** Send emails via SendGrid, schedule follow-ups, and set up the delivery webhook handler.

**Create `src/services/sendgrid_service.py`:**

```python
import os
import sendgrid
from sendgrid.helpers.mail import Mail, To, Content
from typing import Optional

SENDGRID_API_KEY  = os.getenv("SENDGRID_API_KEY")
FROM_EMAIL        = os.getenv("SENDGRID_FROM_EMAIL", "outreach@example.com")


def send_email(to_email: str, subject: str,
               body_html: str, body_text: str,
               custom_args: Optional[dict] = None) -> str:
    """
    Send a single email via SendGrid.
    custom_args: key-value pairs stored with the message for webhook correlation.
    Returns the SendGrid message ID (from X-Message-Id response header).
    """
    sg = sendgrid.SendGridAPIClient(api_key=SENDGRID_API_KEY)

    message = Mail(
        from_email=FROM_EMAIL,
        to_emails=To(to_email),
        subject=subject,
        html_content=Content("text/html", body_html),
        plain_text_content=Content("text/plain", body_text),
    )

    if custom_args:
        message.custom_arg = [
            {"key": k, "value": str(v)} for k, v in custom_args.items()
        ]

    response = sg.send(message)
    message_id = response.headers.get("X-Message-Id", "unknown")
    return message_id
```

**Webhook handler (in `src/api/main.py`, shown in Step 7):**

```python
# This endpoint handles delivery events from SendGrid Event Webhooks
@app.post("/webhooks/sendgrid")
async def sendgrid_webhook(request: Request, db: AsyncSession = Depends(get_db)):
    payload = await request.json()
    for event in payload:
        msg_id    = event.get("sg_message_id", "").split(".")[0]
        event_type = event.get("event")
        await db.execute(
            text("""INSERT INTO email_events (sg_message_id, event_type, event_data)
                    VALUES (:msg_id, :event_type, :data)"""),
            {"msg_id": msg_id, "event_type": event_type, "data": event}
        )
        # Pause sequence on unsubscribe or bounce
        if event_type in ("unsubscribe", "bounce", "spamreport"):
            await pause_sequence_by_message(db, msg_id)
    await db.commit()
    return {"status": "ok"}
```

**Verify:**

```bash
# Use SendGrid's Event Webhook Tester or ngrok to test locally
ngrok http 8000
# Set webhook URL in SendGrid: https://<ngrok-url>/webhooks/sendgrid
```

---

### Step 7: FastAPI backend

**Goal:** Build the REST API with lead ingestion, sequence trigger, and CRM sync endpoints.

**Create `src/api/main.py`:**

```python
import os
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, BackgroundTasks, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from typing import Optional
import asyncpg

DATABASE_URL = os.getenv("DATABASE_URL")


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.pool = await asyncpg.create_pool(DATABASE_URL, min_size=2, max_size=10)
    yield
    await app.state.pool.close()


app = FastAPI(title="GTM Automation API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[os.getenv("FRONTEND_URL", "http://localhost:3000")],
    allow_methods=["*"], allow_headers=["*"],
)


async def get_pool(request: Request):
    return request.app.state.pool


# --- Schemas ---

class LeadIn(BaseModel):
    email: EmailStr
    first_name: str
    last_name: str
    company: str
    title: Optional[str] = None
    company_size: Optional[int] = None
    industry: Optional[str] = None
    source: str = "api"


class LeadOut(BaseModel):
    id: int
    email: str
    lead_score: Optional[float]
    status: str


# --- Endpoints ---

@app.get("/v1/health")
async def health():
    return {"status": "ok", "version": "1.0.0"}


@app.post("/v1/leads", response_model=LeadOut, status_code=201)
async def ingest_lead(lead: LeadIn, background_tasks: BackgroundTasks,
                      pool=Depends(get_pool)):
    """Ingest a lead, score it, and optionally trigger an outreach sequence."""
    async with pool.acquire() as conn:
        existing = await conn.fetchrow(
            "SELECT id FROM leads WHERE email = $1", lead.email
        )
        if existing:
            raise HTTPException(status_code=409, detail="Lead already exists")

        row = await conn.fetchrow("""
            INSERT INTO leads (email, first_name, last_name, company, title,
                               company_size, industry, source)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            RETURNING id, email
        """, lead.email, lead.first_name, lead.last_name, lead.company,
            lead.title, lead.company_size, lead.industry, lead.source)

    lead_id = row["id"]
    background_tasks.add_task(score_and_enrich_lead, lead_id, lead.dict())

    return LeadOut(id=lead_id, email=lead.email, lead_score=None, status="processing")


@app.get("/v1/leads/{lead_id}", response_model=LeadOut)
async def get_lead(lead_id: int, pool=Depends(get_pool)):
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            "SELECT id, email, lead_score FROM leads WHERE id = $1", lead_id
        )
    if not row:
        raise HTTPException(status_code=404, detail="Lead not found")
    return LeadOut(id=row["id"], email=row["email"],
                   lead_score=row["lead_score"], status="scored")


@app.post("/v1/leads/{lead_id}/sequence")
async def trigger_sequence(lead_id: int, variant: str = "A",
                            background_tasks: BackgroundTasks = BackgroundTasks(),
                            pool=Depends(get_pool)):
    """Trigger a personalized email sequence for a scored lead."""
    async with pool.acquire() as conn:
        lead = await conn.fetchrow("SELECT * FROM leads WHERE id = $1", lead_id)
    if not lead:
        raise HTTPException(status_code=404, detail="Lead not found")
    if lead["lead_score"] is None or lead["lead_score"] < 60:
        raise HTTPException(status_code=400, detail="Lead score below threshold (60)")

    background_tasks.add_task(generate_and_send_sequence, dict(lead), variant)
    return {"status": "sequence_queued", "lead_id": lead_id, "variant": variant}


async def score_and_enrich_lead(lead_id: int, lead_data: dict):
    """Background task: enrich prospect, score lead, update DB."""
    import asyncpg
    from src.agents.research_agent import enrich_prospect
    from src.models.lead_scorer import load_model, score_lead

    summary = enrich_prospect(
        lead_data["first_name"], lead_data["last_name"], lead_data["company"]
    )
    pipeline = load_model()
    score    = score_lead(pipeline, lead_data)

    conn = await asyncpg.connect(DATABASE_URL)
    await conn.execute(
        "UPDATE leads SET lead_score = $1, updated_at = NOW() WHERE id = $2",
        score, lead_id
    )
    await conn.close()


async def generate_and_send_sequence(lead: dict, variant: str):
    """Background task: generate emails, store sequence, send touch 1."""
    from src.services.email_generator import generate_sequence
    from src.services.sendgrid_service import send_email
    import asyncpg

    touches = generate_sequence(
        first_name=lead["first_name"], last_name=lead["last_name"],
        title=lead.get("title", ""), company=lead["company"],
        company_summary="", pain_points="", variant=variant,
    )

    conn = await asyncpg.connect(DATABASE_URL)
    seq_id = await conn.fetchval("""
        INSERT INTO sequences (lead_id, variant, status)
        VALUES ($1, $2, 'active') RETURNING id
    """, lead["id"], variant)

    for touch in touches:
        email_id = await conn.fetchval("""
            INSERT INTO sequence_emails
                (sequence_id, touch_number, subject, body_html, body_text)
            VALUES ($1, $2, $3, $4, $5) RETURNING id
        """, seq_id, touch["touch_number"],
            touch["subject"], touch["body_html"], touch["body_text"])

        if touch["touch_number"] == 1:
            msg_id = send_email(
                to_email=lead["email"],
                subject=touch["subject"],
                body_html=touch["body_html"],
                body_text=touch["body_text"],
                custom_args={"sequence_email_id": str(email_id)},
            )
            await conn.execute(
                "UPDATE sequence_emails SET sg_message_id=$1, sent_at=NOW() WHERE id=$2",
                msg_id, email_id
            )
    await conn.close()
```

**Verify:**

```bash
uvicorn src.api.main:app --reload --port 8000 &
curl -s -X POST http://localhost:8000/v1/leads \
  -H "Content-Type: application/json" \
  -d '{"email":"test@acme.com","first_name":"Jane","last_name":"Smith","company":"Acme","source":"api"}' \
  | python -m json.tool
# Expected: {"id": 1, "email": "test@acme.com", "lead_score": null, "status": "processing"}
```

---

### Step 8: Salesforce CRM sync

**Goal:** Push scored leads to Salesforce and sync reply/deal-stage updates back to the database.

**Create `src/services/salesforce_service.py`:**

```python
import os
from simple_salesforce import Salesforce
from typing import Optional

SF_USERNAME       = os.getenv("SF_USERNAME")
SF_PASSWORD       = os.getenv("SF_PASSWORD")
SF_SECURITY_TOKEN = os.getenv("SF_SECURITY_TOKEN")


def get_sf_client() -> Salesforce:
    return Salesforce(
        username=SF_USERNAME,
        password=SF_PASSWORD,
        security_token=SF_SECURITY_TOKEN,
    )


def create_sf_lead(lead: dict) -> str:
    """Create a Lead record in Salesforce. Returns the SF Lead ID."""
    sf = get_sf_client()
    result = sf.Lead.create({
        "FirstName":  lead.get("first_name"),
        "LastName":   lead.get("last_name"),
        "Email":      lead.get("email"),
        "Company":    lead.get("company"),
        "Title":      lead.get("title"),
        "Industry":   lead.get("industry"),
        "LeadSource": "AI GTM System",
        "Rating":     _score_to_rating(lead.get("lead_score", 0)),
        "Description": f"AI Lead Score: {lead.get('lead_score', 'N/A')}",
    })
    return result["id"]


def update_sf_lead_status(sf_lead_id: str, status: str,
                          note: Optional[str] = None) -> None:
    """Update lead status in Salesforce (e.g., after a reply is detected)."""
    sf = get_sf_client()
    payload = {"Status": status}
    if note:
        payload["Description"] = note
    sf.Lead.update(sf_lead_id, payload)


def _score_to_rating(score: float) -> str:
    if score >= 80: return "Hot"
    if score >= 60: return "Warm"
    return "Cold"
```

**Verify:**

```bash
python - <<'EOF'
from src.services.salesforce_service import get_sf_client
sf = get_sf_client()
print("Connected to Salesforce:", sf.base_url)
EOF
# Expected: Connected to Salesforce: https://yourorg.salesforce.com/services/data/v...
```

---

### Step 9: A/B testing framework

**Goal:** Run statistically rigorous A/B tests on email subject line variants; auto-select winner.

**Create `src/models/ab_testing.py`:**

```python
import numpy as np
from scipy import stats
from typing import Tuple
import psycopg2
import os

DB_URL = os.getenv("DATABASE_URL", "postgresql://gtmuser:gtmpassword@localhost:5432/gtm")


def get_variant_metrics(test_name: str) -> dict:
    """Fetch open/click counts per variant from email_events."""
    conn = psycopg2.connect(DB_URL)
    cur  = conn.cursor()
    cur.execute("""
        SELECT
            s.variant,
            COUNT(DISTINCT se.id)                                       AS sent,
            COUNT(CASE WHEN ee.event_type = 'open' THEN 1 END)         AS opens,
            COUNT(CASE WHEN ee.event_type = 'click' THEN 1 END)        AS clicks
        FROM sequences s
        JOIN sequence_emails se ON se.sequence_id = s.id
        LEFT JOIN email_events ee ON ee.sg_message_id = se.sg_message_id
        WHERE s.variant IN ('A', 'B')
        GROUP BY s.variant
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return {row[0]: {"sent": row[1], "opens": row[2], "clicks": row[3]} for row in rows}


def chi_squared_test(successes_a: int, trials_a: int,
                     successes_b: int, trials_b: int) -> Tuple[float, float]:
    """
    Two-proportion chi-squared test.
    Returns (chi2_stat, p_value).
    """
    contingency = np.array([
        [successes_a,        trials_a - successes_a],
        [successes_b,        trials_b - successes_b],
    ])
    chi2, p, _, _ = stats.chi2_contingency(contingency)
    return chi2, p


def evaluate_ab_test(test_name: str, alpha: float = 0.05) -> dict:
    """
    Evaluate an A/B test for statistical significance.
    Returns recommendation: 'A', 'B', or 'inconclusive'.
    """
    metrics = get_variant_metrics(test_name)
    a = metrics.get("A", {"sent": 0, "opens": 0})
    b = metrics.get("B", {"sent": 0, "opens": 0})

    if a["sent"] < 30 or b["sent"] < 30:
        return {"result": "inconclusive", "reason": "insufficient sample size",
                "a": a, "b": b}

    chi2, p = chi_squared_test(a["opens"], a["sent"], b["opens"], b["sent"])

    rate_a = a["opens"] / max(a["sent"], 1)
    rate_b = b["opens"] / max(b["sent"], 1)

    result = {
        "p_value": round(p, 6),
        "chi2": round(chi2, 4),
        "rate_a": round(rate_a, 4),
        "rate_b": round(rate_b, 4),
        "significant": p < alpha,
        "a": a,
        "b": b,
    }

    if p < alpha:
        result["winner"] = "A" if rate_a > rate_b else "B"
    else:
        result["winner"] = "inconclusive"

    return result
```

**Verify:**

```bash
python - <<'EOF'
from src.models.ab_testing import chi_squared_test, evaluate_ab_test

# Synthetic significance test
chi2, p = chi_squared_test(50, 200, 70, 200)
print(f"p-value: {p:.4f}, significant: {p < 0.05}")
# Expected: p-value should reflect the real difference
EOF
```

---

### Step 10: Next.js dashboard

**Goal:** Build a dashboard displaying lead pipeline health, sequence performance, and A/B test results.

**Create `frontend/src/app/page.tsx`:**

```typescript
import { Suspense } from "react";
import PipelineStats from "@/components/PipelineStats";
import SequenceTable from "@/components/SequenceTable";
import ABTestResults from "@/components/ABTestResults";

export default function Dashboard() {
  return (
    <main className="min-h-screen bg-gray-50 p-8">
      <h1 className="text-2xl font-bold text-gray-900 mb-6">
        GTM Pipeline Dashboard
      </h1>
      <div className="grid grid-cols-3 gap-4 mb-8">
        <Suspense fallback={<div>Loading...</div>}>
          <PipelineStats />
        </Suspense>
      </div>
      <div className="grid grid-cols-2 gap-8">
        <SequenceTable />
        <ABTestResults />
      </div>
    </main>
  );
}
```

**Create `frontend/src/app/api/pipeline/route.ts`:**

```typescript
import { NextResponse } from "next/server";
import { Pool } from "pg";

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

export async function GET() {
  const client = await pool.connect();
  try {
    const { rows } = await client.query(`
      SELECT
        COUNT(*)                                         AS total_leads,
        COUNT(CASE WHEN lead_score >= 60 THEN 1 END)    AS qualified_leads,
        AVG(lead_score)                                  AS avg_score,
        COUNT(CASE WHEN sf_lead_id IS NOT NULL THEN 1 END) AS synced_to_sf
      FROM leads
    `);
    return NextResponse.json(rows[0]);
  } finally {
    client.release();
  }
}
```

**Verify:**

```bash
cd frontend && npm run dev &
curl -s http://localhost:3000/api/pipeline | python -m json.tool
# Expected: JSON with total_leads, qualified_leads, avg_score, synced_to_sf
```

---

### Step 11: Make.com automation layer

**Goal:** Configure Make.com scenarios to respond to CRM and Stripe events without writing server code.

**Scenario 1 — Deal Won → Slack Alert:**
1. Trigger: Salesforce "Opportunity Stage Changed to Closed Won"
2. Action 1: Slack → Post message to `#wins` channel with deal name and ARR
3. Action 2: Stripe → Create invoice for the ACV amount

**Scenario 2 — Email Reply Detected → Pause Sequence:**
1. Trigger: Webhook from FastAPI (`POST /webhooks/sendgrid`) with `event_type=reply`
2. Action: FastAPI `PATCH /v1/sequences/{id}` with `{"status": "paused"}`
3. Action: Slack → Notify assigned rep with prospect name and reply snippet

**Export your scenarios as JSON blueprints and store them in `make/`:**

```bash
mkdir -p make/
# Download blueprint JSON from Make.com → Scenario → Export Blueprint
# Store as make/deal_won_alert.json and make/reply_pause.json
```

**Verify:**

```bash
# Trigger a test webhook from Make.com and verify Slack message arrives
curl -X POST https://hook.make.com/YOUR_WEBHOOK_ID \
  -H "Content-Type: application/json" \
  -d '{"deal": "Acme Corp", "arr": 50000, "stage": "Closed Won"}'
```

---

### Step 12: Observability and CI/CD

**Goal:** Add structured logging, Prometheus metrics endpoint, and GitHub Actions CI.

**Add metrics to FastAPI:**

```python
# src/api/middleware.py
import time
from fastapi import Request
import logging

logger = logging.getLogger("gtm_api")

async def logging_middleware(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    duration_ms = (time.time() - start) * 1000
    logger.info(
        '{"method":"%s","path":"%s","status":%d,"duration_ms":%.1f}',
        request.method, request.url.path, response.status_code, duration_ms
    )
    return response
```

**Create `.github/workflows/ci.yml`:**

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  backend:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_DB: gtm_test
          POSTGRES_USER: gtmuser
          POSTGRES_PASSWORD: gtmpassword
        ports: ["5432:5432"]
        options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: {python-version: "3.11", cache: pip}
      - run: pip install -r requirements.txt
      - run: psql postgresql://gtmuser:gtmpassword@localhost:5432/gtm_test -f src/db/schema.sql
      - run: pytest tests/ -v
        env:
          DATABASE_URL: postgresql://gtmuser:gtmpassword@localhost:5432/gtm_test

  frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: {node-version: "20", cache: npm, cache-dependency-path: frontend/package-lock.json}
      - run: cd frontend && npm ci && npm run build
```

---

## Testing

**Unit tests (`tests/test_lead_scorer.py`):**

```python
import numpy as np
import pandas as pd
import pytest
from src.models.lead_scorer import engineer_features, score_lead, train_scorer


def make_lead_df(n: int = 100) -> pd.DataFrame:
    np.random.seed(0)
    return pd.DataFrame({
        "company_size": np.random.randint(10, 1000, n),
        "title": np.random.choice(["VP Sales", "Engineer", "CEO"], n),
        "industry": np.random.choice(["SaaS", "Retail"], n),
        "funding_stage": np.random.choice(["seed", None], n),
        "tech_stack": [{"tools": ["Salesforce"]} if i % 2 == 0 else None for i in range(n)],
    })


def test_engineer_features_shape():
    df = make_lead_df(10)
    X = engineer_features(df)
    assert X.shape == (10, 6), f"Expected 6 features, got {X.shape[1]}"


def test_train_scorer_auc():
    df     = make_lead_df(100)
    labels = np.random.binomial(1, 0.3, 100)
    pipeline, metrics = train_scorer(df, labels)
    assert metrics["auc_mean"] > 0.4, "AUC too low — model may be broken"


def test_score_lead_range():
    df     = make_lead_df(100)
    labels = np.random.binomial(1, 0.3, 100)
    pipeline, _ = train_scorer(df, labels)
    lead = {"company_size": 200, "title": "VP Sales", "industry": "SaaS",
            "funding_stage": "series_a", "tech_stack": {"tools": ["Salesforce"]}}
    score = score_lead(pipeline, lead)
    assert 0 <= score <= 100, f"Score out of range: {score}"
```

**Integration test for FastAPI:**

```python
# tests/test_api.py
import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, AsyncMock


@pytest.fixture
def client():
    from src.api.main import app
    return TestClient(app)


def test_health(client):
    response = client.get("/v1/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"
```

```bash
pytest tests/ -v --tb=short
```

---

## Deployment

```dockerfile
# Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ ./src/
EXPOSE 8000
CMD ["uvicorn", "src.api.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
```

```bash
docker build -t gtm-api .
docker run -p 8000:8000 \
  -e DATABASE_URL=... \
  -e MISTRAL_API_KEY=... \
  -e SENDGRID_API_KEY=... \
  gtm-api
```

---

## Resources

1. [LangChain ReAct agents](https://python.langchain.com/docs/modules/agents/agent_types/react) — agent architecture used in the prospect research component
2. [Mistral API docs](https://docs.mistral.ai/api/) — model parameters and rate limits for the email generation service
3. [SendGrid Event Webhooks](https://docs.sendgrid.com/for-developers/tracking-events/event) — full event schema for the delivery webhook handler
4. [simple-salesforce docs](https://github.com/simple-salesforce/simple-salesforce) — CRUD operations on Salesforce objects
5. [FastAPI background tasks](https://fastapi.tiangolo.com/tutorial/background-tasks/) — pattern used for async enrichment and sequence generation
6. [Make.com developer docs](https://www.make.com/en/api-documentation) — building and exporting scenario blueprints
7. [scipy.stats chi2_contingency](https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.chi2_contingency.html) — statistical test used in the A/B framework
