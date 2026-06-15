# P10 — Cinema Revenue Optimization and Pricing

**Domain:** Media & Entertainment / Cinema Operations  **Track:** `fde-ai`  **Status:** not started  **Hours target:** 42

## Business Problem

Cinemas set ticket prices weeks in advance using static price sheets, leaving 30-40% of potential revenue on the table. Demand signals — day of week, weather, competing releases, local events, and remaining seat inventory — are never factored in. This project builds a dynamic pricing engine that combines an LSTM demand forecast with a LangChain agent, serves prices via FastAPI in under 100 ms using Redis, and lets customers pay through a Stripe-integrated Next.js dashboard.

## What you will build

- A Prophet + PyTorch LSTM demand forecast that predicts hourly ticket sales per screening from historical data and external signals (weather, local events)
- A LangChain agent ingesting demand signals and calling the pricing solver as a tool to produce optimal price recommendations
- A Mistral API integration generating plain-English pricing rationale for the cinema operations team
- A FastAPI pricing engine serving ticket prices in under 100 ms with Redis sub-second cache
- A Next.js operations dashboard showing live occupancy, dynamic prices, and revenue vs. static-price baseline
- A Stripe payment integration processing ticket purchases at the dynamically computed price

## Architecture

```
Historical Sales DB (PostgreSQL)
         |
  Feature Engineering
         |
Prophet (trend/seasonality) + PyTorch LSTM (demand forecast)
         |
 LangChain Pricing Agent  <-- Mistral API (rationale)
         |        |
   Pricing Solver  Redis cache (< 100 ms)
         |
   FastAPI /price endpoint
         |              \
  Next.js Dashboard    Stripe Checkout
         |
  Twilio SMS (booking confirmations)
         |
  AWS Lambda (scheduled re-pricing every 4 hours)
         |
  GitHub Actions (CI/CD)
```

## Skills covered

| Skill ID | Skill Name | What you practice |
|----------|------------|------------------|
| SK02 | RAG Architecture Design | Vector retrieval of historical pricing decisions to inform the LangChain agent's context |
| SK03 | Prompt Engineering and System Design | Mistral prompts generating pricing rationale in brand-appropriate language |
| SK04 | API Design and Contract Management | FastAPI versioned endpoints, Pydantic price schemas, OpenAPI contract |
| SK05 | Full-Stack Application Development | End-to-end: FastAPI backend + Next.js frontend + Stripe payments |
| SK06 | Database Schema Design and Query Optimization | PostgreSQL schema for screenings, pricing history, and bookings; BRIN indexes for time-series |
| SK07 | Data Security and Privacy Compliance | Stripe PCI compliance; customer email/phone encryption at rest |
| SK10 | Business Impact and ROI Quantification | Revenue lift KPI: dynamic vs. static pricing tracked in the ops dashboard |
| SK14 | Semantic Search and Vector Store Optimization | pgvector similarity search over past pricing decisions as LangChain agent context |
| SK20 | Cost Optimization and Resource Allocation | Redis TTL tuning to balance cache hit rate vs. staleness; Lambda right-sizing |
| SK21 | Time Series Forecasting and Trend Analysis | Prophet for weekly seasonality; LSTM for short-horizon demand spikes |
| SK22 | Experimentation and A/B Testing Frameworks | A/B test dynamic vs. static pricing on split screening schedule |
| SK31 | Statistical Modeling and Causal Inference | Elasticity estimation: how a 10% price increase affects demand |

## Tools & dependencies

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| LangChain | 0.2 | Agent orchestrating demand signals and pricing tools | `pip install langchain langchain-mistralai` |
| Mistral API | latest | LLM generating pricing rationale text | API key from console.mistral.ai |
| FastAPI | 0.111 | Sub-100 ms pricing API with async endpoints | `pip install fastapi uvicorn` |
| Next.js | 14 | Operations dashboard with server components | `npx create-next-app` |
| PostgreSQL | 16 | Screenings, bookings, and pricing history | Docker or managed RDS |
| Redis | 7.x | In-memory price cache with configurable TTL | Docker or Redis Cloud |
| S3 | latest | Model artifact storage and feature archive | AWS CLI |
| Stripe | latest | PCI-compliant ticket payment processing | `pip install stripe` / `npm install stripe` |
| Twilio | 9.x | SMS booking confirmation and seat reminders | `pip install twilio` |
| AWS Lambda | latest | Scheduled re-pricing job every 4 hours | AWS SAM or Serverless Framework |
| GitHub Actions | latest | CI/CD: test, lint, deploy on push to main | Included with GitHub |
| Prophet | 1.1 | Weekly/daily seasonality decomposition | `pip install prophet` |
| PyTorch | 2.x | LSTM demand forecast model | `pip install torch` |

