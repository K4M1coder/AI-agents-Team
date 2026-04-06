# Monetization Models Reference

Pricing strategies and implementation patterns for AI products.

## Pricing Model Comparison

| Model | Best For | Pros | Cons |
| ------- | --------- | ------ | ------ |
| **Per-request** | Simple APIs | Easy to understand, predictable billing | Doesn't account for cost variation |
| **Per-token** | LLMs | Directly tied to compute cost | Complex for users to estimate |
| **Per-second** | Audio/Video | Intuitive for media | Variable quality/cost per second |
| **Subscription** | Predictable usage | Predictable revenue | May overprovision or under-serve |
| **Hybrid** | Complex products | Flexible, captures value | Complex billing logic |
| **Freemium** | Growth-stage | Low barrier to entry | May never convert free users |

## Tier Design Patterns

### Standard 3-Tier

| Feature | Free | Pro ($49/mo) | Enterprise (Custom) |
| --------- | ------ | ------------- | ------------------- |
| Requests/month | 1,000 | 100,000 | Unlimited |
| Models | Base | All standard | All + custom |
| Concurrent sessions | 1 | 10 | Custom |
| Audio minutes/month | 10 | 1,000 | Unlimited |
| Fine-tuning | No | Self-service | Managed + assisted |
| Support | Community | Email (24h SLA) | Dedicated + Slack |
| Latency SLA | Best effort | p95 < 200ms | p99 < 100ms |
| Data retention | 7 days | 30 days | Custom |
| SSO/SAML | No | No | Yes |
| VPC deployment | No | No | Yes |

### Usage-Based Pricing

```text
Base: $0/month (free tier)
Audio processing: $0.006 per second
Text generation: $0.002 per 1K tokens (input) + $0.008 per 1K tokens (output)
Fine-tuning: $0.008 per 1K tokens trained
Storage: $0.02 per GB/month (for custom models)
```

### Enterprise Custom Pricing

Factors for enterprise pricing:

- Volume commitments (annual minimums)
- Custom SLAs (99.9% vs 99.99%)
- Dedicated infrastructure costs
- Support level and dedicated engineer
- Custom model development hours
- Data processing and privacy requirements

## Implementation Patterns

### Usage Metering System

```python
from dataclasses import dataclass
from datetime import datetime
import asyncio

@dataclass
class UsageRecord:
    api_key: str
    model: str
    input_tokens: int
    output_tokens: int
    audio_seconds: float
    compute_ms: int
    timestamp: datetime

class UsageMeter:
    def __init__(self, storage):
        self.storage = storage
        self._buffer: list[UsageRecord] = []
        self._flush_interval = 10  # seconds

    async def record(self, record: UsageRecord):
        self._buffer.append(record)
        if len(self._buffer) >= 100:
            await self._flush()

    async def _flush(self):
        records = self._buffer.copy()
        self._buffer.clear()
        await self.storage.batch_insert(records)

    async def get_usage(self, api_key: str, period: str) -> dict:
        return await self.storage.aggregate(
            api_key=api_key,
            period=period,
            metrics=["input_tokens", "output_tokens", "audio_seconds", "requests"],
        )
```

### Quota Enforcement

```python
class QuotaEnforcer:
    LIMITS = {
        "free": {"requests_per_month": 1000, "concurrent": 1},
        "pro": {"requests_per_month": 100000, "concurrent": 10},
        "enterprise": {"requests_per_month": float("inf"), "concurrent": 100},
    }

    async def check_quota(self, api_key: str) -> bool:
        tier = await self.get_tier(api_key)
        limits = self.LIMITS[tier]

        current_usage = await self.meter.get_usage(api_key, "month")
        if current_usage["requests"] >= limits["requests_per_month"]:
            raise QuotaExceeded(
                f"Monthly request limit ({limits['requests_per_month']}) exceeded",
                retry_after=self._seconds_until_reset(),
            )

        active_sessions = await self.session_manager.count(api_key)
        if active_sessions >= limits["concurrent"]:
            raise ConcurrentLimitExceeded(
                f"Concurrent session limit ({limits['concurrent']}) exceeded"
            )

        return True
```

### Billing Integration

```python
# Monthly billing aggregation
async def generate_invoice(api_key: str, month: str) -> Invoice:
    usage = await meter.get_usage(api_key, month)
    tier = await get_tier(api_key)

    line_items = []

    # Base subscription
    if tier == "pro":
        line_items.append(LineItem("Pro subscription", 49.00))

    # Usage charges (overage beyond plan)
    if usage["audio_seconds"] > TIER_INCLUDED_AUDIO[tier]:
        overage = usage["audio_seconds"] - TIER_INCLUDED_AUDIO[tier]
        line_items.append(LineItem(
            f"Audio processing ({overage:.0f}s overage)",
            overage * 0.006,
        ))

    if usage["output_tokens"] > TIER_INCLUDED_TOKENS[tier]:
        overage = usage["output_tokens"] - TIER_INCLUDED_TOKENS[tier]
        line_items.append(LineItem(
            f"Text generation ({overage/1000:.0f}K tokens overage)",
            overage / 1000 * 0.008,
        ))

    return Invoice(api_key=api_key, month=month, items=line_items)
```

## Kyutai Open-Source Reference — Product Monetization

| Product | Model | Rationale |
| --------- | ------- | ----------- |
| **Moshi API** | Per-second audio + subscription | Premium real-time speech |
| **Pocket-TTS** | Per-request + free tier | Low barrier, high volume |
| **Mimi codec** | Open-source + support contracts | Ecosystem play |
| **Unmute platform** | Hybrid (subscription + usage) | Multi-model bundle |
| **Fine-tuning** | Per-token trained + support | High-value professional service |

## Key Metrics to Track

| Metric | Formula | Healthy |
| -------- | --------- | --------- |
| **ARPU** | Revenue / Active Users | Growing |
| **Conversion rate** | Paid / Total signups | 2-5% |
| **Churn rate** | Lost customers / Total | < 5%/month |
| **LTV** | ARPU × avg lifetime | > 3× CAC |
| **Unit economics** | Revenue per request - cost per request | Positive |
| **Gross margin** | (Revenue - GPU cost) / Revenue | > 50% |

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| ------------- | --------- | ----- |
| Only free tier | No revenue | Add paid tier with clear value |
| No usage visibility | Users surprised by bills | Real-time usage dashboard |
| Hard cutoff at limits | Bad UX | Soft limits with warnings |
| Pricing by model size | Users don't care about params | Price by value (quality, speed) |
| No annual option | Unpredictable revenue | Offer annual discount (20%) |
