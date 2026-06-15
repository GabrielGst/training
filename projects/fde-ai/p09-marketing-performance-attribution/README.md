# P09 — Marketing Performance Attribution

**Domain:** Marketing / Analytics  **Track:** `fde-ai`  **Status:** not started  **Hours target:** 38

## Business Problem

A marketing team running campaigns across paid search, social, email, content, influencer, and events cannot determine true channel ROI. Last-click attribution misattributes 40% of conversions to the final touchpoint, starving high-impact upper-funnel channels of budget. This project builds a Shapley-value multi-touch attribution model backed by a Snowflake data warehouse, a dbt transformation layer, and a Looker dashboard that finally shows the marketing team what each dollar is actually doing.

## What you will build

- A Google Analytics API ingestion pipeline that pulls session and conversion event data daily into Snowflake via a staging schema
- A dbt transformation layer with staging models, intermediate models, and a `mart_attribution` mart exposing clean per-touchpoint data
- A Python Shapley-value attribution model that correctly credits each channel across the full conversion journey
- A Flask API with a `/attribution` endpoint that computes on-demand channel attribution for arbitrary date ranges
- A Looker dashboard visualising channel ROI, conversion-path funnels, and budget recommendations
- A GitHub Actions CI/CD pipeline that runs dbt tests and re-trains the attribution model on every push to main

## Architecture

```
Google Analytics API    (other channel APIs)
        |                       |
   GA Ingestion (Python)   ETL adapters
        |                       |
           Snowflake (staging schema)
                    |
              dbt transformations
                    |
           mart_attribution table
                    |
      Shapley Attribution Model (Python)
                    |
             Flask /attribution API
                    |              \
            Looker Dashboard    GitHub Actions CI
                                  (dbt test + retrain)
```

## Skills covered

| Skill ID | Skill Name | What you practice |
|----------|------------|------------------|
| SK02 | RAG Architecture Design | Not directly applied here; foundational pattern reviewed during architecture planning |
| SK04 | API Design and Contract Management | Flask REST API with versioned routes, Pydantic validation, OpenAPI docs |
| SK06 | Database Schema Design and Query Optimization | Snowflake staging + mart schema; dbt tests; clustering keys for fast attribution queries |
| SK07 | Data Security and Privacy Compliance | PII redaction of user IDs before attribution; Snowflake column-level access controls |
| SK08 | Observability and Production Debugging | dbt test alerting; Flask request logging; Snowflake query profiling |
| SK13 | Agentic Workflows and Tool Use | LLM agent calling `/attribution` as a tool to answer natural-language budget questions |
| SK15 | Real-time Integration and Event Streaming | Webhook listener updating attribution cache as conversion events arrive |
| SK20 | Cost Optimization and Resource Allocation | Snowflake credit budget; Redis caching attribution results to reduce warehouse queries |
| SK21 | Time Series Forecasting and Trend Analysis | Weekly attribution trend decomposition; channel contribution moving averages |
| SK22 | Experimentation and A/B Testing Frameworks | A/B test comparing Shapley attribution against last-click on budget allocation decisions |
| SK31 | Statistical Modeling and Causal Inference | Shapley values for multi-player cooperative game attribution across 6+ channels |

## Tools & dependencies

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| Snowflake | current | Cloud data warehouse for all event data | Snowflake trial account |
| dbt | 1.8 | SQL-based transformation layer with testing | `pip install dbt-snowflake` |
| Looker | 7.x | Business intelligence dashboards | Looker Studio (free) or Looker |
| Google Analytics API | v4 | Pull session and conversion data | `pip install google-analytics-data` |
| Flask | 3.x | Python REST API for attribution queries | `pip install flask` |
| PostgreSQL | 16 | Local development database | Docker |
| S3 | latest | Raw event archive and dbt artifact storage | AWS CLI |
| GitHub Actions | latest | CI/CD: dbt tests and model retraining | Included with GitHub |
| Express.js | 4.x | Node.js webhook listener for real-time events | `npm install express` |

## Prerequisites

**Track modules to complete first:**
- [ ] `data-engineer/04-data-pipelines-airflow` — pipeline orchestration patterns before building the GA ingestion job
- [ ] `data-engineer/05-dbt-transformations` — dbt models, tests, and lineage before building the mart layer
- [ ] `data-engineer/06-data-warehouse` — Snowflake architecture, clustering keys, cost controls
- [ ] `ai-engineer/10-time-series-forecasting` — trend decomposition applied to weekly attribution series

