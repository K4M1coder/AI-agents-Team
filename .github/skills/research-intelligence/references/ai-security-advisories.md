# AI Security Advisories

> **Operator/Integrator Reference**: This file documents CVE sources, adversarial ML threat categories, supply chain risks, and incident classification specific to AI/ML infrastructure. Use for defensive security posture assessment, not for offensive exploitation.

---

## CVE & Security Advisory Sources

| Source | URL / Feed | Components Covered | Update Frequency |
| -------- | ----------- | ------------------- | ----------------- |
| PyTorch Security | <https://github.com/pytorch/pytorch/security/advisories> | PyTorch core, CUDA extensions, torchscript | As-announced |
| vLLM Security | <https://github.com/vllm-project/vllm/security/advisories> | vLLM serving, OpenAI-compatible API, LoRA loading | As-announced |
| Hugging Face Security | <https://github.com/huggingface/transformers/security/advisories> | `transformers`, `tokenizers`, `hub_sdk` | As-announced |
| MLflow GHSA | <https://github.com/mlflow/mlflow/security/advisories> | MLflow server, artifact store, model registry | As-announced |
| Triton CVEs | <https://github.com/openai/triton/security/advisories> | Triton compiler, GPU kernels | As-announced |
| Ollama Advisories | <https://github.com/ollama/ollama/releases> | Local LLM server, model loading | Per release |
| Apache Airflow | <https://airflow.apache.org/docs/apache-airflow/stable/security/report-vulnerabilities.html> | ML pipeline orchestration | As-announced |
| Kubeflow Issues | <https://github.com/kubeflow/kubeflow/security/advisories> | Kubeflow Pipelines, Training Operator | As-announced |
| NIST NVD — PyTorch | <https://nvd.nist.gov/vuln/search/results?query=pytorch> | All PyTorch CVEs (cross-referenced) | Continuous |
| NIST NVD — vLLM | <https://nvd.nist.gov/vuln/search/results?query=vllm> | All vLLM CVEs | Continuous |
| OSS Security Mailing List | <https://oss-security.openwall.org/wiki/mailing-lists/oss-security> | Open-source ML tooling disclosures | Continuous |
| GitHub Advisory Database | <https://github.com/advisories?query=ecosystem%3Apip> | All PyPI package advisories | Continuous |

### CVE Query Pattern (GitHub Advisory API)

```python
import requests

GHSA_ECOSYSTEM_PACKAGES = [
    ("pip", "torch"),
    ("pip", "vllm"),
    ("pip", "transformers"),
    ("pip", "mlflow"),
    ("pip", "triton"),
    ("pip", "ollama"),
    ("pip", "ray"),             # used in distributed training + vLLM
    ("pip", "langchain"),
    ("pip", "llama-index"),
    ("pip", "accelerate"),
    ("pip", "peft"),
    ("pip", "trl"),
]

def query_github_advisories(ecosystem: str, package: str, token: str) -> list[dict]:
    """Query GitHub Advisory Database for a specific package."""
    query = """
    query($ecosystem: SecurityAdvisoryEcosystem!, $package: String!) {
      securityVulnerabilities(ecosystem: $ecosystem, package: $package, first: 20, orderBy: {field: UPDATED_AT, direction: DESC}) {
        nodes {
          advisory {
            ghsaId
            summary
            severity
            publishedAt
            updatedAt
            references { url }
          }
          vulnerableVersionRange
          firstPatchedVersion { identifier }
        }
      }
    }
    """
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    r = requests.post(
        "https://api.github.com/graphql",
        json={"query": query, "variables": {"ecosystem": ecosystem.upper(), "package": package}},
        headers=headers,
        timeout=30,
    )
    r.raise_for_status()
    nodes = r.json()["data"]["securityVulnerabilities"]["nodes"]
    return [
        {
            "ghsa_id": n["advisory"]["ghsaId"],
            "summary": n["advisory"]["summary"],
            "severity": n["advisory"]["severity"],
            "published": n["advisory"]["publishedAt"],
            "affected_versions": n["vulnerableVersionRange"],
            "patched_version": n.get("firstPatchedVersion", {}).get("identifier", "No patch"),
        }
        for n in nodes
    ]
```

---

## Adversarial ML Threat Categories

### 1. Prompt Injection

**Definition**: Attacker injects instructions into user input or retrieved context that override system prompts or hijack agent behavior.

**Variants**:

- **Direct injection**: Malicious text in user input (e.g., "Ignore previous instructions...")
- **Indirect injection**: Malicious content in tool outputs, retrieved documents, or web pages fetched by agent
- **Multi-turn injection**: Spreading injection across conversation turns to evade per-turn defenses

**Detection Methods**:

- Input/output classification layer (specialized injection detector model)
- Perplexity filtering (injections tend to have distinctive perplexity signatures)
- Structural anomaly detection (sudden shift in instruction-following behavior)
- Canary token monitoring (special tokens that should never appear in output)

**Mitigation**:

- Privilege separation: differentiate trusted system prompts from untrusted user context
- Instruction hierarchy enforcement in system prompt
- Output filtering before action execution
- Sandbox tool calls independently of LLM reasoning chain

### 2. Model Extraction

**Definition**: Attacker reconstructs a proprietary model's capabilities through repeated API queries.

**Variants**:

- **Functional extraction**: Replicate input→output mapping via distillation
- **Parameter theft**: Infer weights via side-channel (timing, energy) or API response analysis
- **Architecture probing**: Determine model architecture through carefully crafted inputs

**Detection Methods**:

- Query rate limiting + anomaly detection (unusually systematic query patterns)
- Watermarking (embed imperceptible watermarks in model outputs)
- Output randomization (add calibrated noise to logits for API responses)
- API key fingerprinting + rate enforcement

