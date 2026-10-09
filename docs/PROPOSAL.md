# Modernization Proposal — Open-Source PL/SQL Salary Management Platform

> **Status:** Draft / Plan only — no product code changed yet.
> **Goal:** Turn this university-origin PL/SQL project into a professional, well-documented,
> highly discoverable open-source **payroll & salary-management platform** — the
> "Bagisto/Magento of payroll, built on Oracle PL/SQL."
> **Chosen scope:** Full product stack (ORDS REST API + Flyway migrations + utPLSQL tests +
> Docker + docs site).

---

## 1. Where the repo stands today

The current repository is a solid university project: the core payroll idea is sound
(employees → salary → leave-based deduction → pay run → company fund). The gap is entirely
between "class project" and "open-source product."

| What's there | Reality check |
|---|---|
| 6 tables + 2 audit tables, 1 package, a few procedures/functions, print-only triggers | Good conceptual foundation |
| "UI" = SQL\*Plus anonymous blocks with `&Name`, `&Eid` substitution prompts | Main thing that reads as "class project," not product |
| `LinkUp.sql` has a hardcoded password (`system/"123456"`) + a distributed DB link | Security red flag + not reproducible for others |
| Dates stored as `varchar2(20)`, email `varchar2(20)`, money as `int` | Wrong datatypes — breaks sorting, math, real data |
| Typos in schema: `TRANSECTION`, `ammount`, `'Fab/19'` | A product can't ship misspelled object names |
| `Check_Valid` loops every row; salary rules (3/5 days, 5%/7%) hardcoded in the function | Not scalable, not configurable |
| Every exception handler is `'Something wrong happened'` | Swallows real errors — undebuggable |
| No license, tests, CI, installer, or versioning; README links a blog + a PDF | No "product" scaffolding |

None of this is a criticism of the original work — it is simply the backlog to close.

---

## 2. What a modern PL/SQL salary/payroll system should have (built in 2026)

### Core domain (data model)
- **People & org:** Employees, Departments, Job titles/grades, employment status, pay cycles.
- **Compensation as components** (not fixed columns): *earnings* (basic, housing, transport,
  medical, bonus, overtime) and *deductions* (tax, provident fund, loan/advance, insurance,
  loss-of-pay), all driven by a `pay_component` reference table so companies add their own.
