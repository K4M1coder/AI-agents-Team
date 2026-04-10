# Network MVP Deploy Runbook

1. Verifier baseline M0:
   - python [validate_baseline.py](http://_vscodecontentref_/0)
2. Valider Terraform module:
   - terraform -chdir=terraform/modules/network fmt -check -recursive
   - terraform -chdir=terraform/modules/network init -backend=false
   - terraform -chdir=terraform/modules/network validate
3. Valider Ansible:
   - ansible-lint ansible/playbooks/bootstrap.yml
4. Valider policies (optionnel si conftest installe):
   - conftest test sample-network-input.json -p policies/network
5. Rollback:
   - revert commit M1 skeleton
