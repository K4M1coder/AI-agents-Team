# Audit: Compétences Agents & Branchements Existants

## Légende
- **Rôle**: manager / project-manager / team-lead / executant / maintainer
- **Skills liés**: skills déclarés dans le frontmatter `contextualSkills` ou dans le corps de l'agent

---

## Agents de Management (6)

### agent-manager (manager)
**Compétences**: Multi-project arbitration, chain-of-command management, final decision-making, top-level orchestration, priority arbitration
**Skills liés**: multi-agent-manager, terraform-provisioning, incident-management, documentation-ops

### agent-project-manager-delivery (project-manager)
**Compétences**: End-to-end delivery planning, cross-team coordination, release execution, dependency tracking, deployment management
**Skills liés**: multi-agent-manager, ai-integration, mlops-lifecycle, model-training, model-inference, backend-development, frontend-development, database-engineering

### agent-project-manager-governance (project-manager)
**Compétences**: Organizational refactors, governance rollouts, documentation governance, onboarding systems, structural maintenance
**Skills liés**: multi-agent-manager, documentation-ops, ai-enablement, research-intelligence, ai-research-watch, incident-management

### agent-project-manager-platform (project-manager)
**Compétences**: Infrastructure programs, cloud/datacenter rollouts, platform migrations, hosting changes, operational readiness
**Skills liés**: multi-agent-manager, terraform-provisioning, kubernetes-orchestration, security-hardening, secrets-management, observability-stack, packer-imaging

### agent-lead-ai-core (team-lead)
**Compétences**: AI/ML delivery decomposition, research/data/training/inference/MLOps/audio/safety management, model-family selection, training-vs-inference tradeoffs, data requirements, safety gates
**Skills liés**: ai-integration, model-training, model-inference, dataset-engineering, ai-alignment, audio-speech-engineering, mlops-lifecycle

### agent-lead-governance (team-lead)
**Compétences**: Governance rollout structure, documentation strategy, onboarding direction, intelligence distribution, ownership clarity
**Skills liés**: documentation-ops, ai-enablement, research-intelligence, ai-research-watch, incident-management

### agent-lead-infra-ops (team-lead)
**Compétences**: Platform selection, cloud-vs-on-prem tradeoffs, GPU hosting, IaC boundaries, virtualization choices, hybrid topology, network decisions
**Skills liés**: terraform-provisioning, gpu-compute, packer-imaging, ansible-automation, kubernetes-orchestration, docker-containerization

### agent-lead-security (team-lead)
**Compétences**: Risk posture assessment, hardening strategy, compliance direction, secrets governance, exposure review, security gate decisions
**Skills liés**: security-hardening, secrets-management, supply-chain-security, incident-management, ai-alignment

### agent-lead-site-reliability (team-lead)
**Compétences**: SLO strategy, production-readiness criteria, incident-management structure, observability scope, release guardrails, operational maturity
**Skills liés**: incident-management, observability-stack, ci-cd-pipeline, kubernetes-orchestration

### agent-lead-software-engineering (team-lead)
**Compétences**: Language/framework selection, architecture patterns (DDD/CQRS/event-driven), database engine selection, test strategy, build tooling, development workflow
**Skills liés**: backend-development, frontend-development, database-engineering, testing-strategy, debugging-profiling, code-review-practice, docker-containerization, ci-cd-pipeline

---

## Agents Executants AI/ML (10)

### executant-ai-architect (executant)
**Compétences**: Multi-model pipelines, API design (REST/gRPC/WebSocket/GraphQL), scaling patterns, GPU-aware autoscaling, RAG, vector stores, semantic caching, latency optimization, speculative decoding, microservice orchestration, service mesh, event-driven (Kafka/NATS), feature/embedding stores, security (model isolation, prompt injection defense, rate limiting), open-weight routing
**Skills liés**: ai-integration, model-architectures, model-inference, gpu-compute, cutting-edge-architectures

### executant-ai-enablement (executant)
**Compétences**: Training programs, curricula, tutorials, Jupyter, configuration guides, open-weight guidance, prompt engineering, fine-tuning guidance, SDK design (Python/JS/Rust), API documentation (OpenAPI/Swagger), integration patterns, React/Vue components, mobile SDKs, CLI tools, onboarding flow design, user journey mapping
**Skills liés**: ai-enablement, ai-integration, documentation-ops

### executant-ai-safety (executant)
**Compétences**: RLHF, DPO, PPO, Constitutional AI, RLAIF, rejection sampling, red teaming, adversarial prompt testing, bias detection, toxicity measurement, hallucination detection, robustness testing, guardrails (NeMo/Guardrails AI/LangChain), threat modeling
**Skills liés**: ai-alignment, model-training, audio-speech-engineering

