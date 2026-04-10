# Repository Baseline Policy — M0 Gate Checklist

All items below must be present and valid before any milestone gate (M0 → M1) is approved.

## 1. Repository Structure

- [ ] `CONTRIBUTING.md` — contribution guide with branch naming, commit format, PR process
- [ ] `Makefile` — targets: `validate`, `precommit`, `ci`
- [ ] `.pre-commit-config.yaml` — hooks: trailing-whitespace, check-yaml, detect-private-key, terraform_fmt, terraform_validate, tflint, ansible-lint, trivy-config, validate-baseline

## 2. Secrets & Encryption

- [ ] `.sops.yaml` — SOPS creation rules with age recipients
- [ ] `secrets/.gitignore` — blocks plaintext, allows `*.enc.*` and `*.age`
- [ ] `secrets/.age-recipients.example.txt` — public key reference
- [ ] `secrets/README.md` — SOPS+age workflow documentation

## 3. Documentation

- [ ] `docs/adr/template.md` — ADR template
- [ ] `docs/adr/ADR-001-tooling-selection.md` — tooling decision record
- [ ] `docs/conventions/naming.md` — branch, tag, and naming standards
- [ ] `docs/runbooks/` — at least one runbook per milestone

## 4. Policies

- [ ] `policies/repository-baseline.md` — this checklist
- [ ] `policies/secrets-baseline.md` — secret handling rules

## 5. CI/CD

- [ ] `.github/workflows/pr-validation.yml` — PR gate workflow
- [ ] `.github/workflows/m1-network-validation.yml` — M1 network CI (from M1 onward)

## 6. IaC Stack Directories

Each directory must exist with at minimum a README:

- [ ] `terraform/README.md` + `terraform/modules/`
- [ ] `ansible/README.md` + `ansible/playbooks/`
- [ ] `packer/README.md` + `packer/templates/`
- [ ] `helm/README.md` + `helm/charts/`

## 7. Validation

- [ ] `scripts/validate_baseline.py` — automated baseline checker (runs in CI and pre-commit)
- [ ] `make validate` passes with zero errors

## 8. Observability Baseline

- [ ] `observability/slo/` — at least one SLO definition per active layer
- [ ] `observability/alerts/` — at least one alert rule per active layer

## Enforcement

- The `validate-baseline` pre-commit hook runs `scripts/validate_baseline.py` on every commit
- The PR validation workflow gates merge on baseline compliance
- Non-compliant PRs are blocked from merging to `main`
