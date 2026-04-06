# Repository Governance Convention

Shared governance for the agent team, the skill collection, the shared references layer, and their explicit branchings.

## How to Use This Convention

- Use this file when adding, splitting, merging, renaming, or deprecating an agent, a skill, or a shared reference.
- Use it when deciding whether knowledge should be linked explicitly from an agent or skill, exposed as a shared reference, or left as runtime-only discovery.
- Treat this file as the structural policy layer for the repo.

## Boundaries

- This file defines structure and branching policy; it does not replace domain expertise.
- Domain-specific content remains owned by the relevant agents, skills, and shared references.
- Documentation publishing and docs-as-code infrastructure remain owned by `executant-docs-ops`.
- Top-level user-task management remains owned by `agent-manager`.

## Domain Specialization Boundary

- LLM and AI system specialization belongs to `agent-lead-ai-core` and its experts.
- Platform, security, reliability, governance, documentation, and structural-maintenance roles stay focused on their own domains by default.
- Non-AI roles should reference AI-specific knowledge only when AI constraints materially affect their own surface, such as hosting, compliance, exposure, observability, or enablement.
- Do not make AI or model-specific routing the default framing for roles outside the AI team.

## Chain of Command

The organization uses an explicit hierarchy:

```text
manager -> project manager -> team lead -> expert
```

- `agent-manager` is the manager.
- Project managers distribute work to team leads.
- Team leads decompose work into task-level execution for experts.
- Questions move upward only through the direct superior of the current layer.
- `team-maintainer` is a manager-only expert and may be called only by `agent-manager`.

## Governance Model

| Surface | Primary Owner | Purpose |
| ------- | ------------- | ------- |
| Agent roster | `team-maintainer` | Maintain coverage, handoffs, and structural coherence |
| Skill collection | `team-maintainer` | Maintain scope clarity, coverage, and branching needs |
| Shared references | `team-maintainer` | Maintain discoverable routing layers and boundaries |
| Governance documents | `executant-docs-ops` | Keep governance artifacts readable, reviewable, and publishable |
| User-task routing | `agent-manager` | Direct project managers and arbitrate work across projects |

## Branching Statuses

| Status | Meaning | Use When | Typical Location |
| ------ | ------- | -------- | ---------------- |
| `explicitly-branched` | The repo guarantees that a role or workflow points directly to the needed knowledge | The knowledge is critical to the role, repeatedly needed, or too important to leave implicit | Agent or skill file |
| `discoverable-shared-reference` | The knowledge is stable, cross-cutting, and reusable through a shared entry point | Multiple agents or skills need the same routing layer, matrix, or selection guide | `skills/_shared/references/` |
| `runtime-optional` | The repo does not guarantee a static branch; the knowledge may still be discovered dynamically during execution | The knowledge is opportunistic, narrow, volatile, or not central to the role definition | No mandatory repo-level branch |

## Reference Skills Convention

Management and execution agents must declare a dedicated `## Reference Skills` section as part of their durable routing contract.

### Required Structure

Each agent-level `Reference Skills` section should contain exactly these three subsections:

- `### Primary Skills`
- `### Contextual Skills`
- `### Shared References`

### Meaning

- `Primary Skills` are the default workflow skills the role is expected to rely on repeatedly and directly.
- `Contextual Skills` are optional or situational workflow skills used only when the task shape requires them.
- `Shared References` are stable cross-cutting reference entry points used for routing, selection, or domain framing across multiple roles.

### Scope Rules

- Management agents should list routing and decomposition skills first, then domain-shaping skills relevant to their layer.
- Team leads should list the skills that support lead-level synthesis and specialist dispatch for their team scope.
- Experts should list the workflow skills they use directly for execution, review, or specialist analysis.
- Shared references should point only to durable, reusable routing references rather than volatile task notes.
- Non-AI roles should keep AI- or model-specific skills and references contextual rather than primary, unless AI specialization is part of that role's core remit.

