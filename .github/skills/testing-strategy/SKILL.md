---
name: testing-strategy
description: "**WORKFLOW SKILL** — Design and implement test strategies across languages and paradigms. USE FOR: unit testing, integration testing, e2e testing, performance testing, security testing, TDD/BDD, test frameworks (JUnit, pytest, Jest, Vitest, Rust test, Playwright, Cypress), coverage analysis, mutation testing, contract testing, load testing (k6, Gatling, Locust), test data management, CI test orchestration. USE WHEN: defining a test strategy, writing tests, improving coverage, setting up test automation, or debugging test failures."
argument-hint: "Describe the testing task (e.g., 'pytest integration tests for FastAPI with PostgreSQL testcontainers')"
---

# Testing Strategy

Design and implement test strategies, write tests, and build test automation pipelines.

## When to Use

- Defining a test strategy for a new or existing project
- Writing unit, integration, or end-to-end tests
- Setting up test automation in CI/CD
- Analyzing coverage gaps or improving test quality
- Performance or load testing
- Contract testing between services

## Test Pyramid

```text
         ╱  E2E  ╲           Few, slow, high confidence
        ╱─────────╲
       ╱Integration ╲        Moderate count, API/DB boundaries
      ╱───────────────╲
     ╱     Unit        ╲     Many, fast, isolated
    ╱───────────────────╲
```

| Level | Scope | Speed | Isolation |
| ----- | ----- | ----- | --------- |
| Unit | Single function/class | < 10ms | Full (mocked dependencies) |
| Integration | Module + real dependencies | < 5s | Partial (testcontainers, in-memory DB) |
| E2E | Full system, user flows | < 60s | None (real services) |
| Contract | API boundary between services | < 1s | Mocked consumer/provider |
| Performance | Load, stress, soak | Minutes | Production-like environment |

## Framework Reference

### Unit and Integration

| Language | Framework | Runner | Mocking |
| -------- | --------- | ------ | ------- |
| Java | JUnit 5 | Maven Surefire / Gradle | Mockito, WireMock |
| Python | pytest | pytest CLI | pytest-mock, unittest.mock, responses |
| TypeScript | Vitest / Jest | Vitest / Jest CLI | vi.mock / jest.mock, MSW |
| Rust | built-in `#[test]` | cargo test | mockall, wiremock-rs |
| C | Unity / CUnit / CMocka | CTest / custom | CMock, fff |

### End-to-End

| Tool | Target | Language |
| ---- | ------ | -------- |
| Playwright | Web (Chromium, Firefox, WebKit) | TypeScript, Python, Java, .NET |
| Cypress | Web (Chromium-based) | JavaScript/TypeScript |
| Selenium | Web (all browsers) | Java, Python, JS, C# |
| Appium | Mobile (iOS, Android) | Multiple |

### Performance and Load

| Tool | Approach | Script Language |
| ---- | -------- | --------------- |
| k6 | Code-driven load testing | JavaScript |
| Gatling | Simulation-based | Scala / Java |
| Locust | Python-native, distributed | Python |
| JMeter | GUI + CLI, protocol-level | XML / Java |

### Contract Testing

| Tool | Approach |
| ---- | -------- |
| Pact | Consumer-driven contracts, multi-language |
| Schemathesis | OpenAPI-driven property testing |
| Dredd | API Blueprint / OpenAPI validation |

## Test Design Patterns

| Pattern | Use When |
| ------- | -------- |
| Arrange-Act-Assert (AAA) | Default for all tests |
| Given-When-Then (BDD) | Behavior specs, stakeholder-readable |
| Builder pattern for test data | Complex object construction |
| Object Mother / Factory | Reusable test fixtures |
| Testcontainers | Real databases/services in integration tests |
| Snapshot testing | UI components, serialized output |
| Property-based testing | Edge cases, invariant verification (Hypothesis, jqwik, proptest) |
| Mutation testing | Test quality validation (PIT, mutmut, cargo-mutants) |

## Coverage Strategy

- **Target**: 80%+ line coverage as baseline, not a ceiling
- **Branch coverage** matters more than line coverage
- **Mutation testing** reveals tests that pass but don't actually verify behavior
- **Coverage ratchet**: never decrease coverage in CI, only increase
- **Excluded from coverage**: generated code, configuration, pure data classes

## CI Integration

```text
┌──────────┐   ┌──────────────┐   ┌─────────┐   ┌────────────┐
│ Unit     │──▶│ Integration  │──▶│   E2E   │──▶│ Performance│
│ (fast)   │   │ (containers) │   │ (staged)│   │ (scheduled)│
└──────────┘   └──────────────┘   └─────────┘   └────────────┘
   Always          Always           On merge      Nightly/weekly
```

- Unit tests: run on every commit, block PR on failure
- Integration tests: run on every commit, use testcontainers or in-memory services
- E2E tests: run on merge to main or staging deployment
- Performance tests: scheduled (nightly or weekly), alert on regression
- Contract tests: run on PR when API contracts change

## Procedure

1. **Analyze** the codebase, identify critical paths and risk zones
2. **Define** test strategy: which levels, frameworks, and coverage targets
3. **Write** tests following the pyramid (most unit, fewer integration, fewest e2e)
4. **Automate** in CI with proper gating and parallelization
5. **Measure** coverage including branch and mutation
6. **Maintain** tests as first-class code: refactor, name clearly, keep fast
7. **Review** test quality: do tests actually catch regressions?

## Anti-Patterns to Avoid

- Testing implementation details instead of behavior
- Flaky tests left unfixed in CI
- Over-mocking: mocking everything defeats the test's purpose
- Testing only the happy path
- Slow test suites that developers skip locally
- Coverage gaming: tests without meaningful assertions
