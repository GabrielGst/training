# Track: Data Engineer

## Objective

Build production-grade data engineering skills: schema design, advanced SQL, ETL pipelines, data transformation with dbt, and orchestration with Airflow. By the end of this track you can design and operate a complete data platform from ingestion to BI-ready marts — and anchor that in real FDE portfolio projects.

---

## Junior → Senior Progression

| Level | Can do |
|-------|--------|
| Junior | Write complex SQL (CTEs, window functions), design a normalized schema, build a simple ETL script, use the Django ORM for basic queries |
| Mid | Build Airflow DAGs with retry logic and alerting, write dbt models with tests and docs, understand data warehouse design (star schema, mart layer) |
| Senior | Design a full data platform architecture, choose between lake/warehouse/lakehouse, handle data quality at scale (Great Expectations, data contracts), build streaming pipelines |

---

## Modules

### Phase 1 — Foundations

| # | Slug | Key Skills | Hours | Status |
|---|------|-----------|-------|--------|
| 01 | [01-postgresql](01-postgresql/) | Advanced SQL, CTEs, window funcs, indexes, EXPLAIN ANALYZE | 12 | ⏳ |
| 02 | [02-django-orm](02-django-orm/) | Models, migrations, querysets, select_related, raw SQL, signals | 15 | ⏳ |
| 03 | [03-mysql-mariadb](03-mysql-mariadb/) | MySQL vs Postgres differences, replication, storage engines | 10 | ⏳ |

### Phase 2 — Core Modules

| # | Slug | Key Skills | Hours | Anchor Project | Status |
|---|------|-----------|-------|---------------|--------|
| 04 | [04-data-pipelines-airflow](04-data-pipelines-airflow/) | Airflow DAGs, operators, sensors, scheduling, XComs | 15 | P09 Marketing | ⏳ |
| 05 | [05-dbt-transformations](05-dbt-transformations/) | dbt models, sources, tests, documentation, lineage graph | 12 | P09 Marketing | ⏳ |
| 06 | [06-data-warehouse](06-data-warehouse/) | Snowflake, OLAP vs OLTP, ELT patterns, star schema | 12 | P04 Supply Chain | ⏳ |
| 07 | [07-observability-monitoring](07-observability-monitoring/) | Prometheus metrics, Grafana dashboards, alerting rules | 10 | P03 Fraud Detection | ⏳ |

### Phase 3 — Capstone

| Slug | Description | Hours | Status |
|------|-------------|-------|--------|
| [capstone-data-platform](capstone-data-platform/) | Full ELT platform: source → PostgreSQL → dbt → dashboard, orchestrated with Airflow | 45 | ⏳ |

---

## FDE Portfolio Projects (anchored in this track)

| Project | Domain | Key Skills | Modules Required |
|---------|--------|-----------|-----------------|
| [P09 Marketing Attribution](../../doc/roadmap/projects/ai-projects.md#p09) | Marketing Analytics | SK06, SK19, SK21, SK22 | 01, 04, 05, 06 |
| [P03 Fraud Detection](../../doc/roadmap/projects/ai-projects.md#p03) | Fintech | SK06, SK19 (pipeline) | 04, 05, 07 |
| [P04 Supply Chain](../../doc/roadmap/projects/ai-projects.md#p04) | Supply Chain | SK06, SK19 | 04, 06 |

---

## Job Market Mapping

From [`skill-matrix.md`](../../doc/research/skill-matrix.md):

| Skill ID | Skill | JD Frequency | Tier | Module |
|----------|-------|------------|------|--------|
| SK06 | Database Schema Design & Query Optimization | **High** | P1 | 01-postgresql, 02-django-orm |
| — | PostgreSQL / SQL | **High** | P1 | 01-postgresql |
| — | Python (pandas/polars) | **High** | P1 | 04-data-pipelines-airflow |
| — | dbt | **High** (standard 2025) | P1 | 05-dbt-transformations |
| — | Apache Airflow | **High** | P2 | 04-data-pipelines-airflow |
| SK19 | Pipeline Orchestration & Automation | **High** | P1 | 04-data-pipelines-airflow |
| — | MySQL / MariaDB | **Medium** | P2 | 03-mysql-mariadb |
| — | Snowflake / Cloud DW | **High** | P2 | 06-data-warehouse |
| SK08 | Observability & Monitoring | **High** | P1 | 07-observability-monitoring |

---

## Resources

1. [dbt Learn](https://learn.getdbt.com) — Official dbt fundamentals and advanced course; free
2. [pgexercises.com](https://pgexercises.com) — Progressive PostgreSQL exercises; best SQL practice tool
3. [Fundamentals of Data Engineering](https://www.oreilly.com/library/view/fundamentals-of-data/9781098108298/) — Reis & Housley — the field's bible

---

## Capstone

**`capstone-data-platform` — End-to-End Data Platform**

A complete ELT pipeline: Python extractor → PostgreSQL raw layer → dbt staging/intermediate/mart → Metabase or Looker visualization. Orchestrated with Airflow (daily schedule, retry logic, alerting). Deployed on Docker with live data.

Full spec: [doc/roadmap/phase-3-capstones.md](../../doc/roadmap/phase-3-capstones.md#capstone-3-end-to-end-data-platform-data-engineer)
