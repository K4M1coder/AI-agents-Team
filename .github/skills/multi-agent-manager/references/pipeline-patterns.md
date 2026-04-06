# Pipeline Patterns Reference

Common multi-agent pipeline configurations for different workflow types.

## Pattern 1: Research-First Development

Best for: Feature implementation where codebase understanding is critical.

```text
──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│ Explore  │────▶│ Planner  │────▶│ Default  │────▶│ Reviewer │
│(thorough)│     │          │     │(implement)│    │          │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
```

**Flow:**

1. Explore agent researches the codebase (patterns, existing code, tests)
2. Planner agent creates implementation plan from research
3. Default agent implements the changes
4. Reviewer agent validates the result

---

## Pattern 2: Parallel Research Fan-Out

Best for: Broad understanding tasks, cross-cutting concerns, audit/compliance.

```text
                ┌─────────────┐
            ┌───▶│ Explore (A) │───┐
            │    └─────────────┘   │
┌────────┐  │    ┌─────────────┐   │    ┌────────────┐
│Decompose├─┼───▶│ Explore (B) │───┼───▶│ Aggregate  │
└────────┘  │    └─────────────┘   │    └────────────┘
            │    ┌─────────────┐   │
            └───▶│ Explore (C) │───┘
                 └─────────────┘
```

**Flow:**

1. Decompose the research question into independent queries
2. Launch parallel Explore agents with different search scopes
3. Aggregate findings into a unified report

---

## Pattern 3: Implement + Dual Review

Best for: Security-sensitive or high-reliability code changes.

```text
                             ┌──────────┐
┌──────────┐    ┌──────────┐  │ Reviewer  │
│ Default  │───▶│ Default  │─▶│ (quality) │──▶ Merge
│(implement)│   │ (tests)  │  ├──────────┤
└──────────┘    └──────────┘  │ Security  │
                              │ Auditor   │
                              └──────────┘
```

**Flow:**

1. Default agent implements the feature
2. Default agent writes tests
3. In parallel: Reviewer checks quality, Security Auditor checks vulnerabilities
4. Merge if both approve

---

## Pattern 4: DevOps Pipeline

Best for: Infrastructure changes that need validation.

```text
──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│ Explore  │────▶│ DevOps   │────▶│ Default  │────▶│ Security │
│(infra)   │     │(implement)│    │(test/CI) │     │ Auditor  │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
```

---

## Pattern 5: Documentation Sprint

Best for: Generating or updating docs across a project.

```text
──────────┐     ┌──────────────┐     ┌──────────┐
│ Explore  │────▶│ Documenter   │────▶│ Reviewer │
│(thorough)│     │(write docs)  │     │(accuracy)│
└──────────┘     └──────────────┘     └──────────┘
```

---

## Composing Custom Pipelines

Define a pipeline as an ordered list of stages:

```text
ipeline: <name>
  Stage 1: <agent> — <task description> — depends: []
  Stage 2: <agent> — <task description> — depends: [1]
  Stage 3: <agent> — <task description> — depends: [1]    ← parallel with Stage 2
  Stage 4: <agent> — <task description> — depends: [2, 3] ← waits for both
```

**Rules:**

- Stages with no overlapping dependencies can run in parallel
- Each stage's prompt must include outputs from its dependencies
- Add explicit output contracts so downstream agents know what to expect
- Keep pipeline depth ≤ 4 stages to avoid context degradation

---

## Pattern 6: Infrastructure Provisioning Pipeline

Best for: End-to-end infrastructure changes (design → implement → harden → document).

```text
─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    Infra     │────▶│ Platform/   │────▶│  Security   │────▶│   Docs Ops  │
│  Architect   │     │ Cloud Ops   │     │    Ops      │     │ (runbook)   │
│  (design)    │     │ (implement) │     │  (harden)   │     │             │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

**Flow:**

1. Infra Architect produces ADR and Terraform/Ansible design
2. Platform Ops (on-prem) or Cloud Ops (cloud) implements the IaC
3. Security Ops validates hardening, scans configs, reviews compliance
4. Docs Ops writes Service Overview Card and runbook

---

## Pattern 7: Full DevSecOps CI/CD Pipeline

Best for: New application deployment with full security gates.

```text
───────────┐   ┌───────────┐   ┌───────────┐   ┌───────────┐
│  CI/CD    │──▶│  Security │──▶│  Secrets  │──▶│  Observ.  │
│   Ops     │   │    Ops    │   │  Manager  │   │   Ops     │
│(pipeline) │   │  (scan)   │   │  (inject) │   │(dashboard)│
└───────────┘   └───────────┘   └───────────┘   └───────────┘
```

**Flow:**

1. CI/CD Ops creates pipeline (lint → test → build → scan → sign → deploy)
2. Security Ops validates security gates and image scanning config
3. Secrets Manager configures SOPS/Vault for secret injection
4. Observability Ops adds monitoring dashboards and alerts

---

## Pattern 8: Incident Response & Learning

Best for: Post-incident review and improvement cycle.

```text
───────────┐   ┌───────────┐   ┌───────────┐
│  SRE Ops  │──▶│  Docs Ops │──▶│  CI/CD    │
│(postmortem│   │ (runbook  │   │   Ops     │
│ + SLO     │   │  update)  │   │(auto-fix) │
│ review)   │   │           │   │           │
└───────────┘   └───────────┘   └───────────┘
```

**Flow:**

1. SRE Ops analyzes the incident, writes blameless postmortem, reviews SLO impact
2. Docs Ops updates runbooks with new diagnosis/mitigation steps
3. CI/CD Ops adds automated checks/rollback to prevent recurrence

---

## Pattern 9: Network & Security Hardening

Best for: Comprehensive network + OS hardening for a new environment.

```text
                ┌─────────────┐
            ┌───▶│ Network Ops │───┐
            │    │(firewall/VPN)│  │
