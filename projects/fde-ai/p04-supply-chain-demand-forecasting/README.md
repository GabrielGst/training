# P04 — Supply Chain Demand Forecasting

**Domain:** Supply Chain / Operations  **Track:** `fde-ai`  **Status:** not started  **Hours target:** 40

## Business Problem

Inventory teams lose millions annually to the twin failures of stockouts and overstock. Regional managers produce demand estimates manually from spreadsheets, ignoring external signals such as weather events, promotions, and supply disruptions. This project builds an AI-powered forecasting system that combines historical sales data with external regressors to produce weekly SKU-level demand forecasts with calibrated confidence intervals, enabling proactive replenishment decisions 8 weeks ahead of lead time.

## What you will build

- A **Prophet + LSTM hybrid forecasting engine** that ingests historical sales, weather data, and calendar events to produce weekly SKU-level forecasts with upper/lower confidence bounds
- An **Apache Airflow DAG** that retrains models weekly, validates forecast accuracy against holdout data, and writes results to PostgreSQL
- A **dbt mart** (`mart_forecast_vs_actuals`) that joins forecast output with actuals, computes MAPE and bias, and surfaces them for BI
- A **Flask REST API** (`/forecast/<sku_id>`) that returns the 8-week forecast JSON for integration with ERP and procurement systems
- A **Looker dashboard** with inventory health metrics: fill rate, overstock ratio, and forecast accuracy over time
- A **GitHub Actions CI pipeline** that runs unit tests and model validation checks on every pull request

## Architecture

```
External Signals                 Historical Sales
(weather API, calendar)          (Postgres: sales_daily)
        |                                |
        +-----------> Feature Builder <--+
                             |
                    [Airflow DAG - weekly]
                             |
               +-------------+-------------+
               |                           |
          Prophet Model              LSTM Model
          (seasonality +             (PyTorch sequence
           regressors)                model, 52-week
               |                      lookback)
               |                           |
               +---------> Ensemble <------+
                          (weighted avg)
                               |
                     Postgres: forecasts table
                               |
               +---------------+---------------+
               |                               |
          dbt mart                         Flask API
     (forecast_vs_actuals)              GET /forecast/<sku>
               |                               |
          Looker dashboard             ERP / Procurement
          (fill rate, MAPE,            (webhook consumer)
           bias, accuracy)
                               |
                        AWS S3
                  (model artifacts,
                   training datasets)
```

## Skills covered

| Skill ID | Skill Name | What you practice |
|----------|------------|------------------|
| SK03 | Prompt Engineering and System Design | Crafting LLM prompts for anomaly explanation and forecast narrative generation |
| SK06 | Database Schema Design and Query Optimization | Designing `sales_daily`, `forecasts`, `sku_metadata` tables; indexing by SKU and date |
| SK07 | Data Security and Privacy Compliance | Encrypting S3 model artifacts at rest; VPC isolation for database; audit logging access |
| SK13 | Agentic Workflows and Tool Use | Building Airflow DAG with branching: retrain if MAPE > threshold, alert if anomaly detected |
| SK14 | Semantic Search and Vector Store Optimization | Embedding SKU descriptions for similarity-based cold-start forecasting of new products |
| SK15 | Real-time Integration and Event Streaming | Consuming inventory adjustment events via SQS to trigger forecast recalculation |
| SK20 | Cost Optimization and Resource Allocation | Scheduling GPU training on spot instances; using batch inference for weekly reruns |
| SK21 | Time Series Forecasting and Trend Analysis | Prophet seasonal decomposition, LSTM architecture design, ensemble weighting, anomaly detection |

## Tools & dependencies

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| Flask | 3.0.x | REST API serving forecast results | `pip install flask` |
| Prophet | 1.1.x | Time-series forecasting with seasonality and regressors | `pip install prophet` |
| PyTorch | 2.2.x | LSTM sequence model for demand forecasting | `pip install torch` |
| PostgreSQL | 15.x | Primary database for sales history and forecasts | `brew install postgresql@15` |
| dbt-core | 1.7.x | SQL transformation layer for forecast vs actuals mart | `pip install dbt-postgres` |
| Apache Airflow | 2.8.x | Weekly retraining orchestration DAG | `pip install apache-airflow` |
| AWS S3 (boto3) | 1.34.x | Model artifact and dataset storage | `pip install boto3` |
| Looker | cloud | BI dashboard (uses LookML on top of dbt mart) | Looker Cloud account |
| GitHub Actions | cloud | CI/CD: run tests and model validation on PR | `.github/workflows/*.yml` |
| pandas | 2.x | Data wrangling, feature engineering | `pip install pandas` |
| scikit-learn | 1.4.x | Metrics (MAPE, RMSE), preprocessing | `pip install scikit-learn` |

## Prerequisites

**Track modules to complete first:**

