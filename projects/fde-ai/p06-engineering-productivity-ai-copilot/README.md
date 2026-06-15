# P06 — Engineering Productivity AI Copilot

**Domain:** Software Engineering / Developer Tools  **Track:** `fde-ai`  **Status:** not started  **Hours target:** 50

## Business Problem

Engineers at growing organizations spend approximately 30% of their time on low-leverage tasks: writing documentation for existing code, reviewing PRs for style and pattern violations, and navigating unfamiliar codebases. Onboarding to a new service takes days. This project builds an AI copilot that understands the codebase semantically — using Tree-sitter for AST parsing and code embeddings stored in pgvector — and provides in-editor suggestions via an LSP-based VS Code extension, automated PR review comments via GitHub Actions, and a Next.js web UI for codebase Q&A.

## What you will build

- A **codebase indexer** that parses all source files using Tree-sitter, chunks them by function/class, generates code embeddings via Mistral, and stores them in PostgreSQL with pgvector for semantic search
- A **LangChain RAG pipeline** that answers natural-language questions about the codebase by retrieving the most relevant code chunks and passing them to Mistral for explanation
- A **GitHub Actions PR review bot** that runs on every pull request, semantically queries the diff against the indexed codebase, and posts inline review comments with suggestions
- A **VS Code extension** implementing the Language Server Protocol that provides hover documentation and "explain this function" commands backed by the RAG pipeline
- A **Next.js web dashboard** for codebase search, documentation generation, and per-file coverage of the embedding index
- A **FastAPI server** exposing the RAG and indexer operations as REST endpoints consumed by both the VS Code extension and the web dashboard

## Architecture

```
Codebase (Git repo)
        |
        v
  Tree-sitter Parser
  (parse all .py/.ts/.js
   files into AST nodes)
        |
  Function/Class Chunker
  (extract docstring, signature,
   body, file path, line range)
        |
  Mistral Embeddings API
  (codestral-embed or
   text-embedding-latest)
        |
  PostgreSQL + pgvector
  (code_chunks table with
   embedding column)
        |
        +---------------------------+
        |                           |
  LangChain RAG                FastAPI
  (retrieve top-k chunks        /v1/search
   → Mistral generation)        /v1/explain
        |                       /v1/index
        |                           |
        +----------+----------------+
                   |
       +-----------+------------+
       |                        |
 VS Code Extension         Next.js Dashboard
 (LSP server: hover,       (search UI, doc
  explain command,          generator, index
  inline suggestions)       coverage view)
                   |
           GitHub Actions
           (PR review bot:
            semantic diff analysis
            → inline comments)
                   |
              AWS S3
         (embedding snapshots,
          index version history)
```

## Skills covered

| Skill ID | Skill Name | What you practice |
|----------|------------|------------------|
| SK03 | Prompt Engineering and System Design | Designing system prompts for code explanation, PR review, and documentation generation; few-shot examples per language |
| SK05 | Full-Stack Application Development | Building the Next.js dashboard with server components, API routes, and real-time index status |
| SK06 | Database Schema Design and Query Optimization | Designing the `code_chunks` table with pgvector, HNSW index, and filtering by repo/language |
| SK08 | Observability and Production Debugging | Structured logging for LSP requests, embedding latency metrics, and RAG retrieval quality monitoring |
| SK11 | Structured Output Extraction and Parsing | Extracting structured PR review comments (file, line, severity, suggestion) from Mistral output using Pydantic |
| SK13 | Agentic Workflows and Tool Use | Multi-step agent: fetch diff → retrieve context → generate review → post comments |
| SK24 | IDE Integration and Developer UX | Implementing an LSP server with hover and code action handlers; VS Code extension packaging |
| SK25 | Context Window Management and Prompt Optimization | Token budget management for large file explanations; hierarchical summarization for module-level context |
| SK26 | Codebase Indexing and Semantic Search | Tree-sitter AST parsing, function-level chunking strategy, embedding model selection, HNSW index tuning |

## Tools & dependencies

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| LangChain | 0.2.x | RAG pipeline orchestration: retrieval, prompt chaining, output parsing | `pip install langchain langchain-community` |
| Mistral API | latest | Code embedding generation and explanation generation | `pip install mistralai` |
| PostgreSQL + pgvector | 15.x + 0.7.x | Vector storage for code chunk embeddings with HNSW similarity search | `brew install postgresql@15` + `CREATE EXTENSION vector` |
| Next.js | 14.x | Web dashboard for codebase search and documentation browser | `npx create-next-app@14` |
| FastAPI | 0.111.x | REST API consumed by VS Code extension and dashboard | `pip install fastapi uvicorn` |
| AWS S3 | — | Storing index snapshots and version history | `pip install boto3` |
| GitHub Actions | cloud | PR review bot: triggered on `pull_request` events | `.github/workflows/pr-review.yml` |
| Tree-sitter | 0.21.x | AST parsing for Python, TypeScript, JavaScript source files | `pip install tree-sitter tree-sitter-python tree-sitter-javascript` |
| LSP (pygls) | 1.3.x | Language Server Protocol implementation for VS Code extension backend | `pip install pygls` |
| VS Code | 1.90.x | Extension host and development environment for the copilot extension | VS Code installer |
| psycopg2 | 2.9.x | PostgreSQL driver for the indexer and API | `pip install psycopg2-binary` |
| tiktoken | 0.7.x | Token counting for context window budget management | `pip install tiktoken` |

## Prerequisites

**Track modules to complete first:**

- [ ] `ai-agents/02-langchain` — LangChain chains, retrievers, and output parsers used extensively in the RAG pipeline
- [ ] `ai-agents/05-mcp-tool-use` — tool-use patterns relevant to the agentic PR review workflow
- [ ] `ai-agents/06-rag-advanced` — advanced RAG: reranking, hybrid search, and context compression strategies used in the codebase retriever
- [ ] `software-engineer/03-nextjs` — Next.js server components, API routes, and streaming responses used in the dashboard

**Accounts / API keys needed:**

