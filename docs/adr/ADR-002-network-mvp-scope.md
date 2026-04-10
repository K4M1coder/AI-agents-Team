# ADR-002: Network MVP Scope

- Statut: Accepted
- Date: 2026-04-10

Contexte:
M1 doit livrer un socle reseau validable sans credentials fournisseurs.

Decision:
- Module Terraform network agnostique (CIDR, subnets, tags)
- tfvars dev/preprod
- Playbook Ansible bootstrap
- Policy OPA/Rego baseline
- SLO/alertes et runbook de deploiement

Consequences:
- Validation CI possible sans acces infra
- Passage M1.1 pour integration fournisseurs (OPNsense/NSX/etc.)
