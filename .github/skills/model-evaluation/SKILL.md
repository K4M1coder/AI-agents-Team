---
name: model-evaluation
description: "**WORKFLOW SKILL** — Evaluate ML models against benchmarks, task-specific metrics, and quality criteria. USE FOR: automated evaluation pipelines, benchmark selection (MMLU, HumanEval, MT-Bench, HELM, lm-evaluation-harness), metric design (accuracy, BLEU, ROUGE, WER, MOS, toxicity), SOTA comparison, regression testing between checkpoints, evaluation harness setup, human evaluation design, model card reporting. USE WHEN: comparing model checkpoints, selecting a model for production, validating fine-tuning results, establishing a regression baseline, or reporting model capabilities in a model card."
argument-hint: "Describe the evaluation goal (e.g., 'compare checkpoint A vs B on code generation tasks')"
---

# Model Evaluation

Design and run evaluation pipelines to measure, compare, and report ML model capabilities.

## When to Use

- Selecting between model checkpoints or fine-tuning runs
- Running standardized benchmarks for SOTA comparison
- Designing task-specific metrics for a custom domain
- Establishing a regression baseline before production release
- Validating that fine-tuning improved the target capability without degrading others
- Authoring model card evaluation sections
- Setting up continuous evaluation in CI/CD for model promotion gates

## Core Concepts

| Concept | Description |
| --------- | ------------- |
| **Benchmark** | Standardized task suite for model comparison (MMLU, HumanEval, MT-Bench) |
| **Task-Specific Metric** | Custom metric aligned to product quality criteria |
| **Regression Baseline** | Reference checkpoint scores all future releases are measured against |
| **Contamination** | Training data overlap with benchmark test sets — invalidates comparison |
| **Calibration** | Whether model confidence correlates with empirical accuracy |
| **Win Rate** | Human preference score via pairwise comparison (common for chat models) |
| **Harness** | Evaluation runner framework (lm-evaluation-harness, HELM, Inspect) |

## Procedure

### Phase 1: Define Evaluation Scope

1. **Clarify the decision** — What question is the evaluation answering?
   - Model selection (A vs B): use comparative benchmarks
   - Release gate (is this good enough?): use threshold-based metrics
   - Regression check (did fine-tuning break anything?): use baseline comparison
   - Capability reporting (model card): use canonical benchmarks + task-specific

2. **Map capabilities to metrics**:

| Capability | Recommended Metrics / Benchmarks |
| ---------- | --------------------------------- |
| General reasoning | MMLU, BIG-Bench-Hard, AGIEval |
| Code generation | HumanEval, MBPP, SWE-bench |
| Instruction following | MT-Bench, AlpacaEval, IFEval |
| Math | GSM8K, MATH, AIME |
| Factuality | TruthfulQA, FActScore |
| Speech/audio quality | MOS (MUSHRA), PESQ, STOI, WER, CER |
| Safety/toxicity | ToxiGen, BBQ, WinoBias |
| Retrieval-augmented | RAGAs, BEIR |

3. **Check for contamination** — Verify the training data pipeline was not contaminated by benchmark test sets before trusting absolute scores.

### Phase 2: Set Up Evaluation Harness

**Standard harnesses:**

```bash
# lm-evaluation-harness (most common for LLMs)
pip install lm-eval
lm_eval --model hf --model_args pretrained=<model_path> \
        --tasks mmlu,hellaswag,truthfulqa_mc2 \
        --device cuda:0 --batch_size 8

# HELM
pip install crfm-helm
helm-run --conf-path run_specs.conf --suite my_eval

# Inspect (for agentic/tool-use evaluation)
pip install inspect-ai
inspect eval task_file.py --model openai/gpt-4o
```

**Custom task setup:**
```python
from lm_eval.api.task import ConfigurableTask
from lm_eval.api.instance import Instance

class MyTask(ConfigurableTask):
    DATASET_PATH = "my_org/my_eval_dataset"
    OUTPUT_TYPE = "generate_until"

    def doc_to_text(self, doc):
        return doc["prompt"]

    def process_results(self, doc, results):
        prediction = results[0].strip()
        return {"exact_match": prediction == doc["answer"]}
```

### Phase 3: Run and Record Results

1. **Pin the harness version** — Benchmark scores are not comparable across harness versions
2. **Record metadata** per run:
   - Model checkpoint path + git ref
   - Harness version
   - Evaluation date
   - Hardware (GPU model, VRAM)
   - Batch size, dtype, quantization method
3. **Store results** in structured format (JSON) next to the checkpoint in the model registry
4. **Never compare** quantized scores to full-precision scores without explicit documentation

### Phase 4: Interpret Results

**Score comparison checklist:**
- [ ] Same harness version as the baseline?
- [ ] Same few-shot count as the baseline?
- [ ] Same quantization method (FP16 vs INT8 vs GGUF)?
- [ ] Contamination risk assessed?
- [ ] Results within expected variance (re-run 3x if p-value matters)?

**Decision thresholds:**

| Scenario | Threshold |
| -------- | --------- |
| Production release gate | Must not regress on regression baseline by >1% on primary metric |
| Fine-tuning validation | Must improve target metric by >2%, no >1% regression on general |
| Model selection | Pareto-dominant (better on ≥2 primary metrics, no regressions) |

### Phase 5: Report Results

For model cards and team communication, produce:

```markdown
## Evaluation Summary — <model-name> v<version>

| Benchmark | Score | Baseline | Delta | Notes |
| --- | --- | --- | --- | --- |
| MMLU (5-shot) | 0.72 | 0.70 | +2% | No contamination |
| HumanEval (0-shot) | 0.45 | 0.42 | +3% | Pass@1 |

**Harness**: lm-evaluation-harness v0.4.3
**Date**: YYYY-MM-DD
**Hardware**: 1× A100 80GB, bf16
**Known limitations**: Not evaluated on multimodal or audio tasks.
```

## Anti-Patterns

| Anti-Pattern | Why It Fails | Do This Instead |
| ------------ | ------------ | --------------- |
| Comparing scores across harness versions | Scores are not comparable | Pin harness version per project |
| Using leaderboard numbers without rerunning | Different hardware/quantization/prompt format | Always reproduce scores on your own setup |
| Evaluating only on benchmark tasks | May not reflect production task distribution | Add at least one task-specific custom eval |
| Ignoring contamination | Makes absolute scores meaningless | Check training data against benchmark test sets |
| Single-run comparisons | High variance at small scale | Run 3× and report mean ± stddev |
| Only evaluating the target capability | Fine-tuning regressions go undetected | Always run regression baseline |
| Reporting only pass/fail | Loses gradient signal for improvement | Report full score distributions |

## Agent Integration

| Agent | Relationship | Usage |
| --- | --- | --- |
| `executant-ml-researcher` | **Primary consumer** | Architecture comparison, SOTA tracking, benchmark triage |
| `executant-ml-engineer` | **Primary consumer** | Checkpoint validation, fine-tuning regression gates |
| `executant-inference-engineer` | **Contextual** | Post-quantization quality validation, latency-quality tradeoff |
| `executant-mlops-engineer` | **Contextual** | CI evaluation gates, model registry promotion criteria |
| `executant-ai-safety` | **Contextual** | Safety benchmark design (ToxiGen, BBQ), bias auditing |
| `executant-data-engineer` | **Contextual** | Contamination analysis, evaluation dataset construction |
| `agent-lead-ai-core` | **Contextual** | Gates and thresholds for model promotion decisions |
