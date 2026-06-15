# P03 — Fintech Fraud Detection Real-Time

**Domain:** Financial Services / Fraud Prevention  **Track:** `fde-ai`  **Status:** not started  **Hours target:** 40

## Business Problem

The legacy fraud system scores transactions with a 12% false-positive rate, blocking legitimate customer purchases and generating costly manual review queues. Mean time to detect actual fraud is 4 hours because the batch scoring pipeline runs hourly, allowing fraudsters to execute many transactions before detection. Growing transaction volume demands sub-50ms end-to-end scoring latency, adaptive feature engineering that responds to new attack patterns, and audit-ready explainability for every decision.

## What you will build

- A Kafka event stream that receives raw payment transactions from a producer simulator
- A Faust stateful stream processor that engineers real-time features (velocity counts, rolling averages, device fingerprint aggregations) per card and merchant
- An XGBoost fraud classifier exported to ONNX Runtime for sub-10ms inference with Redis caching of feature windows
- A SHAP explainability layer that annotates each scored transaction with top contributing features
- A dbt mart in PostgreSQL for offline analysis, model retraining, and compliance reporting
- A Grafana + PagerDuty observability stack tracking false-positive rate, true-positive rate, and p99 latency with on-call alerts

## Architecture

```
Payment event producer (simulator / upstream system)
            |
            v
     Apache Kafka  (topic: transactions-raw)
            |
            v
     Faust stream processor  (Python, stateful)
      ├── Per-card velocity: txn count last 1m / 5m / 1h
      ├── Per-merchant anomaly: avg amount deviation
      ├── Device fingerprint: new device flag
      └── Geographic: country change in last 30m
            |
            v
     Feature vector (20 features, ~1ms assembly)
            |
    ┌───────┴──────────┐
    v                  v
 Redis cache        Inference
 (feature windows)  (ONNX Runtime + XGBoost model)
                       |
                       v
               Fraud score + SHAP values
                       |
            ┌──────────┴──────────┐
            v                     v
   Kafka (topic:           PostgreSQL
   scored-transactions)    (transactions table,
            |               dbt mart)
            v
      Grafana dashboard
      + PagerDuty alerts
      (high fraud wave, latency spike)
```

## Skills covered

| Skill ID | Skill Name | What you practice |
|----------|------------|------------------|
| SK03 | Prompt Engineering and System Design | Using Mistral to generate natural-language explanations of SHAP values for analyst reports |
| SK06 | Database Schema Design and Query Optimization | Designing the PostgreSQL transactions table with partitioning, composite indexes, and dbt mart views |
| SK11 | Structured Output Extraction and Parsing | Parsing Faust stream records into typed Pydantic models with validation at ingestion |
| SK13 | Agentic Workflows and Tool Use | Orchestrating the multi-step scoring pipeline as a deterministic agent: feature fetch → inference → explain → publish |
| SK17 | Model Evaluation and Ablation Testing | Holdout evaluation with precision/recall curves, threshold selection, and ablation of individual feature groups |
| SK18 | Feedback Loop Design and Active Learning | Building a label pipeline where analyst dispute decisions flow back as retraining data |
| SK19 | Pipeline Orchestration and Automation | Scheduling the offline retraining pipeline with GitHub Actions cron and dbt transformations |

## Tools & dependencies

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| Kafka | 3.7+ | Distributed event stream for raw and scored transactions | `docker pull confluentinc/cp-kafka` |
| Faust | 1.10+ | Python stateful stream processing on Kafka | `pip install faust-streaming` |
| XGBoost | 2.0+ | Gradient boosting fraud classifier | `pip install xgboost` |
| ONNX Runtime | 1.18+ | Fast inference engine for the exported XGBoost model | `pip install onnxruntime` |
| Redis | 7+ | In-memory feature window cache (velocity counters) | `docker pull redis:7-alpine` |
| Grafana | 10+ | Real-time dashboard for fraud metrics and latency | `docker pull grafana/grafana` |
| PagerDuty | N/A | Incident management and on-call alerts | pagerduty.com (free dev account) |
| dbt | 1.8+ | SQL transformation framework for the fraud mart | `pip install dbt-postgres` |
| SHAP | 0.45+ | Shapley value explainability for XGBoost | `pip install shap` |
| PostgreSQL | 15+ | Primary store for transaction history and dbt mart | `docker pull ankane/pgvector` |
| Prometheus | 2+ | Metrics collection for Grafana | `docker pull prom/prometheus` |
| scikit-learn | 1.5+ | Train/test splitting, metrics, and preprocessing | `pip install scikit-learn` |
| skl2onnx | 1.17+ | Convert XGBoost to ONNX format | `pip install skl2onnx onnxmltools` |

## Prerequisites

**Track modules to complete first:**
- [ ] `ai-engineer/05-pytorch` — ML model training patterns, loss functions, evaluation metrics
- [ ] `ai-engineer/11-streaming-ml` — Kafka producers/consumers, stream processing concepts
- [ ] `ai-engineer/09-ml-explainability` — SHAP values, feature importance, and model interpretability
- [ ] `data-engineer/04-data-pipelines-airflow` — pipeline orchestration patterns and DAG design
- [ ] `data-engineer/05-dbt-transformations` — dbt models, tests, and incremental materialization

**Accounts / API keys needed:**
- [ ] PagerDuty developer account with an integration key — pagerduty.com
- [ ] Mistral API key (for natural language SHAP explanations) — mistral.ai

## Step-by-step tutorial

### Step 1: Environment setup

**Goal:** Stand up the full local stack — Kafka, Redis, PostgreSQL, Prometheus, Grafana — with Docker Compose before writing pipeline code.

Create the project structure:

```
p03-fintech-fraud-detection-real-time/
├── pipeline/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── models.py          # Pydantic models
│   │   ├── features.py        # Faust feature engineering
│   │   ├── inference.py       # ONNX Runtime scoring
│   │   ├── explainability.py  # SHAP annotations
│   │   └── publisher.py       # Scored event publisher
│   ├── training/
│   │   ├── train.py           # XGBoost training
│   │   ├── evaluate.py        # Evaluation + ablation
│   │   └── export_onnx.py     # ONNX export
│   ├── requirements.txt
│   └── .env.example
├── dbt_mart/
│   ├── dbt_project.yml
│   ├── models/
│   │   ├── staging/stg_transactions.sql
│   │   └── marts/fraud_summary.sql
│   └── profiles.yml
├── infra/
│   ├── docker-compose.yml
│   ├── prometheus.yml
│   └── grafana/dashboards/fraud.json
└── .github/workflows/retrain.yml
```

Create `infra/docker-compose.yml`:

```yaml
version: "3.9"
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.6.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
    ports:
      - "2181:2181"

  kafka:
    image: confluentinc/cp-kafka:7.6.0
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  postgres:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_DB: fraud_detection
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./pipeline/schema.sql:/docker-entrypoint-initdb.d/schema.sql

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
    volumes:
      - grafana_data:/var/lib/grafana

volumes:
  pgdata:
  grafana_data:
```

```bash
cd pipeline
python -m venv .venv && source .venv/bin/activate
pip install faust-streaming xgboost onnxruntime shap scikit-learn \
    skl2onnx onnxmltools redis psycopg2-binary pydantic \
    mistralai python-dotenv prometheus-client pytest
pip freeze > requirements.txt

docker compose -f infra/docker-compose.yml up -d
```

Create `.env.example`:

```env
KAFKA_BROKER=localhost:9092
REDIS_URL=redis://localhost:6379
DATABASE_URL=postgresql://postgres:password@localhost:5432/fraud_detection
MISTRAL_API_KEY=your_key_here
PAGERDUTY_ROUTING_KEY=your_key_here
FRAUD_THRESHOLD=0.7
```

**Verify:**

```bash
docker compose -f infra/docker-compose.yml ps
# All services should show State: Up
kafka-topics --bootstrap-server localhost:9092 --list
# Expected: empty list (auto-create enabled)
```

### Step 2: Database schema

**Goal:** Create the PostgreSQL schema for raw transactions, scored results, and the feedback label table.

Create `pipeline/schema.sql`:

```sql
CREATE TABLE transactions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id  TEXT UNIQUE NOT NULL,
    card_id         TEXT NOT NULL,
    merchant_id     TEXT NOT NULL,
    amount_usd      NUMERIC(12,2) NOT NULL,
    currency        CHAR(3) NOT NULL DEFAULT 'USD',
    country         CHAR(2) NOT NULL,
    device_id       TEXT,
    ip_address      INET,
    channel         TEXT,                    -- online|pos|atm|mobile
    event_time      TIMESTAMPTZ NOT NULL,
    ingested_at     TIMESTAMPTZ NOT NULL DEFAULT now()
) PARTITION BY RANGE (event_time);

-- Monthly partitions for efficient retention
CREATE TABLE transactions_2024_01 PARTITION OF transactions
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE transactions_2024_02 PARTITION OF transactions
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
-- Add partitions as needed; automate with a monthly cron

CREATE TABLE fraud_scores (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id  TEXT NOT NULL REFERENCES transactions(transaction_id),
    fraud_score     NUMERIC(4,3) NOT NULL,          -- 0.000 to 1.000
    is_fraud        BOOLEAN NOT NULL,               -- threshold decision
    shap_values     JSONB,                          -- top 5 features
    latency_ms      NUMERIC(6,2),
    model_version   TEXT NOT NULL,
    scored_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE fraud_labels (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id  TEXT NOT NULL REFERENCES transactions(transaction_id),
    is_fraud_label  BOOLEAN NOT NULL,
    label_source    TEXT NOT NULL,                  -- analyst|dispute|confirmed
    labeled_by      TEXT,
    labeled_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX ON transactions (card_id, event_time DESC);
CREATE INDEX ON transactions (merchant_id, event_time DESC);
CREATE INDEX ON fraud_scores (transaction_id);
CREATE INDEX ON fraud_scores (scored_at DESC);
CREATE INDEX ON fraud_scores (is_fraud, scored_at DESC);
```

```bash
psql postgresql://postgres:password@localhost:5432/fraud_detection < pipeline/schema.sql
```

**Verify:**

```bash
psql postgresql://postgres:password@localhost:5432/fraud_detection -c "\dt"
# Expected: transactions, fraud_scores, fraud_labels
```

### Step 3: Pydantic models

**Goal:** Define typed models for raw transactions and scored outputs so every pipeline stage has validated data contracts.

Create `pipeline/app/models.py`:

