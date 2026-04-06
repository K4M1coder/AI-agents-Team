# Container Security Scanning Reference

## Trivy

### Image Scanning

```bash
# Scan image for vulnerabilities (HIGH + CRITICAL only)
trivy image --severity HIGH,CRITICAL myimage:latest

# Scan with SBOM output
trivy image --format spdx-json -o sbom.json myimage:latest

# Scan and fail CI if vulnerabilities found
trivy image --exit-code 1 --severity CRITICAL myimage:latest

# Ignore unfixed vulnerabilities
trivy image --ignore-unfixed myimage:latest

# Scan specific image from registry
trivy image registry.example.com/app:v1.2.3
```

### Configuration Scanning

```bash
# Scan Dockerfile for misconfigurations
trivy config Dockerfile

# Scan docker-compose.yml
trivy config docker-compose.yml

# Scan Kubernetes manifests
trivy config k8s/

# Scan Terraform configs
trivy config terraform/
```

### Filesystem Scanning

```bash
# Scan project dependencies (requirements.txt, package-lock.json, etc.)
trivy fs --scanners vuln,secret .

# Scan for exposed secrets
trivy fs --scanners secret .
```

### Trivy in CI Pipeline

```yaml
# GitHub Actions
- name: Trivy image scan
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ${{ env.IMAGE }}
    format: sarif
    output: trivy-results.sarif
    severity: CRITICAL,HIGH
    exit-code: 1

- name: Upload Trivy results
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: trivy-results.sarif
```

## Grype

```bash
# Scan image
grype myimage:latest

# Fail on HIGH+
grype myimage:latest --fail-on high

# Output as JSON
grype myimage:latest -o json > grype-results.json

# Scan SBOM
grype sbom:./sbom.json
```

## Docker Scout (Docker Desktop)

```bash
# Quick vulnerability overview
docker scout quickview myimage:latest

# Detailed CVE listing
docker scout cves myimage:latest

# Compare with previous version
docker scout compare myimage:latest --to myimage:previous

# Recommendations for base image updates
docker scout recommendations myimage:latest
```

## Scanning Strategy

| Stage | Tool | What | Fail Condition |
| ------- | ------ | ------ | ---------------- |
| Pre-build | `trivy config` | Dockerfile misconfig | Any HIGH+ |
| Pre-build | `trivy fs` | Dependency vulns + secrets | CRITICAL unfixed |
| Post-build | `trivy image` | Image vulns | CRITICAL unfixed |
| Post-build | `grype` | Second opinion scan | HIGH unfixed |
| Registry | `trivy image` (scheduled) | Drift/new CVEs | Alert on CRITICAL |

## Ignoring Known False Positives

### .trivyignore

```text
# CVE-YYYY-NNNNN: False positive — not reachable in our code
CVE-2024-12345

# Accepted risk — mitigated by network policy
CVE-2024-67890
```

### Grype .grype.yaml

```yaml
ignore:
  - vulnerability: CVE-2024-12345
    reason: "False positive — unused code path"
```text
