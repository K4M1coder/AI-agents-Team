---
name: performance-engineering
description: "**WORKFLOW SKILL** — Measure, profile, analyze, and improve system performance. USE FOR: load testing (k6, Locust, Gatling), capacity modeling, flame graph interpretation, performance regression detection, SLO-driven resource budgeting, benchmark design, CPU/memory profiling, latency analysis (P50/P95/P99), throughput optimization, bottleneck identification, garbage collection tuning, connection pool sizing, query performance, cache efficiency. USE WHEN: a service is slow or degrading under load, an SLO is being breached, a new feature may have a performance impact, or capacity planning is needed before a launch."
argument-hint: "Describe the performance target and stack (e.g., 'Python FastAPI service p99 latency > 2s under 1000 RPS')"
---

# Performance Engineering

Measure, profile, and improve the performance of services, models, and infrastructure.

## When to Use

- Load testing a service before a launch or traffic spike
- Diagnosing high latency, throughput drops, or resource saturation
- Detecting performance regressions between releases
- Capacity planning for a new workload or infrastructure tier
- Profiling CPU, memory, I/O, or network to find bottlenecks
- Translating SLO targets into concrete resource and scaling requirements

## Methodology

### Phase 1 — Define Performance Goals

1. Identify the SLOs: P50, P95, P99 latency targets and minimum throughput (RPS/concurrency)
2. Classify the workload: latency-sensitive, throughput-bound, or resource-constrained
3. Establish a baseline: measure current performance before any changes
4. Set regression thresholds: how much degradation triggers an alert or build failure

**Workload classification:**

| Workload Type | Primary Metric | Secondary Metric |
| ------------- | -------------- | ---------------- |
| Interactive API | P95/P99 latency | Error rate |
| Batch pipeline | Throughput (items/s) | CPU/memory cost per item |
| ML inference | P95 latency + GPU utilization | Token throughput |
| Background worker | Job queue depth | CPU/memory saturation |

### Phase 2 — Load Test Design

```yaml
# k6 baseline pattern (adjust stages for full ramp strategy)
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 50 },     // ramp-up
    { duration: '5m', target: 50 },     // steady state
    { duration: '2m', target: 200 },    // spike test
    { duration: '5m', target: 200 },    # sustained load
    { duration: '2m', target: 0 },      // ramp-down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  const res = http.get('http://localhost:8080/api/health');
  check(res, { 'status 200': (r) => r.status === 200 });
  sleep(1);
}
```

**Tool selection:**

| Tool | Best For |
| ---- | -------- |
| k6 | Script-based HTTP load testing, CI integration, thresholds |
| Locust | Python-native load testing, complex workflows |
| Gatling | Java/Scala, high-fidelity simulations, enterprise reporting |
| wrk / hey | Simple HTTP benchmarking, quick baselines |
| Vegeta | Constant-rate HTTP load, Go ecosystem |

### Phase 3 — Profile to Find the Bottleneck

#### CPU Profiling

```bash
# Python — py-spy flame graph
py-spy record -o flamegraph.svg --pid <PID>

# Node.js — clinic.js
clinic flame -- node server.js

# Java — async-profiler
async-profiler -d 30 -f flamegraph.html <PID>

# Rust — perf + flamegraph
sudo perf record -g -p <PID> -- sleep 30
sudo perf script | flamegraph.pl > flamegraph.svg
```

#### Memory Profiling

```bash
# Python — tracemalloc (in code)
import tracemalloc
tracemalloc.start()
# ... workload ...
snapshot = tracemalloc.take_snapshot()
top_stats = snapshot.statistics('lineno')

# Java — Eclipse MAT (heap dump analysis)
jmap -dump:live,format=b,file=heap.hprof <PID>

# Node.js — v8 heapsnapshot via clinic.js or Chrome DevTools
```

#### Flame Graph Reading

