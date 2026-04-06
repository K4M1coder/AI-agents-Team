# Code & Model Intelligence

> **Operator/Integrator Reference**: This file documents patterns for monitoring HF Hub, GitHub, and Papers With Code for significant AI/ML code and model releases. These patterns are for legitimate research intelligence and security assessment purposes.

---

## HF Hub Model Drop Detection

### Large Checkpoint Detection

Large file uploads from unknown or new HF accounts warrant closer scrutiny — they may indicate leaked weights, unattributed derivatives, or security risks.

```python
from huggingface_hub import HfApi, list_models
from datetime import datetime, timedelta
import re

api = HfApi()

def detect_anomalous_uploads(
    min_size_gb: float = 1.0,
    days_back: int = 2,
    known_orgs: set[str] | None = None
) -> list[dict]:
    """Detect large, recent model uploads from unknown or new accounts."""
    if known_orgs is None:
        known_orgs = {
            "deepseek-ai", "meta-llama", "facebookresearch", "google",
            "deepmind", "openai", "mistralai", "CohereForAI", "allenai",
            "microsoft", "nvidia", "HuggingFaceH4", "HuggingFaceFW",
            "moonshotai", "xai-org", "Qwen", "EleutherAI",
        }

    cutoff = datetime.now() - timedelta(days=days_back)
    flagged = []

    models = list_models(
        sort="lastModified",
        direction=-1,
        limit=200,
        cardData=True,      # include model card info
    )

    for m in models:
        last_mod = getattr(m, "lastModified", None)
        if not last_mod or last_mod < cutoff:
            continue

        org = m.modelId.split("/")[0] if "/" in m.modelId else m.modelId
        is_known_org = org.lower() in {k.lower() for k in known_orgs}

        # Check model card for red flags
        card = getattr(m, "cardData", {}) or {}
        has_license = bool(card.get("license"))
        has_datasets = bool(card.get("datasets"))
        has_eval_results = bool(card.get("eval_results"))

        # Size heuristic: require model_info for accurate size
        try:
            info = api.model_info(m.modelId)
            size_bytes = sum(
                s.size for s in (info.siblings or []) if s.size
            )
            size_gb = size_bytes / 1e9
        except Exception:
            size_gb = 0.0

        flags = []
        if not is_known_org:
            flags.append("UNKNOWN_ORG")
        if not has_license:
            flags.append("NO_LICENSE")
        if not has_datasets:
            flags.append("NO_TRAINING_DATA_DISCLOSURE")
        if not has_eval_results:
            flags.append("NO_EVAL_RESULTS")
        if size_gb >= min_size_gb:
            flags.append(f"LARGE_CHECKPOINT_{size_gb:.1f}GB")

        if flags:
            # Check for gated/private status
            is_gated = getattr(m, "gated", False)
            flagged.append({
                "model_id": m.modelId,
                "org": org,
                "modified": last_mod,
                "size_gb": size_gb,
                "flags": flags,
                "is_known_org": is_known_org,
                "is_gated": is_gated,
                "tags": m.tags or [],
                "url": f"https://huggingface.co/{m.modelId}",
            })

    return sorted(flagged, key=lambda x: x["size_gb"], reverse=True)


# Example usage
suspicious = detect_anomalous_uploads(min_size_gb=1.0, days_back=2)
for entry in suspicious[:10]:
    print(f"\n[{'!!' if 'UNKNOWN_ORG' in entry['flags'] else 'OK'}] {entry['model_id']}")
    print(f"  Size: {entry['size_gb']:.1f} GB | Flags: {', '.join(entry['flags'])}")
    print(f"  URL: {entry['url']}")
```

### File Hash Verification for Known Models

When a model is being re-uploaded or a new version claimed to match a known checkpoint, verify via SHA256 of model files:

