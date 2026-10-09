# AGENTS.md — Guide for AI agents working on PaySQL

This file orients AI coding agents (and humans) to the PaySQL repository. It follows the
[agents.md](https://agentsmd.net/) convention.

## What PaySQL is

PaySQL is an open-source **payroll & salary-management platform built on Oracle PL/SQL**, with a
REST API exposed via Oracle REST Data Services (ORDS). The database is the source of truth;
salary logic lives in versioned PL/SQL packages.

## Repository map

| Path | Purpose |
|---|---|
| `docs/` | Documentation site (MkDocs Material) and the modernization proposal |
| `docs/PROPOSAL.md` | The plan and phased roadmap — **read this first** |
| `db/migrations/` | Flyway schema migrations (`V*__*.sql`) |
| `db/migrations/repeatable/` | Source of truth for packages, views, and triggers (`R__*.sql`, numeric-prefixed for compile order) |
| `db/seed/` | Demo data |
| `db/security/` | Least-privilege database roles & grants |
| `api/` | ORDS REST module + security definitions (opt-in layer, not in the Flyway path) |
| `tests/` | utPLSQL test suites |
| `examples/` | Ready-to-run REST API requests |
| `docker/` | Docker Compose for Oracle Free + ORDS *(Phase 1+)* |
| `SalaryManagement/` | Legacy university scripts (historical; see tag `v0-university`) |

## Conventions (please follow)

- SQL objects: `snake_case`, singular table names, correct spelling (`transaction`, `amount`).
- Money: `NUMBER(p,s)`. Dates: `DATE`/`TIMESTAMP`. Never store dates or money as `VARCHAR2`.
- Compensation is **data** (components in reference tables), not hardcoded columns or percentages.
- Raise typed exceptions and log them; do not swallow errors with generic messages.
- One domain per package; migrations for every schema change; Conventional Commits.

## Do not

- Do not deploy or copy patterns from `SalaryManagement/` (legacy, contains a hardcoded password).
- Do not hardcode credentials — use env vars / Oracle Wallet.

## Current phase

See **[docs/PROPOSAL.md](./docs/PROPOSAL.md)** for the roadmap. The project is in **Phase 0
(scaffolding & cleanup)**.