**Accounts / API keys needed:**
- [ ] Snowflake — trial account (30 days free, $400 credit)
- [ ] Google Analytics — GA4 property with Data API access enabled
- [ ] AWS — S3 bucket for raw event archiving
- [ ] Looker Studio — free Google account; or Looker license for full LookML

---

## Step-by-step tutorial

### Step 1: Environment setup

**Goal:** Configure Snowflake, install dbt, and connect all Python and Node dependencies.

```bash
# Python environment
python -m venv .venv && source .venv/bin/activate
pip install dbt-snowflake flask pandas google-analytics-data python-dotenv \
            itertools sqlalchemy psycopg2-binary redis prometheus-client

# Node (webhook listener)
npm install express dotenv axios
```

Configure dbt to connect to Snowflake:

```yaml
# ~/.dbt/profiles.yml
marketing_attribution:
  target: dev
  outputs:
    dev:
      type: snowflake
      account:   "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
      user:      "{{ env_var('SNOWFLAKE_USER') }}"
      password:  "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      role:      TRANSFORMER
      database:  MARKETING
      warehouse: COMPUTE_WH
      schema:    DEV
      threads:   4
```

Create the Snowflake databases and schemas:

```sql
-- Run in Snowflake worksheet
CREATE DATABASE IF NOT EXISTS MARKETING;
CREATE SCHEMA IF NOT EXISTS MARKETING.RAW;
CREATE SCHEMA IF NOT EXISTS MARKETING.STAGING;
CREATE SCHEMA IF NOT EXISTS MARKETING.MART;
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND   = 60
    AUTO_RESUME    = TRUE;
```

**Verify:** `dbt debug` from the project root prints `All checks passed!`.

---

### Step 2: Google Analytics ingestion

**Goal:** Pull GA4 session and conversion data daily into the Snowflake RAW schema.

```python
# src/ga_ingest.py
import os, json
from datetime import date, timedelta
from google.analytics.data_v1beta import BetaAnalyticsDataClient
from google.analytics.data_v1beta.types import (
    RunReportRequest, Dimension, Metric, DateRange,
)
import snowflake.connector

GA_PROPERTY_ID = os.environ["GA_PROPERTY_ID"]
client         = BetaAnalyticsDataClient()

def fetch_sessions(start_date: str, end_date: str) -> list[dict]:
    request = RunReportRequest(
        property=f"properties/{GA_PROPERTY_ID}",
        date_ranges=[DateRange(start_date=start_date, end_date=end_date)],
        dimensions=[
            Dimension(name="sessionDefaultChannelGroup"),
            Dimension(name="sessionSource"),
            Dimension(name="sessionMedium"),
            Dimension(name="date"),
        ],
        metrics=[
            Metric(name="sessions"),
            Metric(name="conversions"),
            Metric(name="totalRevenue"),
        ],
    )
    response = client.run_report(request)
    rows = []
    for row in response.rows:
        rows.append({
            "channel":    row.dimension_values[0].value,
            "source":     row.dimension_values[1].value,
            "medium":     row.dimension_values[2].value,
            "date":       row.dimension_values[3].value,
            "sessions":   int(row.metric_values[0].value),
            "conversions": int(row.metric_values[1].value),
            "revenue":    float(row.metric_values[2].value),
        })
    return rows

def load_to_snowflake(rows: list[dict], run_date: str) -> None:
    conn   = snowflake.connector.connect(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        password=os.environ["SNOWFLAKE_PASSWORD"],
        database="MARKETING",
        schema="RAW",
        warehouse="COMPUTE_WH",
    )
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS RAW.GA_SESSIONS (
            channel     TEXT,
            source      TEXT,
            medium      TEXT,
            event_date  DATE,
            sessions    INT,
            conversions INT,
            revenue     FLOAT,
            loaded_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    cursor.executemany(
        "INSERT INTO RAW.GA_SESSIONS VALUES (%s,%s,%s,%s,%s,%s,%s,CURRENT_TIMESTAMP)",
        [(r["channel"], r["source"], r["medium"], r["date"],
          r["sessions"], r["conversions"], r["revenue"]) for r in rows],
    )
    conn.commit()
    conn.close()

if __name__ == "__main__":
    yesterday = str(date.today() - timedelta(days=1))
    rows = fetch_sessions(yesterday, yesterday)
    load_to_snowflake(rows, yesterday)
    print(f"Loaded {len(rows)} rows for {yesterday}")
```

