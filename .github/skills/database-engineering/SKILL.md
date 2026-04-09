---
name: database-engineering
description: "**WORKFLOW SKILL** — Design, implement, and optimize databases across paradigms. USE FOR: Relational (Oracle, DB2, H2, SQLite, SQL Server, MySQL, PostgreSQL, Supabase), Document (MongoDB), Vector (Qdrant), Graph (Neo4j, Neptune), Search (Elasticsearch), Time-series (TimescaleDB, InfluxDB, ClickHouse), schema design, migrations, indexing, query optimization, replication, backup, connection pooling. USE WHEN: designing schemas, writing migrations, optimizing queries, choosing a database engine, or managing database infrastructure."
argument-hint: "Describe the database task (e.g., 'PostgreSQL schema with TimescaleDB hypertables for IoT metrics')"
---

# Database Engineering

Design, implement, and optimize databases across relational, document, vector, graph, search, and time-series paradigms.

## When to Use

- Designing schemas or data models
- Choosing a database engine for a workload
- Writing or reviewing migrations
- Optimizing queries, indexes, or storage
- Configuring replication, backups, or high availability
- Integrating databases with application code

## Database Selection Guide

### Relational Databases

| Engine | Strengths | Best For |
| ------ | --------- | -------- |
| PostgreSQL | Extensions, JSON, full-text search, ACID | Default choice for new projects |
| Supabase | Managed Postgres, auth, realtime, edge functions | Rapid prototyping, BaaS |
| MySQL / MariaDB | Mature, wide hosting support | Web applications, WordPress ecosystem |
| SQL Server | Enterprise .NET integration, BI | Microsoft stack, enterprise |
| Oracle | Extreme scale, PL/SQL, enterprise features | Legacy enterprise, financial systems |
| DB2 | Mainframe integration, enterprise analytics | IBM ecosystem, banking |
| H2 | In-process, Java-native, fast startup | Testing, embedded, development |
| SQLite | Embedded, zero-config, serverless | Mobile, desktop, edge, prototyping |

### Document Databases

| Engine | Strengths | Best For |
| ------ | --------- | -------- |
| MongoDB | Flexible schema, aggregation pipeline, Atlas | Content management, catalogs, rapid iteration |

### Vector Databases

| Engine | Strengths | Best For |
| ------ | --------- | -------- |
| Qdrant | Rust-based, filtering, gRPC/REST, high performance | RAG, semantic search, recommendation |

### Graph Databases

| Engine | Strengths | Best For |
| ------ | --------- | -------- |
| Neo4j | Cypher query language, mature ecosystem | Social graphs, knowledge graphs, fraud detection |
| Neptune | AWS managed, Gremlin + SPARQL | AWS-native graph workloads, RDF/linked data |

### Search Engines

| Engine | Strengths | Best For |
| ------ | --------- | -------- |
| Elasticsearch | Full-text, aggregations, ELK stack | Log analysis, product search, analytics |

### Time-Series Databases

| Engine | Strengths | Best For |
| ------ | --------- | -------- |
| TimescaleDB | PostgreSQL extension, SQL, compression | IoT, metrics with relational joins |
| InfluxDB | Purpose-built, Flux/InfluxQL, retention policies | Infrastructure monitoring, sensor data |
| ClickHouse | Columnar, extreme query speed, analytical | OLAP, event analytics, large-scale aggregations |

## Schema Design Principles

### Relational

- Normalize to 3NF then denormalize consciously for performance
- Primary keys: prefer UUIDs or ULIDs for distributed systems, sequences for single-node
- Foreign keys: always declare, enforce referentially
- Indexes: cover query patterns, not tables. Composite indexes follow leftmost-prefix rule
- Constraints: NOT NULL by default, CHECK constraints for domain rules, UNIQUE where needed
- Naming: `snake_case`, singular table names, `_id` suffix for foreign keys

### Document (MongoDB)

- Embed frequently accessed related data; reference when data is large or shared
- Schema validation with JSON Schema
- Indexes on query patterns, compound indexes for multi-field queries
- Avoid unbounded arrays

### Graph (Neo4j / Neptune)

- Nodes = entities, relationships = verbs with direction
- Properties on relationships when the connection has attributes
- Index frequently traversed properties
- Cypher: `MATCH (a)-[:KNOWS]->(b)` pattern

### Time-Series

- Partition by time (hypertables in TimescaleDB, measurement/bucket in InfluxDB)
- Retention policies for automatic data lifecycle
- Downsampling / continuous aggregates for long-term storage
- Tag vs field distinction (InfluxDB): tags are indexed, fields are not

### Vector (Qdrant)

- Payload filtering combined with vector similarity
- Collection configuration: vector size, distance metric (cosine, dot, euclidean)
- Batch upsert for ingestion pipelines

## Migration Management

| Language | Tool | Pattern |
| -------- | ---- | ------- |
| Java | Flyway / Liquibase | Versioned SQL or XML changesets |
| Python | Alembic / Django migrations | Auto-generated from ORM models |
| TypeScript | Prisma Migrate / Drizzle Kit | Schema-first or code-first |
| Rust | SQLx migrations / Diesel | SQL files or DSL |
| Multi | golang-migrate / dbmate | Raw SQL, language-agnostic |

**Rules:**
- Migrations are immutable once applied
- Always include rollback/down migration
- Separate DDL (schema) from DML (data) migrations
- Test migrations on a copy of production data shape

## Query Optimization

1. **EXPLAIN ANALYZE** every slow query
2. **Index** columns in WHERE, JOIN, ORDER BY, GROUP BY
3. **Avoid** `SELECT *` — project only needed columns
4. **Pagination**: cursor-based for large datasets, OFFSET for small
5. **Connection pooling**: PgBouncer (Postgres), ProxySQL (MySQL), HikariCP (Java)
6. **Read replicas** for read-heavy workloads
7. **Materialized views** or continuous aggregates for expensive computations

## Procedure

1. **Analyze** the data model, access patterns, and scale requirements
2. **Choose** the database engine(s) matching the workload paradigm
3. **Design** schema with proper normalization, types, and constraints
4. **Write** migrations with rollback support
5. **Index** based on query patterns, not guesses
6. **Optimize** with EXPLAIN, connection pooling, and caching
7. **Secure** with least-privilege roles, encryption at rest/transit, parameterized queries
8. **Monitor** with slow query logs, connection metrics, storage growth

## Security Standards

- Parameterized queries / prepared statements — never string interpolation
- Least-privilege database roles per service
- Encryption at rest (TDE, LUKS, cloud-native)
- TLS for all client connections
- Audit logging for DDL and privileged operations
- Regular backups with tested restore procedures
