---
name: ai-alignment
description: "**WORKFLOW SKILL** — AI safety & alignment: RLHF, DPO, PPO, Constitutional AI, red teaming, bias detection, guardrails, evaluation frameworks. USE FOR: alignment training, safety evaluation, bias audits, guardrail design, red teaming, responsible AI practices. USE WHEN: aligning a model, evaluating safety, designing content filters, auditing for bias."
argument-hint: "Describe the alignment task: method selection, safety evaluation, bias audit, or guardrail design"
---

# AI Alignment & Safety

Align AI models with human values and ensure safe, fair, robust behavior.

## When to Use

- Choosing an alignment method for a model
- Running safety evaluations (red teaming, bias audits)
- Designing input/output guardrails
- Implementing RLHF, DPO, or Constitutional AI
- Creating evaluation benchmarks for safety

## Core Concepts

| Concept | Description |
| --------- | ------------- |
| **Alignment** | Making model behavior match human intentions |
| **RLHF** | Train reward model from preferences, optimize policy with PPO |
| **DPO** | Direct optimization on preference pairs without reward model |
| **Constitutional AI** | Self-critique against a set of principles |
| **Red Teaming** | Adversarial testing to find failure modes |
| **Guardrails** | Input/output filters to prevent harmful content |

## Procedure

### Phase 1: Alignment Method Selection

| Method | Complexity | Data Required | Quality | Best For |
| -------- | ----------- | -------------- | --------- | ---------- |
| **SFT (Supervised Fine-Tuning)** | Low | Instruction-response pairs | Good baseline | First step |
| **DPO** | Medium | Preference pairs (chosen/rejected) | Good | Simpler alternative to RLHF |
| **RLHF (PPO)** | High | Preference data + reward model | Best control | Production alignment |
| **KTO** | Medium | Binary feedback (good/bad) | Good | When only binary labels |
| **ORPO** | Low | Preference pairs | Good | Single-stage alignment |
| **Constitutional AI** | Medium | Principles + self-critique | Good for rules | Rule-based alignment |

### Phase 2: Data Collection

**Preference data format:**
```json
{
  "prompt": "What's the weather?",
  "chosen": "I'd be happy to help with weather info. What city?",
  "rejected": "I can't predict weather, I'm just an AI."
}
```

**Data requirements:**
- SFT: 10k-100k instruction-response pairs
- DPO: 5k-50k preference pairs
- RLHF: 10k-100k comparisons for reward model + policy training
- Quality > quantity: well-curated data beats larger noisy datasets

### Phase 3: Training

**DPO Training (simplest alignment):**
```python
from trl import DPOTrainer, DPOConfig

training_args = DPOConfig(
    output_dir="dpo_output",
    per_device_train_batch_size=4,
    learning_rate=5e-7,
    beta=0.1,  # KL penalty strength
    max_length=1024,
    num_train_epochs=3,
)

trainer = DPOTrainer(
    model=model,
    ref_model=ref_model,
    args=training_args,
    train_dataset=dataset,
    tokenizer=tokenizer,
)
trainer.train()
```

### Phase 4: Safety Evaluation

See `references/evaluation-frameworks.md` for benchmark details.

### Phase 5: Guardrail Deployment

See `references/alignment-techniques.md` for implementation patterns.

## Audio/Speech Safety Considerations

Reference: Kyutai audio models (Moshi/Mimi):
- **Voice cloning prevention**: Detect and flag unauthorized speaker mimicry
- **Content moderation**: Audio content classification (hate speech, violence)
- **Deepfake detection**: Watermarking and provenance tracking
- **Speaker consent**: Verify speaker identity for voice synthesis
- **Privacy**: PII in transcripts, speaker identification risks

## Output Format

- **Alignment Plan**: Method, data, training configuration
- **Safety Report**: Evaluation results, identified risks
- **Red Team Report**: Attack categories, success rates, mitigations
- **Guardrail Spec**: Input/output filters, thresholds, fallback behavior
