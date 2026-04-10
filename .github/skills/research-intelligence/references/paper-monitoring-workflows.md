# Paper Monitoring Workflows

> **Operator/Integrator Reference**: This file documents systematic workflows for monitoring AI research output. All API patterns shown represent public, unauthenticated or API-key-authenticated endpoints available as documented by the respective services.

---

## arxiv Category Reference

| Category | Full Name | Key Topics | Recommended Cadence |
| ---------- | ----------- | ------------ | --------------------- |
| `cs.LG` | Machine Learning | training, optimization, generalization, foundation models | Daily |
| `cs.CL` | Computation and Language | LLMs, NLP, dialogue, translation, reasoning | Daily |
| `cs.CV` | Computer Vision | image/video models, JEPA, diffusion, detection | Daily |
| `cs.AI` | Artificial Intelligence | agents, planning, symbolic AI, cognitive architectures | Weekly |
| `cs.CR` | Cryptography and Security | ML security, adversarial attacks, privacy, federated learning | Daily (security review) |
| `cs.DC` | Distributed Computing | Multi-GPU training, parallelism strategies, cluster optimization | Weekly |
| `cs.NE` | Neural and Evolutionary Computing | architecture search, neuromorphic, neuro-symbolic | Weekly |
| `cs.RO` | Robotics | embodied AI, world models for control, manipulation | Weekly |
| `eess.AS` | Audio and Speech | TTS, ASR, audio codecs, speech separation | Weekly |
| `stat.ML` | Statistics ML | Bayesian methods, causal inference, uncertainty quantification | Weekly |

### arxiv RSS Feed Pattern

```text
ttps://arxiv.org/rss/{category}
```

Example: `https://arxiv.org/rss/cs.LG` returns today's submissions.

For cross-listed papers (most LLM papers cross-list cs.LG+cs.CL), subscribe to both feeds and deduplicate by arxiv ID.

---

## Semantic Scholar API

Unauthenticated rate limit: 100 requests/5 minutes. API key (free): 1 request/second.

### Paper Search

```python
import requests

def search_recent_papers(query: str, fields_of_study: list[str], days_back: int = 7) -> list[dict]:
    """Search Semantic Scholar for recent papers matching a query."""
    import time
    from datetime import datetime, timedelta

    cutoff = (datetime.now() - timedelta(days=days_back)).strftime("%Y-%m-%d")

    params = {
        "query": query,
        "fields": "title,authors,year,publicationDate,externalIds,abstract,citationCount,url",
        "publicationDateOrYear": f"{cutoff}:",
        "fieldsOfStudy": ",".join(fields_of_study),
        "limit": 50,
        "sort": "PublicationDate:desc",
    }

    response = requests.get(
        "https://api.semanticscholar.org/graph/v1/paper/search",
        params=params,
        headers={"x-api-key": "YOUR_API_KEY_HERE"},  # optional: increases rate limit
        timeout=30,
    )
    response.raise_for_status()
    return response.json().get("data", [])


# Example: track MoE papers published this week
moe_papers = search_recent_papers(
    query="mixture of experts language model",
    fields_of_study=["Computer Science"],
    days_back=7
)
for paper in moe_papers[:5]:
    print(f"[{paper['publicationDate']}] {paper['title']}")
    print(f"  arxiv: {paper.get('externalIds', {}).get('ArXiv', 'N/A')}")
    print(f"  citations: {paper.get('citationCount', 0)}")
```

### Author/Lab Tracking

```python
def get_recent_papers_by_author(author_id: str, limit: int = 10) -> list[dict]:
    """Retrieve recent papers from a specific author (by S2 author ID)."""
    url = f"https://api.semanticscholar.org/graph/v1/author/{author_id}/papers"
    params = {
        "fields": "title,publicationDate,externalIds,abstract",
        "limit": limit,
        "sort": "PublicationDate:desc",
    }
    r = requests.get(url, params=params, timeout=30)
    r.raise_for_status()
    return r.json().get("data", [])

# Notable AI researcher S2 IDs (illustrative — verify before use)
# Yann LeCun: 1751762
# Aäron van den Oord: 2056423
# Note: S2 author IDs change; prefer org-based searches for reliability
```

---

## Lab Tracker

