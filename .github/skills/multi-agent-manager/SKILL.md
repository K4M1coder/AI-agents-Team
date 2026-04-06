---
name: multi-agent-manager
description: "**WORKFLOW SKILL** — Orchestrate multi-agent workflows for complex tasks. USE FOR: decomposing work into subtasks and dispatching to subagents; running agent pipelines (research → plan → implement → review); coordinating parallel agents with dependency tracking; managing a roster of specialized agents with roles. USE WHEN: task requires multiple capabilities or perspectives; work can be parallelized across agents; sequential agent handoffs are needed; you need to define or invoke a team of custom agents. DO NOT USE FOR: simple single-step tasks; tasks a single agent handles well alone."
argument-hint: "Describe the complex task to decompose and orchestrate across agents"
---

# Multi-Agent Manager

Orchestrate complex, multi-step work by decomposing tasks, dispatching to specialized agents, and aggregating results. Supports pipeline sequencing, parallel coordination, and custom agent roster management.

## When to Use

- A task spans multiple domains (e.g., research + implement + test + document)
- Work can be split into independent subtasks for parallel execution
- You need a structured handoff chain between agents with different specializations
- You want to define a reusable team of agents for a project

## Core Concepts

| Concept | Description |
| --------- | ------------- |
| **Task Decomposition** | Break a complex request into discrete, actionable subtasks |
| **Agent Roster** | A defined set of agents with roles, capabilities, and tool access |
| **Pipeline** | Sequential chain: output of one agent feeds input of the next |
| **Parallel Dispatch** | Independent subtasks run concurrently across agents |
| **Dependency Graph** | DAG of subtasks with explicit dependencies before dispatch |
| **Aggregation** | Merge results from multiple agents into a coherent deliverable |

## Procedure

### Phase 1: Task Analysis & Decomposition

1. **Understand the goal.** Restate the user's request as a concrete deliverable with acceptance criteria.
2. **Identify subtasks.** Break the work into 3–8 discrete subtasks. Each must be:
   - Self-contained (an agent can complete it without back-and-forth)
   - Clearly scoped (one outcome per subtask)
   - Testable (you can verify the result)
3. **Map dependencies.** Build a dependency graph:
   - Independent tasks → parallelizable
   - Tasks that consume another's output → sequential
   - Tasks that share mutable resources → serialize access
4. **Write the task manifest.** For each subtask, define:
   - **ID**: Short identifier (e.g., `T1`, `T2`)
   - **Description**: What to do and what to return
   - **Agent**: Which agent handles it (see Agent Selection below)
   - **Depends on**: List of prerequisite task IDs (empty = parallelizable)
   - **Output contract**: What the agent must return (format, structure)

Example manifest:
```text
T1: Research existing patterns     → Agent: Explore (thorough)  → Depends: []
T2: Analyze test coverage gaps     → Agent: Explore (medium)    → Depends: []
T3: Draft implementation plan      → Agent: Planner             → Depends: [T1, T2]
T4: Implement changes              → Agent: Default (Copilot)   → Depends: [T3]
T5: Write tests                    → Agent: Default (Copilot)   → Depends: [T4]
T6: Review & validate              → Agent: Reviewer            → Depends: [T4, T5]
```

### Phase 2: Agent Selection

Choose the right agent type for each subtask:

| Agent Type | Best For | How to Invoke |
| ------------ | ---------- | --------------- |
| **Explore subagent** | Read-only codebase research, file discovery, Q&A | `runSubagent` with `agentName: "Explore"` |
| **Default agent** | Implementation, editing, terminal commands | Direct execution (no subagent needed) |
| **Custom `.agent.md`** | Specialized roles with tool restrictions or custom instructions | `runSubagent` with custom agent name |
| **MCP-backed agent** | External system integration (GitHub, Notion, browser, etc.) | Via MCP tool calls within agent context |

#### Agent Selection Decision Tree

```text
Is the subtask read-only research?
  YES → Use Explore subagent (set thoroughness: quick/medium/thorough)
  NO →
    Does it need restricted tool access or a specialized persona?
      YES → Use or create a custom .agent.md
      NO →
        Does it need external system access?
          YES → Use MCP tools (GitHub, browser, Notion, etc.)
          NO → Use the default agent directly
```

### Phase 3: Dispatch & Execute

