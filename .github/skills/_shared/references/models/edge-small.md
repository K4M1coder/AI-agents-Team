# Edge and Small-Model Routing

Selection guide for low-VRAM, offline, or on-device deployment.

This file is intentionally a guide, not a duplicate catalog. Detailed facts stay in the lab files.

Use this reference after `llm-landscape.md` has narrowed the search to low-cost or low-memory deployments.

## Quick Picks

| Constraint | Recommended Models | Detailed Reference |
| ---------- | ------------------ | ------------------ |
| Phone / embedded reasoning | LFM2.5-1.2B-Thinking | [liquid.md](liquid.md) |
| Tiny general local assistant | Ministral 3 3B | [mistral.md](mistral.md) |
| Small multilingual model | Tiny Aya | [emerging-models.md](emerging-models.md) |
| Small multimodal Google stack | Gemma 4 E2B / E4B | [gemma.md](gemma.md) |
| Budget reasoning on 24 GB | DeepSeek-R1 distill 7B / 14B | [deepseek.md](deepseek.md) |
| Transparent 7B local reasoning | Olmo 3 Think 7B | [olmo.md](olmo.md) |

## Practical Routing Rules

### If VRAM is under 16 GB

- Start with LFM2.5-1.2B-Thinking, Ministral 3 3B, or Tiny Aya.
- Prefer GGUF or equivalent low-bit formats when available.

### If you have 16-24 GB VRAM

- DeepSeek-R1 distill 7B-14B is usually the best reasoning step up.
- TranslateGemma 12B is the better choice for translation than repurposing a general 7B-14B chat model.

### If you need offline multilingual support

- Tiny Aya and Gemma 4 E2B / E4B should be evaluated first.

### If you need edge reasoning plus OCR pipeline support

- Use DeepSeek-OCR upstream, then a small reasoning model downstream.
- For translation-heavy document workflows, pair DeepSeek-OCR with TranslateGemma.

## Related References

- [mistral.md](mistral.md)
- [deepseek.md](deepseek.md)
- [gemma.md](gemma.md)
- [olmo.md](olmo.md)
- [liquid.md](liquid.md)
- [emerging-models.md](emerging-models.md)
