# JEPA & World Models Reference

Technical reference for the Joint Embedding Predictive Architecture (JEPA) paradigm and LeCun's world model research (Meta FAIR, 2023–2026).

> **Operator/Integrator Reference**: All models, papers, and checkpoints in this file originate from Meta FAIR / Yann LeCun's lab. They are documented here as open-source technical references for integration and research adoption.

---

## JEPA Core Paradigm

### What Is JEPA?

**Joint Embedding Predictive Architecture** — predict representations of target signals in **latent/embedding space**, not in pixel or token space.

```text
Standard (generative SSL)             JEPA
──────────────────────────            ─────────────────────────────
Context → Decoder → Pixels            Context → Predictor → z_target
         (high-variance)                        (semantic, low-variance)
```

**Key insight**: Generative models that reconstruct pixels must model irrelevant high-frequency details. A predictor that forecasts embeddings only needs to capture semantically meaningful variation.

### Anti-Collapse Mechanisms

All JEPA variants must prevent representational collapse (all embeddings → same vector):

| Strategy | Used In | Mechanism |
| ---------- | --------- | ----------- |
| **VICReg** | I-JEPA, general | Variance, Invariance, Covariance regularization on embeddings |
| **EMA (Exponential Moving Average)** | I-JEPA (target encoder) | Target encoder is slow-moving copy of context encoder |
| **VCReg** | Most JEPA variants | Variance + Covariance regularization (lighter than VICReg) |
| **LeJEPA Objective** | LeJEPA (arxiv:2511.08544) | Formal theory; lean objective provably avoids collapse without EMA |
| **LeWorldModel** | arxiv:2603.19312 | Eliminates EMA entirely; stable training from pixels |

---

## JEPA Family Taxonomy

| Variant | Paper | Domain | Key Mechanic | Collapse Prevention |
| --------- | ------- | -------- | -------------- | --------------------- |
| **I-JEPA** | arxiv:2301.08243 (ICCV 2023) | Image | Predict latent reps of masked image blocks via ViT-Huge | EMA target encoder |
| **V-JEPA** (v1) | Meta 2024 | Video | Extend I-JEPA to space-time; mask tubes of video patches | EMA |
| **V-JEPA 2** | arxiv:2506.09985 (Jun 2025) | Video + Robotics | Action-free SSL on video + robot interaction; latent action planning | EMA |
| **V-JEPA 2.1** | arxiv:2603.14482 (Mar 2026) | Video | Dense predictive loss; improved spatial understanding | EMA + density |
| **LLM-JEPA** | arxiv:2509.14252 (Sep 2025) | Language | JEPA objectives for LLM pretraining in embedding space (not token reconstruction) | VCReg |
| **VL-JEPA** | arxiv:2512.10942 (Dec 2025) | Vision-Language | Predicts continuous text embeddings (not discrete tokens); multimodal alignment | VCReg |
| **Causal-JEPA** | arxiv:2602.11389 (Feb 2026) | Object-centric | Relational world model with latent causal interventions; structural abstraction | EMA + object slots |
| **LeJEPA** | arxiv:2511.08544 (Nov 2025) | Theory | Formal JEPA theory; derives lean scalable training objective | Formal proof |
| **LeWorldModel** | arxiv:2603.19312 (Mar 2026) | World model | First stable end-to-end JEPA from pixels, no EMA, no auxiliary losses | Novel stabilization |
| **GMM-JEPA** | arxiv:2602.09040 (Feb 2026) | Speech | JEPA for speech representation via GMM-anchored targets | GMM anchoring |
| **LeCun Cognitive Arch** | arxiv:2603.15381 (Mar 2026) | Agent | System A (observation) + System B (active behavior) + meta-control; architectural theory | — |

---

## Training Objectives

### I-JEPA Training Objective

```python
# Context encoder: encodes context patches
z_context = context_encoder(x_context)    # [B, n_context_patches, d]

# Target encoder: slow-moving EMA of context encoder
z_target = target_encoder(x_full)         # [B, n_patches, d]  -- stop_gradient

# Predictor: predicts target from context + positional mask tokens
z_pred = predictor(z_context, target_positions)  # [B, n_target_patches, d]

# Loss: smooth L1 between predicted and target embeddings
loss = F.smooth_l1_loss(z_pred, z_target[target_positions])

# EMA update of target encoder
for p_ema, p in zip(target_encoder.parameters(), context_encoder.parameters()):
    p_ema.data = momentum * p_ema.data + (1 - momentum) * p.data
```

