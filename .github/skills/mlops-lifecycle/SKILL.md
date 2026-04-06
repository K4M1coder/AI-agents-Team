---
name: mlops-lifecycle
description: "**WORKFLOW SKILL** — ML lifecycle management: experiment tracking (W&B, MLflow), model registry (HF Hub, MLflow), ML CI/CD, monitoring, drift detection, feature stores, and open-weight family-aware promotion. USE FOR: setting up experiment tracking, ML pipelines, model deployment automation, production monitoring, and governing how recent open-weight families move from experiment to production. USE WHEN: managing ML experiments, deploying models to production, monitoring model performance, or promoting a family-specific baseline."
argument-hint: "Describe the MLOps task: tracking, deployment, monitoring, or pipeline design"
---

# MLOps Lifecycle

Manage the full ML lifecycle from experiment to production: tracking, registry, CI/CD, monitoring, and governance.

## When to Use

- Setting up experiment tracking for a new project
- Designing ML CI/CD pipelines
- Deploying models with rollback capability
- Monitoring models in production (drift, quality)
- Versioning models alongside data and code
- Choosing how a recent open-weight family should be registered, staged, and promoted

## Core Concepts

| Concept | Description |
| --------- | ------------- |
| **Experiment Tracking** | Log hyperparameters, metrics, artifacts for every run |
| **Model Registry** | Versioned model storage with metadata and lifecycle stages |
| **ML CI/CD** | Automated test → train → evaluate → deploy pipeline |
| **Data Drift** | Distribution shift in input data over time |
| **Model Drift** | Degradation in model predictions over time |
| **Feature Store** | Centralized feature computation, online/offline serving |
| **Model Card** | Documentation: intended use, metrics, limitations, biases |

## Procedure

### Phase 1: Experiment Tracking Setup

1. **Choose** tracking tool:
   - **W&B**: Best UI, sweeps, team collaboration (used in moshi-finetune)
   - **MLflow**: Self-hosted, open-source, model registry included
   - **TensorBoard**: Simple, embedded in PyTorch (used in moshi-finetune)

2. **Instrument** training code:
   ```python
   # Minimum viable logging
   wandb.init(project="my-project", config=config)
   for step, batch in enumerate(dataloader):
       loss = train_step(batch)
       wandb.log({"loss": loss, "step": step})
   wandb.finish()
   ```

3. **Log** consistently: hyperparameters, metrics, model checkpoints, data version

### Phase 2: Model Registry

1. **Version** models with semantic versioning or hash-based IDs
2. **Store** artifacts: model weights, config, tokenizer, data card
3. **Stage** lifecycle: `staging` → `production` → `archived`
4. **Publish** to HuggingFace Hub or MLflow Registry

### Phase 2.5: Open-Weight Family Governance

When the model family is not fixed yet, use `../_shared/references/llm-landscape.md` first.

- Use `../_shared/references/models/` for family-specific licensing, deployment, and packaging constraints.
- Use `../_shared/references/models/edge-small.md` when a model should take a dedicated low-VRAM, offline, or mobile promotion path.

### Phase 3: ML CI/CD Pipeline

```text
──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│ Code     │────▶│ Data     │────▶│ Train    │────▶│ Evaluate │────▶│ Deploy   │
│ Lint/Test│     │ Validate │     │ (GPU)    │     │ (gates)  │     │ (canary) │
└──────────┘     └──────────┘     └──────────┘     └──────────┘     └──────────┘
                                                       │
                                                  ┌────┴────┐
                                                  │ Quality  │
                                                  │ Gate:    │
                                                  │ metric > │
                                                  │ threshold│
                                                  └─────────┘
```

**Quality gates** (fail pipeline if not met):
- Accuracy/loss meets threshold
- No regression vs. baseline model
- Inference latency within SLO
- Model size within deployment limits

### Phase 4: Production Monitoring

| Signal | Tool | Action |
| -------- | ------ | -------- |
| **Data drift** | Evidently, NannyML | Alert → investigate → retrain |
| **Prediction drift** | Custom metrics + dashboards | Alert → A/B test new model |
| **Latency degradation** | Prometheus + Grafana | Scale up or optimize |
| **Error rate spike** | Application monitoring | Rollback → debug |
| **Feature drift** | Feature store monitoring | Update feature pipeline |

### Phase 5: Governance

1. **Model cards**: Document intended use, limitations, metrics, biases
2. **Lineage tracking**: Data → training run → model → deployment
3. **Access control**: Who can promote models to production
4. **Audit trail**: All changes logged with timestamps and users
5. **Compliance**: Data privacy (GDPR), model transparency requirements

## Kyutai Open-Source Reference — MLOps Patterns

> These patterns are from Kyutai open-source projects (`moshi-finetune`, `moshi`). Use as reference for MLOps implementation in similar audio/LM workloads.

- **W&B**: Used in moshi-finetune for experiment tracking
- **TensorBoard**: Secondary logging in moshi-finetune
- **HuggingFace Hub**: Model hosting (published at `huggingface.co/kyutai`)
- **Docker**: Deployment packaging (all projects have Dockerfiles)
- **pyproject.toml**: Standardized Python packaging across all projects

## Tools Reference

| Tool | Category | Notes |
| ------ | ---------- | ------- |
| W&B | Tracking | Sweeps, reports, team features |
| MLflow | Tracking + Registry | Self-hosted, open-source |
| TensorBoard | Visualization | Simple, PyTorch integration |
| HF Hub | Model hosting | Git-based, model cards |
| DVC | Data versioning | S3/GCS backends |
| Evidently | Monitoring | Data/model drift detection |
| Great Expectations | Data validation | Schema, quality checks |
| Airflow / Prefect | Orchestration | DAG-based pipeline scheduling |