- **Effective-dated salary history** (`valid_from` / `valid_to`) so a raise never destroys the
  prior record. (Today's audit tables are the seed of this idea, done properly.)
- **Pay periods & pay runs** with a real lifecycle:
  `DRAFT → CALCULATED → APPROVED → POSTED → PAID → CLOSED` — reversible and idempotent.
  (The current `Check_Valid` "already paid?" check is the embryo of this.)
- **Leave** with leave *types* and accruals feeding loss-of-pay.
- **Tax slabs / statutory rules** in config tables (country-aware), not `if basic*0.05`.
- **Loans & advances**, reimbursements, final settlement, multi-currency, proration for
  mid-period joiners/leavers.

### The engine
- A **rules-driven calculation engine**: `pkg_payroll.run(period)` reads components + rules,
  computes each payslip, writes results, and logs everything — configurable, not hardcoded.
- Proper **payslip** and **payroll register** outputs.

### How it's built (the modern stack that makes it a *product*)

| Concern | Old way (now) | Modern way (this plan) |
|---|---|---|
| Install | Run scripts by hand in order | **Flyway/Liquibase** versioned migrations — one command, repeatable |
| Access | SQL\*Plus `&` prompts | **ORDS (Oracle REST Data Services)** → REST API for web/mobile/AI |
| Code org | Loose `.sql` files | Domain **packages** (`pkg_employee`, `pkg_payroll`, `pkg_leave`, `pkg_tax`, `pkg_audit`) with spec/body, custom exceptions, error-log table |
| Security | Hardcoded `system` password | Dedicated schema/user, Oracle **roles** (HR/Accountant/Employee/Auditor), least privilege, secrets in env/wallet |
| Testing | None | **utPLSQL** unit tests |
| Reproducibility | "install Oracle yourself" | **Docker Compose** → Oracle Free + ORDS + auto-migrate, one `docker compose up` |
| CI | None | **GitHub Actions**: spin Oracle Free, run migrations + utPLSQL on every PR |

---

## 3. Target repository organization

```
salary-management-system/
├── README.md                 ← hero, badges, 60-second quickstart, ERD, feature matrix
├── LICENSE                    ← MIT or Apache-2.0
├── CONTRIBUTING.md  CODE_OF_CONDUCT.md  SECURITY.md  CHANGELOG.md
├── AGENTS.md / CLAUDE.md      ← machine-readable project guide for AI agents
├── llms.txt                   ← AI-crawler summary of the project
├── CITATION.cff               ← citable (valuable for an academic-origin repo)
├── .github/
│   ├── workflows/ci.yml       ← Oracle Free + migrations + utPLSQL
│   ├── ISSUE_TEMPLATE/  PULL_REQUEST_TEMPLATE.md  FUNDING.yml
├── docs/                      ← MkDocs-Material site (indexable, searchable)
│   ├── index, getting-started, architecture, data-model (ERD),
│   │   payroll-engine, api, configuration, roles-and-security
├── db/
│   ├── migrations/            ← Flyway: V1.0.0__reference.sql, V1.1.0__hr.sql,
│   │   │                          V1.2.0__compensation.sql, V1.3.0__payroll.sql
│   │   └── repeatable/        ← R__pkg_payroll.sql (re-applied on change)
│   ├── packages/              ← readable source of truth for each package
│   ├── views/                 ← payslip, payroll register, reports
│   └── seed/                  ← demo company + employees (one command)
├── api/                       ← ORDS module / endpoint definitions
├── tests/                     ← utPLSQL suites mirroring packages
├── docker/                    ← docker-compose.yml, bootstrap
├── examples/                  ← sample REST calls, SQL recipes
└── legacy/ (or git tag v0-university)  ← original scripts preserved
```

---

## 4. Documentation plan

- **README as a landing page:** one-line value prop, badges (license, CI, release), an ERD
  image, a feature table, a copy-paste quickstart (`docker compose up` → hit a REST endpoint),
  screenshots/diagrams.
- **`docs/` site** via MkDocs Material (free, GitHub-Pages-hostable, full-text search):
  architecture, data model + ERD, payroll engine explained, API reference, configuration,
  security/roles.
- **Data dictionary** (every table/column documented) + an **ERD** generated from the schema.
- **Contribution docs** so others can extend it (extensibility is documented — the Bagisto trick).

---

## 5. Cleanup

- ❌ Delete `ProjectReport_160104061.pdf`.
- ❌ Remove the blogspot link from `README.md`; replace with the docs site.
- 🔁 Keep the original logic but migrate it into the new structure — rename
  `TRANSECTION` → `transaction`, `ammount` → `amount`, fix datatypes.
- 🗄️ Preserve origin in `legacy/` or a git tag `v0-university`.

---

## 6. Discoverability — for AI agents *and* search engines

- **GitHub topics/tags:** `payroll`, `plsql`, `oracle`, `salary-management`, `hr`, `ords`,
  `open-source-payroll`.
- **SEO-rich README & docs** with real search phrases ("open source payroll system",
  "Oracle PL/SQL salary management", "ORDS payroll API").
- **`AGENTS.md` + `llms.txt`:** emerging standard files that let AI coding agents and LLM
  crawlers understand the project at a glance.
- **`CITATION.cff`** + **semantic-versioned GitHub Releases** with changelogs.
- **Published docs site** (GitHub Pages) → indexed by search engines.
- Clean one-liner description + listing-ready blurb (fits "awesome-payroll" / "awesome-oracle" lists).

---

## 7. Product positioning (the Bagisto/Magento angle)

Frame it as: **"An open-source, modular, REST-ready payroll & salary-management platform on
Oracle PL/SQL."** Modular packages + config-driven components + seed/demo data + one-command
install + documented extension points = the same recipe that makes Bagisto feel like a
platform, not a script.

**Product name ideas** (repo can keep `SalaryManagementSystem` for continuity + stars, and carry
a product name in branding): **PaySQL**, **OpenPayroll (PL/SQL Edition)**, **SalaryForge**,
**Paygrid**.

---

## 8. Phased roadmap

| Phase | Theme | Deliverables |
|---|---|---|
| **0** | Scaffolding & cleanup | License, docs skeleton, remove PDF/blog, repo topics, `AGENTS.md`/`llms.txt`, CI stub |
| **1** | Data model redesign | Fix datatypes/typos, components model, effective-dated salary, Flyway migrations + seed data + Docker |
| **2** | Engine & packages | Domain packages, rules-driven pay-run lifecycle, real exception handling + error log, utPLSQL tests |
| **3** | API & reporting | ORDS REST endpoints, payslip/register views, role-based security |
| **4** | Polish & launch | Full docs site, ERD, screenshots, first tagged release, discoverability pass |

---

*This document is a plan. Implementation begins only when approved.*
