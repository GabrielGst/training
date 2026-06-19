# P0.1 — Setting up a local LLM using Ollama

**Domain:** AI Agents/ AI Engineer **Track:** `fde-extra` **Status:** started **Hours target:** 1

## Business Problem

Corporation and developpers struggle implementing AI because of the related heavy cost per token, as well as data privacy. One solution is to work offline, or on a local network, to keep data private, but that require using a local ai model. Ollama is an inference platform that can download models, but also handles quantization format, memory allocation, and GPU offloading automatically. Using Ollama to run LLMs locally answer three rationals : cost, privacy, offline.

## What you will build

- a chatbot with flexible models
- an offline coding assistant

## Architecture

```
User prompt (terminal / Python script)
        |
        v  HTTP REST on localhost:11434
 Ollama daemon (background service)
   ├── Model loading & memory management
   ├── GPU / CPU layer offloading
   └── Quantized weights  (~/.ollama/models)
        |
        v
 Response (streaming tokens or full JSON)
        |
        v
 Terminal output / Python application
```

## Skills covered

| Skill | What you practice |
| ----- | ----------------- |
| Local LLM inference | Installing and operating an inference runtime; pulling and managing quantized models |
| REST API consumption | Calling Ollama's HTTP API with `curl` and parsing JSON responses |
| Python LLM integration | Using the `ollama` Python SDK; streaming responses; listing models programmatically |
| Prompt engineering | System prompts, temperature, context window tuning, Modelfiles |
| Docker deployment | Containerising the Ollama service with GPU passthrough and Open WebUI |
| Performance optimisation | Choosing quantization levels; GPU offloading; memory and concurrency settings |
| Model evaluation | A/B testing multiple models on the same prompt with latency and token metrics |

## Tools & dependencies

| Tool | Version | Purpose | Install |
| ---- | ------- | ------- | ------- |
| Ollama | 0.13.x | Local LLM inference runtime | `curl -fsSL https://ollama.com/install.sh \| sh` |
| ollama (Python) | 0.6.2 | Python SDK for the Ollama API | `pip install ollama==0.6.2` |
| Python | 3.10+ | Chatbot and comparison scripts | pre-installed |
| curl | any | REST API testing (Step 4) | pre-installed |
| Docker | 24+ | Containerised deployment (Step 8) | `apt install docker.io` |

## Prerequisites

**Track modules to complete first:**
- Basic Python scripting (Steps 5, 6, 11)
- Terminal / shell basics (all steps)
- Docker fundamentals (Step 8 only — optional)

**System requirements:**
- 8 GB RAM minimum (for 7B–8B models)
- 12 GB free disk space
- macOS 12+, Ubuntu 20.04+, or Windows 10+

**Accounts / API keys needed:**
- None — Ollama runs entirely locally with no external API

## Step-by-step tutorial

### Step 1: Install Ollama on Your System

### Step 2: Pull and Run Your First Model

### Step 3: Explore the Model Library

### Step 4: Use the Ollama REST API

### Step 5: Integrate Ollama with Python

### Step 6: Build a Local Chatbot Application

### Step 7: Create Custom Models with Modelfiles

### Step 8: Deploy Ollama with Docker

### Step 9: Optimize Performance and Memory Usage

### Step 10: Set Up Ollama as a Development Tool

### Step 11: Run Multiple Models and A/B Test Responses

## Testing

## Deployment

## Resources

1. [Ollama GitHub](https://github.com/ollama/ollama) — source, issue tracker, and release notes
2. [Ollama model library](https://ollama.com/library) — all available models with pull counts and sizes
3. [Ollama REST API reference](https://github.com/ollama/ollama/blob/main/docs/api.md) — full endpoint documentation
4. [Ollama Python SDK](https://github.com/ollama/ollama-python) — source and examples for the `ollama` package
5. [Open WebUI](https://github.com/open-webui/open-webui) — the ChatGPT-like web UI used in Step 8

## Skill coverage mapping

| Step | Primary skill |
| ---- | ------------- |
| 1–3 | Local LLM inference |
| 4 | REST API consumption |
| 5 | Python LLM integration |
| 6 | Python LLM integration + prompt engineering |
| 7 | Prompt engineering (Modelfiles) |
| 8 | Docker deployment |
| 9 | Performance optimisation |
| 10 | Python LLM integration (dev tooling) |
| 11 | Model evaluation |