**File structure:**
```
src/
  ga_ingest.py
  attribution.py   <- built in step 4
  api.py
models/
  staging/
    stg_ga_sessions.sql
  intermediate/
    int_conversion_journeys.sql
  mart/
    mart_attribution.sql
dbt_project.yml
```

**Verify:** `python src/ga_ingest.py` completes without error; `SELECT COUNT(*) FROM RAW.GA_SESSIONS` in Snowflake returns rows.

---

### Step 3: dbt transformation layer

**Goal:** Build staging, intermediate, and mart models with dbt tests to ensure data quality before attribution.

```yaml
# dbt_project.yml
name: marketing_attribution
version: "1.0.0"
profile: marketing_attribution

models:
  marketing_attribution:
    staging:
      +schema: STAGING
      +materialized: view
    intermediate:
      +schema: STAGING
      +materialized: ephemeral
    mart:
      +schema: MART
      +materialized: table
      +cluster_by: ["channel", "event_date"]
```

```sql
-- models/staging/stg_ga_sessions.sql
SELECT
    channel,
    source,
    medium,
    event_date::DATE                         AS event_date,
    sessions::INT                            AS sessions,
    conversions::INT                         AS conversions,
    revenue::FLOAT                           AS revenue,
    CURRENT_TIMESTAMP                        AS _dbt_loaded_at
FROM {{ source('raw', 'ga_sessions') }}
WHERE event_date >= DATEADD('day', -90, CURRENT_DATE)
```

```sql
-- models/mart/mart_attribution.sql
WITH daily AS (
    SELECT
        channel,
        event_date,
        SUM(sessions)    AS sessions,
        SUM(conversions) AS conversions,
        SUM(revenue)     AS revenue
    FROM {{ ref('stg_ga_sessions') }}
    GROUP BY 1, 2
),
with_share AS (
    SELECT
        *,
        SUM(conversions) OVER (PARTITION BY event_date) AS total_conversions_day,
        ROUND(conversions /
              NULLIF(SUM(conversions) OVER (PARTITION BY event_date), 0), 4
        ) AS last_click_share
    FROM daily
)
SELECT * FROM with_share
```

```yaml
# models/staging/schema.yml
version: 2
sources:
  - name: raw
    database: MARKETING
    schema: RAW
    tables:
      - name: ga_sessions
        columns:
          - name: channel
            tests: [not_null]
          - name: event_date
            tests: [not_null]
          - name: conversions
            tests:
              - not_null
              - dbt_utils.accepted_range:
                  min_value: 0
```

```bash
dbt run && dbt test
```

**Verify:** `dbt test` passes all schema tests; `SELECT * FROM MARKETING.MART.MART_ATTRIBUTION LIMIT 5` returns rows in Snowflake.

---

### Step 4: Shapley-value attribution model

**Goal:** Implement cooperative game theory Shapley values to correctly credit each channel across the full conversion funnel.

```python
# src/attribution.py
"""
Shapley-value multi-touch attribution.
Each conversion journey is a coalition game where channels are players.
The Shapley value for channel c = average marginal contribution of c
across all possible orderings of the channels that appeared in the journey.
"""
from itertools import combinations
from collections import defaultdict
import math

def shapley_attribution(
    journeys: list[list[str]],
    values:   list[float],
) -> dict[str, float]:
    """
    journeys: list of ordered channel sequences leading to conversion
    values:   revenue value of each conversion
    Returns:  {channel: total_shapley_credit}
    """
    channel_credit: dict[str, float] = defaultdict(float)

    for journey, value in zip(journeys, values):
        channels = list(dict.fromkeys(journey))  # deduplicate, preserve order
        n        = len(channels)
        if n == 0:
            continue

        # Characteristic function: value if subset S converts (simplified: uniform)
        def v(subset: tuple) -> float:
            # Real implementation: use historical conversion rate for this subset
            return value * (len(subset) / n)

        for i, channel in enumerate(channels):
            phi = 0.0
            for size in range(n):
                for subset in combinations([c for j, c in enumerate(channels) if j != i], size):
                    s = len(subset)
                    weight = (math.factorial(s) * math.factorial(n - s - 1)
                              / math.factorial(n))
                    coalition_with    = tuple(sorted(subset + (channel,)))
                    coalition_without = tuple(sorted(subset))
                    phi += weight * (v(coalition_with) - v(coalition_without))
            channel_credit[channel] += phi

    return dict(channel_credit)

def run_attribution_from_mart(df) -> dict[str, float]:
    """
    df: mart_attribution DataFrame with columns [channel, event_date, conversions, revenue]
    Treats each day's channel mix as a single-step journey.
    """
    journeys, values = [], []
    for date, group in df.groupby("event_date"):
        journey = group.sort_values("sessions", ascending=False)["channel"].tolist()
        total_revenue = float(group["revenue"].sum())
        journeys.append(journey)
        values.append(total_revenue)
    return shapley_attribution(journeys, values)
```

