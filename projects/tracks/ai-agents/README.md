# Track: AI Agents

## Objective

Build production-grade AI agent engineering skills: from LLM fundamentals to multi-agent orchestration with LangGraph, CrewAI, MCP tool use, and RAG. By the end of this track you can design, build, evaluate, and monitor a multi-agent system in production — and anchor that skill set in real FDE portfolio projects.

---

## Junior → Senior Progression

| Level | Can do |
|-------|--------|
| Junior | Prompt engineer effectively, build a LangChain Q&A bot with memory, implement basic RAG (chunk → embed → retrieve → generate) |
| Mid | Build stateful multi-step agents with LangGraph, integrate custom MCP tools, implement re-ranking and query rewriting for advanced RAG |
| Senior | Design multi-agent architectures (supervisor/worker patterns), implement eval harnesses (LLM-as-judge), optimize for cost/latency in production, handle safety and guardrails |

---

## Modules

### Phase 1 — Foundations

| # | Slug | Key Skills | Hours | Status |
|---|------|-----------|-------|--------|
| 01 | [01-llm-fundamentals](01-llm-fundamentals/) | Prompt engineering, token limits, system prompts, RAG concepts, eval | 12 | ⏳ |
| 02 | [02-langchain](02-langchain/) | Chains, memory, output parsers, callbacks, LCEL | 12 | ⏳ |

### Phase 2 — Core Modules

| # | Slug | Key Skills | Hours | Anchor Project | Status |
|---|------|-----------|-------|---------------|--------|
| 03 | [03-langgraph](03-langgraph/) | State graphs, nodes, edges, supervisor pattern, streaming, persistence | 15 | P02 Customer Support | ⏳ |
| 04 | [04-crewai](04-crewai/) | Agents, tasks, crews, custom tools, hierarchical process | 12 | P05 Sales GTM | ⏳ |
| 05 | [05-mcp-tool-use](05-mcp-tool-use/) | MCP protocol, custom MCP servers, tool schema design, Claude Desktop | 15 | P06 AI Copilot | ⏳ |
| 06 | [06-rag-advanced](06-rag-advanced/) | Reranking, hybrid search (BM25 + vector), chunking strategies, RAGAS eval | 12 | P01 VC Analyst | ⏳ |

### Phase 3 — Capstone

| Slug | Description | Hours | Status |
|------|-------------|-------|--------|
| [capstone-agent-system](capstone-agent-system/) | Multi-agent research assistant with memory, tools, RAG, Streamlit UI | 50 | ⏳ |

---

## FDE Portfolio Projects (anchored in this track)

| Project | Domain | Key Skills | Modules Required |
|---------|--------|-----------|-----------------|
| [P01 VC Analyst](../../doc/roadmap/projects/ai-projects.md#p01) | Venture Capital | SK02, SK03, SK04, SK05 | 01, 02, 06 |
| [P02 Customer Support](../../doc/roadmap/projects/ai-projects.md#p02) | Customer Support | SK02, SK03, SK13, SK15 | 01, 02, 03 |
| [P05 Sales GTM](../../doc/roadmap/projects/ai-projects.md#p05) | Sales / GTM | SK03, SK04, SK05, SK13 | 03, 04 |
| [P06 AI Copilot](../../doc/roadmap/projects/ai-projects.md#p06) | Developer Tools | SK03, SK25, SK26 | 05, 06 |

---

## Job Market Mapping

From [`skill-matrix.md`](../../doc/research/skill-matrix.md):

| Skill ID | Skill | JD Frequency | Tier | Module |
|----------|-------|------------|------|--------|
| SK03 | Prompt Engineering & System Design | **High** | P1 | 01-llm-fundamentals |
| SK02 | RAG Architecture Design | **High** | P1 | 02-langchain, 06-rag-advanced |
| SK13 | Agentic Workflows & Tool Use | **High** | P1 | 03-langgraph, 04-crewai, 05-mcp-tool-use |
| SK14 | Semantic Search & Vector Store Opt. | **High** | P1 | 06-rag-advanced |
| SK04 | API Design & Contract Management | **High** | P1 | 05-mcp-tool-use |
| SK08 | Observability & Production Debugging | **High** | P1 | capstone |
| SK25 | Context Window Management | **Medium** | P2 | 06-rag-advanced |

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

## Resources

1. [LangGraph documentation](https://langchain-ai.github.io/langgraph/) — Read end to end before building complex agents
2. [Anthropic MCP documentation](https://docs.anthropic.com) — Protocol spec + Claude API for tool use
3. [DeepLearning.AI short courses](https://www.deeplearning.ai/short-courses/) — Free courses on LangGraph, CrewAI, RAG
4. [RAGAS documentation](https://docs.ragas.io) — RAG evaluation framework used in Module 06

---

## Capstone

**`capstone-agent-system` — Multi-Agent Research Assistant**

A system that takes a research question, decomposes it into sub-tasks, assigns LangGraph agents, and produces a structured report with cited sources. MCP tools for web search and document reading. Streamlit UI. LangSmith tracing for observability.

Full spec: [doc/roadmap/phase-3-capstones.md](../../doc/roadmap/phase-3-capstones.md#capstone-4-multi-agent-research-assistant-ai-agents)
