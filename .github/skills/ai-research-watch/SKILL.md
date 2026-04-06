---
name: ai-research-watch
description: "**WORKFLOW SKILL** — AI technical watch: arxiv analysis, paper methodology, benchmark tracking, conference monitoring, reproducibility assessment. USE FOR: analyzing papers, tracking SOTA, evaluating new methods, summarizing research trends, comparing approaches. USE WHEN: evaluating a new technique, staying current on AI research, assessing paper claims."
argument-hint: "Describe what to research: topic, paper, architecture, or benchmark to analyze"
---

# AI Research Watch

Track state-of-the-art AI research, analyze papers, and evaluate new methods for practical applicability.

## When to Use

- Evaluating a new paper or technique for adoption
- Tracking benchmarks and SOTA for a specific task
- Summarizing research trends in a domain
- Assessing reproducibility of published results
- Comparing competing approaches for a project

## Core Concepts

| Concept | Description |
| --------- | ------------- |
| **SOTA Tracking** | Monitoring best results on standard benchmarks |
| **Paper Analysis** | Structured reading: claims, methods, results, limitations |
| **Reproducibility** | Can results be replicated? Code, data, compute requirements |
| **Ablation Study** | Which components matter? Sensitivity analysis |
| **Transfer Potential** | Can methods apply to our tasks and constraints? |

## Procedure

### Phase 1: Paper Analysis

For each paper, extract:

1. **Problem Statement**: What task? What's the gap in prior work?
2. **Key Contribution**: What's new? (architecture, training method, data, scale)
3. **Method Summary**: Core technique in 2-3 sentences
4. **Architecture Details**: Model size, components, innovations
5. **Training Setup**: Data, compute, duration, hyperparameters
6. **Results**: Main benchmarks, comparison to baselines
7. **Ablations**: What components contribute most?
8. **Limitations**: Authors' acknowledged limitations + your assessment
9. **Reproducibility**: Code available? Data available? Compute feasible?
10. **Relevance**: Applicable to our projects? Priority level?

### Phase 2: Benchmark Tracking

Maintain awareness of key benchmarks:

#### Language Models
| Benchmark | Measures | Key Models |
| ----------- | --------- | ------------ |
| MMLU | Knowledge, reasoning | GPT-4, Claude, Llama |
| HumanEval | Code generation | Codex, DeepSeek-Coder |
| HellaSwag | Common sense | Most LLMs |
| ARC | Science reasoning | Most LLMs |

#### Speech/Audio
| Benchmark | Measures | Key Models |
| ----------- | --------- | ------------ |
| LibriSpeech | ASR (WER) | Whisper, Conformer |
| PESQ/STOI | Audio quality | Mimi, EnCodec, DAC |
| MOS | Subjective quality | TTS systems |
| VoiceBox benchmark | Speech generation | VoiceBox, Moshi |

#### Vision
| Benchmark | Measures | Key Models |
| ----------- | --------- | ------------ |
| ImageNet | Classification | ViT, EfficientNet |
| COCO | Detection/Segmentation | DETR, SAM |
| FID/IS | Image generation quality | Diffusion models |

### Phase 3: Research Trend Monitoring

Track these active research areas:

1. **Scaling**: Training efficiency, data efficiency, inference optimization
2. **Architecture**: SSM/Mamba vs Transformers, MoE, hybrid approaches
3. **Alignment**: RLHF alternatives (DPO, KTO, ORPO), Constitutional AI
4. **Multi-modal**: Vision-language, audio-language, omni-models
5. **Efficiency**: Quantization, distillation, pruning, NAS
6. **Long Context**: Rope extensions, ring attention, landmark attention
7. **Reasoning**: Chain-of-thought, tree-of-thought, reasoning tokens
8. **Agents**: Tool use, planning, multi-agent systems

### Phase 4: Applicability Assessment

Score each method for our context:

| Criterion | Weight | Score 1-5 |
| ----------- | -------- | ----------- |
| Relevance to audio/speech | 30% | |
| Implementation complexity | 20% | |
| Compute requirements | 20% | |
| Quality improvement expected | 20% | |
| Maturity / reproducibility | 10% | |

## Kyutai Open-Source Reference — Published Papers

Key papers published by the Kyutai open-source research team:

| Paper | Topic | Relevance |
| ------- | ------- | ----------- |
| arxiv:2410.00037 | Moshi: full-duplex speech-text | Core architecture |
| arxiv:2502.03382 | Hibiki: speech translation | Cross-lingual |
| arxiv:2509.06926 | Pocket-TTS: lightweight TTS | Edge deployment |
| arxiv:2505.18825 | LSD: latent speech diffusion | Generative method |
| arxiv:2106.09685 | LoRA | Fine-tuning method |
| arxiv:2104.09864 | RoPE | Position encoding |

## Key Conferences

| Conference | When | Focus |
| ----------- | ------ | ------- |
| NeurIPS | December | General ML |
| ICML | July | General ML |
| ICLR | May | Representation learning |
| ACL/EMNLP | July/December | NLP |
| Interspeech | September | Speech |
| ICASSP | April/June | Signal processing |
| CVPR/ICCV | June/October | Computer vision |

## Output Format

- **Paper Summary**: Structured analysis (see Phase 1)
- **SOTA Table**: Benchmark comparisons with dates
- **Trend Report**: Summary of active research directions
- **Recommendation**: Priority ranking for methods to adopt
