.PHONY: validate precommit ci

validate:
    python scripts/validate_baseline.py

precommit:
    pre-commit run --all-files

ci: validate precommit