1. **Track progress.** Use `manage_todo_list` to create a todo for each subtask with status tracking.
2. **Dispatch parallel tasks first.** Launch all independent subtasks (those with no dependencies) simultaneously via `runSubagent`.
3. **Craft precise prompts.** Each subagent prompt must include:
   - Exact task description and expected output format
   - All necessary context (file paths, prior results, constraints)
   - Whether the agent should write code or only research
   - What information to return in its final message
4. **Collect results.** As each agent completes, capture its output and mark the todo as completed.
5. **Resolve dependencies.** When a task's prerequisites are all complete, dispatch it with the prerequisite outputs included in the prompt.
6. **Handle failures.** If a subtask fails, follow this recovery chain:
   - **Step A — Diagnose**: Was the prompt ambiguous? Missing context? Wrong agent type?
   - **Step B — Try alternate agent**: Reassign the subtask to a different agent type that can handle the same domain (e.g., Explore → custom research agent, Default → DevOps agent)
   - **Step C — Escalate**: If the alternate agent also fails, surface to the user with:
     - The original subtask description
     - What was attempted (both agents, both prompts)
     - The specific error or blocker
     - A suggested next step

### Phase 4: Aggregation & Delivery

1. **Merge results.** Combine outputs from all subtasks into the final deliverable.
2. **Resolve conflicts.** If parallel agents made conflicting changes:
   - Identify the conflict scope
   - Apply the most authoritative result (later pipeline stages take priority)
   - Validate the merged state
3. **Validate.** Run any applicable checks (tests, linting, build) on the combined result.
4. **Report.** Summarize what was done, by which agents, and any issues encountered.

## Agent Roster Management

### Defining a Custom Agent

Create `.github/agents/<name>.agent.md` for project-specific agents:

```yaml
---
name: reviewer
description: "Code review agent. Reviews PRs, checks patterns, validates tests."
tools: ["read_file", "grep_search", "semantic_search", "file_search", "list_dir", "get_errors"]
---

# Reviewer Agent

You are a code reviewer. Analyze code changes for:
- Correctness and edge cases
- Adherence to project conventions
- Test coverage gaps
- Security concerns (OWASP Top 10)

## Output Format
Return a structured review with: summary, issues (severity + description), and approval status.
```

See [agent roster reference](./references/agent-roster.md) for common agent definitions.
See [MCP integration reference](./references/mcp-integration.md) for dispatching to MCP-backed services.

### Auto-Creating Missing Agents

When a subtask requires an agent role that doesn't exist as a `.agent.md` file:

1. Check if `.github/agents/<role>.agent.md` exists
2. If missing, draft the agent definition from the [agent roster reference](./references/agent-roster.md)
3. Show the user the proposed `.agent.md` content and ask for confirmation before creating
4. Create the file at `.github/agents/<role>.agent.md` upon approval

### Common Agent Team Patterns

| Team Pattern | Agents | Use Case |
| ------------- | -------- | ---------- |
| **Research → Implement** | Explore → Default | Feature development with upfront discovery |
| **Implement → Review** | Default → Reviewer | Code changes with quality gate |
| **Full Pipeline** | Explore → Planner → Default → Reviewer | Complex features end-to-end |
| **Parallel Research** | Multiple Explore (different queries) | Broad codebase understanding |
| **DevOps Pipeline** | Default → Deployer → Monitor | Infrastructure changes with validation |

## Prompt Engineering for Subagents

Effective subagent prompts follow this structure:

```text
## Context
[What the agent needs to know — prior results, file locations, constraints]

## Task
[Exactly what to do — be specific and unambiguous]

## Output Requirements
[What to return — format, structure, level of detail]
[Whether to write code or only research]

## Constraints
[What NOT to do — boundaries, things to avoid]
```

**Key rules:**
- Subagents are stateless — include ALL context in the prompt
- Specify desired thoroughness for Explore agents
- Tell the agent its output will feed another agent downstream (if applicable)
- Request structured output (bullet points, JSON, tables) for easy aggregation

## Guardrails

- **Max depth**: Do not nest multi-agent orchestration more than 2 levels deep
- **Max parallelism**: Launch at most 5 parallel subagents (context window limits)
- **Confirmation**: Ask the user before dispatching if the plan has >6 subtasks or involves destructive operations
- **Timeouts**: Set reasonable timeouts for subagent tasks; escalate if stuck
- **Idempotency**: Subtasks that write files should be safe to retry
- **Conflict resolution**: Never silently overwrite another agent's output
