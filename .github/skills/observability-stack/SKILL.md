---
name: observability-stack
description: "**WORKFLOW SKILL** — Deploy and configure observability with Prometheus, Grafana, Loki, and Tempo. USE FOR: Prometheus setup and PromQL queries, Grafana dashboard design, Loki log aggregation and LogQL, Tempo distributed tracing, Alertmanager routing and silences, OpenTelemetry instrumentation, recording rules, SLI/SLO dashboards, burn-rate alerting, RED/USE method dashboards, Kubernetes monitoring (kube-prometheus-stack), node exporter, custom exporters. USE WHEN: setting up monitoring, writing PromQL queries, creating dashboards, configuring alerts, instrumenting applications."
argument-hint: "Describe the observability task (e.g., 'Alertmanager config with PagerDuty and Slack routing')"
---

# Observability Stack

Deploy and configure Prometheus + Grafana + Loki + Tempo for full observability.

## When to Use

- Setting up monitoring infrastructure
- Writing PromQL/LogQL queries
- Creating Grafana dashboards
- Configuring alerting rules and routing
- Instrumenting applications with OpenTelemetry
- Designing SLI/SLO dashboards

## Stack Architecture

```text
┌─────────────┐  ┌──────────┐  ┌──────────┐
│   Metrics   │  │   Logs   │  │  Traces  │
│ (Prometheus)│  │  (Loki)  │  │  (Tempo) │
└──────┬──────┘  └─────┬────┘  └─────┬────┘
       │               │             │
       └───────┬───────┴─────────────┘
               │
        ┌──────▼──────┐     ┌──────────────┐
        │   Grafana   │────▶│ Alertmanager │
        │ (visualize) │     │  (routing)   │
        └─────────────┘     └──────────────┘
```

## Procedure

### 1. Deploy the Stack

**Kubernetes (kube-prometheus-stack):**
```bash
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts

helm install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f values-monitoring.yaml
```

**Docker Compose (dev/small):**
```yaml
services:
  prometheus:
    image: prom/prometheus:v2.52.0
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    ports: ["9090:9090"]

  grafana:
    image: grafana/grafana:11.0.0
    volumes:
      - grafana-data:/var/lib/grafana
    ports: ["3000:3000"]
    environment:
      GF_SECURITY_ADMIN_PASSWORD: "${GRAFANA_PASSWORD}"

  loki:
    image: grafana/loki:3.0.0
    volumes:
      - ./loki-config.yml:/etc/loki/config.yml
      - loki-data:/loki
    ports: ["3100:3100"]

  tempo:
    image: grafana/tempo:2.5.0
    volumes:
      - ./tempo-config.yml:/etc/tempo/config.yml
    ports: ["3200:3200", "4317:4317"]  # API + OTLP gRPC
```

### 2. Configure Prometheus

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - /etc/prometheus/rules/*.yml

alerting:
  alertmanagers:
    - static_configs:
        - targets: ["alertmanager:9093"]

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: node-exporter
    static_configs:
      - targets: ["node-exporter:9100"]

  - job_name: app
    metrics_path: /metrics
    static_configs:
      - targets: ["app:8080"]
```

### 3. Write PromQL Queries

**Essential patterns:**

```promql
# Request rate (RED - Rate)
rate(http_requests_total{job="app"}[5m])

# Error rate (RED - Errors)
rate(http_requests_total{job="app", status=~"5.."}[5m])
  / rate(http_requests_total{job="app"}[5m])

# Latency percentiles (RED - Duration)
histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
histogram_quantile(0.50, rate(http_request_duration_seconds_bucket[5m]))

# CPU usage (USE - Utilization)
1 - avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m]))

# Memory usage (USE - Utilization)
1 - (node_memory_AvailableBytes / node_memory_MemTotalBytes)

# Disk usage
1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})

# Container restarts
increase(kube_pod_container_status_restarts_total[1h])
```

### 4. Configure Alertmanager

```yaml
# alertmanager.yml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'namespace']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  receiver: default
  routes:
    - match:
        severity: critical
      receiver: pagerduty
      repeat_interval: 1h
    - match:
        severity: warning
      receiver: slack

receivers:
  - name: default
    slack_configs:
      - channel: '#alerts'
        send_resolved: true

  - name: pagerduty
    pagerduty_configs:
      - service_key: '<key>'
        severity: '{{ .CommonLabels.severity }}'

  - name: slack
    slack_configs:
      - channel: '#alerts-warning'
        send_resolved: true
        title: '{{ .CommonLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'

inhibit_rules:
  - source_match:
      severity: critical
    target_match:
      severity: warning
    equal: ['alertname', 'namespace']
```

### 5. Create Dashboards

**Dashboard hierarchy:**
| Level | Audience | Content |
| ------- | ---------- | --------- |
| Executive | Management | SLO status, error budget, DORA metrics |
| Service | Dev team | RED metrics, dependencies, deployments |
| Infrastructure | Ops | CPU, memory, disk, network per host |
| Debug | On-call | Request traces, log streams, pod details |

### 6. Instrument Applications (OpenTelemetry)

```python
# Python (FastAPI example)
from opentelemetry import trace, metrics
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

# Setup tracing
provider = TracerProvider()
provider.add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter(endpoint="tempo:4317", insecure=True))
)
trace.set_tracer_provider(provider)

# Auto-instrument FastAPI
FastAPIInstrumentor.instrument_app(app)
```

## Burn-Rate Alerting

```yaml
# SLO: 99.9% availability over 30 days
# Error budget: 0.1% = 43.2 minutes/month

# Multi-window, multi-burn-rate alerts
groups:
  - name: slo-alerts
    rules:
      - alert: HighErrorBudgetBurn
        expr: |
          (
            http_requests:burnrate5m{job="app"} > 14.4
            and
            http_requests:burnrate1h{job="app"} > 14.4
          )
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High error budget burn rate (>14.4x in 5m and 1h)"

      - alert: ModerateErrorBudgetBurn
        expr: |
          (
            http_requests:burnrate30m{job="app"} > 6
            and
            http_requests:burnrate6h{job="app"} > 6
          )
        for: 15m
        labels:
          severity: warning
```

## Agent Integration

- **`executant-observability-ops`** agent: Stack architecture and PromQL/LogQL guidance
- **`executant-sre-ops`** agent: SLI/SLO definition and error budget policies
- **`kubernetes-orchestration`** skill: kube-prometheus-stack Helm deployment
- **`executant-ci-cd-ops`**: Deploy monitoring changes via GitOps
