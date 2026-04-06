---
name: cutting-edge-architectures
description: "**WORKFLOW SKILL** — Cutting-edge ML architecture techniques: DeepSeek MLA (KV latent compression), mHC/HC (manifold-constrained hyper-connections, residual topology), SMoE/MoE (sparse expert routing, expert parallelism, DeepSpeed-MoE/Tutel), Kimi AttnRes (depth-wise attention residuals), Meta JEPA/world models, TurboQuant (online KV quantization), DyT normalization. USE FOR: evaluating breakthrough techniques for adoption; implementing MLA-class attention; designing JEPA-based self-supervised pipelines; applying sub-4-bit KV cache quantization; replacing residual connections with HC or mHC for deeper stability; adopting sparse MoE routing with DeepSpeed-MoE or Tutel; sizing expert parallelism for MoE training/inference. USE WHEN: architecture decision touches 2024–2026 SOTA; serving budget requires MLA-class KV reduction; need world-model or latent-prediction self-supervised training; training instability suspected in deep residual stacks; sublinear compute scaling needed via sparse expert routing."
argument-hint: "Describe the technique, model, or design question: e.g. 'Should we adopt MLA for our 70B decoder?', 'How does V-JEPA 2 handle planning?', 'TurboQuant vs AWQ at 3.5 bits', 'mHC vs HC for training stability at 27B scale', 'DeepSpeed-MoE vs Tutel for 64-expert training on 8×H100', 'Expert collapse prevention for fine-grained SMoE'"
---

# Cutting-Edge Architectures

Evaluate, implement, and adapt breakthrough architecture techniques from 2024–2026 SOTA research.

## When to Use

- Deciding whether to adopt MLA, AttnRes, or JEPA paradigms in a new or existing model
- Implementing or fine-tuning models with low-rank KV compression (DeepSeek V2/V3/R1)
- Designing self-supervised pretraining using latent prediction (JEPA family)
- Selecting sub-4-bit KV quantization approaches for long-context serving
- Replacing LayerNorm with DyT for training stability at scale
- Benchmarking current implementation against 2025–2026 SOTA

## Core Concepts

| Technique | Family | Key Paper | Core Idea |
| ----------- | -------- | ----------- | ----------- |
| **MLA** (Multi-head Latent Attention) | Attention | arxiv:2405.04434 | Low-rank joint compression of KV → 93.3% KV cache reduction |
| **AttnRes** (Attention Residuals) | Residual Connection | arxiv:2603.15031 | Softmax attention over all preceding layer outputs instead of fixed unit-weight skip |
| **I-JEPA** | Self-supervised | arxiv:2301.08243 | Predict latent representations of masked image blocks (not pixels) |
| **V-JEPA 2** | World Model | arxiv:2506.09985 | Video SSL + robot interaction planning via latent prediction |
| **V-JEPA 2.1** | World Model | arxiv:2603.14482 | Dense predictive loss + spatial understanding |
| **LLM-JEPA** | Self-supervised LLM | arxiv:2509.14252 | JEPA objectives applied to LLM embedding-space pretraining |
| **VL-JEPA** | Vision-Language | arxiv:2512.10942 | Predicts continuous text embeddings (not discrete tokens) |
| **Causal-JEPA** | World Model | arxiv:2602.11389 | Object-centric relational world model with latent interventions |
| **LeJEPA** | Theory | arxiv:2511.08544 | Formal JEPA theory + lean scalable training objective |
| **LeWorldModel** | World Model | arxiv:2603.19312 | First stable end-to-end JEPA from pixels; no EMA or auxiliary supervision |
| **HC** (Hyper-Connections) | Residual Connection | arxiv:2409.19606 | Learnable ℋ𝒞 matrix replaces fixed skip; depth-connections (vertical) + width-connections (lateral); 1.8× faster convergence, +6 pts ARC-Challenge on MoE |
| **mHC** (Manifold-Constrained HC) | Residual Connection | arxiv:2512.24880 | Projects HC mixing matrices onto Birkhoff polytope (doubly stochastic) via Sinkhorn-Knopp; restores identity mapping; stable at 3B–27B scale; +6.7% compute for substantial quality gain |
| **TurboQuant** | KV Quantization | arxiv:2504.19874 | Random rotation + optimal scalar quantizer + 1-bit QJL residual; near-optimal distortion |
| **DyT** (Dynamic Tanh) | Normalization | arxiv:2503.10622 | Drop-in `tanh(αx)` replacement for LayerNorm; no running stats required |
| **DeepSeekMoE** | MoE Routing | arxiv:2405.04434 | 256 fine-grained → 8 activated; auxiliary-loss-free (expert isolation loss); 5.76× throughput with MLA |
| **SMoE** (Sparse MoE) | MoE Systems | arxiv:2602.08019 | Sublinear compute scaling via top-k routing; system stacks: DeepSpeed-MoE, Tutel, X-MoE; expert parallelism |
| **Unified Competitive Learning** | MoE Routing Theory | arxiv:2503.22996 | LP formulation unifying auxiliary loss, entropy regularization, and variational constraints for expert routing |

