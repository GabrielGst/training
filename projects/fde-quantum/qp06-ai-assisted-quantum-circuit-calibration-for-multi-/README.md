# QP06 — AI-Assisted Quantum Circuit Calibration for Multi-Qubit Gates

**Modality:** superconducting (Qiskit Pulse / IBM) **Phase:** 2A **Track:** `fde-quantum` **Status:** not started **Hours target:** 45

## Business Problem

Multi-qubit gate calibration on superconducting hardware is the single most time-consuming operational bottleneck in quantum computing. Two-qubit gate fidelities drift on timescales of hours due to charge noise, flux noise, and TLS defects. Re-calibrating a single cross-resonance (CR) gate currently requires hundreds of Rabi and randomised benchmarking experiments, occupying a physicist for days.

The goal is an AI-driven calibration loop: a reinforcement learning agent observes gate fidelity metrics from randomised benchmarking and adjusts Qiskit Pulse parameters (pulse amplitudes, durations, DRAG coefficients) autonomously — reaching target fidelity with 10x fewer experiments than grid search.

## What You Will Build

A closed-loop quantum calibration system that:

1. Defines a parameterised CR gate pulse schedule with Qiskit Pulse.
2. Implements a randomised benchmarking (RB) protocol using Qiskit Experiments to measure gate fidelity.
3. Trains a PyTorch reinforcement learning agent (PPO) via Stable Baselines3 to optimise pulse parameters based on RB fidelity feedback.
4. Uses Ray to parallelise RB experiment batches across multiple Qiskit Aer simulator workers.
5. Exposes a FastAPI `/calibrate` endpoint that accepts a target fidelity and returns the optimal pulse parameters.
6. Publishes gate fidelity metrics to Prometheus and visualises calibration progress in Grafana.
7. Runs inside Docker with PostgreSQL result persistence and GitHub Actions CI.

## Architecture

```
                ┌──────────────────────────────────────────────────┐
                │             FastAPI Service                        │
                │    POST /calibrate   GET /metrics                  │
                └────────────────────┬─────────────────────────────┘
                                     │
         ┌───────────────────────────▼──────────────────────────────┐
         │               Calibration Orchestrator                    │
         │                                                           │
┌────────▼──────────────┐          ┌──────────────────────────────┐ │
│  RL Agent (PyTorch)   │          │  Qiskit Pulse Schedule        │ │
│  PPO via SB3          │◄─reward──│  CR gate parameterisation     │ │
│  Action: pulse params  │──params─►│  Qiskit Aer simulation        │ │
└────────────────────────┘          └──────────────┬───────────────┘ │
         │                                          │                 │
         │                         ┌────────────────▼──────────────┐ │
         │                         │  Randomised Benchmarking (RB) │ │
         │                         │  Qiskit Experiments           │ │
         │                         │  Ray parallel execution        │ │
         │                         └────────────────┬──────────────┘ │
         │                                          │                 │
         └───────────────────────────◄──fidelity────┘                │
                                                                      │
         ┌──────────────────────────────────────────────────────────┐ │
         │              Observability Stack                          │◄┘
         │  Prometheus (metrics) → Grafana (dashboard)              │
         └──────────────────────────────────────────────────────────┘
                              │
                  ┌───────────▼──────────┐
                  │     PostgreSQL        │
                  │  (calibration runs,   │
                  │   fidelity history)   │
                  └──────────────────────┘
```

## Theory Prerequisites

| Skill ID | Concept | Why you need it |
|----------|---------|-----------------|
| SK01 | Quantum State Representation — Hilbert Spaces & Bra-Ket Notation | Foundation for understanding qubit evolution under pulse drives |
| SK02 | Quantum Measurement Theory — Born Rule | Interpreting RB measurement outcomes and computing fidelity from count statistics |
| SK03 | Quantum Decoherence & Relaxation — T1/T2, Lindblad Master Equation | Understanding why gate fidelity drifts and what limits calibration precision |
| SK04 | Quantum Gate Model & Universal Gate Sets | Knowing what a CR gate does unitarily before optimising its pulse implementation |
| SK05 | Complex Vector Spaces & Tensor Products | Multi-qubit system state representation in Qiskit Pulse simulation |
| SK06 | Eigendecomposition & Matrix Decompositions | Deriving gate unitary from pulse Hamiltonian via matrix exponentiation |
| SK09 | NISQ-Era Limitations & Error Mitigation | Understanding the noise regime the RL agent operates in and what residual errors remain after calibration |
| SK51 | Randomised Benchmarking Protocol Design | Designing valid RB sequences, extracting depolarising channel decay rate, and converting to average gate fidelity |