**Verify:** `from src.attribution import shapley_attribution; print(shapley_attribution([["paid_search","email","social"]], [100.0]))` returns a dict with three channel keys summing to 100.0.

---

### Step 5: Flask attribution API

**Goal:** Expose the Shapley model through a versioned REST endpoint with Redis caching to avoid re-running Snowflake queries on every request.

```python
# src/api.py
import os, json
from flask import Flask, request, jsonify
import redis
import pandas as pd
import snowflake.connector
from src.attribution import run_attribution_from_mart

app = Flask(__name__)
rc  = redis.Redis(host=os.environ.get("REDIS_HOST", "localhost"), decode_responses=True)

def query_mart(start_date: str, end_date: str) -> pd.DataFrame:
    conn = snowflake.connector.connect(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        password=os.environ["SNOWFLAKE_PASSWORD"],
        database="MARKETING",
        schema="MART",
        warehouse="COMPUTE_WH",
    )
    df = pd.read_sql(
        f"SELECT * FROM MART_ATTRIBUTION WHERE event_date BETWEEN '{start_date}' AND '{end_date}'",
        conn,
    )
    conn.close()
    return df

@app.get("/api/v1/attribution")
def attribution():
    start = request.args.get("start_date", "2024-01-01")
    end   = request.args.get("end_date",   "2024-01-31")

    cache_key = f"attribution:{start}:{end}"
    cached    = rc.get(cache_key)
    if cached:
        return jsonify({"source": "cache", "data": json.loads(cached)})

    df     = query_mart(start, end)
    result = run_attribution_from_mart(df)
    rc.setex(cache_key, 3600, json.dumps(result))
    return jsonify({"source": "computed", "data": result})

@app.get("/api/v1/attribution/health")
def health():
    return jsonify({"status": "ok"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002, debug=False)
```

```bash
flask --app src.api run --port 5002
```

**Verify:** `curl "http://localhost:5002/api/v1/attribution?start_date=2024-01-01&end_date=2024-01-31"` returns `{"source":"computed","data":{...}}`.

---

### Step 6: A/B test — Shapley vs last-click attribution

**Goal:** Statistically validate that Shapley attribution produces better budget allocation decisions than last-click.

```python
# src/ab_test.py
"""
Test: does Shapley attribution improve forecasted conversion rate
when used to reallocate a $10K monthly budget vs. last-click?
Use two months as the test and holdout periods.
"""
import numpy as np
from scipy import stats

def compare_attribution_strategies(
    shapley_conversions:   np.ndarray,
    last_click_conversions: np.ndarray,
    alpha: float = 0.05,
) -> dict:
    t_stat, p_value = stats.ttest_ind(shapley_conversions, last_click_conversions)
    lift = (shapley_conversions.mean() - last_click_conversions.mean()) / \
           last_click_conversions.mean()

    return {
        "shapley_mean":     round(float(shapley_conversions.mean()), 2),
        "last_click_mean":  round(float(last_click_conversions.mean()), 2),
        "lift_pct":         round(lift * 100, 2),
        "p_value":          round(p_value, 4),
        "significant":      p_value < alpha,
        "recommendation":   "Adopt Shapley" if (p_value < alpha and lift > 0) else "Inconclusive",
    }

if __name__ == "__main__":
    # Simulate: Shapley-guided budget outperforms last-click by ~12%
    np.random.seed(42)
    shapley   = np.random.normal(loc=112, scale=18, size=30)
    lastclick = np.random.normal(loc=100, scale=20, size=30)
    result    = compare_attribution_strategies(shapley, lastclick)
    print(result)
```

**Verify:** `python src/ab_test.py` prints `"significant": True` and `"recommendation": "Adopt Shapley"` with the simulated data.

---

### Step 7: Express.js real-time webhook listener

