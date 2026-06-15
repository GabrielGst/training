# P07 — Field Service Optimization and Routing

**Domain:** Field Services / Operations  **Track:** `fde-ai`  **Status:** not started  **Hours target:** 40

## Business Problem

Field technicians are dispatched inefficiently because routing ignores real-time traffic, technician skill profiles, and SLA priority tiers. Dispatchers manually assign 200+ technicians daily, resulting in 4-hour average response times and 35% of billable time lost to excess travel. This project builds a dynamic route optimization engine with a mobile app for field updates, cutting response times and maximizing billable utilization.

## What you will build

- A Flask + OR-Tools VRP (Vehicle Routing Problem) solver that optimally assigns work orders to technicians given skill requirements, time windows, and live traffic data
- A PostGIS-backed PostgreSQL schema storing job sites, technician locations, and historical route data with geospatial indexes
- A Redis-cached dispatch layer that refreshes route assignments every 60 seconds as technicians complete jobs or new orders arrive
- An Express.js REST API serving the mobile app with endpoints for accepting job completions, status updates, and route recalculation triggers
- A React Native mobile app displaying the technician's daily route on Google Maps with turn-by-turn directions and one-tap job completion
- Twilio SMS notifications alerting customers when a technician is 20 minutes away, with live ETA updates

## Architecture

```
Google Maps API
      |
  Travel-Time Matrix
      |
OR-Tools VRP Solver (Flask)
      |               \
PostGIS (routes)   Redis cache (60-s TTL)
      |               /
  Express.js REST API
      |           |
React Native   Twilio SMS
  Mobile App    (customer alerts)
```

## Skills covered

| Skill ID | Skill Name | What you practice |
|----------|------------|------------------|
| SK03 | Prompt Engineering and System Design | Craft prompts for the LLM-assisted dispatch rationale explainer |
| SK05 | Full-Stack Application Development | End-to-end: Flask solver + Express API + React Native mobile UI |
| SK06 | Database Schema Design and Query Optimization | PostGIS spatial schema, GIST indexes, nearest-neighbour queries |
| SK07 | Data Security and Privacy Compliance | Encrypt technician location data at rest; audit log all dispatch events |
| SK08 | Observability and Production Debugging | Prometheus metrics on solver latency; Grafana alert on stale Redis cache |
| SK13 | Agentic Workflows and Tool Use | LLM agent calling the VRP solver as a tool to explain routing decisions |
| SK17 | Model Evaluation and Ablation Testing | Compare OR-Tools VRP against greedy baseline on historic job datasets |
| SK18 | Feedback Loop Design and Active Learning | Collect technician feedback on route quality to retrain time estimates |
| SK27 | Geospatial Data and Location Services | PostGIS spatial queries, Google Maps travel-time matrix, coordinate transforms |
| SK28 | Mobile App Integration and Real-time Sync | React Native app with real-time route sync and offline-first job updates |
| SK29 | HIPAA and Healthcare Compliance | Apply enterprise compliance patterns (access control, audit trails) in an ops context |

## Tools & dependencies

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| Flask | 3.x | Python API server for the VRP solver | `pip install flask` |
| OR-Tools | 9.x | Google's VRP/constraint solver | `pip install ortools` |
| PostGIS | 3.4 | Spatial extension for PostgreSQL | `apt install postgis` or Docker image |
| Redis | 7.x | Sub-second route cache with 60-s TTL | `apt install redis` or Docker |
| React Native | 0.74 | Cross-platform iOS/Android mobile app | `npx react-native init` |
| Google Maps API | latest | Travel-time matrix + map rendering | API key from GCP console |
| Express.js | 4.x | Node.js REST API for mobile clients | `npm install express` |
| Twilio | 9.x | SMS customer notifications | `pip install twilio` |
| PostgreSQL | 16 | Primary relational database | Docker or managed RDS |

## Prerequisites

**Track modules to complete first:**
- [ ] `software-engineer/02-nodejs-fundamentals` — needed for Express.js API development
- [ ] `software-engineer/03-nextjs` — React component patterns reused in React Native
- [ ] `data-engineer/01-postgresql` — schema design, indexing, query plans before adding PostGIS

**Accounts / API keys needed:**
- [ ] Google Cloud Platform — Maps JavaScript API + Distance Matrix API
- [ ] Twilio — SMS sending number + account SID/auth token
- [ ] AWS — S3 bucket for route snapshots (optional)

---

## Step-by-step tutorial

### Step 1: Environment setup

**Goal:** Reproducible local environment with PostgreSQL/PostGIS, Redis, and Python + Node dependencies.

