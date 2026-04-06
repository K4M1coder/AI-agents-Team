---
name: incident-management
description: "**WORKFLOW SKILL** — Handle incidents from detection to postmortem. USE FOR: incident response procedures, severity classification (SEV1-SEV4), on-call playbooks/runbooks, blameless postmortem authoring, incident communication templates, escalation paths, war room coordination, SLA/SLO breach handling, chaos engineering experiments, toil identification and reduction, error budget policies. USE WHEN: responding to incidents, writing postmortems, creating runbooks, planning chaos experiments, defining on-call procedures."
argument-hint: "Describe the incident task (e.g., 'postmortem template for database failover incident')"
---

# Incident Management

Handle incidents from detection through resolution to learning, following SRE best practices.

## When to Use

- Defining incident response procedures
- Writing runbooks for known failure modes
- Authoring blameless postmortems
- Planning chaos engineering experiments
- Classifying and responding to active incidents
- Reducing toil in operational procedures

## Severity Classification

| Level | Impact | Response Time | Examples |
| ------- | -------- | -------------- | ---------- |
| SEV1 / P1 | Revenue-impacting, data loss, security breach | 15 min | Production down, data breach |
| SEV2 / P2 | Major feature broken, significant degradation | 30 min | API errors > 5%, payment failures |
| SEV3 / P3 | Minor feature broken, workaround available | 4 hours | Non-critical service degraded |
| SEV4 / P4 | Cosmetic, minimal impact | Next business day | UI glitch, log noise |

## Incident Response Procedure

### 1. Detect & Triage

```text
Alert fires → On-call acknowledges → Assess severity → Declare incident
```

- **Acknowledge** the alert within SLA (15 min for SEV1)
- **Assess** impact: users affected, revenue impact, data risk
- **Declare** severity level, open incident channel
- **Communicate**: "We are aware of [issue] affecting [scope]. Investigating."

### 2. Respond

```text
Diagnose → Mitigate → Resolve → Verify
```

**Diagnosis checklist:**
- [ ] What changed recently? (deployments, config changes, traffic spikes)
- [ ] Which service/component is the root cause?
- [ ] Is the issue in the application, infrastructure, or external dependency?
- [ ] Do dashboards/logs/traces show the failure mode?

**Mitigation options (fast to slow):**
1. Rollback the last deployment
2. Feature flag toggle
3. Scale resources (replicas, CPU, memory)
4. Redirect traffic (DNS, load balancer)
5. Restart affected services
6. Apply hotfix

### 3. Communicate

**Status update template:**
```text
**Incident: [Title]**
**Severity:** SEV[X]
**Status:** Investigating / Identified / Monitoring / Resolved
**Impact:** [Who is affected and how]
**Current action:** [What we're doing right now]
**Next update:** [Time]
```

### 4. Postmortem

**Trigger:** All SEV1 and SEV2 incidents get a postmortem within 48 hours.

**Blameless postmortem structure:**

```markdown
# Postmortem: [Title]

**Date:** YYYY-MM-DD
**Duration:** X hours Y minutes
**Severity:** SEV[X]
**Author:** [Name]
**Reviewers:** [Names]

## Summary
One paragraph describing what happened.

## Impact
- Users affected: X
- Duration: Xh Ym
- Revenue impact: $X (if applicable)
- SLO budget consumed: X%

## Timeline (UTC)
| Time | Event |
| ------ | ------- |
| HH:MM | Alert fired for [metric] |
| HH:MM | On-call acknowledged |
| HH:MM | Identified root cause |
| HH:MM | Mitigation applied |
| HH:MM | Service fully restored |

## Root Cause
What actually caused the incident (technical details).

## Contributing Factors
What conditions made this incident possible or worse.

## What Went Well
- Fast detection (alert fired within X minutes)
- Clear runbook available for this scenario

## What Could Be Improved
- Detection was delayed because [reason]
- Communication gap between teams

## Action Items
| Priority | Action | Owner | Due Date |
| ---------- | -------- | ------- | ---------- |
| P1 | Fix the root cause | @engineer | YYYY-MM-DD |
| P2 | Add monitoring for [gap] | @sre | YYYY-MM-DD |
| P2 | Update runbook with learnings | @oncall | YYYY-MM-DD |
| P3 | Improve alerting threshold | @sre | YYYY-MM-DD |

## Lessons Learned
Key takeaways for the team and organization.
```

## Runbook Template

```markdown
# Runbook: [Service/Scenario Name]

**Last updated:** YYYY-MM-DD
**Owner:** [Team]
**Services:** [List]

## Symptoms
- Alert: `AlertName` fires
- Users report: [description]
- Dashboard shows: [metric pattern]

## Diagnosis Steps
1. Check [dashboard URL]
2. Run: `kubectl get pods -n namespace`
3. Check logs: `kubectl logs -n namespace -l app=service --tail=100`
4. Verify dependencies: [list]

## Mitigation Steps

### Option A: Rollback (fastest)
```bash
helm rollback service -n namespace
```

### Option B: Scale up
```bash
kubectl scale deployment service -n namespace --replicas=5
```

### Option C: Restart
```bash
kubectl rollout restart deployment service -n namespace
```

## Escalation
- L1: On-call SRE — try mitigation options A/B/C
- L2: Service owner team — if root cause unclear after 30 min
- L3: Platform team — if infrastructure-level issue

## Related Incidents
- [Link to previous postmortem if any]
```

## Chaos Engineering

**Principles:**
1. Define steady state (SLIs in normal range)
2. Hypothesize what happens when X fails
3. Run smallest possible experiment
4. Observe and learn
5. Fix weaknesses found

**Starter experiments:**
| Experiment | Tool | What It Tests |
| ----------- | ------ | --------------- |
| Kill a pod | `kubectl delete pod` | Self-healing, HPA |
| Network latency | Chaos Mesh / Litmus | Timeout handling |
| CPU stress | stress-ng | Autoscaling, throttling |
| DNS failure | CoreDNS policy | Fallback, caching |
| Disk fill | dd / Chaos Mesh | Alerting, log rotation |

## Toil Reduction

**Identify toil:**
- Manual, repetitive, automatable
- Scales linearly with service growth
- No lasting value (just keeps things running)
- Interrupt-driven

**50% rule:** SRE teams should spend ≤50% of time on toil. If exceeded, prioritize automation.

## Agent Integration

- **`executant-sre-ops`** agent: SLI/SLO policies, error budget decisions, Dickerson pyramid
- **`executant-observability-ops`** agent: Dashboard and alerting configuration
- **`executant-docs-ops`** agent: Postmortem and runbook quality review
- **`executant-ci-cd-ops`**: Canary deployments, rollback automation
