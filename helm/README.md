# Helm — Kubernetes Package Management

## Overview

Helm charts for deploying platform services onto Kubernetes clusters. Charts follow the standard Helm 3 structure and are linted/tested in CI before merge.

## Directory Structure

```
helm/
├── charts/             # Individual Helm charts
│   └── <chart-name>/
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── templates/
│       └── tests/
└── README.md
```

## Deployment Instructions

```bash
# Lint a chart
helm lint helm/charts/<chart-name>

# Template render (dry-run)
helm template <release-name> helm/charts/<chart-name> \
  -f helm/charts/<chart-name>/values.yaml

# Install to cluster
helm install <release-name> helm/charts/<chart-name> \
  -n <namespace> --create-namespace \
  -f helm/charts/<chart-name>/values.yaml

# Upgrade existing release
helm upgrade <release-name> helm/charts/<chart-name> \
  -n <namespace> -f helm/charts/<chart-name>/values.yaml
```

## Chart Development

```bash
# Create new chart scaffold
helm create helm/charts/<chart-name>

# Run chart tests
helm test <release-name> -n <namespace>
```

## Conventions

- Charts use Helm 3 (no Tiller)
- All charts include `tests/` directory with connection tests
- Values documented inline in `values.yaml`
- Chart versions follow SemVer
- See [naming conventions](../docs/conventions/naming.md)