## Engineering Skills Covered

| Skill ID | Skill | What you practice |
|----------|-------|------------------|
| SK24 | ML for Quantum Error Mitigation | Using ML (RL) to drive calibration rather than physics intuition; post-processing noisy RB curves |
| SK25 | Hybrid Classical-Quantum Loops & Orchestration | Designing the RL agent → pulse schedule → simulation → RB fidelity → reward feedback loop |
| SK26 | PyTorch Production Patterns | Implementing the PPO agent with Stable Baselines3 + custom PyTorch policy network |
| SK27 | REST API Design & FastAPI | Building the `/calibrate` endpoint with background task execution |
| SK50 | Reinforcement Learning for Hardware Control | RL agent with continuous action space (pulse amplitude, duration, DRAG), reward = gate fidelity - penalty for experiment count |
| SK51 | Randomised Benchmarking Protocol Design | Implementing RB sequences, fitting exponential decay, computing EPC (error per Clifford) |
| SK52 | Distributed ML Training — Ray | Parallelising RB experiment batches across Ray workers to accelerate the calibration loop |
| SK53 | MLOps & Continuous Retraining | Triggering recalibration when Prometheus detects fidelity drift below threshold |
| SK54 | Prometheus/Grafana Monitoring | Publishing gate fidelity as Prometheus gauge; building Grafana dashboard for operations team |
| SK33 | SQL Data Modelling — PostgreSQL | Storing calibration run history, pulse parameters, and fidelity timeseries |
| SK34 | Container Orchestration — Docker | Packaging Qiskit Pulse + Ray + Prometheus stack |
| SK35 | CI/CD & GitHub Actions | Automated testing of pulse schedule construction and RB protocol |

## Tools & Dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| Qiskit | Gate model circuits, Clifford group for RB sequence generation | `pip install qiskit` |
| Qiskit Pulse | Low-level pulse programming for CR gate schedule definition | `pip install qiskit` (included) |
| Qiskit Aer | High-fidelity noise-model simulation of pulse schedules | `pip install qiskit-aer` |
| Qiskit Experiments | Randomised benchmarking protocol and fidelity extraction | `pip install qiskit-experiments` |
| PyTorch | Custom policy network for the PPO RL agent | `pip install torch` |
| Stable Baselines3 | PPO implementation with continuous action space | `pip install stable-baselines3` |
| Ray | Distributed RB experiment execution across simulator workers | `pip install ray[default]` |
| Prometheus | Gate fidelity metrics collection | `pip install prometheus-client` |
| Grafana | Fidelity dashboard visualisation | Docker image |
| FastAPI | REST API layer for calibration requests | `pip install fastapi uvicorn` |
| PostgreSQL | Calibration run persistence | `pip install psycopg2-binary sqlalchemy` |
| Docker | Full-stack containerisation | system install |
| JAX | Optional: Hamiltonian simulation for pulse-to-unitary conversion | `pip install jax[cpu]` |

## Prerequisites

**Complete these first:**
- [ ] SK01–SK04: Quantum state, measurement, decoherence, gate model — work through Qiskit textbook chapters 1–3
- [ ] SK09: NISQ limitations — read the `mitiq` documentation introduction
- [ ] SK51: Randomised benchmarking — read the Qiskit Experiments RB tutorial
- [ ] SK50: RL basics — complete the Stable Baselines3 getting-started guide with CartPole

**Access needed:**
- [ ] IBM Quantum account (optional for real hardware; Qiskit Aer covers simulation)
- [ ] Docker Desktop or Docker Engine for the Prometheus/Grafana stack
- [ ] 8 GB RAM minimum for Ray parallel simulation

---

## Step-by-Step Tutorial

### Step 1: Environment Setup