| Lab | arxiv Author Affiliation Keywords | HF Hub Namespace | GitHub Org |
| ----- | ---------------------------------- | ------------------ | ----------- |
| Meta FAIR | `Meta AI`, `FAIR`, `Meta Platforms` | `facebook`, `meta-llama`, `facebookresearch` | `facebookresearch` |
| Google DeepMind | `Google DeepMind`, `Google Research` | `google`, `deepmind` | `google-deepmind` |
| DeepSeek | `DeepSeek` | `deepseek-ai` | `deepseek-ai` |
| Kimi / Moonshot AI | `Moonshot AI`, `Kimi` | `moonshotai` | `MoonshotAI` |
| OpenAI | `OpenAI` | `openai` | `openai` |
| Mistral AI | `Mistral AI` | `mistralai` | `mistralai` |
| Cohere | `Cohere` | `CohereForAI` | `cohere-ai` |
| Anthropic | `Anthropic` | *(limited HF presence)* | `anthropics` |
| xAI | `xAI` | `xai-org` | `xai-org` |
| Allen AI | `Allen Institute for AI` | `allenai` | `allenai` |
| Cohere | `Cohere` | `CohereForAI` | `cohere-ai` |
| Microsoft Research | `Microsoft Research` | `microsoft` | `microsoft` |
| Hugging Face | `Hugging Face` | `HuggingFaceH4`, `HuggingFaceFW` | `huggingface` |
| NVIDIA | `NVIDIA` | `nvidia` | `NVIDIA` |

### HF Hub — New Model Monitoring

```python
from huggingface_hub import list_models
from datetime import datetime, timedelta

def scan_new_lab_models(org: str, days_back: int = 7) -> list:
    """Detect new model uploads from a known lab HF org."""
    cutoff = datetime.now() - timedelta(days=days_back)
    models = list_models(
        author=org,
        sort="lastModified",
        direction=-1,    # most recent first
        limit=50,
    )
    recent = []
    for m in models:
        last_mod = getattr(m, "lastModified", None)
        if last_mod and last_mod >= cutoff:
            recent.append({
                "id": m.modelId,
                "modified": last_mod,
                "tags": m.tags,
                "downloads": getattr(m, "downloads", 0),
                "private": m.private,
            })
    return recent

# Check for new DeepSeek releases
new_deepseek = scan_new_lab_models("deepseek-ai", days_back=7)
for m in new_deepseek:
    print(f"{m['id']} — {m['modified'].date()} — {m['downloads']} downloads")
```

---

## Paper Triage Rubric

Score each paper dimension 1–5 before investing analysis time.

| Dimension | 1 (Skip) | 3 (Review) | 5 (Deep Dive) |
| ----------- | ---------- | ------------ | -------------- |
| **Novelty** | Minor variant of known method | Meaningful improvement or novel combination | Fundamental new paradigm or technique |
| **Relevance** | Unrelated to any active project | Adjacent domain, may inform future work | Directly applicable to active roadmap item |
| **Reproducibility** | No code, no data, very large compute | Code coming soon, accessible hardware | Code + data released, runs on 1–4 GPUs |
| **Credibility** | Unknown authors, no ablations, weak baselines | Reputable authors, partial ablations | Top venue or heavy citation, full ablations |
| **Urgency** | No time pressure | Competitor released something similar | Benchmark superceded, security disclosure, direct competitor |

**Scoring Action Table:**

| Total Score | Action |
| ------------- | -------- |
| 22–25 | **Deep dive**: Full read + implementation test + team summary |
| 18–21 | **Thorough review**: Read all sections, extract key insights, note open questions |
| 13–17 | **Abstract + figures**: Skim, note if worth revisiting |
| 8–12 | **Archive**: Title + one-line note, no follow-up |
| 5–7 | **Skip**: Do not archive, discard |

---

## Weekly Research Digest Template

```markdown
# Weekly AI Research Digest — [Week of DATE]

## Highlights

| Paper | Venue/Source | Triage Score | One-Line Summary |
| ------- | ------------- | ------------- | ----------------- |
| [Title](arxiv link) | cs.LG | 22 | Brief description |

---

## Architecture & Training

### [Paper Title] (arxiv:XXXX.XXXXX)
**Authors**: A, B, C — **Lab**: [Lab Name]
**TL;DR**: One sentence.
**Key Result**: Benchmark / metric / comparison.
**Reproducibility**: Code at [URL] / Not released
**Action**: [Assigned to / Next step]

---

## Inference & Efficiency

[Same structure]

---

## Security & Adversarial ML

[Same structure]

---

## Notable Model/Code Releases

| Model | Lab | License | Architecture | HF Hub |
| ------- | ----- | --------- | ------------- | -------- |
| [Name] | [Lab] | [License] | [Architecture summary] | [link] |

---

## Active CVEs

| CVE ID | Component | CVSS | Affected Versions | Status |
| -------- | ----------- | ------ | ------------------- | -------- |
| CVE-YYYY-XXXXX | vLLM | 8.1 | <0.4.2 | Patch available |

---

## Upcoming Watchlist

- [Lab] expected to release [model] in [timeframe] based on [signal]
```
