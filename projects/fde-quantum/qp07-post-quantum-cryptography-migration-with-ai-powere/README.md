# QP07 — Post-Quantum Cryptography Migration with AI-Powered Key Management

**Modality:** classical-only (no QPU required) **Phase:** 2F **Track:** `fde-quantum` **Status:** not started **Hours target:** 35

## Business Problem

Enterprises running RSA-2048 or ECDSA-256 PKI infrastructure are vulnerable to "Harvest-Now-Decrypt-Later" (HNDL) attacks: nation-state adversaries are harvesting encrypted traffic today to decrypt it once a cryptographically relevant quantum computer (CRQC) exists — estimated by NIST between 2030 and 2035.

NIST finalised its post-quantum cryptography standards in 2024: Kyber (ML-KEM) for key encapsulation and Dilithium (ML-DSA) for digital signatures. However, migrating a large enterprise PKI is operationally complex: audit existing certificates, identify algorithm dependencies, rotate keys without service interruption, and manage hybrid classical/PQC key lifecycles.

The solution is an AI-assisted migration toolkit: `liboqs` (OpenQuantumSafe) provides the NIST PQC primitives, HashiCorp Vault manages the key lifecycle, and a Mistral-powered LangChain agent provides guided migration recommendations, risk assessments, and crypto-agility planning.

## What You Will Build

An enterprise PQC migration toolkit that:

1. Implements Kyber (ML-KEM) key encapsulation and Dilithium (ML-DSA) signing using `liboqs` Python bindings.
2. Integrates with HashiCorp Vault for secure key storage, rotation scheduling, and audit logging.
3. Builds a LangChain + Mistral RAG agent that answers migration questions, assesses PKI inventory risk, and generates migration plans.
4. Implements a hybrid classical/PQC key exchange for backward compatibility during migration.
5. Provides a FastAPI migration assessment endpoint that scans a certificate inventory and returns a prioritised remediation plan.
6. Deploys on Kubernetes with Prometheus monitoring and GitHub Actions CI.

## Architecture

```
               ┌─────────────────────────────────────────────────┐
               │              FastAPI Service                      │
               │   POST /assess-inventory                          │
               │   POST /generate-pqc-key                         │
               │   POST /rotate-keys                               │
               └───────────────────┬─────────────────────────────┘
                                   │
        ┌──────────────────────────▼───────────────────────────────┐
        │                 Migration Orchestrator                    │
        │                                                           │
┌───────▼───────────────┐          ┌───────────────────────────────▼──┐
│  PQC Crypto Layer      │          │  AI Migration Agent              │
│  liboqs (Kyber + Dil.) │          │  LangChain + Mistral API         │
│  Hybrid KEM wrapper    │          │  RAG over NIST PQC docs          │
└───────┬───────────────┘          └──────────────────┬───────────────┘
        │                                             │
┌───────▼───────────────┐          ┌──────────────────▼───────────────┐
│  HashiCorp Vault       │          │  Qdrant Vector Store             │
│  Key lifecycle mgmt    │          │  NIST docs, RFC embeddings       │
│  Audit log             │          └──────────────────────────────────┘
└───────┬───────────────┘
        │
┌───────▼───────────────┐
│     PostgreSQL         │
│  Certificate inventory │
│  Migration audit trail │
└───────────────────────┘
```

## Theory Prerequisites

