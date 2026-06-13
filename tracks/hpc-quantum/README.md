# Track: HPC & Quantum Computing

## Objective

Gain introductory-to-intermediate exposure to High-Performance Computing (HPC) with Slurm and MPI, and to quantum computing with Qiskit. This track is a differentiator — it signals breadth and curiosity in a portfolio, and is genuinely useful for research-adjacent or compute-intensive ML work.

All skills in this track are P3 (differentiator tier). Complete after P1 and P2 tracks are solid.

---

## Modules

| # | Module | Key Skills | Status |
|---|--------|-----------|--------|
| 01 | [HPC Intro](01-hpc-intro/) | Slurm: sbatch, squeue, job arrays, resource requests, GPU partitions | ⏳ |
| 02 | [Quantum Intro](02-quantum-intro/) | Qiskit: circuits, gates, simulation, measurement, VQE basics | ⏳ |

---

## Job Market Mapping

From [`skill-matrix.md`](../../doc/research/skill-matrix.md):

| Skill | JD Frequency | Module |
|-------|------------|--------|
| Slurm | **Low** (niche, academic/research HPC) | 01-hpc-intro |
| MPI / mpi4py | **Low** | 01-hpc-intro |
| Qiskit | **Low** (emerging) | 02-quantum-intro |

These skills are **P3 — differentiators**. They appear in research labs, national labs, fintech quant roles, and quantum computing companies. They are rare enough that proficiency is a meaningful signal.

---

## Resources

1. [IBM Quantum Learning](https://quantum.cloud.ibm.com/learning) — Qiskit from zero, free labs on real quantum hardware
2. [NERSC Slurm tutorials](https://docs.nersc.gov/jobs/) — Real HPC center documentation, very practical
3. ["Quantum Computing: An Applied Approach"](https://www.springer.com/book/9783030832735) — Hidary — bridges math and code for quantum

---

## Context: Quantum + HPC Integration (2025)

As of 2025–2026, IBM has released Slurm plugins to manage quantum workloads with standard HPC schedulers. Qiskit Runtime provides low-latency quantum circuit execution orchestrated alongside classical HPC jobs. This is the frontier of hybrid quantum-classical computing — learning both Slurm and Qiskit positions you to work in this space.

---

## Capstone

**Module 02 extension — Hybrid Quantum-Classical Optimization**

Implement the Variational Quantum Eigensolver (VQE) for H2 molecular energy estimation, comparing quantum simulation vs classical approximation. Includes a Slurm job script for running on an HPC cluster. See [doc/roadmap/phase-3-capstones.md](../../doc/roadmap/phase-3-capstones.md#capstone-6-hybrid-quantum-classical-optimization-hpcquantum) for full spec.