```python
from pydantic import BaseModel, Field, field_validator
from typing import Optional, Dict, List
from datetime import datetime
import uuid


class RawTransaction(BaseModel):
    transaction_id: str
    card_id: str
    merchant_id: str
    amount_usd: float = Field(..., gt=0)
    currency: str = Field(default="USD", max_length=3)
    country: str = Field(..., min_length=2, max_length=2)
    device_id: Optional[str] = None
    ip_address: Optional[str] = None
    channel: str = Field(..., pattern="^(online|pos|atm|mobile)$")
    event_time: datetime

    @field_validator("amount_usd")
    @classmethod
    def amount_must_be_positive(cls, v: float) -> float:
        if v <= 0:
            raise ValueError("amount_usd must be positive")
        return round(v, 2)


class FeatureVector(BaseModel):
    transaction_id: str
    card_id: str
    amount_usd: float
    # Velocity features
    card_txn_count_1m: int = 0
    card_txn_count_5m: int = 0
    card_txn_count_1h: int = 0
    card_amount_sum_1h: float = 0.0
    card_amount_avg_1h: float = 0.0
    # Merchant features
    merchant_txn_count_1h: int = 0
    merchant_avg_amount: float = 0.0
    amount_deviation_from_merchant_avg: float = 0.0
    # Device / location
    is_new_device: int = 0                  # 0 or 1
    is_country_change: int = 0              # 0 or 1
    # Contextual
    hour_of_day: int = Field(..., ge=0, le=23)
    day_of_week: int = Field(..., ge=0, le=6)
    channel_online: int = 0
    channel_mobile: int = 0
    channel_atm: int = 0


class ScoredTransaction(BaseModel):
    transaction_id: str
    card_id: str
    fraud_score: float = Field(..., ge=0.0, le=1.0)
    is_fraud: bool
    shap_top_features: Dict[str, float] = Field(default_factory=dict)
    latency_ms: float
    model_version: str
    scored_at: datetime = Field(default_factory=datetime.utcnow)
```

### Step 4: Faust stateful stream processor with Redis feature engineering

**Goal:** Process raw transaction events in real time, compute velocity and behavioral features using Redis as the state backend, and emit feature vectors.

Create `pipeline/app/features.py`:

```python
import faust
import redis
import json
import os
from datetime import datetime
from app.models import RawTransaction, FeatureVector

app = faust.App(
    "fraud-detector",
    broker=os.environ.get("KAFKA_BROKER", "kafka://localhost:9092"),
    value_serializer="json",
)

raw_topic = app.topic("transactions-raw", value_type=bytes)
feature_topic = app.topic("transactions-features", value_type=bytes)

r = redis.from_url(os.environ.get("REDIS_URL", "redis://localhost:6379"), decode_responses=True)

WINDOWS = {"1m": 60, "5m": 300, "1h": 3600}


def redis_incr_window(key_prefix: str, window_seconds: int, event_time: datetime) -> int:
    """Increment a sliding window counter in Redis, return current count."""
    bucket = int(event_time.timestamp()) // window_seconds
    key = f"{key_prefix}:{bucket}"
    pipe = r.pipeline()
    pipe.incr(key)
    pipe.expire(key, window_seconds * 2)
    results = pipe.execute()
    return results[0]


def get_window_sum(key_prefix: str, window_seconds: int, now: datetime) -> float:
    """Sum float values across all active window buckets."""
    now_ts = int(now.timestamp())
    bucket_size = max(window_seconds // 10, 1)
    buckets = range(
        (now_ts - window_seconds) // bucket_size,
        now_ts // bucket_size + 1,
    )
    keys = [f"{key_prefix}:{b}" for b in buckets]
    values = r.mget(keys)
    return sum(float(v) for v in values if v is not None)


@app.agent(raw_topic)
async def process_transaction(stream):
    async for raw_bytes in stream:
        try:
            data = json.loads(raw_bytes)
            txn = RawTransaction(**data)
            now = txn.event_time

            card_prefix = f"card:{txn.card_id}"
            merchant_prefix = f"merchant:{txn.merchant_id}"
            device_key = f"card_devices:{txn.card_id}"
            country_key = f"card_country:{txn.card_id}"

            # Velocity counts
            card_count_1m = redis_incr_window(f"{card_prefix}:count", 60, now)
            card_count_5m = redis_incr_window(f"{card_prefix}:count", 300, now)
            card_count_1h = redis_incr_window(f"{card_prefix}:count", 3600, now)

            # Amount aggregates
            r.lpush(f"{card_prefix}:amounts_1h", txn.amount_usd)
            r.ltrim(f"{card_prefix}:amounts_1h", 0, 999)
            r.expire(f"{card_prefix}:amounts_1h", 3600)
            amounts = [float(a) for a in r.lrange(f"{card_prefix}:amounts_1h", 0, -1)]
            card_amount_sum = sum(amounts)
            card_amount_avg = card_amount_sum / len(amounts) if amounts else 0.0

            # Merchant average
            r.lpush(f"{merchant_prefix}:amounts", txn.amount_usd)
            r.ltrim(f"{merchant_prefix}:amounts", 0, 99)
            r.expire(f"{merchant_prefix}:amounts", 3600 * 24)
            m_amounts = [float(a) for a in r.lrange(f"{merchant_prefix}:amounts", 0, -1)]
            merchant_avg = sum(m_amounts) / len(m_amounts) if m_amounts else txn.amount_usd
            merchant_count_1h = redis_incr_window(f"{merchant_prefix}:count", 3600, now)

            # Device fingerprint
            is_new_device = 0
            if txn.device_id:
                known = r.sismember(device_key, txn.device_id)
                is_new_device = 0 if known else 1
                r.sadd(device_key, txn.device_id)
                r.expire(device_key, 3600 * 24 * 30)

            # Country change
            last_country = r.get(country_key)
            is_country_change = 1 if (last_country and last_country != txn.country) else 0
            r.setex(country_key, 1800, txn.country)

            feature_vec = FeatureVector(
                transaction_id=txn.transaction_id,
                card_id=txn.card_id,
                amount_usd=txn.amount_usd,
                card_txn_count_1m=card_count_1m,
                card_txn_count_5m=card_count_5m,
                card_txn_count_1h=card_count_1h,
                card_amount_sum_1h=card_amount_sum,
                card_amount_avg_1h=card_amount_avg,
                merchant_txn_count_1h=merchant_count_1h,
                merchant_avg_amount=merchant_avg,
                amount_deviation_from_merchant_avg=(txn.amount_usd - merchant_avg) / (merchant_avg + 1e-9),
                is_new_device=is_new_device,
                is_country_change=is_country_change,
                hour_of_day=now.hour,
                day_of_week=now.weekday(),
                channel_online=int(txn.channel == "online"),
                channel_mobile=int(txn.channel == "mobile"),
                channel_atm=int(txn.channel == "atm"),
            )

            await feature_topic.send(
                key=txn.card_id,
                value=feature_vec.model_dump_json().encode(),
            )

        except Exception as e:
            print(f"Feature engineering error: {e}")
```

