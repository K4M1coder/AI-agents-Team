---
name: executant-research-intelligence
description: "**WORKFLOW SKILL** — AI research monitoring and intelligence: arxiv paper tracking, lab release monitoring, open-weight family watchlists, HF Hub model/dataset drop detection, AI-specific CVE and security advisory tracking, adversarial ML threat intel, supply chain risk for AI/ML tooling. USE FOR: finding new papers on a topic; monitoring for model releases; checking CVEs in vLLM/PyTorch/Triton/Ollama; assessing leaked model weights; generating weekly research digests; tracking competitive lab output; maintaining coverage across major open-weight labs. USE WHEN: staying ahead of field developments; threat intel for newly released weights or code; security hardening of AI/ML infrastructure; competitive landscape assessment; release tracking across the current open-weight LLM landscape."
argument-hint: "Describe the monitoring target: e.g. 'Track new JEPA papers this week', 'Check PyTorch CVEs Q1 2026', 'Assess newly dropped DeepSeek weights', 'Weekly digest for cs.LG + cs.CL', 'Suspicious HF model from unknown account'"
---

# Research Intelligence

Systematic monitoring and analysis of the AI research landscape, model/code releases, and AI-specific security advisories.

## When to Use

- Identifying and triaging newly published papers relevant to active projects
- Monitoring key labs (Meta FAIR, DeepSeek, Kimi, Google DeepMind) for model drops
- Monitoring key open-weight labs and families (Mistral, DeepSeek, Kimi, Z.ai/GLM, Qwen, NVIDIA Nemotron, Gemma, MiniMax, AI2, Liquid, Cohere, Arcee, Sarvam, Xiaomi)
- Tracking CVEs and security advisories for PyTorch, vLLM, TGI, Triton, Ollama, MLflow
- Evaluating suspicious model/dataset uploads to HF Hub (supply chain risk)
- Generating periodic research digests for team distribution
- Assessing leaked or unattributed model weights for origin, safety, and licensing risk
- Competitive intelligence on models released without pre-announcement

## Core Concepts

| Concept | Description |
| --------- | ------------- |
| **Paper Triage** | Score newly published papers on novelty, relevance, reproducibility — separate signal from noise |
| **Lab Monitoring** | Track major AI lab output on arxiv (cs.LG/cs.CL/cs.CV/cs.AI) and HF Hub |
| **Code Drop Intelligence** | Detect significant new model/dataset/codebase releases across GitHub and HF Hub |
| **CVE Tracking** | Monitor GitHub Security Advisories, PyPA, and NIST NVD for AI/ML tooling vulnerabilities |
| **Adversarial Threat Intel** | Assess prompt injection, model extraction, membership inference, backdoor/trojan risks |
| **Supply Chain Risk** | Evaluate poisoned training data, backdoored weights, malicious HF repos |

## Procedure

### Phase 1: Continuous Input Monitoring

Identify what needs to be monitored, then set cadence:

1. **Define scope**: Topic (cs.LG, JEPA, MoE, quantization), lab (Meta FAIR, DeepSeek, Kimi, Z.ai/GLM, Qwen, NVIDIA, Mistral, AI2, Liquid, MiniMax), infrastructure (PyTorch, vLLM, Kubernetes), or event (model release, CVE disclosure)
2. **Select feeds**: arxiv RSS, HF Hub API, GitHub releases API, security mailing lists (oss-security, full-disclosure), NIST NVD
3. **Set triage cadence**: Daily (security CVEs) vs. weekly (research papers) vs. event-driven (model releases)
4. **Assign reviewers**: Route security advisories to `executant-security-ops`; architecture papers to `executant-ml-researcher`; model releases to `executant-mlops-engineer` + `executant-inference-engineer`

See `references/paper-monitoring-workflows.md` for arxiv category guide and Semantic Scholar API patterns.

### Phase 2: Paper Triage

For each paper candidate, apply the triage rubric (1–5 scoring):

