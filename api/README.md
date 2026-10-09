# PaySQL REST API (ORDS)

This directory defines the PaySQL REST API using Oracle REST Data Services (ORDS). The scripts
are version-controlled definitions you run against a database where ORDS is installed; they are
**not** part of the Flyway migration path (so `docker compose up` stays focused on the schema).

## Prerequisites

- PaySQL schema + engine installed (Flyway migrations / `db/install.sql`)
- ORDS installed and running against the same database
- Privileges to REST-enable the `PAYSQL` schema

## Install order

```sql
-- connect as PAYSQL
@api/ords_enable.sql     -- REST-enable the schema (base path /paysql/)
@api/ords_modules.sql    -- define the /v1/ module, templates and handlers
@api/ords_security.sql   -- create ORDS roles + privilege (adapt to your ORDS/APEX setup)
```

Then register an OAuth2 client and grant it a role (see the bottom of `ords_security.sql`).

## Base URL

```
https://<host>/ords/paysql/v1/
```

## Endpoints

| Method | Path | Role | Purpose |
|---|---|---|---|
| GET  | `/employees` | HR, Auditor | List employees |
| POST | `/employees` | HR | Create an employee |
| GET  | `/employees/{id}` | HR, Auditor | Employee detail |
| GET  | `/employees/{id}/payslips` | HR, Employee, Auditor | Payslip history |
| GET  | `/payslips/{id}` | HR, Employee, Auditor | Payslip line items |
| GET  | `/payruns` | Accountant, Auditor | All pay runs (register summary) |
| POST | `/payruns` | Accountant | Calculate a run (`{"period_code":"2026-01"}`) |
| POST | `/payruns/{id}/approve` | Accountant | Approve (`{"approved_by":"alice"}`) |
| POST | `/payruns/{id}/post` | Accountant | Post |
| POST | `/payruns/{id}/pay` | Accountant | Pay (`{"fund_code":"MAIN"}`) |
| POST | `/payruns/{id}/close` | Accountant | Close |
| GET  | `/payruns/{id}/register` | Accountant, Auditor | Register for one run |

See [`examples/rest-api.http`](../examples/rest-api.http) for ready-to-run requests.

> The handlers call the Phase 2 PL/SQL engine directly, so the REST API and any SQL*Plus usage
> share exactly the same business rules.