**Goal:** Accept real-time conversion events from the website and invalidate the Redis attribution cache immediately.

```javascript
// server/webhook.js
const express = require("express");
const redis   = require("redis");
const app     = express();
app.use(express.json());

const rc = redis.createClient({ url: process.env.REDIS_URL || "redis://localhost:6379" });
rc.connect();

// POST /webhook/conversion — fired by the frontend on each conversion
app.post("/webhook/conversion", async (req, res) => {
  const { channel, source, revenue, event_date } = req.body;
  if (!channel || !event_date) {
    return res.status(400).json({ error: "channel and event_date required" });
  }

  // Invalidate all cached attribution results that include this date
  const keys = await rc.keys(`attribution:*:${event_date}*`);
  if (keys.length) await rc.del(keys);

  // In production: also stream event to Kafka / Snowflake ingestion queue
  console.log(`Conversion received: ${channel} / ${revenue} / ${event_date}`);
  res.json({ received: true, cache_invalidated: keys.length });
});

app.listen(3002, () => console.log("Webhook listener on :3002"));
```

```bash
node server/webhook.js
```

**Verify:** `curl -X POST http://localhost:3002/webhook/conversion -H "Content-Type: application/json" -d '{"channel":"paid_search","revenue":49.99,"event_date":"2024-01-15"}'` returns `{"received":true,"cache_invalidated":0}`.

---

### Step 8: GitHub Actions CI/CD

**Goal:** Run dbt tests and retrain the attribution model on every push to main; fail the build if data quality tests fail.

```yaml
# .github/workflows/attribution-ci.yml
name: Attribution CI

on:
  push:
    branches: [main]
  schedule:
    - cron: "0 5 * * *"   # daily at 05:00 UTC — retrain on fresh data

jobs:
  dbt-test-and-train:
    runs-on: ubuntu-latest
    env:
      SNOWFLAKE_ACCOUNT:  ${{ secrets.SNOWFLAKE_ACCOUNT }}
      SNOWFLAKE_USER:     ${{ secrets.SNOWFLAKE_USER }}
      SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PASSWORD }}
      GA_PROPERTY_ID:     ${{ secrets.GA_PROPERTY_ID }}

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install dependencies
        run: pip install dbt-snowflake pandas google-analytics-data snowflake-connector-python

      - name: Run GA ingestion
        run: python src/ga_ingest.py

      - name: dbt run + test
        run: |
          dbt deps
          dbt run --target prod
          dbt test --target prod

      - name: Retrain attribution model
        run: python src/train_attribution.py

      - name: Upload model artifact
        uses: actions/upload-artifact@v4
        with:
          name: attribution-model
          path: models/attribution_weights.json
```

**Verify:** After pushing to main, the Actions tab shows a green build with dbt test results in the logs.

---

### Step 9: Looker attribution dashboard

**Goal:** Give the marketing team a self-serve dashboard showing channel ROI, conversion paths, and Shapley vs. last-click comparison.

Create a LookML model connecting to Snowflake:

```lookml
# models/attribution.model.lkml
connection: "snowflake_marketing"
include: "/views/*.view.lkml"

explore: mart_attribution {
  label: "Channel Attribution"
}
```

```lookml
# views/mart_attribution.view.lkml
view: mart_attribution {
  sql_table_name: MARKETING.MART.MART_ATTRIBUTION ;;

  dimension: channel {
    type: string
    sql: ${TABLE}.channel ;;
  }
  dimension_group: event {
    type: time
    timeframes: [date, week, month]
    sql: ${TABLE}.event_date ;;
  }
  measure: total_revenue {
    type: sum
    sql: ${TABLE}.revenue ;;
    value_format_name: usd
  }
  measure: total_conversions {
    type: sum
    sql: ${TABLE}.conversions ;;
  }
  measure: revenue_per_conversion {
    type: number
    sql: ${total_revenue} / NULLIF(${total_conversions}, 0) ;;
    value_format_name: usd
  }
  measure: last_click_share {
    type: average
    sql: ${TABLE}.last_click_share ;;
    value_format: "0.0%"
  }
}
```

Create a dashboard tile showing `total_revenue` by `channel` as a horizontal bar chart, pivoted by `event.month`.

**Verify:** The Looker dashboard renders without SQL errors; `total_revenue` across all channels matches the Snowflake source.

---

### Step 10: Observability and cost controls

**Goal:** Track Snowflake credit consumption and Flask API latency; alert when attribution queries exceed budget.