### V-JEPA 2 Training (Video + Actions)

```python
# Video tube masking: mask space-time tubes (not random patches)
context_frames, target_frames = tube_mask(video)     # context ≠ target frames

# Both encoders process video clips
z_context = context_encoder(context_frames)           # [B, T_ctx, n_patches, d]
z_target = target_encoder(target_frames)              # [B, T_tgt, n_patches, d]  -- EMA

# Predictor: given context + action conditioning → predict target
# Actions are latent if no explicit action labels (action-free mode)
z_pred = predictor(z_context, z_target_positions, action=None)

# L2 loss in latent space (no pixel reconstruction)
loss = F.mse_loss(z_pred, z_target.detach())
```

### LLM-JEPA Objective (Embedding Space)

```python
# Instead of predicting the next token ID, predict the embedding of a masked span
z_full = sentence_encoder(tokens)                     # [B, S, d]  -- unmasked text
z_context = sentence_encoder(masked_tokens)           # [B, S, d]  -- masked text

# Predictor forecasts masked span embeddings
z_pred = predictor(z_context, masked_span_positions)  # [B, span_len, d]

# Target = stop_gradient embeddings from full-context encoder
loss = F.mse_loss(z_pred, z_full[masked_span_positions].detach())
# ↑ No discrete cross-entropy; learns semantic embeddings, not surface strings
```

---

## Latent Planning (V-JEPA 2 / Causal-JEPA)

JEPA world models enable **planning in latent space** without generating observations:

```python
# Given current state embedding z_0, plan a sequence of actions
z_t = z_0
for t in range(planning_horizon):
    # Predict next state using world model predictor
    z_t_next = world_model.predict(z_t, candidate_action=a_t)

    # Score the predicted outcome
    reward_t = reward_model(z_t_next)
    cost_t   = constraint_model(z_t_next)

# Select action sequence with highest reward subject to constraints
# (Model Predictive Control in latent space)
```

**Causal-JEPA** extends this to object-centric reasoning:

- Represents scenes as sets of object slots
- Interventions are modeled as targeted changes to specific object slots
- Enables counterfactual reasoning ("what if object A was removed?")

---

## Per-Domain Application Guide

### Image SSL (I-JEPA)

```bash
# Pre-training with I-JEPA (Meta FAIR reference implementation)
git clone https://github.com/facebookresearch/ijepa
cd ijepa

# Config: configs/in1k_vith14_ep300.yaml
# Key parameters:
#   pred_depth: 12          # predictor transformer depth
#   pred_emb_dim: 384       # predictor hidden dim (< encoder dim)
#   mask_scale: [0.15, 0.2] # fraction of patches to mask (target)
#   mask_aspect_ratio: [0.75, 1.5] # aspect ratio of masked blocks

python main.py \
    --config configs/in1k_vith14_ep300.yaml \
    --devices 0 1 2 3
```

**Best for**: ImageNet linear probe, few-shot classification, transfer to downstream tasks.

### Video Understanding / Robotics (V-JEPA 2)

```python
from transformers import AutoModel

# Load V-JEPA 2 video encoder (Meta FAIR)
video_encoder = AutoModel.from_pretrained("facebook/v-jepa-2-vitl-16")
# Note: check HF Hub for latest checkpoints — V-JEPA 2.1 may supersede

# Process video clip (T frames of H×W)
frames = load_video_clip(path, num_frames=16, resolution=224)  # [T, 3, H, W]
frames = frames.unsqueeze(0).to(device)                         # [1, T, 3, H, W]

with torch.no_grad():
    z_video = video_encoder(frames)   # [1, T*n_patches, d]
```

**Best for**: Video classification, action recognition, robot manipulation planning.

### Language Pretraining (LLM-JEPA)

**Key difference from standard LLM**: Objective is MSE in embedding space, not cross-entropy over vocabulary. Results in:

- Stronger semantic representations
- Better transfer to classification tasks
- Weaker direct text generation (may need autoregressive decoding head as separate stage)

### Speech (GMM-JEPA, arxiv:2602.09040)

Uses GMM-anchored targets rather than EMA encoder. The GMM quantizes speech frames into discrete anchor points. The JEPA predictor forecasts which GMM cluster the target speech frame belongs to (soft assignment). Prevents collapse by anchoring predictions to a fixed GMM fitted on acoustic features.

