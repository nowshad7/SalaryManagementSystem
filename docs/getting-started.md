# Getting Started

PaySQL runs on Oracle Database Free. Phase 1 ships the schema, migrations, and demo data. The
REST API (ORDS) arrives in Phase 3 — see the [roadmap](./PROPOSAL.md).

## Option A — Docker (recommended)

Brings up Oracle Free, creates the `paysql` user, and applies all migrations + demo data.

```bash
git clone https://github.com/nowshad7/SalaryManagementSystem.git
cd SalaryManagementSystem/docker
cp .env.example .env        # then edit the passwords
docker compose up
```

When Flyway finishes, connect and explore:

```sql
-- connect as paysql to //localhost:1521/FREEPDB1
SELECT * FROM v_current_salary;
SELECT * FROM v_payroll_register;
```

## Option B — Flyway against an existing database

```bash
export FLYWAY_PASSWORD='your-paysql-password'
flyway -url='jdbc:oracle:thin:@//HOST:1521/FREEPDB1' -user=paysql migrate
```

Configuration lives in [`flyway.conf`](../flyway.conf). Remove the `db/seed` location for a
production (no demo data) install.

## Option C — Manual (SQL*Plus / SQLcl)

```sql
-- connect as the PAYSQL user, from the repo root
@db/install.sql
```

Comment out the seed line in `db/install.sql` for a clean install.

## What you get

- A normalized, component-based payroll schema (see [Data Model](./data-model.md))
- A demo company with 10 employees migrated from the original project
- Reporting views ready to query

## Legacy scripts

The original university coursework is preserved under `SalaryManagement/`. It is for historical
reference only and should not be deployed.
