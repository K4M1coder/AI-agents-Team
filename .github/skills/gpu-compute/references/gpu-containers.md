# GPU Containers Reference

Docker and Kubernetes GPU configuration patterns for ML workloads.

## Docker GPU Setup

### Prerequisites

```bash
# Install NVIDIA Container Toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Verify
docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
```

### CUDA Base Images

| Image | Size | Use Case |
| ------- | ------ | ---------- |
| `nvidia/cuda:12.4.1-base-ubuntu22.04` | ~120 MB | Runtime only (no dev tools) |
| `nvidia/cuda:12.4.1-runtime-ubuntu22.04` | ~870 MB | Runtime + cuBLAS, cuDNN |
| `nvidia/cuda:12.4.1-devel-ubuntu22.04` | ~3.5 GB | Full development (nvcc, headers) |
| `pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime` | ~5 GB | PyTorch pre-installed |

**Rule**: Use `-runtime` for serving, `-devel` for build stage only.

### Multi-Stage Dockerfile (ML Inference)

```dockerfile
# Build stage — install packages that need compilation
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-dev python3-pip gcc && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Runtime stage — minimal image
FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /install /usr/local
COPY ./app /app
WORKDIR /app

# Non-root user
RUN useradd -m -s /bin/bash appuser
USER appuser

EXPOSE 8000
CMD ["python3", "serve.py"]
```

### Docker Compose GPU Configuration

```yaml
services:
  inference:
    build: .
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1          # or "all"
              capabilities: [gpu]
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=compute,utility
    shm_size: "8g"              # Required for PyTorch DataLoader workers
    ulimits:
      memlock:
        soft: -1
        hard: -1

  training:
    build: .
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              device_ids: ["0", "1"]   # Specific GPUs
              capabilities: [gpu]
    volumes:
      - ./data:/data:ro
      - ./checkpoints:/checkpoints
    shm_size: "16g"
    ipc: host                   # Alternative to shm_size for NCCL
```

## Kubernetes GPU Scheduling

### NVIDIA Device Plugin

```bash
# Install NVIDIA device plugin (DaemonSet)
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.15.0/deployments/static/nvidia-device-plugin.yml

# Verify GPUs are detected
kubectl get nodes -o json | jq '.items[].status.capacity["nvidia.com/gpu"]'
```

### GPU Pod Configuration

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: inference-server
spec:
  containers:
    - name: model-server
      image: registry.example.com/model-server:latest
      resources:
        limits:
          nvidia.com/gpu: 1     # Request 1 GPU
        requests:
          cpu: "4"
          memory: "16Gi"
      env:
        - name: NVIDIA_VISIBLE_DEVICES
          value: "all"
        - name: CUDA_DEVICE_ORDER
          value: "PCI_BUS_ID"
      volumeMounts:
        - name: shm
          mountPath: /dev/shm
  volumes:
    - name: shm
      emptyDir:
        medium: Memory
        sizeLimit: 8Gi
  tolerations:
    - key: nvidia.com/gpu
      operator: Exists
      effect: NoSchedule
  nodeSelector:
    cloud.google.com/gke-accelerator: nvidia-tesla-a100  # GKE example
```

### Multi-GPU Training Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: training-job
spec:
  parallelism: 1
  template:
    spec:
      containers:
        - name: trainer
          image: registry.example.com/trainer:latest
          resources:
            limits:
              nvidia.com/gpu: 4
            requests:
              cpu: "16"
              memory: "64Gi"
          env:
            - name: NCCL_SOCKET_IFNAME
              value: "eth0"
            - name: NCCL_DEBUG
              value: "WARN"
            - name: MASTER_ADDR
              value: "localhost"
            - name: MASTER_PORT
              value: "29500"
          command:
            - torchrun
            - --nproc_per_node=4
            - --standalone
            - train.py
          volumeMounts:
            - name: shm
              mountPath: /dev/shm
            - name: data
              mountPath: /data
              readOnly: true
      volumes:
        - name: shm
          emptyDir:
            medium: Memory
            sizeLimit: 16Gi
        - name: data
          persistentVolumeClaim:
            claimName: training-data
      restartPolicy: OnFailure
```

### GPU HPA (Horizontal Pod Autoscaler)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: inference-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: inference-server
  minReplicas: 1
  maxReplicas: 8
  metrics:
    - type: Pods
      pods:
        metric:
          name: DCGM_FI_DEV_GPU_UTIL    # From dcgm-exporter
        target:
          type: AverageValue
          averageValue: "80"
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          targetAverageUtilization: 70
```

## GPU Monitoring Stack

```yaml
# dcgm-exporter DaemonSet for Prometheus GPU metrics
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: dcgm-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: dcgm-exporter
  template:
    metadata:
      labels:
        app: dcgm-exporter
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9400"
    spec:
      containers:
        - name: dcgm-exporter
          image: nvcr.io/nvidia/k8s/dcgm-exporter:3.3.6-3.4.2-ubuntu22.04
          ports:
            - containerPort: 9400
          securityContext:
            runAsNonRoot: false
            runAsUser: 0
          volumeMounts:
            - name: device-plugin
              mountPath: /var/lib/kubelet/device-plugins
      volumes:
        - name: device-plugin
          hostPath:
            path: /var/lib/kubelet/device-plugins
      tolerations:
        - key: nvidia.com/gpu
          operator: Exists
          effect: NoSchedule
```

## Key Metrics from dcgm-exporter

| Metric | Description | Alert Threshold |
| -------- | ------------- | ---------------- |
| `DCGM_FI_DEV_GPU_UTIL` | GPU compute utilization % | > 95% sustained |
| `DCGM_FI_DEV_FB_USED` | Framebuffer memory used (MB) | > 90% capacity |
| `DCGM_FI_DEV_GPU_TEMP` | GPU temperature °C | > 83°C |
| `DCGM_FI_DEV_POWER_USAGE` | Power draw (W) | > TDP |
| `DCGM_FI_DEV_MEM_CLOCK` | Memory clock (MHz) | Throttling detection |
| `DCGM_FI_DEV_NVLINK_BANDWIDTH_TOTAL` | NVLink bandwidth | < expected BW |
| `DCGM_FI_DEV_XID_ERRORS` | XID error count | > 0 |
