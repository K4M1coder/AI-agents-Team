# MiniMax Family

Includes MiniMax M2.5, M2.5-Lightning, and M2.7.

## Variant Snapshot

| Model | Style | Total / Active Params | Context | Primary Use | Notes |
| ----- | ----- | --------------------- | ------- | ----------- | ----- |
| MiniMax-M2.5 | Sparse MoE | ~229B-230B / ~10B active | ~200k | Code + agents | Major SWE-focused release |
| MiniMax-M2.5-Lightning | Optimized serving variant | Same family | ~200k | Latency / throughput | About 100 tok/s via the official API |
| MiniMax-M2.7 | Improved code / productivity line | Large | N/A | Coding + self-evolution branding | Strong SWE-Pro / Multi-SWE scores |

## Architecture and Innovations

- MiniMax is one of the strongest code-agent families in the 2026 open-weight wave.
- M2.5 is a large MoE line with heavy emphasis on agentic coding and realistic environments.
- M2.7 extends the brand around self-improvement and productivity benchmarks.

## Training and Post-Training Notes

- MiniMax reports large-scale RL on more than 200,000 real environments for M2.5.
- The line is clearly optimized around code, browsing, office-like tasks, and tool-heavy agents.

## Inference and Deployment Profiles

| Deployment Profile | Good Candidates | Notes |
| ------------------ | --------------- | ----- |
| 4 x 80 GB GPUs | M2.5 quantized | Strong internal code-agent cluster candidate |
| Larger node / unified memory | M2.5 bf16 | About 457 GB inference memory unquantized |
| API or hosted use | M2.5-Lightning, M2.7 | Useful when local hardware is insufficient |

Serving notes:

- Referenced deployment guides report roughly 101 GB for dynamic 3-bit GGUF on M2.5.
- MiniMax is especially relevant for internal IDE, repo automation, and maintenance workflows.

## Strengths and Positioning

| Model | Strength |
| ----- | ----------------- |
| M2.5 | Around 80.2% SWE-Bench Verified, making it one of the strongest open-weight software-engineering models |
| M2.7 | Around 56.22% SWE-Pro with strong Multi-SWE and multilingual coding results |

## Repos and Weights

- OpenHands analysis: <https://openhands.dev/blog/minimax-m2-5-open-weights-models-catch-up-to-claude>
- Local guide: <https://unsloth.ai/docs/models/minimax-m25>
- M2.7 docs: <https://platform.minimax.io/docs/guides/text-ai-coding-tools>
- M2.7 product page: <https://www.minimax.io/models/text/m27>
- M2.7 Ollama: <https://ollama.com/library/minimax-m2.7>

## Sources

- <https://openhands.dev/blog/minimax-m2-5-open-weights-models-catch-up-to-claude>
- <https://unsloth.ai/docs/models/minimax-m25>
- <https://jangwook.net/en/blog/en/minimax-m25-open-weight-vs-proprietary/>
- <https://platform.minimax.io/docs/guides/text-ai-coding-tools>
- <https://www.minimax.io/news/minimax-m27-en>
- <https://www.minimax.io/models/text/m27>
- <https://ollama.com/library/minimax-m2.7>
