# Track: Data Engineer

## Objective

Build production-grade data engineering skills: schema design, advanced SQL, ETL pipelines, data transformation with dbt, and orchestration with Airflow. By the end of this track, you can design and operate a complete data platform from ingestion to BI-ready marts.

---

## Junior → Senior Progression

| Level | Can do |
|-------|--------|
| Junior | Write complex SQL (CTEs, window functions), design a normalized schema, build a simple ETL script, use the Django ORM for basic queries |
| Mid | Build Airflow DAGs with retry logic and alerting, write dbt models with tests and docs, understand data warehouse design (star schema, mart layer) |
| Senior | Design a full data platform architecture, choose between lake/warehouse/lakehouse, handle data quality at scale (Great Expectations, data contracts), build streaming pipelines |

---

## Modules

| # | Module | Key Skills | Status |
|---|--------|-----------|--------|
| 01 | [PostgreSQL](01-postgresql/) | Advanced SQL, CTEs, window funcs, indexes, EXPLAIN ANALYZE | ⏳ |
| 02 | [Django ORM](02-django-orm/) | Models, migrations, querysets, select_related, raw SQL | ⏳ |
| 03 | [MySQL / MariaDB](03-mysql-mariadb/) | MySQL differences from Postgres, replication, storage engines | ⏳ |
| 04 | [Data Pipelines](04-data-pipelines/) | Apache Airflow, dbt, ELT pattern, idempotent loads | ⏳ |
| 05 | [Capstone: Data Platform](05-capstone-data-platform/) | Full ELT pipeline: source → warehouse → dbt → visualization | ⏳ |

---

## Job Market Mapping

From [`skill-matrix.md`](../../doc/research/skill-matrix.md):

| Skill | JD Frequency | This Track Module |
|-------|------------|-------------------|
| PostgreSQL / SQL | **High** | 01-postgresql |
| Python (pandas/polars) | **High** | 04-data-pipelines |
| dbt | **High** (standard 2025) | 04-data-pipelines |
| Apache Airflow | **High** | 04-data-pipelines |
| Django ORM | **Medium** | 02-django-orm |
| MySQL / MariaDB | **Medium** | 03-mysql-mariadb |
| ETL pipeline design | **High** | 04-data-pipelines, 05-capstone |

---

## Resources

1. [dbt Learn](https://learn.getdbt.com) — Official dbt fundamentals and advanced course; free
2. [pgexercises.com](https://pgexercises.com) — Progressive PostgreSQL exercises; best SQL practice tool
3. [Fundamentals of Data Engineering](https://www.oreilly.com/library/view/fundamentals-of-data/9781098108298/) — Reis & Housley — the field's bible

---

## Capstone

**Module 05 — End-to-End Data Platform**

A complete ELT pipeline: Python extractor → PostgreSQL raw layer → dbt staging/intermediate/mart → Metabase or custom visualization. Orchestrated with Airflow (daily schedule, retry logic, alerting). See [doc/roadmap/phase-3-capstones.md](../../doc/roadmap/phase-3-capstones.md#capstone-3-end-to-end-data-platform-data-engineer) for full spec.