```python
# src/monitoring.py
import os
import snowflake.connector
from prometheus_client import Gauge

SNOWFLAKE_CREDITS = Gauge("snowflake_credits_used_today",
                          "Snowflake compute credits consumed today")

def update_credit_gauge() -> None:
    conn = snowflake.connector.connect(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        password=os.environ["SNOWFLAKE_PASSWORD"],
        database="SNOWFLAKE",
        schema="ACCOUNT_USAGE",
        warehouse="COMPUTE_WH",
    )
    cursor = conn.cursor()
    cursor.execute("""
        SELECT SUM(credits_used)
        FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
        WHERE START_TIME >= CURRENT_DATE
    """)
    credits = cursor.fetchone()[0] or 0.0
    SNOWFLAKE_CREDITS.set(credits)
    conn.close()
```

Add a Grafana alert: fire if `snowflake_credits_used_today > 5` (approximately $15 at standard pricing).

**Verify:** After running a dbt run, `snowflake_credits_used_today` in Prometheus shows a non-zero value.

---

### Step 11: End-to-end integration test

**Goal:** Verify the pipeline from GA ingestion through Shapley attribution to API response.

```python
# tests/test_attribution_e2e.py
import pytest
from src.attribution import shapley_attribution

def test_single_channel_gets_full_credit():
    result = shapley_attribution([["paid_search"]], [200.0])
    assert abs(result["paid_search"] - 200.0) < 0.01

def test_two_channels_sum_to_total():
    result = shapley_attribution([["paid_search", "email"]], [100.0])
    total  = sum(result.values())
    assert abs(total - 100.0) < 0.01

def test_equal_contribution_equal_credit():
    # Two channels with identical marginal contributions should share equally
    result = shapley_attribution(
        [["social", "email"], ["email", "social"]],
        [100.0, 100.0],
    )
    assert abs(result["social"] - result["email"]) < 1.0   # within $1

def test_api_returns_200(client):
    resp = client.get("/api/v1/attribution?start_date=2024-01-01&end_date=2024-01-07")
    assert resp.status_code == 200
    assert "data" in resp.get_json()
```

```bash
pytest tests/ -v --tb=short
```

---

## Testing

```bash
# Unit tests (no Snowflake connection required)
pytest tests/unit/ -v

# Integration tests (requires Snowflake and Redis)
pytest tests/integration/ -v

# dbt data quality tests
dbt test --target dev

# Load test the Flask API
k6 run tests/load_attribution.js
```

Key test scenarios:
- Shapley values for N channels always sum to total conversion value
- Redis cache returns results within 5 ms on second request
- dbt `not_null` test catches missing `channel` values in GA data
- GitHub Actions pipeline fails if dbt test detects negative conversion counts

---

## Deployment

```bash
# Build and push Docker image for Flask API
docker build -t attribution-api:latest .
docker run -p 5002:5002 \
  -e SNOWFLAKE_ACCOUNT=... \
  -e SNOWFLAKE_USER=... \
  -e SNOWFLAKE_PASSWORD=... \
  -e REDIS_URL=redis://redis:6379 \
  attribution-api:latest

# dbt production run (scheduled in GitHub Actions)
dbt run --target prod
dbt test --target prod
```

Cost controls:
- Set Snowflake warehouse to `AUTO_SUSPEND = 60` (seconds) to stop charging when idle
- Use `X-SMALL` warehouse for development; upgrade to `SMALL` only for production full-refresh
- Cache all Flask API responses in Redis with a 1-hour TTL to avoid redundant warehouse hits

---

## Resources

1. [Shapley values in marketing attribution](https://www.datascience.com/blog/multi-touch-attribution) — conceptual introduction to cooperative game theory attribution
2. [dbt Snowflake quickstart](https://docs.getdbt.com/guides/snowflake) — official guide to connecting dbt to Snowflake
3. [Google Analytics Data API v1](https://developers.google.com/analytics/devguides/reporting/data/v1) — GA4 session and conversion metrics reference
4. [Looker LookML basics](https://cloud.google.com/looker/docs/lookml-terms-and-concepts) — views, explores, and measures
5. [Snowflake cost management](https://docs.snowflake.com/en/user-guide/cost-understanding-compute) — warehouse sizing and credit consumption
6. [scipy.stats.ttest_ind](https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.ttest_ind.html) — two-sample t-test for A/B comparison