Create the project's Docker Compose file so the entire infrastructure runs with one command:

```yaml
# docker-compose.yml
version: "3.9"
services:
  db:
    image: postgis/postgis:16-3.4
    environment:
      POSTGRES_DB: fieldservice
      POSTGRES_USER: fs_user
      POSTGRES_PASSWORD: fs_secret
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  pgdata:
```

```bash
docker compose up -d
python -m venv .venv && source .venv/bin/activate
pip install flask ortools psycopg2-binary redis twilio python-dotenv sqlalchemy geoalchemy2 prometheus-client
npm install express axios dotenv
```

**Verify:** `docker compose ps` shows both containers healthy; `redis-cli ping` returns `PONG`.

---

### Step 2: Database schema with PostGIS

**Goal:** Store technicians, work orders, and geospatial routes with proper spatial indexes.

```sql
-- migrations/001_init.sql
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE technicians (
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL,
    phone       TEXT,
    skills      TEXT[],          -- e.g. ARRAY['HVAC','electrical']
    current_loc GEOMETRY(Point, 4326),
    updated_at  TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE work_orders (
    id           SERIAL PRIMARY KEY,
    customer     TEXT NOT NULL,
    phone        TEXT,
    address      TEXT NOT NULL,
    location     GEOMETRY(Point, 4326),
    skill_req    TEXT,            -- required technician skill
    priority     SMALLINT DEFAULT 2,  -- 1=urgent, 2=standard, 3=low
    time_window_start  TIMESTAMPTZ,
    time_window_end    TIMESTAMPTZ,
    status       TEXT DEFAULT 'pending',  -- pending | assigned | complete
    assigned_to  INT REFERENCES technicians(id),
    created_at   TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE route_snapshots (
    id          SERIAL PRIMARY KEY,
    snapshot_at TIMESTAMPTZ DEFAULT now(),
    payload     JSONB NOT NULL   -- full assignment map per technician
);

-- Spatial indexes for fast nearest-neighbour queries
CREATE INDEX idx_tech_loc   ON technicians USING GIST(current_loc);
CREATE INDEX idx_order_loc  ON work_orders  USING GIST(location);
```

```bash
psql -h localhost -U fs_user -d fieldservice -f migrations/001_init.sql
```

**Verify:** `\d work_orders` in psql shows the `location` column with type `geometry`.

---

### Step 3: Google Maps travel-time matrix

**Goal:** Pre-compute a technician × job travel-time matrix used by the VRP solver.

```python
# src/maps_client.py
import os, requests

MAPS_KEY = os.environ["GOOGLE_MAPS_API_KEY"]

def get_travel_matrix(origins: list[tuple], destinations: list[tuple]) -> list[list[int]]:
    """
    origins / destinations: list of (lat, lng) tuples
    Returns seconds matrix: matrix[i][j] = travel time from origin i to destination j
    """
    def fmt(coords):
        return "|".join(f"{lat},{lng}" for lat, lng in coords)

    url = "https://maps.googleapis.com/maps/api/distancematrix/json"
    resp = requests.get(url, params={
        "origins":      fmt(origins),
        "destinations": fmt(destinations),
        "mode":         "driving",
        "departure_time": "now",
        "key":          MAPS_KEY,
    })
    resp.raise_for_status()
    data = resp.json()

    matrix = []
    for row in data["rows"]:
        matrix.append([
            elem["duration_in_traffic"]["value"]   # seconds
            for elem in row["elements"]
        ])
    return matrix
```

**File structure:**
```
src/
  maps_client.py
  solver.py       ← next step
  api.py
  models.py
```

**Verify:** `python -c "from src.maps_client import get_travel_matrix; print('OK')"` with a valid API key.

---

### Step 4: OR-Tools VRP solver

**Goal:** Assign work orders to technicians while respecting skill constraints, time windows, and minimising total travel time.