## Prerequisites

**Track modules to complete first:**
- [ ] `ai-agents/01-llm-fundamentals` — prompt design and tool-calling before wiring the LangChain pricing agent
- [ ] `ai-engineer/10-time-series-forecasting` — Prophet and LSTM patterns before building the demand model
- [ ] `ai-engineer/02-fastapi` — async endpoints, Pydantic schemas, dependency injection
- [ ] `software-engineer/03-nextjs` — server components, API routes, and Stripe integration

**Accounts / API keys needed:**
- [ ] Mistral API — pricing rationale generation
- [ ] Stripe — test mode keys for payment integration (no real charges in development)
- [ ] Twilio — SMS confirmation number
- [ ] AWS — Lambda deployment + S3 model storage
- [ ] OpenWeatherMap or similar — weather signal for demand forecasting

---

## Step-by-step tutorial

### Step 1: Environment setup

**Goal:** Spin up PostgreSQL and Redis with Docker; install all Python and Node dependencies.

```yaml
# docker-compose.yml
version: "3.9"
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: cinema
      POSTGRES_USER: cinema_user
      POSTGRES_PASSWORD: cinema_secret
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru

volumes:
  pgdata:
```

```bash
docker compose up -d
python -m venv .venv && source .venv/bin/activate
pip install fastapi uvicorn redis sqlalchemy psycopg2-binary \
            langchain langchain-mistralai torch prophet pandas \
            stripe twilio python-dotenv prometheus-client pgvector

# Next.js frontend
npx create-next-app@14 dashboard --typescript --tailwind --app
cd dashboard && npm install stripe @stripe/stripe-js
```

**Verify:** `docker compose ps` shows both containers healthy; `redis-cli ping` returns `PONG`.

---

### Step 2: Database schema

**Goal:** Store screenings, historical bookings, pricing events, and model features with time-series-friendly indexes.

```sql
-- migrations/001_schema.sql
CREATE EXTENSION IF NOT EXISTS vector;  -- pgvector for pricing history RAG

CREATE TABLE films (
    id        SERIAL PRIMARY KEY,
    title     TEXT NOT NULL,
    genre     TEXT,
    rating    TEXT,
    duration  INT   -- minutes
);

CREATE TABLE screenings (
    id            SERIAL PRIMARY KEY,
    film_id       INT REFERENCES films(id),
    screen_name   TEXT,
    starts_at     TIMESTAMPTZ NOT NULL,
    capacity      INT NOT NULL DEFAULT 150,
    base_price    NUMERIC(8,2) NOT NULL,
    current_price NUMERIC(8,2),
    updated_at    TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE bookings (
    id            SERIAL PRIMARY KEY,
    screening_id  INT REFERENCES screenings(id),
    customer_email TEXT,              -- encrypted in production
    seats         SMALLINT DEFAULT 1,
    price_paid    NUMERIC(8,2),
    stripe_pi_id  TEXT,               -- Stripe PaymentIntent ID
    booked_at     TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE pricing_events (
    id            SERIAL PRIMARY KEY,
    screening_id  INT REFERENCES screenings(id),
    old_price     NUMERIC(8,2),
    new_price     NUMERIC(8,2),
    reason        TEXT,               -- LLM-generated rationale
    demand_score  NUMERIC(5,4),       -- forecast demand (0-1 normalised)
    embedding     vector(384),        -- pgvector: for RAG over past decisions
    created_at    TIMESTAMPTZ DEFAULT now()
);

-- BRIN index: efficient range scans on large time-series tables
CREATE INDEX idx_screenings_starts ON screenings USING BRIN(starts_at);
CREATE INDEX idx_bookings_time     ON bookings   USING BRIN(booked_at);
CREATE INDEX idx_pricing_emb       ON pricing_events USING ivfflat(embedding vector_cosine_ops)
    WITH (lists = 50);
```

