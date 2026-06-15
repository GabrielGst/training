# P08 — Healthcare Patient Outcome Prediction

**Domain:** Healthcare / Clinical Operations  **Track:** `fde-ai`  **Status:** not started  **Hours target:** 45

## Business Problem

Hospital readmissions within 30 days cost $15,000+ per event and represent the single largest avoidable expense in most health systems. Clinicians lack a decision-support tool that surfaces high-risk patients at discharge time, in a format they can act on and trust. This project builds a HIPAA-compliant ML pipeline that ingests HL7 FHIR records, trains an XGBoost readmission classifier, and delivers SHAP-explained risk scores through a FastAPI inference endpoint secured by Auth0.

## What you will build

- A FHIR R4 ingestion pipeline that pulls patient observations, diagnoses, and encounters from an EHR system, normalising them into a flat feature table in PostgreSQL
- An XGBoost binary classifier trained on 30-day readmission labels with SHAP explainability output for every prediction
- A FastAPI inference endpoint protected by Auth0 JWT authentication, returning structured JSON risk scores with feature contribution breakdowns
- A spaCy NLP pipeline extracting clinical entities (medications, diagnoses, procedures) from free-text discharge notes to enrich the feature set
- A Grafana dashboard monitoring model drift, prediction volume, and authentication failures in real time
- A Looker data model surfacing readmission trends by ward, physician, and diagnosis code for clinical leadership

## Architecture

```
EHR System
    |
HL7 FHIR R4 API
    |
FHIR Ingestion (Python)
    |
PostgreSQL  <---- spaCy NLP (discharge notes)
    |
XGBoost Classifier
    |             \
SHAP Explainer   LangChain + Mistral API (clinical summaries)
    |
FastAPI /predict (Auth0 JWT)
    |         \
Looker BI    Grafana + Prometheus
```

## Skills covered

| Skill ID | Skill Name | What you practice |
|----------|------------|------------------|
| SK03 | Prompt Engineering and System Design | Mistral prompts converting SHAP scores into plain-English clinical summaries |
| SK06 | Database Schema Design and Query Optimization | OLTP patient schema plus OLAP mart for Looker; EXPLAIN ANALYZE tuning |
| SK07 | Data Security and Privacy Compliance | PHI encryption at rest (AES-256), TLS in transit, audit log on every prediction |
| SK08 | Observability and Production Debugging | Grafana panels for model drift, request latency, and auth failures |
| SK09 | Cross-functional Stakeholder Engagement | Co-design prediction output format with clinical staff; iterate on SHAP layout |
| SK11 | Structured Output Extraction and Parsing | Pydantic schemas for FHIR payloads; structured LLM output for clinical summaries |
| SK13 | Agentic Workflows and Tool Use | LangChain agent calling the predict endpoint as a tool within a clinical Q&A flow |
| SK17 | Model Evaluation and Ablation Testing | AUC-ROC, precision-recall, threshold calibration, and leave-one-hospital-out CV |
| SK18 | Feedback Loop Design and Active Learning | Clinician confirmation labels fed back into retraining pipeline via Label Studio |
| SK29 | HIPAA and Healthcare Compliance | Auth0 SSO and MFA, PHI audit trails, BAA-compliant cloud configuration |
| SK30 | Voice/Audio Processing and Transcription | Whisper transcription of verbal discharge summaries into the NLP pipeline |

## Tools & dependencies

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| FastAPI | 0.111 | Async inference API with auto OpenAPI docs | `pip install fastapi uvicorn` |
| XGBoost | 2.x | Gradient-boosted readmission classifier | `pip install xgboost` |
| spaCy | 3.7 | Clinical NER on discharge notes | `pip install spacy scispacy` |
| Auth0 | latest | HIPAA-compliant JWT auth and MFA | Auth0 tenant (free tier) |
| HL7 FHIR | R4 | EHR data standard for ingestion | `pip install fhir.resources` |
| Grafana | 10.x | Metrics dashboards and drift alerting | Docker or Grafana Cloud |
| LangChain | 0.2 | Orchestrate Mistral for clinical summaries | `pip install langchain langchain-mistralai` |
| Mistral API | latest | LLM for generating plain-English summaries | API key from console.mistral.ai |
| PostgreSQL | 16 | Primary patient data store | Docker or managed RDS |
| SHAP | 0.45 | Feature importance for every prediction | `pip install shap` |
| Looker | 7.x | BI dashboard for clinical leadership | Looker Studio (free) or Looker |

