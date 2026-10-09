# Changelog

All notable changes to PaySQL are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/) and the project aims to follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

_Nothing yet._

## [1.0.0] - 2026-10-09

First release of modernized PaySQL — a complete, documented, open-source PL/SQL payroll platform.

### Added
- **Phase 4 — polish & launch:** architecture diagram (`docs/images/architecture.svg`),
  deployable MkDocs Material site with Mermaid rendering and a GitHub Pages workflow
  (`.github/workflows/docs.yml`), `ROADMAP.md`, discoverability finish, and release preparation.
- **Phase 3 — API & security:** a versioned ORDS REST API (`api/ords_modules.sql`) over the
  engine — employees, payslips, and the full pay-run lifecycle under `/paysql/v1/` — plus schema
  REST-enablement (`api/ords_enable.sql`) and API protection (`api/ords_security.sql`).
  Least-privilege database roles (`db/security/roles.sql`) for the HR/Accountant/Employee/Auditor
  personas, an optional ORDS Docker overlay (`docker/docker-compose.ords.yml`), runnable request
  examples (`examples/rest-api.http`), and expanded API/security docs.
- **Phase 2 — engine & packages:** PL/SQL packages as repeatable migrations —
  `pkg_error` (autonomous error logging), `pkg_tax` (progressive tax from `tax_slab`),
  `pkg_leave` (leave + unpaid-days), `pkg_employee` (effective-dated salary management), and
  `pkg_payroll` (the rules-driven pay-run engine with a guarded
  DRAFT→CALCULATED→APPROVED→POSTED→PAID→CLOSED lifecycle and idempotent payments). Real audit
  triggers writing to `audit_log`, and a utPLSQL test suite (`tests/ut_payroll.pkg.sql`).
- **Phase 1 — data model redesign:** normalized, component-based, effective-dated schema as
  Flyway migrations (`db/migrations/`): reference tables, core HR, compensation, payroll, and
  audit/error logging. Reporting views (`v_current_salary`, `v_payslip_detail`,
  `v_payroll_register`), demo seed data migrating the original 10 employees (`db/seed/`), a
  SQL*Plus installer (`db/install.sql`), Flyway config, and a Docker Compose stack
  (Oracle Free + Flyway). Fixes original datatype and spelling issues (dates, money,
  `TRANSECTION`→`salary_payment`, `ammount`→`amount`) and replaces the `Check_Valid` cursor
  with a uniqueness constraint.
- **Phase 0 — scaffolding & cleanup:** MIT license, project rebranded to **PaySQL**,
  documentation skeleton (`docs/`), community health files (contributing, code of conduct,
  security), AI/SEO discoverability files (`AGENTS.md`, `llms.txt`, `CITATION.cff`),
  GitHub issue/PR templates, and a CI workflow stub.
- Modernization proposal and roadmap (`docs/PROPOSAL.md`).

### Removed
- Legacy project report PDF and the external blog link from the README.

### Preserved
- Original university coursework scripts under `SalaryManagement/` (git tag `v0-university`).

---

_Earlier history: the project began as a university PL/SQL distributed-database salary
management system._
