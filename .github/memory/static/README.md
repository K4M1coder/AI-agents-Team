# Static Memory — Team Knowledge Base

Durable knowledge the team must always have access to.

## What Belongs Here

| Category | Example | NOT here (use instead) |
|----------|---------|----------------------|
| Architecture decisions | Team structure rationale, audit conclusions | ADRs → `executant-docs-ops` |
| Verified conventions | Naming patterns, branching rules | Governance → `GOVERNANCE.md` |
| Lessons learned | Past failures, edge cases discovered | Incident reports → `executant-sre-ops` |
| Environment facts | Infrastructure topology, platform constraints | Cross-cutting → `_shared/references/` |
| Project context | Client requirements, domain glossary | — |

## Rules

1. **Reviewed content only** — No draft or speculative content. Everything here should be verified.
2. **Concise** — Use bullet points and tables. No prose where a list suffices.
3. **Dated** — Each file should include a `Last updated: YYYY-MM-DD` line.
4. **Flat structure** — Files at this level, no deep nesting. Use descriptive filenames.
5. **No duplication** — If it exists in `GOVERNANCE.md`, skills, or shared references, link to it instead.

## Naming Convention

```
<topic>.md
```

Examples:
- `team-audit-2026-04.md` — Results of the April 2026 competency audit
- `infrastructure-topology.md` — Current datacenter and cloud layout
- `project-glossary.md` — Domain-specific terminology
