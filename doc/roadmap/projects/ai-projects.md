# AI Projects Catalogue

> Source: `fde_ai_projects.csv`. All 10 FDE/AI portfolio projects.
> Project IDs are stable keys for DB import (P01–P10).

---

## P01 — VC Due Diligence AI Analyst

**Domain:** Venture Capital / Deal Flow  
**Primary track:** `ai-agents` (RAG, LLM, full-stack)  
**Skill IDs:** SK01, SK02, SK03, SK04, SK05, SK06, SK07, SK12, SK14  
**Tool IDs:** TL01, TL02, TL03, TL04, TL05, TL08, TL09, TL12, TL14, TL32, TL26  

### Business Problem
VCs spend 40+ hours analyzing pitch decks, cap tables, and market comps manually. Decision cycles delay weeks. Need automated extraction and scoring of deal viability signals.

### Solution Architecture
Build a multi-modal RAG pipeline that ingests PDFs (decks, financial docs), extracts structured signals (market size, team quality, traction), queries a vector store of comparable exits, and surfaces risk/opportunity scores via an internal API dashboard.

### Tech Stack
Next.js, FastAPI, Mistral API, LangChain, pgvector, Postgres, AWS S3, AWS Lambda, Pinecone

### Infrastructure
Serverless ingestion (Lambda), document storage on S3, vector embeddings stored in pgvector on RDS Postgres, inference via Mistral large-language-model API, frontend dashboard on Vercel.

### Integration Targets
Salesforce (deal tracking), Carta (cap table data), Slack (alert notifications)

### Portfolio Value
Flagship solo project: demonstrates full-stack RAG (embeddings → retrieval → LLM reasoning), multi-modal document handling, API design for financial workflows, and direct business impact metrics (days saved per deal).

### Skills Required
| Skill ID | Skill Name |
|----------|------------|
| SK01 | Requirements Discovery and Scoping Workshops |
| SK02 | RAG Architecture Design |
| SK03 | Prompt Engineering and System Design |
| SK04 | API Design and Contract Management |
| SK05 | Full-Stack Application Development |
| SK06 | Database Schema Design and Query Optimization |
| SK07 | Data Security and Privacy Compliance |
| SK12 | Customer Feedback Loops and Iteration |
| SK14 | Semantic Search and Vector Store Optimization |

---

## P02 — Customer Support Multimodal Triage

**Domain:** Customer Support / Service Operations  
**Primary track:** `ai-agents` (multimodal, async, event streaming)  
**Skill IDs:** SK01, SK02, SK03, SK08, SK09, SK10, SK12, SK13, SK15, SK16  
**Tool IDs:** TL01, TL02, TL07, TL10, TL11, TL13, TL15, TL16, TL17, TL24, TL33  

### Business Problem
Support teams receive 500+ tickets/day via email, chat, phone, and video; 50% misrouted or require re-reading context. Escalation to specialists takes 2+ days. Need intelligent intake and first-pass resolution.

### Solution Architecture
Multimodal ingestion pipeline that transcribes calls, extracts sentiment/intent from chat/email, classifies issue category using a fine-tuned classifier, retrieves relevant KB articles via RAG, and auto-drafts responses or escalates with full context to the right specialist.

### Tech Stack
React, Express.js, Mistral API, LangChain, Whisper (OpenAI), Qdrant, MongoDB, Node.js, Docker, GCP Cloud Run

### Infrastructure
Containerized microservices on GCP Cloud Run, message queue (Pub/Sub) for async processing, vector embeddings stored in Qdrant, KB documents in MongoDB, call transcription via Whisper API, async job queue for long-running classifications.

### Integration Targets
Zendesk (ticket system), Slack (team alerts), internal KB (Confluence), CRM (HubSpot)

### Portfolio Value
Demonstrates multimodal ingestion (voice, text, chat), production-grade async architectures, fine-tuning workflows, and measurable ops impact (ticket resolution time, CSAT lift). Strong narrative for ops-focused FDE roles.

### Skills Required
| Skill ID | Skill Name |
|----------|------------|
| SK01 | Requirements Discovery and Scoping Workshops |
| SK02 | RAG Architecture Design |
| SK03 | Prompt Engineering and System Design |
| SK08 | Observability and Production Debugging |
| SK09 | Cross-functional Stakeholder Engagement |
| SK10 | Business Impact and ROI Quantification |
| SK12 | Customer Feedback Loops and Iteration |
| SK13 | Agentic Workflows and Tool Use |
| SK15 | Real-time Integration and Event Streaming |
| SK16 | Feature Engineering and Model Architecture |