**Verify:**

```bash
# Start the Faust worker
cd pipeline && python -m faust -A app.features worker -l info &

# Publish a test transaction
python -c "
from kafka import KafkaProducer
import json
from datetime import datetime, timezone

producer = KafkaProducer(bootstrap_servers='localhost:9092')
txn = {
    'transaction_id': 'txn-001',
    'card_id': 'card-abc',
    'merchant_id': 'merchant-xyz',
    'amount_usd': 149.99,
    'currency': 'USD',
    'country': 'US',
    'device_id': 'device-001',
    'channel': 'online',
    'event_time': datetime.now(timezone.utc).isoformat(),
}
producer.send('transactions-raw', json.dumps(txn).encode())
producer.flush()
print('Published transaction')
"
# Expected: Faust logs show processing, feature vector published to transactions-features
```

### Step 5: XGBoost model training and ONNX export

**Goal:** Train a fraud classifier on historical labeled data, evaluate it rigorously, and export it to ONNX for low-latency inference.

Create `pipeline/training/train.py`:

```python
import numpy as np
import xgboost as xgb
from sklearn.model_selection import train_test_split
from sklearn.metrics import (
    classification_report, roc_auc_score, precision_recall_curve, average_precision_score
)
import psycopg2
import os
import json

FEATURE_COLS = [
    "amount_usd", "card_txn_count_1m", "card_txn_count_5m", "card_txn_count_1h",
    "card_amount_sum_1h", "card_amount_avg_1h", "merchant_txn_count_1h",
    "merchant_avg_amount", "amount_deviation_from_merchant_avg",
    "is_new_device", "is_country_change", "hour_of_day", "day_of_week",
    "channel_online", "channel_mobile", "channel_atm",
]


def load_training_data():
    """Load labeled transactions from PostgreSQL for training."""
    conn = psycopg2.connect(os.environ["DATABASE_URL"])
    query = """
        SELECT
            t.amount_usd,
            fs.shap_values->>'card_txn_count_1m' AS card_txn_count_1m,
            l.is_fraud_label
        FROM transactions t
        JOIN fraud_labels l ON l.transaction_id = t.transaction_id
        WHERE l.label_source IN ('analyst', 'confirmed')
        ORDER BY t.event_time
    """
    # NOTE: In production, join against a pre-computed feature store.
    # For training, use the stored feature snapshots in fraud_scores.shap_values.
    import pandas as pd
    df = pd.read_sql(query, conn)
    conn.close()
    return df


def generate_synthetic_data(n_samples: int = 50000):
    """Generate synthetic data for initial model training before real labels accumulate."""
    rng = np.random.default_rng(42)
    n_fraud = int(n_samples * 0.02)  # 2% fraud rate
    n_legit = n_samples - n_fraud

    legit = np.column_stack([
        rng.lognormal(4.5, 1.0, n_legit),   # amount ~$90
        rng.poisson(0.5, n_legit),            # card_txn_count_1m
        rng.poisson(1.5, n_legit),            # card_txn_count_5m
        rng.poisson(6, n_legit),              # card_txn_count_1h
        rng.lognormal(6, 1, n_legit),         # card_amount_sum_1h
        rng.lognormal(4.5, 0.5, n_legit),     # card_amount_avg_1h
        rng.poisson(20, n_legit),             # merchant_txn_count_1h
        rng.lognormal(4.5, 0.8, n_legit),     # merchant_avg_amount
        rng.normal(0, 0.2, n_legit),           # amount_deviation
        rng.binomial(1, 0.05, n_legit),        # is_new_device
        rng.binomial(1, 0.01, n_legit),        # is_country_change
        rng.integers(0, 24, n_legit),          # hour_of_day
        rng.integers(0, 7, n_legit),           # day_of_week
        rng.binomial(1, 0.6, n_legit),         # channel_online
        rng.binomial(1, 0.2, n_legit),         # channel_mobile
        rng.binomial(1, 0.1, n_legit),         # channel_atm
    ])

    fraud = np.column_stack([
        rng.lognormal(6.0, 1.5, n_fraud),     # higher amounts
        rng.poisson(8, n_fraud),               # high velocity
        rng.poisson(20, n_fraud),
        rng.poisson(50, n_fraud),
        rng.lognormal(8, 1, n_fraud),
        rng.lognormal(6, 1, n_fraud),
        rng.poisson(5, n_fraud),
        rng.lognormal(4.5, 0.8, n_fraud),
        rng.normal(3, 1, n_fraud),             # high deviation
        rng.binomial(1, 0.8, n_fraud),         # usually new device
        rng.binomial(1, 0.6, n_fraud),         # often country change
        rng.integers(0, 24, n_fraud),
        rng.integers(0, 7, n_fraud),
        rng.binomial(1, 0.9, n_fraud),
        rng.binomial(1, 0.1, n_fraud),
        rng.binomial(1, 0.05, n_fraud),
    ])

    X = np.vstack([legit, fraud])
    y = np.array([0] * n_legit + [1] * n_fraud)
    shuffle_idx = rng.permutation(n_samples)
    return X[shuffle_idx], y[shuffle_idx]


def train_model():
    X, y = generate_synthetic_data(50000)
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, stratify=y, random_state=42)

    scale_pos_weight = (y_train == 0).sum() / (y_train == 1).sum()

    model = xgb.XGBClassifier(
        n_estimators=300,
        max_depth=6,
        learning_rate=0.05,
        subsample=0.8,
        colsample_bytree=0.8,
        scale_pos_weight=scale_pos_weight,
        eval_metric="aucpr",
        early_stopping_rounds=20,
        random_state=42,
        device="cpu",
    )

    model.fit(
        X_train, y_train,
        eval_set=[(X_test, y_test)],
        verbose=50,
    )

    # Evaluation
    y_prob = model.predict_proba(X_test)[:, 1]
    print("\n=== Model Evaluation ===")
    print(f"ROC-AUC: {roc_auc_score(y_test, y_prob):.4f}")
    print(f"Average Precision: {average_precision_score(y_test, y_prob):.4f}")
    print(classification_report(y_test, model.predict(X_test), target_names=["legit", "fraud"]))

    model.save_model("models/fraud_xgb.json")
    print("Model saved to models/fraud_xgb.json")
    return model, X_test, y_test


if __name__ == "__main__":
    import os
    os.makedirs("models", exist_ok=True)
    train_model()
```

