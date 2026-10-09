# Architecture

!!! note "Expanding through Phases 1–3"
    This page documents the target architecture as it is built. See the
    [proposal](./PROPOSAL.md) for the full plan.

## Overview

PaySQL keeps the **database as the source of truth**. Salary logic lives in versioned PL/SQL
packages; clients interact through a REST API.

```
Clients (web / mobile / AI agents)
        │  HTTPS / REST
        ▼
   ORDS (Oracle REST Data Services)
        │  PL/SQL calls
        ▼
   PL/SQL packages  ──►  Tables, views, audit log
   (pkg_employee, pkg_payroll, pkg_leave, pkg_tax, pkg_audit)
```

## Layers

- **Data layer** — normalized schema, effective-dated salary history, component-based compensation.
- **Engine layer** — domain packages implementing the pay-run lifecycle and calculation rules.
- **API layer** — ORDS modules exposing REST endpoints with role-based access.

## Tooling

- **Flyway** for versioned, repeatable migrations.
- **utPLSQL** for unit tests.
- **Docker** for a reproducible Oracle Free + ORDS environment.
- **GitHub Actions** for CI.