**Goal:** Install all dependencies and verify Qiskit Aer simulation works correctly.

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Fill in: DATABASE_URL, IBM_QUANTUM_TOKEN (optional)
```

```python
# src/check_setup.py
from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator
from qiskit_aer.noise import NoiseModel
from qiskit_ibm_runtime.fake_provider import FakeNairobi

def verify_aer_with_noise() -> dict:
    """Run a Bell state circuit on Aer with a realistic noise model."""
    backend = FakeNairobi()
    noise_model = NoiseModel.from_backend(backend)
    simulator = AerSimulator(noise_model=noise_model)

    qc = QuantumCircuit(2, 2)
    qc.h(0)
    qc.cx(0, 1)
    qc.measure_all()

    job = simulator.run(qc, shots=1024)
    counts = job.result().get_counts()
    total = sum(counts.values())
    return {
        "counts": counts,
        "fidelity_proxy": counts.get("00", 0) / total + counts.get("11", 0) / total,
    }

if __name__ == "__main__":
    result = verify_aer_with_noise()
    print(result)
```

**Verify:** Output shows `fidelity_proxy > 0.85` for a noiseless Bell state on FakeNairobi.

---

### Step 2: Theory Warm-Up — Cross-Resonance Gate and Pulse Programming

**Goal:** Build a parameterised cross-resonance (CR) pulse schedule with Qiskit Pulse and visualise it before hooking it to the RL agent.

```python
# src/pulse/cr_schedule.py
import numpy as np
from qiskit import pulse
from qiskit.pulse import Schedule, Play, DriveChannel, GaussianSquare
from qiskit_ibm_runtime.fake_provider import FakeNairobi

def build_cr_schedule(
    control_qubit: int,
    target_qubit: int,
    amplitude: float = 0.3,
    duration: int = 672,
    sigma: int = 64,
    risefall_sigma_ratio: float = 2.0,
    drag_coefficient: float = 0.0,
) -> Schedule:
    """
    Build a parameterised cross-resonance pulse schedule.

    The CR gate drives the control qubit's channel at the target qubit's
    resonance frequency. Key parameters:
      amplitude: pulse envelope peak amplitude [0,1]
      duration:  total pulse duration in dt units
      sigma:     Gaussian edge sigma in dt units
      drag_coefficient: DRAG correction to reduce leakage to |2>
    """
    backend = FakeNairobi()

    with pulse.build(backend=backend, name="cr_gate") as cr_sched:
        drive_ch = pulse.drive_channel(control_qubit)
        width = duration - 2 * int(risefall_sigma_ratio * sigma)
        if width < 0:
            raise ValueError(
                f"duration={duration} too short for sigma={sigma} and "
                f"risefall_sigma_ratio={risefall_sigma_ratio}"
            )
        cr_pulse = GaussianSquare(
            duration=duration,
            amp=amplitude,
            sigma=sigma,
            width=width,
        )
        pulse.play(cr_pulse, drive_ch)

    return cr_sched


def visualise_schedule(sched: Schedule) -> None:
    """Draw the schedule (requires matplotlib)."""
    sched.draw(backend=FakeNairobi())


if __name__ == "__main__":
    sched = build_cr_schedule(control_qubit=0, target_qubit=1, amplitude=0.25)
    print(f"Schedule duration: {sched.duration} dt")
    print(f"Instructions: {len(list(sched.instructions))}")
```

**Verify:** Schedule duration matches the `duration` parameter. `list(sched.instructions)` contains one `Play` instruction on the drive channel.

---

### Step 3: Randomised Benchmarking Protocol

**Goal:** Implement a 1Q and 2Q randomised benchmarking protocol using Qiskit Experiments to measure average gate fidelity.

```python
# src/benchmarking/rb_protocol.py
import numpy as np
from qiskit_aer import AerSimulator
from qiskit_aer.noise import NoiseModel
from qiskit_ibm_runtime.fake_provider import FakeNairobi
from qiskit_experiments.library import StandardRB


