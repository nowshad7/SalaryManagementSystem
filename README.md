<div align="center">

# PaySQL

### Open-source, modular, REST-ready payroll & salary-management platform — built on Oracle PL/SQL

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![PL/SQL](https://img.shields.io/badge/Oracle-PL%2FSQL-F80000?logo=oracle&logoColor=white)](https://www.oracle.com/database/)
[![Status](https://img.shields.io/badge/status-modernization%20in%20progress-blue.svg)](./docs/PROPOSAL.md)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](./CONTRIBUTING.md)

</div>

---

**PaySQL** is an open-source payroll engine written in Oracle PL/SQL. It manages employees,
compensation, leave, tax/statutory deductions, and full pay-run cycles — with the database as
the source of truth and a REST API (via Oracle REST Data Services) for any web, mobile, or
AI-agent client to build on.

> Think "Bagisto/Magento for payroll," but PL/SQL-native: modular packages, config-driven
> compensation components, one-command install, seed data, and documented extension points.

## ✨ Why PaySQL

- **Database-native engine** — salary logic lives in versioned PL/SQL packages, not scattered app code.
- **Component-based compensation** — earnings and deductions are configurable data, not hardcoded columns.
- **Real pay-run lifecycle** — `DRAFT → CALCULATED → APPROVED → POSTED → PAID → CLOSED`, idempotent and reversible.
- **REST-ready** — exposed through Oracle REST Data Services (ORDS) for web/mobile/AI clients.
- **Reproducible** — Flyway migrations + Docker + utPLSQL tests + CI.
- **Discoverable & documented** — full docs site, ERD, and machine-readable guides for AI agents.

## 📦 Project status

PaySQL began as a university PL/SQL project and is being modernized into a production-grade
open-source product. Development is phased — see the plan and roadmap:

- 📋 **[Modernization Proposal & Roadmap](./docs/PROPOSAL.md)**
- 📚 **[Documentation](./docs/index.md)**

> The original coursework scripts live under `SalaryManagement/` and are preserved at the
> `v0-university` git tag while the new structure is built out.

## 🚀 Quickstart

Spin up Oracle Free with the full schema and demo data:

```bash
git clone https://github.com/nowshad7/SalaryManagementSystem.git
cd SalaryManagementSystem/docker
cp .env.example .env        # edit the passwords
docker compose up           # Oracle Free + Flyway migrations + demo data
```

Then query the demo company:

```sql
SELECT * FROM v_current_salary;
SELECT * FROM v_payroll_register;
```

See the [getting-started guide](./docs/getting-started.md) for Flyway and manual (SQL*Plus)
installs, and the [REST API docs](./docs/api.md) to expose it over HTTP via ORDS.

## 🧩 Roles

| Role | Can do |
|---|---|
| **HR / Admin** | Manage employees, job grades, salary assignments |
| **Accountant** | Run payroll, manage funds, record leave |
| **Employee** | View own payslips and payment history |
| **Auditor** | Read-only access to audit trails |

## 🤝 Contributing

PaySQL is open source and contributions are welcome — see [CONTRIBUTING.md](./CONTRIBUTING.md)
and our [Code of Conduct](./CODE_OF_CONDUCT.md).

## 📄 License

[MIT](./LICENSE) © PaySQL contributors.

<div align="center">
<sub>Keywords: open source payroll · Oracle PL/SQL salary management · ORDS payroll API · HR payroll database · open source HRIS</sub>
</div>
