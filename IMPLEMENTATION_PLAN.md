# PLAN D'IMPLÉMENTATION — Audit Compétences × Skills × Branchements

> **Règle stricte** : Je comprends → J'exécute → Je vérifie → Je coche → Je passe au suivant.
> Interdit de passer à la tâche suivante si toutes les sous-tâches ne sont pas cochées.

---

## TÂCHE 1 : Créer le skill `network-engineering`
- [x] 1.1 Créer le dossier `.github/skills/network-engineering/`
- [x] 1.2 Créer `SKILL.md` avec frontmatter YAML (name, description, argument-hint)
- [x] 1.3 Rédiger sections : When to Use, Procedure, Diagnostics, Anti-Patterns, Agent Integration
- [x] 1.4 Vérifier que le fichier est syntaxiquement correct (frontmatter YAML valide)

## TÂCHE 2 : Créer le skill `cloud-operations`
- [x] 2.1 Créer le dossier `.github/skills/cloud-operations/`
- [x] 2.2 Créer `SKILL.md` avec frontmatter YAML (name, description, argument-hint)
- [x] 2.3 Rédiger sections : When to Use, Procedure, Cloud Provider Matrix, FinOps, Anti-Patterns, Agent Integration
- [x] 2.4 Vérifier que le fichier est syntaxiquement correct (frontmatter YAML valide)

## TÂCHE 3 : Créer le skill `virtualization-platform`
- [x] 3.1 Créer le dossier `.github/skills/virtualization-platform/`
- [x] 3.2 Créer `SKILL.md` avec frontmatter YAML (name, description, argument-hint)
- [x] 3.3 Rédiger sections : When to Use, Procedure, Hypervisor Matrix, Storage, HA, Anti-Patterns, Agent Integration
- [x] 3.4 Vérifier que le fichier est syntaxiquement correct (frontmatter YAML valide)

## TÂCHE 4 : Branchements obligatoires — skills existants (8 modifications)
- [x] 4.1 `executant-ai-safety` : ajouter `dataset-engineering` en Contextual Skill
- [x] 4.2 `executant-ml-engineer` : ajouter `model-architectures` en Contextual Skill
- [x] 4.3 `executant-ml-engineer` : ajouter `gpu-compute` en Contextual Skill
- [x] 4.4 `executant-mlops-engineer` : ajouter `docker-containerization` en Contextual Skill
- [x] 4.5 `executant-infra-architect` : ajouter `docker-containerization` en Contextual Skill
- [x] 4.6 `executant-security-ops` : ajouter `docker-containerization` en Contextual Skill
- [x] 4.7 `executant-software-engineer` : ajouter `testing-strategy` en Contextual Skill
- [x] 4.8 `agent-lead-ai-core` : ajouter `model-architectures` en Contextual Skill

## TÂCHE 5 : Branchements obligatoires — nouveaux skills (9 modifications)
- [x] 5.1 `executant-network-ops` : ajouter `network-engineering` en Primary Skill
- [x] 5.2 `executant-cloud-ops` : ajouter `cloud-operations` en Primary Skill
- [x] 5.3 `executant-platform-ops` : ajouter `virtualization-platform` en Primary Skill
- [x] 5.4 `agent-lead-infra-ops` : ajouter `cloud-operations` en Primary Skill
- [x] 5.5 `agent-lead-infra-ops` : ajouter `network-engineering` en Contextual Skill
- [x] 5.6 `agent-lead-infra-ops` : ajouter `virtualization-platform` en Contextual Skill
- [x] 5.7 `executant-infra-architect` : ajouter `cloud-operations` en Contextual Skill
- [x] 5.8 `executant-infra-architect` : ajouter `virtualization-platform` en Contextual Skill
- [x] 5.9 `agent-project-manager-platform` : ajouter `cloud-operations` en Contextual Skill

## TÂCHE 6 : Nettoyage — retirer le branchement sous-utilisé
- [x] 6.1 `agent-manager` : retirer `terraform-provisioning` de Contextual Skills
- [x] 6.2 Vérifier que la section Reference Skills reste cohérente après retrait

## TÂCHE 7 : Vérification globale
- [x] 7.1 Lister tous les fichiers modifiés et vérifier absence d'erreurs de syntaxe
- [x] 7.2 Vérifier que les 3 nouveaux skills apparaissent dans `.github/skills/`
- [x] 7.3 Vérifier que les 17 branchements obligatoires sont en place (spot-check 5 agents)
- [x] 7.4 Vérifier que le branchement retiré (agent-manager → terraform) est bien absent
- [x] 7.5 Mettre à jour AUDIT_TASKS.md pour refléter l'implémentation terminée

---

## Compteurs

| Catégorie | Items | Complétés |
|---|---|---|
| Tâche 1 — Skill network-engineering | 4 | 4 |
| Tâche 2 — Skill cloud-operations | 4 | 4 |
| Tâche 3 — Skill virtualization-platform | 4 | 4 |
| Tâche 4 — Branchements obligatoires existants | 8 | 8 |
| Tâche 5 — Branchements obligatoires nouveaux | 9 | 9 |
| Tâche 6 — Nettoyage | 2 | 2 |
| Tâche 7 — Vérification | 5 | 5 |
| **TOTAL** | **36** | **36** |