```bash
psql -h localhost -U cinema_user -d cinema -f migrations/001_schema.sql
```

**Verify:** `\d screenings` shows `current_price` column and `\d pricing_events` shows `embedding vector(384)`.

---

### Step 3: Prophet + LSTM demand forecast

**Goal:** Build a two-stage forecast: Prophet for weekly/seasonal baseline, LSTM for short-horizon adjustment using external signals.

```python
# src/demand_model.py
import numpy as np
import pandas as pd
import torch
import torch.nn as nn
from prophet import Prophet

# --- Stage 1: Prophet for seasonal baseline ---

def train_prophet(df: pd.DataFrame) -> Prophet:
    """
    df: columns [ds (datetime), y (bookings per hour)]
    """
    m = Prophet(
        changepoint_prior_scale=0.05,
        seasonality_mode="multiplicative",
        weekly_seasonality=True,
        daily_seasonality=True,
    )
    m.add_country_holidays(country_name="FR")
    m.add_regressor("weather_score")   # 0-1: sun/rain
    m.add_regressor("local_event")     # 0/1: major local event
    m.fit(df)
    return m

# --- Stage 2: LSTM for residual demand spikes ---

class DemandLSTM(nn.Module):
    def __init__(self, input_size: int = 6, hidden_size: int = 64):
        super().__init__()
        self.lstm   = nn.LSTM(input_size, hidden_size, batch_first=True)
        self.linear = nn.Linear(hidden_size, 1)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        out, _ = self.lstm(x)
        return self.linear(out[:, -1, :]).squeeze(-1)

def train_lstm(X: np.ndarray, y: np.ndarray, epochs: int = 50) -> DemandLSTM:
    """
    X: (samples, seq_len, features) — normalised features
    y: (samples,) — normalised demand
    """
    model     = DemandLSTM(input_size=X.shape[-1])
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
    criterion = nn.MSELoss()
    Xt = torch.FloatTensor(X)
    yt = torch.FloatTensor(y)

    model.train()
    for epoch in range(epochs):
        optimizer.zero_grad()
        pred = model(Xt)
        loss = criterion(pred, yt)
        loss.backward()
        optimizer.step()
        if epoch % 10 == 0:
            print(f"Epoch {epoch}: loss={loss.item():.4f}")

    torch.save(model.state_dict(), "models/demand_lstm.pt")
    return model

def predict_demand(
    prophet_model: Prophet,
    lstm_model:    DemandLSTM,
    future_df:     pd.DataFrame,
) -> np.ndarray:
    """Returns normalised demand score 0-1 for each row in future_df."""
    baseline  = prophet_model.predict(future_df)["yhat"].values
    # LSTM refinement would use last-N-hours features; simplified here
    demand    = np.clip(baseline / baseline.max(), 0, 1)
    return demand
```

```bash
mkdir -p models
python src/train_demand.py   # standalone training script calling the above functions
```

**Verify:** `models/demand_lstm.pt` exists; Prophet forecast plot shows expected weekly shape.

---

### Step 4: LangChain pricing agent

**Goal:** Wire the demand forecast and historical pricing context into a LangChain agent that calls a pricing tool and outputs a JSON price recommendation with reasoning.

