---
name: skills-management
description: "**WORKFLOW SKILL** — Manage the SKILL.md lifecycle within the AI agent team: create, audit, update, deprecate, and branch skills to agents. USE FOR: creating new skills from conventions, auditing existing skill coverage, updating skill scope or description, deprecating obsolete skills, wiring explicit branchings to agents, validating YAML frontmatter and body structure. USE WHEN: adding a new reusable workflow, running a skills coverage audit, refactoring skill boundaries, updating Reference Skills sections in agent files, or checking compliance with GOVERNANCE.md branching policy."
argument-hint: "Describe the skill action (e.g., 'create a skill for X', 'audit skill coverage for infra team')"
---

# Skills Management

Manage the full lifecycle of SKILL.md files within this AI agent team — from creation through audit, update, deprecation, and explicit branching to agents.

## When to Use

- Creating a new skill from a recurring workflow or domain expertise
- Auditing existing skills for coverage gaps, overlap, or drift
- Updating a skill's scope, description, or internal structure
- Deprecating a skill that is no longer durable or distinct
- Wiring or rewiring explicit branchings between skills and agents
- Validating that skills comply with structural conventions

## Conventions Reference

All decisions must align with these project artifacts:

| Artifact | Path | Relevance |
| -------- | ---- | --------- |
| **Governance convention** | `.github/GOVERNANCE.md` | Branching statuses, lifecycle rules, change checklist, decision rule |
| **Skill files** | `.github/skills/<name>/SKILL.md` | Source of truth for each skill's scope and structure |
| **Agent files** | `.github/agents/<name>.agent.md` | Reference Skills sections (Primary / Contextual / Shared References) |
| **Shared references** | `.github/skills/_shared/references/` | Cross-cutting routing content shared across skills and agents |
| **Memory (static)** | `.github/memory/static/` | Durable team knowledge — audit results, lessons learned |

## Procedure

### Phase 1 — Create a Skill

Follow this procedure when building a new SKILL.md from scratch.

#### Step 1: Justify the Skill

Before creating, answer:

1. **Is the workflow reusable?** — Will multiple agents or tasks use it more than once?
2. **Is it distinct?** — Does an existing skill already cover this? Check the full list under `.github/skills/`.
3. **Is it durable?** — Will this workflow still matter in 3–6 months?

If any answer is "no", stop. Consider extending an existing skill or leaving the knowledge `runtime-optional`.

#### Step 2: Choose the Name

- Lowercase alphanumeric + hyphens only (1–64 chars)
- Create folder `.github/skills/<name>/`
- The `name` field in YAML frontmatter **must** match the folder name exactly

#### Step 3: Write the YAML Frontmatter

```yaml
---
name: <name>
description: "**WORKFLOW SKILL** — <concise summary>. USE FOR: <comma-separated triggers>. USE WHEN: <comma-separated conditions>. DO NOT USE FOR: <exclusions if needed>."
argument-hint: "<optional slash-command hint>"
---
```

Rules:
- `description` must be ≤ 1024 characters
- Always prefix with `**WORKFLOW SKILL**` (team convention)
- Include `USE FOR:` and `USE WHEN:` trigger keywords for discovery
- Quote the entire description value if it contains colons

#### Step 4: Write the Body

Use the standard section order:

1. `# <Skill Title>` — one-line purpose
2. `## When to Use` — bullet list of triggers
3. `## Procedure` — numbered steps with code examples where relevant
4. Decision matrices or checklists (optional, as needed)
5. `## Anti-Patterns` — common mistakes to avoid
6. `## Agent Integration` — which agents use this skill and how

Constraints:
- **Max 500 lines** total — if longer, move heavy docs into `./references/`
- Keep resources one level deep from SKILL.md
- Use progressive loading: only include what the agent needs to start; put deeper references in subdirectories

#### Step 5: Validate

Run the validation checklist:

- [ ] `name` field == folder name
- [ ] `description` < 1024 characters
- [ ] `description` has `USE FOR:` and `USE WHEN:` keywords
- [ ] Body < 500 lines
- [ ] `## When to Use` section present
- [ ] `## Procedure` section with numbered steps present
- [ ] `## Anti-Patterns` section present
- [ ] `## Agent Integration` section present
- [ ] YAML frontmatter valid (no tabs, values quoted if they contain colons)

### Phase 2 — Branch a Skill to Agents

After creating or updating a skill, decide which agents need explicit links.

#### Step 1: Classify Branching Need

Apply the GOVERNANCE.md decision rule:

```text
Is the skill critical to the agent's recurring workflow?
  YES → explicitly-branched as Primary Skill
  NO →
    Is it situationally useful for the agent?
      YES → explicitly-branched as Contextual Skill
      NO → Leave runtime-optional (no branch needed)
```

#### Step 2: Update Agent Files

For each agent that needs the branch, update its `## Reference Skills` section:

```markdown
## Reference Skills

### Primary Skills
- `skills-management` — skill lifecycle management

### Contextual Skills
- `documentation-ops` — when skill changes require docs updates

### Shared References
- `skills/_shared/references/environments.md` — cross-cutting environment routing
```

Rules from GOVERNANCE.md:
- Every agent must have at least one Primary Skill
- Skill paths must point to existing repo content
- Rename/split/merge changes must update Reference Skills in the same commit

#### Step 3: Verify Wiring

After updating, confirm:
- [ ] Every Primary Skill link resolves to an existing SKILL.md
- [ ] No orphan skills (every skill is branched to at least one agent)
- [ ] No duplicate coverage (two agents should not both have the same skill as Primary unless justified)

### Phase 3 — Audit Existing Skills

Use this procedure for periodic or triggered reviews.

#### Step 1: Load Prior Audits

Before starting, check `.github/memory/static/` for previous audit results. Compare to detect recurring issues, track resolution of past findings, and avoid re-investigating resolved items.

#### Step 2: Inventory

List all skills under `.github/skills/` and all agents under `.github/agents/`. Build a matrix:

```text
Skill → [Agent branches (Primary | Contextual)] → Utility score (1-10)
```

Rate each branching 1–10 on utility (frequency of use × criticality to the agent's core workflow). Branchings scoring ≤ 3 are candidates for removal.

#### Step 3: Detect Issues

| Issue | Detection | Resolution |
| ----- | --------- | ---------- |
| **Orphan skill** | Skill has no agent branches | Branch it or deprecate |
| **Scope overlap** | Two skills cover the same domain | Merge or tighten boundaries |
| **Stale description** | Description no longer matches body | Update frontmatter |
| **Over-branched** | Skill is Primary in >3 agents | Consider promoting to shared reference |
| **Missing coverage** | Agent has no Primary Skill for its core workflow | Create or branch a skill |
| **Convention drift** | Frontmatter missing keywords, body missing sections | Fix to match conventions |

#### Step 4: Report

Produce a structured report:

```text
## Skills Audit — <YYYY-MM-DD>
### Coverage Summary: X skills, Y agents, Z branches
### Utility Scores: branchings rated ≤3 flagged for review
### Issues Found: <list with severity>
### Recommended Actions: <ordered by priority>
### Delta from Last Audit: resolved / new / recurring
```

Store audit results in `.github/memory/static/` with filename `skills-audit-<YYYY-MM-DD>.md`.

### Phase 4 — Update a Skill

1. Read the current SKILL.md fully
2. Identify what changed (scope expansion, procedure refinement, boundary shift)
3. Update body sections and frontmatter description accordingly
4. Re-run the validation checklist (Phase 1, Step 5)
5. Check if branching changes are needed (Phase 2)
6. Update all affected agent Reference Skills sections in the same commit

### Phase 5 — Deprecate a Skill

1. Confirm the skill is no longer durable, distinct, or used
2. Check all agents for references → remove branches
3. If the skill's knowledge is still needed but covered elsewhere, add a redirect note
4. Remove the skill folder
5. Record the deprecation rationale in `.github/memory/static/`

## Anti-Patterns

| Anti-Pattern | Why It Fails | Do This Instead |
| ------------ | ------------ | --------------- |
| Creating a skill for a one-time task | Skills must be reusable and durable | Leave as runtime-optional or put in memory |
| Copying content from other skills | Causes drift and duplicate maintenance | Reference the other skill or use shared references |
| Forgetting to branch after creation | Skill exists but no agent can discover it | Always complete Phase 2 after Phase 1 |
| Description without trigger keywords | Model cannot auto-discover the skill | Always include `USE FOR:` and `USE WHEN:` |
| Exceeding 500 lines | Breaks progressive loading, wastes context | Move heavy content to `./references/` |
| Branching everything as Primary | Dilutes what "primary" means for the agent | Use Contextual for situational skills |
| Skipping validation checklist | Drift from conventions accumulates silently | Run checklist on every create and update |
| Updating skill without updating agent branches | Agent routing becomes stale | Same-commit updates for skill + branches |

## Agent Integration

| Agent | Relationship | Usage |
| ----- | ------------ | ----- |
| `team-maintainer` | **Primary consumer** | Uses this skill for structural audits, skill creation, branching maintenance |
| `agent-manager` | **Escalation target** | Receives unresolved scope or ownership questions from team-maintainer |
| `agent-project-manager-governance` | **Contextual consumer** | References when managing governance programs that touch skill structure |
| `executant-docs-ops` | **Contextual consumer** | References when skill changes require documentation updates |

## Hierarchy Context

This skill operates within the team's chain of command:

```text
agent-manager
  └── team-maintainer (manager-only expert, uses this skill directly)
  └── agent-project-manager-governance
        └── agent-lead-governance
              └── executant-docs-ops (contextual reference only)
```

Structural changes to skills always route through `team-maintainer` → `agent-manager` for approval.