- [ ] `ai-engineer/05-pytorch` — understand LSTM architecture, training loops, and sequence modeling before building the demand forecasting neural network
- [ ] `ai-engineer/10-time-series-forecasting` — covers Prophet, seasonal decomposition, and evaluation metrics (MAPE, RMSE, bias) used directly in this project
- [ ] `data-engineer/04-data-pipelines-airflow` — Airflow DAG structure, sensors, operators, and branching logic used for the weekly retraining pipeline
- [ ] `data-engineer/05-dbt-transformations` — dbt models, sources, tests, and mart patterns used for the forecast vs actuals layer

**Accounts / API keys needed:**

- [ ] AWS account — S3 bucket for model artifacts and raw data CSVs; IAM role for GitHub Actions deployment
- [ ] Open-Meteo API (free) — historical and forecast weather data as external regressor
- [ ] Looker Cloud — BI dashboarding (or substitute with Metabase if cost-constrained)
- [ ] PostgreSQL (local Docker or RDS) — primary data store

---

## Step-by-step tutorial

### Step 1: Environment setup

**Goal:** Create a reproducible Python environment and initialize the project database.

**Install dependencies:**

```bash
python -m venv .venv && source .venv/bin/activate
pip install flask prophet torch pandas scikit-learn boto3 dbt-postgres apache-airflow psycopg2-binary python-dotenv
cp .env.example .env
```

**Start PostgreSQL with Docker:**

```yaml
# docker-compose.yml
version: "3.9"
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: supply_chain
      POSTGRES_USER: scuser
      POSTGRES_PASSWORD: scpassword
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

```bash
docker compose up -d postgres
```

**File structure to create:**

```
p04-supply-chain-demand-forecasting/
├── src/
│   ├── api/
│   │   └── app.py
│   ├── models/
│   │   ├── prophet_model.py
│   │   └── lstm_model.py
│   ├── pipelines/
│   │   └── feature_builder.py
│   └── airflow_dags/
│       └── weekly_retrain_dag.py
├── dbt/
│   ├── models/
│   │   └── mart/
│   │       └── mart_forecast_vs_actuals.sql
│   └── dbt_project.yml
├── tests/
├── docker-compose.yml
└── .env
```

**Verify:**

```bash
docker compose ps
# Expected: postgres is Up on 0.0.0.0:5432
psql postgresql://scuser:scpassword@localhost:5432/supply_chain -c "SELECT version();"
```

---

### Step 2: Database schema design

**Goal:** Create normalized tables for sales history, SKU metadata, external signals, and forecast output.

**Create schema (`src/db/schema.sql`):**

```sql
-- Raw sales transactions, partitioned by week
CREATE TABLE sales_daily (
    id          BIGSERIAL PRIMARY KEY,
    sku_id      VARCHAR(32)    NOT NULL,
    region      VARCHAR(64)    NOT NULL,
    sale_date   DATE           NOT NULL,
    units_sold  INTEGER        NOT NULL CHECK (units_sold >= 0),
    revenue     NUMERIC(12, 2) NOT NULL,
    created_at  TIMESTAMPTZ    DEFAULT NOW()
);

CREATE INDEX idx_sales_sku_date ON sales_daily (sku_id, sale_date DESC);