def run_standard_rb(
    qubit_indices: list[int],
    lengths: list[int],
    num_samples: int = 10,
    shots: int = 256,
) -> dict:
    """
    Run Standard Randomised Benchmarking and extract average gate fidelity.

    Args:
        qubit_indices: Qubit(s) to benchmark (1Q or 2Q)
        lengths: Clifford sequence lengths to sample
        num_samples: Number of random sequences per length
        shots: Shots per circuit

    Returns:
        dict with EPC (error per Clifford), gate fidelity, and fitted decay rate alpha
    """
    backend = FakeNairobi()
    noise_model = NoiseModel.from_backend(backend)
    simulator = AerSimulator(noise_model=noise_model)

    rb_exp = StandardRB(
        physical_qubits=qubit_indices,
        lengths=lengths,
        num_samples=num_samples,
        seed=42,
    )
    rb_data = rb_exp.run(simulator, shots=shots).block_for_results()

    analysis_result = rb_data.analysis_results("EPC")
    epc = analysis_result.value.nominal_value
    epc_err = analysis_result.value.std_dev
    gate_fidelity = 1.0 - epc

    return {
        "qubit_indices": qubit_indices,
        "epc": epc,
        "epc_stderr": epc_err,
        "gate_fidelity": gate_fidelity,
        "clifford_lengths": lengths,
    }


if __name__ == "__main__":
    result = run_standard_rb(
        qubit_indices=[0],
        lengths=[1, 10, 20, 50, 100, 200],
    )
    print(f"1Q gate fidelity: {result['gate_fidelity']:.4f}")
    print(f"EPC: {result['epc']:.6f} ± {result['epc_stderr']:.6f}")
```

**Verify:** 1Q gate fidelity is in (0.95, 1.0) on FakeNairobi. EPC is positive and below 0.05.

---

### Step 4: RL Environment — Calibration Gym

**Goal:** Wrap the Qiskit Pulse + RB protocol as a Gymnasium environment for the PPO agent.

```python
# src/rl/calibration_env.py
import numpy as np
import gymnasium as gym
from gymnasium import spaces
from src.pulse.cr_schedule import build_cr_schedule
from src.benchmarking.rb_protocol import run_standard_rb


class CalibrationEnv(gym.Env):
    """
    Gymnasium environment for quantum gate calibration via RL.

    Observation: [current_amplitude, current_duration_normalised,
                  current_drag, last_gate_fidelity, step_count_normalised]
    Action:      continuous delta in [amplitude, duration, drag_coefficient]
    Reward:      gate_fidelity - penalty * num_rb_circuits
    Episode ends when fidelity >= target_fidelity or max_steps reached.
    """

    metadata = {"render_modes": []}

    def __init__(
        self,
        target_fidelity: float = 0.999,
        max_steps: int = 50,
        rb_lengths: list[int] = None,
    ):
        super().__init__()
        self.target_fidelity = target_fidelity
        self.max_steps = max_steps
        self.rb_lengths = rb_lengths or [1, 10, 50, 100]

        # Pulse parameter bounds
        self._amp_bounds = (0.05, 0.95)
        self._dur_bounds = (160, 1280)  # dt units
        self._drag_bounds = (-2.0, 2.0)

        # Observation: [amp, dur_norm, drag_norm, fidelity, step_norm]
        self.observation_space = spaces.Box(
            low=np.array([0.0, 0.0, 0.0, 0.0, 0.0], dtype=np.float32),
            high=np.array([1.0, 1.0, 1.0, 1.0, 1.0], dtype=np.float32),
        )
        # Action: delta for [amplitude, duration, drag]
        self.action_space = spaces.Box(
            low=np.array([-0.05, -64.0, -0.2], dtype=np.float32),
            high=np.array([0.05, 64.0, 0.2], dtype=np.float32),
        )

        self._reset_params()

    def _reset_params(self):
        self._amplitude = 0.3
        self._duration = 672
        self._drag = 0.0
        self._fidelity = 0.0
        self._step = 0

    def _obs(self) -> np.ndarray:
        amp_norm = (self._amplitude - self._amp_bounds[0]) / (
            self._amp_bounds[1] - self._amp_bounds[0]
        )
        dur_norm = (self._duration - self._dur_bounds[0]) / (
            self._dur_bounds[1] - self._dur_bounds[0]
        )
        drag_norm = (self._drag - self._drag_bounds[0]) / (
            self._drag_bounds[1] - self._drag_bounds[0]
        )
        return np.array(
            [amp_norm, dur_norm, drag_norm, self._fidelity,
             self._step / self.max_steps],
            dtype=np.float32,
        )

    def reset(self, seed=None, options=None):
        super().reset(seed=seed)
        self._reset_params()
        # Random initialisation within safe range
        self._amplitude = float(self.np_random.uniform(0.15, 0.45))
        return self._obs(), {}

    def step(self, action: np.ndarray):
        # Apply action deltas with clipping
        self._amplitude = np.clip(
            self._amplitude + action[0], *self._amp_bounds
        )
        self._duration = int(np.clip(
            self._duration + action[1], *self._dur_bounds
        ))
        self._drag = np.clip(self._drag + action[2], *self._drag_bounds)
        self._step += 1

        # Measure fidelity via RB
        try:
            rb_result = run_standard_rb(
                qubit_indices=[0],
                lengths=self.rb_lengths,
                num_samples=5,
                shots=128,
            )
            self._fidelity = rb_result["gate_fidelity"]
        except Exception:
            self._fidelity = 0.0

        experiment_cost = len(self.rb_lengths) * 5 * 128  # total shots used
        reward = self._fidelity - 1e-7 * experiment_cost

        terminated = self._fidelity >= self.target_fidelity
        truncated = self._step >= self.max_steps

        return self._obs(), reward, terminated, truncated, {
            "fidelity": self._fidelity,
            "amplitude": self._amplitude,
            "duration": self._duration,
            "drag": self._drag,
        }