- Wide base → function dominates CPU time → primary optimization target
- Tall narrow spike → deep call chains → check for recursion or unnecessary layers
- Flat top → leaf functions are executing, not blocking → CPU-bound
- Flat wide middle with thin top → blocking/waiting → I/O or lock contention

### Phase 4 — Capacity Modeling

1. Measure single-instance max throughput and resource consumption
2. Model horizontal scaling: throughput × (# instances / overhead factor)
3. Identify the bottleneck resource: CPU, memory, I/O, network, or external dependency
4. Calculate headroom required for SLO compliance at target traffic × safety multiplier

**SLO-driven resource budgeting:**

| SLO Target | Recommended Headroom | Scaling Trigger |
| ---------- | -------------------- | --------------- |
| P99 < 200ms | 40% CPU headroom | Scale at 60% CPU |
| P99 < 500ms | 30% CPU headroom | Scale at 70% CPU |
| P99 < 2s | 20% CPU headroom | Scale at 80% CPU |
| Availability > 99.9% | N+1 redundancy minimum | HPA min replicas ≥ 2 |

### Phase 5 — Regression Testing in CI

```yaml
# GitHub Actions — performance gate
- name: Load test
  run: k6 run --out json=results.json load-test.js

- name: Check thresholds
  run: |
    node ci/check-performance.js results.json \
      --p95-threshold 500 \
      --p99-threshold 1000 \
      --error-rate 0.01
```

- Store baseline metrics in CI artifacts or a time-series store
- Fail the build if a PR increases P99 by more than 20% relative to baseline
- Annotate PRs with performance summary reports

### Phase 6 — Common Optimizations

**Database:**
- Add indexes for WHERE/JOIN/ORDER BY columns surfaced by EXPLAIN/EXPLAIN ANALYZE
- Use connection pooling (PgBouncer, HikariCP)
- Batch small queries; avoid N+1 patterns
- Use read replicas for read-heavy workloads

**Application:**
- Cache computation-heavy results (Redis, in-memory LRU)
- Reduce serialization overhead (switch JSON libs, use proper content types)
- Use async/non-blocking I/O wherever possible
- Profile GC pressure (Java, .NET) — tune heap sizes and GC strategies

**Network:**
- Enable HTTP keep-alive and connection reuse
- Enable compression (gzip/brotli) for large payloads
- Use CDN for static assets and cacheable API responses

**ML inference:**
- Batch requests to maximize GPU utilization
- Use quantization (int8/AWQ/GPTQ) to reduce latency
- Enable KV cache for autoregressive models
- Consider speculative decoding for high-throughput scenarios

## Anti-Patterns

| Anti-Pattern | Why It Fails | Do This Instead |
| ------------ | ------------ | --------------- |
| Profiling with production traffic | Adds latency to real users | Profile with synthetic load in staging |
| Optimizing before measuring | Wastes effort on non-bottlenecks | Measure first; profile second; optimize last |
| Single-run benchmarks | High variance, noise-dominated | Run 5+ iterations; discard outliers; use median |
| Load testing only at peak (no ramp) | Misses warm-up and connection pool behavior | Always include ramp-up/ramp-down phases |
| Ignoring P99 — only measuring P50 | Tail latency causes user-facing failures | Always report P50, P95, P99 |
| Setting capacity at 100% CPU | No headroom for bursts | Scale at 60-80% utilization |
| No regression test in CI | Regressions reach production silently | Automate threshold gates in every pipeline |

## Agent Integration

| Agent | Relationship | Usage |
| ----- | ------------ | ----- |
| `executant-sre-ops` | **Primary consumer** | SLO-driven capacity modeling, load test design, reliability engineering |
| `executant-debug-engineer` | **Primary consumer** | Bottleneck identification, flame graph analysis, profiling workflows |
| `agent-lead-site-reliability` | **Contextual** | When reliability programs require performance SLO alignment or capacity planning |
| `executant-test-engineer` | **Contextual** | When performance regression tests need integration into the test strategy |
| `executant-inference-engineer` | **Contextual** | When ML serving latency optimization is the performance target |