## Prerequisites

**Track modules to complete first:**
- [ ] `ai-engineer/05-pytorch` — deep learning fundamentals before XGBoost feature engineering
- [ ] `ai-engineer/09-ml-explainability` — SHAP values, LIME, calibration plots
- [ ] `ai-engineer/02-fastapi` — async endpoints, Pydantic validation, dependency injection
- [ ] `data-engineer/01-postgresql` — schema design, query optimisation, connection pooling

**Accounts / API keys needed:**
- [ ] Auth0 — free tenant for JWT and MFA (mark as HIPAA-eligible in production)
- [ ] Mistral API — for LLM summarisation of SHAP output
- [ ] Grafana Cloud — optional; otherwise run Grafana in Docker

---

## Step-by-step tutorial

### Step 1: Environment setup

**Goal:** Spin up PostgreSQL, Grafana, and install all Python dependencies in an isolated environment.

```yaml
# docker-compose.yml
version: "3.9"
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: healthdb
      POSTGRES_USER: health_user
      POSTGRES_PASSWORD: health_secret
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  grafana:
    image: grafana/grafana:10.4.0
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin

  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

volumes:
  pgdata:
```

```bash
docker compose up -d
python -m venv .venv && source .venv/bin/activate
pip install fastapi uvicorn xgboost shap spacy scispacy fhir.resources sqlalchemy \
            psycopg2-binary python-jose[cryptography] httpx langchain \
            langchain-mistralai prometheus-client python-dotenv scikit-learn pandas
python -m spacy download en_core_sci_sm   # SciSpacy clinical model
```

**Verify:** `python -c "import xgboost, shap, spacy; print('OK')"` prints `OK`; `docker compose ps` shows all three containers healthy.

---

### Step 2: Patient database schema

**Goal:** OLTP schema for storing FHIR-sourced patient data and predictions, with a HIPAA-compliant audit log.

```sql
-- migrations/001_schema.sql

CREATE TABLE patients (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fhir_id      TEXT UNIQUE NOT NULL,
    birth_date   DATE,
    gender       TEXT,
    created_at   TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE encounters (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id      UUID REFERENCES patients(id),
    fhir_enc_id     TEXT UNIQUE NOT NULL,
    admission_date  DATE,
    discharge_date  DATE,
    primary_dx      TEXT,     -- ICD-10 code
    ward            TEXT,
    attending_md    TEXT,
    created_at      TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE observations (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    encounter_id  UUID REFERENCES encounters(id),
    loinc_code    TEXT,
    value_num     NUMERIC,
    value_text    TEXT,
    recorded_at   TIMESTAMPTZ
);

-- Prediction store — every inference logged for audit and retraining
CREATE TABLE predictions (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    encounter_id   UUID REFERENCES encounters(id),
    risk_score     NUMERIC(5,4),   -- 0.0-1.0
    risk_label     BOOLEAN,        -- threshold > 0.35
    shap_json      JSONB,
    requested_by   TEXT,           -- Auth0 sub claim
    created_at     TIMESTAMPTZ DEFAULT now()
);

-- HIPAA-required audit trail for all PHI access
CREATE TABLE audit_log (
    id          BIGSERIAL PRIMARY KEY,
    action      TEXT NOT NULL,
    resource    TEXT NOT NULL,
    actor       TEXT NOT NULL,
    ip_addr     INET,
    ts          TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_predictions_encounter ON predictions(encounter_id);
CREATE INDEX idx_observations_enc      ON observations(encounter_id);
CREATE INDEX idx_encounters_patient    ON encounters(patient_id);
CREATE INDEX idx_audit_actor           ON audit_log(actor, ts DESC);
```

```bash
psql -h localhost -U health_user -d healthdb -f migrations/001_schema.sql
```