```

**Verify:** `env = CalibrationEnv(); obs, _ = env.reset(); obs2, r, done, _, info = env.step(env.action_space.sample())` completes without error. `info["fidelity"]` is in (0, 1).

---

### Step 5: Train the PPO Agent with Stable Baselines3

**Goal:** Train the RL calibration agent and save the best-performing policy.

```python
# src/rl/train_agent.py
import os
from stable_baselines3 import PPO
from stable_baselines3.common.env_util import make_vec_env
from stable_baselines3.common.callbacks import EvalCallback, CheckpointCallback
from src.rl.calibration_env import CalibrationEnv


def train_calibration_agent(
    total_timesteps: int = 50_000,
    n_envs: int = 4,
    save_path: str = "models/ppo_calibration",
) -> PPO:
    """
    Train a PPO agent to calibrate quantum gate pulse parameters.

    Args:
        total_timesteps: Total environment steps for training
        n_envs: Number of parallel calibration environments (Ray workers in prod)
        save_path: Directory to save checkpoints and final model

    Returns:
        Trained PPO model
    """
    os.makedirs(save_path, exist_ok=True)

    vec_env = make_vec_env(CalibrationEnv, n_envs=n_envs)

    model = PPO(
        policy="MlpPolicy",
        env=vec_env,
        learning_rate=3e-4,
        n_steps=256,
        batch_size=64,
        n_epochs=10,
        gamma=0.99,
        gae_lambda=0.95,
        clip_range=0.2,
        ent_coef=0.01,
        verbose=1,
        tensorboard_log=f"{save_path}/tb_logs/",
    )

    eval_env = CalibrationEnv()
    eval_callback = EvalCallback(
        eval_env,
        best_model_save_path=f"{save_path}/best/",
        log_path=f"{save_path}/eval_logs/",
        eval_freq=2000,
        n_eval_episodes=5,
        deterministic=True,
    )
    checkpoint_callback = CheckpointCallback(
        save_freq=5000,
        save_path=f"{save_path}/checkpoints/",
    )

    model.learn(
        total_timesteps=total_timesteps,
        callback=[eval_callback, checkpoint_callback],
    )
    model.save(f"{save_path}/final_model")
    return model


def load_and_evaluate(model_path: str) -> dict:
    """Load a saved PPO model and run one calibration episode."""
    model = PPO.load(model_path)
    env = CalibrationEnv()
    obs, _ = env.reset()

    episode_fidelities = []
    for _ in range(env.max_steps):
        action, _ = model.predict(obs, deterministic=True)
        obs, reward, done, truncated, info = env.step(action)
        episode_fidelities.append(info["fidelity"])
        if done or truncated:
            break

    return {
        "final_fidelity": episode_fidelities[-1],
        "max_fidelity": max(episode_fidelities),
        "steps_to_converge": len(episode_fidelities),
        "best_amplitude": info["amplitude"],
        "best_duration": info["duration"],
        "best_drag": info["drag"],
    }