Create `pipeline/training/export_onnx.py`:

```python
import xgboost as xgb
import numpy as np
from skl2onnx.common.data_types import FloatTensorType
import onnxmltools
from onnxmltools.convert.xgboost.operator_converters.XGBoost import convert_xgboost

# Load trained model
model = xgb.XGBClassifier()
model.load_model("models/fraud_xgb.json")

# Export to ONNX
initial_type = [("float_input", FloatTensorType([None, 16]))]
onnx_model = onnxmltools.convert_xgboost(model, initial_types=initial_type)

with open("models/fraud_model.onnx", "wb") as f:
    f.write(onnx_model.SerializeToString())

print("ONNX model exported to models/fraud_model.onnx")

# Sanity-check inference
import onnxruntime as rt
sess = rt.InferenceSession("models/fraud_model.onnx")
test_input = np.zeros((1, 16), dtype=np.float32)
test_input[0, 9] = 1.0   # is_new_device = 1
test_input[0, 10] = 1.0  # is_country_change = 1
test_input[0, 0] = 500.0 # high amount

output = sess.run(None, {"float_input": test_input})
proba = output[1][0][1]  # probability of fraud class
print(f"Test fraud score: {proba:.4f}")
```

**Verify:**

```bash
cd pipeline
python training/train.py
# Expected: ROC-AUC > 0.95 on synthetic data

python training/export_onnx.py
# Expected: ONNX model exported, test fraud score printed
```

### Step 6: ONNX inference + SHAP explainability

**Goal:** Score feature vectors with ONNX Runtime in under 10ms and annotate each decision with the top contributing SHAP features.

Create `pipeline/app/inference.py`:

```python
import onnxruntime as rt
import numpy as np
import shap
import xgboost as xgb
import os
import time
from app.models import FeatureVector, ScoredTransaction
from datetime import datetime

FEATURE_COLS = [
    "amount_usd", "card_txn_count_1m", "card_txn_count_5m", "card_txn_count_1h",
    "card_amount_sum_1h", "card_amount_avg_1h", "merchant_txn_count_1h",
    "merchant_avg_amount", "amount_deviation_from_merchant_avg",
    "is_new_device", "is_country_change", "hour_of_day", "day_of_week",
    "channel_online", "channel_mobile", "channel_atm",
]

MODEL_PATH = os.environ.get("MODEL_PATH", "models/fraud_model.onnx")
XGB_PATH = os.environ.get("XGB_PATH", "models/fraud_xgb.json")
FRAUD_THRESHOLD = float(os.environ.get("FRAUD_THRESHOLD", "0.7"))
MODEL_VERSION = "v1.0.0"

_onnx_session = None
_shap_explainer = None


def get_onnx_session() -> rt.InferenceSession:
    global _onnx_session
    if _onnx_session is None:
        opts = rt.SessionOptions()
        opts.intra_op_num_threads = 1
        opts.inter_op_num_threads = 1
        _onnx_session = rt.InferenceSession(MODEL_PATH, sess_options=opts)
    return _onnx_session


def get_shap_explainer():
    global _shap_explainer
    if _shap_explainer is None:
        xgb_model = xgb.XGBClassifier()
        xgb_model.load_model(XGB_PATH)
        _shap_explainer = shap.TreeExplainer(xgb_model)
    return _shap_explainer


def feature_vec_to_array(fv: FeatureVector) -> np.ndarray:
    return np.array(
        [[getattr(fv, col) for col in FEATURE_COLS]],
        dtype=np.float32,
    )


def get_top_shap_features(fv: FeatureVector, n: int = 5) -> dict:
    """Return the top N features by absolute SHAP value."""
    explainer = get_shap_explainer()
    arr = feature_vec_to_array(fv)
    shap_vals = explainer.shap_values(arr)[0]   # shape: (n_features,)
    feature_importance = dict(zip(FEATURE_COLS, shap_vals.tolist()))
    top = sorted(feature_importance.items(), key=lambda x: abs(x[1]), reverse=True)[:n]
    return dict(top)


def score_transaction(fv: FeatureVector) -> ScoredTransaction:
    session = get_onnx_session()

    t0 = time.perf_counter()
    arr = feature_vec_to_array(fv)
    output = session.run(None, {"float_input": arr})
    fraud_score = float(output[1][0][1])   # class 1 probability
    latency_ms = (time.perf_counter() - t0) * 1000

    # SHAP is slower (~5-15ms); only compute if flagged for review
    shap_features = {}
    if fraud_score >= FRAUD_THRESHOLD * 0.8:  # compute for borderline + fraud
        shap_features = get_top_shap_features(fv)

    return ScoredTransaction(
        transaction_id=fv.transaction_id,
        card_id=fv.card_id,
        fraud_score=fraud_score,
        is_fraud=fraud_score >= FRAUD_THRESHOLD,
        shap_top_features=shap_features,
        latency_ms=latency_ms,
        model_version=MODEL_VERSION,
        scored_at=datetime.utcnow(),
    )
```

