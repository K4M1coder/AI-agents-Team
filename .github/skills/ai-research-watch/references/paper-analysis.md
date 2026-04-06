# Paper Analysis Framework

Structured approach to reading, evaluating, and cataloging AI research papers.

## Analysis Template

For each paper, fill out this template:

```markdown
# Paper: [Title]
**Authors**: [names]
**Published**: [venue, date]
**ArXiv**: [link]
**Code**: [link or N/A]

## 1. Problem
What gap does this paper address? What was the limitation of prior work?

## 2. Key Contribution
What is the novel contribution? (one sentence)

## 3. Method
- Architecture: [description]
- Training: [data, compute, duration]
- Key innovation: [what makes it different]

## 4. Results
| Benchmark | This Paper | Previous SOTA | Improvement |
| ----------- | ----------- | -------------- | ------------- |
| [name]    | [score]   | [score]      | [delta]     |

## 5. Ablations
| Component Removed | Impact |
| ------------------- | -------- |
| [component]       | [effect on metrics] |

## 6. Limitations
- [acknowledged by authors]
- [our assessment]

## 7. Reproducibility Score (1-5)
- Code available: [yes/no]
- Data available: [yes/no]
- Compute feasible: [yes/no, estimate GPU-hours]
- Hyperparameters complete: [yes/no]

## 8. Relevance to Kyutai (1-5)
- Applicable to: [which projects]
- Integration effort: [low/medium/high]
- Priority: [immediate/near-term/long-term/monitor]
```

## Paper Search Strategy

### Where to Find Papers

| Source | URL | Best For |
| -------- | ----- | ---------- |
| arXiv | arxiv.org | Pre-prints, latest research |
| Semantic Scholar | semanticscholar.org | Connected papers, citations |
| Papers with Code | paperswithcode.com | SOTA benchmarks, code links |
| Google Scholar | scholar.google.com | Citation tracking |
| HuggingFace Papers | huggingface.co/papers | Trending ML papers |
| Conference proceedings | Various | Peer-reviewed work |

### Search Queries for Kyutai Domains

| Domain | Search Terms |
| -------- | ------------- |
| Speech synthesis | `text-to-speech`, `speech synthesis`, `neural TTS`, `flow matching speech` |
| Speech dialogue | `spoken dialogue`, `full-duplex speech`, `conversational AI` |
| Audio codec | `neural audio codec`, `residual vector quantization`, `audio compression` |
| Speech translation | `speech-to-speech translation`, `simultaneous translation` |
| Model efficiency | `quantization`, `distillation`, `pruning`, `efficient transformers` |

## Citation Graph Analysis

When evaluating a paper's significance:

1. **Forward citations**: How many papers cite this? Growing or plateauing?
2. **Backward citations**: What does it build on? Solid foundations?
3. **Implementation adoption**: Used in production systems? Open-source adoption?
4. **Author track record**: Prior impactful work? Established group?
5. **Venue quality**: Top-tier conference? Workshop? Pre-print only?

## Kyutai Open-Source Papers Registry

Track Kyutai open-source published papers:

| ID | Paper | Status | Relevance |
| ---- | ------- | -------- | ----------- |
| P1 | arxiv:2410.00037 (Moshi) | Implemented | Core — full architecture in workspace |
| P2 | arxiv:2502.03382 (Hibiki) | Implemented | Core — speech translation |
| P3 | arxiv:2509.06926 (Pocket-TTS) | Implemented | Core — lightweight TTS |
| P4 | arxiv:2505.18825 (LSD) | Implemented | Core — latent speech diffusion |
| P5 | arxiv:2106.09685 (LoRA) | Integrated | Training — used in moshi-finetune |
| P6 | arxiv:2104.09864 (RoPE) | Integrated | Architecture — position encoding |

## Method Comparison Template

When comparing competing approaches:

```markdown
# Comparison: [Method A] vs [Method B] vs [Method C]

## Task: [what problem]

| Criterion | Method A | Method B | Method C |
| ----------- | ---------- | ---------- | ---------- |
| Quality (primary metric) | | | |
| Training compute (GPU-hours) | | | |
| Inference latency | | | |
| Memory requirement | | | |
| Implementation complexity | | | |
| Data requirements | | | |
| Maturity / ecosystem | | | |
| Open-source implementation | | | |

## Recommendation
[Which method and why, given our constraints]
```
