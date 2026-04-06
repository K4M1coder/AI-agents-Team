# Alignment Techniques Reference

Implementation patterns for AI alignment methods.

## RLHF Pipeline

```schema
┌─────────────┐     ┌──────────────┐     ┌─────────────┐     ┌──────────────┐
│ Collect      │────▶│ Train Reward │────▶│ Train Policy│────▶│ Evaluate     │
│ Preferences  │     │ Model        │     │ (PPO)       │     │ & Deploy     │
└─────────────┘     └──────────────┘     └─────────────┘     └──────────────┘
```

### Step 1: Preference Data Collection

```json
{
  "prompt": "Explain quantum computing",
  "chosen": "Quantum computing uses quantum bits...",
  "rejected": "I don't know about quantum stuff",
  "metadata": {"annotator": "human_01", "confidence": 0.9}
}
```

**Quality guidelines:**

- Clear winner in each pair (high annotator agreement)
- Cover diverse topics and difficulty levels
- Include safety-relevant examples (harmful requests, edge cases)
- Minimum 10k pairs, ideally 50k+

### Step 2: Reward Model Training

```python
from trl import RewardTrainer, RewardConfig

reward_config = RewardConfig(
    output_dir="reward_model",
    per_device_train_batch_size=8,
    learning_rate=1e-5,
    num_train_epochs=1,
    max_length=512,
)

trainer = RewardTrainer(
    model=reward_model,
    args=reward_config,
    train_dataset=preference_dataset,
    tokenizer=tokenizer,
)
trainer.train()
```

### Step 3: PPO Training

```python
from trl import PPOTrainer, PPOConfig

ppo_config = PPOConfig(
    batch_size=64,
    learning_rate=1e-6,
    ppo_epochs=4,
    kl_penalty="kl",
    init_kl_coef=0.2,
    target_kl=6.0,
)

ppo_trainer = PPOTrainer(
    config=ppo_config,
    model=policy_model,
    ref_model=ref_model,
    tokenizer=tokenizer,
    dataset=prompt_dataset,
    reward_model=reward_model,
)

for batch in ppo_trainer.dataloader:
    query_tensors = batch["input_ids"]
    response_tensors = ppo_trainer.generate(query_tensors)
    rewards = reward_model(query_tensors, response_tensors)
    stats = ppo_trainer.step(query_tensors, response_tensors, rewards)
```

## DPO (Direct Preference Optimization)

Simpler alternative to RLHF — no separate reward model needed.

```python
from trl import DPOTrainer, DPOConfig

dpo_config = DPOConfig(
    output_dir="dpo_model",
    beta=0.1,                        # KL penalty (higher = more conservative)
    learning_rate=5e-7,
    per_device_train_batch_size=4,
    gradient_accumulation_steps=4,
    num_train_epochs=3,
    warmup_ratio=0.1,
    bf16=True,
    loss_type="sigmoid",             # or "hinge", "ipo"
)

trainer = DPOTrainer(
    model=model,
    ref_model=ref_model,             # frozen copy of model
    args=dpo_config,
    train_dataset=dataset,
    tokenizer=tokenizer,
)
trainer.train()
```

### DPO Hyperparameter Guide

| Parameter | Range | Effect |
| ----------- | ------- | -------- |
| beta | 0.05-0.5 | Lower = more change from reference, higher = conservative |
| learning_rate | 1e-7 to 5e-6 | Very sensitive, start low |
| epochs | 1-3 | More can overfit on small datasets |
| loss_type | sigmoid/hinge/ipo | sigmoid is most common |

## Constitutional AI

Self-critique and revision against defined principles.

### Principles Example

```yaml
principles:
  - name: harmlessness
    critique: "Does the response contain harmful, dangerous, or unethical content?"
    revision: "Please revise the response to remove harmful content while being helpful."

  - name: honesty
    critique: "Does the response make claims that might be false or misleading?"
    revision: "Please revise the response to be truthful and acknowledge uncertainty."

  - name: helpfulness
    critique: "Is the response helpful and relevant to the user's question?"
    revision: "Please revise the response to be more helpful and directly address the question."
```

### Constitutional AI Pipeline

```list
1. Generate initial response
2. For each principle:
   a. Critique: "Given this principle, is there an issue with the response?"
   b. If issue found: Revise response according to principle
3. Use revised responses as "chosen" in DPO training
4. Use original responses as "rejected"
5. Train with DPO on self-generated preference data
```

## KTO (Kahneman-Tversky Optimization)

Uses binary feedback (good/bad) instead of preference pairs.

```python
from trl import KTOTrainer, KTOConfig

# Data format: each sample has a binary label
dataset = [
    {"prompt": "...", "completion": "...", "label": True},   # good
    {"prompt": "...", "completion": "...", "label": False},   # bad
]

kto_config = KTOConfig(
    beta=0.1,
    desirable_weight=1.0,
    undesirable_weight=1.0,
)
```

**When to use KTO**: When you only have thumbs-up/down feedback, not pairwise comparisons.

## ORPO (Odds Ratio Preference Optimization)

Single-stage: combines SFT and alignment in one training run.

```python
from trl import ORPOTrainer, ORPOConfig

orpo_config = ORPOConfig(
    output_dir="orpo_model",
    beta=0.1,
    learning_rate=5e-6,
    per_device_train_batch_size=4,
    num_train_epochs=3,
)

# Uses same preference data format as DPO
trainer = ORPOTrainer(
    model=model,  # no ref_model needed
    args=orpo_config,
    train_dataset=preference_dataset,
    tokenizer=tokenizer,
)
```

## Alignment Method Selection Guide

```schema
Have preference pairs (chosen/rejected)?
├── Yes →
│   Want simplest approach?
│   ├── Yes → DPO (beta=0.1)
│   └── No →
│       Need fine-grained control?
│       ├── Yes → RLHF (PPO)
│       └── No → ORPO (single-stage)
├── Only binary feedback (good/bad)?
│   └── KTO
└── Want rule-based alignment?
    └── Constitutional AI → DPO
```text