**Verify:** `\dt` in psql lists 5 tables: patients, encounters, observations, predictions, audit_log.

---

### Step 3: FHIR R4 ingestion pipeline

**Goal:** Pull patient bundles from a FHIR server (using the public HAPI FHIR sandbox for development) and normalise them into PostgreSQL.

```python
# src/fhir_ingest.py
import os, requests
from fhir.resources.bundle import Bundle
import sqlalchemy as sa

FHIR_BASE = os.environ.get("FHIR_BASE_URL", "https://hapi.fhir.org/baseR4")
engine    = sa.create_engine(os.environ["DATABASE_URL"])

def fetch_patient_bundle(patient_fhir_id: str) -> dict:
    """Fetch patient + encounters + observations as a FHIR Bundle."""
    resp = requests.get(
        f"{FHIR_BASE}/Patient/{patient_fhir_id}/$everything",
        headers={"Accept": "application/fhir+json"},
        timeout=30,
    )
    resp.raise_for_status()
    return resp.json()

def upsert_patient(bundle_json: dict) -> str | None:
    bundle = Bundle.parse_obj(bundle_json)
    patient_row = None

    with engine.begin() as conn:
        for entry in bundle.entry or []:
            resource = entry.resource
            if resource.resource_type == "Patient":
                r = conn.execute(
                    sa.text("""
                        INSERT INTO patients (fhir_id, birth_date, gender)
                        VALUES (:fhir_id, :birth_date, :gender)
                        ON CONFLICT (fhir_id) DO UPDATE
                          SET birth_date = EXCLUDED.birth_date
                        RETURNING id
                    """),
                    {
                        "fhir_id":    resource.id,
                        "birth_date": str(resource.birthDate) if resource.birthDate else None,
                        "gender":     resource.gender,
                    },
                )
                patient_row = r.fetchone()[0]

            elif resource.resource_type == "Encounter" and patient_row:
                conn.execute(
                    sa.text("""
                        INSERT INTO encounters
                            (patient_id, fhir_enc_id, admission_date, discharge_date, primary_dx)
                        VALUES (:pid, :fhir_id, :adm, :dis, :dx)
                        ON CONFLICT (fhir_enc_id) DO NOTHING
                    """),
                    {
                        "pid":     patient_row,
                        "fhir_id": resource.id,
                        "adm":     str(resource.period.start.date()) if resource.period else None,
                        "dis":     str(resource.period.end.date())   if resource.period else None,
                        "dx":      (resource.diagnosis[0].condition.display
                                    if resource.diagnosis else None),
                    },
                )
    return str(patient_row)
```

**File structure:**
```
src/
  fhir_ingest.py
  features.py     <- next step
  train.py
  nlp_pipeline.py
  auth.py
  main.py
  summariser.py
migrations/
  001_schema.sql
models/           <- populated after training
tests/
```

**Verify:** `python -c "from src.fhir_ingest import fetch_patient_bundle; d = fetch_patient_bundle('example'); print(d['resourceType'])"` prints `Bundle`.

---

### Step 4: Feature engineering from PostgreSQL

**Goal:** Flatten the normalised patient tables into a feature matrix ready for XGBoost, including the 30-day readmission label.