```python
# src/solver.py
from ortools.constraint_solver import routing_enums_pb2, pywrapcp

def solve_vrp(
    technicians: list[dict],   # [{id, skills, lat, lng}]
    orders:      list[dict],   # [{id, skill_req, lat, lng, priority, tw_start_s, tw_end_s}]
    matrix:      list[list[int]],
) -> dict[int, list[int]]:
    """
    Returns {technician_id: [order_id, ...]} assignment map.
    Nodes: 0..n-1 are technicians (depots), n..n+m-1 are orders.
    """
    n, m = len(technicians), len(orders)
    manager = pywrapcp.RoutingIndexManager(n + m, n, list(range(n)))
    routing = pywrapcp.RoutingModel(manager)

    def transit(from_idx, to_idx):
        i = manager.IndexToNode(from_idx)
        j = manager.IndexToNode(to_idx)
        return matrix[i][j]

    transit_cb = routing.RegisterTransitCallback(transit)
    routing.SetArcCostEvaluatorOfAllVehicles(transit_cb)

    # Time dimension for time-window constraints
    routing.AddDimension(transit_cb, 3600, 28800, False, "Time")
    time_dim = routing.GetDimensionOrDie("Time")

    for idx, order in enumerate(orders):
        node = manager.NodeToIndex(n + idx)
        if order.get("tw_start_s") and order.get("tw_end_s"):
            time_dim.CumulVar(node).SetRange(order["tw_start_s"], order["tw_end_s"])

        # Enforce skill constraint via disjunction (allowed vehicles only)
        allowed = [
            i for i, t in enumerate(technicians)
            if order["skill_req"] in t.get("skills", [])
        ]
        if len(allowed) < n:
            routing.SetAllowedVehiclesForIndex(allowed, node)

    params = pywrapcp.DefaultRoutingSearchParameters()
    params.first_solution_strategy = routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC
    params.time_limit.seconds = 10

    solution = routing.SolveWithParameters(params)
    if not solution:
        return {}

    result = {}
    for v in range(n):
        tech_id = technicians[v]["id"]
        route, idx = [], routing.Start(v)
        while not routing.IsEnd(idx):
            node = manager.IndexToNode(idx)
            if node >= n:
                route.append(orders[node - n]["id"])
            idx = solution.Value(routing.NextVar(idx))
        result[tech_id] = route
    return result
```

**Verify:** Write a small test with 2 technicians and 4 orders and assert the result has 2 keys.

---

### Step 5: Flask solver API

**Goal:** Expose the VRP solver as a REST endpoint that the Express.js layer can call.

```python
# src/api.py
from flask import Flask, request, jsonify
from prometheus_client import Histogram, generate_latest, CONTENT_TYPE_LATEST
import time, os
from src.solver import solve_vrp
from src.maps_client import get_travel_matrix

app = Flask(__name__)

SOLVE_LATENCY = Histogram("vrp_solve_seconds", "Time spent solving VRP")

@app.post("/solve")
def solve():
    body = request.get_json()
    technicians = body["technicians"]
    orders      = body["orders"]

    all_locs = [(t["lat"], t["lng"]) for t in technicians] + \
               [(o["lat"], o["lng"]) for o in orders]

    t0 = time.time()
    matrix = get_travel_matrix(all_locs, all_locs)
    assignment = solve_vrp(technicians, orders, matrix)
    SOLVE_LATENCY.observe(time.time() - t0)

    return jsonify({"assignment": assignment})

@app.get("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=False)
```

```bash
flask --app src.api run --port 5001
```

**Verify:** `curl -X POST http://localhost:5001/solve -H "Content-Type: application/json" -d '{"technicians":[],"orders":[]}'` returns `{"assignment":{}}`.

---

### Step 6: Redis dispatch cache

**Goal:** Cache the current route assignment so the Express API can serve the mobile app without hitting the solver on every request.

```python
# src/cache.py
import redis, json, os

r = redis.Redis(host=os.environ.get("REDIS_HOST", "localhost"), decode_responses=True)

CACHE_KEY = "current_assignment"
TTL = 60  # seconds

def set_assignment(assignment: dict) -> None:
    r.setex(CACHE_KEY, TTL, json.dumps(assignment))

def get_assignment() -> dict | None:
    raw = r.get(CACHE_KEY)
    return json.loads(raw) if raw else None

def invalidate() -> None:
    r.delete(CACHE_KEY)
```

Add a background thread to the Flask app that re-solves every 60 seconds and calls `set_assignment`:

```python
# in src/api.py — add after app definition
import threading
from src.cache import set_assignment, get_assignment

def refresh_loop():
    import requests as req
    while True:
        time.sleep(60)
        try:
            resp = req.post("http://localhost:5001/solve", json=build_payload())
            set_assignment(resp.json()["assignment"])
        except Exception as e:
            app.logger.error(f"refresh failed: {e}")

threading.Thread(target=refresh_loop, daemon=True).start()
```

**Verify:** After posting a `/solve` request, `redis-cli get current_assignment` shows the JSON payload.

---

### Step 7: Express.js mobile API

**Goal:** Node.js layer that the React Native app talks to — serves routes, accepts job completions, and triggers cache invalidation.

