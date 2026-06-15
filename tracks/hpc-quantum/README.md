# Track: HPC & Quantum Computing

## Objective

Gain introductory-to-intermediate exposure to High-Performance Computing (HPC) with Slurm and MPI, and to quantum computing with Qiskit. This track is a differentiator — it signals breadth and curiosity in a portfolio, and is genuinely useful for research-adjacent or compute-intensive ML work.

For FDE / Quantum specialization (Pasqal, IonQ, D-Wave roles), see the extended FDE/Quantum module catalog in [`doc/roadmap/modules.md`](../../doc/roadmap/modules.md#track-fde--quantum-quantum-field-deployment-engineering) and the full project catalog in [`doc/roadmap/projects/quantum-projects.md`](../../doc/roadmap/projects/quantum-projects.md).

All skills in this track are P3 (differentiator tier). Complete after P1 and P2 tracks are solid.

---

## Modules

### Phase 1 — Foundations

| # | Slug | Key Skills | Hours | Status |
|---|------|-----------|-------|--------|
| 01 | [01-hpc-intro](01-hpc-intro/) | Slurm: sbatch, squeue, job arrays, resource requests, GPU partitions | 15 | ⏳ |
| 02 | [02-quantum-intro](02-quantum-intro/) | Qiskit: circuits, gates, simulation, measurement, VQE basics, noise models | 15 | ⏳ |

### Phase 3 — Capstone

| Slug | Description | Hours | Status |
|------|-------------|-------|--------|
| [capstone-quantum-hpc](capstone-quantum-hpc/) | Hybrid quantum-classical optimization: Qiskit VQE + Python + Slurm on IBM Quantum | 40 | ⏳ |

---

## FDE / Quantum Extended Track

Once the foundations above are complete, the full FDE/Quantum curriculum covers 12 projects across 6 quantum hardware modalities. Entry point is `02-quantum-intro`.

| Phase | Modules | Projects |
|-------|---------|---------|
| Theory bootcamp | q-theory-01 → q-theory-06 (42h) | Prerequisite for all hardware tracks |
| Phase 2A: Superconducting | q-p01, q-p06, q-p08, q-p10 | VQE Drug Screening, Circuit Calibration, QML Anomaly, Tensor Networks |
| Phase 2B: Neutral-atom | q-theory-rydberg, q-p02 | Rydberg QAOA Logistics |
| Phase 2C: Photonic | q-theory-photonic, q-p03, q-p09 | Boson Sampling, Privacy-Preserving QC |
| Phase 2D: Trapped-ion | q-theory-trapped-ion, q-p04 | Portfolio Optimisation |
| Phase 2E: Annealing | q-theory-annealing, q-p05, q-p11 | Supply Chain, Cinema Pricing |
| Phase 2F: Post-quantum crypto | q-p07 | PQC Migration |
| Phase 3 capstone | q-p12 | Multi-modality Benchmark Portal |

Full module specs: [`doc/roadmap/modules.md`](../../doc/roadmap/modules.md)  
Full project specs: [`doc/roadmap/projects/quantum-projects.md`](../../doc/roadmap/projects/quantum-projects.md)

---

## Job Market Mapping

From [`skill-matrix.md`](../../doc/research/skill-matrix.md):

| Skill | JD Frequency | Module |
|-------|------------|--------|
| Slurm | **Low** (niche, academic/research HPC) | 01-hpc-intro |
| MPI / mpi4py | **Low** | 01-hpc-intro |
| Qiskit | **Low** (emerging) | 02-quantum-intro |
| Quantum concepts | **Low** | 02-quantum-intro |
| VQE / QAOA (FDE roles) | **Medium** (quantum companies) | q-p01, q-p02 |
| PQC / NIST standards | **Medium** (enterprise security) | q-p07 |

These skills are **P3 — differentiators**. They appear in research labs, national labs, fintech quant roles, and quantum computing companies.

---

## Resources

1. [IBM Quantum Learning](https://quantum.cloud.ibm.com/learning) — Qiskit from zero, free labs on real quantum hardware
2. [NERSC Slurm tutorials](https://docs.nersc.gov/jobs/) — Real HPC center documentation, very practical
3. ["Quantum Computing: An Applied Approach"](https://www.springer.com/book/9783030832735) — Hidary — bridges math and code for quantum
4. [Pasqal documentation](https://docs.pasqal.com) — Pulser SDK for neutral-atom / Rydberg hardware
5. [Qiskit Textbook](https://qiskit.org/learn) — Free textbook covering circuits through VQE

---

## Context: Quantum + HPC Integration (2025)

As of 2025–2026, IBM has released Slurm plugins to manage quantum workloads with standard HPC schedulers. Qiskit Runtime provides low-latency quantum circuit execution orchestrated alongside classical HPC jobs. This is the frontier of hybrid quantum-classical computing — learning both Slurm and Qiskit positions you to work in this space.

---

## Capstone

**`capstone-quantum-hpc` — Hybrid Quantum-Classical Optimization**

Implement the Variational Quantum Eigensolver (VQE) for H2 molecular energy estimation, comparing quantum simulation vs classical approximation. Includes a Slurm job script for running on an HPC cluster.

Full spec: [doc/roadmap/phase-3-capstones.md](../../doc/roadmap/phase-3-capstones.md#capstone-6-hybrid-quantum-classical-optimization-hpcquantum)
