# Track: GPU Monitoring & Remote Training

## Objective

Set up and operate a remote NVIDIA GPU machine for deep learning training. Build the workflow for pushing training scripts from an Ubuntu development machine to a Windows NVIDIA machine, monitoring GPU utilization, and pulling results back.

This track is shorter than the others — it's infrastructure, not a domain. Complete it early (Phase 2, weeks 5–7) so the GPU is available for AI Engineer track capstone work.

---

## Modules

### Phase 1 — Foundations

| # | Slug | Key Skills | Hours | Status |
|---|------|-----------|-------|--------|
| 01 | [01-cuda-setup](01-cuda-setup/) | CUDA toolkit, driver compat, Docker GPU passthrough, verify setup | 8 | ⏳ |
| 02 | [02-nvidia-smi-nvtop](02-nvidia-smi-nvtop/) | GPU monitoring commands, scripted alerts, utilization logging | 8 | ⏳ |

### Phase 2 — Core Modules

| # | Slug | Key Skills | Hours | Status |
|---|------|-----------|-------|--------|
| 03 | [03-remote-training-bridge](03-remote-training-bridge/) | SSH key auth, rsync workflows, remote PyTorch execution, VSCode Remote SSH | 12 | ⏳ |
| 04 | [04-training-dashboard](04-training-dashboard/) | Real-time training metrics, TensorBoard, wandb integration, live GPU stats | 12 | ⏳ |

### Phase 3 — Capstone

| Slug | Description | Hours | Status |
|------|-------------|-------|--------|
| [capstone-gpu-monitor](capstone-gpu-monitor/) | Typer-based CLI + web dashboard showing live GPU stats from remote machine | 30 | ⏳ |

---

## Job Market Mapping

From [`skill-matrix.md`](../../doc/research/skill-matrix.md):

| Skill | JD Frequency | Module |
|-------|------------|--------|
| PyTorch GPU training | **High** (for ML roles) | 01-cuda-setup, 03-remote-training-bridge |
| CUDA setup | **Medium** | 01-cuda-setup |
| Remote training workflows | **Medium** | 03-remote-training-bridge |
| GPU monitoring | **Medium** | 02-nvidia-smi-nvtop, 04-training-dashboard |

---

## Resources

1. [NVIDIA CUDA Installation Guide](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/) — Always check the driver compatibility matrix before installing
2. [NVIDIA Container Toolkit docs](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html) — GPU Docker passthrough
3. [VSCode Remote SSH docs](https://code.visualstudio.com/docs/remote/ssh) — The GPU bridge workflow

---

## Hardware Setup Reference

Full setup guide: [doc/environment/gpu-bridge.md](../../doc/environment/gpu-bridge.md)

Quick checklist:
- [ ] Windows machine has OpenSSH server installed and running
- [ ] SSH key auth works: `ssh gpu-machine` connects without password
- [ ] `nvidia-smi` works over SSH: `ssh gpu-machine "nvidia-smi"`
- [ ] CUDA toolkit installed on Windows machine
- [ ] rsync push/pull workflow tested
- [ ] VSCode Remote SSH connects to Windows machine

---

## Capstone

**`capstone-gpu-monitor` — Remote Training CLI + Monitoring Dashboard**

A Typer-based CLI for launching, monitoring, and retrieving results from remote training jobs. Includes a web dashboard showing live GPU utilization, memory, temperature, and loss/accuracy curves.

Full spec: [doc/roadmap/phase-3-capstones.md](../../doc/roadmap/phase-3-capstones.md#capstone-5-remote-gpu-training-cli-gpu-monitoring)
