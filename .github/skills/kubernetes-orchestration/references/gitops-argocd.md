# GitOps with ArgoCD Reference

## Architecture

```schema
┌──────────────┐     ┌───────────┐     ┌────────────────┐
│   Git Repo   │────▶│  ArgoCD   │────▶│   Kubernetes   │
│ (manifests)  │     │ (control) │     │   (clusters)   │
└──────────────┘     └───────────┘     └────────────────┘
     ▲                                        │
     │              Sync Loop                 │
     └────────────────────────────────────────┘
```

**GitOps principles:**

1. **Declarative**: All infrastructure and apps defined in Git
2. **Versioned**: Git history = audit trail
3. **Automated**: Changes auto-applied (or require approval)
4. **Self-healing**: Drift automatically corrected

## Repository Structure

### App-of-Apps Pattern (Recommended)

```hierachical schema
gitops/
├── apps/                          # ArgoCD Application definitions
│   ├── myapp.yaml
│   ├── monitoring.yaml
│   └── ingress-nginx.yaml
├── base/                          # Base manifests (Kustomize)
│   ├── myapp/
│   │   ├── kustomization.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── ingress.yaml
│   └── monitoring/
│       └── kustomization.yaml
└── overlays/                      # Environment-specific overrides
    ├── dev/
    │   ├── kustomization.yaml
    │   └── patches/
    ├── staging/
    │   ├── kustomization.yaml
    │   └── patches/
    └── prod/
        ├── kustomization.yaml
        └── patches/
```

## ArgoCD Application Manifest

### Kustomize Source

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp-prod
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/org/gitops.git
    targetRevision: main
    path: overlays/prod
  destination:
    server: https://kubernetes.default.svc
    namespace: myapp
  syncPolicy:
    automated:
      prune: true          # Delete resources removed from Git
      selfHeal: true       # Revert manual changes
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
    retry:
      limit: 3
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 1m
```

### Helm Source

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp-prod
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/org/charts.git
    targetRevision: main
    path: charts/myapp
    helm:
      valueFiles:
        - values-prod.yaml
      parameters:
        - name: image.tag
          value: "1.2.3"
  destination:
    server: https://kubernetes.default.svc
    namespace: myapp
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### ApplicationSet (Multi-Environment)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: myapp
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - env: dev
            cluster: https://kubernetes.default.svc
            autoSync: "true"
          - env: staging
            cluster: https://kubernetes.default.svc
            autoSync: "true"
          - env: prod
            cluster: https://prod-cluster.example.com
            autoSync: "false"   # Manual sync for prod
  template:
    metadata:
      name: "myapp-{{env}}"
    spec:
      project: default
      source:
        repoURL: https://github.com/org/gitops.git
        targetRevision: main
        path: "overlays/{{env}}"
      destination:
        server: "{{cluster}}"
        namespace: "myapp-{{env}}"
      syncPolicy:
        automated:
          prune: "{{autoSync}}"
          selfHeal: "{{autoSync}}"
```

## Sync Strategies

| Strategy | `automated` | `prune` | `selfHeal` | Use Case |
| ---------- | ------------- | --------- | ------------ | ---------- |
| Manual | `false` | — | — | Production (human approval) |
| Auto no-prune | `true` | `false` | `true` | Staging (add only, no delete) |
| Full auto | `true` | `true` | `true` | Dev/staging (full reconciliation) |

## Sync Waves & Hooks

```yaml
# Namespace first (wave -1)
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "-1"

# ConfigMaps/Secrets (wave 0 - default)

# Deployments (wave 1)
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"

# Post-sync hook (DB migration)
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migrate
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
```

## ArgoCD CLI

```bash
# Login
argocd login argocd.example.com --grpc-web

# Sync application
argocd app sync myapp-prod

# Get app status
argocd app get myapp-prod

# Diff (preview changes)
argocd app diff myapp-prod

# History
argocd app history myapp-prod

# Rollback to previous revision
argocd app rollback myapp-prod 2
```

## Image Updater (Automated Tag Promotion)

```yaml
# Annotation on Application
metadata:
  annotations:
    argocd-image-updater.argoproj.io/image-list: myapp=registry.example.com/myapp
    argocd-image-updater.argoproj.io/myapp.update-strategy: semver
    argocd-image-updater.argoproj.io/myapp.allow-tags: "regexp:^v\\d+\\.\\d+\\.\\d+$"
    argocd-image-updater.argoproj.io/write-back-method: git
```text
