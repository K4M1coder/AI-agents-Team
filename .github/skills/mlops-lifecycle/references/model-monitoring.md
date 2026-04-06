# Model Monitoring Reference

Patterns for monitoring ML models in production.

## Monitoring Layers

```text
┌─────────────────────────────────────────────┐
│ Layer 1: Infrastructure Monitoring          │
│ - GPU utilization, memory, temperature      │
│ - Network bandwidth, latency               │
│ - Container health, restarts               │
├─────────────────────────────────────────────┤
│ Layer 2: Application Monitoring             │
│ - Request rate, latency (p50/p95/p99)      │
│ - Error rate, timeout rate                 │
│ - Queue depth, batch utilization           │
├─────────────────────────────────────────────┤
│ Layer 3: Model Performance Monitoring       │
│ - Prediction quality metrics               │
│ - Data drift detection                     │
│ - Feature drift detection                  │
├─────────────────────────────────────────────┤
│ Layer 4: Business Monitoring                │
│ - User satisfaction, feedback              │
│ - Cost per prediction                      │
│ - Revenue impact                           │
└─────────────────────────────────────────────┘
```

## Data Drift Detection

### Statistical Tests

| Test | Data Type | Use Case |
| ------ | ----------- | ---------- |
| KS test (Kolmogorov-Smirnov) | Continuous | Compare distributions |
| PSI (Population Stability Index) | Continuous | Binned comparison |
| Chi-square | Categorical | Category frequency shift |
| Jensen-Shannon divergence | Any | Symmetric KL divergence |
| Wasserstein distance | Continuous | Earth mover's distance |

### PSI Thresholds
| PSI Value | Interpretation | Action |
| ----------- | --------------- | -------- |
| < 0.1 | No significant shift | No action |
| 0.1 - 0.2 | Moderate shift | Investigate |
| > 0.2 | Significant shift | Retrain |

### Evidently Setup
```python
from evidently import ColumnMapping
from evidently.report import Report
from evidently.metric_preset import DataDriftPreset

report = Report(metrics=[DataDriftPreset()])
report.run(reference_data=train_df, current_data=production_df)
report.save_html("drift_report.html")
```

## Model Quality Monitoring

### Metrics by Task

| Task | Primary Metric | Secondary Metrics |
| ------ | --------------- | ------------------- |
| Speech recognition | WER | CER, RTF |
| Text-to-speech | MOS | PESQ, STOI, speaker similarity |
| Dialogue | Human eval | Perplexity, response relevance |
| Classification | F1 / Accuracy | Precision, Recall, AUC |
| Generation | Human eval | BLEU, ROUGE, BERTScore |

### Alert Thresholds

```yaml
alerts:
  - name: model_quality_degradation
    metric: eval_wer
    condition: "> baseline + 5%"
    severity: warning
    action: investigate

  - name: latency_slo_breach
    metric: p95_latency_ms
    condition: "> 200"
    severity: critical
    action: page_oncall

  - name: error_rate_spike
    metric: error_rate_5m
    condition: "> 1%"
    severity: critical
    action: page_oncall

  - name: data_drift_detected
    metric: psi_score
    condition: "> 0.2"
    severity: warning
    action: schedule_retrain
```

## Prometheus Metrics for ML

```python
from prometheus_client import Histogram, Counter, Gauge

# Inference metrics
INFERENCE_LATENCY = Histogram(
    "model_inference_latency_seconds",
    "Model inference latency",
    buckets=[0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0],
)

INFERENCE_TOTAL = Counter(
    "model_inference_total",
    "Total inference requests",
    ["model_name", "status"],
)

GPU_MEMORY_USED = Gauge(
    "gpu_memory_used_bytes",
    "GPU memory usage",
    ["gpu_id"],
)

# Usage
with INFERENCE_LATENCY.time():
    output = model(input)
INFERENCE_TOTAL.labels(model_name="moshi-7b", status="success").inc()
```

## Grafana Dashboard Template

### Key Panels
1. **Request Rate**: `rate(model_inference_total[5m])`
2. **Latency (p95)**: `histogram_quantile(0.95, rate(model_inference_latency_seconds_bucket[5m]))`
3. **Error Rate**: `rate(model_inference_total{status="error"}[5m]) / rate(model_inference_total[5m])`
4. **GPU Utilization**: `nvidia_gpu_utilization_percent`
5. **GPU Memory**: `nvidia_gpu_memory_used_bytes / nvidia_gpu_memory_total_bytes`
6. **Queue Depth**: `model_queue_depth`
7. **Batch Size**: `avg(model_batch_size)`
8. **Data Drift (PSI)**: `model_psi_score`

## Retraining Triggers

| Trigger | Signal | Cadence |
| --------- | -------- | --------- |
| Scheduled | Calendar | Weekly/monthly |
| Data drift | PSI > 0.2 | On detection |
| Performance drop | Metric below threshold | On detection |
| New data volume | N new labeled samples | On threshold |
| User feedback | Negative feedback rate | On threshold |

## Rollback Procedure

1. **Detect**: Alert fires on quality degradation
2. **Confirm**: Verify with manual spot-check
3. **Rollback**: Switch traffic to previous model version
4. **Investigate**: Root cause analysis (data issue, model issue, infra issue)
5. **Fix**: Address root cause and retrain
6. **Validate**: Run full evaluation before redeploying
7. **Deploy**: Canary → full rollout
