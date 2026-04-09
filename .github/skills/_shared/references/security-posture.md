# Security Posture Reference

Cross-cutting routing reference for all security-adjacent agents and skills. Maps security scenarios to the right skill and explains how the five security skills divide responsibility.

## How to Use This Reference

- Use this file when the task involves security but the right skill is not obvious.
- Pick the row that matches the **scenario type**, then load the referenced skill.
- Multiple skills may apply; the table indicates the **primary skill** for each scenario and secondary skills that may be needed alongside it.

## Boundaries

- This file routes to skills; it does not contain procedure.
- Skill-specific procedures, commands, and checklists live in each SKILL.md.
- Incident response for active security breaches is owned by `incident-management`, not here.
- AI/ML model misuse, adversarial prompts, and content safety are owned by `ai-alignment` and `executant-ai-safety`.

## Security Skill Map

| Scenario | Primary Skill | Secondary Skill(s) | When to combine |
| -------- | ------------- | ------------------- | ---------------- |
| Harden a new server or VM template to CIS/ANSSI baseline | `security-hardening` | `ansible-automation` | Use Ansible to automate the hardening playbook |
| Triage a CVE, assess severity, patch or accept risk | `vulnerability-management` | `supply-chain-security` | If the CVE is in a container image or dependency |
| Sign container images, generate SBOM, pin deps | `supply-chain-security` | `ci-cd-pipeline` | Signing usually lives inside CI |
| Store secrets, rotate credentials, set up Vault/OIDC | `secrets-management` | `kubernetes-orchestration` | When secrets are consumed via K8s CSI or ESO |
| Analyze attack surface, model threats at design time | `threat-modeling` | `security-hardening` | Hardening implements the mitigations from the threat model |
| Patch cycle across all services (scheduled process) | `vulnerability-management` | `security-hardening` | OS-level patches + CIS re-scan after patching |
| Security review of a CI/CD pipeline | `supply-chain-security` | `ci-cd-pipeline` | Pipeline hardening (OIDC, least-privilege) is in ci-cd-pipeline |
| Security review of infrastructure architecture (IaC) | `threat-modeling` | `terraform-provisioning` | Threat model first, then Checkov/tfsec in IaC |
| Compliance audit (SOC2, ISO 27001, CIS L2) | `security-hardening` | `vulnerability-management` | Hardening + patching posture evidence required together |
| AI/ML model or serving security | `threat-modeling` | `ai-alignment` | Design-time attack surface + model-level safety controls |

## Decision Tree

```text
Is this a design-time question (before deployment)?
  YES → threat-modeling
  NO  →
    Is there a known CVE or patch to apply?
      YES → vulnerability-management
      NO  →
        Is this about secrets, PKI, or credential lifecycle?
          YES → secrets-management
          NO  →
            Is this about artifact integrity, SBOMs, or dependency trust?
              YES → supply-chain-security
              NO  → security-hardening  (baseline config, compliance, OS posture)
```

## Skill Ownership

| Skill | Primary Agent | Lead | Key tools |
| ----- | ------------- | ---- | --------- |
| `security-hardening` | `executant-security-ops` | `agent-lead-security` | OpenSCAP, Ansible, Lynis, CIS-CAT |
| `vulnerability-management` | `executant-security-ops` | `agent-lead-security` | Trivy, Grype, Wazuh, pip-audit |
| `supply-chain-security` | `executant-security-ops` | `agent-lead-security` | Cosign, Syft, Grype, Renovate |
| `secrets-management` | `executant-secrets-manager` | `agent-lead-security` | Vault, SOPS, ESO, Infisical |
| `threat-modeling` | `executant-security-ops` | `agent-lead-security` | STRIDE, DREAD, attack trees, DFDs |

## Cross-Cutting Notes

- **Hardening before CVEs**: Run `security-hardening` on every new server before deploying software. CVE exposure is lower when the baseline is tight.
- **Threat model drives hardening**: Use `threat-modeling` to identify what needs hardening; use `security-hardening` to implement it.
- **Supply chain is a CI gate**: `supply-chain-security` works best when integrated into `ci-cd-pipeline` as a blocking stage.
- **Vault + ESO for K8s**: When secrets feed Kubernetes, `secrets-management` pairs with `kubernetes-orchestration`.
