# Track: AI Agents

## Objective

Build production-grade AI agent engineering skills: from LLM fundamentals to multi-agent orchestration with LangGraph, CrewAI, MCP tool use, and RAG. By the end of this track, you can design, build, evaluate, and monitor a multi-agent system in production.

---

## Junior → Senior Progression

| Level | Can do |
|-------|--------|
| Junior | Prompt engineer effectively, build a LangChain Q&A bot with memory, implement basic RAG (chunk → embed → retrieve → generate) |
| Mid | Build stateful multi-step agents with LangGraph, integrate custom MCP tools, implement re-ranking and query rewriting for advanced RAG |
| Senior | Design multi-agent architectures (supervisor/worker patterns), implement eval harnesses (LLM-as-judge), optimize for cost/latency in production, handle safety and guardrails |

---

## Modules

| # | Module | Key Skills | Status |
|---|--------|-----------|--------|
| 01 | [LLM Fundamentals](01-llm-fundamentals/) | Prompt engineering, token limits, system prompts, RAG concepts, eval | ⏳ |
| 02 | [LangChain](02-langchain/) | Chains, memory, output parsers, callbacks, LangSmith | ⏳ |
| 03 | [LangGraph](03-langgraph/) | State graphs, nodes, edges, supervisor pattern, streaming, persistence | ⏳ |
| 04 | [CrewAI](04-crewai/) | Agents, tasks, crews, custom tools, hierarchical process | ⏳ |
| 05 | [MCP Tool Use](05-mcp-tool-use/) | MCP protocol, custom MCP servers, tool schema design | ⏳ |
| 06 | [Capstone: Agent System](06-capstone-agent-system/) | Multi-agent research assistant, deployed | ⏳ |

---

## Job Market Mapping

From [`skill-matrix.md`](../../doc/research/skill-matrix.md):

| Skill | JD Frequency | This Track Module |
|-------|------------|-------------------|
| LLM fundamentals | **High** | 01-llm-fundamentals |
| LangChain | **High** | 02-langchain |
| LangGraph | **High** (leading 2025–26) | 03-langgraph |
| MCP | **High** (2026 hiring checklist) | 05-mcp-tool-use |
| RAG design | **High** | 01-llm-fundamentals, 02-langchain |
| CrewAI | **Medium** | 04-crewai |
| Vector databases | **High** | 02-langchain, 03-langgraph |
| Agent evaluation | **Medium** | 06-capstone |

---

## Resources

1. [LangGraph documentation](https://langchain-ai.github.io/langgraph/) — Read end to end before building complex agents
2. [Anthropic MCP documentation](https://docs.anthropic.com) — Protocol spec + Claude API for tool use
3. [DeepLearning.AI short courses](https://www.deeplearning.ai/short-courses/) — Free courses on LangGraph, CrewAI, RAG

---

## Key Concepts

**When NOT to use an agent (critical for senior-level thinking):**
- When a deterministic function or a single LLM call would suffice
- When latency is critical and you can't afford multi-hop reasoning
- When the task has a well-defined schema (use structured output, not an agent)

**Agent patterns this track covers:**
- ReAct (reason + act loop)
- Supervisor + worker pattern
- Parallel agents with reducer
- Human-in-the-loop with interrupt

---

## Capstone

**Module 06 — Multi-Agent Research Assistant**

A system that takes a research question, decomposes it into sub-tasks, assigns LangGraph agents, and produces a structured report with cited sources. MCP tools for web search and document reading. Streamlit UI. LangSmith tracing for observability. See [doc/roadmap/phase-3-capstones.md](../../doc/roadmap/phase-3-capstones.md#capstone-4-multi-agent-research-assistant-ai-agents) for full spec.
