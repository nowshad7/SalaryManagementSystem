# API

!!! note "Built in Phase 3"
    PaySQL exposes a REST API via Oracle REST Data Services (ORDS). Endpoint definitions will live
    under `api/` and be documented here.

## Planned resources (illustrative)

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/employees` | List employees |
| `POST` | `/employees` | Create an employee |
| `GET` | `/employees/{id}/payslips` | Employee payslip history |
| `POST` | `/payruns` | Start a pay run for a period |
| `POST` | `/payruns/{id}/approve` | Approve a pay run |
| `GET` | `/payruns/{id}/register` | Payroll register for a run |

Access is role-based (see [Roles & Security](./roles-and-security.md)).
