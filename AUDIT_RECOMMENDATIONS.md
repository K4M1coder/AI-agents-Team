# Audit: Recommandations de Branchement

## 1. BRANCHEMENTS OBLIGATOIRES À AJOUTER (Utilité 8-10)

Paires agent × skill avec utilité ≥ 8 **sans branchement existant**.

### Nouveaux skills à créer d'abord
Ces skills n'existent pas encore et doivent être créés avant branchement :

| Nouveau Skill | Agents obligatoires (≥8) | Agents optionnels (5-7) |
|---|---|---|
| **network-engineering** | executant-network-ops (10), agent-lead-infra-ops (8) | executant-cloud-ops (7), executant-infra-architect (7), agent-lead-security (7), executant-security-ops (5), executant-debug-engineer (5), executant-gpu-infra (5), executant-sre-ops (5), agent-lead-site-reliability (5), agent-project-manager-platform (6) |
| **cloud-operations** | executant-cloud-ops (10), agent-lead-infra-ops (9), agent-project-manager-platform (8) | executant-infra-architect (8)★, executant-gpu-infra (7), executant-security-ops (6), executant-sre-ops (5), agent-lead-security (5), agent-lead-site-reliability (6), executant-observability-ops (5), executant-network-ops (6), executant-ai-architect (5), executant-inference-engineer (5), executant-mlops-engineer (5), executant-secrets-manager (5), executant-platform-ops (5) |
| **virtualization-platform** | executant-platform-ops (10), executant-infra-architect (8), agent-lead-infra-ops (8) | executant-network-ops (4)✗, agent-project-manager-platform (6) |

> ★ executant-infra-architect a cloud-operations = 8, donc **obligatoire**. Corrigé dans le tableau agent ci-dessous.

### Branchements obligatoires sur skills existants

| Agent | Skill à ajouter | Utilité | Raison |
|---|---|---|---|
| **executant-ai-safety** | dataset-engineering | 8 | Red-teaming et évaluation nécessitent manipulation de datasets |
| **executant-ml-engineer** | model-architectures | 8 | Implémente les architectures, doit comprendre les designs |
| **executant-ml-engineer** | gpu-compute | 8 | Training distribué nécessite gestion GPU/mémoire |
| **executant-mlops-engineer** | docker-containerization | 8 | Containerisation des pipelines ML et modèles |
| **executant-infra-architect** | docker-containerization | 8 | IaC inclut systématiquement la containerisation |
| **executant-security-ops** | docker-containerization | 8 | Sécurité des containers critique (rootless, capabilities) |
| **executant-software-engineer** | testing-strategy | 8 | Tout développeur doit tester son code |
| **agent-lead-ai-core** | model-architectures | 8 | Lead technique doit comprendre les architectures des équipes |

### Résumé des branchements obligatoires

| Catégorie | Nombre |
|---|---|
| Sur skills existants | 8 |
| Sur cloud-operations (NEW) | 4 (cloud-ops, infra-ops-lead, PM-platform, infra-architect) |
| Sur network-engineering (NEW) | 2 (network-ops, infra-ops-lead) |
| Sur virtualization-platform (NEW) | 3 (platform-ops, infra-architect, infra-ops-lead) |
| **TOTAL obligatoires** | **17** |

---

## 2. BRANCHEMENTS OPTIONNELS À AJOUTER (Utilité 5-7)