```python
# src/features.py
import pandas as pd
import sqlalchemy as sa

FEATURE_COLS = [
    "age", "gender_male", "obs_count",
    "avg_temp", "avg_hr", "avg_creatinine",
    "has_high_risk_dx", "medication_count",
]

FEATURE_QUERY = """
WITH enc_features AS (
    SELECT
        e.id                                                      AS encounter_id,
        EXTRACT(YEAR FROM AGE(e.discharge_date, p.birth_date))::INT AS age,
        CASE p.gender WHEN 'male' THEN 1 ELSE 0 END               AS gender_male,
        COUNT(o.id)                                               AS obs_count,
        AVG(CASE WHEN o.loinc_code = '8310-5' THEN o.value_num END) AS avg_temp,
        AVG(CASE WHEN o.loinc_code = '8867-4' THEN o.value_num END) AS avg_hr,
        AVG(CASE WHEN o.loinc_code = '2160-0' THEN o.value_num END) AS avg_creatinine,
        0 AS has_high_risk_dx,    -- enriched by NLP pipeline
        0 AS medication_count,    -- enriched by NLP pipeline
        e.discharge_date
    FROM encounters e
    JOIN patients p ON p.id = e.patient_id
    LEFT JOIN observations o ON o.encounter_id = e.id
    GROUP BY e.id, p.birth_date, p.gender, e.discharge_date
),
readmit AS (
    SELECT
        e1.id AS enc_id,
        EXISTS (
            SELECT 1 FROM encounters e2
            WHERE e2.patient_id = e1.patient_id
              AND e2.admission_date BETWEEN e1.discharge_date
                                        AND e1.discharge_date + INTERVAL '30 days'
              AND e2.id <> e1.id
        )::INT AS readmitted_30d
    FROM encounters e1
)
SELECT f.*, r.readmitted_30d
FROM enc_features f
JOIN readmit r ON r.enc_id = f.encounter_id;
"""

def load_feature_matrix(engine: sa.Engine) -> pd.DataFrame:
    return pd.read_sql(FEATURE_QUERY, engine)
```

**Verify:** `df = load_feature_matrix(engine); print(df.shape, df["readmitted_30d"].mean())` — readmission rate typically 0.10–0.20 on real data.

---

### Step 5: spaCy clinical NLP pipeline

**Goal:** Extract medications, diagnoses, and procedures from unstructured discharge notes to add two new features: `has_high_risk_dx` and `medication_count`.

```python
# src/nlp_pipeline.py
import spacy

nlp = spacy.load("en_core_sci_sm")

ENTITY_LABELS   = {"DISEASE", "CHEMICAL", "PROCEDURE"}
HIGH_RISK_DX    = {"heart failure", "copd", "diabetes", "renal failure", "sepsis"}

def extract_clinical_entities(note: str) -> dict[str, list[str]]:
    doc = nlp(note)
    entities: dict[str, list[str]] = {label: [] for label in ENTITY_LABELS}
    for ent in doc.ents:
        if ent.label_ in ENTITY_LABELS:
            entities[ent.label_].append(ent.text)
    return {k: list(set(v)) for k, v in entities.items()}

def enrich_features_from_note(base_features: dict, note: str) -> dict:
    entities = extract_clinical_entities(note)
    base_features["has_high_risk_dx"] = int(
        any(d.lower() in HIGH_RISK_DX for d in entities.get("DISEASE", []))
    )
    base_features["medication_count"] = len(entities.get("CHEMICAL", []))
    return base_features
```

**Verify:** `python -c "from src.nlp_pipeline import extract_clinical_entities; print(extract_clinical_entities('Patient with heart failure on furosemide'))"` returns a dict with `DISEASE` and `CHEMICAL` entries.

---

### Step 6: XGBoost model training and SHAP

**Goal:** Train a calibrated XGBoost classifier and produce per-prediction SHAP values.

```python
# src/train.py
import pickle
import pandas as pd
import xgboost as xgb
import shap
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score, classification_report
from sklearn.calibration import CalibratedClassifierCV
import sqlalchemy as sa
from src.features import load_feature_matrix, FEATURE_COLS

TARGET     = "readmitted_30d"
MODEL_PATH = "models/readmission_xgb.pkl"

def train(engine: sa.Engine):
    df = load_feature_matrix(engine).dropna(subset=FEATURE_COLS)
    X, y = df[FEATURE_COLS].fillna(0), df[TARGET]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    base = xgb.XGBClassifier(
        n_estimators=400,
        max_depth=5,
        learning_rate=0.05,
        scale_pos_weight=(y_train == 0).sum() / (y_train == 1).sum(),
        eval_metric="auc",
        use_label_encoder=False,
    )
    model = CalibratedClassifierCV(base, method="isotonic", cv=5)
    model.fit(X_train, y_train)

    proba = model.predict_proba(X_test)[:, 1]
    print(f"AUC-ROC: {roc_auc_score(y_test, proba):.4f}")
    print(classification_report(y_test, (proba > 0.35).astype(int)))

    with open(MODEL_PATH, "wb") as f:
        pickle.dump(model, f)
    return model

def explain_one(model, X_row: pd.DataFrame) -> dict[str, float]:
    base_est = model.calibrated_classifiers_[0].estimator
    explainer = shap.TreeExplainer(base_est)
    vals = explainer.shap_values(X_row)[0]
    return dict(zip(X_row.columns.tolist(), [round(float(v), 4) for v in vals]))

if __name__ == "__main__":
    import os
    engine = sa.create_engine(os.environ["DATABASE_URL"])
    train(engine)
    print(f"Model saved to {MODEL_PATH}")
```