```python
# src/pricing_agent.py
import os, json
from langchain_mistralai import ChatMistralAI
from langchain.agents import tool, AgentExecutor, create_tool_calling_agent
from langchain_core.prompts import ChatPromptTemplate
import sqlalchemy as sa

llm    = ChatMistralAI(model="mistral-small-latest", api_key=os.environ["MISTRAL_API_KEY"])
engine = sa.create_engine(os.environ["DATABASE_URL"])

@tool
def get_demand_forecast(screening_id: int) -> str:
    """Return the normalised demand score (0-1) for a screening."""
    # In production: call the trained LSTM/Prophet pipeline
    with engine.connect() as conn:
        row = conn.execute(
            sa.text("SELECT base_price, starts_at FROM screenings WHERE id = :id"),
            {"id": screening_id},
        ).fetchone()
    if not row:
        return json.dumps({"error": "screening not found"})
    return json.dumps({"screening_id": screening_id, "demand_score": 0.82,
                       "starts_at": str(row[1]), "base_price": float(row[0])})

@tool
def compute_optimal_price(demand_score: float, base_price: float,
                          occupancy_pct: float) -> str:
    """
    Compute the optimal price given demand score (0-1), base price, and current occupancy.
    Returns recommended price and multiplier.
    """
    # Price elasticity model: multiplier = 1 + alpha*(demand - 0.5)
    alpha = 0.8
    multiplier  = max(0.7, min(2.0, 1.0 + alpha * (demand_score - 0.5)))
    # Urgency premium: if >80% seats sold, add 15%
    if occupancy_pct > 0.80:
        multiplier *= 1.15
    price = round(base_price * multiplier, 2)
    return json.dumps({"recommended_price": price, "multiplier": round(multiplier, 3)})

SYSTEM_PROMPT = """You are a cinema revenue optimization agent.
Given a screening ID and current occupancy, use the available tools to:
1. Fetch the demand forecast
2. Compute the optimal price
3. Return a JSON object: {screening_id, recommended_price, rationale}
Keep the rationale under 30 words and suitable for the operations team."""

prompt = ChatPromptTemplate.from_messages([
    ("system", SYSTEM_PROMPT),
    ("human", "Optimize price for screening {screening_id} with {occupancy_pct:.0%} occupancy."),
    ("placeholder", "{agent_scratchpad}"),
])

agent     = create_tool_calling_agent(llm, [get_demand_forecast, compute_optimal_price], prompt)
agent_exe = AgentExecutor(agent=agent, tools=[get_demand_forecast, compute_optimal_price], verbose=True)

def recommend_price(screening_id: int, occupancy_pct: float) -> dict:
    result = agent_exe.invoke({
        "screening_id":  screening_id,
        "occupancy_pct": occupancy_pct,
    })
    return json.loads(result["output"]) if isinstance(result["output"], str) else result
```

**Verify:** `python -c "from src.pricing_agent import recommend_price; print(recommend_price(1, 0.65))"` returns a dict with `recommended_price` and `rationale` keys.

---

### Step 5: FastAPI pricing engine

**Goal:** Serve price recommendations in under 100 ms by caching results in Redis; expose a Prometheus metrics endpoint.

```python
# src/main.py
import os, json
from fastapi import FastAPI
from fastapi.responses import Response
from pydantic import BaseModel
import redis
import sqlalchemy as sa
from prometheus_client import Histogram, Counter, generate_latest, CONTENT_TYPE_LATEST
from src.pricing_agent import recommend_price

app    = FastAPI(title="Cinema Pricing Engine", version="1.0")
rc     = redis.Redis(host=os.environ.get("REDIS_HOST", "localhost"), decode_responses=True)
engine = sa.create_engine(os.environ["DATABASE_URL"])

PRICE_LATENCY = Histogram("price_request_latency_seconds", "Price endpoint latency")
CACHE_HITS    = Counter("price_cache_hits_total", "Requests served from Redis cache")
CACHE_MISSES  = Counter("price_cache_misses_total", "Requests requiring agent compute")

class PriceResponse(BaseModel):
    screening_id:      int
    recommended_price: float
    rationale:         str
    source:            str   # "cache" or "computed"

@app.get("/api/v1/price/{screening_id}", response_model=PriceResponse)
async def get_price(screening_id: int, occupancy_pct: float = 0.5):
    cache_key = f"price:{screening_id}:{occupancy_pct:.2f}"
    cached    = rc.get(cache_key)

    with PRICE_LATENCY.time():
        if cached:
            CACHE_HITS.inc()
            data = json.loads(cached)
            return PriceResponse(**data, source="cache")

        CACHE_MISSES.inc()
        result = recommend_price(screening_id, occupancy_pct)
        payload = {
            "screening_id":      screening_id,
            "recommended_price": result.get("recommended_price", 0.0),
            "rationale":         result.get("rationale", ""),
        }
        rc.setex(cache_key, 300, json.dumps(payload))   # 5-minute TTL
        return PriceResponse(**payload, source="computed")

@app.post("/api/v1/price/{screening_id}/apply")
async def apply_price(screening_id: int, price: float):
    """Persist the recommended price to the database."""
    with engine.begin() as conn:
        conn.execute(
            sa.text("UPDATE screenings SET current_price = :p, updated_at = now() WHERE id = :id"),
            {"p": price, "id": screening_id},
        )
    rc.delete(f"price:{screening_id}:*")   # invalidate all variants
    return {"status": "ok", "screening_id": screening_id, "new_price": price}

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
```

