# Dynamic Memory — Working Memory

Per-request working memory for the agent team. Each active request gets its own folder.

## Structure

```
dynamic/
├── README.md              # This file
└── <request-id>/          # One folder per request
    ├── context.md         # Request context and objectives
    ├── progress.md        # Task tracking and status
    └── (artifacts)        # Working files, intermediate results
```

## Request Folder Convention

### Folder Naming

```
<YYYY-MM-DD>_<short-descriptor>
```

Examples:
- `2026-04-10_skill-audit-implementation`
- `2026-04-11_proxmox-cluster-setup`
- `2026-04-12_ci-pipeline-migration`

### Required Files

#### `context.md`
```markdown
# Request: <title>
- **Date**: YYYY-MM-DD
- **Requester**: <who asked>
- **Assigned to**: <agent or team lead>
- **Status**: active | paused | completed | archived
- **Objective**: <one-line goal>

## Scope
<what is in and out of scope>

## Dependencies
<what this request depends on or blocks>
```

#### `progress.md`
```markdown
# Progress: <title>

## Current Status
<brief status summary>

## Task Log
- [ ] Task 1
- [x] Task 2 (completed YYYY-MM-DD)

## Notes
<working notes, decisions made, issues encountered>
```

### Optional Files
- Analysis results, intermediate data, draft configs
- Keep artifacts related to the request together

## Lifecycle

| Phase | Action | Who |
|-------|--------|-----|
| **Create** | New folder when request starts | Assigned agent |
| **Update** | Progress notes during execution | Working agent(s) |
| **Complete** | Mark status=completed, extract lessons → static/ | Assigned agent |
| **Archive** | Delete folder after lessons extracted | team-maintainer |

## Rules

1. **One folder per request** — Don't mix unrelated work.
2. **Update progress** — Keep `progress.md` current during execution.
3. **Extract before delete** — Move valuable insights to `static/` before archiving.
4. **No stale folders** — Completed requests should be archived within a reasonable time.
5. **Self-contained** — Each folder should be understandable without external context.