- [ ] Mistral AI — embedding API and generation (`MISTRAL_API_KEY`; codestral-embed model for code embeddings)
- [ ] GitHub — Personal Access Token with `pull_requests: write` scope for the PR review bot (`GITHUB_TOKEN`)
- [ ] AWS account — S3 bucket for index snapshots (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- [ ] PostgreSQL — local Docker or managed RDS with pgvector extension enabled

---

## Step-by-step tutorial

### Step 1: Environment setup

**Goal:** Bootstrap the Python backend, Next.js frontend, and PostgreSQL with pgvector.

**Backend:**

```bash
python -m venv .venv && source .venv/bin/activate
pip install fastapi uvicorn langchain langchain-community mistralai \
    psycopg2-binary tree-sitter tree-sitter-python tree-sitter-javascript \
    pygls boto3 tiktoken python-dotenv pydantic
```

**Frontend:**

```bash
cd frontend
npx create-next-app@14 . --typescript --tailwind --app --src-dir
npm install swr @codemirror/state @codemirror/view @uiw/react-codemirror
```

**Docker Compose (with pgvector):**

```yaml
# docker-compose.yml
version: "3.9"
services:
  postgres:
    image: pgvector/pgvector:pg15
    environment:
      POSTGRES_DB: copilot
      POSTGRES_USER: copilot
      POSTGRES_PASSWORD: copilotpass
    ports: ["5432:5432"]
    volumes:
      - pgdata:/var/lib/postgresql/data

  api:
    build: .
    ports: ["8000:8000"]
    environment:
      DATABASE_URL: postgresql://copilot:copilotpass@postgres:5432/copilot
      MISTRAL_API_KEY: ${MISTRAL_API_KEY}
    depends_on: [postgres]
    volumes: ["./src:/app/src"]

volumes:
  pgdata:
```

```bash
docker compose up -d postgres
```

**File structure:**

```
p06-engineering-productivity-ai-copilot/
├── src/
│   ├── api/
│   │   └── main.py
│   ├── indexer/
│   │   ├── parser.py
│   │   ├── chunker.py
│   │   └── embedder.py
│   ├── rag/
│   │   ├── retriever.py
│   │   └── generator.py
│   ├── lsp/
│   │   └── server.py
│   ├── pr_review/
│   │   └── reviewer.py
│   └── db/
│       └── schema.sql
├── vscode-extension/
│   ├── package.json
│   └── src/extension.ts
├── frontend/
├── tests/
├── docker-compose.yml
└── .env
```

**Verify:**

```bash
docker compose ps
psql postgresql://copilot:copilotpass@localhost:5432/copilot -c "SELECT version();"
```

---

### Step 2: Database schema with pgvector

**Goal:** Create the schema for code chunks, their embeddings, and index run metadata.

**Create `src/db/schema.sql`:**

```sql
-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Code chunk index: one row per function/class/module
CREATE TABLE code_chunks (
    id            BIGSERIAL PRIMARY KEY,
    repo_id       VARCHAR(128) NOT NULL,     -- e.g. "org/repo"
    file_path     VARCHAR(512) NOT NULL,
    language      VARCHAR(32)  NOT NULL,     -- python, typescript, javascript
    chunk_type    VARCHAR(32)  NOT NULL,     -- function, class, module
    name          VARCHAR(256),              -- function or class name
    signature     TEXT,                      -- e.g. "def train(df: pd.DataFrame) -> Model"
    docstring     TEXT,
    body          TEXT         NOT NULL,     -- raw source code of the chunk
    start_line    INTEGER      NOT NULL,
    end_line      INTEGER      NOT NULL,
    embedding     vector(1024),             -- Mistral text-embedding-latest dimension
    token_count   INTEGER,
    index_run_id  VARCHAR(64)  NOT NULL,
    created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- HNSW index for fast approximate nearest-neighbour search
CREATE INDEX idx_chunks_embedding ON code_chunks
    USING hnsw (embedding vector_cosine_ops)
    WITH (m = 16, ef_construction = 64);

CREATE INDEX idx_chunks_repo_lang ON code_chunks (repo_id, language);
CREATE INDEX idx_chunks_file ON code_chunks (file_path);

-- Track index runs for versioning and audit
CREATE TABLE index_runs (
    id          VARCHAR(64)  PRIMARY KEY,    -- UUID
    repo_id     VARCHAR(128) NOT NULL,
    status      VARCHAR(32)  DEFAULT 'running',  -- running, complete, failed
    chunks_indexed INTEGER DEFAULT 0,
    files_indexed  INTEGER DEFAULT 0,
    started_at  TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- Cache for generated documentation (avoid re-calling Mistral)
CREATE TABLE doc_cache (
    chunk_id    BIGINT REFERENCES code_chunks(id) ON DELETE CASCADE PRIMARY KEY,
    doc_text    TEXT NOT NULL,
    generated_at TIMESTAMPTZ DEFAULT NOW()
);
```

```bash
psql postgresql://copilot:copilotpass@localhost:5432/copilot -f src/db/schema.sql
```

**Verify:**

```bash
psql postgresql://copilot:copilotpass@localhost:5432/copilot \
  -c "SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';"
# Expected: vector | 0.7.x
```

---

### Step 3: Tree-sitter AST parser

**Goal:** Parse Python and TypeScript source files into structured chunk records using Tree-sitter.

**Create `src/indexer/parser.py`:**

```python
import os
from dataclasses import dataclass
from typing import List, Optional
from tree_sitter import Language, Parser
import tree_sitter_python as tspython
import tree_sitter_javascript as tsjavascript


@dataclass
class CodeChunk:
    file_path: str
    language: str
    chunk_type: str       # function, class, module
    name: Optional[str]
    signature: Optional[str]
    docstring: Optional[str]
    body: str
    start_line: int
    end_line: int


def _build_parser(language_name: str) -> Parser:
    if language_name == "python":
        lang = Language(tspython.language())
    elif language_name in ("javascript", "typescript"):
        lang = Language(tsjavascript.language())
    else:
        raise ValueError(f"Unsupported language: {language_name}")
    parser = Parser(lang)
    return parser


def _detect_language(file_path: str) -> Optional[str]:
    ext = os.path.splitext(file_path)[1].lower()
    return {".py": "python", ".ts": "typescript", ".tsx": "typescript",
            ".js": "javascript", ".jsx": "javascript"}.get(ext)


def _extract_docstring_python(node, source: bytes) -> Optional[str]:
    """Extract leading string literal as docstring for Python functions/classes."""
    body = node.child_by_field_name("body")
    if not body:
        return None
    for child in body.children:
        if child.type == "expression_statement":
            expr = child.children[0] if child.children else None
            if expr and expr.type == "string":
                return source[expr.start_byte:expr.end_byte].decode("utf-8").strip('"""\'')
    return None


def parse_file(file_path: str) -> List[CodeChunk]:
    """Parse a source file and return a list of CodeChunk objects."""
    language = _detect_language(file_path)
    if not language:
        return []

    with open(file_path, "rb") as f:
        source = f.read()

    parser = _build_parser(language)
    tree   = parser.parse(source)

    chunks = []
    lines  = source.decode("utf-8", errors="replace").splitlines()

    def visit(node):
        if node.type in ("function_definition", "function_declaration",
                         "arrow_function", "method_definition"):
            name_node = node.child_by_field_name("name")
            name      = source[name_node.start_byte:name_node.end_byte].decode() if name_node else None
            body_text = source[node.start_byte:node.end_byte].decode("utf-8", errors="replace")
            docstring = _extract_docstring_python(node, source) if language == "python" else None
            # Build signature: first line of the function
            sig_line = lines[node.start_point[0]] if node.start_point[0] < len(lines) else ""
            chunks.append(CodeChunk(
                file_path=file_path, language=language,
                chunk_type="function", name=name,
                signature=sig_line.strip(), docstring=docstring,
                body=body_text,
                start_line=node.start_point[0] + 1,
                end_line=node.end_point[0] + 1,
            ))

        elif node.type in ("class_definition", "class_declaration"):
            name_node = node.child_by_field_name("name")
            name      = source[name_node.start_byte:name_node.end_byte].decode() if name_node else None
            body_text = source[node.start_byte:node.end_byte].decode("utf-8", errors="replace")
            chunks.append(CodeChunk(
                file_path=file_path, language=language,
                chunk_type="class", name=name,
                signature=None, docstring=None,
                body=body_text[:2000],  # Truncate large classes
                start_line=node.start_point[0] + 1,
                end_line=node.end_point[0] + 1,
            ))

        for child in node.children:
            visit(child)

    visit(tree.root_node)

    # If no chunks extracted, treat whole file as a module chunk
    if not chunks:
        chunks.append(CodeChunk(
            file_path=file_path, language=language,
            chunk_type="module", name=os.path.basename(file_path),
            signature=None, docstring=None,
            body=source.decode("utf-8", errors="replace")[:3000],
            start_line=1, end_line=len(lines),
        ))

    return chunks
```

**Verify:**

```bash
# Create a test Python file and parse it
cat > /tmp/test_sample.py << 'EOF'
def add(a: int, b: int) -> int:
    """Add two numbers."""
    return a + b

class Calculator:
    def multiply(self, x: float, y: float) -> float:
        return x * y
EOF

python - <<'PYEOF'
from src.indexer.parser import parse_file
chunks = parse_file("/tmp/test_sample.py")
for c in chunks:
    print(f"{c.chunk_type}: {c.name} (lines {c.start_line}-{c.end_line})")
PYEOF
# Expected: function: add (lines 1-3), class: Calculator (lines ...), function: multiply (lines ...)
```

---

### Step 4: Embedding generation

**Goal:** Generate code embeddings using the Mistral embedding API and persist chunks to PostgreSQL.

**Create `src/indexer/embedder.py`:**

```python
import os
import uuid
import psycopg2
import psycopg2.extras
import tiktoken
from mistralai import Mistral
from typing import List
from src.indexer.parser import CodeChunk

MISTRAL_API_KEY = os.getenv("MISTRAL_API_KEY")
DB_URL          = os.getenv("DATABASE_URL", "postgresql://copilot:copilotpass@localhost:5432/copilot")
EMBED_MODEL     = "mistral-embed"
MAX_TOKENS      = 512   # Truncate chunks exceeding this before embedding

_tokenizer = tiktoken.get_encoding("cl100k_base")


def count_tokens(text: str) -> int:
    return len(_tokenizer.encode(text))


def truncate_to_tokens(text: str, max_tokens: int = MAX_TOKENS) -> str:
    tokens = _tokenizer.encode(text)
    if len(tokens) <= max_tokens:
        return text
    return _tokenizer.decode(tokens[:max_tokens])


def embed_texts(texts: List[str]) -> List[List[float]]:
    """Call Mistral embeddings API. Returns list of embedding vectors."""
    client    = Mistral(api_key=MISTRAL_API_KEY)
    truncated = [truncate_to_tokens(t) for t in texts]
    response  = client.embeddings.create(model=EMBED_MODEL, inputs=truncated)
    return [item.embedding for item in response.data]


def index_chunks(chunks: List[CodeChunk], repo_id: str, run_id: str,
                 batch_size: int = 20) -> int:
    """
    Embed and persist a list of CodeChunk objects to PostgreSQL.
    Processes in batches to respect API rate limits.
    Returns total chunks inserted.
    """
    conn = psycopg2.connect(DB_URL)
    cur  = conn.cursor()
    total_inserted = 0

    for i in range(0, len(chunks), batch_size):
        batch  = chunks[i : i + batch_size]
        texts  = [
            f"{c.signature or ''}\n{c.docstring or ''}\n{c.body}"
            for c in batch
        ]
        embeddings = embed_texts(texts)

        for chunk, embedding in zip(batch, embeddings):
            token_count = count_tokens(chunk.body)
            cur.execute("""
                INSERT INTO code_chunks
                    (repo_id, file_path, language, chunk_type, name, signature,
                     docstring, body, start_line, end_line, embedding,
                     token_count, index_run_id)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s::vector, %s, %s)
            """, (
                repo_id, chunk.file_path, chunk.language, chunk.chunk_type,
                chunk.name, chunk.signature, chunk.docstring, chunk.body,
                chunk.start_line, chunk.end_line,
                str(embedding),   # pgvector accepts '[0.1, 0.2, ...]' format
                token_count, run_id,
            ))
            total_inserted += 1

        conn.commit()
        print(f"Indexed batch {i // batch_size + 1}: {len(batch)} chunks")

    cur.close()
    conn.close()
    return total_inserted
```

**Create `src/indexer/run_indexer.py` (entry point):**

```python
#!/usr/bin/env python3
"""
Index a directory of source files.
Usage: python -m src.indexer.run_indexer --repo-id org/repo --path /path/to/repo
"""
import argparse
import os
import uuid
import psycopg2
from pathlib import Path
from src.indexer.parser import parse_file
from src.indexer.embedder import index_chunks

SUPPORTED_EXTENSIONS = {".py", ".ts", ".tsx", ".js", ".jsx"}


def collect_files(root: str) -> list[str]:
    paths = []
    for dirpath, dirnames, filenames in os.walk(root):
        # Skip common non-source directories
        dirnames[:] = [d for d in dirnames
                       if d not in {"node_modules", ".git", "__pycache__",
                                    "dist", "build", ".venv", "venv"}]
        for fname in filenames:
            if Path(fname).suffix in SUPPORTED_EXTENSIONS:
                paths.append(os.path.join(dirpath, fname))
    return sorted(paths)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-id", required=True)
    parser.add_argument("--path", required=True)
    args = parser.parse_args()

    run_id = str(uuid.uuid4())
    db_url = os.getenv("DATABASE_URL", "postgresql://copilot:copilotpass@localhost:5432/copilot")

    # Register index run
    conn = psycopg2.connect(db_url)
    conn.cursor().execute(
        "INSERT INTO index_runs (id, repo_id) VALUES (%s, %s)",
        (run_id, args.repo_id)
    )
    conn.commit()

    files = collect_files(args.path)
    print(f"Found {len(files)} source files to index")

    all_chunks = []
    for fpath in files:
        chunks = parse_file(fpath)
        all_chunks.extend(chunks)

    total = index_chunks(all_chunks, repo_id=args.repo_id, run_id=run_id)

    # Mark run complete
    conn.cursor().execute(
        """UPDATE index_runs
           SET status='complete', chunks_indexed=%s, files_indexed=%s, completed_at=NOW()
           WHERE id=%s""",
        (total, len(files), run_id)
    )
    conn.commit()
    conn.close()
    print(f"Indexed {total} chunks from {len(files)} files. Run ID: {run_id}")


if __name__ == "__main__":
    main()
```

**Verify:**

```bash
python -m src.indexer.run_indexer --repo-id "myorg/myrepo" --path ./src
psql postgresql://copilot:copilotpass@localhost:5432/copilot \
  -c "SELECT language, COUNT(*) FROM code_chunks GROUP BY language;"
# Expected: rows with python / typescript counts
```

---

### Step 5: RAG retriever and generator

**Goal:** Build a LangChain retriever that finds the most relevant code chunks for a query and generates an explanation.

**Create `src/rag/retriever.py`:**

```python
import os
import psycopg2
import psycopg2.extras
from typing import List, Tuple
from mistralai import Mistral
from src.indexer.embedder import embed_texts

DB_URL          = os.getenv("DATABASE_URL", "postgresql://copilot:copilotpass@localhost:5432/copilot")
MISTRAL_API_KEY = os.getenv("MISTRAL_API_KEY")


def retrieve_chunks(query: str, repo_id: str, top_k: int = 5,
                    language_filter: str = None) -> List[dict]:
    """
    Embed the query, then retrieve top-k most similar code chunks using pgvector.
    Returns list of chunk dicts with similarity score.
    """
    query_embedding = embed_texts([query])[0]

    conn = psycopg2.connect(DB_URL, cursor_factory=psycopg2.extras.RealDictCursor)
    cur  = conn.cursor()

    lang_clause = "AND language = %s" if language_filter else ""
    params = [repo_id, str(query_embedding), top_k]
    if language_filter:
        params.insert(2, language_filter)

    cur.execute(f"""
        SELECT
            id, file_path, language, chunk_type, name, signature,
            docstring, body, start_line, end_line,
            1 - (embedding <=> %s::vector) AS similarity
        FROM code_chunks
        WHERE repo_id = %s
          {lang_clause}
          AND embedding IS NOT NULL
        ORDER BY embedding <=> %s::vector
        LIMIT %s
    """, [str(query_embedding), repo_id] +
         ([language_filter] if language_filter else []) +
         [str(query_embedding), top_k])

    rows = [dict(r) for r in cur.fetchall()]
    cur.close()
    conn.close()
    return rows
```

**Create `src/rag/generator.py`:**

```python
import os
import tiktoken
from mistralai import Mistral
from typing import List

MISTRAL_API_KEY = os.getenv("MISTRAL_API_KEY")
MAX_CONTEXT_TOKENS = 6000  # Reserve space for system prompt and response

_tokenizer = tiktoken.get_encoding("cl100k_base")


EXPLAIN_SYSTEM_PROMPT = """You are an expert software engineer acting as a codebase assistant.
Given retrieved code chunks from a repository, answer the user's question accurately and concisely.

Guidelines:
- Reference specific function names and file paths in your answer
- If the retrieved chunks don't contain enough information, say so explicitly
- Prefer showing code examples when helpful
- Keep explanations under 400 words unless depth is specifically requested"""


def build_context(chunks: List[dict], max_tokens: int = MAX_CONTEXT_TOKENS) -> str:
    """Build a context block from retrieved chunks, respecting the token budget."""
    parts = []
    used  = 0
    for chunk in chunks:
        snippet = (
            f"### {chunk['chunk_type']}: `{chunk['name'] or chunk['file_path']}`\n"
            f"**File:** `{chunk['file_path']}` (lines {chunk['start_line']}-{chunk['end_line']})\n"
            f"**Similarity:** {chunk.get('similarity', 0):.3f}\n\n"
            f"```{chunk['language']}\n{chunk['body']}\n```\n"
        )
        tokens = len(_tokenizer.encode(snippet))
        if used + tokens > max_tokens:
            break
        parts.append(snippet)
        used += tokens

    return "\n---\n".join(parts)


def generate_explanation(query: str, chunks: List[dict],
                         stream: bool = False) -> str:
    """
    Generate an answer to the query using retrieved code chunks as context.
    Returns the generated text.
    """
    client  = Mistral(api_key=MISTRAL_API_KEY)
    context = build_context(chunks)

    messages = [
        {"role": "system", "content": EXPLAIN_SYSTEM_PROMPT},
        {"role": "user", "content": f"**Retrieved code context:**\n\n{context}\n\n**Question:** {query}"},
    ]

    response = client.chat.complete(
        model="mistral-large-latest",
        messages=messages,
        temperature=0.1,
        max_tokens=600,
    )
    return response.choices[0].message.content


def generate_docstring(chunk_body: str, language: str) -> str:
    """Generate a docstring for a code chunk."""
    client = Mistral(api_key=MISTRAL_API_KEY)
    prompt = (
        f"Write a concise, accurate docstring for the following {language} function.\n"
        f"Return only the docstring text, no code fences.\n\n```{language}\n{chunk_body}\n```"
    )
    response = client.chat.complete(
        model="mistral-small-latest",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.0,
        max_tokens=200,
    )
    return response.choices[0].message.content.strip()
```

**Verify:**

```bash
python - <<'EOF'
from src.rag.retriever import retrieve_chunks
from src.rag.generator import generate_explanation

chunks = retrieve_chunks("How does the feature engineering pipeline work?",
                          repo_id="myorg/myrepo", top_k=3)
print(f"Retrieved {len(chunks)} chunks")
if chunks:
    answer = generate_explanation(
        "How does the feature engineering pipeline work?", chunks
    )
    print(answer[:300])
EOF
# Expected: 3 chunks retrieved, followed by a coherent explanation
```

---

### Step 6: FastAPI backend

**Goal:** Expose RAG operations and indexer controls as REST endpoints.

**Create `src/api/main.py`:**

```python
import os
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import asyncpg

DATABASE_URL = os.getenv("DATABASE_URL")


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.pool = await asyncpg.create_pool(DATABASE_URL, min_size=2, max_size=10)
    yield
    await app.state.pool.close()


app = FastAPI(title="AI Copilot API", version="1.0.0", lifespan=lifespan)
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])


# --- Schemas ---

class SearchRequest(BaseModel):
    query: str
    repo_id: str
    top_k: int = 5
    language: Optional[str] = None


class SearchResult(BaseModel):
    chunk_id: int
    file_path: str
    name: Optional[str]
    signature: Optional[str]
    body: str
    start_line: int
    end_line: int
    similarity: float
    explanation: str


class IndexRequest(BaseModel):
    repo_id: str
    path: str  # Filesystem path (for local use) or S3 URI


# --- Endpoints ---

@app.get("/v1/health")
async def health():
    return {"status": "ok"}


@app.post("/v1/search", response_model=List[SearchResult])
async def semantic_search(req: SearchRequest):
    """Search the codebase index and return an AI-generated explanation."""
    from src.rag.retriever import retrieve_chunks
    from src.rag.generator import generate_explanation

    chunks = retrieve_chunks(req.query, req.repo_id, req.top_k, req.language)
    if not chunks:
        raise HTTPException(status_code=404, detail="No indexed chunks found for this repo")

    explanation = generate_explanation(req.query, chunks)

    return [
        SearchResult(
            chunk_id=c["id"], file_path=c["file_path"],
            name=c.get("name"), signature=c.get("signature"),
            body=c["body"], start_line=c["start_line"],
            end_line=c["end_line"], similarity=float(c["similarity"]),
            explanation=explanation if i == 0 else "",
        )
        for i, c in enumerate(chunks)
    ]


@app.post("/v1/explain")
async def explain_chunk(chunk_id: int):
    """Generate documentation for a specific code chunk by ID."""
    from src.rag.generator import generate_docstring
    import psycopg2, psycopg2.extras

    conn = psycopg2.connect(DATABASE_URL, cursor_factory=psycopg2.extras.RealDictCursor)
    cur  = conn.cursor()
    cur.execute("SELECT body, language FROM code_chunks WHERE id = %s", (chunk_id,))
    row = cur.fetchone()
    cur.close()
    conn.close()

    if not row:
        raise HTTPException(status_code=404, detail="Chunk not found")

    doc = generate_docstring(row["body"], row["language"])
    return {"chunk_id": chunk_id, "docstring": doc}


@app.post("/v1/index")
async def trigger_index(req: IndexRequest, background_tasks: BackgroundTasks):
    """Trigger a background indexing run for a repository path."""
    import uuid
    run_id = str(uuid.uuid4())
    background_tasks.add_task(_run_index, req.repo_id, req.path, run_id)
    return {"run_id": run_id, "status": "started"}


@app.get("/v1/index/{run_id}")
async def index_status(run_id: str):
    """Check the status of an indexing run."""
    import psycopg2, psycopg2.extras
    conn = psycopg2.connect(DATABASE_URL, cursor_factory=psycopg2.extras.RealDictCursor)
    cur  = conn.cursor()
    cur.execute("SELECT * FROM index_runs WHERE id = %s", (run_id,))
    row = cur.fetchone()
    cur.close()
    conn.close()
    if not row:
        raise HTTPException(status_code=404)
    return dict(row)


async def _run_index(repo_id: str, path: str, run_id: str):
    from src.indexer.run_indexer import collect_files, main as run_main
    import subprocess
    subprocess.run(
        ["python", "-m", "src.indexer.run_indexer",
         "--repo-id", repo_id, "--path", path],
        check=True
    )
```

**Verify:**

```bash
uvicorn src.api.main:app --reload --port 8000 &
curl -s -X POST http://localhost:8000/v1/search \
  -H "Content-Type: application/json" \
  -d '{"query":"How do I train the demand model?","repo_id":"myorg/myrepo","top_k":3}' \
  | python -m json.tool
# Expected: JSON array with chunk results and explanation on first item
```

---

### Step 7: GitHub Actions PR review bot

**Goal:** On every pull request, retrieve relevant context from the index and post structured inline review comments.

**Create `src/pr_review/reviewer.py`:**

```python
import os
import re
import json
from mistralai import Mistral
from pydantic import BaseModel
from typing import List, Optional

MISTRAL_API_KEY = os.getenv("MISTRAL_API_KEY")
GITHUB_TOKEN    = os.getenv("GITHUB_TOKEN")

PR_REVIEW_SYSTEM_PROMPT = """You are a senior software engineer performing a code review.
Given a code diff and relevant context from the existing codebase, identify:
1. Potential bugs or correctness issues
2. Deviations from patterns already established in the codebase
3. Missing error handling or edge cases
4. Opportunities to reuse existing functions from the codebase context

Return a JSON array of review comments with this structure:
[
  {
    "path": "src/models/foo.py",
    "line": 42,
    "severity": "error|warning|suggestion",
    "comment": "Human-readable review comment"
  }
]

If there are no issues, return an empty array []."""


class ReviewComment(BaseModel):
    path: str
    line: int
    severity: str
    comment: str


def parse_diff_files(diff_text: str) -> List[dict]:
    """Extract file paths and changed lines from a unified diff."""
    files = []
    current_file = None
    line_num = 0

    for line in diff_text.splitlines():
        if line.startswith("diff --git"):
            m = re.search(r"b/(.+)$", line)
            if m:
                current_file = {"path": m.group(1), "changes": []}
                files.append(current_file)
        elif line.startswith("@@ "):
            m = re.search(r"\+(\d+)", line)
            if m:
                line_num = int(m.group(1)) - 1
        elif current_file is not None:
            if line.startswith("+") and not line.startswith("+++"):
                line_num += 1
                current_file["changes"].append({"line": line_num, "content": line[1:]})
            elif not line.startswith("-"):
                line_num += 1

    return files


def review_diff(diff_text: str, context_chunks: List[dict]) -> List[ReviewComment]:
    """
    Generate structured review comments for a diff given codebase context.
    """
    client  = Mistral(api_key=MISTRAL_API_KEY)
    context = "\n\n".join([
        f"// {c['file_path']}:{c['start_line']}\n{c['body'][:800]}"
        for c in context_chunks
    ])

    messages = [
        {"role": "system", "content": PR_REVIEW_SYSTEM_PROMPT},
        {"role": "user", "content": (
            f"**Codebase context (similar code already in repo):**\n```\n{context}\n```\n\n"
            f"**Pull request diff to review:**\n```diff\n{diff_text[:4000]}\n```"
        )},
    ]

    response = client.chat.complete(
        model="mistral-large-latest",
        messages=messages,
        temperature=0.1,
        max_tokens=1500,
        response_format={"type": "json_object"},
    )

    raw = response.choices[0].message.content
    data = json.loads(raw)
    comments_data = data if isinstance(data, list) else data.get("comments", [])
    return [ReviewComment(**c) for c in comments_data]


def post_review_comments(owner: str, repo: str, pr_number: int,
                          commit_sha: str, comments: List[ReviewComment]) -> None:
    """Post inline review comments to a GitHub pull request."""
    import requests

    headers = {
        "Authorization": f"Bearer {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json",
    }

    review_payload = {
        "commit_id": commit_sha,
        "event": "COMMENT",
        "comments": [
            {
                "path": c.path,
                "line": c.line,
                "side": "RIGHT",
                "body": f"**[{c.severity.upper()}]** {c.comment}",
            }
            for c in comments
        ],
    }

    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}/reviews"
    resp = requests.post(url, headers=headers, json=review_payload)
    resp.raise_for_status()
    print(f"Posted {len(comments)} review comments")
```

**Create `.github/workflows/pr-review.yml`:**

```yaml
name: AI PR Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
      contents: read

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
          cache: pip

      - name: Install dependencies
        run: pip install mistralai psycopg2-binary pydantic requests python-dotenv

      - name: Fetch PR diff
        id: diff
        run: |
          git diff origin/${{ github.base_ref }}...HEAD > /tmp/pr.diff
          echo "diff_path=/tmp/pr.diff" >> $GITHUB_OUTPUT

      - name: Run AI review
        env:
          MISTRAL_API_KEY: ${{ secrets.MISTRAL_API_KEY }}
          GITHUB_TOKEN:    ${{ secrets.GITHUB_TOKEN }}
          DATABASE_URL:    ${{ secrets.DATABASE_URL }}
          REPO_ID:         ${{ github.repository }}
          PR_NUMBER:       ${{ github.event.pull_request.number }}
          COMMIT_SHA:      ${{ github.event.pull_request.head.sha }}
          OWNER:           ${{ github.repository_owner }}
          REPO:            ${{ github.event.repository.name }}
        run: |
          python - <<'EOF'
          import os
          from src.pr_review.reviewer import review_diff, post_review_comments
          from src.rag.retriever import retrieve_chunks

          diff_text  = open("/tmp/pr.diff").read()
          repo_id    = os.getenv("REPO_ID")
          pr_number  = int(os.getenv("PR_NUMBER"))
          commit_sha = os.getenv("COMMIT_SHA")
          owner      = os.getenv("OWNER")
          repo       = os.getenv("REPO")

          # Retrieve relevant codebase context based on the diff summary
          context = retrieve_chunks(diff_text[:500], repo_id=repo_id, top_k=5)
          comments = review_diff(diff_text, context)

          if comments:
              post_review_comments(owner, repo, pr_number, commit_sha, comments)
          else:
              print("No issues found.")
          EOF
```

**Verify:**

```bash
# Open a test PR and check the pull_request tab for AI review comments
# Or test locally:
python - <<'EOF'
from src.pr_review.reviewer import parse_diff_files

sample_diff = """diff --git a/src/api/main.py b/src/api/main.py
index abc1234..def5678 100644
--- a/src/api/main.py
+++ b/src/api/main.py
@@ -10,6 +10,8 @@ async def health():
+def get_user(id):
+    result = db.query(f"SELECT * FROM users WHERE id={id}")
+    return result
"""
files = parse_diff_files(sample_diff)
print("Parsed files:", [f["path"] for f in files])
EOF
```

---

### Step 8: LSP server

**Goal:** Implement a Language Server Protocol server that provides hover documentation using the RAG pipeline.

**Create `src/lsp/server.py`:**

```python
import os
import logging
from pygls.server import LanguageServer
from lsprotocol.types import (
    TEXT_DOCUMENT_HOVER, HoverParams, Hover,
    MarkupContent, MarkupKind,
    TEXT_DOCUMENT_DID_OPEN, DidOpenTextDocumentParams,
    INITIALIZE, InitializeParams,
)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("copilot-lsp")

server = LanguageServer("copilot-lsp", "v0.1.0")

REPO_ID = os.getenv("COPILOT_REPO_ID", "myorg/myrepo")
API_URL = os.getenv("COPILOT_API_URL", "http://localhost:8000")


@server.feature(INITIALIZE)
def initialize(params: InitializeParams):
    logger.info("LSP client connected: %s", params.client_info)


@server.feature(TEXT_DOCUMENT_HOVER)
def hover(ls: LanguageServer, params: HoverParams) -> Hover:
    """On hover: extract the symbol under cursor and explain it via the RAG API."""
    import requests

    doc  = ls.workspace.get_document(params.text_document.uri)
    line = doc.lines[params.position.line] if doc.lines else ""

    # Extract word under cursor
    char = params.position.character
    start = char
    end   = char
    while start > 0 and (line[start - 1].isalnum() or line[start - 1] == "_"):
        start -= 1
    while end < len(line) and (line[end].isalnum() or line[end] == "_"):
        end += 1

    symbol = line[start:end].strip()
    if not symbol or len(symbol) < 2:
        return None

    query = f"What does `{symbol}` do in this codebase?"
    try:
        resp = requests.post(
            f"{API_URL}/v1/search",
            json={"query": query, "repo_id": REPO_ID, "top_k": 3},
            timeout=5,
        )
        resp.raise_for_status()
        data     = resp.json()
        if not data:
            return None
        explanation = data[0].get("explanation", "No explanation available.")
        file_path   = data[0].get("file_path", "")
        start_line  = data[0].get("start_line", 0)

        markdown = (
            f"**AI Copilot — `{symbol}`**\n\n"
            f"{explanation}\n\n"
            f"*Source: `{file_path}:{start_line}`*"
        )
        return Hover(contents=MarkupContent(kind=MarkupKind.Markdown, value=markdown))
    except Exception as e:
        logger.error("Hover lookup failed: %s", e)
        return None


def main():
    server.start_io()


if __name__ == "__main__":
    main()
```

**Verify:**

```bash
python src/lsp/server.py &
# Test with a JSON-RPC message:
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":null,"rootUri":null,"capabilities":{}}}' \
  | python src/lsp/server.py
# Expected: JSON response with capabilities
```

---

### Step 9: VS Code extension

**Goal:** Package the LSP server as a VS Code extension with hover support and an "Explain function" command.

**Create `vscode-extension/package.json`:**

```json
{
  "name": "ai-copilot",
  "displayName": "AI Engineering Copilot",
  "description": "Semantic codebase search and AI-powered hover documentation",
  "version": "0.1.0",
  "engines": { "vscode": "^1.85.0" },
  "categories": ["Other"],
  "activationEvents": ["onLanguage:python", "onLanguage:typescript"],
  "main": "./out/extension.js",
  "contributes": {
    "commands": [
      {
        "command": "copilot.explainFunction",
        "title": "AI Copilot: Explain Function"
      },
      {
        "command": "copilot.searchCodebase",
        "title": "AI Copilot: Search Codebase"
      }
    ]
  },
  "scripts": {
    "compile": "tsc -p ./",
    "watch": "tsc -watch -p ./",
    "package": "vsce package"
  },
  "dependencies": {
    "vscode-languageclient": "^9.0.1"
  },
  "devDependencies": {
    "@types/vscode": "^1.85.0",
    "@vscode/vsce": "^2.24.0",
    "typescript": "^5.3.3"
  }
}
```

**Create `vscode-extension/src/extension.ts`:**

```typescript
import * as vscode from "vscode";
import {
  LanguageClient,
  LanguageClientOptions,
  ServerOptions,
  TransportKind,
} from "vscode-languageclient/node";

let client: LanguageClient;

export function activate(context: vscode.ExtensionContext) {
  const serverOptions: ServerOptions = {
    command: "python",
    args: ["-m", "src.lsp.server"],
    transport: TransportKind.stdio,
    options: { cwd: process.env.COPILOT_REPO_PATH || process.cwd() },
  };

  const clientOptions: LanguageClientOptions = {
    documentSelector: [
      { scheme: "file", language: "python" },
      { scheme: "file", language: "typescript" },
      { scheme: "file", language: "javascript" },
    ],
  };

  client = new LanguageClient(
    "aiCopilot",
    "AI Engineering Copilot",
    serverOptions,
    clientOptions
  );
  client.start();

  // "Explain Function" command
  context.subscriptions.push(
    vscode.commands.registerCommand("copilot.explainFunction", async () => {
      const editor = vscode.window.activeTextEditor;
      if (!editor) return;

      const selection = editor.selection;
      const code = editor.document.getText(selection);
      if (!code) {
        vscode.window.showInformationMessage("Select a function to explain.");
        return;
      }

      const apiUrl =
        vscode.workspace.getConfiguration("copilot").get<string>("apiUrl") ||
        "http://localhost:8000";
      const repoId =
        vscode.workspace.getConfiguration("copilot").get<string>("repoId") || "";

      const response = await fetch(`${apiUrl}/v1/search`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ query: code.substring(0, 200), repo_id: repoId, top_k: 3 }),
      });

      const data = (await response.json()) as Array<{ explanation: string }>;
      if (data.length > 0) {
        const panel = vscode.window.createWebviewPanel(
          "copilotExplain",
          "AI Explanation",
          vscode.ViewColumn.Beside,
          {}
        );
        panel.webview.html = `<html><body style="font-family:sans-serif;padding:16px">
          <h2>AI Copilot Explanation</h2>
          <pre style="white-space:pre-wrap">${data[0].explanation}</pre>
        </body></html>`;
      }
    })
  );
}

export function deactivate() {
  if (client) return client.stop();
}
```

**Build and install extension:**

```bash
cd vscode-extension
npm install
npm run compile
npx vsce package
# Produces ai-copilot-0.1.0.vsix
code --install-extension ai-copilot-0.1.0.vsix
```

**Verify:**

```
1. Open VS Code in a Python project that has been indexed
2. Hover over a function name
3. Expected: markdown tooltip with AI-generated explanation and source file reference
4. Select a function body → Run "AI Copilot: Explain Function"
5. Expected: side panel with explanation
```

---

### Step 10: Next.js dashboard

**Goal:** Build a web interface for codebase search, documentation browser, and index coverage metrics.

**Create `frontend/src/app/page.tsx`:**

```typescript
"use client";
import { useState } from "react";

interface SearchResult {
  chunk_id: number;
  file_path: string;
  name: string | null;
  signature: string | null;
  body: string;
  start_line: number;
  end_line: number;
  similarity: number;
  explanation: string;
}

export default function Dashboard() {
  const [query, setQuery]     = useState("");
  const [results, setResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(false);

  const search = async () => {
    setLoading(true);
    const res = await fetch("/api/search", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ query, repo_id: process.env.NEXT_PUBLIC_REPO_ID }),
    });
    const data = await res.json();
    setResults(data);
    setLoading(false);
  };

  return (
    <main className="min-h-screen bg-gray-900 text-gray-100 p-8">
      <h1 className="text-3xl font-bold mb-6">AI Codebase Copilot</h1>

      <div className="flex gap-4 mb-8">
        <input
          className="flex-1 rounded-lg bg-gray-800 border border-gray-600 px-4 py-2
                     text-white placeholder-gray-400 focus:outline-none focus:border-blue-500"
          placeholder="Ask anything about the codebase..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && search()}
        />
        <button
          onClick={search}
          disabled={loading}
          className="px-6 py-2 bg-blue-600 hover:bg-blue-500 rounded-lg font-medium
                     disabled:opacity-50 transition-colors"
        >
          {loading ? "Searching..." : "Search"}
        </button>
      </div>

      {results.length > 0 && (
        <div className="mb-6 p-4 bg-gray-800 rounded-lg border border-gray-700">
          <h2 className="font-semibold text-blue-400 mb-2">AI Explanation</h2>
          <p className="text-gray-300 whitespace-pre-wrap">{results[0].explanation}</p>
        </div>
      )}

      <div className="space-y-4">
        {results.map((r) => (
          <div key={r.chunk_id}
               className="bg-gray-800 rounded-lg border border-gray-700 p-4">
            <div className="flex justify-between items-start mb-2">
              <span className="font-mono text-sm text-blue-400">
                {r.file_path}:{r.start_line}
              </span>
              <span className="text-xs text-gray-500">
                similarity: {(r.similarity * 100).toFixed(1)}%
              </span>
            </div>
            {r.name && (
              <h3 className="font-semibold text-gray-200 mb-2">{r.name}</h3>
            )}
            <pre className="text-xs text-gray-400 overflow-x-auto bg-gray-900
                            rounded p-3 max-h-40">
              {r.body.substring(0, 500)}
            </pre>
          </div>
        ))}
      </div>
    </main>
  );
}
```

**Create `frontend/src/app/api/search/route.ts`:**

```typescript
import { NextRequest, NextResponse } from "next/server";

export async function POST(req: NextRequest) {
  const body = await req.json();
  const apiUrl = process.env.COPILOT_API_URL || "http://localhost:8000";

  const res = await fetch(`${apiUrl}/v1/search`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    return NextResponse.json({ error: "Search failed" }, { status: res.status });
  }

  return NextResponse.json(await res.json());
}
```

**Verify:**

```bash
cd frontend && npm run dev &
open http://localhost:3000
# Type "how does the indexer work?" and press Enter
# Expected: results with file paths, code snippets, and AI explanation
```

---

### Step 11: Observability and CI/CD

**Goal:** Add request-level logging, embedding latency metrics, and a CI pipeline.

**Structured logging middleware:**

```python
# src/api/middleware.py
import time
import logging
import json
from fastapi import Request

logger = logging.getLogger("copilot")
logging.basicConfig(
    level=logging.INFO,
    format="%(message)s",
)

async def logging_middleware(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    duration_ms = (time.time() - start) * 1000
    logger.info(json.dumps({
        "method":      request.method,
        "path":        str(request.url.path),
        "status":      response.status_code,
        "duration_ms": round(duration_ms, 1),
    }))
    return response
```

**Create `.github/workflows/ci.yml`:**

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  backend:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: pgvector/pgvector:pg15
        env:
          POSTGRES_DB: copilot_test
          POSTGRES_USER: copilot
          POSTGRES_PASSWORD: copilotpass
        ports: ["5432:5432"]
        options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: {python-version: "3.11", cache: pip}
      - run: pip install -r requirements.txt
      - run: psql postgresql://copilot:copilotpass@localhost:5432/copilot_test -f src/db/schema.sql
        env:
          DATABASE_URL: postgresql://copilot:copilotpass@localhost:5432/copilot_test
      - run: pytest tests/ -v --tb=short
        env:
          DATABASE_URL: postgresql://copilot:copilotpass@localhost:5432/copilot_test
          MISTRAL_API_KEY: ${{ secrets.MISTRAL_API_KEY }}

  frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: {node-version: "20", cache: npm, cache-dependency-path: frontend/package-lock.json}
      - run: cd frontend && npm ci && npm run build

  vscode-extension:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: {node-version: "20"}
      - run: cd vscode-extension && npm ci && npm run compile
```

---

## Testing

**Unit tests (`tests/test_parser.py`):**

```python
import os
import tempfile
import pytest
from src.indexer.parser import parse_file


SAMPLE_PYTHON = '''
def calculate_mape(actual, predicted):
    """Calculate mean absolute percentage error."""
    import numpy as np
    return np.mean(np.abs((actual - predicted) / (actual + 1e-8)))

class ModelTrainer:
    def train(self, X, y):
        pass
'''

SAMPLE_TYPESCRIPT = '''
export function formatDate(date: Date): string {
  return date.toISOString().split("T")[0];
}

export class ApiClient {
  constructor(private baseUrl: string) {}
}
'''


@pytest.fixture
def python_file(tmp_path):
    f = tmp_path / "sample.py"
    f.write_text(SAMPLE_PYTHON)
    return str(f)


@pytest.fixture
def ts_file(tmp_path):
    f = tmp_path / "sample.ts"
    f.write_text(SAMPLE_TYPESCRIPT)
    return str(f)


def test_parse_python_extracts_functions(python_file):
    chunks = parse_file(python_file)
    function_names = [c.name for c in chunks if c.chunk_type == "function"]
    assert "calculate_mape" in function_names


def test_parse_python_extracts_docstring(python_file):
    chunks = parse_file(python_file)
    mape_fn = next((c for c in chunks if c.name == "calculate_mape"), None)
    assert mape_fn is not None
    assert mape_fn.docstring and "percentage error" in mape_fn.docstring


def test_parse_python_extracts_class(python_file):
    chunks = parse_file(python_file)
    classes = [c for c in chunks if c.chunk_type == "class"]
    assert any(c.name == "ModelTrainer" for c in classes)


def test_parse_typescript(ts_file):
    chunks = parse_file(ts_file)
    assert len(chunks) > 0
    assert all(c.language == "typescript" for c in chunks)


def test_parse_unsupported_extension(tmp_path):
    f = tmp_path / "config.json"
    f.write_text('{"key": "value"}')
    chunks = parse_file(str(f))
    assert chunks == []


def test_chunk_line_numbers(python_file):
    chunks = parse_file(python_file)
    for chunk in chunks:
        assert chunk.start_line >= 1
        assert chunk.end_line >= chunk.start_line
```

**RAG integration test (`tests/test_rag.py`):**

```python
import pytest
from unittest.mock import patch, MagicMock
from src.rag.generator import build_context, generate_explanation


MOCK_CHUNKS = [
    {
        "id": 1,
        "file_path": "src/models/forecast.py",
        "language": "python",
        "chunk_type": "function",
        "name": "train_model",
        "body": "def train_model(df): ...",
        "start_line": 10,
        "end_line": 30,
        "similarity": 0.92,
    }
]


def test_build_context_includes_file_path():
    context = build_context(MOCK_CHUNKS)
    assert "src/models/forecast.py" in context
    assert "train_model" in context


def test_build_context_respects_token_budget():
    # Create a chunk with very long body
    long_chunk = dict(MOCK_CHUNKS[0])
    long_chunk["body"] = "x = 1\n" * 2000
    context = build_context([long_chunk], max_tokens=100)
    assert len(context) < 10000   # Should be truncated


@patch("src.rag.generator.Mistral")
def test_generate_explanation_calls_mistral(mock_mistral):
    mock_client = MagicMock()
    mock_mistral.return_value = mock_client
    mock_client.chat.complete.return_value.choices[0].message.content = "It trains a model."

    result = generate_explanation("What does train_model do?", MOCK_CHUNKS)
    assert "trains" in result
    mock_client.chat.complete.assert_called_once()
```

```bash
pytest tests/ -v --tb=short
# Expected: all tests pass; mock-based tests don't require live API keys
```

---

## Deployment

**Dockerfile:**

```dockerfile
FROM python:3.11-slim

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/

EXPOSE 8000
CMD ["uvicorn", "src.api.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
```

**Production docker-compose:**

```yaml
# docker-compose.prod.yml
version: "3.9"
services:
  postgres:
    image: pgvector/pgvector:pg15
    environment:
      POSTGRES_DB: copilot
      POSTGRES_USER: copilot
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data

  api:
    build: .
    ports: ["8000:8000"]
    environment:
      DATABASE_URL: postgresql://copilot:${POSTGRES_PASSWORD}@postgres:5432/copilot
      MISTRAL_API_KEY: ${MISTRAL_API_KEY}
    depends_on: [postgres]
    restart: unless-stopped

  frontend:
    build: ./frontend
    ports: ["3000:3000"]
    environment:
      COPILOT_API_URL: http://api:8000
      NEXT_PUBLIC_REPO_ID: ${REPO_ID}
    depends_on: [api]

volumes:
  pgdata:
```

```bash
docker compose -f docker-compose.prod.yml up -d
# Index your codebase:
docker compose exec api python -m src.indexer.run_indexer \
  --repo-id "myorg/myrepo" --path /app/src
```

---

## Resources

1. [Tree-sitter Python bindings](https://github.com/tree-sitter/py-tree-sitter) — API reference for the AST parser used in the indexer
2. [pgvector documentation](https://github.com/pgvector/pgvector) — vector column types, HNSW index options, and cosine similarity query syntax
3. [Mistral embedding models](https://docs.mistral.ai/capabilities/embeddings/) — model options, dimensions, and rate limits for code embedding generation
4. [pygls Language Server Protocol](https://pygls.readthedocs.io/) — LSP server implementation used for the VS Code hover feature
5. [VS Code Extension API](https://code.visualstudio.com/api) — activation events, commands, and webview panels used in the extension
6. [LangChain retrieval docs](https://python.langchain.com/docs/modules/data_connection/) — retriever abstractions and pgvector integration patterns
7. [GitHub REST API — pull request reviews](https://docs.github.com/en/rest/pulls/reviews) — review comment payload schema used by the PR review bot