## Methodology

### Phase 1: Technique Evaluation

1. **Identify** the bottleneck or gap: KV memory, training efficiency, self-supervised pretraining quality, serving cost
2. **Map** to technique family: attention → MLA/AttnRes; pretraining → JEPA; quantization → TurboQuant; normalization → DyT
3. **Read** the reference file for that technique (see below)
4. **Assess** adoption cost: refactoring depth, framework support, calibration data requirements

### Phase 2: Architecture Decision

1. **Compare** against current implementation using the reference comparison tables
2. **Prototype** the minimal change required (e.g., swap KV projection matrices for MLA, add Block AttnRes)
3. **Measure** KV cache memory, throughput, and accuracy on held-out benchmark
4. **Decide**: full adoption, partial adoption (e.g., just Block AttnRes for last N layers), or defer

### Phase 3: Implementation

1. For **MLA**: Start from `deepseek-ai/DeepSeek-V3` or implement decoupled RoPE + KV latent projection. See `references/attention-innovations.md`.
2. For **AttnRes**: Replace residual add with learned depth-wise attention. Block AttnRes is the production-feasible variant. See `references/attention-innovations.md`.
3. For **HC / mHC**: Replace `residual_add` with the ℋ𝒞 mixing step. For mHC, apply Sinkhorn-Knopp projection after each mixing matrix update (1–3 iterations suffice for mHC-lite). Use fused kernels for the lane-broadcast step. See `references/residual-innovations.md`.
3b. For **MoE / SMoE**: Configure DeepSpeed-MoE or Tutel for sparse expert routing. Set `ep_size`, `capacity_factor`, load balance loss. For fine-grained pattern, use 256 sub-experts → 8 activated (DeepSeekMoE). For expert parallelism sizing, match `ep_size` to GPU topology. See `references/moe-sparse-routing.md`.
4. For **JEPA**: Use Meta's open-source checkpoints as teacher. Implement VICReg / LeJEPA collapse prevention. See `references/jepa-world-models.md`.
5. For **TurboQuant**: Apply three-step pipeline (rotation → scalar quant → QJL residual) via reference pattern. See `references/advanced-quantization.md`.
6. For **DyT**: Replace `nn.LayerNorm` with `DynamicTanh(alpha=0.5)` (learnable α). See `references/advanced-quantization.md`.

### Phase 4: Benchmarking & Reporting

1. **Latency/Throughput**: TTFT, tokens/sec, GPU memory at batch sizes 1 / 8 / 64
2. **Quality**: Perplexity, task benchmarks (MMLU, HumanEval, ARC), task-specific metrics
3. **KV memory**: Bytes/token at target context length vs baseline
4. **Report**: Include architecture diagram, table comparing baseline vs new, decision rationale

## Reference Files

| File | Contents |
| ------ | ---------- |
| `references/attention-innovations.md` | DeepSeek MLA + Kimi AttnRes — math, code patterns, adoption guide |
| `references/residual-innovations.md` | HC + mHC — ℋ𝒞 math, Sinkhorn projection, PyTorch patterns, adoption guide, 2026 variant comparison |
| `references/jepa-world-models.md` | Full JEPA taxonomy, collapse prevention, per-domain application guide |
| `references/advanced-quantization.md` | TurboQuant algorithm, DyT normalization, bit-width comparison tables |
| `references/moe-sparse-routing.md` | SMoE routing, expert collapse prevention, DeepSpeed-MoE/Tutel/X-MoE stacks, expert parallelism, inference patterns, adoption guide |

## Coordinates With

| Agent | Handoff |
| ------- | -------- |
| `executant-ml-researcher` | Provides architecture analysis and paper triage; receives design recommendations |
| `executant-ml-engineer` | Provides implementation patterns; receives training feasibility feedback |
| `executant-inference-engineer` | Provides KV-efficient serving patterns (MLA, TurboQuant); receives deployment constraints |
| `executant-gpu-infra` | Provides memory budget and hardware constraints; receives compute projections |
| `executant-research-intelligence` | Receives alerts on new JEPA, attention, and quantization papers; provides synthesis |