### executant-ai-systems-engineer (executant)
**Compétences**: Rust/Candle, CUDA C++, Triton kernels, PyTorch custom ops, FFI/PyO3/maturin, CUDA bindings, safetensors, tokenizers, linear algebra perf, precision strategy (fp32/fp16/bf16/fp8), attention kernels, memory optimization, parallel execution, tokio async, WebSocket audio servers, SIMD, ring buffers, lock-free queues, binary protocols
**Skills liés**: ai-integration, model-inference, audio-speech-engineering, ci-cd-pipeline, gpu-compute, cutting-edge-architectures

### executant-audio-speech-specialist (executant)
**Compétences**: Neural audio codecs (Mimi/EnCodec/DAC/SoundStream/RVQ), speech metrics (MOS/PESQ/STOI/WER/CER), WebSocket streaming, real-time pipelines, audio I/O, resampling, buffering, acoustic features (Mel/MFCC/F0/VAD/diarization), codec integration, streaming protocols
**Skills liés**: audio-speech-engineering, dataset-engineering, model-training, model-inference

### executant-data-engineer (executant)
**Compétences**: Data acquisition (scraping/API/public datasets), audio/speech processing, text/NLP processing (tokenization/dedup/lang detection), data cleaning, labeling (LabelStudio/active learning), augmentation, synthetic data, versioning (DVC/HF Datasets/webdataset), data quality (Great Expectations)
**Skills liés**: dataset-engineering, model-training, audio-speech-engineering, ai-alignment

### executant-inference-engineer (executant)
**Compétences**: Quantization (int8/GPTQ/AWQ/GGUF/TurboQuant), serving (vLLM/TGI/Triton), streaming, batching, KV cache (MLA/TurboQuant), MoE inference, ONNX/TensorRT, MLX, Rust/Candle, edge/mobile deployment
**Skills liés**: model-inference, gpu-compute, ai-integration, cutting-edge-architectures

### executant-ml-engineer (executant)
**Compétences**: PyTorch (nn.Module/autograd/mixed precision), distributed training (FSDP/DDP/DeepSpeed ZeRO), MoE training (DeepSpeed-MoE/Tutel), fine-tuning (LoRA/QLoRA), custom training loops, loss functions, optimization (AdamW/Lion), evaluation metrics, checkpointing, open-weight baseline selection
**Skills liés**: model-training, dataset-engineering, ai-alignment, cutting-edge-architectures

### executant-ml-researcher (executant)
**Compétences**: Architecture expertise (Transformers/CNN/RNN/Mamba/SSM/MoE/JEPA/world models), attention mechanisms (MHA/GQA/MLA/AttnRes), residual topologies (HC/mHC), diffusion/flow matching, neural codecs, paper analysis, benchmark comparison, SOTA tracking, open-weight landscape, JEPA variants
**Skills liés**: model-architectures, ai-research-watch, cutting-edge-architectures, research-intelligence

### executant-mlops-engineer (executant)
**Compétences**: Experiment tracking (W&B/MLflow/TensorBoard), model registry (HF Hub), ML CI/CD, data drift detection, feature stores (Feast/Tecton), pipeline orchestration (Airflow/Prefect/Kubeflow), containerization (Docker ML), reproducibility/versioning (DVC), open-weight release governance
**Skills liés**: mlops-lifecycle, ci-cd-pipeline, model-inference, supply-chain-security

### executant-research-intelligence (executant)
**Compétences**: Paper monitoring & triage, code/model release tracking (HF Hub/GitHub), security advisory processing (CVE/GHSA), supply chain risk assessment, model card red flags, competitive lab intelligence, adversarial ML threat intel, leak/trojan detection
**Skills liés**: research-intelligence, ai-research-watch, model-architectures

---

## Agents Executants Infra/Platform (8)

### executant-ci-cd-ops (executant)
**Compétences**: GitHub Actions, GitLab CI, Jenkins, Dagger, security gates (SAST/DAST/image scan/dependency scan), DORA metrics, trunk-based development, monorepo/polyrepo, artifact promotion, matrix builds, caching, ArgoCD GitOps, Helm, Kubernetes deployment, reusable workflows, OIDC
**Skills liés**: ci-cd-pipeline, supply-chain-security, docker-containerization, kubernetes-orchestration

### executant-cloud-ops (executant)
**Compétences**: Azure (VMs/AKS/Functions/VNet/NSGs/Entra ID), M365/Entra ID, AWS (EC2/ECS/EKS/Lambda/VPC/IAM), GCP (GCE/GKE/Cloud Run/IAM), FinOps, multi-cloud, Terraform modules, Bicep/CloudFormation, identity management
**Skills liés**: terraform-provisioning, kubernetes-orchestration, secrets-management, packer-imaging

### executant-gpu-infra (executant)
**Compétences**: GPU selection (A100/H100/L40S/MI300X/RTX/Apple Silicon), CUDA/ROCm/Metal, multi-GPU topology, NCCL/InfiniBand, expert parallelism sizing (MoE), cluster design, cloud GPU provisioning, hardware envelope sizing, cost optimization, memory estimation
**Skills liés**: gpu-compute, model-inference, model-training, cutting-edge-architectures

