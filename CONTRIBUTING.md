# Contribution Guide

Prerequis:
- Python 3.11+
- pre-commit
- sops
- age

Workflow:
1. Branche feature/fix/docs/chore
2. Commits atomiques
3. Validation locale:
   - make validate
   - pre-commit run --all-files
4. PR vers main

Secrets:
- Aucun secret en clair
- Utiliser uniquement secrets/*.enc.yaml|*.enc.yml|*.enc.json|*.age