```bash
mkdir -p models
python src/train.py
```

**Verify:** AUC-ROC is printed (target > 0.70 on synthetic data); `ls models/` shows `readmission_xgb.pkl`.

---

### Step 7: Auth0 HIPAA-compliant authentication

**Goal:** Protect the inference API with Auth0 JWT bearer tokens; enforce MFA for clinical roles.

In the Auth0 dashboard:
1. Create a new API (identifier: `https://api.healthpredict.example.com`)
2. Enable "Enforce MFA" for the clinician user connection
3. Add permission `predict:read` to the API and assign it to the clinical role

```python
# src/auth.py
import os
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError
import httpx

AUTH0_DOMAIN   = os.environ["AUTH0_DOMAIN"]
AUTH0_AUDIENCE = os.environ["AUTH0_AUDIENCE"]
JWKS_URL       = f"https://{AUTH0_DOMAIN}/.well-known/jwks.json"

bearer = HTTPBearer()

async def get_current_user(
    creds: HTTPAuthorizationCredentials = Depends(bearer),
) -> dict:
    token = creds.credentials
    try:
        async with httpx.AsyncClient() as client:
            jwks = (await client.get(JWKS_URL)).json()
        header  = jwt.get_unverified_header(token)
        key     = next(k for k in jwks["keys"] if k["kid"] == header["kid"])
        payload = jwt.decode(
            token,
            key,
            algorithms=["RS256"],
            audience=AUTH0_AUDIENCE,
            issuer=f"https://{AUTH0_DOMAIN}/",
        )
        if "predict:read" not in payload.get("permissions", []):
            raise HTTPException(status_code=403, detail="Missing predict:read permission")
        return payload
    except (JWTError, StopIteration) as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(exc))
```

**Verify:** `curl -H "Authorization: Bearer invalid" http://localhost:8000/predict` returns HTTP 401.

---

### Step 8: FastAPI inference endpoint

**Goal:** Serve readmission risk scores with SHAP explanations, authenticated via Auth0 JWT, with every request audit-logged.

```python
# src/main.py
import pickle, os
import pandas as pd
from fastapi import FastAPI, Depends, Request
from fastapi.responses import Response
from pydantic import BaseModel
import sqlalchemy as sa
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from src.auth import get_current_user
from src.train import explain_one, FEATURE_COLS

app    = FastAPI(title="Patient Readmission Risk API", version="1.0")
engine = sa.create_engine(os.environ["DATABASE_URL"])

with open("models/readmission_xgb.pkl", "rb") as f:
    MODEL = pickle.load(f)

PREDICT_COUNT   = Counter("predictions_total",    "Total predictions served")
PREDICT_LATENCY = Histogram("prediction_latency_seconds", "Inference latency")

class PredictRequest(BaseModel):
    encounter_id:   str
    age:            int
    gender_male:    int
    obs_count:      int
    avg_temp:       float | None = None
    avg_hr:         float | None = None
    avg_creatinine: float | None = None
    has_high_risk_dx:  int = 0
    medication_count:  int = 0

class PredictResponse(BaseModel):
    encounter_id: str
    risk_score:   float
    high_risk:    bool
    shap_values:  dict[str, float]
    explanation:  str | None = None

@app.post("/predict", response_model=PredictResponse)
async def predict(
    body: PredictRequest,
    request: Request,
    user: dict = Depends(get_current_user),
):
    with PREDICT_LATENCY.time():
        row    = pd.DataFrame([body.model_dump(include=set(FEATURE_COLS))]).fillna(0)
        score  = float(MODEL.predict_proba(row)[0, 1])
        shap_v = explain_one(MODEL, row)
        PREDICT_COUNT.inc()

    # HIPAA audit log
    with engine.begin() as conn:
        conn.execute(
            sa.text("INSERT INTO audit_log (action, resource, actor, ip_addr) "
                    "VALUES ('predict', :enc, :actor, :ip)"),
            {"enc": body.encounter_id, "actor": user["sub"], "ip": request.client.host},
        )

    return PredictResponse(
        encounter_id=body.encounter_id,
        risk_score=round(score, 4),
        high_risk=score > 0.35,
        shap_values=shap_v,
    )

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
```