| Agent | Skills optionnels à ajouter | Utilités |
|---|---|---|
| **executant-ai-architect** | backend-development (7), database-engineering (6), ai-enablement (5), kubernetes-orchestration (5), cloud-operations (5) | 5-7 |
| **executant-ai-enablement** | model-inference (6), frontend-development (6), backend-development (5), model-training (5), model-architectures (5) | 5-6 |
| **executant-ai-safety** | model-architectures (7), research-intelligence (6), ai-research-watch (6), model-inference (5) | 5-7 |
| **executant-ai-systems-engineer** | debugging-profiling (7), model-training (6), backend-development (6), testing-strategy (5) | 5-7 |
| **executant-audio-speech** | model-architectures (7), cutting-edge-architectures (6), debugging-profiling (5), ai-research-watch (5), gpu-compute (5) | 5-7 |
| **executant-data-engineer** | database-engineering (7), backend-development (5), testing-strategy (5) | 5-7 |
| **executant-inference-engineer** | docker-containerization (7), model-architectures (7), model-training (6), kubernetes-orchestration (6), mlops-lifecycle (6), debugging-profiling (5), cloud-operations (5) | 5-7 |
| **executant-ml-engineer** | model-inference (7), mlops-lifecycle (7), debugging-profiling (6), ai-research-watch (5) | 5-7 |
| **executant-ml-researcher** | model-training (7), model-inference (7), audio-speech-engineering (6), ai-alignment (6), gpu-compute (6), dataset-engineering (5) | 5-7 |
| **executant-mlops-engineer** | kubernetes-orchestration (7), model-training (7), observability-stack (6), dataset-engineering (5), cloud-operations (5), gpu-compute (5) | 5-7 |
| **executant-research-intelligence** | supply-chain-security (7), cutting-edge-architectures (7), ai-alignment (6) | 6-7 |
| **executant-ci-cd-ops** | security-hardening (7), testing-strategy (6), secrets-management (6), observability-stack (5) | 5-7 |
| **executant-cloud-ops** | security-hardening (7), network-engineering (7), docker-containerization (6), observability-stack (5), ansible-automation (5) | 5-7 |
| **executant-gpu-infra** | cloud-operations (7), kubernetes-orchestration (6), network-engineering (5), docker-containerization (5), terraform-provisioning (5) | 5-7 |
| **executant-infra-architect** | network-engineering (7), security-hardening (7), documentation-ops (6) | 6-7 |
| **executant-network-ops** | docker-containerization (5), observability-stack (6), cloud-operations (6), debugging-profiling (5) | 5-6 |
| **executant-observability-ops** | docker-containerization (6), debugging-profiling (6), cloud-operations (5), ci-cd-pipeline (5) | 5-6 |
| **executant-platform-ops** | docker-containerization (6), network-engineering (6), security-hardening (5), cloud-operations (5) | 5-6 |
| **executant-secrets-manager** | kubernetes-orchestration (7), supply-chain-security (6), terraform-provisioning (5), cloud-operations (5) | 5-7 |
| **executant-code-reviewer** | debugging-profiling (6), docker-containerization (5), ci-cd-pipeline (5) | 5-6 |
| **executant-debug-engineer** | testing-strategy (6), docker-containerization (6), kubernetes-orchestration (5), network-engineering (5) | 5-6 |
| **executant-security-ops** | ci-cd-pipeline (7), kubernetes-orchestration (7), cloud-operations (6), ansible-automation (5), network-engineering (5) | 5-7 |
| **executant-software-engineer** | debugging-profiling (7), code-review-practice (6), kubernetes-orchestration (5) | 5-7 |
| **executant-sre-ops** | kubernetes-orchestration (7), debugging-profiling (6), docker-containerization (5), testing-strategy (5), cloud-operations (5), network-engineering (5) | 5-7 |
| **executant-test-engineer** | debugging-profiling (7), docker-containerization (5), code-review-practice (5) | 5-7 |
| **executant-docs-ops** | ai-enablement (5) | 5 |
| **team-maintainer** | documentation-ops (6) | 6 |
| **agent-lead-ai-core** | cutting-edge-architectures (7), gpu-compute (7), research-intelligence (6) | 6-7 |
| **agent-lead-governance** | multi-agent-manager (5) | 5 |
| **agent-lead-infra-ops** | security-hardening (5) | 5 |
| **agent-lead-security** | docker-containerization (6), kubernetes-orchestration (6), ci-cd-pipeline (6), network-engineering (7), cloud-operations (5) | 5-7 |
| **agent-lead-site-reliability** | docker-containerization (6), debugging-profiling (6), cloud-operations (6), security-hardening (5), testing-strategy (5), network-engineering (5) | 5-6 |
| **agent-lead-software-engineering** | kubernetes-orchestration (5), security-hardening (5) | 5 |
| **agent-project-manager-delivery** | ci-cd-pipeline (6), testing-strategy (5) | 5-6 |
| **agent-project-manager-platform** | docker-containerization (6), network-engineering (6), virtualization-platform (6) | 6 |

**TOTAL optionnels : ~140 paires**

---

## 3. BRANCHEMENTS EXISTANTS AVEC UTILITÉ < 5

| Agent | Skill existant | Utilité | Risque si retiré |
|---|---|---|---|
| **agent-manager** | terraform-provisioning | 3 | **BAS** — manager ne provisionne jamais directement |
| **executant-ai-safety** | audio-speech-engineering | 6 | AUCUN (≥5, conserver) |

### Analyse détaillée

Après revue de la matrice complète, **un seul branchement existant** a une utilité < 5 :

**agent-manager → terraform-provisioning (3)**

Tous les autres branchements existants ont une utilité ≥ 5, ce qui indique que l'architecture de branchement actuelle est **bien dimensionnée** — pas de surcharge significative.

---

## 4. IMPACT DU RETRAIT DES BRANCHEMENTS < 5

### Cas unique : agent-manager → terraform-provisioning

**Impact fonctionnel :** FAIBLE
- L'agent-manager est un rôle de supervision pure qui délègue via les project-managers
- Il n'utilise jamais terraform-provisioning directement
- Le PM-platform (qui a ce skill à utilité 8) gère tout le provisionnement infrastructure
- Retirer ce skill de l'agent-manager n'affecte aucune capacité de l'équipe

**Recommandation :** Retirer ce branchement. Il constitue un bruit qui dilue le contexte du manager.

### Conclusion sur les branchements existants < 5

L'architecture actuelle est **remarquablement propre** :
- Sur ~175 branchements existants, un seul est sous-dimensionné
- Le ratio branchements pertinents / total est de **99.4%**
- La principale lacune n'est pas le surplus mais l'**absence** de skills pour certains domaines (network, cloud, virtualization)