### Multimodal (VL-JEPA, arxiv:2512.10942)

Unlike CLIP (contrastive, discrete alignment), VL-JEPA:

- Predicts **continuous text embeddings** from image patches
- No tokenization bottleneck in the alignment target
- Better for fine-grained retrieval and dense captioning tasks

---

## Dynamic Tanh (DyT) — Normalization Innovation

**Paper**: arxiv:2503.10622 — "Transformers without Normalization" (LeCun lab, CVPR 2025)

### What It Is

Replace `nn.LayerNorm(x)` with `tanh(α × x)`, where `α` is a **learnable scalar per layer**.

```python
class DynamicTanh(nn.Module):
    def __init__(self, d_model, alpha_init=0.5):
        super().__init__()
        # Per-channel learnable scale (initialized uniformly)
        self.alpha = nn.Parameter(torch.ones(d_model) * alpha_init)

    def forward(self, x):
        return torch.tanh(self.alpha * x)
```

### Drop-In Replacement

```python
# Before (standard PreNorm Transformer layer)
class TransformerLayer(nn.Module):
    def __init__(self, d_model, n_heads, d_ff):
        self.norm1 = nn.LayerNorm(d_model)
        self.norm2 = nn.LayerNorm(d_model)
        ...

    def forward(self, x):
        x = x + self.attn(self.norm1(x))
        x = x + self.ffn(self.norm2(x))
        return x

# After (DyT replacement — same API, no running stats)
class TransformerLayer(nn.Module):
    def __init__(self, d_model, n_heads, d_ff):
        self.norm1 = DynamicTanh(d_model)   # ← swap
        self.norm2 = DynamicTanh(d_model)   # ← swap
        ...
```

### When to Use DyT

| Scenario | Recommendation |
| ---------- | --------------- |
| Training speed is bottleneck | **Consider** — eliminates layer norm backward pass computation |
| Small-batch training | **Consider** — no running statistics dependencies |
| Already using RMSNorm | **Try** — DyT may give equivalent or better results |
| Very deep networks (>96 layers) | **Evaluate** — tanh saturation at extreme depth may need lower `alpha_init` |
| Production model, no retraining | **Do not** — DyT requires training; not a post-hoc swap |

### Comparison with Normalization Approaches

| Normalization | Formula | Running Stats? | Learnable? | CVPR '25 Rank |
| -------------- | --------- | ---------------- | ------------ | --------------- |
| LayerNorm | (x−μ)/σ × γ + β | No (per-sample) | γ, β | Baseline |
| RMSNorm | x/RMS(x) × γ | No (per-sample) | γ | ~LayerNorm quality |
| BatchNorm | (x−μ_batch)/σ_batch × γ + β | **Yes** | γ, β | Worse for NLP |
| **DyT** | tanh(α × x) | **No** | α | Matches or exceeds LayerNorm |

---

## LeCun's Cognitive Architecture (2026)

**Paper**: arxiv:2603.15381 — Architecture for autonomous AI agents (March 2026)

Three-tier system:

1. **System A** (observation): Fast perception → latent state embedding (V-JEPA encoder)
2. **System B** (active behavior): Planning + latent space action search via world model predictor
3. **Meta-control**: Arbitrates between Systems A and B; sets goals; monitors progress

This formalizes the research direction behind V-JEPA 2, Causal-JEPA, and LeWorldModel into a unified agent architecture framework.

---

## HF Hub Resources

| Resource | HF Hub ID | Notes |
| ---------- | ----------- | ------- |
| I-JEPA ViT-H/14 | `facebook/ijepa_vith14_1k` | ImageNet 1K pre-trained |
| V-JEPA 2 ViT-L/16 | Check `facebook/` namespace | Latest video encoder |
| V-JEPA 2 ViT-H/16 | Check `facebook/` namespace | Larger video encoder |

> **Note**: V-JEPA 2.1 (arxiv:2603.14482, March 2026) checkpoints may supersede V-JEPA 2. Verify current state of `facebook/` namespace on HF Hub before training.

---

## Cross-Reference

- JEPA applications to speech: `skills/audio-speech-engineering/references/`
- Attention mechanism details (for VL-JEPA cross-attention patterns): `references/attention-innovations.md`
- Self-supervised training infrastructure: `skills/model-training/`
- Dataset curation for JEPA pretraining: `skills/dataset-engineering/`
