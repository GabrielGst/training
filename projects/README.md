# Projects

Standalone FDE portfolio projects, initialized from the project catalog in [`doc/roadmap/projects/`](../doc/roadmap/projects/).

Each directory has: `README.md` · `CASE_STUDY.md` · `src/` · `tests/` · `docs/architecture.md` · `.env.example`

---

## FDE / AI Projects (`fde-ai/`)

| ID | Directory | Track | Status |
|----|-----------|-------|--------|
| P01 | [p01-vc-due-diligence-ai-analyst](fde-ai/p01-vc-due-diligence-ai-analyst/) | ai-agents | ⏳ |
| P02 | [p02-customer-support-multimodal-triage](fde-ai/p02-customer-support-multimodal-triage/) | ai-agents | ⏳ |
| P03 | [p03-fintech-fraud-detection-real-time](fde-ai/p03-fintech-fraud-detection-real-time/) | ai-engineer | ⏳ |
| P04 | [p04-supply-chain-demand-forecasting](fde-ai/p04-supply-chain-demand-forecasting/) | ai-engineer | ⏳ |
| P05 | [p05-sales-gtm-playbook-and-automation](fde-ai/p05-sales-gtm-playbook-and-automation/) | ai-agents | ⏳ |
| P06 | [p06-engineering-productivity-ai-copilot](fde-ai/p06-engineering-productivity-ai-copilot/) | ai-agents | ⏳ |
| P07 | [p07-field-service-optimization-and-routing](fde-ai/p07-field-service-optimization-and-routing/) | software-engineer | ⏳ |
| P08 | [p08-healthcare-patient-outcome-prediction](fde-ai/p08-healthcare-patient-outcome-prediction/) | ai-engineer | ⏳ |
| P09 | [p09-marketing-performance-attribution](fde-ai/p09-marketing-performance-attribution/) | data-engineer | ⏳ |
| P10 | [p10-cinema-revenue-optimization-and-pricing](fde-ai/p10-cinema-revenue-optimization-and-pricing/) | ai-engineer | ⏳ |

---

## FDE / Quantum Projects (`fde-quantum/`)

| ID | Directory | Modality | Status |
|----|-----------|----------|--------|
| QP01 | [qp01-…-vqe](fde-quantum/qp01-quantum-enhanced-drug-molecule-screening-via-vqe/) | superconducting | ⏳ |
| QP02 | [qp02-…-qaoa-logistics](fde-quantum/qp02-rydberg-neutral-atom-qaoa-for-logistics-route-opti/) | neutral-atom | ⏳ |
| QP03 | [qp03-…-boson-sampling](fde-quantum/qp03-photonic-quantum-sampling-for-materials-discovery-/) | photonic | ⏳ |
| QP04 | [qp04-…-portfolio](fde-quantum/qp04-trapped-ion-quantum-simulation-for-financial-portf/) | trapped-ion | ⏳ |
| QP05 | [qp05-…-d-wave](fde-quantum/qp05-d-wave-annealing-ml-for-supply-chain-disruption-pr/) | annealing | ⏳ |
| QP06 | [qp06-…-calibration](fde-quantum/qp06-ai-assisted-quantum-circuit-calibration-for-multi-/) | superconducting | ⏳ |
| QP07 | [qp07-…-pqc](fde-quantum/qp07-post-quantum-cryptography-migration-with-ai-powere/) | classical-only | ⏳ |
| QP08 | [qp08-…-qml](fde-quantum/qp08-variational-quantum-classifier-for-anomaly-detecti/) | superconducting | ⏳ |
| QP09 | [qp09-…-sdqc](fde-quantum/qp09-secure-delegated-quantum-computation-sdqc-for-priv/) | photonic | ⏳ |
| QP10 | [qp10-…-tensor-networks](fde-quantum/qp10-tensor-network-classical-simulation-ml-for-quantum/) | superconducting | ⏳ |
| QP11 | [qp11-…-cinema](fde-quantum/qp11-cinema-demand-forecasting-dynamic-pricing-with-qua/) | annealing | ⏳ |
| QP12 | [qp12-…-benchmark](fde-quantum/qp12-multi-modality-quantum-benchmark-aggregator-llm-po/) | classical-only | ⏳ |

---

## Working on a project

```bash
# Start a specific project
./scripts/new-project.sh --id P01

# Re-scaffold all (idempotent — skips existing)
./scripts/new-project.sh --all
```

Full project specs: [`doc/roadmap/projects/`](../doc/roadmap/projects/)  
Skill-project bridge: [`doc/roadmap/bridge.md`](../doc/roadmap/bridge.md)

---

## Promotion criteria (track capstones → this folder)

A track capstone is promoted here when:
- Complete self-contained README (setup → run → test)
- `CASE_STUDY.md` written
- Deployed (live URL or reproducible demo script)
- CI passes (lint + tests green)
- Peer-reviewed by at least one person
