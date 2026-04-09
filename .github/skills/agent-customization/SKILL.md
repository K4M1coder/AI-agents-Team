---
name: agent-customization
description: "**WORKFLOW SKILL** — Create, update, review, fix, or debug VS Code agent customization files for this AI agent team. USE FOR: authoring .agent.md files, creating SKILL.md files following team conventions, fixing YAML frontmatter errors, configuring tool restrictions, writing descriptions with USE FOR/USE WHEN triggers, validating frontmatter, updating Reference Skills sections, debugging why a skill or agent is not discovered or invoked. USE WHEN: adding a new agent to the team, creating a new skill, updating an existing agent's scope or toolset, or troubleshooting discovery and routing failures."
argument-hint: "Describe the customization task (e.g., 'create a new executant agent for X' or 'fix YAML frontmatter in skill Y')"
---

# Agent Customization

Author, update, validate, and debug VS Code agent and skill customization files following this team's conventions.

## When to Use

- Creating a new `.agent.md` file for a new team role
- Creating a new `SKILL.md` file for a reusable workflow
- Updating an existing agent's description, tools, or methodology
- Fixing YAML frontmatter errors (quoting, indentation, invalid characters)
- Debugging why a skill or agent is not being invoked or discovered
- Reviewing a customization file for convention compliance

## File Types and Locations

| File type | Location | Purpose |
| --------- | -------- | ------- |
| `.agent.md` | `.github/agents/<name>.agent.md` | Defines a VS Code agent mode with tools, instructions, escalation |
| `SKILL.md` | `.github/skills/<name>/SKILL.md` | Defines a reusable workflow skill loaded by agents |
| Shared reference | `.github/skills/_shared/references/<name>.md` | Cross-cutting routing matrices used by multiple agents |
| Memory (static) | `.github/memory/static/` | Durable team knowledge, audit results, conventions |
| Memory (dynamic) | `.github/memory/dynamic/<YYYY-MM-DD>_<desc>/` | Per-request working memory |

## Procedure

### Part 1 — Writing a `.agent.md` File

#### Step 1: YAML Frontmatter

```yaml
---
name: <name>          # must match filename without .agent.md extension
description: "<concise role summary + USE FOR: + USE WHEN: triggers>"
tools: ["read_file", "grep_search", "semantic_search", "file_search",
        "list_dir", "memory", "run_in_terminal", "create_file",
        "replace_string_in_file", "agent", "manage_todo_list"]
---
```

**Tool selection guidelines:**

| Tool group | Include when |
| ---------- | ------------ |
| `read_file`, `grep_search`, `semantic_search`, `file_search`, `list_dir` | Always — every agent needs read access |
| `memory` | Always — agents must read/write memory |
| `run_in_terminal` | Include for executants that run commands; exclude for orchestrators |
| `create_file`, `replace_string_in_file` | Include for executants that write code or configs |
| `agent` / `runSubagent` | Include for orchestrators (manager, leads, project managers) |
| `manage_todo_list` | Include for orchestrators and complex executants |
| `web/fetch`, `web/githubRepo` | Include only when the role requires web access |

#### Step 2: Body Sections

Standard section order for executant agents:

1. `# <Role Title>` — one sentence purpose
2. Direct superior quote (`> **Direct superior**: ...`)
3. `## Expertise` or `## Scope` — what the agent knows and does
4. `## Methodology` — numbered steps for how the agent works
5. `## Reference Skills` — Primary / Contextual / Shared References
6. `## Coordinates With` — table of agents and handoffs
7. `## Output Format` — what the agent returns

Standard section order for orchestrator agents (manager, leads, project managers):

1. `# <Role Title>`
2. Direct superior quote
3. `## Your Team` or `## Your Team Leads` — table of direct reports
4. `## Team Competence Synthesis` (leads only) — what the lead can answer directly
5. `## Methodology` — numbered orchestration steps
6. `## Reference Skills`
7. `## Coordinates With`
8. `## Output Format`

#### Step 3: Reference Skills Section

```markdown
## Reference Skills

### Primary Skills
- `<skill-name>` for <what it provides to this agent>.

### Contextual Skills
- `<skill-name>` when <specific condition>.

### Shared References
- `skills/_shared/references/<file>.md` for <what routing decision it enables>.
```

Rules:
- Every agent must have at least one Primary Skill
- Contextual entries must have a "when" condition
- Shared Reference paths are relative to `.github/` — use `skills/_shared/...` not `../_shared/...`

### Part 2 — Writing a `SKILL.md` File

See `skills-management` for the full skill lifecycle. Summary:

#### YAML Frontmatter

```yaml
---
name: <name>             # must match folder name exactly
description: "**WORKFLOW SKILL** — <summary>. USE FOR: <comma-separated>. USE WHEN: <conditions>."
argument-hint: "<slash-command hint>"
---
```

- `description` ≤ 1024 chars
- Always prefix with `**WORKFLOW SKILL**`
- Quote the whole value — descriptions often contain colons

#### Body Section Order

1. `# <Skill Title>`
2. `## When to Use` — bullet list
3. `## Procedure` — numbered phases/steps with code examples
4. Decision matrices / checklists
5. `## Anti-Patterns` — table format preferred
6. `## Agent Integration` — table of agents + relationship + usage

### Part 3 — Debugging Discovery Failures

If a skill or agent is not being invoked when expected:

1. **Check description keywords** — Does the description contain `USE FOR:` and `USE WHEN:`? Are the trigger words present?
2. **Check YAML validity** — Open the file and look for:
   - Tabs (must be spaces)
   - Unquoted colons in values
   - Trailing spaces on frontmatter delimiter lines (`---`)
   - Missing closing `---`
3. **Check name matching**:
   - Skill: `name` in frontmatter must equal folder name
   - Agent: `name` in frontmatter must equal filename (without `.agent.md`)
4. **Check tool availability** — If the task requires a tool not listed in the agent's `tools` array, the agent cannot use it
5. **Check branching** — Is the skill listed in the relevant agent's `## Reference Skills`? A skill not wired to any agent is discoverable but not guaranteed to be loaded

## Anti-Patterns

| Anti-Pattern | Why It Fails | Do This Instead |
| ------------ | ------------ | --------------- |
| Description without USE FOR/USE WHEN | Skill not auto-discovered by model | Always include both trigger sections |
| Tabs in YAML frontmatter | Breaks YAML parsing silently | Use 2-space indentation, no tabs |
| `name` field doesn't match folder/filename | File is ignored or loads under wrong name | Always verify name matches |
| Giving every tool to every agent | Blurs agent boundaries, context bloat | Give only the tools the role genuinely needs |
| Contextual Skill without "when" condition | Routing ambiguity — agent calls it always or never | Every Contextual entry must have a "when" clause |
| Creating a SKILL.md over 500 lines | Breaks progressive loading | Move heavy content to `./references/` subdirectory |
| No `## Coordinates With` in agent | Handoffs are implicit and fragile | Always declare coordination relationships |

## Agent Integration

| Agent | Relationship | Usage |
| ----- | ------------ | ----- |
| `team-maintainer` | **Primary consumer** | Full agent and skill authoring, validation, branching |
| `executant-docs-ops` | **Contextual** | When agent/skill documentation needs publishing or review governance |
| `agent-project-manager-governance` | **Contextual** | When governance programs require new agents or skill restructuring |