### Hygiene Rules

- Every agent must declare at least one `Primary Skill`.
- Skill and reference paths must point to existing repository content.
- Rename, split, merge, and deprecation changes must update `Reference Skills` sections in the same change.
- Structural audits should verify that `Reference Skills` remains aligned with agent scope, hierarchy, and explicit branching.

### Recommended Placement

- Prefer placing `## Reference Skills` after methodology or common pipelines and before `## Coordinates With`.
- If a file does not have a `## Coordinates With` section, place it before `## Output Format`.

## Decision Rule

Classify new knowledge in this order:

1. **Is it critical to a role or recurring workflow?**
   - If yes, make it `explicitly-branched` from the agent or skill that depends on it.
2. **Is it stable, reusable, and shared across multiple domains?**
   - If yes, create or extend a `discoverable-shared-reference`.
3. **Is it context-specific, optional, or likely to churn quickly?**
   - If yes, leave it `runtime-optional` unless repeated usage proves otherwise.

## Shared Reference Pattern

Shared references should follow the same operating pattern:

- `How to Use This Reference`
- `Boundaries`
- a routing matrix, file map, or decision table
- explicit cross-references to adjacent shared references or specialist skills when needed

Examples already following this pattern:

- `skills/_shared/references/environments.md`

Domain-specific examples:

- `skills/_shared/references/llm-landscape.md`
- `skills/_shared/references/ai-stack.md`

## Change Checklist

When introducing or changing a structural element, check the following:

1. **Coverage** — Does an existing agent, skill, or reference already cover the need?
2. **Boundary** — Is the proposed scope clearly distinct from neighboring roles or references?
3. **Branching** — Which roles need explicit links to this knowledge?
4. **Handoffs** — Do coordination tables or routing instructions need updates?
5. **Lifecycle** — Is this an addition, split, merge, rename, or deprecation?
6. **Escalation** — Does every affected role have a clear direct superior?
7. **Verification** — Can a maintainer audit the result without guessing intent?

## Lifecycle Rules

### Add

- Add a new agent only when the responsibility is durable, non-trivial, and not already cleanly owned.
- Add a new skill only when the workflow is reusable and sufficiently distinct from existing skills.
- Add a new shared reference only when the information is cross-cutting and repeatedly needed by multiple roles.

### Merge or Deprecate

- Merge when two agents, skills, or references overlap substantially and differ only by wording or historical drift.
- Deprecate when a role is no longer durable, when a shared reference no longer acts as a routing layer, or when explicit branches are no longer justified.
- Prefer redirection and boundary updates over silent removal.

### Rename

- Rename only when the new name improves scope clarity.
- Update all explicit branches, handoff tables, and routing notes in the same change.

## Review Cadence

| Surface | Minimum Review Cadence |
| ------- | ---------------------- |
| Agent roster and handoffs | On every structural change and quarterly audit |
| Skill scope and branching | On every structural change and quarterly audit |
| Shared references | On every material expansion and semi-annual audit |
| Governance convention | On policy change and semi-annual audit |

## Operating Procedure

1. Inventory the affected agents, skills, references, and branches.
2. Classify the knowledge using the three branching statuses.
3. Map the impact across the hierarchy: manager, project manager, team lead, expert.
4. Apply the smallest structural change that resolves the gap.
5. Update handoffs, explicit routing, and direct-superior escalation where required.
6. Verify that responsibilities remain distinct and auditable.

## Coordinates With

| Role | Coordination |
| ---- | ------------ |
| `team-maintainer` | Owns structural maintenance and branching decisions |
| `executant-docs-ops` | Maintains the governance artifacts as documentation |
| `agent-project-manager-governance` | Manages governance programs excluding manager-only structural maintenance |
| `agent-manager` | Directs project managers, owns manager-only access to `team-maintainer`, and arbitrates team-structure or coverage changes |
