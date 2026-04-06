---
name: model-architectures
description: "**WORKFLOW SKILL** — Architecture selection and design: Transformers, CNN, RNN, Mamba/SSM, MoE, JEPA, world models, diffusion, flow matching, neural codecs, attention variants, residual connections. USE FOR: choosing model architectures, understanding design trade-offs, implementing custom layers, analyzing papers. USE WHEN: designing a new model, selecting architecture for a task, comparing approaches."
argument-hint: "Describe the task and constraints: modality, latency, compute budget, accuracy requirements"
---

# Model Architectures

Select, design, and understand ML model architectures across all major paradigms.

## When to Use

- Selecting an architecture for a new ML task
- Understanding trade-offs between architecture families
- Implementing custom layers or attention mechanisms
- Analyzing a paper's architecture choices
- Adapting an architecture to new constraints (latency, memory, modality)

## Architecture Catalog

### Transformer Family

| Variant | Key Idea | Strengths | Weaknesses |
| --------- | ---------- | ----------- | ------------ |
| **Encoder-only** (BERT) | Bidirectional self-attention | Classification, embeddings | Not generative |
| **Decoder-only** (GPT) | Causal self-attention | Generation, in-context learning | Quadratic in sequence length |
| **Encoder-Decoder** (T5) | Cross-attention bridge | Seq2seq, translation | Higher parameter count |
| **Temporal + Depth** (Moshi) | Dual transformer for multi-stream | Multi-codebook audio | Complex training |
| **Vision Transformer** (ViT) | Patch embedding + attention | Image classification | Needs large data or distillation |

### State Space Models

| Variant | Key Idea | Strengths | Weaknesses |
| --------- | ---------- | ----------- | ------------ |
| **S4** | Structured state space | Long sequences, linear cost | Less expressive than attention |
| **Mamba** | Selective SSM, input-dependent | Fast inference, long context | Newer ecosystem |
| **RWKV** | Linear attention RNN | RNN-like inference, Transformer-like training | Limited adoption |
| **Hyena** | Implicit convolutions | Sub-quadratic | Early stage |

### Mixture of Experts (MoE)

| Aspect | Detail |
| -------- | -------- |
| **Core idea** | Sparse routing: only activate top-k experts per token |
| **Gating** | Learned router (softmax, top-k selection) |
| **Load balancing** | Auxiliary loss to prevent expert collapse |
| **Examples** | Mixtral 8×7B, Switch Transformer, GShard |
| **Trade-offs** | More total params, same FLOPs; communication overhead |

### Self-Supervised & Predictive

| Architecture | Key Idea | Use Case |
| ------------- | ---------- | ---------- |
| **JEPA** | Predict latent representations, not pixels | Self-supervised learning (LeCun) |
| **MAE** | Masked autoencoder, reconstruct patches | Vision pre-training |
| **BYOL / SimCLR** | Contrastive / non-contrastive | Representation learning |
| **World Models** | Learn environment dynamics in latent space | Planning, RL, video prediction |

### Generative Models

| Architecture | Key Idea | Use Case |
| ------------- | ---------- | ---------- |
| **Diffusion** | Iterative denoising (DDPM/DDIM) | Image, audio generation |
| **Flow Matching** | Optimal transport, continuous flows | Speech (LSD), images |
| **VAE** | Latent variable model, ELBO | Generation, compression |
| **VQ-VAE / RVQ** | Discrete latent codes | Neural codecs (Mimi) |
| **GAN** | Adversarial training | Image synthesis, super-resolution |
| **Autoregressive** | Token-by-token generation | Language, audio (Moshi) |

## Attention Mechanism Reference

See `references/attention-mechanisms.md` for detailed comparison.

## Architecture Selection Decision Tree

```text
ask type?
├── Sequence generation (text, audio) → Decoder-only Transformer or Mamba
├── Sequence understanding → Encoder-only (BERT) or Encoder-Decoder
├── Image generation → Diffusion / Flow Matching
├── Image classification → ViT / CNN (EfficientNet)
├── Audio codec → VQ-VAE / RVQ (Mimi pattern)
├── Audio generation → Flow Matching (LSD) or Autoregressive + codec
├── Self-supervised pre-training → MAE / JEPA / contrastive
├── Sparse large model → MoE
└── Very long sequences → Mamba / S4 / Hyena

Latency constraint?
├── < 10ms → Small model + quantization + compiled kernels
├── < 100ms → Standard Transformer + int8
├── Real-time streaming → Streaming Transformer with KV cache (Moshi pattern)
└── Batch processing → Largest feasible model
```

## Kyutai Open-Source Reference — Architectures

| Project | Architecture | Key Components |
| --------- | ------------- | ---------------- |
| Moshi | Temporal Transformer (7B) + Depformer | RoPE, RMSNorm, SwiGLU, GQA, streaming KV cache |
| Mimi | Encoder-Decoder with RVQ | 8 codebooks, 12.5 Hz, SEANet backbone |
| Pocket-TTS | Lightweight Transformer | CPU-targeted, small footprint |
| Hibiki | Speech-to-speech Transformer | Cross-lingual transfer |
| LSD | Flow Matching network | Latent speech diffusion |

## Procedure

1. **Define** task, modality, and constraints
2. **Shortlist** 2-3 candidate architectures from the catalog
3. **Compare** on: compute cost, memory, scaling behavior, data efficiency, implementation complexity
4. **Prototype** smallest viable version of top candidate
5. **Ablate** key design choices (attention type, depth, width, normalization)
6. **Scale** winning architecture to target size