---

## P03 — Fintech Fraud Detection Real-Time

**Domain:** Financial Services / Fraud Prevention  
**Primary track:** `ai-engineer` (real-time ML, streaming, fraud)  
**Skill IDs:** SK02, SK03, SK06, SK11, SK13, SK14, SK17, SK18, SK19  
**Tool IDs:** TL18, TL19, TL20, TL22, TL23, TL24, TL25, TL27, TL28, TL04  

### Business Problem
Legacy fraud system has 12% false-positive rate (blocks legit transactions); mean time to detect fraud is 4 hours. Growing transaction volume demands sub-100ms latency and adaptive feature engineering.

### Solution Architecture
Replace batch-mode rules with real-time ML pipeline: ingest transactions as events, compute streaming features (velocity, geographic anomalies, merchant clustering), run low-latency ensemble model via ONNX, return accept/decline/challenge decision in <50ms with explainability.

### Tech Stack
Python, Kafka, Faust, XGBoost, ONNX, Redis, Postgres, Grafana, PagerDuty, AWS EC2 / ECS

### Infrastructure
Kafka topic per transaction flow, Faust for stateful stream processing (feature engineering), ONNX Runtime for <10ms inference, Redis for feature cache and state, Postgres for audit log, Grafana dashboards for fraud patterns, auto-scaling on ECS.

### Integration Targets
Core banking system (transaction feed), payment processor (authorization API), risk management platform

### Portfolio Value
Deep systems engineering + ML: demonstrates streaming architectures, sub-100ms latency optimization, model explainability (SHAP), and compliance/audit trails. Strong fit for fintech and high-stakes FDE roles.

### Skills Required
| Skill ID | Skill Name |
|----------|------------|
| SK02 | RAG Architecture Design |
| SK03 | Prompt Engineering and System Design |
| SK06 | Database Schema Design and Query Optimization |
| SK11 | Structured Output Extraction and Parsing |
| SK13 | Agentic Workflows and Tool Use |
| SK14 | Semantic Search and Vector Store Optimization |
| SK17 | Model Evaluation and Ablation Testing |
| SK18 | Feedback Loop Design and Active Learning |
| SK19 | Pipeline Orchestration and Automation |

---

## P04 — Supply Chain Demand Forecasting

**Domain:** Supply Chain / Operations  
**Primary track:** `ai-engineer` (time series forecasting, ML)  
**Skill IDs:** SK03, SK06, SK07, SK13, SK14, SK15, SK20, SK21  
**Tool IDs:** TL06, TL34, TL35, TL04, TL12, TL37, TL26, TL27  

### Business Problem
Manual forecasting by regional managers leads to 30% overstock / 15% stockouts. Lead times are 6–12 weeks; stock decisions need 8-week horizon visibility. Seasonality and supply disruptions are poorly modeled.

### Solution Architecture
Build ML forecast pipeline ingesting 3-year sales history, external signals (macro, weather, events), and supply constraints. Fine-tune time-series model (Prophet / LSTM hybrid), expose via REST API, integrate dashboards into supply planning tool with what-if simulation.

### Tech Stack
Python, Flask, Prophet, PyTorch, Postgres, Looker, AWS S3, AWS SageMaker, GitHub Actions

### Infrastructure
Daily batch retraining on SageMaker, model artifacts stored on S3, Postgres for historical data and forecasts, Flask API for ad-hoc queries, Looker for stakeholder dashboards, GitHub Actions for CI/CD pipeline orchestration.

### Integration Targets
ERP system (sales + inventory data), Salesforce (demand signals), planning tools (like Kinaxis)

### Portfolio Value
Demonstrates time-series domain expertise, stakeholder reporting (Looker), operational metrics (inventory turns, fill rates), and ROI modeling (working capital savings). Ideal for ops/supply-chain focused FDE tracks.

### Skills Required
| Skill ID | Skill Name |
|----------|------------|
| SK03 | Prompt Engineering and System Design |
| SK06 | Database Schema Design and Query Optimization |
| SK07 | Data Security and Privacy Compliance |
| SK13 | Agentic Workflows and Tool Use |
| SK14 | Semantic Search and Vector Store Optimization |
| SK15 | Real-time Integration and Event Streaming |
| SK20 | Cost Optimization and Resource Allocation |
| SK21 | Time Series Forecasting and Trend Analysis |

---