```python
import hashlib
from huggingface_hub import hf_hub_download

def hash_model_file(repo_id: str, filename: str, local_dir: str = "/tmp/model_check") -> str:
    """Download and hash a specific model file for integrity verification."""
    path = hf_hub_download(repo_id=repo_id, filename=filename, local_dir=local_dir)
    sha256 = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            sha256.update(chunk)
    return sha256.hexdigest()

# Compare with published hash from official release
expected_hash = "abc123..."  # hash from official release notes
actual_hash = hash_model_file("unknown-org/model-name", "pytorch_model.bin")
if actual_hash != expected_hash:
    print("HASH MISMATCH: Potential unauthorized derivative or corruption")
```

---

## Model Card Red Flags Checklist

Evaluate any new model release against this checklist before deploying or sharing:

| Check | Green (Safe) | Yellow (Investigate) | Red (Escalate) |
| ------- | ------------- | --------------------- | ---------------- |
| License | OSI-approved / Apache 2 / MIT / Llama Community | Custom license, restrictions | No license field |
| Model Architecture | Documented + known | Documented but novel | Architecture description absent |
| Training Data | Disclosed + filtered | Partially disclosed | No training data disclosure |
| Evaluation | Published on standard benchmarks | Custom benchmarks only | No evaluation results |
| Code | Training code released | Inference-only code | No code |
| Author Affiliation | Verified institution or known lab | Individual account, legitimate | Anonymous / no profile |
| File Structure | Standard HF format (config.json, tokenizer, shards) | Extra unexpected files | .pkl, .exe, .sh files present |
| Model Card Completeness | Full card with all sections | Partial (missing eval) | Stub or auto-generated only |
| Downstream Use | Stated intended uses + prohibited uses | Partial | No use case documentation |
| Gated Access | Gated with identity verification | Ungated but small | Claims to be "open" but blocks API access |

### File Structure Anomaly Detection

```python
from huggingface_hub import model_info

SAFE_EXTENSIONS = {
    ".bin", ".safetensors", ".json", ".txt", ".md", ".py",
    ".yaml", ".yml", ".model", ".tiktoken", ".gguf", ".ggml",
}

DANGEROUS_EXTENSIONS = {".pkl", ".exe", ".sh", ".bat", ".ps1", ".js", ".php"}

SUSPICIOUS_EXTENSIONS = {".zip", ".tar", ".gz", ".7z", ".rar"}

def check_file_structure(repo_id: str) -> dict:
    """Check model repo file structure for anomalies."""
    info = model_info(repo_id)
    files = [s.rfilename for s in (info.siblings or [])]

    dangerous = [f for f in files if any(f.endswith(ext) for ext in DANGEROUS_EXTENSIONS)]
    suspicious = [f for f in files if any(f.endswith(ext) for ext in SUSPICIOUS_EXTENSIONS)]
    unknown = [f for f in files if not any(f.endswith(ext) for ext in SAFE_EXTENSIONS | DANGEROUS_EXTENSIONS | SUSPICIOUS_EXTENSIONS)]

    has_config = any(f == "config.json" for f in files)
    has_tokenizer = any("tokenizer" in f for f in files)
    has_weights = any(f.endswith((".bin", ".safetensors")) for f in files)

    return {
        "repo_id": repo_id,
        "total_files": len(files),
        "dangerous_files": dangerous,
        "suspicious_files": suspicious,
        "unknown_extension_files": unknown,
        "has_config": has_config,
        "has_tokenizer": has_tokenizer,
        "has_weights": has_weights,
        "risk_level": "HIGH" if dangerous else ("MEDIUM" if suspicious else "LOW"),
    }
```

---

## Papers With Code — SOTA Tracking

Papers With Code maintains leaderboards per dataset/benchmark. Track when a known model is surpassed.

```python
import requests

def get_sota_for_benchmark(task_slug: str, dataset_slug: str, top_n: int = 5) -> list[dict]:
    """
    Retrieve current SOTA results from Papers With Code.

    task_slug examples: "language-modelling", "image-classification", "question-answering"
    dataset_slug examples: "imagenet", "mmlu", "gsm8k", "hellaswag"
    """
    url = f"https://paperswithcode.com/api/v1/sota/results/?task={task_slug}&dataset={dataset_slug}"
    r = requests.get(url, timeout=30)
    r.raise_for_status()
    data = r.json()
    results = data.get("results", [])
    return results[:top_n]

# Example: track MMLU leaderboard
mmlu_sota = get_sota_for_benchmark("multi-task-language-understanding", "mmlu", top_n=5)
for entry in mmlu_sota:
    print(f"{entry.get('model_name', 'N/A')} — {entry.get('best_result', 'N/A')} — {entry.get('paper_date', 'N/A')}")
```

