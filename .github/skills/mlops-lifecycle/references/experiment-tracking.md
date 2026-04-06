# Experiment Tracking Reference

Patterns and configuration for ML experiment tracking and reproducibility.

## W&B (Weights & Biases)

Primary tracking tool used in Kyutai's open-source moshi-finetune.

### Basic Setup

```python
import wandb

wandb.init(
    project="moshi-finetune",
    name="lora-r64-lr2e4",
    config={
        "model": "moshi-7b",
        "lora_rank": 64,
        "learning_rate": 2e-4,
        "batch_size": 32,
        "precision": "bf16",
    },
    tags=["lora", "7b", "speech"],
)
```

### Logging Patterns

```python
# Scalar metrics
wandb.log({"train/loss": loss, "train/lr": lr, "step": step})

# Evaluation metrics
wandb.log({"eval/loss": eval_loss, "eval/wer": wer, "eval/perplexity": ppl})

# Audio samples
wandb.log({"audio/sample": wandb.Audio(audio_array, sample_rate=24000)})

# Model artifacts
artifact = wandb.Artifact("model-checkpoint", type="model")
artifact.add_dir("checkpoints/step_5000/")
wandb.log_artifact(artifact)

# Hyperparameter sweeps
sweep_config = {
    "method": "bayes",
    "metric": {"name": "eval/loss", "goal": "minimize"},
    "parameters": {
        "learning_rate": {"min": 1e-5, "max": 5e-4, "distribution": "log_uniform_values"},
        "lora_rank": {"values": [16, 32, 64, 128]},
    },
}
```

### W&B Best Practices

- Always log `config` with all hyperparameters
- Use `tags` for filtering (model size, task, method)
- Log `system` metrics (GPU utilization, memory)
- Save checkpoints as artifacts for lineage tracking
- Use `group` for related runs (e.g., sweep trials)

## MLflow

Self-hosted alternative with model registry.

### Setup

```python
import mlflow

mlflow.set_tracking_uri("http://mlflow-server:5000")
mlflow.set_experiment("moshi-finetune")

with mlflow.start_run(run_name="lora-r64"):
    mlflow.log_params({
        "model": "moshi-7b",
        "lora_rank": 64,
        "learning_rate": 2e-4,
    })

    for step in range(total_steps):
        loss = train_step()
        mlflow.log_metric("loss", loss, step=step)

    mlflow.pytorch.log_model(model, "model")
```

### Model Registry

```python
# Register model
mlflow.register_model("runs:/<run_id>/model", "moshi-7b-lora")

# Transition stage
client = mlflow.MlflowClient()
client.transition_model_version_stage("moshi-7b-lora", version=3, stage="Production")
```

## TensorBoard

Simple, embedded logging (used alongside W&B in moshi-finetune).

```python
from torch.utils.tensorboard import SummaryWriter

writer = SummaryWriter("runs/experiment_name")
writer.add_scalar("loss/train", loss, step)
writer.add_scalar("loss/eval", eval_loss, step)
writer.add_audio("samples/generated", audio, step, sample_rate=24000)
writer.add_histogram("gradients/layer_0", grads, step)
writer.close()
```

## Reproducibility Checklist

- [ ] Log all hyperparameters (optimizer, scheduler, data processing)
- [ ] Set and log random seeds (`torch.manual_seed`, `numpy.random.seed`)
- [ ] Pin dependency versions (`requirements.txt` or `pyproject.toml`)
- [ ] Version training data (DVC hash or HF dataset version)
- [ ] Log git commit hash
- [ ] Save full config file as artifact
- [ ] Log hardware info (GPU model, count, driver version)
- [ ] Use deterministic operations where possible (`torch.use_deterministic_algorithms`)

## Experiment Organization

### Naming Convention

```text
model}_{method}_{key_param}_{date}
Example: moshi7b_lora64_lr2e4_20260401
```

### Tagging Strategy

| Tag Category | Examples |
| ------------- | --------- |
| Model | `7b`, `2b`, `1b` |
| Method | `lora`, `full-ft`, `qlora` |
| Task | `tts`, `stt`, `dialogue` |
| Status | `baseline`, `experiment`, `production` |
| Hardware | `a100`, `h100`, `mlx` |

### Run Comparison

Always compare against:

1. **Baseline**: Pre-trained model (zero-shot)
2. **Previous best**: Best run from prior experiments
3. **Ablations**: Same config with one variable changed
