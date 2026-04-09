---
name: code-review-practice
description: "**WORKFLOW SKILL** — Conduct thorough code reviews across languages, frameworks, and concerns. USE FOR: correctness review, security review (OWASP), performance review, architecture and design review, anti-pattern detection, style and convention enforcement, PR best practices, review checklists, mentoring through reviews. USE WHEN: reviewing pull requests, auditing code quality, establishing review practices, or enforcing coding standards."
argument-hint: "Describe the review scope (e.g., 'review Java Spring Boot PR for security and performance')"
---

# Code Review Practice

Conduct systematic code reviews for correctness, security, performance, and maintainability.

## When to Use

- Reviewing pull requests or merge requests
- Auditing existing code for quality issues
- Establishing code review practices for a team
- Performing security-focused code review
- Reviewing architecture or design decisions in code

## Review Methodology

### Review Order

```text
1. Purpose   → Does the PR solve the right problem?
2. Design    → Is the approach sound?
3. Correctness → Does the code do what it claims?
4. Security  → Is it safe from OWASP Top 10?
5. Performance → Will it perform at expected scale?
6. Readability → Can the next developer understand it?
7. Tests     → Are the changes properly verified?
```

### Before Reading Code

- Read the PR description and linked issue
- Understand the intended behavior change
- Check the scope: is the PR focused or too broad?
- Review the test changes first — they describe the expected behavior

### While Reading Code

- Read top-down: entry points first, then callees
- Note questions and concerns inline, batch feedback
- Distinguish blocking issues from suggestions
- Offer alternatives, not just criticism

## Review Checklists

### Correctness

- [ ] Logic matches the stated requirements
- [ ] Edge cases handled (null, empty, boundary values, overflow)
- [ ] Error handling: specific exceptions, proper propagation, no swallowed errors
- [ ] Resource cleanup: connections, files, streams closed (try-with-resources, context managers, defer)
- [ ] Concurrency: thread safety, race conditions, deadlock potential
- [ ] State mutations: no unintended side effects

### Security (OWASP-Aligned)

- [ ] **Injection**: Parameterized queries, no string concatenation for SQL/commands
- [ ] **Broken auth**: Proper session management, token validation, password handling
- [ ] **Sensitive data**: No secrets in code, logs, or error messages
- [ ] **XXE/deserialization**: Safe parsers, allowlisted types
- [ ] **Access control**: Authorization checks on every endpoint, not just UI
- [ ] **Misconfiguration**: Debug mode off, default credentials removed, headers set
- [ ] **XSS**: Output encoding, CSP headers, sanitized user input
- [ ] **SSRF**: URL validation, allowlisted hosts for outbound requests
- [ ] **Dependencies**: No known CVEs, pinned versions, lockfile updated

### Performance

- [ ] No N+1 queries (eager loading or batching used)
- [ ] No unbounded collections (pagination, limits, streaming)
- [ ] Appropriate data structures for the access pattern
- [ ] No unnecessary allocations in hot paths
- [ ] Database indexes support the query patterns
- [ ] Connection pooling and resource reuse
- [ ] Caching used where appropriate, invalidation correct

### Design and Architecture

- [ ] Single Responsibility: each class/function does one thing
- [ ] Appropriate abstraction level (not over- or under-engineered)
- [ ] Dependencies flow inward (domain does not depend on infrastructure)
- [ ] API contracts: backward-compatible changes, versioning if breaking
- [ ] Configuration externalized (no hardcoded URLs, ports, credentials)
- [ ] Naming: clear, consistent, domain-appropriate

### Readability

- [ ] Code is self-documenting (comments explain why, not what)
- [ ] Function and variable names convey intent
- [ ] No dead code, commented-out code, or TODO without ticket reference
- [ ] Consistent style with the surrounding codebase
- [ ] Complex logic has explanatory comments or is refactored for clarity

### Tests

- [ ] New behavior has corresponding tests
- [ ] Tests verify behavior, not implementation
- [ ] Test names describe the scenario
- [ ] No test-only changes to production code (no `@VisibleForTesting` overuse)
- [ ] Edge cases and error paths tested
- [ ] No flaky patterns (sleeps, order-dependent, shared state)

## Language-Specific Anti-Patterns

### Java
- Checked exceptions used for control flow
- Mutable static state, singletons without thread safety
- `Optional.get()` without `isPresent()` check
- Catching `Exception` or `Throwable` broadly

### Python
- Bare `except:` or `except Exception:`
- Mutable default arguments (`def f(x=[])`)
- `import *` in non-interactive code
- Missing `__all__` in public modules

### TypeScript
- `any` type used to bypass type safety
- Non-null assertion (`!`) hiding potential nulls
- Floating promises (no `await` or `.catch()`)
- `== null` vs `=== null` confusion

### Rust
- `unwrap()` in library or production code
- `clone()` to satisfy borrow checker without understanding ownership
- Blocking in async context
- Ignoring `Result` or `Option` values

### C
- Buffer overflows: unchecked `strcpy`, `sprintf`, array bounds
- Use-after-free, double-free
- Missing null checks on malloc return
- Integer overflow in size calculations

## PR Best Practices

### For Authors
- Small, focused PRs (< 400 lines changed)
- Descriptive title and body explaining what and why
- Self-review before requesting others
- Link to issue/ticket
- Add reviewer guidance for complex changes

### For Reviewers
- Respond within 1 business day
- Distinguish: **blocker** vs **suggestion** vs **question** vs **nit**
- Approve when remaining comments are nits only
- Avoid bike-shedding on style when a linter could catch it
- Acknowledge good patterns and improvements

## Procedure

1. **Understand** the context: PR description, linked issue, scope
2. **Review tests first** to understand the expected behavior
3. **Read code** top-down, noting concerns inline
4. **Check** against the checklists (correctness, security, performance, design, readability, tests)
5. **Provide feedback** with clear severity labels (blocker/suggestion/nit)
6. **Verify** fixes on follow-up commits
7. **Approve** when all blockers are resolved
