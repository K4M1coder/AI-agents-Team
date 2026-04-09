# Audit: Matrice Utilité Skill × Agent (Score 1-10)

## Légende
- **10**: Le skill EST le cœur de métier de l'agent
- **9**: Le skill couvre une compétence primaire critique
- **8**: Le skill est essentiel pour le travail quotidien
- **7**: Le skill est fréquemment utile
- **6**: Le skill est utile pour certaines missions
- **5**: Le skill apporte un contexte régulier
- **4**: Le skill est occasionnellement pertinent
- **3**: Le skill est rarement mais parfois utile
- **2**: Le skill apporte un contexte marginal
- **1**: Le skill est quasi-inutile pour cet agent
- **—**: Non pertinent (0)

### Symboles de branchement existant
- **[E]** = Branchement existant (déjà lié dans l'agent)
- **(vide)** = Pas de branchement

---

## EXECUTANTS AI/ML (10 agents)

### executant-ai-architect

| Skill | Score | Existant | Action |
|---|---|---|---|
| ai-integration | 10 | [E] | — |
| model-architectures | 9 | [E] | — |
| model-inference | 9 | [E] | — |
| gpu-compute | 8 | [E] | — |
| cutting-edge-architectures | 8 | [E] | — |
| backend-development | 7 | | +optionnel |
| database-engineering | 6 | | +optionnel |
| ai-enablement | 5 | | +optionnel |
| kubernetes-orchestration | 5 | | +optionnel |
| docker-containerization | 4 | | — |
| mlops-lifecycle | 4 | | — |
| cloud-operations (NEW) | 5 | | +optionnel |
| network-engineering (NEW) | 4 | | — |
| observability-stack | 4 | | — |
| security-hardening | 3 | | — |

### executant-ai-enablement

| Skill | Score | Existant | Action |
|---|---|---|---|
| ai-enablement | 10 | [E] | — |
| ai-integration | 9 | [E] | — |
| documentation-ops | 9 | [E] | — |
| model-inference | 6 | | +optionnel |
| model-training | 5 | | +optionnel |
| frontend-development | 6 | | +optionnel |
| backend-development | 5 | | +optionnel |
| model-architectures | 5 | | +optionnel |
| ai-alignment | 4 | | — |
| dataset-engineering | 3 | | — |

### executant-ai-safety

| Skill | Score | Existant | Action |
|---|---|---|---|
| ai-alignment | 10 | [E] | — |
| model-training | 9 | [E] | — |
| audio-speech-engineering | 6 | [E] | — |
| dataset-engineering | 8 | | **+obligatoire** |
| model-architectures | 7 | | +optionnel |
| research-intelligence | 6 | | +optionnel |
| ai-research-watch | 6 | | +optionnel |
| model-inference | 5 | | +optionnel |
| cutting-edge-architectures | 4 | | — |
| testing-strategy | 4 | | — |

### executant-ai-systems-engineer

| Skill | Score | Existant | Action |
|---|---|---|---|
| gpu-compute | 10 | [E] | — |
| model-inference | 9 | [E] | — |
| ai-integration | 8 | [E] | — |
| cutting-edge-architectures | 8 | [E] | — |
| audio-speech-engineering | 8 | [E] | — |
| ci-cd-pipeline | 5 | [E] | — |
| model-training | 6 | | +optionnel |
| backend-development | 6 | | +optionnel |
| debugging-profiling | 7 | | +optionnel |
| testing-strategy | 5 | | +optionnel |

### executant-audio-speech-specialist

| Skill | Score | Existant | Action |
|---|---|---|---|
| audio-speech-engineering | 10 | [E] | — |
| dataset-engineering | 9 | [E] | — |
| model-training | 8 | [E] | — |
| model-inference | 8 | [E] | — |
| model-architectures | 7 | | +optionnel |
| cutting-edge-architectures | 6 | | +optionnel |
| debugging-profiling | 5 | | +optionnel |
| ai-research-watch | 5 | | +optionnel |
| gpu-compute | 5 | | +optionnel |
| testing-strategy | 4 | | — |

### executant-data-engineer

| Skill | Score | Existant | Action |
|---|---|---|---|
| dataset-engineering | 10 | [E] | — |
| audio-speech-engineering | 8 | [E] | — |
| model-training | 7 | [E] | — |
| ai-alignment | 6 | [E] | — |
| database-engineering | 7 | | +optionnel |
| backend-development | 5 | | +optionnel |
| ai-research-watch | 4 | | — |
| testing-strategy | 5 | | +optionnel |
| docker-containerization | 4 | | — |
| ci-cd-pipeline | 4 | | — |

### executant-inference-engineer

| Skill | Score | Existant | Action |
|---|---|---|---|
| model-inference | 10 | [E] | — |
| gpu-compute | 9 | [E] | — |
| ai-integration | 8 | [E] | — |
| cutting-edge-architectures | 8 | [E] | — |
| model-training | 6 | | +optionnel |
| docker-containerization | 7 | | +optionnel |
| kubernetes-orchestration | 6 | | +optionnel |
| model-architectures | 7 | | +optionnel |
| mlops-lifecycle | 6 | | +optionnel |
| backend-development | 4 | | — |
| debugging-profiling | 5 | | +optionnel |
| cloud-operations (NEW) | 5 | | +optionnel |

### executant-ml-engineer

| Skill | Score | Existant | Action |
|---|---|---|---|
| model-training | 10 | [E] | — |
| dataset-engineering | 9 | [E] | — |
| cutting-edge-architectures | 8 | [E] | — |
| ai-alignment | 6 | [E] | — |
| model-architectures | 8 | | **+obligatoire** |
| gpu-compute | 8 | | **+obligatoire** |
| model-inference | 7 | | +optionnel |
| debugging-profiling | 6 | | +optionnel |
| mlops-lifecycle | 7 | | +optionnel |
| ai-research-watch | 5 | | +optionnel |
| docker-containerization | 4 | | — |

### executant-ml-researcher

| Skill | Score | Existant | Action |
|---|---|---|---|
| model-architectures | 10 | [E] | — |
| ai-research-watch | 10 | [E] | — |
| cutting-edge-architectures | 9 | [E] | — |
| research-intelligence | 9 | [E] | — |
| model-training | 7 | | +optionnel |
| model-inference | 7 | | +optionnel |
| audio-speech-engineering | 6 | | +optionnel |
| ai-alignment | 6 | | +optionnel |
| gpu-compute | 6 | | +optionnel |
| dataset-engineering | 5 | | +optionnel |

### executant-mlops-engineer

| Skill | Score | Existant | Action |
|---|---|---|---|
| mlops-lifecycle | 10 | [E] | — |
| ci-cd-pipeline | 9 | [E] | — |
| model-inference | 7 | [E] | — |
| supply-chain-security | 6 | [E] | — |
| docker-containerization | 8 | | **+obligatoire** |
| kubernetes-orchestration | 7 | | +optionnel |
| model-training | 7 | | +optionnel |
| observability-stack | 6 | | +optionnel |
| dataset-engineering | 5 | | +optionnel |
| cloud-operations (NEW) | 5 | | +optionnel |
| gpu-compute | 5 | | +optionnel |
| testing-strategy | 4 | | — |

### executant-research-intelligence

| Skill | Score | Existant | Action |
|---|---|---|---|
| research-intelligence | 10 | [E] | — |
| ai-research-watch | 10 | [E] | — |
| model-architectures | 8 | [E] | — |
| supply-chain-security | 7 | | +optionnel |
| ai-alignment | 6 | | +optionnel |
| cutting-edge-architectures | 7 | | +optionnel |
| model-training | 4 | | — |
| model-inference | 4 | | — |

---

## EXECUTANTS INFRA/PLATFORM (8 agents)

### executant-ci-cd-ops

| Skill | Score | Existant | Action |
|---|---|---|---|
| ci-cd-pipeline | 10 | [E] | — |
| supply-chain-security | 9 | [E] | — |
| docker-containerization | 9 | [E] | — |
| kubernetes-orchestration | 8 | [E] | — |
| security-hardening | 7 | | +optionnel |
| observability-stack | 5 | | +optionnel |
| testing-strategy | 6 | | +optionnel |
| secrets-management | 6 | | +optionnel |
| terraform-provisioning | 4 | | — |
| cloud-operations (NEW) | 4 | | — |

### executant-cloud-ops

| Skill | Score | Existant | Action |
|---|---|---|---|
| cloud-operations (NEW) | 10 | | **+obligatoire (NEW)** |
| terraform-provisioning | 9 | [E] | — |
| kubernetes-orchestration | 8 | [E] | — |
| secrets-management | 7 | [E] | — |
| packer-imaging | 6 | [E] | — |
| security-hardening | 7 | | +optionnel |
| network-engineering (NEW) | 7 | | +optionnel |
| docker-containerization | 6 | | +optionnel |
| observability-stack | 5 | | +optionnel |
| ansible-automation | 5 | | +optionnel |

### executant-gpu-infra

| Skill | Score | Existant | Action |
|---|---|---|---|
| gpu-compute | 10 | [E] | — |
| model-inference | 8 | [E] | — |
| model-training | 8 | [E] | — |
| cutting-edge-architectures | 8 | [E] | — |
| cloud-operations (NEW) | 7 | | +optionnel |
| kubernetes-orchestration | 6 | | +optionnel |
| network-engineering (NEW) | 5 | | +optionnel |
| docker-containerization | 5 | | +optionnel |
| terraform-provisioning | 5 | | +optionnel |
| observability-stack | 4 | | — |

### executant-infra-architect

| Skill | Score | Existant | Action |
|---|---|---|---|
| terraform-provisioning | 10 | [E] | — |
| ansible-automation | 9 | [E] | — |
| packer-imaging | 8 | [E] | — |
| kubernetes-orchestration | 8 | [E] | — |
| docker-containerization | 8 | | **+obligatoire** |
| virtualization-platform (NEW) | 8 | | **+obligatoire (NEW)** |
| cloud-operations (NEW) | 8 | | **+obligatoire (NEW)** |
| network-engineering (NEW) | 7 | | +optionnel |
| security-hardening | 7 | | +optionnel |
| documentation-ops | 6 | | +optionnel |
| observability-stack | 4 | | — |

### executant-network-ops

| Skill | Score | Existant | Action |
|---|---|---|---|
| network-engineering (NEW) | 10 | | **+obligatoire (NEW)** |
| terraform-provisioning | 6 | [E] | — |
| kubernetes-orchestration | 8 | [E] | — |
| security-hardening | 8 | [E] | — |
| incident-management | 7 | [E] | — |
| docker-containerization | 5 | | +optionnel |
| observability-stack | 6 | | +optionnel |
| cloud-operations (NEW) | 6 | | +optionnel |
| virtualization-platform (NEW) | 4 | | — |
| debugging-profiling | 5 | | +optionnel |

### executant-observability-ops

| Skill | Score | Existant | Action |
|---|---|---|---|
| observability-stack | 10 | [E] | — |
| incident-management | 9 | [E] | — |
| kubernetes-orchestration | 8 | [E] | — |
| docker-containerization | 6 | | +optionnel |
| cloud-operations (NEW) | 5 | | +optionnel |
| debugging-profiling | 6 | | +optionnel |
| ci-cd-pipeline | 5 | | +optionnel |
| terraform-provisioning | 3 | | — |
| backend-development | 4 | | — |

### executant-platform-ops

| Skill | Score | Existant | Action |
|---|---|---|---|
| virtualization-platform (NEW) | 10 | | **+obligatoire (NEW)** |
| packer-imaging | 9 | [E] | — |
| ansible-automation | 9 | [E] | — |
| terraform-provisioning | 8 | [E] | — |
| kubernetes-orchestration | 6 | [E] | — |
| docker-containerization | 6 | | +optionnel |
| network-engineering (NEW) | 6 | | +optionnel |
| security-hardening | 5 | | +optionnel |
| cloud-operations (NEW) | 5 | | +optionnel |
| observability-stack | 4 | | — |
| incident-management | 4 | | — |

### executant-secrets-manager

| Skill | Score | Existant | Action |
|---|---|---|---|
| secrets-management | 10 | [E] | — |
| security-hardening | 9 | [E] | — |
| ci-cd-pipeline | 7 | [E] | — |
| kubernetes-orchestration | 7 | | +optionnel |
| supply-chain-security | 6 | | +optionnel |
| docker-containerization | 4 | | — |
| terraform-provisioning | 5 | | +optionnel |
| cloud-operations (NEW) | 5 | | +optionnel |
| ansible-automation | 4 | | — |

---

## EXECUTANTS SOFTWARE & OPS (6 agents)

### executant-code-reviewer

| Skill | Score | Existant | Action |
|---|---|---|---|
| code-review-practice | 10 | [E] | — |
| backend-development | 9 | [E] | — |
| frontend-development | 8 | [E] | — |
| database-engineering | 8 | [E] | — |
| testing-strategy | 8 | [E] | — |
| security-hardening | 8 | [E] | — |
| docker-containerization | 5 | | +optionnel |
| debugging-profiling | 6 | | +optionnel |
| ci-cd-pipeline | 5 | | +optionnel |
| kubernetes-orchestration | 3 | | — |

### executant-debug-engineer

| Skill | Score | Existant | Action |
|---|---|---|---|
| debugging-profiling | 10 | [E] | — |
| backend-development | 9 | [E] | — |
| frontend-development | 7 | [E] | — |
| database-engineering | 8 | [E] | — |
| observability-stack | 8 | [E] | — |
| testing-strategy | 6 | | +optionnel |
| docker-containerization | 6 | | +optionnel |
| kubernetes-orchestration | 5 | | +optionnel |
| network-engineering (NEW) | 5 | | +optionnel |
| ci-cd-pipeline | 3 | | — |

### executant-security-ops

| Skill | Score | Existant | Action |
|---|---|---|---|
| security-hardening | 10 | [E] | — |
| supply-chain-security | 10 | [E] | — |
| secrets-management | 8 | [E] | — |
| ai-alignment | 5 | [E] | — |
| docker-containerization | 8 | | **+obligatoire** |
| ci-cd-pipeline | 7 | | +optionnel |
| kubernetes-orchestration | 7 | | +optionnel |
| ansible-automation | 5 | | +optionnel |
| network-engineering (NEW) | 5 | | +optionnel |
| cloud-operations (NEW) | 6 | | +optionnel |
| debugging-profiling | 3 | | — |

### executant-software-engineer

| Skill | Score | Existant | Action |
|---|---|---|---|
| backend-development | 10 | [E] | — |
| frontend-development | 10 | [E] | — |
| database-engineering | 10 | [E] | — |
| docker-containerization | 8 | [E] | — |
| ci-cd-pipeline | 7 | [E] | — |
| testing-strategy | 8 | | **+obligatoire** |
| debugging-profiling | 7 | | +optionnel |
| code-review-practice | 6 | | +optionnel |
| kubernetes-orchestration | 5 | | +optionnel |
| security-hardening | 4 | | — |
| observability-stack | 4 | | — |

### executant-sre-ops

| Skill | Score | Existant | Action |
|---|---|---|---|
| incident-management | 10 | [E] | — |
| observability-stack | 9 | [E] | — |
| ci-cd-pipeline | 8 | [E] | — |
| kubernetes-orchestration | 7 | | +optionnel |
| docker-containerization | 5 | | +optionnel |
| debugging-profiling | 6 | | +optionnel |
| testing-strategy | 5 | | +optionnel |
| cloud-operations (NEW) | 5 | | +optionnel |
| security-hardening | 4 | | — |
| network-engineering (NEW) | 5 | | +optionnel |

### executant-test-engineer

| Skill | Score | Existant | Action |
|---|---|---|---|
| testing-strategy | 10 | [E] | — |
| backend-development | 8 | [E] | — |
| frontend-development | 8 | [E] | — |
| database-engineering | 7 | [E] | — |
| ci-cd-pipeline | 8 | [E] | — |
| debugging-profiling | 7 | | +optionnel |
| docker-containerization | 5 | | +optionnel |
| code-review-practice | 5 | | +optionnel |
| security-hardening | 4 | | — |
| kubernetes-orchestration | 3 | | — |

---

## AGENT DE GOUVERNANCE

### team-maintainer

| Skill | Score | Existant | Action |
|---|---|---|---|
| multi-agent-manager | 10 | [E] | — |
| documentation-ops | 6 | | +optionnel |
| — | — | | — |

### executant-docs-ops

| Skill | Score | Existant | Action |
|---|---|---|---|
| documentation-ops | 10 | [E] | — |
| ai-enablement | 5 | | +optionnel |
| backend-development | 3 | | — |
| frontend-development | 3 | | — |
| ci-cd-pipeline | 4 | | — |

---

## TEAM LEADS (6)

### agent-lead-ai-core

| Skill | Score | Existant | Action |
|---|---|---|---|
| ai-integration | 9 | [E] | — |
| model-training | 9 | [E] | — |
| model-inference | 9 | [E] | — |
| dataset-engineering | 8 | [E] | — |
| ai-alignment | 8 | [E] | — |
| audio-speech-engineering | 8 | [E] | — |
| mlops-lifecycle | 8 | [E] | — |
| model-architectures | 8 | | **+obligatoire** |
| cutting-edge-architectures | 7 | | +optionnel |
| gpu-compute | 7 | | +optionnel |
| research-intelligence | 6 | | +optionnel |

### agent-lead-governance

| Skill | Score | Existant | Action |
|---|---|---|---|
| documentation-ops | 9 | [E] | — |
| ai-enablement | 9 | [E] | — |
| research-intelligence | 9 | [E] | — |
| ai-research-watch | 8 | [E] | — |
| incident-management | 6 | [E] | — |
| multi-agent-manager | 5 | | +optionnel |

### agent-lead-infra-ops

| Skill | Score | Existant | Action |
|---|---|---|---|
| terraform-provisioning | 9 | [E] | — |
| gpu-compute | 8 | [E] | — |
| packer-imaging | 8 | [E] | — |
| ansible-automation | 8 | [E] | — |
| kubernetes-orchestration | 8 | [E] | — |
| docker-containerization | 8 | [E] | — |
| cloud-operations (NEW) | 9 | | **+obligatoire (NEW)** |
| virtualization-platform (NEW) | 8 | | **+obligatoire (NEW)** |
| network-engineering (NEW) | 8 | | **+obligatoire (NEW)** |
| security-hardening | 5 | | +optionnel |

### agent-lead-security

| Skill | Score | Existant | Action |
|---|---|---|---|
| security-hardening | 10 | [E] | — |
| secrets-management | 9 | [E] | — |
| supply-chain-security | 9 | [E] | — |
| incident-management | 8 | [E] | — |
| ai-alignment | 7 | [E] | — |
| docker-containerization | 6 | | +optionnel |
| kubernetes-orchestration | 6 | | +optionnel |
| ci-cd-pipeline | 6 | | +optionnel |
| network-engineering (NEW) | 7 | | +optionnel |
| cloud-operations (NEW) | 5 | | +optionnel |

### agent-lead-site-reliability

| Skill | Score | Existant | Action |
|---|---|---|---|
| incident-management | 10 | [E] | — |
| observability-stack | 9 | [E] | — |
| ci-cd-pipeline | 9 | [E] | — |
| kubernetes-orchestration | 8 | [E] | — |
| docker-containerization | 6 | | +optionnel |
| debugging-profiling | 6 | | +optionnel |
| cloud-operations (NEW) | 6 | | +optionnel |
| security-hardening | 5 | | +optionnel |
| testing-strategy | 5 | | +optionnel |
| network-engineering (NEW) | 5 | | +optionnel |

### agent-lead-software-engineering

| Skill | Score | Existant | Action |
|---|---|---|---|
| backend-development | 10 | [E] | — |
| frontend-development | 9 | [E] | — |
| database-engineering | 9 | [E] | — |
| testing-strategy | 9 | [E] | — |
| debugging-profiling | 9 | [E] | — |
| code-review-practice | 9 | [E] | — |
| docker-containerization | 8 | [E] | — |
| ci-cd-pipeline | 8 | [E] | — |
| kubernetes-orchestration | 5 | | +optionnel |
| security-hardening | 5 | | +optionnel |
| observability-stack | 4 | | — |

---

## PROJECT MANAGERS (3) — scores plus bas (rôle de supervision, pas d'exécution directe)

### agent-project-manager-delivery

| Skill | Score | Existant | Action |
|---|---|---|---|
| multi-agent-manager | 9 | [E] | — |
| ai-integration | 7 | [E] | — |
| mlops-lifecycle | 7 | [E] | — |
| model-training | 6 | [E] | — |
| model-inference | 6 | [E] | — |
| backend-development | 7 | [E] | — |
| frontend-development | 6 | [E] | — |
| database-engineering | 6 | [E] | — |
| ci-cd-pipeline | 6 | | +optionnel |
| testing-strategy | 5 | | +optionnel |

### agent-project-manager-governance

| Skill | Score | Existant | Action |
|---|---|---|---|
| multi-agent-manager | 9 | [E] | — |
| documentation-ops | 8 | [E] | — |
| ai-enablement | 7 | [E] | — |
| research-intelligence | 7 | [E] | — |
| ai-research-watch | 7 | [E] | — |
| incident-management | 6 | [E] | — |

### agent-project-manager-platform

| Skill | Score | Existant | Action |
|---|---|---|---|
| multi-agent-manager | 9 | [E] | — |
| terraform-provisioning | 8 | [E] | — |
| kubernetes-orchestration | 7 | [E] | — |
| security-hardening | 7 | [E] | — |
| secrets-management | 6 | [E] | — |
| observability-stack | 7 | [E] | — |
| packer-imaging | 6 | [E] | — |
| cloud-operations (NEW) | 8 | | **+obligatoire (NEW)** |
| network-engineering (NEW) | 6 | | +optionnel |
| virtualization-platform (NEW) | 6 | | +optionnel |
| docker-containerization | 6 | | +optionnel |

### agent-manager

| Skill | Score | Existant | Action |
|---|---|---|---|
| multi-agent-manager | 10 | [E] | — |
| terraform-provisioning | 3 | [E] | ⚠ LOW |
| incident-management | 5 | [E] | — |
| documentation-ops | 5 | [E] | — |