if __name__ == "__main__":
    model = train_calibration_agent(total_timesteps=20_000)
    result = load_and_evaluate("models/ppo_calibration/final_model")
    print(result)
```

**Verify:** Training completes without error. `load_and_evaluate` returns `final_fidelity > 0.97` after 50k timesteps on the Aer simulator.

---

### Step 6: Ray Distributed Benchmarking

**Goal:** Use Ray to parallelise RB experiment batches across multiple workers to reduce wall-clock calibration time.

```python
# src/benchmarking/distributed_rb.py
import ray
import numpy as np
from src.benchmarking.rb_protocol import run_standard_rb


@ray.remote
def rb_worker(
    qubit_indices: list[int],
    lengths: list[int],
    num_samples: int,
    shots: int,
    seed: int,
) -> dict:
    """Ray remote task: run RB experiment and return fidelity metrics."""
    import random
    random.seed(seed)
    return run_standard_rb(
        qubit_indices=qubit_indices,
        lengths=lengths,
        num_samples=num_samples,
        shots=shots,
    )


def parallel_rb_sweep(
    qubit_indices: list[int],
    lengths: list[int],
    num_parallel: int = 4,
    shots_per_worker: int = 256,
) -> dict:
    """
    Run RB across num_parallel workers and aggregate results.

    Each worker runs an independent RB experiment. The aggregate fidelity
    is a weighted average of per-worker estimates.
    """
    ray.init(ignore_reinit_error=True)

    futures = [
        rb_worker.remote(
            qubit_indices=qubit_indices,
            lengths=lengths,
            num_samples=10,
            shots=shots_per_worker,
            seed=i,
        )
        for i in range(num_parallel)
    ]
    results = ray.get(futures)

    fidelities = [r["gate_fidelity"] for r in results]
    epcs = [r["epc"] for r in results]

    return {
        "mean_gate_fidelity": float(np.mean(fidelities)),
        "std_gate_fidelity": float(np.std(fidelities)),
        "mean_epc": float(np.mean(epcs)),
        "num_workers": num_parallel,
        "per_worker_results": results,
    }


if __name__ == "__main__":
    result = parallel_rb_sweep(
        qubit_indices=[0],
        lengths=[1, 10, 50, 100, 200],
        num_parallel=2,
    )
    print(f"Mean fidelity: {result['mean_gate_fidelity']:.4f} "
          f"± {result['std_gate_fidelity']:.5f}")
```

**Verify:** `parallel_rb_sweep` completes in less time than 4x serial RB. `mean_gate_fidelity` is consistent with the serial `run_standard_rb` result (within 2 standard deviations).

---

### Step 7: Prometheus Metrics Integration

**Goal:** Publish gate fidelity, calibration episode count, and pulse parameters as Prometheus metrics.

```python
# src/monitoring/metrics.py
from prometheus_client import Gauge, Counter, start_http_server
import time

# Define metrics
GATE_FIDELITY = Gauge(
    "quantum_gate_fidelity",
    "Current measured gate fidelity from RB protocol",
    ["qubit_pair", "gate_type"],
)
EPC = Gauge(
    "quantum_epc",
    "Error per Clifford from randomised benchmarking",
    ["qubit_pair"],
)
CALIBRATION_EPISODES = Counter(
    "calibration_episodes_total",
    "Total number of RL calibration episodes completed",
)
PULSE_AMPLITUDE = Gauge(
    "pulse_amplitude",
    "Current CR gate pulse amplitude",
    ["control_qubit"],
)
PULSE_DURATION = Gauge(
    "pulse_duration_dt",
    "Current CR gate pulse duration in dt units",
    ["control_qubit"],
)


def publish_calibration_result(
    qubit_pair: str,
    gate_fidelity: float,
    epc: float,
    amplitude: float,
    duration: int,
    control_qubit: int,
) -> None:
    """Update Prometheus gauges with latest calibration result."""
    GATE_FIDELITY.labels(qubit_pair=qubit_pair, gate_type="CR").set(gate_fidelity)
    EPC.labels(qubit_pair=qubit_pair).set(epc)
    CALIBRATION_EPISODES.inc()
    PULSE_AMPLITUDE.labels(control_qubit=str(control_qubit)).set(amplitude)
    PULSE_DURATION.labels(control_qubit=str(control_qubit)).set(duration)