```bash
uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload
```

**Verify:** `http://localhost:8000/docs` shows the Swagger UI with the `/predict` endpoint; every call inserts a row into `audit_log`.

---

### Step 9: LangChain clinical summary agent

**Goal:** Convert raw SHAP values into a plain-English clinical summary that a nurse can read in 10 seconds.

```python
# src/summariser.py
import os, json
from langchain_mistralai import ChatMistralAI
from langchain.schema import SystemMessage, HumanMessage

llm = ChatMistralAI(
    model="mistral-small-latest",
    api_key=os.environ["MISTRAL_API_KEY"],
    temperature=0.2,
)

SYSTEM_PROMPT = """You are a clinical decision-support assistant.
Given a patient's 30-day readmission risk score and SHAP feature contributions,
write a 2-3 sentence summary a nurse or physician can act on at discharge.
Name the top 3 risk drivers in plain English. Do NOT make treatment recommendations.
Output only the summary — no headings, no bullet points."""

def summarise_prediction(
    risk_score: float,
    shap_values: dict[str, float],
    encounter_id: str,
) -> str:
    top3 = sorted(shap_values.items(), key=lambda x: abs(x[1]), reverse=True)[:3]
    payload = {
        "encounter_id":    encounter_id,
        "risk_score":      risk_score,
        "top_risk_drivers": [{"feature": k, "shap": round(v, 3)} for k, v in top3],
    }
    messages = [
        SystemMessage(content=SYSTEM_PROMPT),
        HumanMessage(content=json.dumps(payload)),
    ]
    return llm.invoke(messages).content
```

Add `summariser.summarise_prediction(score, shap_v, body.encounter_id)` to the `/predict` handler and return it as the `explanation` field.

**Verify:** Calling `/predict` with high creatinine and age values produces a summary that mentions renal function or age as a risk factor.

---

### Step 10: Grafana model monitoring dashboard

**Goal:** Detect service degradation and model drift before clinicians notice.

```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: readmission_api
    static_configs:
      - targets: ["host.docker.internal:8000"]
```

In Grafana (`http://localhost:3000`), add panels:
- `rate(predictions_total[5m])` — prediction throughput
- `histogram_quantile(0.99, prediction_latency_seconds_bucket)` — P99 latency
- Rolling 24-hour average of `risk_score` from PostgreSQL (distribution shift alert)

Create an alert rule: fire if P99 latency exceeds 500 ms for 5 consecutive minutes.

**Verify:** After 10 `/predict` calls, `http://localhost:9090/graph?g0.expr=predictions_total` shows a non-zero counter.

---

### Step 11: Looker BI layer for clinical leadership

**Goal:** Surface readmission risk trends by ward, attending physician, and ICD-10 code without requiring SQL knowledge.

Create a LookML project connected to PostgreSQL:

```lookml
# models/healthpredict.model.lkml
connection: "healthdb_postgres"
include: "/views/*.view.lkml"

explore: predictions {
  join: encounters {
    type: left_outer
    sql_on: ${predictions.encounter_id} = ${encounters.id} ;;
    relationship: many_to_one
  }
}
```

```lookml
# views/predictions.view.lkml
view: predictions {
  sql_table_name: public.predictions ;;

  dimension: risk_score {
    type: number
    sql: ${TABLE}.risk_score ;;
    value_format: "0.00%"
  }
  dimension: high_risk {
    type: yesno
    sql: ${TABLE}.risk_label ;;
  }
  dimension_group: created {
    type: time
    timeframes: [date, week, month]
    sql: ${TABLE}.created_at ;;
  }
  measure: avg_risk_score {
    type: average
    sql: ${TABLE}.risk_score ;;
  }
  measure: high_risk_count {
    type: count_distinct
    sql: CASE WHEN ${TABLE}.risk_label THEN ${TABLE}.id END ;;
  }
}
```

