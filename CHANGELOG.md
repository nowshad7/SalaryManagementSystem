# Changelog

All notable changes to PaySQL are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/) and the project aims to follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
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
