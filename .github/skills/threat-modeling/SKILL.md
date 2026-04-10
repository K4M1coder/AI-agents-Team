---
name: threat-modeling
description: "**WORKFLOW SKILL** — Analyze attack surfaces and model threats at design time before deployment. USE FOR: STRIDE analysis, DREAD scoring, attack tree construction, data flow diagram (DFD) creation, trust boundary mapping, threat enumeration, mitigation planning, architecture security review, AI/ML system threat modeling. USE WHEN: designing a new system or service, reviewing infrastructure architecture for security risks, onboarding a new component, or preparing for a security audit or compliance review."
argument-hint: "Describe the system to model (e.g., 'API gateway + LLM inference service exposed to the internet')"
---

# Threat Modeling

Systematically identify, enumerate, and prioritize security threats at design time so mitigations are built in rather than bolted on.

## When to Use

- Designing a new service, API, or infrastructure component
- Reviewing an existing architecture before a major change or release
- Preparing for a security audit, compliance review, or penetration test
- Evaluating a third-party component or integration
- Modeling AI/ML inference endpoints, model registries, or training pipelines

## Boundary with Adjacent Skills

| This skill | Adjacent skills |
| ---------- | --------------- |
| Design-time threat identification and mitigation planning | `security-hardening` — implements the OS-level mitigations identified here |
| Attack surface documentation | `vulnerability-management` — tracks post-deployment CVEs and patches |
| Trust model for artifacts and pipelines | `supply-chain-security` — implements artifact signing and provenance |

See `skills/_shared/references/security-posture.md` for the full security skill decision tree.

## Procedure

### Phase 1: Define Scope

1. **Name the system** — What component or interaction are you modeling?
2. **Identify stakeholders** — Who interacts with the system (users, services, admins, attackers)?
3. **Define the trust boundary** — Where does trust change? (e.g., internet → DMZ → internal service → DB)
4. **List assets** — What data, credentials, or capabilities does the system hold or process?

### Phase 2: Build a Data Flow Diagram (DFD)

Draw a Level-0 and Level-1 DFD with these elements:

| Symbol | Meaning | Example |
| ------ | ------- | ------- |
| Rectangle | External entity (outside trust boundary) | User, third-party API |
| Circle / rounded box | Process (transforms data) | API service, model inference |
| Open rectangle | Data store | PostgreSQL, S3 bucket, Redis |
| Arrow | Data flow (label with data type) | JWT token, model output, file upload |
| Dashed line | Trust boundary | Internet / internal network |

```text
[User] --HTTP/S--> [API Gateway] --gRPC--> [Inference Service] --read/write--> [Model Store]
                        |
                   Trust boundary
                        |
                   [Auth Service]
```

### Phase 3: Apply STRIDE

For each process, data flow, and data store in the DFD, enumerate threats using STRIDE:

| Threat category | Definition | Example |
| --------------- | ---------- | ------- |
| **S**poofing | Attacker impersonates a user or service | Stolen JWT, forged source IP |
| **T**ampering | Attacker modifies data or code | Model weight poisoning, config injection |
| **R**epudiation | Actions cannot be traced to an actor | Missing audit logs, anonymous model calls |
| **I**nformation Disclosure | Data leaks to unauthorized parties | Model memorization, verbose error messages |
| **D**enial of Service | Service becomes unavailable | Unbounded prompt length, GPU OOM |
| **E**levation of Privilege | Attacker gains higher permissions | SSRF to metadata API, container escape |

For each threat found, produce a row:

```markdown
| Threat ID | Category | Target | Description | Severity | Mitigation |
| T-001 | Spoofing | API Gateway | Stolen API key reused after expiry | High | Short key TTL + refresh token rotation |
```

### Phase 4: Score with DREAD

Rate each threat to prioritize mitigation:

| Factor | Score 1 | Score 5 | Score 10 |
| ------ | ------- | ------- | -------- |
| **D**amage | Minimal impact | Data loss for one user | Full system compromise |
| **R**eproducibility | Rare, specific conditions | Occasionally reproducible | Trivially reproducible |
| **E**xploitability | Expert attacker required | Skilled attacker | Script kiddie / automated |
| **A**ffected users | Admin only | Subset of users | All users |
| **D**iscoverability | Internal knowledge | Can be inferred | Visible in public docs/headers |