**Verify:**

```bash
python -c "
from app.models import FeatureVector
from app.inference import score_transaction
from datetime import datetime

fv = FeatureVector(
    transaction_id='test-001',
    card_id='card-abc',
    amount_usd=2500.0,
    card_txn_count_1m=8,
    card_txn_count_5m=15,
    card_txn_count_1h=40,
    card_amount_sum_1h=9800.0,
    card_amount_avg_1h=245.0,
    merchant_txn_count_1h=3,
    merchant_avg_amount=80.0,
    amount_deviation_from_merchant_avg=30.25,
    is_new_device=1,
    is_country_change=1,
    hour_of_day=3,
    day_of_week=6,
    channel_online=1,
    channel_mobile=0,
    channel_atm=0,
)
result = score_transaction(fv)
print(f'Score: {result.fraud_score:.4f}, is_fraud: {result.is_fraud}, latency: {result.latency_ms:.2f}ms')
print(f'Top features: {result.shap_top_features}')
# Expected: high fraud score, latency < 10ms
"
```

### Step 7: Scoring agent — Faust consumer with DB persistence

**Goal:** Consume feature vectors from Kafka, score them, persist to PostgreSQL, and publish scored results.

Create `pipeline/app/publisher.py`:

```python
import faust
import json
import os
import psycopg2
from datetime import datetime
from app.models import FeatureVector, ScoredTransaction
from app.inference import score_transaction
from prometheus_client import Counter, Histogram, start_http_server

# Metrics
scored_total = Counter("transactions_scored_total", "Scored transactions", ["is_fraud"])
fraud_score_hist = Histogram("fraud_score", "Fraud score distribution", buckets=[0.1*i for i in range(11)])
latency_hist = Histogram("scoring_latency_ms", "ONNX scoring latency", buckets=[1, 2, 5, 10, 20, 50, 100])

app = faust.App(
    "fraud-scorer",
    broker=os.environ.get("KAFKA_BROKER", "kafka://localhost:9092"),
    value_serializer="json",
)

feature_topic = app.topic("transactions-features", value_type=bytes)
scored_topic = app.topic("scored-transactions", value_type=bytes)


def get_db():
    return psycopg2.connect(os.environ["DATABASE_URL"])


@app.agent(feature_topic)
async def score_agent(stream):
    async for raw_bytes in stream:
        try:
            data = json.loads(raw_bytes)
            fv = FeatureVector(**data)
            result = score_transaction(fv)

            # Prometheus
            scored_total.labels(is_fraud=str(result.is_fraud)).inc()
            fraud_score_hist.observe(result.fraud_score)
            latency_hist.observe(result.latency_ms)

            # Persist to PostgreSQL
            conn = get_db()
            with conn.cursor() as cur:
                cur.execute(
                    """INSERT INTO fraud_scores
                       (transaction_id, fraud_score, is_fraud, shap_values, latency_ms, model_version)
                       VALUES (%s, %s, %s, %s, %s, %s)
                       ON CONFLICT DO NOTHING""",
                    (
                        result.transaction_id,
                        result.fraud_score,
                        result.is_fraud,
                        json.dumps(result.shap_top_features),
                        result.latency_ms,
                        result.model_version,
                    ),
                )
                conn.commit()
            conn.close()

            # Publish scored result
            await scored_topic.send(
                key=result.card_id,
                value=result.model_dump_json().encode(),
            )

        except Exception as e:
            print(f"Scoring error: {e}")


@app.timer(interval=60.0)
async def alert_check():
    """Check for fraud spikes every 60 seconds and fire PagerDuty if needed."""
    import requests

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            """SELECT COUNT(*) FROM fraud_scores
               WHERE is_fraud = true AND scored_at > now() - interval '5 minutes'"""
        )
        fraud_count = cur.fetchone()[0]
    conn.close()

    if fraud_count > 50:  # alert threshold: >50 fraud txns in 5 min
        routing_key = os.environ.get("PAGERDUTY_ROUTING_KEY")
        if routing_key:
            requests.post(
                "https://events.pagerduty.com/v2/enqueue",
                json={
                    "routing_key": routing_key,
                    "event_action": "trigger",
                    "payload": {
                        "summary": f"Fraud spike: {fraud_count} fraud transactions in last 5 minutes",
                        "severity": "critical",
                        "source": "fraud-detector",
                    },
                },
            )
```

**Verify:**

```bash
# Start both Faust workers
python -m faust -A app.features worker -l info &
python -m faust -A app.publisher worker -l info &

# After publishing test transactions, check the DB
psql postgresql://postgres:password@localhost:5432/fraud_detection \
  -c "SELECT transaction_id, fraud_score, is_fraud, latency_ms FROM fraud_scores LIMIT 5;"
```

### Step 8: dbt analytical mart

**Goal:** Build the dbt transformation layer that creates reusable fraud analysis views for reporting and model retraining.

```bash
pip install dbt-postgres
dbt init dbt_mart --profiles-dir dbt_mart
```