## P05 — Sales GTM Playbook and Automation

**Domain:** Sales / Go-To-Market  
**Primary track:** `ai-agents` (agents, automation, full-stack)  
**Skill IDs:** SK02, SK03, SK04, SK05, SK06, SK07, SK13, SK16, SK21, SK22, SK23  
**Tool IDs:** TL01, TL02, TL04, TL05, TL09, TL12, TL29, TL30, TL31, TL36, TL50  

### Business Problem
New sales hires take 6 months to ramp; deal cycles are inconsistent (30–180 days); best practices are tribal knowledge. Sales ops spend 15 hrs/week on manual data hygiene and email sequences.

### Solution Architecture
Design and ship a GTM automation system: parse historical deals (CRM), generate playbook templates via LLM (discovery questions, pitch angles, close tactics by deal stage), automate email sequences, identify bottleneck stages, and surface coaching recommendations to sales leadership.

### Tech Stack
Next.js, Python FastAPI, Mistral API, LangChain, Supabase, Stripe, SendGrid, Make

### Infrastructure
Frontend on Vercel, FastAPI backend on Fly.io or Railway, Postgres (via Supabase) for deal history and playbook templates, Stripe webhooks for customer lifecycle signals, SendGrid for templated email, Make for low-code CRM ↔ automation orchestration.

### Integration Targets
Salesforce (deal data, activity logs), Slack (deal alerts, bottleneck signals), LinkedIn Sales Navigator (prospect intel), email system (SendGrid)

### Portfolio Value
End-to-end product demo: playbook generation (LLM → templates), sales ops automation, and clear metric narrative (ramp time, deal velocity). Showcases business process understanding and product thinking.

### Skills Required
| Skill ID | Skill Name |
|----------|------------|
| SK02 | RAG Architecture Design |
| SK03 | Prompt Engineering and System Design |
| SK04 | API Design and Contract Management |
| SK05 | Full-Stack Application Development |
| SK06 | Database Schema Design and Query Optimization |
| SK07 | Data Security and Privacy Compliance |
| SK13 | Agentic Workflows and Tool Use |
| SK16 | Feature Engineering and Model Architecture |
| SK21 | Time Series Forecasting and Trend Analysis |
| SK22 | Experimentation and A/B Testing Frameworks |
| SK23 | Data Privacy and Compliance at Scale |

---

## P06 — Engineering Productivity AI Copilot

**Domain:** Software Engineering / Developer Tools  
**Primary track:** `ai-agents` (RAG, IDE integration, developer tools)  
**Skill IDs:** SK03, SK05, SK06, SK08, SK11, SK13, SK24, SK25, SK26  
**Tool IDs:** TL01, TL02, TL04, TL09, TL12, TL26, TL38, TL39, TL40  

### Business Problem
Engineers spend 30% of time on low-value tasks: writing boilerplate, debugging logs, refactoring old code. Code review cycles average 2 days. Test coverage is spotty (67%). IDE tooling is fragmented.

### Solution Architecture
Build an AI-powered copilot integrated into VS Code: ingest codebase context (Git history, architecture docs, tests), use fine-tuned LLM to suggest refactorings, auto-generate test cases, summarize PRs, and surface risky changes. Implement as Language Server Protocol (LSP) plugin.

### Tech Stack
TypeScript, LSP, Mistral API, LangChain, Tree-sitter, Git, GitHub Actions, Postgres, Docker

### Infrastructure
LSP server runs locally or in Docker container, communicates with VS Code extension via JSON-RPC, codebase indexed via Tree-sitter, embeddings stored locally (SQLite) or remote Postgres, fine-tuning via SFT on internal codebases, CI/CD via GitHub Actions.

### Integration Targets
GitHub (PR metadata, code review), Jira (task context), Slack (team alerts on risky PRs)

### Portfolio Value
Developer-tool narrative: demonstrates IDE/LSP protocol depth, fine-tuning workflows on proprietary data, and measurable velocity impact (code review time, test coverage). Strong for engineering-forward FDE tracks.

### Skills Required
| Skill ID | Skill Name |
|----------|------------|
| SK03 | Prompt Engineering and System Design |
| SK05 | Full-Stack Application Development |
| SK06 | Database Schema Design and Query Optimization |
| SK08 | Observability and Production Debugging |
| SK11 | Structured Output Extraction and Parsing |
| SK13 | Agentic Workflows and Tool Use |
| SK24 | IDE Integration and Developer UX |
| SK25 | Context Window Management and Prompt Optimization |
| SK26 | Codebase Indexing and Semantic Search |