### Benchmark Tracker Configuration

Maintain a config file (e.g., `benchmark-watchlist.yaml`) with benchmarks relevant to active projects:

```yaml
# benchmark-watchlist.yaml
benchmarks:
  - task: "language-modelling"
    dataset: "wikitext-103"
    metric: "bits per character"
    direction: minimize    # lower is better
    current_best_model: "Mamba-2 3B"
    current_best_value: 0.882

  - task: "image-classification"
    dataset: "imagenet"
    metric: "top-1 accuracy"
    direction: maximize
    current_best_model: "V-JEPA 2 ViT-G"
    current_best_value: 90.4

  - task: "text-generation"
    dataset: "mmlu"
    metric: "accuracy"
    direction: maximize
    current_best_model: "DeepSeek-V3"
    current_best_value: 90.0

check_frequency: weekly
alert_threshold_pct: 0.5   # alert if exceeded by 0.5+ points
```

---

## GitHub Trending — AI/ML Alerts

```python
import requests
from bs4 import BeautifulSoup

def get_github_trending(language: str = "python", since: str = "weekly") -> list[dict]:
    """
    Scrape GitHub trending page for AI/ML repositories.

    since: "daily", "weekly", "monthly"
    Note: GitHub does not provide an official trending API; scraping is subject to ToS.
    Consider using GitHub Search API as alternative.
    """
    url = f"https://github.com/trending/{language}?since={since}"
    headers = {"Accept": "text/html", "User-Agent": "executant-research-intelligence-bot/1.0"}
    r = requests.get(url, headers=headers, timeout=30)
    r.raise_for_status()
    soup = BeautifulSoup(r.text, "html.parser")

    repos = []
    for article in soup.select("article.Box-row"):
        name_tag = article.select_one("h2 a")
        if not name_tag:
            continue
        desc_tag = article.select_one("p")
        stars_tags = article.select("a.Link--muted")

        repos.append({
            "repo": name_tag.get_text(strip=True).replace("\n", "").replace(" ", ""),
            "description": desc_tag.get_text(strip=True) if desc_tag else "",
            "url": f"https://github.com{name_tag['href']}",
            "stars_this_period": stars_tags[-1].get_text(strip=True) if stars_tags else "N/A",
        })
    return repos

# Alternatively, use GitHub REST API for repo search (avoids scraping)
def search_github_ai_repos(query: str, sort: str = "updated", per_page: int = 20) -> list[dict]:
    """Search GitHub for AI/ML repos using REST API (no scraping)."""
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": "Bearer YOUR_GITHUB_TOKEN",  # required for higher rate limits
    }
    params = {
        "q": f"{query} language:python",
        "sort": sort,
        "order": "desc",
        "per_page": per_page,
    }
    r = requests.get("https://api.github.com/search/repositories", headers=headers, params=params, timeout=30)
    r.raise_for_status()
    items = r.json().get("items", [])
    return [
        {
            "full_name": item["full_name"],
            "description": item.get("description", ""),
            "stars": item["stargazers_count"],
            "updated_at": item["updated_at"],
            "url": item["html_url"],
            "topics": item.get("topics", []),
        }
        for item in items
    ]

# Track recent attention mechanism implementations
attention_repos = search_github_ai_repos("MLA multi-head latent attention implementation", sort="updated")
```

---

## Cross-References

- `skills/cutting-edge-architectures` — techniques worth tracking in new model releases
- `skills/executant-research-intelligence/references/ai-security-advisories.md` — supply chain threat details
- `skills/executant-research-intelligence/references/paper-monitoring-workflows.md` — triage and digest workflows
