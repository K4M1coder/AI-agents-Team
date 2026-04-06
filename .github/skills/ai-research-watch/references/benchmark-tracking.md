# Benchmark Tracking Reference

Track and compare state-of-the-art results across ML tasks.

## Speech & Audio Benchmarks

### Speech Recognition (ASR)

| Benchmark | Metric | SOTA Model | Score | Date |
| ----------- | -------- | ----------- | ------- | ------ |
| LibriSpeech (clean) | WER ↓ | Whisper large-v3 | 1.8% | 2024 |
| LibriSpeech (other) | WER ↓ | Whisper large-v3 | 3.6% | 2024 |
| Common Voice | WER ↓ | Varies by language | - | - |
| FLEURS | WER ↓ | Whisper, SeamlessM4T | - | - |

### Text-to-Speech (TTS)

| Benchmark | Metric | Direction | Notes |
| ----------- | -------- | ----------- | ------- |
| MOS (Mean Opinion Score) | 1-5 | ↑ | Human evaluation, gold standard |
| PESQ | -0.5 to 4.5 | ↑ | Perceptual quality |
| STOI | 0 to 1 | ↑ | Intelligibility |
| Speaker Similarity | Cosine sim | ↑ | Voice cloning fidelity |
| RTF (Real-Time Factor) | ratio | ↓ | Speed: < 1.0 = faster than real-time |

**Kyutai TTS context**: Pocket-TTS targets CPU real-time (RTF < 1.0)

### Audio Codec

| Benchmark | Metric | Mimi (Kyutai) | EnCodec | DAC |
| ----------- | -------- | -------------- | --------- | ----- |
| Bitrate | kbps ↓ | 1.1 | 1.5-24 | 8-16 |
| Frame rate | Hz | 12.5 | 75 | 86 |
| PESQ | ↑ | - | - | - |
| ViSQOL | ↑ | - | - | - |
| Sample rate | kHz | 24 | 24 | 44.1 |

### Speech Dialogue

| Benchmark | Metric | Notes |
| ----------- | -------- | ------- |
| Turn-taking accuracy | % | How well the model handles conversation flow |
| Response latency | ms | Time to first response token |
| Full-duplex quality | MOS | Simultaneous speech handling |

---

## Language Model Benchmarks

| Benchmark | Measures | Top Models | Notes |
| ----------- | --------- | ------------ | ------- |
| **MMLU** | Knowledge (57 subjects) | GPT-4, Claude 3.5, Llama 3.1 | 5-shot accuracy |
| **HumanEval** | Code generation | GPT-4, DeepSeek-Coder | pass@1 |
| **HellaSwag** | Common sense | Most LLMs | 10-shot accuracy |
| **ARC-Challenge** | Science QA | Most LLMs | 25-shot accuracy |
| **TruthfulQA** | Truthfulness | RLHF models | 0-shot, MC |
| **GSM8K** | Math reasoning | CoT models | Chain-of-thought |
| **BBH** | Hard reasoning | Large models | Big Bench Hard |
| **MATH** | Math competition | CoT + verification | Level 1-5 |

---

## Vision Benchmarks

| Benchmark | Measures | Metric |
| ----------- | --------- | -------- |
| **ImageNet-1k** | Classification | Top-1 accuracy |
| **COCO** | Detection + Segmentation | mAP |
| **ADE20K** | Semantic segmentation | mIoU |
| **FID** | Image generation quality | ↓ (lower is better) |
| **CLIP Score** | Image-text alignment | ↑ |

---

## Tracking Methodology

### How to Track SOTA

1. **Subscribe** to paperswithcode.com for benchmark updates
2. **Monitor** HuggingFace spaces leaderboards
3. **Follow** top research groups on arXiv (weekly digest)
4. **Track** conferences: NeurIPS, ICML, ICLR, Interspeech, ICASSP

### When SOTA Claims Need Scrutiny

| Red Flag | What to Check |
| ---------- | --------------- |
| No code/data | Can results be reproduced? |
| Evaluation on custom benchmark | Are they comparing fairly? |
| Cherry-picked metrics | What about other metrics? |
| No ablations | What actually contributes? |
| Very marginal improvement | Within noise / confidence interval? |
| Training data contamination | Is benchmark data in training set? |

### Benchmark Result Template

```markdown
# Benchmark Update: [benchmark_name]

**Date**: YYYY-MM-DD
**Source**: [paper/blog/leaderboard link]

| Model | Score | Params | Training Data | Hardware | Notes |
| ------- | ------- | -------- | -------------- | ---------- | ------- |
| [model] | [score] | [size] | [data] | [GPUs × hours] | [notes] |

**Previous SOTA**: [model] at [score] (date)
**Improvement**: [absolute/relative delta]
**Key technique**: [what enabled the improvement]
**Relevance**: [how this affects our work]
```

## Leaderboard URLs

| Resource | URL | Coverage |
| ---------- | ----- | ---------- |
| Papers with Code | paperswithcode.com | Most ML tasks |
| Open LLM Leaderboard | huggingface.co/spaces/open-llm-leaderboard | Open LLMs |
| LMSYS Chatbot Arena | chat.lmsys.org | LLM head-to-head |
| SuperGLUE | super.gluebenchmark.com | NLU |
| Massive Text Embedding | huggingface.co/spaces/mteb | Embedding models |