---

## P07 — Field Service Optimization and Routing

**Domain:** Field Services / Operations  
**Primary track:** `software-engineer` (mobile, geospatial, routing)  
**Skill IDs:** SK03, SK06, SK07, SK13, SK17, SK18, SK27, SK28, SK29  
**Tool IDs:** TL04, TL06, TL12, TL23, TL41, TL42, TL43, TL49, TL52, TL13  

### Business Problem
Service dispatchers manually route 200+ technicians daily; average response time is 4 hours; travel time eats 35% of billable time. No predictive capability for demand spikes or technician churn.

### Solution Architecture
Real-time optimization engine: ingest service requests (priority, location, skills required), predict demand patterns via ML, solve vehicle routing problem (VRP) with time windows via OR-Tools, assign technicians with skill matching, and expose mobile app + dispatcher dashboard with re-optimization on new requests.

### Tech Stack
React Native, Node.js, Python, OR-Tools, Postgres, PostGIS, Redis, Google Maps API, Twilio, AWS EC2

### Infrastructure
Mobile app (React Native) for technician location updates, Node.js backend for real-time dispatch, Python microservice for VRP optimization (OR-Tools), PostGIS extension on Postgres for geo-queries, Redis for session state, Google Maps for routing and travel time matrices.

### Integration Targets
Dispatch system (request feed), CRM (technician profiles), mobile app (location, job completion), billing system (timesheets)

### Portfolio Value
Demonstrates operations research depth (VRP, constraint solving), mobile deployment, and direct productivity impact (travel time, response SLA). Ideal for ops optimization FDE roles.

### Skills Required
| Skill ID | Skill Name |
|----------|------------|
| SK03 | Prompt Engineering and System Design |
| SK06 | Database Schema Design and Query Optimization |
| SK07 | Data Security and Privacy Compliance |
| SK13 | Agentic Workflows and Tool Use |
| SK17 | Model Evaluation and Ablation Testing |
| SK18 | Feedback Loop Design and Active Learning |
| SK27 | Geospatial Data and Location Services |
| SK28 | Mobile App Integration and Real-time Sync |
| SK29 | HIPAA and Healthcare Compliance |

---

## P08 — Healthcare Patient Outcome Prediction

**Domain:** Healthcare / Clinical Operations  
**Primary track:** `ai-engineer` (clinical ML, compliance, healthcare)  
**Skill IDs:** SK03, SK08, SK09, SK11, SK13, SK17, SK18, SK30, SK31  
**Tool IDs:** TL01, TL02, TL05, TL20, TL23, TL24, TL28, TL37, TL44, TL45, TL46, TL04  

### Business Problem
Hospital readmission rates are 15% (costly); clinicians lack early warning signals for high-risk patients. EHR data is fragmented; predictive models are 2 years old. Need HIPAA-compliant, interpretable predictions.

### Solution Architecture
Build a HIPAA-compliant ML pipeline: ingest EHR data (labs, vitals, medications) via secure API, engineer features from unstructured clinical notes via NLP, train ensemble model (gradient boosting + LLM-based risk summarization), expose risk scores via secure dashboards with explainability (SHAP) and alert rules.

### Tech Stack
Python, FastAPI, XGBoost, spaCy, Postgres, HIPAA-compliant AWS (PrivateLink, encryption), Looker, Auth0

### Infrastructure
EHR data ingested via HL7 FHIR APIs into encrypted S3, processed via Lambda functions in private VPC, features stored in Postgres with column-level encryption, model inference via FastAPI on private EC2, dashboards via Looker with SSO (Auth0), audit logs for compliance.

### Integration Targets
EHR system (Epic, Cerner), alerting system (hospital pagers), patient portal

### Portfolio Value
Regulatory and compliance depth (HIPAA, audit trails, explainability), healthcare domain expertise, and high-stakes decision-making. Compelling for regulated-industry FDE roles.

### Skills Required
| Skill ID | Skill Name |
|----------|------------|
| SK03 | Prompt Engineering and System Design |
| SK08 | Observability and Production Debugging |
| SK09 | Cross-functional Stakeholder Engagement |
| SK11 | Structured Output Extraction and Parsing |
| SK13 | Agentic Workflows and Tool Use |
| SK17 | Model Evaluation and Ablation Testing |
| SK18 | Feedback Loop Design and Active Learning |
| SK30 | Voice/Audio Processing and Transcription |
| SK31 | Statistical Modeling and Causal Inference |

