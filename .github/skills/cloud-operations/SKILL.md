---
name: cloud-operations
description: "**WORKFLOW SKILL** — Provision and manage multi-cloud infrastructure on AWS, Azure, GCP, Microsoft 365, and Entra ID. USE FOR: Terraform cloud modules, Bicep/CloudFormation/CDK, identity management (EntraID/IAM/GCP IAM), cloud networking (VPC/VNet/NSG), FinOps cost optimization, managed services selection, shared responsibility model, cloud migrations, multi-cloud patterns. USE WHEN: provisioning cloud resources, managing cloud identity, optimizing cloud costs, or designing multi-cloud architecture."
argument-hint: "Describe the cloud task (e.g., 'Azure AKS with Entra ID RBAC and VNet integration')"
---

# Cloud Operations

Provision and manage multi-cloud infrastructure across AWS, Azure, GCP, Microsoft 365, and Entra ID.

## When to Use

- Provisioning cloud compute, networking, or storage resources
- Managing cloud identity (Entra ID, IAM, GCP IAM)
- Designing multi-cloud or hybrid architectures
- Performing FinOps cost optimization
- Writing Terraform modules for cloud providers
- Migrating workloads to/between cloud providers
- Configuring managed services (databases, queues, CDN)

## Procedure

### 1. Identify Cloud Context

Determine:
- **Provider(s)**: AWS, Azure, GCP, or multi-cloud
- **Service model**: IaaS, PaaS, SaaS
- **Identity model**: Entra ID (Azure/M365), IAM (AWS), GCP IAM
- **Compliance**: Data residency, sovereignty, regulatory requirements
- **Budget**: Reserved capacity, spot/preemptible, on-demand mix

### 2. Design Networking

#### AWS VPC
```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "main-vpc", Environment = var.environment }
}

resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = var.azs[count.index]
}
```

#### Azure VNet
```hcl
resource "azurerm_virtual_network" "main" {
  name                = "main-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "workloads" {
  name                 = "workloads"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}
```

### 3. Configure Identity

#### Entra ID / Azure AD
```hcl
# Terraform with azuread provider
resource "azuread_application" "app" {
  display_name = "my-app"
  sign_in_audience = "AzureADMyOrg"
}

resource "azuread_service_principal" "app" {
  client_id = azuread_application.app.client_id
}

# Workload Identity Federation (no secrets)
resource "azuread_application_federated_identity_credential" "github" {
  application_id = azuread_application.app.id
  display_name   = "github-actions"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:org/repo:ref:refs/heads/main"
}
```

#### AWS IAM
```hcl
resource "aws_iam_role" "app" {
  name = "app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}
```

### 4. Provision Compute

**Decision matrix:**

| Workload Type | AWS | Azure | GCP |
| --------------- | ----- | ------- | ----- |
| VMs (IaaS) | EC2 | Virtual Machines | Compute Engine |
| Managed K8s | EKS | AKS | GKE |
| Serverless containers | Fargate/ECS | Container Apps | Cloud Run |
| Functions | Lambda | Functions | Cloud Functions |
| Batch / HPC | AWS Batch | Azure Batch | Cloud Batch |
| GPU workloads | P4d/P5 (NVIDIA) | NC/ND series | A2/A3 (NVIDIA) |

### 5. Apply FinOps

**Cost optimization checklist:**
- [ ] Right-size instances (analyze CPU/memory utilization over 14 days)
- [ ] Use reserved capacity for stable workloads (1y/3y commitments)
- [ ] Use spot/preemptible for fault-tolerant workloads (CI, batch, training)
- [ ] Enforce tagging policy (`Environment`, `Owner`, `CostCenter`, `ManagedBy`)
- [ ] Set budget alerts per project/subscription/account
- [ ] Detect idle resources (unattached disks, stopped VMs, unused IPs)
- [ ] Use cloud-native storage tiers (S3 IA, Blob Cool/Archive, Nearline/Coldline)
- [ ] Schedule non-prod environments shutdown (nights/weekends)

```bash
# AWS — cost explorer CLI
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE
```

### 6. Configure Monitoring

| Provider | Metrics | Logs | Tracing | Alerts |
| ---------- | --------- | ------ | --------- | ------- |
| AWS | CloudWatch Metrics | CloudWatch Logs | X-Ray | CloudWatch Alarms |
| Azure | Azure Monitor | Log Analytics | Application Insights | Azure Alerts |
| GCP | Cloud Monitoring | Cloud Logging | Cloud Trace | Alerting Policies |

### 7. Shared Responsibility Model

| Layer | Provider | Customer |
| ------- | ---------- | ---------- |
| Physical infrastructure | ✓ | — |
| Hypervisor / Host OS | ✓ | — |
| Network controls | Shared | Shared |
| Guest OS patching | — (IaaS) | ✓ |
| Application security | — | ✓ |
| Identity & access | Shared | ✓ |
| Data encryption | Provides tools | Configures & manages |

## Multi-Cloud Patterns

- **Active-Passive**: Primary in one cloud, DR in another
- **Best-of-Breed**: Use each cloud's strengths (e.g., AWS for data, Azure for identity)
- **Abstraction Layer**: Terraform + Kubernetes for cloud portability
- **Data Gravity**: Keep compute near data; minimize cross-cloud data transfer
- **Identity Federation**: OIDC/SAML between clouds, Entra ID as IdP

## Anti-Patterns

- Managing resources via console instead of IaC
- Using root/admin accounts for automation
- Flat networking without subnets or security groups
- Hardcoded credentials in Terraform or scripts
- No budget alerts (surprise bills)
- Ignoring egress costs in multi-cloud designs
- Over-provisioning without right-sizing analysis
- Missing tagging (lost cost attribution)

## Agent Integration

- **`executant-infra-architect`**: Cloud architecture review and multi-cloud design decisions
- **`executant-network-ops`**: Cloud networking (VPC peering, Transit Gateway, VPN)
- **`executant-security-ops`**: Cloud security posture (IAM review, NSG audit, encryption)
- **`executant-secrets-manager`**: Cloud KMS, Vault integration, workload identity
- **`executant-gpu-infra`**: Cloud GPU provisioning (instance selection, spot/reserved)
- **`executant-platform-ops`**: Hybrid cloud patterns, on-prem ↔ cloud connectivity
