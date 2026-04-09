# CI/CD Routing Reference

Cross-cutting routing reference for CI/CD pipeline work. Maps CI platform selection, integration decisions, and pipeline-stage ownership to the right skill and agent.

## How to Use This Reference

- Use this file when the task involves CI/CD but the right platform, integration, or ownership is not obvious.
- Use the selection matrix to choose the CI system.
- Use the integration map to find which other skill to load alongside `ci-cd-pipeline`.

## Boundaries

- Platform procedures (GitHub Actions YAML, Jenkins syntax, Dagger API) live in `ci-cd-pipeline` skill.
- Kubernetes deployment target details live in `kubernetes-orchestration` skill.
- Image hardening, rootless, and capability-stripping live in `docker-containerization` skill.
- Supply-chain gates (Cosign, SLSA, SBOM) live in `supply-chain-security` skill.
- Observability of pipelines (DORA metrics, pipeline dashboards) lives in `observability-stack` skill.

## CI Platform Selection Matrix

| Context | Recommended Platform | Why |
| ------- | -------------------- | --- |
| GitHub-hosted repos, open-source or SaaS teams | **GitHub Actions** | Native GitHub integration, marketplace ecosystem, OIDC to cloud, free for public repos |
| GitLab SaaS or self-hosted GitLab | **GitLab CI/CD** | Native to GitLab SCM, strong Auto DevOps, group-level pipeline inheritance |
| Existing Jenkins install, Java-heavy orgs, complex build graphs | **Jenkins** | Maximum flexibility, plugin ecosystem, declarative or scripted, on-prem control |
| Code-defined portable pipelines, no vendor lock-in | **Dagger** | Pipelines as code (Go/Python/TypeScript SDK), runs locally + in any CI |
| Monorepo with fine-grained task caching (Nx/Turborepo) | **GitHub Actions + Turbo/Nx** | Change-set awareness avoids rebuilding unaffected packages |
| Air-gapped / on-prem with GitOps requirement | **GitLab CI + ArgoCD** | Self-hosted, no outbound SaaS dependency, GitOps-native |

## Pipeline Stage → Skill Integration Map

| Stage | Skills involved | Notes |
| ----- | --------------- | ----- |
| **Lint** | `ci-cd-pipeline` | Inline: ruff, eslint, ansible-lint, terraform fmt |
| **Test** | `ci-cd-pipeline` + `testing-strategy` | Test strategy shapes what runs; CI runs it |
| **Build** | `ci-cd-pipeline` + `docker-containerization` | Multi-stage Dockerfile + build cache |
| **Scan** | `ci-cd-pipeline` + `vulnerability-management` + `supply-chain-security` | Trivy/Grype in CI + CVE triage + SBOM |
| **Sign** | `supply-chain-security` | Cosign keyless signing with OIDC |
| **Deploy to K8s** | `ci-cd-pipeline` + `kubernetes-orchestration` | Helm upgrade, ArgoCD sync, or kubectl |
| **Deploy to cloud** | `ci-cd-pipeline` + `terraform-provisioning` or `cloud-operations` | Terraform apply from CI |
| **Deploy to VMs** | `ci-cd-pipeline` + `ansible-automation` | Ansible playbook triggered from CI |
| **Observability gate** | `ci-cd-pipeline` + `observability-stack` | DORA metrics, deployment markers in Grafana |
| **IaC security gate** | `ci-cd-pipeline` + `supply-chain-security` | Checkov/tfsec as PR blocking step |

## Deployment Pattern Decision Tree

```text
Target is Kubernetes?
  YES →
    GitOps (ArgoCD/Flux)?
      YES → ArgoCD sync in ci-cd-pipeline + kubernetes-orchestration
      NO  → Helm upgrade from CI job
  NO  →
    Target is cloud VMs or functions?
      YES →
        IaC-managed?
          YES → terraform-provisioning (plan in CI, apply on merge)
          NO  → ansible-automation (playbook triggered from CI)
      NO  → Custom deploy script inline in CI job
```

## Security Posture in CI

Every pipeline that builds and ships artifacts should include these gates (see `supply-chain-security` for procedures):

| Gate | Tooling | Blocks merge? |
| ---- | ------- | ------------- |
| Dependency scan | Trivy/Grype on image | Yes — on CRITICAL |
| SAST | Semgrep, CodeQL | Yes — on blocker findings |
| Secret scan | Gitleaks, TruffleHog | Yes — always |
| IaC scan | Checkov, tfsec | Yes — on HIGH/CRITICAL |
| Image signing | Cosign keyless | Yes — on deploy |
| SBOM generation | Syft | No — store as artifact |

## Agent Ownership

| Concern | Primary Agent | Secondary Agent |
| ------- | ------------- | --------------- |
| Pipeline design and authoring | `executant-ci-cd-ops` | — |
| GitOps deployment (ArgoCD, Flux) | `executant-ci-cd-ops` | `executant-cloud-ops` |
| Security gates in pipeline | `executant-security-ops` | `executant-ci-cd-ops` |
| Observability gates (DORA) | `executant-observability-ops` | `executant-sre-ops` |
| Release governance and SLOs | `executant-sre-ops` | `agent-lead-site-reliability` |
| K8s deployment target | `executant-network-ops` | `executant-platform-ops` |