-- SKU catalogue
CREATE TABLE sku_metadata (
    sku_id       VARCHAR(32) PRIMARY KEY,
    sku_name     VARCHAR(256) NOT NULL,
    category     VARCHAR(64),
    supplier_id  VARCHAR(32),
    lead_time_weeks INTEGER DEFAULT 8,
    unit_cost    NUMERIC(10, 2),
    created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- External signal snapshots (weather, events)
CREATE TABLE external_signals (
    id           BIGSERIAL PRIMARY KEY,
    signal_date  DATE        NOT NULL,
    region       VARCHAR(64) NOT NULL,
    temperature_avg NUMERIC(5,2),
    precipitation_mm NUMERIC(6,2),
    is_holiday   BOOLEAN     DEFAULT FALSE,
    event_label  VARCHAR(128),
    created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- Forecast output
CREATE TABLE forecasts (
    id              BIGSERIAL PRIMARY KEY,
    sku_id          VARCHAR(32)  NOT NULL REFERENCES sku_metadata(sku_id),
    forecast_date   DATE         NOT NULL,
    horizon_week    INTEGER      NOT NULL CHECK (horizon_week BETWEEN 1 AND 8),
    model_type      VARCHAR(32)  NOT NULL, -- 'prophet', 'lstm', 'ensemble'
    units_forecast  NUMERIC(10,2) NOT NULL,
    lower_bound     NUMERIC(10,2),
    upper_bound     NUMERIC(10,2),
    run_id          VARCHAR(64)  NOT NULL, -- Airflow run_id for traceability
    created_at      TIMESTAMPTZ  DEFAULT NOW(),
    UNIQUE (sku_id, forecast_date, horizon_week, model_type, run_id)
);

CREATE INDEX idx_forecasts_sku_date ON forecasts (sku_id, forecast_date DESC);
```

```bash
psql postgresql://scuser:scpassword@localhost:5432/supply_chain -f src/db/schema.sql
```

**Verify:**

```bash
psql postgresql://scuser:scpassword@localhost:5432/supply_chain \
  -c "\dt" 
# Expected: sales_daily, sku_metadata, external_signals, forecasts
```

---

### Step 3: Data ingestion and feature engineering

**Goal:** Load synthetic sales history and build the feature matrix used for training.

**Create `src/pipelines/feature_builder.py`:**

```python
import pandas as pd
import numpy as np
import psycopg2
from datetime import date, timedelta
from typing import Optional
import os

DB_URL = os.getenv("DATABASE_URL", "postgresql://scuser:scpassword@localhost:5432/supply_chain")

def load_sales_history(sku_id: str, lookback_weeks: int = 104) -> pd.DataFrame:
    """Load weekly aggregated sales for a SKU from the database."""
    query = """
        SELECT
            DATE_TRUNC('week', sale_date)::DATE AS week_start,
            SUM(units_sold)                     AS units_sold
        FROM sales_daily
        WHERE sku_id = %s
          AND sale_date >= CURRENT_DATE - INTERVAL '%s weeks'
        GROUP BY 1
        ORDER BY 1
    """
    conn = psycopg2.connect(DB_URL)
    df = pd.read_sql(query, conn, params=(sku_id, lookback_weeks))
    conn.close()
    return df

def fetch_external_signals(region: str, start_date: date, end_date: date) -> pd.DataFrame:
    """Fetch weather and event signals for a region and date range."""
    query = """
        SELECT
            DATE_TRUNC('week', signal_date)::DATE AS week_start,
            AVG(temperature_avg)                   AS avg_temp,
            SUM(precipitation_mm)                  AS total_precip,
            BOOL_OR(is_holiday)                    AS has_holiday
        FROM external_signals
        WHERE region = %s
          AND signal_date BETWEEN %s AND %s
        GROUP BY 1
        ORDER BY 1
    """
    conn = psycopg2.connect(DB_URL)
    df = pd.read_sql(query, conn, params=(region, start_date, end_date))
    conn.close()
    return df

def build_feature_matrix(sku_id: str, region: str) -> pd.DataFrame:
    """Join sales history with external signals; add lag and rolling features."""
    sales = load_sales_history(sku_id)
    start = sales["week_start"].min()
    end   = sales["week_start"].max()
    signals = fetch_external_signals(region, start, end)

    df = sales.merge(signals, on="week_start", how="left")
    df = df.sort_values("week_start").reset_index(drop=True)

    # Lag features
    for lag in [1, 2, 4, 8]:
        df[f"lag_{lag}w"] = df["units_sold"].shift(lag)

    # Rolling features
    df["rolling_4w_mean"] = df["units_sold"].rolling(4).mean()
    df["rolling_4w_std"]  = df["units_sold"].rolling(4).std()

    # Calendar features
    df["week_of_year"] = pd.to_datetime(df["week_start"]).dt.isocalendar().week.astype(int)
    df["month"]        = pd.to_datetime(df["week_start"]).dt.month

    return df.dropna()
```

**Seed synthetic data (for development):**

```python
# scripts/seed_data.py
import pandas as pd
import numpy as np
import psycopg2
from datetime import date, timedelta

conn = psycopg2.connect("postgresql://scuser:scpassword@localhost:5432/supply_chain")
cur = conn.cursor()

# Insert a test SKU
cur.execute("""
    INSERT INTO sku_metadata (sku_id, sku_name, category, lead_time_weeks, unit_cost)
    VALUES ('SKU-001', 'Widget Alpha', 'Electronics', 8, 24.99)
    ON CONFLICT DO NOTHING
""")

# Generate 2 years of daily sales with seasonality
np.random.seed(42)
start = date(2022, 1, 3)
for i in range(730):
    d = start + timedelta(days=i)
    week_of_year = d.isocalendar()[1]
    seasonal = 1 + 0.4 * np.sin(2 * np.pi * week_of_year / 52)
    units = max(0, int(np.random.poisson(50 * seasonal)))
    cur.execute("""
        INSERT INTO sales_daily (sku_id, region, sale_date, units_sold, revenue)
        VALUES (%s, 'US-WEST', %s, %s, %s)
    """, ('SKU-001', d, units, units * 24.99))

conn.commit()
cur.close()
conn.close()
print("Seed complete.")
```

```bash
python scripts/seed_data.py
```

**Verify:**

```bash
psql postgresql://scuser:scpassword@localhost:5432/supply_chain \
  -c "SELECT COUNT(*), MIN(sale_date), MAX(sale_date) FROM sales_daily;"
# Expected: 730 rows spanning 2022-01-03 to 2023-12-31
```

---

### Step 4: Prophet forecasting model

**Goal:** Train a Prophet model per SKU with external regressors and produce an 8-week forecast.

**Create `src/models/prophet_model.py`:**

```python
import pandas as pd
import numpy as np
from prophet import Prophet
from typing import Tuple
import logging

logger = logging.getLogger(__name__)

def train_prophet(df: pd.DataFrame) -> Tuple[Prophet, dict]:
    """
    Train a Prophet model on weekly sales data with external regressors.

    df must contain: week_start, units_sold, avg_temp, total_precip, has_holiday
    Returns: (fitted model, metrics dict)
    """
    # Prophet expects 'ds' (datestamp) and 'y' (target)
    prophet_df = df.rename(columns={"week_start": "ds", "units_sold": "y"})
    prophet_df["ds"] = pd.to_datetime(prophet_df["ds"])

    model = Prophet(
        yearly_seasonality=True,
        weekly_seasonality=False,
        daily_seasonality=False,
        changepoint_prior_scale=0.05,
        seasonality_prior_scale=10.0,
        interval_width=0.95,
    )

    # Add external regressors
    for col in ["avg_temp", "total_precip", "has_holiday"]:
        if col in prophet_df.columns:
            prophet_df[col] = prophet_df[col].fillna(0).astype(float)
            model.add_regressor(col)

    # Train on 80% of data, validate on 20%
    split_idx = int(len(prophet_df) * 0.8)
    train_df  = prophet_df.iloc[:split_idx]
    val_df    = prophet_df.iloc[split_idx:]

    model.fit(train_df)

    # Evaluate on validation set
    val_forecast = model.predict(val_df[["ds", "avg_temp", "total_precip", "has_holiday"]])
    mape = float(np.mean(np.abs(
        (val_df["y"].values - val_forecast["yhat"].values) / (val_df["y"].values + 1e-8)
    )))
    logger.info("Prophet validation MAPE: %.4f", mape)

    return model, {"mape": mape, "val_rows": len(val_df)}


def forecast_prophet(model: Prophet, regressors_future: pd.DataFrame) -> pd.DataFrame:
    """
    Produce an 8-week ahead forecast.

    regressors_future: DataFrame with columns [ds, avg_temp, total_precip, has_holiday]
    Returns DataFrame with [ds, yhat, yhat_lower, yhat_upper]
    """
    forecast = model.predict(regressors_future)
    return forecast[["ds", "yhat", "yhat_lower", "yhat_upper"]].rename(
        columns={"yhat": "units_forecast", "yhat_lower": "lower_bound", "yhat_upper": "upper_bound"}
    )
```

**Verify (interactive test):**

```bash
python - <<'EOF'
from src.pipelines.feature_builder import build_feature_matrix
from src.models.prophet_model import train_prophet, forecast_prophet
import pandas as pd
from datetime import date, timedelta

df = build_feature_matrix("SKU-001", "US-WEST")
model, metrics = train_prophet(df)
print("MAPE:", metrics["mape"])

# Build an 8-week future frame (use mean regressor values as placeholder)
last_date = pd.to_datetime(df["week_start"].max())
future_dates = [last_date + pd.Timedelta(weeks=i) for i in range(1, 9)]
future_df = pd.DataFrame({
    "ds": future_dates,
    "avg_temp": [df["avg_temp"].mean()] * 8,
    "total_precip": [df["total_precip"].mean()] * 8,
    "has_holiday": [0.0] * 8,
})
result = forecast_prophet(model, future_df)
print(result)
EOF
# Expected: MAPE < 0.20, 8 rows with units_forecast, lower_bound, upper_bound
```

---

### Step 5: LSTM forecasting model

**Goal:** Build a PyTorch LSTM that learns temporal patterns from a 52-week sliding window.

**Create `src/models/lstm_model.py`:**

```python
import torch
import torch.nn as nn
import numpy as np
import pandas as pd
from torch.utils.data import Dataset, DataLoader
from sklearn.preprocessing import MinMaxScaler
from typing import Tuple

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
LOOKBACK = 52  # weeks
HORIZON  = 8   # weeks ahead


class DemandDataset(Dataset):
    def __init__(self, series: np.ndarray, lookback: int = LOOKBACK, horizon: int = HORIZON):
        self.X, self.y = [], []
        for i in range(len(series) - lookback - horizon + 1):
            self.X.append(series[i : i + lookback])
            self.y.append(series[i + lookback : i + lookback + horizon])
        self.X = torch.FloatTensor(np.array(self.X)).unsqueeze(-1)  # (N, T, 1)
        self.y = torch.FloatTensor(np.array(self.y))                 # (N, H)

    def __len__(self):  return len(self.X)
    def __getitem__(self, i): return self.X[i], self.y[i]


class DemandLSTM(nn.Module):
    def __init__(self, input_size: int = 1, hidden_size: int = 64,
                 num_layers: int = 2, horizon: int = HORIZON):
        super().__init__()
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers,
                            batch_first=True, dropout=0.2)
        self.fc   = nn.Linear(hidden_size, horizon)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        out, _ = self.lstm(x)
        return self.fc(out[:, -1, :])  # Use last timestep


def train_lstm(df: pd.DataFrame, epochs: int = 30) -> Tuple[DemandLSTM, MinMaxScaler, dict]:
    """Train LSTM on weekly units_sold series. Returns model, scaler, and metrics."""
    series = df["units_sold"].values.astype(float).reshape(-1, 1)
    scaler = MinMaxScaler()
    series_scaled = scaler.fit_transform(series).flatten()

    split = int(len(series_scaled) * 0.8)
    train_ds = DemandDataset(series_scaled[:split])
    val_ds   = DemandDataset(series_scaled[split:])

    train_loader = DataLoader(train_ds, batch_size=16, shuffle=True)
    val_loader   = DataLoader(val_ds,   batch_size=16, shuffle=False)

    model     = DemandLSTM().to(DEVICE)
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
    criterion = nn.MSELoss()

    for epoch in range(epochs):
        model.train()
        for X_batch, y_batch in train_loader:
            X_batch, y_batch = X_batch.to(DEVICE), y_batch.to(DEVICE)
            optimizer.zero_grad()
            loss = criterion(model(X_batch), y_batch)
            loss.backward()
            optimizer.step()

    # Validation MAPE
    model.eval()
    preds, actuals = [], []
    with torch.no_grad():
        for X_batch, y_batch in val_loader:
            p = model(X_batch.to(DEVICE)).cpu().numpy()
            preds.append(p); actuals.append(y_batch.numpy())

    preds   = scaler.inverse_transform(np.vstack(preds))
    actuals = scaler.inverse_transform(np.vstack(actuals))
    mape    = float(np.mean(np.abs((actuals - preds) / (actuals + 1e-8))))

    return model, scaler, {"mape": mape}


def forecast_lstm(model: DemandLSTM, scaler: MinMaxScaler,
                  history: np.ndarray) -> np.ndarray:
    """Return 8-week forecast using last LOOKBACK weeks of history."""
    window = history[-LOOKBACK:].reshape(-1, 1)
    window_scaled = scaler.transform(window).flatten()
    x = torch.FloatTensor(window_scaled).unsqueeze(0).unsqueeze(-1).to(DEVICE)
    model.eval()
    with torch.no_grad():
        pred_scaled = model(x).cpu().numpy()
    return scaler.inverse_transform(pred_scaled).flatten()
```

**Verify:**

```bash
python - <<'EOF'
from src.pipelines.feature_builder import build_feature_matrix
from src.models.lstm_model import train_lstm, forecast_lstm
import numpy as np

df = build_feature_matrix("SKU-001", "US-WEST")
model, scaler, metrics = train_lstm(df, epochs=20)
print("LSTM MAPE:", metrics["mape"])

forecast = forecast_lstm(model, scaler, df["units_sold"].values)
print("8-week forecast:", np.round(forecast, 1))
EOF
# Expected: MAPE < 0.30, array of 8 positive floats
```

---

### Step 6: Ensemble and forecast writer

**Goal:** Combine Prophet and LSTM forecasts with weighted averaging; persist results to PostgreSQL.

**Create `src/models/ensemble.py`:**

```python
import numpy as np
import pandas as pd
import psycopg2
import os
from datetime import date
from typing import List

DB_URL = os.getenv("DATABASE_URL", "postgresql://scuser:scpassword@localhost:5432/supply_chain")


def ensemble_forecasts(prophet_yhat: np.ndarray, lstm_yhat: np.ndarray,
                       prophet_weight: float = 0.6) -> np.ndarray:
    """Weighted average of Prophet and LSTM forecasts."""
    lstm_weight = 1.0 - prophet_weight
    return prophet_weight * prophet_yhat + lstm_weight * lstm_yhat


def write_forecasts(sku_id: str, run_id: str,
                    forecast_date: date, forecasts: np.ndarray,
                    lower: np.ndarray, upper: np.ndarray,
                    model_type: str = "ensemble") -> None:
    """Persist forecast rows to the forecasts table."""
    conn = psycopg2.connect(DB_URL)
    cur  = conn.cursor()
    for week_i, (yhat, lo, hi) in enumerate(zip(forecasts, lower, upper), start=1):
        cur.execute("""
            INSERT INTO forecasts
                (sku_id, forecast_date, horizon_week, model_type, units_forecast,
                 lower_bound, upper_bound, run_id)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (sku_id, forecast_date, horizon_week, model_type, run_id)
            DO UPDATE SET units_forecast = EXCLUDED.units_forecast,
                          lower_bound    = EXCLUDED.lower_bound,
                          upper_bound    = EXCLUDED.upper_bound
        """, (sku_id, forecast_date, week_i, model_type,
              float(yhat), float(lo), float(hi), run_id))
    conn.commit()
    cur.close()
    conn.close()
```

**Verify:**

```bash
psql postgresql://scuser:scpassword@localhost:5432/supply_chain \
  -c "SELECT horizon_week, units_forecast, lower_bound, upper_bound FROM forecasts WHERE sku_id='SKU-001' ORDER BY horizon_week;"
# Expected: 8 rows after running the pipeline script
```

---

### Step 7: Airflow retraining DAG

**Goal:** Schedule weekly automated retraining and forecast generation with branching on MAPE threshold.

**Create `src/airflow_dags/weekly_retrain_dag.py`:**

```python
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator, BranchPythonOperator
from airflow.operators.empty import EmptyOperator
import logging

MAPE_THRESHOLD = 0.15  # Trigger alert if MAPE exceeds this value
SKU_LIST = ["SKU-001"]  # Extend for all active SKUs


def retrain_and_forecast(sku_id: str, **context) -> dict:
    """Retrain Prophet + LSTM models and write 8-week forecasts to DB."""
    from src.pipelines.feature_builder import build_feature_matrix
    from src.models.prophet_model import train_prophet, forecast_prophet
    from src.models.lstm_model import train_lstm, forecast_lstm
    from src.models.ensemble import ensemble_forecasts, write_forecasts
    import numpy as np, pandas as pd
    from datetime import date

    df = build_feature_matrix(sku_id, "US-WEST")

    prophet_model, p_metrics = train_prophet(df)
    lstm_model, scaler, l_metrics = train_lstm(df)

    last_date = pd.to_datetime(df["week_start"].max())
    future_dates = [last_date + pd.Timedelta(weeks=i) for i in range(1, 9)]
    future_df = pd.DataFrame({
        "ds": future_dates,
        "avg_temp": [df["avg_temp"].mean()] * 8,
        "total_precip": [df["total_precip"].mean()] * 8,
        "has_holiday": [0.0] * 8,
    })

    p_forecast = forecast_prophet(prophet_model, future_df)
    l_yhat     = forecast_lstm(lstm_model, scaler, df["units_sold"].values)
    ensemble   = ensemble_forecasts(p_forecast["units_forecast"].values, l_yhat)

    # Use Prophet confidence intervals scaled to ensemble
    scale = ensemble / (p_forecast["units_forecast"].values + 1e-8)
    lower = p_forecast["lower_bound"].values * scale
    upper = p_forecast["upper_bound"].values * scale

    run_id = context["run_id"]
    write_forecasts(sku_id, run_id, date.today(), ensemble, lower, upper)

    mape = (p_metrics["mape"] + l_metrics["mape"]) / 2
    context["task_instance"].xcom_push(key=f"mape_{sku_id}", value=mape)
    logging.info("Completed forecast for %s. MAPE=%.4f", sku_id, mape)
    return {"sku_id": sku_id, "mape": mape}


def check_mape(**context) -> str:
    """Branch: alert if any SKU MAPE exceeds threshold."""
    ti = context["task_instance"]
    mapes = [ti.xcom_pull(task_ids=f"retrain_{sku}", key=f"mape_{sku}") for sku in SKU_LIST]
    if any(m and m > MAPE_THRESHOLD for m in mapes):
        return "alert_high_mape"
    return "forecast_done"


default_args = {
    "owner": "data-team",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="weekly_demand_forecast",
    start_date=datetime(2024, 1, 1),
    schedule_interval="0 6 * * MON",  # Every Monday at 06:00 UTC
    catchup=False,
    default_args=default_args,
    tags=["supply-chain", "forecasting"],
) as dag:

    retrain_tasks = [
        PythonOperator(
            task_id=f"retrain_{sku}",
            python_callable=retrain_and_forecast,
            op_kwargs={"sku_id": sku},
        )
        for sku in SKU_LIST
    ]

    branch = BranchPythonOperator(
        task_id="check_mape_threshold",
        python_callable=check_mape,
    )

    alert = PythonOperator(
        task_id="alert_high_mape",
        python_callable=lambda: logging.warning("MAPE exceeded threshold — manual review required"),
    )

    done = EmptyOperator(task_id="forecast_done")

    retrain_tasks >> branch >> [alert, done]
```

**Verify:**

```bash
export AIRFLOW_HOME=$(pwd)/airflow_home
airflow db migrate
airflow dags list
# Expected: weekly_demand_forecast appears in list
airflow dags test weekly_demand_forecast 2024-01-08
```

---

### Step 8: dbt mart for forecast vs actuals

**Goal:** Build a dbt model that joins forecast output with actuals and computes accuracy metrics.

**Create `dbt/dbt_project.yml`:**

```yaml
name: supply_chain
version: "1.0.0"
profile: supply_chain

models:
  supply_chain:
    mart:
      +materialized: table
      +schema: mart
```

**Create `dbt/profiles.yml` (in `~/.dbt/`):**

```yaml
supply_chain:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: scuser
      pass: scpassword
      dbname: supply_chain
      schema: public
      threads: 4
```

**Create `dbt/models/mart/mart_forecast_vs_actuals.sql`:**

```sql
-- mart_forecast_vs_actuals.sql
-- Joins ensemble forecasts against realized weekly sales to compute accuracy metrics.

WITH weekly_actuals AS (
    SELECT
        sku_id,
        DATE_TRUNC('week', sale_date)::DATE AS week_start,
        SUM(units_sold)                      AS actual_units
    FROM {{ source('public', 'sales_daily') }}
    GROUP BY 1, 2
),

latest_forecasts AS (
    SELECT DISTINCT ON (sku_id, forecast_date, horizon_week)
        sku_id,
        forecast_date,
        horizon_week,
        units_forecast,
        lower_bound,
        upper_bound,
        run_id
    FROM {{ source('public', 'forecasts') }}
    WHERE model_type = 'ensemble'
    ORDER BY sku_id, forecast_date, horizon_week, created_at DESC
)

SELECT
    f.sku_id,
    f.forecast_date,
    f.horizon_week,
    f.units_forecast,
    f.lower_bound,
    f.upper_bound,
    a.actual_units,
    CASE
        WHEN a.actual_units IS NOT NULL AND a.actual_units > 0
        THEN ABS(a.actual_units - f.units_forecast) / a.actual_units
        ELSE NULL
    END AS ape,   -- absolute percentage error
    CASE
        WHEN f.units_forecast BETWEEN f.lower_bound AND f.upper_bound THEN true
        ELSE false
    END AS in_confidence_interval,
    f.run_id
FROM latest_forecasts f
LEFT JOIN weekly_actuals a
    ON f.sku_id = a.sku_id
   AND a.week_start = f.forecast_date + (f.horizon_week - 1 * INTERVAL '1 week')
```

```bash
cd dbt && dbt run && dbt test
```

**Verify:**

```bash
psql postgresql://scuser:scpassword@localhost:5432/supply_chain \
  -c "SELECT COUNT(*), AVG(ape) FROM mart.mart_forecast_vs_actuals WHERE ape IS NOT NULL;"
```

---

### Step 9: Flask REST API

**Goal:** Expose the latest 8-week forecast for a given SKU via a REST endpoint.

**Create `src/api/app.py`:**

```python
import os
import psycopg2
import psycopg2.extras
from flask import Flask, jsonify, abort
from functools import lru_cache

app = Flask(__name__)
DB_URL = os.getenv("DATABASE_URL", "postgresql://scuser:scpassword@localhost:5432/supply_chain")


def get_db():
    return psycopg2.connect(DB_URL, cursor_factory=psycopg2.extras.RealDictCursor)


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"})


@app.route("/forecast/<sku_id>", methods=["GET"])
def get_forecast(sku_id: str):
    """Return the latest 8-week ensemble forecast for a SKU."""
    conn = get_db()
    cur  = conn.cursor()
    cur.execute("""
        SELECT
            f.horizon_week,
            f.forecast_date,
            f.units_forecast,
            f.lower_bound,
            f.upper_bound,
            f.run_id,
            f.created_at
        FROM forecasts f
        WHERE f.sku_id = %s
          AND f.model_type = 'ensemble'
          AND f.run_id = (
              SELECT run_id FROM forecasts
              WHERE sku_id = %s AND model_type = 'ensemble'
              ORDER BY created_at DESC LIMIT 1
          )
        ORDER BY f.horizon_week
    """, (sku_id, sku_id))
    rows = cur.fetchall()
    cur.close()
    conn.close()

    if not rows:
        abort(404, description=f"No forecast found for SKU {sku_id}")

    return jsonify({
        "sku_id": sku_id,
        "forecast": [dict(r) for r in rows],
    })


@app.route("/skus", methods=["GET"])
def list_skus():
    """Return all SKUs with active forecasts."""
    conn = get_db()
    cur  = conn.cursor()
    cur.execute("""
        SELECT DISTINCT s.sku_id, s.sku_name, s.category
        FROM sku_metadata s
        JOIN forecasts f USING (sku_id)
        ORDER BY s.sku_id
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify({"skus": [dict(r) for r in rows]})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
```

**Verify:**

```bash
flask --app src/api/app:app run --port 5000 &
curl -s http://localhost:5000/health | python -m json.tool
# Expected: {"status": "ok"}
curl -s http://localhost:5000/forecast/SKU-001 | python -m json.tool
# Expected: JSON with "forecast" array of 8 objects
```

---

### Step 10: Anomaly detection

**Goal:** Flag SKUs where recent sales deviate significantly from the forecast, and surface anomalies in the API.

**Create `src/models/anomaly_detector.py`:**

```python
import numpy as np
import pandas as pd
from sklearn.ensemble import IsolationForest
from typing import List, Dict


def detect_anomalies(series: np.ndarray, contamination: float = 0.05) -> List[int]:
    """
    Return indices of anomalous weeks using Isolation Forest.
    contamination: expected proportion of anomalies.
    """
    clf = IsolationForest(contamination=contamination, random_state=42)
    labels = clf.fit_predict(series.reshape(-1, 1))
    return [i for i, label in enumerate(labels) if label == -1]


def compute_residuals(actuals: np.ndarray, forecasts: np.ndarray) -> np.ndarray:
    """Compute standardized residuals between actuals and forecasts."""
    residuals = actuals - forecasts
    std = np.std(residuals) + 1e-8
    return residuals / std


def flag_anomalous_weeks(df: pd.DataFrame) -> pd.DataFrame:
    """
    Given a DataFrame with 'units_sold' column, add an 'is_anomaly' boolean column.
    """
    anomaly_indices = detect_anomalies(df["units_sold"].values)
    df = df.copy()
    df["is_anomaly"] = False
    df.loc[anomaly_indices, "is_anomaly"] = True
    return df
```

**Verify:**

```bash
python - <<'EOF'
from src.pipelines.feature_builder import build_feature_matrix
from src.models.anomaly_detector import flag_anomalous_weeks

df = build_feature_matrix("SKU-001", "US-WEST")
df_flagged = flag_anomalous_weeks(df)
anomalies = df_flagged[df_flagged["is_anomaly"]]
print(f"Detected {len(anomalies)} anomalous weeks:")
print(anomalies[["week_start", "units_sold"]].to_string())
EOF
# Expected: small number of flagged outlier weeks
```

---

### Step 11: Observability and CI/CD

**Goal:** Add structured logging, a health check endpoint, and a GitHub Actions CI pipeline.

**Add structured logging to `src/api/app.py`:**

```python
import logging
import time
from flask import request, g

logging.basicConfig(
    level=logging.INFO,
    format='{"time":"%(asctime)s","level":"%(levelname)s","msg":"%(message)s"}'
)

@app.before_request
def start_timer():
    g.start = time.time()

@app.after_request
def log_request(response):
    duration_ms = (time.time() - g.start) * 1000
    app.logger.info(
        "method=%s path=%s status=%d duration_ms=%.1f",
        request.method, request.path, response.status_code, duration_ms
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
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_DB: supply_chain_test
          POSTGRES_USER: scuser
          POSTGRES_PASSWORD: scpassword
        ports: ["5432:5432"]
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"
          cache: pip

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Apply schema
        env:
          DATABASE_URL: postgresql://scuser:scpassword@localhost:5432/supply_chain_test
        run: psql $DATABASE_URL -f src/db/schema.sql

      - name: Run tests
        env:
          DATABASE_URL: postgresql://scuser:scpassword@localhost:5432/supply_chain_test
        run: pytest tests/ -v --tb=short

      - name: Validate model MAPE
        env:
          DATABASE_URL: postgresql://scuser:scpassword@localhost:5432/supply_chain_test
        run: python scripts/validate_model_mape.py
```

**Verify:**

```bash
git push origin main
# Check GitHub Actions tab: all jobs should be green
```

---

## Testing

**Unit tests (`tests/test_models.py`):**

```python
import pytest
import numpy as np
import pandas as pd
from src.models.anomaly_detector import detect_anomalies, compute_residuals
from src.models.ensemble import ensemble_forecasts


def test_detect_anomalies_returns_indices():
    series = np.array([50, 48, 52, 51, 49, 200, 50, 47])  # 200 is an outlier
    anomalies = detect_anomalies(series, contamination=0.1)
    assert 5 in anomalies  # Index of the outlier


def test_ensemble_weighted_average():
    prophet = np.array([100.0, 110.0, 120.0])
    lstm    = np.array([90.0, 100.0, 110.0])
    result  = ensemble_forecasts(prophet, lstm, prophet_weight=0.6)
    expected = np.array([96.0, 106.0, 116.0])
    np.testing.assert_allclose(result, expected, rtol=1e-5)


def test_compute_residuals_mean_zero():
    actuals   = np.array([100.0, 110.0, 90.0])
    forecasts = np.array([105.0, 105.0, 95.0])
    residuals = compute_residuals(actuals, forecasts)
    assert residuals.shape == (3,)


def test_flask_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json["status"] == "ok"


@pytest.fixture
def client():
    from src.api.app import app
    app.config["TESTING"] = True
    with app.test_client() as c:
        yield c
```

```bash
pytest tests/ -v
# Expected: all tests pass
```

---

## Deployment

**Docker build:**

```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/
COPY dbt/ ./dbt/

EXPOSE 5000
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "src.api.app:app"]
```

**Production docker-compose:**

```yaml
# docker-compose.prod.yml
version: "3.9"
services:
  api:
    build: .
    ports: ["5000:5000"]
    environment:
      DATABASE_URL: ${DATABASE_URL}
      AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
      S3_BUCKET: ${S3_BUCKET}
    restart: unless-stopped

  airflow:
    image: apache/airflow:2.8.0-python3.11
    depends_on: [postgres]
    environment:
      AIRFLOW__CORE__EXECUTOR: LocalExecutor
      AIRFLOW__DATABASE__SQL_ALCHEMY_CONN: ${DATABASE_URL}
    volumes:
      - ./src/airflow_dags:/opt/airflow/dags
    command: webserver
```

```bash
docker build -t supply-chain-api .
docker run -p 5000:5000 -e DATABASE_URL=... supply-chain-api
```

---

## Resources

1. [Prophet documentation](https://facebook.github.io/prophet/docs/quick_start.html) — official Prophet quickstart with Python examples
2. [PyTorch LSTM tutorial](https://pytorch.org/tutorials/beginner/nlp/sequence_models_tutorial.html) — sequence model fundamentals used in the LSTM component
3. [Airflow DAG authoring](https://airflow.apache.org/docs/apache-airflow/stable/tutorial/fundamentals.html) — Airflow operator patterns and branching used in the retraining DAG
4. [dbt best practices](https://docs.getdbt.com/guides/best-practices) — staging/mart model conventions and test patterns
5. [Scikit-learn Isolation Forest](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.IsolationForest.html) — anomaly detection API reference
6. [Open-Meteo API](https://open-meteo.com/en/docs) — free weather API used as external regressor (no key required)