| Skill ID | Concept | Why you need it |
|----------|---------|-----------------|
| SK01 | Quantum State Representation — Hilbert Spaces | Background for understanding what a CRQC actually does and why it breaks RSA (Shor's algorithm requires quantum superposition) |
| SK32 | Adiabatic Theorem & Quantum Tunnelling | Threat model context: annealing-based attacks on lattice problems remain open research; adiabatic speedup assumptions affect HNDL timelines |

## Engineering Skills Covered

| Skill ID | Skill | What you practice |
|----------|-------|------------------|
| SK42 | Prompt Engineering & Chain-of-Thought Reasoning | Designing chain-of-thought prompts for the Mistral migration agent that reason through PKI dependencies step by step |
| SK43 | Retrieval-Augmented Generation (RAG) Architecture | Indexing NIST PQC documentation, migration guides, and RFCs into Qdrant; retrieving relevant context for the AI agent |
| SK44 | LLM Output Parsing & Safety | Parsing Mistral migration plans into validated Pydantic schemas with guardrails against hallucinated algorithm names |
| SK45 | Semantic Search & Vector Embeddings | Embedding NIST standards documents and querying for relevant migration guidance |
| SK46 | NIST PQC Standards — Kyber, Dilithium, CRYSTALS | Core skill: implementing Kyber KEM and Dilithium signatures with liboqs; understanding lattice hardness assumptions |
| SK47 | Cryptographic Protocol Design & Implementation | Designing the hybrid KEM (classical + PQC) for backward compatibility; composing primitives safely |
| SK48 | Key Lifecycle Management — Generation, Storage, Rotation, Revocation | HashiCorp Vault integration for key generation, rotation scheduling, and SOC-2 audit trails |
| SK49 | Hardware Security Module (HSM) Integration | PKCS#11 interface concepts; understanding where Vault's auto-unseal integrates with HSMs |
| SK53 | MLOps & Continuous Retraining | Triggering Mistral re-indexing when new NIST guidance is published |
| SK54 | Prometheus/Grafana Monitoring | Tracking key rotation coverage, migration progress percentage, and certificate expiry alerts |
| SK33 | SQL Data Modelling — PostgreSQL | Certificate inventory schema, migration audit trail, and remediation priority queue |
| SK34 | Container Orchestration — Docker & Kubernetes | Full production deployment of the migration toolkit |
| SK35 | CI/CD & GitHub Actions | Automated crypto correctness tests (keygen, sign, verify round-trip) |
| SK27 | REST API Design & FastAPI | Migration assessment and key management endpoints |

## Tools & Dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| liboqs (OpenQuantumSafe) | NIST PQC primitives: Kyber KEM, Dilithium signatures | `pip install pyoqs` |
| HashiCorp Vault | Key lifecycle management, HSM integration, audit logging | Docker image + `pip install hvac` |
| Mistral API | LLM backbone for AI migration agent | `pip install mistralai` |
| LangChain | RAG orchestration and structured output parsing | `pip install langchain langchain-community` |
| FastAPI | REST API layer for migration assessment and key management | `pip install fastapi uvicorn` |
| PostgreSQL | Certificate inventory and migration audit trail | `pip install psycopg2-binary sqlalchemy` |
| Docker | Containerised deployment | system install |
| Kubernetes | Production orchestration (optional) | `kubectl`, Helm |
| Qdrant | Vector store for NIST document embeddings | `pip install qdrant-client` |
| Prometheus | Migration coverage and key rotation metrics | `pip install prometheus-client` |
| Pydantic | Request/response validation and LLM output parsing | included with FastAPI |

## Prerequisites

**Complete these first:**
- [ ] SK46: Read the NIST PQC standard documents — FIPS 203 (ML-KEM/Kyber), FIPS 204 (ML-DSA/Dilithium)
- [ ] SK47: Read RFC 9180 (HPKE) to understand the hybrid KEM composition pattern
- [ ] SK48: Complete the HashiCorp Vault getting-started tutorial (dev mode)
- [ ] SK42–SK44: Build a minimal LangChain RAG chain before attempting this project

**Access needed:**
- [ ] Mistral API key (for the AI migration agent)
- [ ] Docker Desktop or Docker Engine (for HashiCorp Vault)
- [ ] Optional: AWS KMS or Azure Key Vault account (for HSM integration exercise)

---

## Step-by-Step Tutorial

### Step 1: Environment Setup

**Goal:** Install dependencies and verify liboqs provides Kyber and Dilithium implementations.

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Fill in: MISTRAL_API_KEY, DATABASE_URL, VAULT_ADDR, VAULT_TOKEN, QDRANT_URL

# Start HashiCorp Vault in dev mode (do not use dev mode in production)
docker run -d --name vault \
  -e VAULT_DEV_ROOT_TOKEN_ID=root-token \
  -p 8200:8200 \
  hashicorp/vault:latest server -dev
```

```python
# src/check_setup.py
import oqs  # pyoqs bindings for liboqs

def check_liboqs() -> dict:
    """Verify liboqs provides Kyber and Dilithium algorithms."""
    supported_kems = oqs.get_enabled_kem_mechanisms()
    supported_sigs = oqs.get_enabled_sig_mechanisms()

    kyber_available = any("Kyber" in m or "ML-KEM" in m for m in supported_kems)
    dilithium_available = any(
        "Dilithium" in m or "ML-DSA" in m for m in supported_sigs
    )

    return {
        "kyber_available": kyber_available,
        "dilithium_available": dilithium_available,
        "available_kems": [m for m in supported_kems if "Kyber" in m or "ML-KEM" in m],
        "available_sigs": [m for m in supported_sigs if "Dilithium" in m or "ML-DSA" in m],
    }


if __name__ == "__main__":
    result = check_liboqs()
    print(result)
    assert result["kyber_available"], "Kyber/ML-KEM not available in liboqs build"
    assert result["dilithium_available"], "Dilithium/ML-DSA not available in liboqs build"
    print("liboqs setup verified.")
```

**Verify:** `python src/check_setup.py` prints `kyber_available: True` and `dilithium_available: True`.

---

### Step 2: Theory Warm-Up — Kyber KEM Round-Trip

**Goal:** Implement a full Kyber-768 KEM key encapsulation and decapsulation round-trip to understand the primitive before integrating with Vault.

```python
# src/crypto/kyber_kem.py
import oqs
from dataclasses import dataclass

# NIST ML-KEM (Kyber) security levels:
# Kyber512  = Level 1 (~AES-128 equivalent)
# Kyber768  = Level 3 (~AES-192 equivalent)  ← recommended for most enterprise use
# Kyber1024 = Level 5 (~AES-256 equivalent)
KYBER_ALG = "Kyber768"


@dataclass
class KyberKeyPair:
    public_key: bytes
    secret_key: bytes
    algorithm: str = KYBER_ALG


@dataclass
class KyberEncapsulation:
    ciphertext: bytes
    shared_secret: bytes


def generate_kyber_keypair() -> KyberKeyPair:
    """Generate a Kyber-768 key pair for key encapsulation."""
    with oqs.KeyEncapsulation(KYBER_ALG) as kem:
        public_key = kem.generate_keypair()
        secret_key = kem.export_secret_key()
    return KyberKeyPair(public_key=public_key, secret_key=secret_key)


def encapsulate(public_key: bytes) -> KyberEncapsulation:
    """
    Encapsulate a shared secret using the recipient's Kyber public key.

    The ciphertext is sent to the recipient; both parties derive the same
    shared_secret, which is then used as a symmetric key (e.g., for AES-256-GCM).
    """
    with oqs.KeyEncapsulation(KYBER_ALG) as kem:
        ciphertext, shared_secret = kem.encap_secret(public_key)
    return KyberEncapsulation(ciphertext=ciphertext, shared_secret=shared_secret)


def decapsulate(ciphertext: bytes, secret_key: bytes) -> bytes:
    """
    Decapsulate the shared secret using the recipient's Kyber secret key.

    Returns:
        shared_secret (32 bytes for Kyber768) — must match encapsulator's secret
    """
    with oqs.KeyEncapsulation(KYBER_ALG, secret_key=secret_key) as kem:
        shared_secret = kem.decap_secret(ciphertext)
    return shared_secret


def kyber_kem_round_trip() -> dict:
    """Demonstrate full KEM round-trip and verify shared secret agreement."""
    keypair = generate_kyber_keypair()
    encap = encapsulate(keypair.public_key)
    recovered_secret = decapsulate(encap.ciphertext, keypair.secret_key)

    secrets_match = encap.shared_secret == recovered_secret
    return {
        "algorithm": KYBER_ALG,
        "public_key_length": len(keypair.public_key),
        "secret_key_length": len(keypair.secret_key),
        "ciphertext_length": len(encap.ciphertext),
        "shared_secret_length": len(encap.shared_secret),
        "secrets_match": secrets_match,
    }


if __name__ == "__main__":
    result = kyber_kem_round_trip()
    print(result)
    assert result["secrets_match"], "Kyber KEM round-trip failed!"
    print("Kyber KEM round-trip: PASSED")
```

**Verify:** `secrets_match: True`. Kyber-768 public key is 1184 bytes, ciphertext is 1088 bytes, shared secret is 32 bytes.

---

### Step 3: Dilithium Signing Round-Trip

**Goal:** Implement Dilithium-3 (ML-DSA-65) signature generation and verification.

```python
# src/crypto/dilithium_sign.py
import oqs
from dataclasses import dataclass

# NIST ML-DSA (Dilithium) security levels:
# Dilithium2  = Level 2  (~128-bit classical)
# Dilithium3  = Level 3  (~192-bit classical) ← enterprise default
# Dilithium5  = Level 5  (~256-bit classical)
DILITHIUM_ALG = "Dilithium3"


@dataclass
class DilithiumKeyPair:
    public_key: bytes
    secret_key: bytes
    algorithm: str = DILITHIUM_ALG


def generate_dilithium_keypair() -> DilithiumKeyPair:
    """Generate a Dilithium-3 key pair for digital signatures."""
    with oqs.Signature(DILITHIUM_ALG) as signer:
        public_key = signer.generate_keypair()
        secret_key = signer.export_secret_key()
    return DilithiumKeyPair(public_key=public_key, secret_key=secret_key)


def sign_message(message: bytes, secret_key: bytes) -> bytes:
    """Sign a message with Dilithium-3 secret key."""
    with oqs.Signature(DILITHIUM_ALG, secret_key=secret_key) as signer:
        signature = signer.sign(message)
    return signature


def verify_signature(message: bytes, signature: bytes, public_key: bytes) -> bool:
    """
    Verify a Dilithium-3 signature.

    Returns:
        True if signature is valid for the given message and public key.
    """
    with oqs.Signature(DILITHIUM_ALG) as verifier:
        return verifier.verify(message, signature, public_key)


def dilithium_sign_round_trip() -> dict:
    """Demonstrate full sign/verify round-trip."""
    keypair = generate_dilithium_keypair()
    message = b"Enterprise data signed with post-quantum Dilithium-3"
    signature = sign_message(message, keypair.secret_key)
    valid = verify_signature(message, signature, keypair.public_key)

    # Tamper test: verify fails for modified message
    tampered = message + b"_tampered"
    tamper_result = verify_signature(tampered, signature, keypair.public_key)

    return {
        "algorithm": DILITHIUM_ALG,
        "public_key_length": len(keypair.public_key),
        "signature_length": len(signature),
        "valid_signature": valid,
        "tamper_detected": not tamper_result,
    }


if __name__ == "__main__":
    result = dilithium_sign_round_trip()
    print(result)
    assert result["valid_signature"], "Dilithium sign round-trip failed!"
    assert result["tamper_detected"], "Tamper detection failed!"
    print("Dilithium signing round-trip: PASSED")
```

**Verify:** `valid_signature: True`, `tamper_detected: True`. Dilithium-3 signature is approximately 3293 bytes.

---

### Step 4: Hybrid KEM — Classical + PQC Backward Compatibility

**Goal:** Implement a hybrid KEM combining ECDH (classical) and Kyber (PQC) for migration-period backward compatibility.

```python
# src/crypto/hybrid_kem.py
import os
import hashlib
import oqs
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from dataclasses import dataclass


@dataclass
class HybridKeyPair:
    ecdh_private_key: bytes    # serialised ECDH private key
    ecdh_public_key: bytes     # serialised ECDH public key
    kyber_public_key: bytes
    kyber_secret_key: bytes


@dataclass
class HybridCiphertext:
    ecdh_public_key: bytes     # ephemeral ECDH public key
    kyber_ciphertext: bytes


def generate_hybrid_keypair() -> HybridKeyPair:
    """Generate a hybrid ECDH-P256 + Kyber-768 key pair."""
    ecdh_key = ec.generate_private_key(ec.SECP256R1())
    ecdh_pub_bytes = ecdh_key.public_key().public_bytes(
        serialization.Encoding.DER,
        serialization.PublicFormat.SubjectPublicKeyInfo,
    )
    ecdh_priv_bytes = ecdh_key.private_bytes(
        serialization.Encoding.DER,
        serialization.PrivateFormat.PKCS8,
        serialization.NoEncryption(),
    )
    with oqs.KeyEncapsulation("Kyber768") as kem:
        kyber_pub = kem.generate_keypair()
        kyber_sec = kem.export_secret_key()
    return HybridKeyPair(
        ecdh_private_key=ecdh_priv_bytes,
        ecdh_public_key=ecdh_pub_bytes,
        kyber_public_key=kyber_pub,
        kyber_secret_key=kyber_sec,
    )


def hybrid_encapsulate(keypair: HybridKeyPair) -> tuple[HybridCiphertext, bytes]:
    """
    Encapsulate shared secret using both ECDH and Kyber.

    The combined shared secret is derived via HKDF from (ecdh_shared || kyber_shared).
    This ensures security as long as either primitive is unbroken.
    """
    # ECDH ephemeral key exchange
    ephemeral = ec.generate_private_key(ec.SECP256R1())
    recipient_pub = serialization.load_der_public_key(keypair.ecdh_public_key)
    ecdh_shared = ephemeral.exchange(ec.ECDH(), recipient_pub)
    ephemeral_pub_bytes = ephemeral.public_key().public_bytes(
        serialization.Encoding.DER,
        serialization.PublicFormat.SubjectPublicKeyInfo,
    )

    # Kyber encapsulation
    with oqs.KeyEncapsulation("Kyber768") as kem:
        kyber_ct, kyber_shared = kem.encap_secret(keypair.kyber_public_key)

    # Hybrid KDF: derive 32-byte key from both secrets
    combined = ecdh_shared + kyber_shared
    hybrid_key = HKDF(
        algorithm=hashes.SHA256(),
        length=32,
        salt=None,
        info=b"hybrid-kem-v1",
    ).derive(combined)

    ciphertext = HybridCiphertext(
        ecdh_public_key=ephemeral_pub_bytes,
        kyber_ciphertext=kyber_ct,
    )
    return ciphertext, hybrid_key


def hybrid_decapsulate(keypair: HybridKeyPair, ciphertext: HybridCiphertext) -> bytes:
    """Recover the hybrid shared secret from the ciphertext."""
    ecdh_priv = serialization.load_der_private_key(keypair.ecdh_private_key, password=None)
    ephemeral_pub = serialization.load_der_public_key(ciphertext.ecdh_public_key)
    ecdh_shared = ecdh_priv.exchange(ec.ECDH(), ephemeral_pub)

    with oqs.KeyEncapsulation("Kyber768", secret_key=keypair.kyber_secret_key) as kem:
        kyber_shared = kem.decap_secret(ciphertext.kyber_ciphertext)

    combined = ecdh_shared + kyber_shared
    return HKDF(
        algorithm=hashes.SHA256(),
        length=32,
        salt=None,
        info=b"hybrid-kem-v1",
    ).derive(combined)
```

**Verify:** `hybrid_encapsulate` and `hybrid_decapsulate` produce identical 32-byte keys. Run the round-trip test in `tests/unit/test_hybrid_kem.py`.

---

### Step 5: HashiCorp Vault Key Lifecycle Integration

**Goal:** Use the Vault `hvac` client to store PQC key pairs, enforce rotation schedules, and retrieve audit logs.

```python
# src/vault/key_manager.py
import os
import json
import base64
from datetime import datetime, timedelta
import hvac

VAULT_ADDR = os.environ.get("VAULT_ADDR", "http://localhost:8200")
VAULT_TOKEN = os.environ.get("VAULT_TOKEN", "root-token")
PQC_SECRET_PATH = "secret/pqc-keys"


def get_vault_client() -> hvac.Client:
    """Return an authenticated Vault client."""
    client = hvac.Client(url=VAULT_ADDR, token=VAULT_TOKEN)
    if not client.is_authenticated():
        raise RuntimeError("Vault authentication failed. Check VAULT_TOKEN.")
    return client


def store_pqc_keypair(
    key_id: str,
    algorithm: str,
    public_key: bytes,
    secret_key: bytes,
    rotation_days: int = 90,
) -> str:
    """
    Store a PQC key pair in Vault's KV secrets engine.

    Args:
        key_id: Unique identifier for this key pair
        algorithm: e.g., "Kyber768" or "Dilithium3"
        public_key: Public key bytes
        secret_key: Secret key bytes (stored in Vault, not in application)
        rotation_days: Days until this key should be rotated

    Returns:
        Vault secret path for this key
    """
    client = get_vault_client()
    secret_path = f"{PQC_SECRET_PATH}/{key_id}"
    rotation_due = (datetime.utcnow() + timedelta(days=rotation_days)).isoformat()

    client.secrets.kv.v2.create_or_update_secret(
        path=f"pqc-keys/{key_id}",
        secret={
            "algorithm": algorithm,
            "public_key": base64.b64encode(public_key).decode(),
            "secret_key": base64.b64encode(secret_key).decode(),
            "created_at": datetime.utcnow().isoformat(),
            "rotation_due": rotation_due,
            "status": "active",
        },
        mount_point="secret",
    )
    return secret_path


def retrieve_public_key(key_id: str) -> dict:
    """
    Retrieve only the public key and metadata (never export secret key to application).
    """
    client = get_vault_client()
    response = client.secrets.kv.v2.read_secret_version(
        path=f"pqc-keys/{key_id}",
        mount_point="secret",
    )
    data = response["data"]["data"]
    return {
        "key_id": key_id,
        "algorithm": data["algorithm"],
        "public_key": base64.b64decode(data["public_key"]),
        "created_at": data["created_at"],
        "rotation_due": data["rotation_due"],
        "status": data["status"],
    }


def rotate_key(key_id: str, new_public_key: bytes, new_secret_key: bytes) -> dict:
    """
    Rotate a PQC key pair: archive the old version and store the new one.
    Vault's KV v2 engine automatically versions secrets.
    """
    store_pqc_keypair(
        key_id=key_id,
        algorithm="Kyber768",
        public_key=new_public_key,
        secret_key=new_secret_key,
        rotation_days=90,
    )
    return {"key_id": key_id, "rotated_at": datetime.utcnow().isoformat()}


def list_keys_due_for_rotation() -> list[dict]:
    """
    Scan all stored keys and return those past their rotation_due date.
    """
    client = get_vault_client()
    try:
        keys = client.secrets.kv.v2.list_secrets(
            path="pqc-keys", mount_point="secret"
        )["data"]["keys"]
    except Exception:
        return []

    overdue = []
    now = datetime.utcnow()
    for key_id in keys:
        meta = retrieve_public_key(key_id.rstrip("/"))
        rotation_due = datetime.fromisoformat(meta["rotation_due"])
        if rotation_due < now:
            overdue.append(meta)
    return overdue
```

**Verify:** `store_pqc_keypair("test-key-001", "Kyber768", pub, sec)` then `retrieve_public_key("test-key-001")` returns the correct algorithm and public key. Vault dev server shows the secret in the UI at `http://localhost:8200/ui`.

---

### Step 6: RAG Pipeline — NIST PQC Documentation

**Goal:** Index NIST PQC standards documents and build a LangChain agent that answers migration questions with structured output.

```python
# src/rag/nist_indexer.py
from langchain_community.document_loaders import PyPDFLoader, WebBaseLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import Qdrant as LangchainQdrant
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams

COLLECTION_NAME = "nist_pqc_docs"
EMBED_MODEL = "sentence-transformers/all-MiniLM-L6-v2"
VECTOR_DIM = 384

NIST_SOURCES = [
    "https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.203.pdf",  # ML-KEM
    "https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.204.pdf",  # ML-DSA
    "https://csrc.nist.gov/pubs/fips/205/final",                  # SLH-DSA
]


def index_nist_documents(qdrant_url: str) -> int:
    """
    Load NIST PQC PDF standards and index into Qdrant.
    Returns number of chunks indexed.
    """
    all_docs = []
    for url in NIST_SOURCES:
        try:
            if url.endswith(".pdf"):
                loader = PyPDFLoader(url)
            else:
                loader = WebBaseLoader([url])
            all_docs.extend(loader.load())
        except Exception as e:
            print(f"Warning: could not load {url}: {e}")

    splitter = RecursiveCharacterTextSplitter(chunk_size=768, chunk_overlap=128)
    chunks = splitter.split_documents(all_docs)

    embeddings = HuggingFaceEmbeddings(model_name=EMBED_MODEL)
    client = QdrantClient(url=qdrant_url)
    existing = {c.name for c in client.get_collections().collections}
    if COLLECTION_NAME not in existing:
        client.create_collection(
            collection_name=COLLECTION_NAME,
            vectors_config=VectorParams(size=VECTOR_DIM, distance=Distance.COSINE),
        )
    store = LangchainQdrant(
        client=client, collection_name=COLLECTION_NAME, embeddings=embeddings
    )
    store.add_documents(chunks)
    return len(chunks)
```

```python
# src/rag/migration_agent.py
import os
from pydantic import BaseModel, Field
from langchain_community.llms import MistralAI
from langchain_community.vectorstores import Qdrant as LangchainQdrant
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain.chains import RetrievalQA
from langchain.output_parsers import PydanticOutputParser
from langchain.prompts import PromptTemplate
from qdrant_client import QdrantClient


class MigrationPlan(BaseModel):
    current_algorithm: str = Field(description="Detected classical algorithm (RSA-2048, ECDSA-256, etc.)")
    pqc_replacement: str = Field(description="Recommended NIST PQC algorithm (ML-KEM-768, ML-DSA-65, etc.)")
    risk_level: str = Field(description="One of: critical, high, medium, low")
    migration_steps: list[str] = Field(description="Ordered list of migration steps")
    backward_compat_required: bool = Field(description="Whether hybrid KEM is required during transition")
    estimated_effort_days: int = Field(description="Estimated engineering effort in days")


def generate_migration_plan(
    certificate_description: str,
    qdrant_url: str,
) -> MigrationPlan:
    """
    Use RAG + Mistral to generate a structured PQC migration plan for a
    described certificate or cryptographic endpoint.
    """
    embeddings = HuggingFaceEmbeddings(
        model_name="sentence-transformers/all-MiniLM-L6-v2"
    )
    client = QdrantClient(url=qdrant_url)
    store = LangchainQdrant(
        client=client,
        collection_name="nist_pqc_docs",
        embeddings=embeddings,
    )
    retriever = store.as_retriever(search_kwargs={"k": 6})

    parser = PydanticOutputParser(pydantic_object=MigrationPlan)
    prompt = PromptTemplate(
        input_variables=["context", "question"],
        template=(
            "You are a post-quantum cryptography migration expert.\n"
            "Use the NIST PQC documentation below to generate a migration plan.\n"
            "Only recommend algorithms from NIST FIPS 203, 204, or 205.\n\n"
            "NIST Documentation:\n{context}\n\n"
            "Certificate/Endpoint Description:\n{question}\n\n"
            "Return a JSON migration plan:\n{format_instructions}"
        ),
        partial_variables={"format_instructions": parser.get_format_instructions()},
    )
    llm = MistralAI(
        model="mistral-small",
        api_key=os.environ["MISTRAL_API_KEY"],
        temperature=0.0,
    )
    chain = RetrievalQA.from_chain_type(
        llm=llm, retriever=retriever, chain_type_kwargs={"prompt": prompt}
    )
    raw = chain.run(certificate_description)
    return parser.parse(raw)
```

**Verify:** `generate_migration_plan("RSA-2048 TLS certificate for web API, 5-year validity, handles financial data", qdrant_url)` returns a `MigrationPlan` with `pqc_replacement` containing "ML-KEM" or "ML-DSA" and `risk_level` in `["critical", "high", "medium", "low"]`.

---

### Step 7: Certificate Inventory Scanner

**Goal:** Build a scanner that ingests a certificate inventory CSV and generates prioritised migration recommendations.

```python
# src/inventory/scanner.py
import csv
from datetime import datetime
from dataclasses import dataclass
from enum import Enum


class RiskLevel(str, Enum):
    CRITICAL = "critical"   # RSA < 2048 or expiry < 180 days
    HIGH = "high"           # RSA-2048 or ECDSA-256 with expiry > 2 years
    MEDIUM = "medium"       # RSA-3072 or ECDSA-384
    LOW = "low"             # Already using PQC or expiry < 1 year


@dataclass
class CertificateRecord:
    cert_id: str
    common_name: str
    algorithm: str
    key_size: int
    expiry_date: datetime
    environment: str    # prod, staging, dev
    service_name: str


def assess_certificate_risk(cert: CertificateRecord) -> RiskLevel:
    """
    Assess the quantum migration risk level for a single certificate.

    Risk drivers:
    - Algorithm: RSA < 2048 is critical; RSA-2048/ECDSA-256 is high
    - Expiry: long-lived certs are higher risk (more exposure window)
    - Environment: production is higher priority than dev
    """
    days_to_expiry = (cert.expiry_date - datetime.utcnow()).days

    # Already PQC
    if any(pqc in cert.algorithm.upper() for pqc in ["KYBER", "DILITHIUM", "ML-KEM", "ML-DSA"]):
        return RiskLevel.LOW

    # Weak classical
    if cert.algorithm.upper().startswith("RSA") and cert.key_size < 2048:
        return RiskLevel.CRITICAL

    # Standard classical (most common case)
    if cert.algorithm.upper() in ("RSA-2048", "ECDSA-256", "ECDSA-P256"):
        if cert.environment == "prod" and days_to_expiry > 365 * 2:
            return RiskLevel.HIGH
        return RiskLevel.MEDIUM

    # Stronger classical
    if cert.algorithm.upper() in ("RSA-3072", "RSA-4096", "ECDSA-384", "ECDSA-521"):
        return RiskLevel.MEDIUM

    return RiskLevel.HIGH  # Unknown algorithm: treat as high risk


def scan_inventory_csv(csv_path: str) -> list[dict]:
    """
    Scan a certificate inventory CSV and return prioritised migration list.

    CSV columns: cert_id, common_name, algorithm, key_size, expiry_date,
                 environment, service_name
    """
    records = []
    with open(csv_path) as f:
        reader = csv.DictReader(f)
        for row in reader:
            cert = CertificateRecord(
                cert_id=row["cert_id"],
                common_name=row["common_name"],
                algorithm=row["algorithm"],
                key_size=int(row["key_size"]),
                expiry_date=datetime.fromisoformat(row["expiry_date"]),
                environment=row["environment"],
                service_name=row["service_name"],
            )
            risk = assess_certificate_risk(cert)
            records.append({
                "cert_id": cert.cert_id,
                "common_name": cert.common_name,
                "algorithm": cert.algorithm,
                "environment": cert.environment,
                "risk_level": risk.value,
                "days_to_expiry": (cert.expiry_date - datetime.utcnow()).days,
            })

    # Sort by risk (critical first) then by days_to_expiry ascending
    risk_order = {"critical": 0, "high": 1, "medium": 2, "low": 3}
    return sorted(records, key=lambda r: (risk_order[r["risk_level"]], r["days_to_expiry"]))
```

**Verify:** `scan_inventory_csv("tests/fixtures/sample_inventory.csv")` returns a list sorted with `critical` entries first. An RSA-1024 cert appears before an RSA-2048 cert.

---

### Step 8: FastAPI Migration Assessment Endpoint

**Goal:** Expose inventory scanning and AI migration planning as production-ready FastAPI endpoints.

```python
# src/api/main.py
import os
import uuid
from fastapi import FastAPI, HTTPException, UploadFile, File
from pydantic import BaseModel, Field
import tempfile
from src.inventory.scanner import scan_inventory_csv
from src.rag.migration_agent import generate_migration_plan
from src.vault.key_manager import store_pqc_keypair, list_keys_due_for_rotation
from src.crypto.kyber_kem import generate_kyber_keypair
from src.crypto.dilithium_sign import generate_dilithium_keypair

app = FastAPI(
    title="PQC Migration API",
    description="AI-assisted post-quantum cryptography migration toolkit",
    version="1.0.0",
)


class PQCKeyRequest(BaseModel):
    key_id: str = Field(description="Unique identifier for the key pair")
    algorithm: str = Field(
        default="Kyber768",
        description="PQC algorithm: Kyber768, Kyber1024, Dilithium3, Dilithium5",
    )
    rotation_days: int = Field(default=90, ge=30, le=365)


class PQCKeyResponse(BaseModel):
    key_id: str
    algorithm: str
    vault_path: str
    public_key_length: int


class CertAssessmentRequest(BaseModel):
    description: str = Field(
        description="Description of the certificate or cryptographic endpoint to assess"
    )


@app.post("/generate-pqc-key", response_model=PQCKeyResponse)
async def generate_pqc_key(request: PQCKeyRequest) -> PQCKeyResponse:
    """
    Generate a PQC key pair using liboqs and store it in HashiCorp Vault.
    Returns metadata only — the secret key never leaves Vault.
    """
    qdrant_url = os.environ.get("QDRANT_URL", "http://localhost:6333")

    if "Kyber" in request.algorithm or "ML-KEM" in request.algorithm:
        keypair = generate_kyber_keypair()
    elif "Dilithium" in request.algorithm or "ML-DSA" in request.algorithm:
        keypair = generate_dilithium_keypair()
    else:
        raise HTTPException(
            status_code=422, detail=f"Unsupported algorithm: {request.algorithm}"
        )

    vault_path = store_pqc_keypair(
        key_id=request.key_id,
        algorithm=request.algorithm,
        public_key=keypair.public_key,
        secret_key=keypair.secret_key,
        rotation_days=request.rotation_days,
    )

    return PQCKeyResponse(
        key_id=request.key_id,
        algorithm=request.algorithm,
        vault_path=vault_path,
        public_key_length=len(keypair.public_key),
    )


@app.post("/assess-certificate")
async def assess_certificate(request: CertAssessmentRequest) -> dict:
    """
    Use the RAG + Mistral agent to generate a PQC migration plan for a
    described certificate or cryptographic endpoint.
    """
    qdrant_url = os.environ.get("QDRANT_URL", "http://localhost:6333")
    try:
        plan = generate_migration_plan(request.description, qdrant_url)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))
    return plan.dict()


@app.post("/scan-inventory")
async def scan_inventory(file: UploadFile = File(...)) -> list[dict]:
    """
    Upload a certificate inventory CSV and receive a prioritised migration list.
    """
    if not file.filename.endswith(".csv"):
        raise HTTPException(status_code=422, detail="File must be a CSV")

    with tempfile.NamedTemporaryFile(suffix=".csv", delete=False) as tmp:
        tmp.write(await file.read())
        tmp_path = tmp.name

    return scan_inventory_csv(tmp_path)


@app.get("/rotation-due")
async def rotation_due() -> list[dict]:
    """List all PQC keys in Vault that are past their rotation_due date."""
    return list_keys_due_for_rotation()


@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}
```

**Verify:** `POST /generate-pqc-key` with `{"key_id": "test-001", "algorithm": "Kyber768"}` returns 200 with `public_key_length: 1184`. `POST /assess-certificate` returns a valid `MigrationPlan` JSON.

---

### Step 9: Kubernetes Deployment

**Goal:** Deploy the migration toolkit on Kubernetes with Vault as an external secret store and Prometheus monitoring.

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pqc-migration-api
  labels:
    app: pqc-migration-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: pqc-migration-api
  template:
    metadata:
      labels:
        app: pqc-migration-api
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9090"
    spec:
      containers:
        - name: api
          image: ghcr.io/your-org/pqc-migration-api:latest
          ports:
            - containerPort: 8000
            - containerPort: 9090   # Prometheus metrics
          env:
            - name: VAULT_ADDR
              value: "http://vault:8200"
            - name: VAULT_TOKEN
              valueFrom:
                secretKeyRef:
                  name: vault-credentials
                  key: token
            - name: MISTRAL_API_KEY
              valueFrom:
                secretKeyRef:
                  name: llm-credentials
                  key: mistral-api-key
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: db-credentials
                  key: url
          livenessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 10
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 5
            periodSeconds: 10
```

**Verify:** `kubectl apply -f k8s/` deploys cleanly. `kubectl get pods` shows 2/2 replicas Running. `kubectl port-forward svc/pqc-migration-api 8000:8000` allows local API access.

---

### Step 10: CI/CD and Monitoring

**Goal:** Add GitHub Actions CI with cryptographic round-trip tests and a docker-compose for local development.

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
      vault:
        image: hashicorp/vault:latest
        env:
          VAULT_DEV_ROOT_TOKEN_ID: root-token
        ports:
          - "8200:8200"
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_DB: pqc_migration
        ports:
          - "5432:5432"
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      qdrant:
        image: qdrant/qdrant:latest
        ports:
          - "6333:6333"
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install -r requirements.txt
      - run: pytest tests/ -v --tb=short
        env:
          VAULT_ADDR: http://localhost:8200
          VAULT_TOKEN: root-token
          DATABASE_URL: postgresql://postgres:test@localhost:5432/pqc_migration
          QDRANT_URL: http://localhost:6333
          MISTRAL_API_KEY: ${{ secrets.MISTRAL_API_KEY }}
```

**Verify:** CI passes. `test_kyber_round_trip` and `test_dilithium_round_trip` both complete in under 5 seconds. `test_vault_store_retrieve` confirms public key round-trip.

---

## Testing

```bash
# Unit tests — no external services required
pytest tests/unit/test_kyber_kem.py -v           # Kyber round-trip
pytest tests/unit/test_dilithium_sign.py -v      # Dilithium sign/verify
pytest tests/unit/test_hybrid_kem.py -v          # Hybrid KEM round-trip
pytest tests/unit/test_inventory_scanner.py -v   # Risk assessment logic

# Integration tests — requires Vault and Qdrant running
pytest tests/integration/test_vault_key_manager.py -v
pytest tests/integration/test_migration_agent.py -v
pytest tests/integration/test_api.py -v
```

Key test cases:
- Kyber KEM: `encap_secret` → `decap_secret` produces identical 32-byte shared secrets
- Dilithium: valid signature verifies True; message tampered by 1 bit verifies False
- Hybrid KEM: combined secret is identical between encapsulator and decapsulator
- `scan_inventory_csv` sorts CRITICAL before HIGH before MEDIUM
- Pydantic `MigrationPlan` raises `ValidationError` when `risk_level` is not one of the allowed values
- FastAPI `POST /generate-pqc-key` with unsupported algorithm returns 422

---

## Deployment

```bash
# Local development
docker compose up --build -d

# Kubernetes production
helm install vault hashicorp/vault --namespace vault --create-namespace
kubectl apply -f k8s/

# Verify deployment
kubectl rollout status deployment/pqc-migration-api
curl http://localhost:8000/health
```

---

## Resources

1. [NIST FIPS 203 — ML-KEM (Kyber)](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.203.pdf) — Official Kyber standard
2. [NIST FIPS 204 — ML-DSA (Dilithium)](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.204.pdf) — Official Dilithium standard
3. [Open Quantum Safe / liboqs](https://openquantumsafe.org/) — NIST PQC reference implementations
4. [pyoqs Documentation](https://github.com/open-quantum-safe/liboqs-python) — Python bindings for liboqs
5. [HashiCorp Vault Documentation](https://developer.hashicorp.com/vault/docs) — KV v2 secrets engine and PKCS#11
6. [NIST PQC Migration Guide (NIST IR 8547)](https://doi.org/10.6028/NIST.IR.8547.ipd) — Enterprise migration framework
7. [RFC 9180 — Hybrid Public Key Encryption](https://www.rfc-editor.org/rfc/rfc9180) — HPKE for hybrid KEM composition
8. [LangChain RAG Documentation](https://python.langchain.com/docs/use_cases/question_answering/) — RAG pipeline construction