---

## P09 — Marketing Performance Attribution

**Domain:** Marketing / Analytics  
**Primary track:** `data-engineer` (analytics pipelines, attribution)  
**Skill IDs:** SK02, SK04, SK06, SK07, SK13, SK15, SK20, SK21, SK32, SK33  
**Tool IDs:** TL04, TL06, TL12, TL26, TL27, TL37, TL47, TL48, TL13  

### Business Problem
Marketing team spends $2M/year across channels (paid search, social, email, content, events) but cannot justify ROI; last-click attribution misses halo effects. Executives demand channel-level forecasts.

### Solution Architecture
Build a multi-touch attribution model: ingest customer journey data (touchpoints, conversions, revenue), apply probabilistic attribution (Shapley values), correlate with external signals (seasonality, competitor activity), expose via Looker dashboard with what-if scenario builder and budget optimization recommendations.

### Tech Stack
Python, Looker, Postgres, Snowflake, dbt, Google Analytics API, Salesforce API, Jupyter

### Infrastructure
ETL via dbt (Snowflake warehouse), customer journey joined with revenue data, attribution model (Shapley or time-decay) computed in Jupyter notebooks or Python UDFs, Looker for interactive dashboards, Google Analytics and Salesforce APIs for data ingestion.

### Integration Targets
Google Analytics, Meta/Facebook Ads, LinkedIn Campaign Manager, Salesforce (revenue), email platform (Marketo)

### Portfolio Value
Demonstrates analytics rigor (Shapley attribution), business metric storytelling, and marketing ops expertise. Strong for post-Series A / growth-stage FDE roles.

### Skills Required
| Skill ID | Skill Name |
|----------|------------|
| SK02 | RAG Architecture Design |
| SK04 | API Design and Contract Management |
| SK06 | Database Schema Design and Query Optimization |
| SK07 | Data Security and Privacy Compliance |
| SK13 | Agentic Workflows and Tool Use |
| SK15 | Real-time Integration and Event Streaming |
| SK20 | Cost Optimization and Resource Allocation |
| SK21 | Time Series Forecasting and Trend Analysis |
| SK32 | SK32 |
| SK33 | SK33 |

---

## P10 — Cinema Revenue Optimization and Pricing

**Domain:** Media & Entertainment / Cinema Operations  
**Primary track:** `ai-engineer` (forecasting, pricing, revenue)  
**Skill IDs:** SK02, SK03, SK04, SK06, SK07, SK14, SK20, SK21, SK22, SK34, SK35  
**Tool IDs:** TL01, TL02, TL04, TL05, TL09, TL12, TL23, TL26, TL29, TL43, TL08  

### Business Problem
Independent and chain cinemas use static pricing; they leave 15–25% revenue on the table. No dynamic pricing based on demand, competition, or audience mix. Seat inventory optimization is manual.

### Solution Architecture
Design a revenue management system: model demand via LLM-powered review/buzz analysis, competitor pricing scraping, and historical patterns, recommend optimal prices per showtime/seat-type via ML, optimize concession bundles, and expose real-time revenue dashboards + mobile ticketing integration.

### Tech Stack
Next.js, Python FastAPI, Mistral API, LangChain, Postgres, Redis, Stripe, Twilio, AWS Lambda

### Infrastructure
Nightly batch pricing optimization via Lambda (Mistral for buzz analysis, ML model for price recommendations), real-time availability and pricing served via Redis cache, Postgres for transaction log, Stripe for payment processing, mobile app integrates Twilio for OTP.

### Integration Targets
POS system (ticketing, concessions), payment processor (Stripe), cinema chain systems (inventory, showtimes)

### Portfolio Value
End-to-end domain deep-dive: demand forecasting, price optimization, and inventory management for specialized B2C use case. Personal relevance (cinema domain expertise) and clear revenue impact narrative.

### Skills Required
| Skill ID | Skill Name |
|----------|------------|
| SK02 | RAG Architecture Design |
| SK03 | Prompt Engineering and System Design |
| SK04 | API Design and Contract Management |
| SK06 | Database Schema Design and Query Optimization |
| SK07 | Data Security and Privacy Compliance |
| SK14 | Semantic Search and Vector Store Optimization |
| SK20 | Cost Optimization and Resource Allocation |
| SK21 | Time Series Forecasting and Trend Analysis |
| SK22 | Experimentation and A/B Testing Frameworks |
| SK34 | SK34 |
| SK35 | SK35 |

---
