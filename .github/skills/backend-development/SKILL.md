---
name: backend-development
description: "**WORKFLOW SKILL** — Design and implement backend services across languages and paradigms. USE FOR: Java (Spring Boot, Jakarta EE, Quarkus), Python (FastAPI, Flask, Django), TypeScript/Node.js (Express, NestJS, Fastify), Rust (Axum, Actix-web), C (system libraries, embedded), REST/GraphQL/gRPC API design, DDD, CQRS, event-driven architecture, microservices, authentication/authorization patterns. USE WHEN: building backend services, APIs, microservices, or server-side application logic."
argument-hint: "Describe the backend task (e.g., 'FastAPI service with JWT auth and PostgreSQL')"
---

# Backend Development

Design and implement backend services, APIs, and server-side application logic.

## When to Use

- Building new backend services or APIs
- Implementing business logic and domain models
- Designing microservice boundaries and communication
- Adding authentication, authorization, or middleware
- Integrating with databases, message queues, or external services

## Language and Framework Reference

### Java

| Framework | Use Case | Build |
| --------- | -------- | ----- |
| Spring Boot 3 | Enterprise APIs, microservices | Maven / Gradle |
| Quarkus | Cloud-native, GraalVM native images | Maven / Gradle |
| Jakarta EE 10 | Full-stack enterprise, legacy modernization | Maven |
| Micronaut | Low-memory microservices, serverless | Gradle / Maven |

**Patterns**: Spring Data JPA, Spring Security, Bean Validation, MapStruct, Flyway/Liquibase migrations.

### Python

| Framework | Use Case | Package Manager |
| --------- | -------- | --------------- |
| FastAPI | High-performance async APIs | pip / uv / poetry |
| Django | Full-stack, ORM-heavy, admin-driven | pip / uv / poetry |
| Flask | Lightweight, flexible, composable | pip / uv / poetry |
| Litestar | Modern async, OpenAPI-first | pip / uv / poetry |

**Patterns**: Pydantic models, SQLAlchemy / Django ORM, Alembic migrations, Celery/ARQ task queues, dependency injection.

### TypeScript / Node.js

| Framework | Use Case | Package Manager |
| --------- | -------- | --------------- |
| NestJS | Enterprise, DI-based, modular | npm / pnpm / yarn |
| Express | Minimal, middleware-based | npm / pnpm / yarn |
| Fastify | High-performance, schema-based | npm / pnpm / yarn |
| tRPC | Type-safe client-server, monorepo | npm / pnpm / yarn |

**Patterns**: TypeORM / Prisma / Drizzle ORM, Zod validation, Passport.js auth, Bull/BullMQ queues.

### Rust

| Framework | Use Case |
| --------- | -------- |
| Axum | Async web, tower middleware, production-grade |
| Actix-web | High-throughput, actor model |
| Rocket | Ergonomic, request guards |

**Patterns**: SQLx / Diesel / SeaORM, serde serialization, tower layers, tracing instrumentation.

### C

| Domain | Use Case |
| ------ | -------- |
| System libraries | Shared libraries, FFI targets, kernel modules |
| Embedded | Bare-metal, RTOS, constrained devices |
| Extensions | CPython extensions, PostgreSQL extensions, Nginx modules |

**Patterns**: CMake/Meson build, Valgrind/ASan memory safety, POSIX APIs, static analysis (cppcheck, clang-tidy).

## API Design Patterns

### REST

- Resource-oriented URIs, proper HTTP verbs and status codes
- Versioning: URI path (`/v1/`) or header-based
- Pagination: cursor-based preferred, offset-based when simple
- Error responses: RFC 7807 Problem Details
- HATEOAS when client discoverability matters

### GraphQL

- Schema-first design with SDL
- DataLoader for N+1 prevention
- Persisted queries for production
- Depth and complexity limits against abuse

### gRPC

- Proto3 definitions, service contracts
- Streaming (server, client, bidirectional)
- Interceptors for auth, logging, tracing
- gRPC-Gateway for REST transcoding

## Architecture Patterns

| Pattern | When | Avoid When |
| ------- | ---- | ---------- |
| Layered (controller → service → repository) | Standard CRUD, familiar teams | Complex domain logic |
| DDD (aggregates, value objects, domain events) | Complex business rules, bounded contexts | Simple CRUD apps |
| CQRS | Read/write asymmetry, event sourcing | Simple domains |
| Event-driven (message bus, pub/sub) | Async workflows, decoupled services | Strong consistency required |
| Hexagonal / Ports-and-Adapters | Testability, swappable infrastructure | Over-engineering for small services |

## Authentication and Authorization

| Method | Use Case |
| ------ | -------- |
| JWT (access + refresh) | Stateless APIs, microservices |
| OAuth2 / OIDC | Third-party auth, SSO |
| API keys | Machine-to-machine, simple integrations |
| mTLS | Service mesh, zero-trust |
| RBAC / ABAC | Role-based or attribute-based access control |

## Procedure

1. **Define** API contract (OpenAPI spec, proto file, or GraphQL schema)
2. **Choose** language, framework, and architecture pattern for the domain
3. **Implement** domain/business logic with proper separation of concerns
4. **Integrate** with data layer (ORM, raw SQL, or external APIs)
5. **Secure** endpoints (auth, input validation, rate limiting)
6. **Test** at unit, integration, and contract levels
7. **Instrument** with structured logging and tracing
8. **Document** API (auto-generated from schema when possible)

## Code Standards

- Input validation at API boundary — never trust external data
- Structured logging (JSON) with correlation IDs
- Health and readiness endpoints (`/health`, `/ready`)
- Graceful shutdown handling
- Configuration via environment variables (12-factor)
- Secrets never hardcoded or logged
