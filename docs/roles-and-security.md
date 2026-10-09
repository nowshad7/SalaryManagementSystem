# Roles & Security

PaySQL uses least-privilege roles at two layers: **database roles** (what each persona can touch
in SQL) and **ORDS roles** (who can call which REST endpoints).

## Personas

| Role | Capabilities |
|---|---|
| **HR / Admin** | Manage employees, job grades, salary assignments & components |
| **Accountant** | Run payroll (the full lifecycle), manage funds, record/approve leave |
| **Employee** | View own payslips and payment history |
| **Auditor** | Read-only access, including audit trails |

## Database roles

Defined in [`db/security/roles.sql`](../db/security/roles.sql) (run by a DBA):
`paysql_hr`, `paysql_accountant`, `paysql_employee`, `paysql_auditor`. Each receives only the
object and package privileges its persona needs — e.g. only `paysql_accountant` can
`EXECUTE pkg_payroll`, and only `paysql_auditor` can read `audit_log`/`error_log`.

## API roles (ORDS)

Defined in [`api/ords_security.sql`](../api/ords_security.sql): ORDS roles
(`PaySQL HR`, `PaySQL Accountant`, `PaySQL Employee`, `PaySQL Auditor`) and a privilege that
protects the `/v1/` module. Callers authenticate with an OAuth2 bearer token tied to a client
that holds the right role.

```
Client → OAuth2 token (role) → ORDS privilege check → /v1/ endpoint → PL/SQL engine
```

## Principles

- **No hardcoded credentials** — secrets come from environment variables / Oracle Wallet.
- **Least privilege** — a dedicated `PAYSQL` schema; roles grant only what each persona needs.
- **Auditability** — salary, fund and payment changes are recorded in `audit_log` in-transaction.
- **Shared rules** — REST and SQL both go through the same PL/SQL packages, so security and
  validation can't be bypassed by picking a different entry point.

## Planned hardening

- **Row-Level Security (VPD)** so an employee can only read their own rows at the database level
  (today that filtering is applied at the API layer).
- A `security-review` pass before the first tagged release.
