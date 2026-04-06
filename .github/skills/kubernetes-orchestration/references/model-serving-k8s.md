# Model Serving on Kubernetes

Patterns for deploying ML model inference workloads on Kubernetes with GPU support.

## Framework Selection

| Framework | Best For | GPU Support | Streaming | Quantization |
| ----------- | ---------- | ------------- | ----------- | ------------- |
| **vLLM** | LLM serving (high throughput) | NVIDIA | SSE | AWQ, GPTQ, FP8 |
| **TGI** | LLM serving (HF ecosystem) | NVIDIA | SSE | GPTQ, AWQ, bitsandbytes |
| **Triton** | Multi-model, multi-framework | NVIDIA | gRPC | TensorRT, ONNX |
| **TorchServe** | PyTorch models (general) | NVIDIA | No | torch.compile, quantize |
| **FastAPI + torch** | Custom serving, streaming audio | NVIDIA | WebSocket | Any |
| **Candle (Rust)** | Low-latency, CPU/GPU | NVIDIA, Metal | Custom | GGUF |

## vLLM on Kubernetes

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-server
  labels:
    app: vllm-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vllm-server
  template:
    metadata:
      labels:
        app: vllm-server
    spec:
      containers:
        - name: vllm
          image: vllm/vllm-openai:v0.6.3
          args:
            - --model=meta-llama/Llama-3.1-8B-Instruct
            - --tensor-parallel-size=1
            - --max-model-len=8192
            - --gpu-memory-utilization=0.90
            - --enforce-eager           # Disable CUDA graphs for stability
            - --port=8000
          ports:
            - containerPort: 8000
              name: http
          resources:
            limits:
              nvidia.com/gpu: 1
            requests:
              cpu: "4"
              memory: "32Gi"
          readinessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 120
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 180
            periodSeconds: 30
          volumeMounts:
            - name: shm
              mountPath: /dev/shm
            - name: model-cache
              mountPath: /root/.cache/huggingface
          env:
            - name: HUGGING_FACE_HUB_TOKEN
              valueFrom:
                secretKeyRef:
                  name: hf-token
                  key: token
      volumes:
        - name: shm
          emptyDir:
            medium: Memory
            sizeLimit: 8Gi
        - name: model-cache
          persistentVolumeClaim:
            claimName: model-cache-pvc
      tolerations:
        - key: nvidia.com/gpu
          operator: Exists
          effect: NoSchedule
---
apiVersion: v1
kind: Service
metadata:
  name: vllm-server
spec:
  selector:
    app: vllm-server
  ports:
    - port: 8000
      targetPort: 8000
      name: http
  type: ClusterIP
```

## Custom Audio Model Serving (Moshi/Mimi pattern)

For streaming audio models that need WebSocket connections:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: audio-model-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: audio-model-server
  template:
    metadata:
      labels:
        app: audio-model-server
    spec:
      containers:
        - name: server
          image: registry.example.com/moshi-server:latest
          ports:
            - containerPort: 8998
              name: ws
          resources:
            limits:
              nvidia.com/gpu: 1
            requests:
              cpu: "4"
              memory: "16Gi"
          readinessProbe:
            tcpSocket:
              port: 8998
            initialDelaySeconds: 60
          volumeMounts:
            - name: shm
              mountPath: /dev/shm
      volumes:
        - name: shm
          emptyDir:
            medium: Memory
            sizeLimit: 4Gi
---
apiVersion: v1
kind: Service
metadata:
  name: audio-model-server
spec:
  selector:
    app: audio-model-server
  ports:
    - port: 8998
      targetPort: 8998
      name: ws
---
# WebSocket-aware ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: audio-model-ingress
  annotations:
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
    nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
    nginx.ingress.kubernetes.io/websocket-services: audio-model-server
spec:
  ingressClassName: nginx
  rules:
    - host: audio.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: audio-model-server
                port:
                  number: 8998
```

## GPU Resource Management

### Resource Requests vs Limits

```yaml
resources:
  requests:
    nvidia.com/gpu: 1       # MUST equal limits (GPUs are not overcommittable)
    cpu: "4"                # Base CPU for data loading
    memory: "32Gi"          # Enough for model loading + overhead
  limits:
    nvidia.com/gpu: 1       # Always set equal to requests
    cpu: "8"                # Burst CPU for tokenization/preprocessing
    memory: "48Gi"          # Headroom for peak usage
```

**Rule**: GPU requests MUST equal GPU limits. Kubernetes does not support GPU overcommit.

### Node Affinity for GPU Types

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: nvidia.com/gpu.product
              operator: In
              values:
                - NVIDIA-A100-SXM4-80GB
                - NVIDIA-H100-80GB-HBM3
```

### Priority Classes for GPU Workloads

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: gpu-inference-critical
value: 1000000
globalDefault: false
description: "Priority for production inference workloads"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: gpu-training-batch
value: 100000
preemptionPolicy: PreemptLowerPriority
description: "Priority for training jobs — can be preempted by inference"
```

## Model Cache Strategy

### PersistentVolumeClaim for Model Downloads

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: model-cache-pvc
spec:
  accessModes:
    - ReadWriteMany          # Allow multiple pods to read
  storageClassName: fast-ssd  # NVMe storage class
  resources:
    requests:
      storage: 200Gi         # Enough for multiple model versions
```

### Init Container for Model Pre-download

```yaml
initContainers:
  - name: download-model
    image: python:3.12-slim
    command:
      - python
      - -c
      - |
        from huggingface_hub import snapshot_download
        snapshot_download("meta-llama/Llama-3.1-8B-Instruct",
                         cache_dir="/models")
    env:
      - name: HUGGING_FACE_HUB_TOKEN
        valueFrom:
          secretKeyRef:
            name: hf-token
            key: token
    volumeMounts:
      - name: model-cache
        mountPath: /models
```

## Scaling Patterns

### Queue-Based Autoscaling (KEDA)

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: inference-scaler
spec:
  scaleTargetRef:
    name: vllm-server
  minReplicaCount: 1
  maxReplicaCount: 4
  triggers:
    - type: prometheus
      metadata:
        serverAddress: http://prometheus.monitoring:9090
        metricName: vllm_pending_requests
        query: sum(vllm_num_requests_waiting)
        threshold: "10"
```

### Blue-Green Model Updates

```yaml
# Deploy new model version alongside existing
# Route traffic via service label selector update
apiVersion: v1
kind: Service
metadata:
  name: inference-api
spec:
  selector:
    app: vllm-server
    model-version: v2          # Switch from v1 to v2 atomically
  ports:
    - port: 8000
```text