Create `dbt_mart/models/staging/stg_transactions.sql`:

```sql
-- stg_transactions.sql
WITH base AS (
    SELECT
        t.transaction_id,
        t.card_id,
        t.merchant_id,
        t.amount_usd,
        t.country,
        t.channel,
        t.event_time,
        fs.fraud_score,
        fs.is_fraud,
        fs.shap_values,
        fs.latency_ms,
        fs.model_version,
        fs.scored_at,
        fl.is_fraud_label,
        fl.label_source
    FROM transactions t
    LEFT JOIN fraud_scores fs ON fs.transaction_id = t.transaction_id
    LEFT JOIN fraud_labels fl ON fl.transaction_id = t.transaction_id
)
SELECT * FROM base
```

Create `dbt_mart/models/marts/fraud_summary.sql`:

```sql
-- fraud_summary.sql
-- Daily fraud summary for analyst dashboards and retraining triggers
{{ config(materialized='incremental', unique_key='date_day || card_id') }}

WITH daily AS (
    SELECT
        DATE_TRUNC('day', event_time)::DATE AS date_day,
        card_id,
        COUNT(*) AS total_transactions,
        SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) AS flagged_fraud,
        SUM(CASE WHEN is_fraud_label = true THEN 1 ELSE 0 END) AS confirmed_fraud,
        SUM(CASE WHEN is_fraud = true AND is_fraud_label = false THEN 1 ELSE 0 END) AS false_positives,
        AVG(fraud_score) AS avg_fraud_score,
        AVG(latency_ms) AS avg_latency_ms,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY latency_ms) AS p99_latency_ms
    FROM {{ ref('stg_transactions') }}
    {% if is_incremental() %}
    WHERE event_time > (SELECT MAX(date_day) FROM {{ this }})
    {% endif %}
    GROUP BY 1, 2
)
SELECT
    *,
    CASE WHEN total_transactions > 0
         THEN ROUND(confirmed_fraud::NUMERIC / total_transactions, 4)
    END AS fraud_rate,
    CASE WHEN flagged_fraud > 0
         THEN ROUND(false_positives::NUMERIC / flagged_fraud, 4)
    END AS false_positive_rate
FROM daily
```

```bash
cd dbt_mart
dbt deps
dbt run --profiles-dir .
dbt test --profiles-dir .
```

**Verify:**

```bash
psql postgresql://postgres:password@localhost:5432/fraud_detection \
  -c "SELECT date_day, total_transactions, avg_fraud_score FROM fraud_summary LIMIT 5;"
```

### Step 9: Testing and model evaluation

**Goal:** Cover inference, features, and the scoring pipeline with unit tests; run a holdout evaluation with precision-recall analysis.

Create `pipeline/tests/test_inference.py`:

```python
import pytest
import numpy as np
from app.models import FeatureVector
from app.inference import feature_vec_to_array, FEATURE_COLS


def make_feature_vector(**overrides) -> FeatureVector:
    defaults = dict(
        transaction_id="test-001",
        card_id="card-abc",
        amount_usd=50.0,
        card_txn_count_1m=0,
        card_txn_count_5m=1,
        card_txn_count_1h=3,
        card_amount_sum_1h=150.0,
        card_amount_avg_1h=50.0,
        merchant_txn_count_1h=20,
        merchant_avg_amount=55.0,
        amount_deviation_from_merchant_avg=-0.09,
        is_new_device=0,
        is_country_change=0,
        hour_of_day=14,
        day_of_week=2,
        channel_online=1,
        channel_mobile=0,
        channel_atm=0,
    )
    defaults.update(overrides)
    return FeatureVector(**defaults)


def test_feature_vector_to_array_shape():
    fv = make_feature_vector()
    arr = feature_vec_to_array(fv)
    assert arr.shape == (1, len(FEATURE_COLS))
    assert arr.dtype == np.float32


def test_legitimate_transaction_low_score():
    from app.inference import score_transaction
    fv = make_feature_vector()
    result = score_transaction(fv)
    assert result.fraud_score < 0.5
    assert not result.is_fraud
    assert result.latency_ms < 50  # sub-50ms SLA


def test_suspicious_transaction_high_score():
    from app.inference import score_transaction
    fv = make_feature_vector(
        amount_usd=3000.0,
        card_txn_count_1m=10,
        card_txn_count_5m=25,
        card_txn_count_1h=60,
        is_new_device=1,
        is_country_change=1,
        amount_deviation_from_merchant_avg=35.0,
        hour_of_day=3,
    )
    result = score_transaction(fv)
    assert result.fraud_score > 0.5


def test_feature_vector_validates_negative_amount():
    with pytest.raises(Exception):
        make_feature_vector(amount_usd=-10.0)
```

```bash
cd pipeline && pytest tests/ -v --tb=short
```

Run holdout evaluation with threshold sweep:

```bash
python -c "
from training.train import generate_synthetic_data
from sklearn.model_selection import train_test_split
from sklearn.metrics import precision_recall_curve
import xgboost as xgb
import numpy as np

X, y = generate_synthetic_data(50000)
_, X_test, _, y_test = train_test_split(X, y, test_size=0.2, stratify=y, random_state=42)

model = xgb.XGBClassifier()
model.load_model('models/fraud_xgb.json')
y_prob = model.predict_proba(X_test)[:, 1]

precision, recall, thresholds = precision_recall_curve(y_test, y_prob)
f1 = 2 * precision * recall / (precision + recall + 1e-9)
best_idx = np.argmax(f1)
print(f'Best threshold: {thresholds[best_idx]:.3f}')
print(f'Precision: {precision[best_idx]:.3f}, Recall: {recall[best_idx]:.3f}, F1: {f1[best_idx]:.3f}')
"
```

