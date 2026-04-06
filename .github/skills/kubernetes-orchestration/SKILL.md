---
name: kubernetes-orchestration
description: "**WORKFLOW SKILL** — Deploy, manage, and troubleshoot Kubernetes workloads. USE FOR: manifest authoring (Deployments, Services, Ingress, ConfigMaps, Secrets), Helm chart development, Kustomize overlays, RBAC policies, NetworkPolicies, resource quotas, HPA/VPA autoscaling, ArgoCD GitOps, debugging pods (logs, exec, events), storage (PVC/PV/StorageClass), service mesh basics, multi-cluster patterns. USE WHEN: deploying to Kubernetes, writing Helm charts, setting up GitOps, troubleshooting workloads."
argument-hint: "Describe the K8s task (e.g., 'Helm chart for Python API with HPA and Ingress')"
---

# Kubernetes Orchestration

Deploy, manage, and troubleshoot Kubernetes workloads following production best practices.

## When to Use

- Writing or reviewing Kubernetes manifests
- Developing Helm charts or Kustomize overlays
- Setting up GitOps with ArgoCD
- Configuring RBAC, NetworkPolicies, resource quotas
- Troubleshooting pod failures, networking, storage

## Procedure

### 1. Define the Workload

Determine:
- **Workload type**: Deployment (stateless), StatefulSet (stateful), DaemonSet (per-node), Job/CronJob (batch)
- **Exposure**: ClusterIP (internal), NodePort (dev), LoadBalancer (cloud), Ingress (HTTP routing)
- **Configuration**: ConfigMap (non-sensitive), Secret (sensitive), External (Vault CSI)
- **Scaling**: Fixed replicas, HPA (CPU/memory/custom metrics), VPA, KEDA (event-driven)

### 2. Write Manifests

**Core manifest rules:**
- Always set `resources.requests` and `resources.limits`
- Always define `readinessProbe` and `livenessProbe` (separate endpoints)
- Use labels consistently: `app.kubernetes.io/name`, `app.kubernetes.io/version`, `app.kubernetes.io/component`
- Set `securityContext`: non-root, read-only rootfs, drop all capabilities
- Use `PodDisruptionBudget` for HA workloads
- Namespace isolation: one namespace per application/team

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  labels:
    app.kubernetes.io/name: myapp
    app.kubernetes.io/version: "1.0.0"
spec:
  replicas: 3
  selector:
    matchLabels:
      app.kubernetes.io/name: myapp
  template:
    metadata:
      labels:
        app.kubernetes.io/name: myapp
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: myapp
          image: registry.example.com/myapp:1.0.0
          ports:
            - containerPort: 8080
              protocol: TCP
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 256Mi
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 15
            periodSeconds: 20
          volumeMounts:
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: tmp
          emptyDir: {}
```

### 3. Choose Packaging Strategy

| Strategy | When | Complexity |
| ---------- | ------ | ------------ |
| Raw YAML | Simple, few resources | Low |
| Kustomize | Environment overlays, no templating needed | Medium |
| Helm | Reusable, parameterized, community charts | Medium-High |
| Helm + Kustomize | Helm for packaging, Kustomize for env tweaks | High |

See [Helm patterns reference](./references/helm-patterns.md) for chart development.
See [GitOps ArgoCD reference](./references/gitops-argocd.md) for continuous deployment.

### 4. Configure RBAC

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: myapp
  name: myapp-reader
rules:
  - apiGroups: [""]
    resources: ["pods", "services", "configmaps"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: myapp
  name: myapp-reader-binding
subjects:
  - kind: ServiceAccount
    name: myapp-sa
    namespace: myapp
roleRef:
  kind: Role
  name: myapp-reader
  apiGroup: rbac.authorization.k8s.io
```

### 5. Network Policies (Default Deny + Allow)

```yaml
# Default deny all ingress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: myapp
spec:
  podSelector: {}
  policyTypes: ["Ingress"]
---
# Allow traffic from specific source
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-api
  namespace: myapp
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: api
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: frontend
      ports:
        - port: 8080
          protocol: TCP
```

### 6. Troubleshooting Toolkit

```bash
# Pod not starting
kubectl describe pod <pod>           # Events, conditions
kubectl logs <pod> --previous        # Previous container logs
kubectl get events --sort-by='.lastTimestamp'

# Shell into pod
kubectl exec -it <pod> -- /bin/sh

# Network debugging
kubectl run debug --image=nicolaka/netshoot --rm -it -- /bin/bash

# Resource usage
kubectl top pods
kubectl top nodes

# Check RBAC
kubectl auth can-i <verb> <resource> --as=system:serviceaccount:<ns>:<sa>
```

## Agent Integration

- **`executant-infra-architect`**: Review architecture and workload design
- **`executant-network-ops`**: NetworkPolicy design, service mesh, ingress config
- **`executant-security-ops`**: RBAC audit, Pod Security Standards review
- **`executant-observability-ops`**: Prometheus ServiceMonitor, Grafana dashboards
- **`executant-ci-cd-ops`**: ArgoCD Application setup, Helm chart CI