**Mitigation**:

- Rate limiting per API key + IP
- Output perturbation
- Access logging + anomaly alerting
- Model output watermarks (logit-based or text-based)

### 3. Membership Inference

**Definition**: Attacker determines whether a specific datapoint was in the training set.

**Risk Level**: High for medical/legal/personal data; moderate for general web crawls.

**Detection Methods**:

- Shadow model attacks (train models on candidate data, compare loss patterns)
- LiRA (likelihood ratio attacks) — state-of-the-art membership inference

**Mitigation**:

- Differential privacy training (DP-SGD, epsilon budgeting)
- Output confidence score suppression
- Selective data exclusion (remove PII from training sets)

### 4. Model Inversion

**Definition**: Attacker uses model outputs to reconstruct training data (e.g., faces, medical records, code).

**Mitigation**:

- Output truncation (suppress raw logits)
- Response rate limiting
- Differential privacy

### 5. Backdoor / Trojan Attacks

**Definition**: Attacker embeds trigger-conditioned behavior into model weights during training or fine-tuning.

**Variants**:

- **Data poisoning**: Poison training data with triggered examples
- **Model poisoning**: Directly modify weights (e.g., LoRA adapter injection)
- **Activation patching**: Modify activations at inference time (requires model serving access)

**Detection Methods**:

- Neural Cleanse / ABS (Artificial Brain Stimulation) — scan for trigger patterns
- Activation clustering — identify outlier neuron activations
- Fine-tuning invariant analysis — retrain on clean data; observe behavioral change
- Spectral signatures (Tran et al.) — PCA on feature representations

**Checklist for Evaluating Downloaded Checkpoints**:

- [ ] Download from verified source (official lab HF org or signed release)
- [ ] Verify file hashes against published checksums
- [ ] Test on behavioral trigger probes from backdoor scan suites
- [ ] Load in isolated environment before connecting to production systems
- [ ] Evaluate on OOD inputs to detect unusual confidence patterns

---

## Supply Chain Risk Matrix

| Attack Vector | Example | Indicators | Severity |
| -------------- | --------- | ------------ | --------- |
| **Poisoned training data** | Injected backdoors in Common Crawl subsets | Unusual model behavior on specific inputs | High |
| **Backdoored pre-trained weights** | Modified HuggingFace model files | Hash mismatch, unexpected files (.pkl), poor model card | Critical |
| **Malicious HF repository** | Fork of popular model with modified weights | Unknown org, no license, new account, large checkpoint | High |
| **Dependency confusion** | Typosquatted PyPI package (`torchh`, `transfromers`) | Unexpected package name similarity, new publisher | High |
| **Compromised CI pipeline** | Attacker-modified GitHub Actions workflow injects payload | Unsigned commits to workflow files, unexpected workflow changes | Critical |
| **Malicious LoRA adapter** | Adapter file with embedded trigger behavior | Unusual adapter size, aggressive fine-tuning claims | High |
| **Tampered ONNX/GGUF models** | Modified converter inserts branching behavior | Tool-converted files from unofficial sources | Medium |
| **Prompt injection via RAG content** | Malicious web page content injected into retrieved context | Indirect instruction-following from retrieved docs | Medium |

---

## AI API Abuse Patterns

### Model Extraction via Repeated Queries

**Indicators**:

- Uniform, systematically varied inputs (grid-pattern or random seed)
- Very high query volume from single API key
- Queries covering entire domain (all numbers, all letter combinations)
- No apparent user-facing application pattern

**Detection Query**:

```python
# Simplified: flag API keys with suspicious query patterns
from collections import Counter

def detect_extraction_attempt(query_log: list[dict], window_hours: int = 24) -> list[str]:
    """Flag API keys with extraction-like behavior."""
    from datetime import datetime, timedelta
    cutoff = datetime.now() - timedelta(hours=window_hours)
    recent = [q for q in query_log if q["timestamp"] >= cutoff]

    key_counts = Counter(q["api_key"] for q in recent)
    flagged = []
    for key, count in key_counts.items():
        if count > 10_000:  # tune threshold per application
            flagged.append(key)
    return flagged
```

### Rate Limit Bypass Patterns

- **Key rotation**: Rapid cycling through many API keys
- **IP rotation**: Proxy/VPN rotation to bypass IP-based limits
- **Timing jitter**: Slightly randomized query timing to evade rate detection

---

## Incident Severity Classification — AI-Specific Threats

| Severity | Definition | Examples | Response SLA |
| ---------- | ----------- | --------- | ------------- |
| **SEV-1 Critical** | Active exploitation of production AI system; data exfiltration; full model theft | Active backdoor triggered, confirmed prompt injection leading to data leak | 15 min escalation |
| **SEV-2 High** | Confirmed vulnerability in production stack; imminent exploitation risk | Critical CVE in serving framework (CVSS ≥ 7), unverified checkpoint in production | 2 hour response |
| **SEV-3 Medium** | Known vulnerability, no confirmed exploitation; supply chain risk identified | Medium-severity CVE (CVSS 4–6.9), suspicious HF upload identified | 24-hour response |
| **SEV-4 Low** | Informational; no immediate risk; requires monitoring | Low-severity CVE, new dependency added without review, theoretical attack disclosed | Weekly digest |

---

## Cross-References

- `skills/executant-research-intelligence/references/code-intelligence.md` — model card red flags + HF monitoring
- `skills/executant-research-intelligence/references/paper-monitoring-workflows.md` — advisory digest template
- `agents/executant-security-ops.agent.md` — CVE escalation and infrastructure hardening
- `agents/executant-ai-safety.agent.md` — adversarial ML threat response