┌────────┐  │    └─────────────┘   │    ┌─────────────┐
│ Infra  │──┤                      ├───▶│  SRE Ops    │
│Architect│  │    ┌─────────────┐  │    │(SLO + chaos)│
└────────┘  └───▶│ Security Ops│───┘    └─────────────┘
                 │(CIS/ANSSI)  │
                 └─────────────┘
```

**Flow:**

1. Infra Architect designs network topology and security architecture
2. In parallel: Network Ops implements firewall/VPN/DNS, Security Ops applies CIS/ANSSI hardening
3. SRE Ops defines SLOs and plans chaos experiments to validate resilience

---

## Pattern 10: AI Model Development Pipeline

Best for: End-to-end model development from research to deployment.

```text
─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│     ML      │────▶│    Data     │────▶│     ML      │────▶│  Inference  │
│  Researcher │     │  Engineer   │     │  Engineer   │     │  Engineer   │
│  (design)   │     │ (data prep) │     │  (train)    │     │ (optimize)  │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

**Flow:**

1. ML Researcher selects architecture, reviews SOTA, produces design spec
2. Data Engineer builds data pipeline, validates quality, versions datasets
3. ML Engineer implements training, runs experiments, tracks with W&B
4. Inference Engineer quantizes, benchmarks, and deploys the model

---

## Pattern 11: AI Safety & Alignment Pipeline

Best for: Model alignment and safety review before production deployment.

```text
─────────────┐     ┌─────────────┐     ┌─────────────┐
│     ML      │────▶│  AI Safety  │────▶│   MLOps     │
│  Engineer   │     │ (alignment  │     │  Engineer   │
│(fine-tune)  │     │  + red team)│     │  (deploy +  │
└─────────────┘     │             │     │  monitor)   │
                    └─────────────┘     └─────────────┘
```

**Flow:**

1. ML Engineer fine-tunes with DPO/RLHF alignment
2. AI Safety runs red teaming, bias audit, evaluates guardrails
3. MLOps Engineer deploys to staging, configures drift monitoring, promotes to prod

---

## Pattern 12: AI Product Launch Pipeline

Best for: Taking a trained model from prototype to market.

```text
                    ┌─────────────┐
                ┌───▶│ AI Architect│───┐
                │    │(API design) │   │
┌────────────┐  │    └─────────────┘   │    ┌─────────────┐
│ AI Team    │──┤                      ├───▶│    AI       │
│   Lead     │  │    ┌─────────────┐   │    │ Enablement  │
│(decompose) │  └───▶│  Inference  │───┘    │(training +  │
└────────────┘       │  Engineer   │        │ pricing)    │
                     │(deploy)     │        └─────────────┘
                     └─────────────┘
```

**Flow:**

1. AI Team Lead decomposes the launch into parallel tracks
2. In parallel: AI Architect designs API + SDK, Inference Engineer deploys + scales
3. AI Enablement writes training materials, defines pricing tiers, prepares docs

---

## Pattern 13: Real-Time Audio AI Pipeline (Reference: Kyutai/Moshi Architecture)

Best for: Building and deploying streaming audio AI (Moshi, Pocket-TTS, Hibiki).

```text
──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│   ML     │──▶│   ML     │──▶│Inference │──▶│  GPU     │──▶│  MLOps   │
│Researcher│   │ Engineer │   │ Engineer │   │  Infra   │   │ Engineer │
│(arch.)   │   │(train)   │   │(stream)  │   │(cluster) │   │(monitor) │
└──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘
```

**Flow:**

1. ML Researcher designs streaming transformer architecture (Depth/Temporal)
2. ML Engineer trains with FSDP on multi-GPU, validates audio quality (MOS, PESQ)
3. Inference Engineer optimizes for real-time (KV cache, INT8, CUDA graphs)
4. GPU Infra sizes the cluster for target concurrent sessions
5. MLOps Engineer deploys with WebSocket API, monitors latency + drift
