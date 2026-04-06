# MCP Integration Reference

How to dispatch subtasks that require external system access via MCP (Model Context Protocol) servers.

## Available MCP Servers

### GitHub (`mcp_io_github_git_*`)

**Capabilities:** Repository management, issues, PRs, code search, releases, branches, commits.

| Task Category | Key Tools | Use When |
| -------------- | ----------- | ---------- |
| Code Search | `mcp_io_github_git_search_code` | Finding code across repos beyond local workspace |
| Issue Management | `mcp_io_github_git_list_issues`, `mcp_io_github_git_issue_read/write` | Creating, reading, updating issues |
| PR Workflow | `mcp_io_github_git_create_pull_request`, `mcp_io_github_git_list_pull_requests` | Opening PRs, requesting reviews |
| Branch Ops | `mcp_io_github_git_create_branch`, `mcp_io_github_git_list_branches` | Branch management |
| File Ops | `mcp_io_github_git_get_file_contents`, `mcp_io_github_git_create_or_update_file` | Remote file read/write |

**Prompt template for GitHub subtasks:**

```text
se MCP GitHub tools to [ACTION].
Repository: [owner/repo]
Details: [specific parameters]
Return: [what to report back]
```

---

### Browser / Playwright (`mcp_microsoft_pla_*` or `mcp_io_github_chr_*`)

**Capabilities:** Web browsing, screenshots, form filling, UI testing, accessibility snapshots.

| Task Category | Key Tools | Use When |
| -------------- | ----------- | ---------- |
| Navigate | `browser_navigate`, `browser_navigate_back` | Loading pages |
| Inspect | `browser_snapshot`, `browser_take_screenshot` | UI verification, visual checks |
| Interact | `browser_click`, `browser_fill_form`, `browser_type` | Form submission, UI testing |
| Monitor | `browser_network_requests`, `browser_console_messages` | Debugging, performance |

**Prompt template for browser subtasks:**

```text
se browser MCP tools to [navigate to URL / test UI / capture screenshot].
URL: [target]
Steps: [click X, fill Y, verify Z]
Return: [screenshot, console output, test result]
```

---

### Notion (`mcp_makenotion_no_*`)

**Capabilities:** Page creation, database management, comments, search, views.

| Task Category | Key Tools | Use When |
| -------------- | ----------- | ---------- |
| Search | `notion-search` | Finding existing pages or databases |
| Pages | `notion-create-pages`, `notion-update-page` | Creating/updating documentation |
| Databases | `notion-create-database`, `notion-create-view` | Structured data management |
| Comments | `notion-create-comment`, `notion-get-comments` | Collaboration and feedback |

---

### Atlassian Confluence (`mcp-server-atlassian-confluence`)

**Capabilities:** Wiki/knowledge base management, page creation, search, space management.

**Common subtask types:**

- Search existing documentation for a topic
- Create or update a Confluence page with implementation docs
- Export architecture decisions or runbooks

**Prompt template:**

```text
se Atlassian Confluence MCP tools to [search/create/update] documentation.
Space: [space key]
Topic: [what to document]
Return: [page URL, content summary]
```

---

### Atlassian Jira (`mcp-server-atlassian-jira`)

**Capabilities:** Issue tracking, sprint management, project queries, workflow transitions.

**Common subtask types:**

- Create Jira tickets from task decomposition
- Query existing issues for context
- Update issue status as subtasks complete
- Link related issues

**Prompt template:**

```text
se Atlassian Jira MCP tools to [create/query/update] issues.
Project: [project key]
Details: [summary, description, type, priority]
Return: [issue key, URL, status]
```

---

### Atlassian Bitbucket (`mcp-server-atlassian-bitbucket`)

**Capabilities:** Repository management, PR workflows, code review, branch operations.

**Common subtask types:**

- Create PRs on Bitbucket repos
- Review code changes
- Manage branch permissions

---

## MCP Dispatch Guidelines

1. **Tool discovery first.** Before dispatching, use `tool_search_tool_regex` to verify the MCP tools are available (they are deferred and must be loaded).
2. **Auth awareness.** MCP servers require authentication configured in the user's environment. If a tool call fails with auth errors, escalate to the user.
3. **Rate limits.** External APIs have rate limits. Space out bulk operations (e.g., creating 20 Jira tickets) with brief pauses.
4. **Idempotency.** Check before creating — search for existing issues/pages/PRs before creating duplicates.
5. **Error mapping.** Map MCP errors to actionable recovery:
   - `401/403` → Auth issue, escalate to user
   - `404` → Resource not found, verify identifiers
   - `429` → Rate limited, retry after delay
   - `500` → Server error, retry once then escalate