### Step 10: CI/CD retraining pipeline

**Goal:** Automate weekly model retraining with new labeled data using GitHub Actions.

Create `.github/workflows/retrain.yml`:

```yaml
name: Weekly Model Retrain

on:
  schedule:
    - cron: "0 2 * * 1"   # Every Monday at 02:00 UTC
  workflow_dispatch:        # Manual trigger

jobs:
  retrain:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install dependencies
        run: pip install -r pipeline/requirements.txt

      - name: Train model
        run: python pipeline/training/train.py
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}

      - name: Export ONNX
        run: python pipeline/training/export_onnx.py

      - name: Run evaluation gate
        run: |
          python -c "
          import xgboost as xgb, numpy as np
          from sklearn.metrics import roc_auc_score
          from training.train import generate_synthetic_data
          from sklearn.model_selection import train_test_split

          X, y = generate_synthetic_data(10000)
          _, X_test, _, y_test = train_test_split(X, y, test_size=0.2, stratify=y)
          model = xgb.XGBClassifier()
          model.load_model('models/fraud_xgb.json')
          auc = roc_auc_score(y_test, model.predict_proba(X_test)[:, 1])
          print(f'AUC: {auc:.4f}')
          assert auc >= 0.90, f'AUC {auc:.4f} below threshold 0.90 — rejecting model'
          "
        working-directory: pipeline

      - name: Upload model artifacts
        uses: actions/upload-artifact@v4
        with:
          name: fraud-model-${{ github.run_id }}
          path: |
            pipeline/models/fraud_xgb.json
            pipeline/models/fraud_model.onnx

      - name: Run tests
        run: cd pipeline && pytest tests/ -v
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

**Verify:**

```bash
# Manually trigger the retrain workflow
gh workflow run retrain.yml
gh run list --workflow=retrain.yml
# Expected: workflow completes with green status
```

## Testing

```bash
# Unit tests for all pipeline components
cd pipeline && pytest tests/ -v --cov=app --cov-report=term-missing

# Latency benchmark: ensure p99 < 50ms
python -c "
import time, statistics
from app.models import FeatureVector
from app.inference import score_transaction

fv = FeatureVector(
    transaction_id='bench', card_id='card-x', amount_usd=100.0,
    card_txn_count_1m=1, card_txn_count_5m=3, card_txn_count_1h=10,
    card_amount_sum_1h=1000.0, card_amount_avg_1h=100.0,
    merchant_txn_count_1h=15, merchant_avg_amount=90.0,
    amount_deviation_from_merchant_avg=0.1,
    is_new_device=0, is_country_change=0,
    hour_of_day=12, day_of_week=1,
    channel_online=1, channel_mobile=0, channel_atm=0,
)

latencies = []
for _ in range(1000):
    result = score_transaction(fv)
    latencies.append(result.latency_ms)

p50 = statistics.median(latencies)
p99 = statistics.quantiles(latencies, n=100)[98]
print(f'p50: {p50:.2f}ms, p99: {p99:.2f}ms')
assert p99 < 50, f'p99 latency {p99:.2f}ms exceeds 50ms SLA'
print('Latency SLA: PASS')
"

# dbt tests
cd dbt_mart && dbt test --profiles-dir .
```

## Deployment

1. **Kafka** — use Confluent Cloud (confluent.io) managed Kafka; update `KAFKA_BROKER` to your bootstrap URL
2. **Redis** — use Redis Cloud (redis.com) or AWS ElastiCache; update `REDIS_URL`
3. **PostgreSQL** — use AWS RDS PostgreSQL 15 with Multi-AZ for high availability
4. **Faust workers** — deploy as ECS Fargate tasks with auto-scaling based on Kafka consumer lag
5. **ONNX model** — load from S3 at startup; model path passed as `MODEL_PATH` env var
6. **Grafana** — use Grafana Cloud; configure Prometheus remote_write from the ECS tasks
7. **PagerDuty** — create a service with an Events API v2 integration; store routing key in AWS Secrets Manager

## Resources

1. [XGBoost early stopping](https://xgboost.readthedocs.io/en/stable/python/examples/early_stopping.html) — preventing overfitting on imbalanced datasets
2. [ONNX Runtime performance tuning](https://onnxruntime.ai/docs/performance/tune-performance/) — thread settings for sub-10ms inference
3. [Faust documentation](https://faust-streaming.github.io/faust/) — tables, windowing, and stateful stream processing
4. [SHAP TreeExplainer](https://shap.readthedocs.io/en/latest/generated/shap.TreeExplainer.html) — fast exact SHAP for tree models
5. [dbt incremental models](https://docs.getdbt.com/docs/build/incremental-models) — efficient large-table transformations
6. [PagerDuty Events API v2](https://developer.pagerduty.com/api-reference/368ae3d938c9e-send-an-event-to-pager-duty) — triggering alerts from Python

## Skill coverage mapping

Refer to: `doc/research/skill-matrix.md` and `doc/roadmap/bridge.md`

Bridge entries for this project: `P03_SK02`, `P03_SK03`, `P03_SK06`, `P03_SK11`, `P03_SK13`, `P03_SK14`, `P03_SK17`, `P03_SK18`, `P03_SK19`

Tool entries: `P03_TL18` (Kafka), `P03_TL19` (Faust), `P03_TL20` (XGBoost), `P03_TL22` (ONNX Runtime), `P03_TL23` (Redis), `P03_TL24` (Grafana), `P03_TL25` (PagerDuty), `P03_TL27` (dbt), `P03_TL28` (SHAP), `P03_TL04` (PostgreSQL)
