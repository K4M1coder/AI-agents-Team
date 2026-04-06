# Security Scanning Tools Reference

## OpenSCAP

**Platforms:** RHEL, AlmaLinux, CentOS, Debian, Ubuntu

```bash
# Install
dnf install -y openscap-scanner scap-security-guide  # RHEL/AlmaLinux
apt install -y libopenscap8 ssg-debian ssg-ubuntu     # Debian/Ubuntu

# List available profiles
oscap info /usr/share/xml/scap/ssg/content/ssg-almalinux9-ds.xml

# Evaluate CIS Level 1 Server
oscap xccdf eval \
  --profile cis_server_l1 \
  --results results.xml \
  --report report.html \
  /usr/share/xml/scap/ssg/content/ssg-almalinux9-ds.xml

# Generate remediation script (Ansible)
oscap xccdf generate fix \
  --fix-type ansible \
  --profile cis_server_l1 \
  --output remediation.yml \
  results.xml

# Generate remediation script (Bash)
oscap xccdf generate fix \
  --fix-type bash \
  --profile cis_server_l1 \
  --output remediation.sh \
  results.xml
```

**Key profiles:**

| Profile ID | Description |
| ----------- | ------------- |
| `cis_server_l1` | CIS Level 1 Server |
| `cis_server_l2` | CIS Level 2 Server |
| `cis_workstation_l1` | CIS Level 1 Workstation |
| `anssi_bp28_minimal` | ANSSI-BP-028 Minimal |
| `anssi_bp28_intermediary` | ANSSI-BP-028 Intermediary |
| `anssi_bp28_enhanced` | ANSSI-BP-028 Enhanced |
| `stig` | DISA STIG |

## Lynis

**Platforms:** All Linux, macOS, BSD

```bash
# Install
dnf install -y lynis       # RHEL via EPEL
apt install -y lynis       # Debian/Ubuntu

# Or from Git
git clone https://github.com/CISOfy/lynis.git
cd lynis && ./lynis audit system

# Full system audit
lynis audit system --quiet --no-colors

# Audit specific category
lynis audit system --tests-from-group "ssh"
lynis audit system --tests-from-group "firewalls"

# Custom profile
lynis audit system --profile custom.prf

# Pentest mode (more aggressive checks)
lynis audit system --pentest
```

**Output:**

- Hardening index: 0-100 score
- Warnings: Immediate attention required
- Suggestions: Recommended improvements
- Log: `/var/log/lynis.log`
- Report: `/var/log/lynis-report.dat`

## Trivy (Infrastructure Scanning)

```bash
# Scan filesystem for misconfigurations
trivy config /etc/ --severity HIGH,CRITICAL

# Scan Ansible playbooks
trivy config playbooks/ --policy-bundle-repository ghcr.io/aquasecurity/trivy-policies

# Scan Terraform
trivy config terraform/

# Scan Kubernetes manifests
trivy config k8s/
```

## InSpec (Compliance as Code)

```bash
# Install
gem install inspec

# Run CIS profile
inspec exec https://github.com/dev-sec/linux-baseline

# Run against remote target
inspec exec linux-baseline -t ssh://user@host -i key.pem

# Custom profile
inspec init profile my-baseline
```

**InSpec control example:**

```ruby
control 'ssh-01' do
  impact 1.0
  title 'Ensure SSH root login is disabled'
  describe sshd_config do
    its('PermitRootLogin') { should eq 'no' }
  end
end
```

## AIDE (File Integrity Monitoring)

```bash
# Install
dnf install -y aide  # RHEL/AlmaLinux

# Initialize database
aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# Check for changes
aide --check

# Update database after legitimate changes
aide --update

# Cron job for daily checks
echo "0 5 * * * root /usr/sbin/aide --check | mail -s 'AIDE Report' admin@example.com" > /etc/cron.d/aide
```

## Windows: Microsoft Baseline Security Analyzer

```powershell
# Download and apply Security Compliance Toolkit
# https://www.microsoft.com/en-us/download/details.aspx?id=55319

# GPO analysis with LGPO
LGPO.exe /parse /m machine-policy.pol

# PowerShell DSC for compliance
Install-Module -Name SecurityPolicyDsc
Install-Module -Name AuditPolicyDsc

# Test compliance
Test-DscConfiguration -Detailed
```

## Scanning Pipeline Integration

```yaml
# GitHub Actions — scheduled compliance scan
name: Security Compliance
on:
  schedule:
    - cron: '0 6 * * 1'  # Weekly Monday 6am
  workflow_dispatch:

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Trivy config scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: config
          scan-ref: .
          severity: HIGH,CRITICAL
          exit-code: 1

      - name: InSpec baseline
        run: |
          gem install inspec
          inspec exec https://github.com/dev-sec/linux-baseline \
            --reporter cli json:inspec-results.json

      - name: Upload results
        uses: actions/upload-artifact@v4
        with:
          name: security-scan-results
          path: inspec-results.json
```text