def start_metrics_server(port: int = 9090) -> None:
    """Start Prometheus HTTP metrics server."""
    start_http_server(port)
    print(f"Metrics server running on :{port}/metrics")
```

**Verify:** `start_metrics_server()` followed by `publish_calibration_result(...)` results in `curl http://localhost:9090/metrics` returning lines like `quantum_gate_fidelity{gate_type="CR",qubit_pair="0_1"} 0.9987`.

---

### Step 8: FastAPI Calibration Endpoint

**Goal:** Expose the full calibration pipeline as an async FastAPI service with background task execution.

```python
# src/api/main.py
import os
import uuid
from fastapi import FastAPI, BackgroundTasks, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from src.monitoring.metrics import publish_calibration_result, start_metrics_server

app = FastAPI(
    title="Quantum Calibration API",
    description="AI-assisted quantum gate calibration via RL + randomised benchmarking",
    version="1.0.0",
)

# In-memory job store (replace with PostgreSQL in production)
_jobs: dict[str, dict] = {}


class CalibrateRequest(BaseModel):
    control_qubit: int = Field(ge=0, le=4)
    target_qubit: int = Field(ge=0, le=4)
    target_fidelity: float = Field(ge=0.9, le=0.9999, default=0.999)
    max_steps: int = Field(ge=5, le=200, default=50)


class CalibrateResponse(BaseModel):
    job_id: str
    status: str
    message: str


def _run_calibration_job(job_id: str, request: CalibrateRequest) -> None:
    """Background calibration task: runs RL agent and updates job store."""
    from src.rl.train_agent import load_and_evaluate
    from src.rl.calibration_env import CalibrationEnv

    _jobs[job_id]["status"] = "running"
    try:
        model_path = os.environ.get(
            "CALIBRATION_MODEL_PATH", "models/ppo_calibration/final_model"
        )
        result = load_and_evaluate(model_path)
        publish_calibration_result(
            qubit_pair=f"{request.control_qubit}_{request.target_qubit}",
            gate_fidelity=result["final_fidelity"],
            epc=1.0 - result["final_fidelity"],
            amplitude=result["best_amplitude"],
            duration=result["best_duration"],
            control_qubit=request.control_qubit,
        )
        _jobs[job_id].update({"status": "completed", "result": result})
    except Exception as exc:
        _jobs[job_id].update({"status": "failed", "error": str(exc)})


@app.on_event("startup")
async def startup():
    start_metrics_server(port=9090)


@app.post("/calibrate", response_model=CalibrateResponse)
async def calibrate(
    request: CalibrateRequest, background_tasks: BackgroundTasks
) -> CalibrateResponse:
    """
    Submit a gate calibration job.

    Launches the RL calibration agent in a background task. Poll /jobs/{job_id}
    for results.
    """
    if request.control_qubit == request.target_qubit:
        raise HTTPException(
            status_code=422, detail="control_qubit and target_qubit must differ"
        )
    job_id = str(uuid.uuid4())
    _jobs[job_id] = {"status": "queued", "request": request.dict()}
    background_tasks.add_task(_run_calibration_job, job_id, request)
    return CalibrateResponse(
        job_id=job_id,
        status="queued",
        message=f"Calibration job {job_id} queued. Poll /jobs/{job_id} for results.",
    )


@app.get("/jobs/{job_id}")
async def get_job(job_id: str) -> JSONResponse:
    """Retrieve calibration job status and result."""
    if job_id not in _jobs:
        raise HTTPException(status_code=404, detail="Job not found")
    return JSONResponse(content=_jobs[job_id])


@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}
```

**Verify:** `uvicorn src.api.main:app --reload` starts. `POST /calibrate` with `{"control_qubit": 0, "target_qubit": 1, "target_fidelity": 0.99}` returns 200 with a `job_id`. Polling `GET /jobs/{job_id}` eventually shows `"status": "completed"`.

---