**DREAD Score** = (D + R + E + A + D) / 5 → 0–10

| Score | Priority |
| ----- | -------- |
| 8–10 | Critical — block release until mitigated |
| 6–7 | High — mitigate before production |
| 4–5 | Medium — schedule in next sprint |
| 1–3 | Low — accept or defer |

### Phase 5: Define Mitigations

For each threat above Medium priority, define:

1. **Mitigation type**: Prevent / Detect / Limit impact / Transfer
2. **Control**: Specific technical or policy control
3. **Owner**: Which team implements it
4. **Skill to use**: Reference the right implementation skill

| Threat ID | Mitigation | Control | Owner | Skill |
| --------- | ---------- | ------- | ----- | ----- |
| T-001 | Prevent | Short-lived API keys + rotation | ops | `secrets-management` |
| T-002 | Detect | Structured audit log per inference call | platform | `observability-stack` |
| T-003 | Limit impact | NetworkPolicy restricting egress from inference pod | platform | `kubernetes-orchestration` |

### Phase 6: AI/ML Specific Threats

When the system includes ML inference, training pipelines, or model registries, extend the STRIDE analysis with these categories:

| AI/ML Threat | Description | Mitigation |
| ------------ | ----------- | ---------- |
| **Model poisoning** | Training data or checkpoint manipulation | Data provenance, checkpoint signing (`supply-chain-security`) |
| **Prompt injection** | Attacker hijacks model via crafted input | Input validation, sandboxed execution (`ai-alignment`) |
| **Model theft** | Model weights extracted via API | Rate limiting, watermarking, output filtering |
| **Membership inference** | Attacker infers training data from outputs | Differential privacy, output rounding |
| **Model inversion** | Attacker reconstructs training samples | Limit output detail, add noise |
| **Supply chain** | Malicious dependency in ML stack | `vulnerability-management` for PyTorch/vLLM CVEs |

### Phase 7: Produce the Threat Model Document

```markdown
## Threat Model — <system-name> — <YYYY-MM-DD>

### Scope
<system description and trust boundary>

### Assets
<list of assets>

### DFD
<diagram or link>

### Threat Register
| ID | Category | Target | Description | DREAD | Priority | Mitigation | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |

### Accepted Risks
| ID | Rationale | Owner | Review Date |
| --- | --- | --- | --- |
```

Store in `.github/memory/static/` or the project's security documentation.

## Anti-Patterns

| Anti-Pattern | Why It Fails | Do This Instead |
| ------------ | ------------ | --------------- |
| Threat modeling only at launch | Every change introduces new attack surface | Run lightweight Phase 1–3 for every significant architectural change |
| Only enumerating known CVEs | CVEs are known threats; threat modeling finds unknown ones | Use STRIDE to enumerate, not just patch lists |
| Skipping DFD | Threats without a system map are incomplete | Always draw the DFD first, even a rough one |
| Treating DREAD as absolute | Scores depend on context and assumptions | Use DREAD for *relative* prioritization, not absolute truth |
| No AI/ML threat categories | ML systems have unique attack surfaces | Always extend with Phase 6 when ML is involved |
| Threat model never updated | System evolves but threat model stays static | Re-run threat modeling on every major change |

## Agent Integration

| Agent | Relationship | Usage |
| ----- | ------------ | ----- |
| `executant-security-ops` | **Primary consumer** | Full threat modeling lifecycle for infrastructure and software |
| `executant-infra-architect` | **Contextual** | Embeds threat model outputs into architecture ADRs |
| `executant-ai-architect` | **Contextual** | AI/ML system threat modeling, prompt injection, model theft |
| `agent-lead-security` | **Contextual** | Escalation for critical threats, risk acceptance decisions |
| `executant-ai-safety` | **Contextual** | AI/ML-specific threats overlapping with alignment and safety |
