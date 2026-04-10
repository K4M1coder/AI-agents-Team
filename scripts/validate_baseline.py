#!/usr/bin/env python3
from pathlib import Path
import sys

REQUIRED_FILES = [
  "CONTRIBUTING.md",
  ".pre-commit-config.yaml",
  ".sops.yaml",
  "Makefile",
  ".github/workflows/pr-validation.yml",
  "docs/adr/template.md",
  "docs/adr/ADR-001-tooling-selection.md",
  "docs/conventions/naming.md",
  "policies/repository-baseline.md",
  "policies/secrets-baseline.md",
  "scripts/README.md",
  "secrets/README.md",
  "secrets/.gitignore",
  "secrets/.age-recipients.example.txt",
  "terraform/README.md",
  "ansible/README.md",
  "packer/README.md",
  "helm/README.md",
]

REQUIRED_DIRS = [
  ".github/workflows",
  "docs/adr",
  "docs/conventions",
  "docs/runbooks",
  "policies",
  "scripts",
  "secrets",
  "terraform/modules",
  "ansible/playbooks",
  "packer/templates",
  "helm/charts",
]

ALLOWED_SECRET = {"README.md", ".gitignore", ".age-recipients.example.txt"}
ALLOWED_SUFFIX = (".enc.yaml", ".enc.yml", ".enc.json", ".age")

root = Path(__file__).resolve().parents[1]
errors = []

for f in REQUIRED_FILES:
  if not (root / f).is_file():
    errors.append(f"Missing file: {f}")

for d in REQUIRED_DIRS:
  if not (root / d).is_dir():
    errors.append(f"Missing dir: {d}")

sdir = root / "secrets"
if sdir.exists():
  for p in sdir.rglob("*"):
    if p.is_file():
      n = p.name
      if n in ALLOWED_SECRET:
        continue
      if any(n.endswith(s) for s in ALLOWED_SUFFIX):
        continue
      errors.append(f"Forbidden file in secrets/: {p.relative_to(root).as_posix()}")

if errors:
  print("Validation baseline: ECHEC")
  for e in errors:
    print("-", e)
  sys.exit(1)

print("Validation baseline: OK")
