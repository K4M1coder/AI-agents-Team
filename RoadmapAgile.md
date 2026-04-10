# 🗺️ Roadmap Agile — Plateforme IaC Entreprise

## Vue d'ensemble / Timeline

```text
SPRINTS →      S1    S2    S3    S4    S5    S6    S7    S8    S9    S10   S11   S12   S13   S14   S15   S16
               ├─────┤─────┤─────┤─────┤─────┤─────┤─────┤─────┤─────┤─────┤─────┤─────┤─────┤─────┤─────┤
GOUVERNANCE    [M0 ──────]
RÉSEAU                    [M1 ──────]
VIRTUALISATION                      [M2 ──────]
KUBERNETES                                      [M3 ──────]
IDENTITY/PKI                                               [M4 ──────────]
OBSERVABILITY                                              [M5 ──────]
SERVICES FULL                                                             [M6 ──────────]
MULTI-CLOUD                                                                              [M7 ──────]
HARDENING                                                                                           [M8 ──────]
```

> Durée totale estimée : **~32 semaines / 16 sprints** (ajustable selon taille d'équipe)
> M4 et M5 peuvent démarrer en parallèle dès M3 terminé.

---

## M0 — Fondations & Gouvernance *(Sprints 1–2)*

**Objectif :** Mettre en place le socle IaC : structure des dépôts, conventions, CI/CD skeleton, et bootstrap des secrets. Rien ne peut être déployé sans ce milestone.

### Livrables - M0

- Structure monorepo : `terraform/`, `ansible/`, `packer/`, `helm/`, `docs/`, `.github/workflows/`
- Branching strategy documentée (trunk-based + feature branches + env branches `dev/staging/prod`)
- Pipeline CI/CD skeleton : lint → validate → plan → security scan → apply (GitHub Actions ou Jenkins)
- Bootstrap Vault via SOPS+age pour le premier secret (chicken-and-egg résolu)
- Templates ADR, CONTRIBUTING.md, module README
- OPA/Kyverno policies minimales (no hardcoded secrets, required tags, naming convention)
- Pre-commit hooks : `tflint`, `terraform fmt`, `ansible-lint`, `detect-secrets`

### Gate de sortie / Definition of Done - M0

- [ ] `terraform validate` passe sur tous les modules skeleton
- [ ] Pipeline CI/CD s'exécute sans erreur sur une PR de test
- [ ] Politique OPA bloque un module sans tags requis
- [ ] Secret bootstrap documenté et rejouable from scratch
- [ ] Peer review effectuée par au moins 2 agents (code-reviewer + security-ops)

### Agents propriétaires - M0

| Rôle | Agent |
| --- | --- |
| PM | `agent-project-manager-governance` |
| Lead | `agent-lead-governance` |
| Experts | `executant-docs-ops`, `executant-ci-cd-ops`, `executant-secrets-manager`, `executant-security-ops`, `executant-code-reviewer` |

---

## M1 — Réseau MVP *(Sprints 3–4)*

**Objectif :** Déployer le backbone réseau minimal — firewall, segmentation VLAN, DNS/NTP — entièrement piloté par IaC.

### Livrables - M1

- Module Terraform `network/opnsense` — provisioning firewall OPNsense via API
- Module Ansible `network/vlans` — VLANs management, MGMT/PROD/DMZ/OOB
- Module Ansible `network/dns` — PowerDNS ou Windows DNS interne
- Documentation VLAN scheme + firewall ruleset as code
- Tests réseau automatisés (Netmiko + Python scripts de validation)

### Gate de sortie  - M1

- [ ] VLAN MGMT isolé, VLAN PROD joignable depuis MGMT uniquement
- [ ] Firewall règles appliquées via IaC, vérifiables par `terraform plan` = no diff
- [ ] DNS résolution interne fonctionnelle (`dig @dns.local`)
- [ ] NTP synchronisé sur tous les équipements
- [ ] Scan de vulnérabilités réseau : Nmap, aucun port non autorisé ouvert

### Agents propriétaires - M1

| Rôle | Agent |
| --- | --- |
| PM | `agent-project-manager-platform` |
| Lead | `agent-lead-infra-ops` |
| Experts | `executant-network-ops`, `executant-security-ops`, `executant-cloud-ops` |

---

## M2 — Virtualisation MVP *(Sprints 5–6)*

**Objectif :** Provisionner un cluster hyperviseur (Proxmox 9.1 ou vSphere) depuis IaC et produire des golden images testées.

### Livrables - M2

- Module Terraform `compute/proxmox` (provider `bpg/proxmox`) ou `compute/vsphere`
- Packer templates : Ubuntu 24.04, AlmaLinux 9, Windows Server 2022
- Pipeline Packer automatisée : build → scan Trivy → publish vers registre
- Module Ansible `system/baseline` — hardening CIS niveau 1 appliqué sur golden images
- `cloud-init` intégré pour customisation at deploy time

### Gate de sortie - M2

- [ ] VM Ubuntu déployée en < 5 min via `terraform apply`
- [ ] VM Windows Server déployée en < 10 min via `terraform apply`
- [ ] Golden images scannées : 0 CVE critique (Trivy)
- [ ] Testinfra : tests sur la VM déployée (ssh, package baseline, NTP, DNS)
- [ ] `terraform destroy` propre, aucun orphan

### Agents propriétaires - M2

| Rôle | Agent |
| --- | --- |
| PM | `agent-project-manager-platform` |
| Lead | `agent-lead-infra-ops` |
| Experts | `executant-platform-ops`, `executant-security-ops`, `executant-ci-cd-ops` |

---

## M3 — Kubernetes Platform MVP *(Sprints 7–8)*

**Objectif :** Déployer un cluster Kubernetes production-grade (RKE2) et le socle GitOps (ArgoCD + Harbor + Traefik).

### Livrables - M3

- Module Terraform `kubernetes/rke2-cluster` (VMs issues de M2)
- Helm chart / ArgoCD ApplicationSet : déploiement ArgoCD lui-même (bootstrap)
- Harbor registry déployé et connecté au pipeline Packer/CI
- Traefik ingress + cert-manager + Let's Encrypt ou Step-CA interne
- `kube-bench` CIS scores dans le pipeline
- Namespace structure + RBAC de base

### Gate de sortie - M3

- [ ] `kube-bench` : score CIS >= niveau 1 sur control plane et workers
- [ ] Application de démonstration déployée depuis Git via ArgoCD en < 3 min
- [ ] TLS valide sur tous les ingress (certificat émis automatiquement)
- [ ] `trivy image` : 0 CVE critique sur l'image de démo
- [ ] Rollback validé : ArgoCD rollback testé

### Agents propriétaires - M3

| Rôle | Agent |
| --- | --- |
| PM | `agent-project-manager-platform` |
| Leads | `agent-lead-infra-ops`, `agent-lead-site-reliability` |
| Experts | `executant-platform-ops`, `executant-ci-cd-ops`, `executant-security-ops`, `executant-sre-ops` |

---

## M4 — Identity, PKI & Secrets *(Sprints 9–11)*

**Objectif :** Déployer le socle identité (AD + Keycloak SSO), PKI interne, et Vault secrets management — fédérant toutes les plateformes.

### Livrables - M4

- Module Ansible `identity/active-directory` — AD DS, DNS AD, GPO baseline
- Module Terraform `identity/keycloak` — realms, fédération AD, clients OIDC K8s
- Module Terraform `pki/step-ca` ou `pki/vault-pki` — CA racine + intermédiaires
- Module Terraform `secrets/vault` — init, unseal, auth methods (AD, Kubernetes, AppRole)
- External Secrets Operator déployé sur K8s
- Teleport pour accès SSH/K8s audité

### Gate de sortie - M4

- [ ] Login SSO Keycloak depuis AD fonctionne (LDAP bind)
- [ ] `kubectl` via OIDC Keycloak — authentification K8s centralisée
- [ ] Certificat TLS interne émis par PKI maison en < 30s
- [ ] Secret injecté dans un pod depuis Vault sans variable d'env hardcodée
- [ ] Vault audit log actif, Teleport session recording actif
- [ ] Wazuh alerte sur tentative auth AD échouée

### Agents propriétaires - M4

| Rôle | Agent |
| --- | --- |
| PM | `agent-project-manager-delivery` |
| Leads | `agent-lead-security`, `agent-lead-infra-ops` |
| Experts | `executant-security-ops`, `executant-secrets-manager`, `executant-software-engineer`, `executant-cloud-ops` |

---

## M5 — Observabilité MVP *(Sprints 9–10, parallèle à M4)*

**Objectif :** Déployer le stack d'observabilité complet sur Kubernetes — métriques, logs, traces, alerting, uptime.

### Livrables - M5

- Helm umbrella chart `observability/kube-prometheus-stack`
- Loki stack + Fluent Bit DaemonSet (logs containers + OS)
- Grafana Tempo + OpenTelemetry Collector
- AlertManager : routes email/Slack/PagerDuty + silence policies
- Wazuh agents déployés (Linux + Windows via Ansible)
- Blackbox Exporter + Uptime Kuma
- Dashboards Grafana as code (Grafonnet ou JSON provisionné)

### Gate de sortie - M5

- [ ] Dashboard K8s cluster health opérationnel (CPU/Mem/Pods/PVs)
- [ ] Log d'un pod visible dans Grafana < 30s après émission
- [ ] Alerte `KubePodCrashLooping` se déclenche en < 2 min sur test contrôlé
- [ ] Wazuh détecte un `sudo` non autorisé sur agent Linux
- [ ] Uptime Kuma : tous les endpoints critiques surveillés

### Agents propriétaires - M5

| Rôle | Agent |
| --- | --- |
| PM | `agent-project-manager-delivery` |
| Leads | `agent-lead-site-reliability`, `agent-lead-security` |
| Experts | `executant-observability-ops`, `executant-sre-ops`, `executant-security-ops` |

---

## M6 — Services Complets *(Sprints 12–13)*

**Objectif :** Connecter tous les services métier (M365, Atlassian, VPN/ZTNA, SIEM complet) au socle identité et observabilité.

### Livrables - M6

- Headscale auto-hébergé + Tailscale mesh multi-site
- SAML/OIDC : Atlassian Cloud → Keycloak, M365 → Entra ID Connect
- Microsoft Sentinel + Wazuh SIEM complet (playbooks)
- Module Terraform `network/vpn` - WireGuard/IPSec site-to-site
- SLOs définis dans Grafana pour services critiques

### Gate de sortie - M6

- [ ] SSO unifié : login Jira, Confluence, et kubectl avec le même compte AD
- [ ] Connexion VPN site-to-site testée avec fail-over
- [ ] SIEM : alerte sur login depuis IP inconnue < 5 min
- [ ] Intune : device compliance policy appliquée sur endpoints Windows

### Agents propriétaires - M6

| Rôle | Agent |
| --- | --- |
| PM | `agent-project-manager-delivery` |
| Leads | `agent-lead-security`, `agent-lead-infra-ops` |
| Experts | `executant-network-ops`, `executant-security-ops`, `executant-cloud-ops`, `executant-software-engineer` |

---

## M7 — Multi-Cloud Extension *(Sprints 14–15)*

**Objectif :** Étendre la plateforme IaC aux clouds publics (AWS, Azure, GCP, OVH) avec mesh réseau unifié et observabilité cross-cloud.

### Livrables - M7

- Modules Terraform par cloud : `cloud/aws`, `cloud/azure`, `cloud/gcp`, `cloud/ovh`
- Tailscale mesh cross-cloud automatisé
- Thanos ou Grafana Mimir pour fédération metrics multi-cluster
- OpenCost/Kubecost déployé par cluster
- Infracost dans le pipeline CI (PR comment avec coût estimé)
- Landing zones sécurisées par cloud (SCPs AWS, Azure Policies, GCP Org Policies)

### Gate de sortie - M7

- [ ] VM déployée sur AWS, Azure, GCP depuis même IaC en < 10 min
- [ ] Dashboard Grafana unifié affichant métriques on-prem + cloud
- [ ] Coût mensuel visible par namespace/projet dans OpenCost
- [ ] Infracost bloque une PR si delta coût > 20% sur threshold défini

### Agents propriétaires - M7

| Rôle | Agent |
| --- | --- |
| PM | `agent-project-manager-platform` |
| Leads | `agent-lead-infra-ops`, `agent-lead-site-reliability` |
| Experts | `executant-cloud-ops`, `executant-observability-ops`, `executant-sre-ops` |

---

## M8 — Hardening & Production Readiness *(Sprint 16)*

**Objectif :** Validation sécurité, SRE, et disaster recovery. Aucun composant ne va en production sans passer ce milestone.

### Livrables - M8

- CIS Benchmark Ansible roles appliqués sur tous les OS
- OPA/Gatekeeper policies enforced (deny privileged containers, require resource limits)
- Runbooks de DR testés (Proxmox snapshot restore, Vault disaster recovery)
- Chaos Engineering : test de résilience Kubernetes (pod kill, node isolate)
- Pentest interne documenté + remédiation

### Gate de sortie - M8

- [ ] CIS score >= niveau 2 sur Linux, niveau 1 sur Windows
- [ ] Kubernetes : 0 pod en `privileged: true` en production
- [ ] DR testé : restore complet Vault < 1h documenté et rejoué
- [ ] Chaos test : perte d'un worker node K8s → 0 interruption de service
- [ ] Rapport pentest : 0 finding critique non remédié

### Agents propriétaires - M8

| Rôle | Agent |
| --- | --- |
| PM | `agent-project-manager-platform` |
| Leads | `agent-lead-security`, `agent-lead-site-reliability` |
| Experts | `executant-security-ops`, `executant-sre-ops`, `executant-debug-engineer` |

---

## Matrice RACI synthétique

| Milestone | PM Delivery | PM Platform | PM Governance | Lead InfraOps | Lead Security | Lead SRE | Lead Governance |
| --- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| M0 Fondations | I | I | **R** | C | C | I | **A** |
| M1 Réseau | I | **R** | I | **A** | C | I | I |
| M2 Virtualisation | I | **R** | I | **A** | C | I | I |
| M3 Kubernetes | I | **R** | I | **A** | C | C | I |
| M4 Identity/PKI | **R** | I | I | C | **A** | I | I |
| M5 Observabilité | **R** | I | I | I | C | **A** | I |
| M6 Services | **R** | I | I | C | **A** | C | I |
| M7 Multi-Cloud | I | **R** | I | **A** | C | C | I |
| M8 Hardening | I | **R** | I | I | **A** | C | I |

> **R** = Responsible · **A** = Accountable · **C** = Consulted · **I** = Informed

---

## Chemin critique

```text
M0 → M1 → M2 → M3 ─┬─→ M4 ──┐
                    └─→ M5 ──┴─→ M6 → M7 → M8
```

**M4 et M5 sont parallélisables** dès M3 terminé. Tous les autres milestones sont séquentiels.

---

## Top 5 Risques Programme

| # | Risque | Probabilité | Impact | Mitigation |
| --- | --- | :---: | :---: | --- |
| 1 | **Chicken-and-egg Vault** : impossible de démarrer sans secrets, impossible d'avoir des secrets sans Vault | Haute | Critique | Bootstrap SOPS+age en M0, migration vers Vault en M4 |
| 2 | **Vendor lock-in vSphere** : licences VMware/Broadcom imprévisibles | Haute | Élevé | Paralléliser Proxmox dès M2, modules interchangeables |
| 3 | **Complexity SSO** : fédération AD→Keycloak→OIDC→SAML→Atlassian — trop de moving parts | Moyenne | Élevé | Tester chaque lien séparément en M4 avant intégration M6 |
| 4 | **Drift IaC** : ressources modifiées manuellement hors Terraform | Haute | Moyen | `terraform plan` dans CI sur toutes les branches + drift detection cron |
| 5 | **Scope creep multi-cloud** : M7 peut s'étirer indéfiniment | Haute | Moyen | Périmètre strict : 1 VPC par cloud en M7, extensions en M8+ |

---

## Sprint 1 — Backlog détaillé (M0)

| # | User Story | Critères d'acceptance | Agent |
| --- | --- | --- | --- |
| US-01 | **En tant que** développeur IaC, **je veux** une structure de repo standardisée **afin de** savoir où placer chaque ressource | `terraform/modules/`, `ansible/roles/`, `packer/`, `helm/`, `docs/adr/` existent avec READMEs | `executant-docs-ops` |
| US-02 | **En tant que** développeur, **je veux** des pre-commit hooks **afin de** détecter les problèmes avant la PR | `tflint`, `terraform fmt`, `ansible-lint`, `detect-secrets` bloquent un commit invalide | `executant-ci-cd-ops` |
| US-03 | **En tant que** ops, **je veux** un pipeline CI minimal **afin de** valider chaque PR | Pipeline GitHub Actions : lint → validate → tflint → trivy config scan → passe en < 5 min | `executant-ci-cd-ops` |
| US-04 | **En tant que** ops, **je veux** bootstrapper les secrets sans Vault **afin de** démarrer le projet | SOPS + age : fichier `secrets.enc.yaml` chiffré, décryptage en CI via clé age stockée dans GitHub Secret | `executant-secrets-manager` |
| US-05 | **En tant que** architecte, **je veux** documenter les décisions techniques **afin de** garantir la traçabilité | Template ADR dans `docs/adr/`, ADR-001 "IaC tooling selection" rédigé et accepté | `executant-docs-ops` |
| US-06 | **En tant que** ops, **je veux** des policies as code **afin de** bloquer les mauvaises pratiques dès la PR | OPA/Rego : rule "no hardcoded IPs", "required tags", "naming convention" — bloquent dans CI | `executant-security-ops` |
| US-07 | **En tant que** lead, **je veux** une convention de nommage documentée **afin de** garantir la cohérence | Document `docs/naming-conventions.md` : ressources Terraform, branches Git, modules Ansible, images Packer | `executant-docs-ops` |

---