### Step 9: Grafana Dashboard Setup

**Goal:** Configure a Grafana dashboard showing gate fidelity over time, EPC, and calibration episode counts.

```yaml
# docker/grafana/provisioning/dashboards/calibration.json
# (abbreviated — full dashboard JSON in docs/grafana/)
# Key panels:
# 1. Gate Fidelity Gauge: quantum_gate_fidelity{gate_type="CR"}
# 2. EPC Time Series: quantum_epc[1h]
# 3. Calibration Episodes Counter: rate(calibration_episodes_total[5m])
# 4. Pulse Amplitude: pulse_amplitude
# 5. Alert rule: gate_fidelity < 0.99 → page on-call
```

```yaml
# docker-compose.yml (observability services)
version: "3.9"
services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./docker/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9091:9090"

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
    volumes:
      - ./docker/grafana/provisioning:/etc/grafana/provisioning
    depends_on:
      - prometheus
```

**Verify:** `docker compose up prometheus grafana` starts. Navigate to `http://localhost:3000` and log in (admin/admin). Import the provisioned dashboard and confirm the `quantum_gate_fidelity` panel populates after triggering a calibration job.

---

### Step 10: Monitoring and CI/CD

**Goal:** Add GitHub Actions CI with Aer simulation tests and a full docker-compose stack.

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_DB: calibration
        ports:
          - "5432:5432"
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install -r requirements.txt
      - run: pytest tests/ -v --tb=short -x
        env:
          DATABASE_URL: postgresql://postgres:test@localhost:5432/calibration
          IBM_QUANTUM_TOKEN: ${{ secrets.IBM_QUANTUM_TOKEN }}
```

**Verify:** CI passes on a fresh push. The RB protocol test (`tests/unit/test_rb_protocol.py`) completes in under 60 seconds on the Aer simulator.

---

## Testing

```bash
# Unit tests
pytest tests/unit/test_cr_schedule.py -v      # Pulse schedule construction
pytest tests/unit/test_rb_protocol.py -v      # RB fidelity extraction
pytest tests/unit/test_calibration_env.py -v  # Gym environment step/reset

# Integration tests
pytest tests/integration/test_api.py -v       # FastAPI endpoint flow
pytest tests/integration/test_ray_rb.py -v    # Ray distributed benchmarking

# RL training smoke test (short)
python src/rl/train_agent.py --timesteps 1000
```

Key test cases:
- `build_cr_schedule` raises `ValueError` when duration is too short for the given sigma
- `run_standard_rb([0], [1,10,50])` returns `gate_fidelity > 0.90` on FakeNairobi
- `CalibrationEnv` observation is always within `observation_space` bounds
- `POST /calibrate` with equal `control_qubit` and `target_qubit` returns 422
- Prometheus metrics endpoint returns valid Prometheus text format

---

## Deployment

```bash
# Build and start the full stack
docker compose up --build -d

# Train the RL agent (one-time, before serving)
docker compose exec api python src/rl/train_agent.py

# Check Grafana dashboard
open http://localhost:3000

# Check Prometheus metrics
curl http://localhost:9090/metrics | grep quantum_
```

---

## Resources

1. [Qiskit Pulse Documentation](https://qiskit.org/documentation/apidoc/pulse.html) — Pulse schedule API and channel model
2. [Qiskit Experiments — Randomised Benchmarking](https://qiskit-extensions.github.io/qiskit-experiments/manuals/verification/randomized_benchmarking.html) — RB tutorial and fidelity extraction
3. [Stable Baselines3 Documentation](https://stable-baselines3.readthedocs.io/) — PPO implementation and custom environments
4. [Ray Documentation](https://docs.ray.io/en/latest/) — Distributed computing and RLlib
5. [Prometheus Python Client](https://github.com/prometheus/client_python) — Gauge, Counter, and histogram instrumentation
6. [Grafana Dashboard Provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/) — Automated dashboard setup
7. [McKay et al. (2017) — Efficient Z gates for quantum computing](https://arxiv.org/abs/1612.00858) — DRAG pulse theory
8. [Magesan et al. (2011) — Scalable and Robust Randomized Benchmarking of Quantum Processes](https://arxiv.org/abs/1009.3639) — RB theory and EPC derivation
