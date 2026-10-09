# Roles & Security

!!! note "Implemented in Phases 2–3"
    Role definitions and the security model will be documented here.

## Roles

| Role | Capabilities |
|---|---|
| **HR / Admin** | Manage employees, job grades, salary assignments |
| **Accountant** | Run payroll, manage funds, record leave |
| **Employee** | View own payslips and payment history |
| **Auditor** | Read-only access to audit trails |

## Principles

- Dedicated schema/user with least-privilege Oracle roles.
- No hardcoded credentials — secrets from env vars / Oracle Wallet.
- Audit trails for sensitive changes (salary, funds).

See also [SECURITY.md](../SECURITY.md).