### executant-infra-architect (executant)
**Compétences**: IaC design (Terraform/Ansible/Packer), architecture decisions/ADRs, multi-platform (AWS/Azure/GCP/Proxmox/vCenter/XCP-ng), multi-OS, declarative vs imperative, anti-pattern detection, technology trade-offs, state management
**Skills liés**: terraform-provisioning, ansible-automation, packer-imaging, kubernetes-orchestration

### executant-network-ops (executant)
**Compétences**: Firewalls (nftables/iptables/UFW/Firewalld/OPNsense/pfSense), DNS/DHCP, VPN (WireGuard/OpenVPN/IPSec), VLAN, Kubernetes networking (CNI/NetworkPolicies/Ingress), load balancing (Nginx/HAProxy/Traefik), network diagnostics (tcpdump/Wireshark/eBPF)
**Skills liés**: terraform-provisioning, kubernetes-orchestration, security-hardening, incident-management

### executant-observability-ops (executant)
**Compétences**: Prometheus/Grafana/Loki/Tempo, OpenTelemetry, PromQL/LogQL, dashboard design (RED/USE), Alertmanager, SLI/SLO alerting (burn rate), VictoriaMetrics/Mimir, exporter config, Kubernetes observability, cost-aware monitoring
**Skills liés**: observability-stack, incident-management, kubernetes-orchestration

### executant-platform-ops (executant)
**Compétences**: Proxmox VE, VMware vCenter/ESXi, Vates/XCP-ng, Hyper-V, VM/LXC lifecycle, storage (ZFS/Ceph/NFS/iSCSI), cloud-init, Packer builds, HA/live migration, network config, backup automation
**Skills liés**: packer-imaging, ansible-automation, terraform-provisioning, kubernetes-orchestration

### executant-secrets-manager (executant)
**Compétences**: Vault/OpenBao, SOPS, Infisical/Bitwarden, PKI/CA, OIDC/workload identity, secret rotation, Kubernetes external-secrets-operator, .env auditing
**Skills liés**: secrets-management, security-hardening, ci-cd-pipeline

---

## Agents Executants Software & Ops (5)

### executant-code-reviewer (executant)
**Compétences**: Correctness/security/performance/design/readability review, OWASP Top 10, N+1 queries, SRP, anti-pattern detection, concurrency patterns, API design review, dependency graph health, backward compatibility, bounded context boundaries
**Skills liés**: code-review-practice, backend-development, frontend-development, database-engineering, testing-strategy, security-hardening

### executant-debug-engineer (executant)
**Compétences**: Debugging (Java/Python/TypeScript/Rust/C), profiling (CPU/memory/I/O/thread), root cause analysis, production troubleshooting, distributed tracing, system tools (strace/perf/eBPF/tcpdump/Wireshark), heap/core dumps, log correlation
**Skills liés**: debugging-profiling, backend-development, frontend-development, database-engineering, observability-stack

### executant-security-ops (executant)
**Compétences**: System hardening (CIS/ANSSI-BP-028), vulnerability scanning (Trivy/Grype/OpenSCAP), supply chain security (Cosign/SLSA/SBOM), secret detection (Gitleaks/TruffleHog), container security, Linux hardening (SELinux/AppArmor), OWASP/CVE/SAST/DAST, compliance (CIS/ANSSI/SOC2)
**Skills liés**: security-hardening, supply-chain-security, secrets-management, ai-alignment

### executant-software-engineer (executant)
**Compétences**: Backend (Java Spring Boot/Python FastAPI/TypeScript NestJS/Rust Axum/C), Frontend (React/Vue/Angular/Svelte), Databases (PostgreSQL/MongoDB/Qdrant/Neo4j/Elasticsearch/TimescaleDB), API design (REST/GraphQL/gRPC), architecture patterns (DDD/CQRS/event-driven), schema/migrations, query optimization
**Skills liés**: backend-development, frontend-development, database-engineering, docker-containerization, ci-cd-pipeline

### executant-sre-ops (executant)
**Compétences**: SLI/SLO/error budget, incident response, blameless postmortems, toil reduction, chaos engineering, capacity planning, Dickerson pyramid, DORA metrics, on-call runbooks
**Skills liés**: incident-management, observability-stack, ci-cd-pipeline

### executant-test-engineer (executant)
**Compétences**: Test frameworks (JUnit/pytest/Vitest/Jest/Rust cargo), unit/integration/e2e/contract testing, property-based testing, mutation testing, performance testing (k6/Gatling/Locust), test data factories, CI test orchestration, coverage analysis
**Skills liés**: testing-strategy, backend-development, frontend-development, database-engineering, ci-cd-pipeline

---

## Agent de Gouvernance (1)

### team-maintainer (maintainer)
**Compétences**: Repository governance, coverage audits, overlap detection, explicit branching maintenance, lifecycle management, boundary clarity, structural refactoring, role decomposition, ownership audit, domain separation
**Skills liés**: multi-agent-manager (aucun skill technique de domaine)

---

## Statistiques Existantes
- **37 agents** total
- **32 skills** existants
- **~175 branchements** skill→agent existants (comptage brut)
