# Security Policy

## Reporting a vulnerability

If you discover a security vulnerability in PaySQL, please **do not open a public issue**.
Instead, report it privately via [GitHub Security Advisories](../../security/advisories/new)
so it can be addressed before disclosure.

We aim to acknowledge reports within a reasonable timeframe and will coordinate a fix and
disclosure with you.

## Security principles in PaySQL

- **No hardcoded credentials.** Connection secrets come from environment variables or an Oracle
  Wallet — never committed to the repository.
- **Least privilege.** PaySQL installs into a dedicated schema/user with scoped Oracle roles
  (HR, Accountant, Employee, Auditor).
- **Auditability.** Sensitive changes (salary, funds) are recorded in audit tables.

> Note: the legacy coursework scripts (`SalaryManagement/`, tag `v0-university`) contain a
> hardcoded password and are kept only for historical reference. Do not deploy them.
