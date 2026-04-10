# Agent Team Memory System

Local memory for the AI agent team, divided into two scopes.

## Structure

```text
.github/memory/
├── static/       # Durable team knowledge — always available
├── dynamic/      # Working memory — per-request task state
└── README.md     # This file
```

## Scopes

### Static Memory (`static/`)

**What the team must always know.**

Persistent knowledge that survives across all requests and conversations. Content here is stable, reviewed, and part of the team's durable mental model.

- Team architecture decisions and audit results
- Verified conventions and patterns
- Cross-cutting knowledge not suited for skills or shared references
- Lessons learned from past incidents or projects

**Lifecycle**: Content is added deliberately and removed only when obsolete. Changes should be reviewed.

### Dynamic Memory (`dynamic/`)

**Working memory for active requests.**

Each request the agent team processes gets its own folder with task context, progress notes, and working artifacts.

- One folder per request: `dynamic/<request-id>/`
- Contains context, progress tracking, intermediate results
- Cleaned up when the request is fully resolved

**Lifecycle**: Created at request start, updated during execution, archived or deleted on completion.

## Governance

- **Owner**: `team-maintainer` owns the memory structure and conventions.
- **Writers**: Any agent may write to `dynamic/` during task execution. Only deliberate team actions write to `static/`.
- **Branching status**: Memory files are `runtime-optional` — they provide working context but are not structurally branched into agent definitions.
- **Scope boundary**: Memory stores operational knowledge. Reusable workflow knowledge → skills. Cross-cutting routing matrices → shared references.
