# Olmo Family

Includes Olmo 3 and Olmo 3.1 Base / Instruct / Think variants from AI2.

## Variant Snapshot

| Model | Style | Params | Context | Primary Use | Notes |
| ----- | ----- | ------ | ------- | ----------- | ----- |
| Olmo 3 Base | Dense | 7B / 32B | ~65k | Fine-tuning base | Fully open pipeline |
| Olmo 3 Instruct | Dense | 7B / 32B | ~65k | Chat + tools | Practical interactive use |
| Olmo 3 Think | Dense reasoning | 7B / 32B | ~65k | Reasoning | Strong fully open reasoning tier |
| Olmo 3.1 Think 32B | Dense reasoning + RL extension | 32B | ~65k | Advanced reasoning | Extended RL improvements |
| Olmo 3.1 Instruct 32B | Dense instruct | 32B | ~65k | Chat, tools, agents | Updated post-training line |

## Architecture and Innovations

- Olmo is the strongest fully open model line in this landscape, with weights, data, and code transparency.
- The line stays dense rather than MoE-heavy, which simplifies some deployment and interpretability concerns.

## Training and Post-Training Notes

- AI2 describes about 6T pretraining tokens for Olmo 3.
- Olmo 3.1 extends reasoning performance with additional RL over Think 32B for roughly 21 more days on 224 GPUs.

## Inference and Deployment Profiles

| Deployment Profile | Good Candidates | Notes |
| ------------------ | --------------- | ----- |
| 1 x 16-24 GB GPU | Olmo 3 / 3.1 7B | Fully open local line |
| 1 x 48-80 GB GPU | Olmo 3 / 3.1 32B | Strong reasoning or chat stack |
| Multi-GPU | 32B high-throughput serving | Useful for enterprise transparency requirements |

Serving notes:

- Olmo is a prime candidate when auditability and reproducibility matter more than raw frontier bragging rights.
- Olmo 3.1 Think 32B is one of the best fully open reasoning models in the current open-weight landscape.

## Strengths and Positioning

| Model | Strength |
| ----- | ----------------- |
| Olmo 3 Think 7B | Matches Qwen3 8B on MATH and leads HumanEvalPlus in class |
| Olmo 3 Think 32B | Strongest fully open 32B reasoning model in current open-weight comparisons |
| Olmo 3.1 Think 32B | Improves AIME, ZebraLogic, IFEval, IFBench and beats Qwen3 32B on AIME 2025 |

## Repos and Weights

- AI2 announcement: <https://allenai.org/blog/olmo3>
- HF weights: <https://huggingface.co/allenai/Olmo-3-1125-32B>
- OpenRouter listing for 3.1 Think 32B: <https://openrouter.ai/allenai/olmo-3.1-32b-think>

## Sources

- <https://allenai.org/blog/olmo3>
- <https://huggingface.co/allenai/Olmo-3-1125-32B>
- <https://prospere.fr/le-nouvel-olmo-3-1-dai2-etend-la-formation-dapprentissage-par-renforcement-pour-des-references-de-raisonnement-plus-solides/>
- <https://openrouter.ai/allenai/olmo-3.1-32b-think>