```bash
uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload
```

**Verify:** `curl http://localhost:8000/api/v1/price/1?occupancy_pct=0.75` returns JSON with `recommended_price`; second call returns `"source":"cache"` within 5 ms.

---

### Step 6: Stripe payment integration

**Goal:** Process ticket purchases at the current dynamic price using Stripe PaymentIntents.

```python
# src/payments.py
import os, stripe
import sqlalchemy as sa

stripe.api_key = os.environ["STRIPE_SECRET_KEY"]
engine         = sa.create_engine(os.environ["DATABASE_URL"])

def create_checkout_session(screening_id: int, seats: int, customer_email: str) -> str:
    """Returns a Stripe Checkout URL. Price is fetched live from the database."""
    with engine.connect() as conn:
        row = conn.execute(
            sa.text("""
                SELECT f.title, s.current_price, s.starts_at
                FROM screenings s JOIN films f ON f.id = s.film_id
                WHERE s.id = :id
            """),
            {"id": screening_id},
        ).fetchone()

    if not row:
        raise ValueError(f"Screening {screening_id} not found")

    title, price, starts_at = row
    session = stripe.checkout.Session.create(
        payment_method_types=["card"],
        customer_email=customer_email,
        line_items=[{
            "price_data": {
                "currency":     "eur",
                "unit_amount":  int(price * 100),  # Stripe uses cents
                "product_data": {
                    "name":        f"{title} — {starts_at.strftime('%a %d %b %H:%M')}",
                    "description": f"{seats} seat(s) at dynamic price €{price:.2f}",
                },
            },
            "quantity": seats,
        }],
        mode="payment",
        success_url=f"{os.environ['APP_URL']}/booking/success?session_id={{CHECKOUT_SESSION_ID}}",
        cancel_url=f"{os.environ['APP_URL']}/booking/cancel",
        metadata={"screening_id": str(screening_id), "seats": str(seats)},
    )
    return session.url
```

Add a FastAPI endpoint:

```python
# in src/main.py
from src.payments import create_checkout_session

@app.post("/api/v1/checkout")
async def checkout(screening_id: int, seats: int, customer_email: str):
    url = create_checkout_session(screening_id, seats, customer_email)
    return {"checkout_url": url}
```

**Verify:** Using Stripe test card `4242 4242 4242 4242`, a booking completes and the Stripe dashboard shows a test PaymentIntent.

---

### Step 7: Next.js operations dashboard

**Goal:** Give cinema staff a real-time view of occupancy, current dynamic prices, and revenue vs. static-price baseline.

```bash
cd dashboard
npm install @tanstack/react-query recharts
```

```typescript
// dashboard/app/screenings/page.tsx
"use client";
import { useQuery } from "@tanstack/react-query";

type Screening = {
  id: number;
  title: string;
  starts_at: string;
  capacity: number;
  booked: number;
  current_price: number;
  base_price: number;
};

async function fetchScreenings(): Promise<Screening[]> {
  const res = await fetch("/api/screenings");
  return res.json();
}

export default function ScreeningsPage() {
  const { data = [], isLoading } = useQuery({
    queryKey: ["screenings"],
    queryFn: fetchScreenings,
    refetchInterval: 30_000,  // refresh every 30 s
  });

  if (isLoading) return <p className="p-4">Loading...</p>;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Live Screenings</h1>
      <table className="w-full text-sm">
        <thead>
          <tr className="text-left border-b">
            <th className="py-2">Film</th>
            <th>Starts</th>
            <th>Occupancy</th>
            <th>Dynamic Price</th>
            <th>Base Price</th>
            <th>Uplift</th>
          </tr>
        </thead>
        <tbody>
          {data.map(s => {
            const occ    = s.booked / s.capacity;
            const uplift = ((s.current_price - s.base_price) / s.base_price * 100).toFixed(1);
            return (
              <tr key={s.id} className="border-b hover:bg-gray-50">
                <td className="py-2 font-medium">{s.title}</td>
                <td>{new Date(s.starts_at).toLocaleString()}</td>
                <td>
                  <span className={occ > 0.8 ? "text-red-600 font-bold" : "text-green-600"}>
                    {(occ * 100).toFixed(0)}%
                  </span>
                </td>
                <td className="font-semibold">€{s.current_price.toFixed(2)}</td>
                <td className="text-gray-500">€{s.base_price.toFixed(2)}</td>
                <td className={Number(uplift) > 0 ? "text-green-700" : "text-red-700"}>
                  {uplift}%
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
```