**Verify:** A bar chart of `high_risk_count` by `encounters.ward` renders in Looker without SQL errors.

---

### Step 12: End-to-end integration test

**Goal:** Validate the full pipeline from a feature payload through prediction to the audit log record.

```python
# tests/test_e2e.py
import pytest, httpx, os

API_URL = "http://localhost:8000"

@pytest.fixture
def auth_token():
    return os.environ.get("TEST_AUTH_TOKEN", "test_token_placeholder")

def test_predict_high_risk(auth_token):
    payload = {
        "encounter_id":    "test-enc-001",
        "age":             72,
        "gender_male":     0,
        "obs_count":       15,
        "avg_temp":        37.8,
        "avg_hr":          98.0,
        "avg_creatinine":  2.1,
        "has_high_risk_dx": 1,
        "medication_count": 8,
    }
    resp = httpx.post(
        f"{API_URL}/predict",
        json=payload,
        headers={"Authorization": f"Bearer {auth_token}"},
    )
    assert resp.status_code == 200
    data = resp.json()
    assert 0.0 <= data["risk_score"] <= 1.0
    assert isinstance(data["shap_values"], dict)
    assert len(data["shap_values"]) == len(payload) - 1   # minus encounter_id

def test_unauthenticated_rejected():
    resp = httpx.post(f"{API_URL}/predict", json={})
    assert resp.status_code in (401, 403)
```

```bash
pytest tests/ -v --tb=short
```

---

## Testing

```bash
# Unit tests (no external services)
pytest tests/unit/ -v

# Integration tests (requires Docker services)
pytest tests/integration/ -v

# Model evaluation report
python src/evaluate.py  # prints AUC, PR-AUC, calibration plot path
```

Key test scenarios:
- `/predict` returns 401 with invalid token and 403 with missing `predict:read` permission
- SHAP values dict has one key per feature column
- Audit log row is inserted for every successful prediction call
- spaCy pipeline correctly extracts known medications and diseases from a sample note
- Calibrated model outputs probabilities between 0.0 and 1.0 on unseen data

---

## Deployment

```bash
# Build Docker image
docker build -t healthpredict-api:latest .

# Run with required environment variables
docker run -p 8000:8000 \
  -e DATABASE_URL=postgresql://health_user:health_secret@db:5432/healthdb \
  -e AUTH0_DOMAIN=your-tenant.auth0.com \
  -e AUTH0_AUDIENCE=https://api.healthpredict.example.com \
  -e MISTRAL_API_KEY=... \
  healthpredict-api:latest
```

For HIPAA-eligible production deployment:
- Use AWS GovCloud or Azure Government (BAA-covered regions)
- Enable RDS encryption at rest (AES-256) and TLS enforcement via `sslmode=require`
- Configure Auth0 HIPAA Business Associate Agreement before handling real PHI
- Enable AWS CloudTrail to supplement the application-level audit log

---

## Resources

1. [FHIR R4 specification](https://hl7.org/fhir/R4/) — resource types and REST API patterns
2. [XGBoost Python docs](https://xgboost.readthedocs.io/en/stable/python/python_api.html) — classifier API and hyperparameter reference
3. [SHAP TreeExplainer](https://shap.readthedocs.io/en/latest/generated/shap.TreeExplainer.html) — fast exact SHAP values for tree models
4. [Auth0 FastAPI integration guide](https://auth0.com/blog/build-and-secure-fastapi-server-with-auth0/) — JWT validation walkthrough
5. [SciSpacy clinical NER models](https://allenai.github.io/scispacy/) — en_core_sci_sm and biomedical entity types
6. [HHS HIPAA Security Rule — technical safeguards](https://www.hhs.gov/hipaa/for-professionals/security/guidance/technical/index.html) — official compliance reference