```javascript
// server/index.js
const express = require("express");
const axios   = require("axios");
const redis   = require("redis");

const app = express();
app.use(express.json());

const rc = redis.createClient({ url: process.env.REDIS_URL || "redis://localhost:6379" });
rc.connect();

// GET /routes/:technicianId — return cached route for one technician
app.get("/routes/:technicianId", async (req, res) => {
  const raw = await rc.get("current_assignment");
  if (!raw) return res.status(503).json({ error: "No route available yet" });
  const assignment = JSON.parse(raw);
  const route = assignment[req.params.technicianId] ?? [];
  res.json({ technicianId: req.params.technicianId, route });
});

// POST /jobs/:orderId/complete — mark a job done, invalidate cache
app.post("/jobs/:orderId/complete", async (req, res) => {
  // Update status in Postgres (simplified; use pg pool in production)
  await axios.post(`${process.env.FLASK_URL}/job-complete`, {
    orderId: req.params.orderId,
  });
  await rc.del("current_assignment");  // force re-solve on next poll
  res.json({ status: "ok" });
});

app.listen(3001, () => console.log("Mobile API listening on :3001"));
```

```bash
node server/index.js
```

**Verify:** `curl http://localhost:3001/routes/1` returns `{"technicianId":"1","route":[]}` (empty until first solve).

---

### Step 8: Twilio SMS notifications

**Goal:** Alert customers by SMS when their technician is 20 minutes away.

```python
# src/notifications.py
import os
from twilio.rest import Client

client = Client(os.environ["TWILIO_ACCOUNT_SID"], os.environ["TWILIO_AUTH_TOKEN"])
FROM_NUMBER = os.environ["TWILIO_FROM"]

def send_eta_alert(customer_phone: str, tech_name: str, eta_minutes: int) -> str:
    message = client.messages.create(
        body=f"Hi! {tech_name} is about {eta_minutes} minutes away. "
             f"Track your appointment at https://fieldservice.example.com/track",
        from_=FROM_NUMBER,
        to=customer_phone,
    )
    return message.sid
```

Add a `/eta-alert` endpoint to the Flask API that calls `send_eta_alert` when a technician's ETA drops below 20 minutes. The React Native app polls its own route and calls this endpoint automatically.

**Verify:** With Twilio trial credentials, a test SMS arrives at your registered number within 30 seconds.

---

### Step 9: React Native mobile app

**Goal:** Display today's route on a map with job cards; one-tap to mark complete.

```bash
npx react-native@latest init FieldServiceApp --template react-native-template-typescript
cd FieldServiceApp
npm install react-native-maps @react-navigation/native axios
```

```typescript
// src/screens/RouteScreen.tsx
import React, { useEffect, useState } from "react";
import { View, FlatList, Text, Button, StyleSheet } from "react-native";
import MapView, { Marker, Polyline } from "react-native-maps";
import axios from "axios";

const API = "http://10.0.2.2:3001"; // Android emulator → host

export default function RouteScreen({ technicianId }: { technicianId: string }) {
  const [route, setRoute] = useState<number[]>([]);

  useEffect(() => {
    axios.get(`${API}/routes/${technicianId}`).then(r => setRoute(r.data.route));
  }, []);

  const complete = async (orderId: number) => {
    await axios.post(`${API}/jobs/${orderId}/complete`);
    setRoute(prev => prev.filter(id => id !== orderId));
  };

  return (
    <View style={styles.container}>
      <MapView style={styles.map} showsUserLocation />
      <FlatList
        data={route}
        keyExtractor={id => String(id)}
        renderItem={({ item }) => (
          <View style={styles.card}>
            <Text>Order #{item}</Text>
            <Button title="Complete" onPress={() => complete(item)} />
          </View>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  map:       { flex: 0.5 },
  card:      { padding: 12, borderBottomWidth: 1, borderColor: "#eee" },
});
```

**Verify:** `npx react-native run-android` launches the emulator; the route list populates after the solver completes.

---

### Step 10: Observability — Prometheus + Grafana

**Goal:** Track solver latency and cache-hit ratio in Grafana so you can detect when the routing degrades.

```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: vrp_solver
    static_configs:
      - targets: ["host.docker.internal:5001"]
```

Add Prometheus and Grafana to `docker-compose.yml`:

```yaml
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
```

Import the Grafana dashboard at `http://localhost:3000` and add a panel for `vrp_solve_seconds_bucket` to visualise P50/P99 solver latency.

**Verify:** After three `/solve` calls, `http://localhost:9090/graph?g0.expr=vrp_solve_seconds_bucket` shows histogram buckets.

---

### Step 11: Dispatch explainability agent