```bash
npm run dev  # http://localhost:3000
```

**Verify:** The screenings table populates from `/api/screenings`; the "Uplift" column shows non-zero values once the pricing agent has run.

---

### Step 8: Twilio SMS booking confirmation

**Goal:** Send a booking confirmation SMS when Stripe reports a successful payment via webhook.

```python
# src/sms.py
import os
from twilio.rest import Client

client      = Client(os.environ["TWILIO_ACCOUNT_SID"], os.environ["TWILIO_AUTH_TOKEN"])
FROM_NUMBER = os.environ["TWILIO_FROM"]

def send_booking_confirmation(
    customer_phone: str,
    film_title:     str,
    starts_at:      str,
    seats:          int,
    price_paid:     float,
) -> str:
    msg = client.messages.create(
        body=(f"Booking confirmed! {seats}x '{film_title}' on {starts_at}. "
              f"Total: €{price_paid * seats:.2f}. Enjoy the film!"),
        from_=FROM_NUMBER,
        to=customer_phone,
    )
    return msg.sid
```

Add a Stripe webhook endpoint to `src/main.py`:

```python
from src.sms import send_booking_confirmation

@app.post("/webhooks/stripe")
async def stripe_webhook(request: Request):
    payload   = await request.body()
    sig       = request.headers.get("stripe-signature", "")
    try:
        event = stripe.Webhook.construct_event(
            payload, sig, os.environ["STRIPE_WEBHOOK_SECRET"]
        )
    except stripe.error.SignatureVerificationError:
        return Response(status_code=400)

    if event["type"] == "checkout.session.completed":
        session    = event["data"]["object"]
        meta       = session.get("metadata", {})
        # In production: look up customer phone from booking record
        send_booking_confirmation(
            customer_phone="+33600000000",   # fetched from DB by screening_id
            film_title="Example Film",
            starts_at=meta.get("starts_at", ""),
            seats=int(meta.get("seats", 1)),
            price_paid=session["amount_total"] / 100,
        )
    return {"status": "ok"}
```

**Verify:** Use `stripe listen --forward-to localhost:8000/webhooks/stripe` in a second terminal; complete a test checkout and confirm an SMS arrives.

---

### Step 9: AWS Lambda scheduled re-pricing

**Goal:** Re-run the pricing agent for all screenings in the next 48 hours every 4 hours without keeping a server running.

```python
# lambda/reprice_handler.py
import os, json, boto3, requests

API_URL = os.environ["PRICING_API_URL"]

def handler(event, context):
    """Fetch all upcoming screenings and trigger a price refresh for each."""
    import sqlalchemy as sa
    engine = sa.create_engine(os.environ["DATABASE_URL"])

    with engine.connect() as conn:
        rows = conn.execute(sa.text("""
            SELECT s.id,
                   COUNT(b.id)::FLOAT / s.capacity AS occupancy_pct
            FROM screenings s
            LEFT JOIN bookings b ON b.screening_id = s.id
            WHERE s.starts_at BETWEEN NOW() AND NOW() + INTERVAL '48 hours'
            GROUP BY s.id, s.capacity
        """)).fetchall()

    refreshed = []
    for screening_id, occupancy_pct in rows:
        resp = requests.get(
            f"{API_URL}/api/v1/price/{screening_id}",
            params={"occupancy_pct": occupancy_pct},
        )
        if resp.status_code == 200:
            price = resp.json()["recommended_price"]
            requests.post(f"{API_URL}/api/v1/price/{screening_id}/apply",
                          params={"price": price})
            refreshed.append(screening_id)

    return {"statusCode": 200, "body": json.dumps({"refreshed": refreshed})}
```