1. **Novelty** (1–5): Is the core idea genuinely new? Incremental vs. breakthrough?
2. **Relevance** (1–5): Direct applicability to active projects or roadmap?
3. **Reproducibility** (1–5): Code + data available? Compute feasible?
4. **Credibility** (1–5): Author track record, venue, ablation quality?
5. **Urgency** (1–5): Time-sensitive (competitor model drop, security vulnerability, benchmark superceded)?

**Total ≥ 18**: Deep dive + summary for team
**Total 12–17**: Review abstract + key sections
**Total < 12**: Archive, no action

Apply this rubric using `references/paper-monitoring-workflows.md`.

### Phase 3: Code & Model Intelligence

1. **HF Hub sweep**: Check new models from known lab accounts + flag unknown-origin large checkpoints
2. **GitHub trending**: Review trending AI/MLOps repos weekly; identify new tooling, forks of known models
3. **Papers With Code**: Track SOTA table updates for benchmarks relevant to active projects
4. **Red flags**: Evaluate suspicious uploads against model card checklist (see `references/code-intelligence.md`)

## Open-Weight Release Baseline

Use `../_shared/references/llm-landscape.md` as the maintained family map for release briefs and comparative watchlists.

- Family files under `../_shared/references/models/` hold the lab-specific baseline for Mistral, DeepSeek, Kimi, GLM, Qwen, Nemotron, Gemma, MiniMax, Olmo, Liquid, and emerging releases.
- The edge routing guide in `../_shared/references/models/edge-small.md` is useful when a release is strategically important because it changes the low-VRAM or offline deployment tier.

### Phase 4: Security Advisory Processing

1. **Collect**: Query CVE sources for AI/ML tooling (PyTorch, vLLM, Triton, Ollama, MLflow, Airflow, Kubeflow)
2. **Classify**: Severity (Critical/High/Medium/Low) + affected component + exploit complexity
3. **Route**: Critical/High → immediate escalation to `executant-security-ops` + `executant-mlops-engineer`; Medium/Low → weekly advisory digest
4. **Assess supply chain**: Evaluate new model/dataset uploads for trojan indicators, unusual file structures, license anomalies (see `references/ai-security-advisories.md`)

### Phase 5: Synthesis & Distribution

1. **Weekly Research Digest**: Summary of top-scored papers, notable model releases, active CVEs (template in `references/paper-monitoring-workflows.md`)
2. **Architecture Briefs**: Deep-dive on high-triage papers → feed to `executant-ml-researcher` + `cutting-edge-architectures` skill
3. **Security Bulletins**: CVE advisories + mitigation steps → feed to `executant-security-ops`
4. **Competitive Alerts**: Lab model drops → feed to `agent-manager` + relevant specialists

## Reference Files

| File | Contents |
| ------ | ---------- |
| `references/paper-monitoring-workflows.md` | arxiv categories, Semantic Scholar API, lab tracker, triage rubric, digest template |
| `references/code-intelligence.md` | HF Hub monitoring, GitHub trending, Papers With Code, model card red-flag checklist |
| `references/ai-security-advisories.md` | CVE sources, adversarial ML threats, supply chain risks, AI API abuse patterns |
| `../_shared/references/llm-landscape.md` | shared open-weight family baseline for release tracking and competitive briefs |

## Coordinates With

| Agent | Handoff |
| ------- | -------- |
| `executant-ml-researcher` | Sends paper triage results and architecture briefs; receives research priorities |
| `executant-security-ops` | Escalates Critical/High CVEs and supply chain risks; receives security tool updates |
| `executant-ai-safety` | Routes adversarial ML threat intel; receives red-teaming findings |
| `executant-mlops-engineer` | Alerts on new model releases requiring pipeline updates; receives release integration feedback |
| `executant-inference-engineer` | Flags new quantization/serving papers; receives deployment feasibility assessment |
| `agent-manager` | Delivers weekly digest and competitive alerts; receives priority adjustments |

## Output Format

- **Paper Triage Report**: Scored table with action column (deep-dive / review / archive)
- **Model Release Brief**: Origin, license, architecture summary, deployment readiness assessment
- **Security Advisory**: CVE ID, affected versions, CVSS score, mitigation steps
- **Weekly Digest**: Sectioned summary — \[Architecture\] \[Training\] \[Inference\] \[Security\] \[Releases\]