**Goal:** Wrap a Mistral LLM call to generate a human-readable explanation of why each technician was assigned their route.

```python
# src/explainer.py
import os, json
from langchain_mistralai import ChatMistralAI
from langchain.schema import HumanMessage, SystemMessage

llm = ChatMistralAI(model="mistral-small-latest", api_key=os.environ["MISTRAL_API_KEY"])

SYSTEM = """You are a field service dispatch assistant. Given a route assignment,
explain in plain English why each technician was assigned their jobs.
Focus on skill match, travel efficiency, and time-window compliance."""

def explain_assignment(technicians: list, orders: list, assignment: dict) -> str:
    tech_map  = {t["id"]: t for t in technicians}
    order_map = {o["id"]: o for o in orders}
    payload   = {
        str(tid): {
            "technician": tech_map[tid],
            "jobs": [order_map[oid] for oid in oids],
        }
        for tid, oids in assignment.items()
    }
    messages = [
        SystemMessage(content=SYSTEM),
        HumanMessage(content=json.dumps(payload, indent=2)),
    ]
    return llm.invoke(messages).content
```

**Verify:** Call `explain_assignment(technicians, orders, assignment)` and verify the LLM output references technician skills and order priorities by name.

---

### Step 12: End-to-end test

**Goal:** Confirm the full pipeline — seed data → solve → cache → API → SMS — without manual steps.

```python
# tests/test_e2e.py
import requests, time

BASE = "http://localhost:5001"

def test_full_pipeline():
    payload = {
        "technicians": [
            {"id": 1, "name": "Alice", "skills": ["HVAC"], "lat": 48.8566, "lng": 2.3522},
            {"id": 2, "name": "Bob",   "skills": ["electrical"], "lat": 48.8600, "lng": 2.3700},
        ],
        "orders": [
            {"id": 10, "skill_req": "HVAC",       "lat": 48.8580, "lng": 2.3600, "priority": 1,
             "tw_start_s": 0, "tw_end_s": 28800},
            {"id": 11, "skill_req": "electrical",  "lat": 48.8650, "lng": 2.3750, "priority": 2,
             "tw_start_s": 0, "tw_end_s": 28800},
        ],
    }
    resp = requests.post(f"{BASE}/solve", json=payload)
    assert resp.status_code == 200
    assignment = resp.json()["assignment"]
    # Alice (HVAC) gets order 10; Bob (electrical) gets order 11
    assert 10 in assignment.get("1", [])
    assert 11 in assignment.get("2", [])
```

```bash
pytest tests/test_e2e.py -v
```

---

## Testing

```bash
# Python unit tests
pytest tests/ -v --tb=short

# Node API integration tests
npm test

# Load test the solver (k6 required)
k6 run tests/load_test.js
```

Key test scenarios:
- Solver returns valid assignment with mixed skill requirements
- Redis cache returns stale data within TTL without calling solver
- Express API returns 503 when Redis is empty (not yet solved)
- Twilio SMS send is mocked in unit tests using `unittest.mock`

---

## Deployment

```bash
# Build and push Docker images
docker build -t fieldservice-solver:latest -f docker/solver.Dockerfile .
docker build -t fieldservice-api:latest    -f docker/api.Dockerfile .

# Deploy to AWS EC2 (or any VPS)
docker compose -f docker-compose.prod.yml up -d

# Environment variables required in production
GOOGLE_MAPS_API_KEY=...
TWILIO_ACCOUNT_SID=...
TWILIO_AUTH_TOKEN=...
TWILIO_FROM=+15550001234
REDIS_URL=redis://redis:6379
DATABASE_URL=postgresql://fs_user:fs_secret@db:5432/fieldservice
MISTRAL_API_KEY=...
```

For mobile, publish the React Native app via Expo EAS Build:
```bash
npx eas build --platform all
```

---

## Resources

1. [OR-Tools Vehicle Routing guide](https://developers.google.com/optimization/routing/vrp) — official VRP tutorial with constraint examples
2. [PostGIS documentation](https://postgis.net/documentation/) — spatial query reference and GIST index tuning
3. [Google Maps Distance Matrix API](https://developers.google.com/maps/documentation/distance-matrix) — travel-time matrix parameters
4. [Twilio Programmable SMS Python quickstart](https://www.twilio.com/docs/sms/quickstart/python) — sending and receiving SMS
5. [React Native Maps](https://github.com/react-native-maps/react-native-maps) — MapView component documentation
6. [LangChain tool-use agents](https://python.langchain.com/docs/modules/agents/) — wiring tools to LLM for dispatch explainability