Deploy with the AWS SAM CLI:

```yaml
# template.yaml
AWSTemplateFormatVersion: "2010-09-09"
Transform: AWS::Serverless-2016-10-31
Resources:
  RepricingFunction:
    Type: AWS::Serverless::Function
    Properties:
      Handler:    reprice_handler.handler
      Runtime:    python3.12
      CodeUri:    lambda/
      Timeout:    120
      Environment:
        Variables:
          PRICING_API_URL: !Sub "https://api.cinema.example.com"
          DATABASE_URL:    !Sub "{{resolve:ssm:/cinema/db_url}}"
      Events:
        Schedule:
          Type: Schedule
          Properties:
            Schedule: "rate(4 hours)"
```

```bash
sam build && sam deploy --guided
```

**Verify:** In the AWS Lambda console, trigger a test event and confirm the function returns `{"refreshed": [...]}` without errors.

---

### Step 10: A/B test — dynamic vs. static pricing

**Goal:** Statistically prove that dynamic pricing increases per-seat revenue compared to the static baseline.

```python
# src/ab_test.py
import numpy as np
from scipy import stats

def run_pricing_ab_test(
    dynamic_revenue_per_seat:  np.ndarray,
    static_revenue_per_seat:   np.ndarray,
    alpha: float = 0.05,
) -> dict:
    t_stat, p_value = stats.ttest_ind(dynamic_revenue_per_seat, static_revenue_per_seat,
                                       alternative="greater")
    lift = ((dynamic_revenue_per_seat.mean() - static_revenue_per_seat.mean())
            / static_revenue_per_seat.mean())

    return {
        "dynamic_mean_eur":  round(float(dynamic_revenue_per_seat.mean()), 2),
        "static_mean_eur":   round(float(static_revenue_per_seat.mean()),  2),
        "lift_pct":          round(lift * 100, 2),
        "p_value":           round(p_value, 4),
        "significant":       p_value < alpha,
        "verdict":           "Dynamic pricing wins" if (p_value < alpha and lift > 0)
                             else "Inconclusive",
    }

if __name__ == "__main__":
    np.random.seed(7)
    dynamic = np.random.normal(13.50, 2.0, size=200)
    static  = np.random.normal(11.00, 2.5, size=200)
    print(run_pricing_ab_test(dynamic, static))
```

**Verify:** `python src/ab_test.py` prints `"verdict": "Dynamic pricing wins"` and `"lift_pct"` in the 20-25% range.

---

### Step 11: GitHub Actions CI/CD

**Goal:** Run tests, lint, and deploy the Lambda re-pricing function on every push to main.

```yaml
# .github/workflows/cinema-ci.yml
name: Cinema Pricing CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test-and-deploy:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB: cinema
          POSTGRES_USER: cinema_user
          POSTGRES_PASSWORD: cinema_secret
        ports:
          - 5432:5432
      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python 3.12
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest httpx

      - name: Run database migrations
        run: psql $DATABASE_URL -f migrations/001_schema.sql
        env:
          DATABASE_URL: postgresql://cinema_user:cinema_secret@localhost:5432/cinema

      - name: Run Python tests
        run: pytest tests/ -v --tb=short
        env:
          DATABASE_URL: postgresql://cinema_user:cinema_secret@localhost:5432/cinema
          REDIS_HOST:   localhost
          MISTRAL_API_KEY: ${{ secrets.MISTRAL_API_KEY }}

      - name: Build Next.js
        run: cd dashboard && npm ci && npm run build

      - name: Deploy Lambda (main only)
        if: github.ref == 'refs/heads/main'
        run: |
          pip install aws-sam-cli
          sam build
          sam deploy --no-confirm-changeset --stack-name cinema-pricing
        env:
          AWS_ACCESS_KEY_ID:     ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_DEFAULT_REGION:    eu-west-1
```

**Verify:** The GitHub Actions tab shows a green pipeline with test results printed; the Lambda stack update appears in CloudFormation on merge to main.

---

### Step 12: End-to-end integration test

