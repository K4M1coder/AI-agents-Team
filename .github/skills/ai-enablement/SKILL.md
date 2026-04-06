---
name: executant-ai-enablement
description: "**WORKFLOW SKILL** — AI user enablement and monetization: training programs, onboarding, configuration guides, SDK documentation, pricing models, usage metering, SaaS patterns, API gateways, and model-selection guidance across open-weight families. USE FOR: creating user documentation, designing training curricula, implementing usage metering, defining pricing tiers, and helping users choose the right model family. USE WHEN: onboarding users to AI products, creating training materials, designing monetization strategy, or writing family-aware configuration guides."
argument-hint: "Describe the enablement task: training program, documentation, pricing design, or SDK guide"
---

# AI Enablement & Monetization

Bridge the gap between AI capabilities and user adoption through training, documentation, and sustainable monetization.

## When to Use

- Creating training programs for AI product users
- Writing integration guides and tutorials
- Designing API pricing and usage metering
- Building onboarding flows for developers
- Creating configuration guides for model deployment
- Writing model-selection and deployment guides across current open-weight families

## Core Concepts

| Concept | Description |
| --------- | ------------- |
| **Developer Experience (DX)** | How easy it is for developers to integrate your AI |
| **Time to First Call** | How quickly a developer can make their first API request |
| **Usage Metering** | Tracking and billing for API consumption |
| **Tier Design** | Free/Pro/Enterprise feature and limit differentiation |
| **Churn Prevention** | Maintaining users through value delivery |

## Open-Weight Model Selection Reference

Use `../_shared/references/llm-landscape.md` when the material must help users choose between current open-weight model families.

- Use `../_shared/references/models/` for family-specific positioning and tradeoffs.
- Use `../_shared/references/models/edge-small.md` for low-VRAM, offline, or on-device guidance.

## Procedure

### Phase 1: Training Program Design

1. **Assess** target audience:
   - **Beginners**: What is AI? How to use the API?
   - **Intermediate**: Fine-tuning, custom models, optimization
   - **Expert**: Architecture design, scaling, custom training

2. **Design** curriculum:
   ```
   Module 1: Getting Started (30 min)
   ├── 1.1 What is [Product]?
   ├── 1.2 Quick start (first API call)
   └── 1.3 Key concepts

   Module 2: Core Usage (2 hours)
   ├── 2.1 API reference walkthrough
   ├── 2.2 Streaming integration
   └── 2.3 Error handling & best practices

   Module 3: Advanced (4 hours)
   ├── 3.1 Fine-tuning with LoRA
   ├── 3.2 Custom model deployment
   └── 3.3 Performance optimization

   Module 4: Production (2 hours)
   ├── 4.1 Scaling and monitoring
   ├── 4.2 Security best practices
   └── 4.3 Cost optimization
   ```

3. **Create** materials: docs, Jupyter notebooks, code samples
4. **Validate** with test users
5. **Iterate** based on feedback and support tickets

### Phase 2: Documentation Strategy

| Doc Type | Purpose | Format |
| --------- | --------- | -------- |
| Quick Start | First API call in < 5 min | Tutorial |
| API Reference | Complete endpoint docs | OpenAPI + examples |
| Guides | Task-specific walkthroughs | How-to |
| Concepts | Explain underlying technology | Explanation |
| FAQ | Common questions | Q&A |
| Changelog | Track API changes | Versioned list |
| Migration Guide | Version upgrade help | Step-by-step |

### Phase 3: Monetization Design

**Pricing Models:**

| Model | Best For | Implementation |
| ------- | --------- | ---------------- |
| **Per-request** | Simple APIs | Count API calls |
| **Per-token** | LLM APIs | Count input+output tokens |
| **Per-second** | Streaming audio | Duration tracking |
| **Subscription** | Predictable usage | Monthly plan |
| **Hybrid** | Complex products | Base subscription + usage |

**Tier Design Template:**

| Feature | Free | Pro | Enterprise |
| --------- | ------ | ----- | ----------- |
| Requests/month | 1,000 | 100,000 | Unlimited |
| Models | Base only | All models | All + custom |
| Max concurrent | 1 | 10 | Custom |
| Latency SLA | Best effort | p95 < 200ms | p99 < 100ms |
| Support | Community | Email (24h) | Dedicated + SLA |
| Fine-tuning | No | Self-service | Managed |
| Price | $0 | $49/mo + usage | Custom |

### Phase 4: Usage Metering

```python
# Token counting middleware
@app.middleware("http")
async def meter_usage(request: Request, call_next):
    response = await call_next(request)
    if request.url.path.startswith("/v1/"):
        usage = response.headers.get("X-Usage-Tokens", "0")
        await record_usage(
            api_key=request.headers.get("Authorization"),
            tokens=int(usage),
            model=request.headers.get("X-Model"),
            timestamp=datetime.utcnow(),
        )
    return response
```

**Metering dimensions:**
- Input tokens / output tokens
- Compute time (GPU-seconds)
- Audio duration (seconds)
- Number of concurrent sessions
- Storage (for fine-tuned models)

### Phase 5: API Gateway

```yaml
# API gateway configuration (Kong / Traefik / custom)
routes:
  - path: /v1/inference
    rate_limit:
      free: 10/minute
      pro: 100/minute
      enterprise: 1000/minute
    authentication: api_key
    cors: true
    timeout: 30s
    circuit_breaker:
      threshold: 50%
      timeout: 60s
```

## Kyutai Open-Source Reference — Product Enablement

> These are publicly available Kyutai open-source products. Use as integration/enablement reference for similar AI SaaS patterns.

| Product | Target User | Monetization |
| --------- | ------------ | ------------- |
| Moshi | Enterprise, researchers | API-as-a-Service (streaming audio) |
| Pocket-TTS | Developers, edge apps | Free tier + Pro (higher quality) |
| Mimi | ML engineers | Open-source, support contracts |
| Unmute | Enterprise | Multi-model API bundle |
| Hibiki | Translation platforms | Per-request pricing |

## Output Format

- **Training Program**: Curriculum outline with materials list
- **Integration Guide**: Step-by-step with code examples
- **Pricing Proposal**: Tier table with rationale
- **Onboarding Flow**: User journey diagram
- **API Gateway Config**: Rate limits, auth, routing