**Goal:** Confirm the full pricing pipeline from database seed through API response to Redis cache.

```python
# tests/test_e2e.py
import pytest, httpx, redis, json, os

API_URL  = "http://localhost:8000"
rc       = redis.Redis(host="localhost", decode_responses=True)

def test_price_endpoint_returns_price():
    resp = httpx.get(f"{API_URL}/api/v1/price/1", params={"occupancy_pct": 0.6})
    assert resp.status_code == 200
    data = resp.json()
    assert "recommended_price" in data
    assert data["recommended_price"] > 0

def test_cache_hit_on_second_request():
    # First request — computed
    r1 = httpx.get(f"{API_URL}/api/v1/price/1", params={"occupancy_pct": 0.6})
    assert r1.json()["source"] == "computed"
    # Second request — cached
    r2 = httpx.get(f"{API_URL}/api/v1/price/1", params={"occupancy_pct": 0.6})
    assert r2.json()["source"] == "cache"

def test_high_occupancy_higher_price():
    low  = httpx.get(f"{API_URL}/api/v1/price/1", params={"occupancy_pct": 0.2}).json()
    high = httpx.get(f"{API_URL}/api/v1/price/1", params={"occupancy_pct": 0.95}).json()
    assert high["recommended_price"] >= low["recommended_price"]

def test_demand_forecast_sanity():
    from src.pricing_agent import compute_optimal_price
    result = json.loads(compute_optimal_price.invoke(
        {"demand_score": 0.9, "base_price": 12.0, "occupancy_pct": 0.85}
    ))
    assert result["recommended_price"] > 12.0   # high demand => premium price
```

```bash
pytest tests/ -v --tb=short
```

---

## Testing

```bash
# Unit tests (no Docker services required)
pytest tests/unit/ -v

# Integration tests (requires Docker services)
pytest tests/integration/ -v

# Next.js
cd dashboard && npm test

# Load test the pricing API
k6 run tests/load_pricing.js   # assert p99 < 100 ms
```

Key test scenarios:
- Redis cache returns `source: cache` within 5 ms on second identical request
- `recommended_price > base_price` when `occupancy_pct > 0.8`
- Stripe webhook integration test using Stripe CLI event fixtures
- Lambda handler returns HTTP 200 with list of refreshed screening IDs

---

## Deployment

```bash
# Python API
docker build -t cinema-pricing:latest .
docker run -p 8000:8000 \
  -e DATABASE_URL=postgresql://cinema_user:cinema_secret@db:5432/cinema \
  -e REDIS_HOST=redis \
  -e MISTRAL_API_KEY=... \
  -e STRIPE_SECRET_KEY=... \
  -e TWILIO_ACCOUNT_SID=... \
  -e TWILIO_AUTH_TOKEN=... \
  -e TWILIO_FROM=+33600000000 \
  cinema-pricing:latest

# Next.js dashboard
cd dashboard && npm run build && npm start

# Lambda (re-pricing cron)
sam deploy --stack-name cinema-pricing --region eu-west-1
```

Cost controls:
- Redis `allkeys-lru` eviction with 256 MB cap keeps price lookups sub-100 ms while limiting memory spend
- Lambda X-SMALL memory (256 MB) is sufficient for the re-pricing loop; upgrade only if 200+ screenings per run
- Mistral `mistral-small-latest` costs ~$0.002 per pricing recommendation; cache aggressively to reduce LLM calls

---

## Resources

1. [Prophet documentation](https://facebook.github.io/prophet/docs/quick_start.html) — seasonal decomposition and regressor configuration
2. [PyTorch LSTM tutorial](https://pytorch.org/tutorials/beginner/nlp/sequence_models_tutorial.html) — sequence model foundations
3. [LangChain tool-calling agents](https://python.langchain.com/docs/modules/agents/agent_types/tool_calling/) — wiring Python functions as LLM tools
4. [Stripe PaymentIntents guide](https://stripe.com/docs/payments/payment-intents) — checkout sessions and webhook verification
5. [FastAPI Redis caching patterns](https://fastapi.tiangolo.com/advanced/middleware/) — request-level caching with Redis
6. [AWS SAM CLI quickstart](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-getting-started-hello-world.html) — deploy and schedule Lambda functions
