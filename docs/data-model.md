# Data Model

!!! note "Designed in Phase 1"
    The redesigned schema and its ERD will be documented here. See the
    [proposal](./PROPOSAL.md) for the data-model direction.

## Direction

- Proper datatypes: money as `NUMBER(p,s)`, dates as `DATE`/`TIMESTAMP`, correct spelling of
  objects (`transaction`, `amount`).
- **Component-based compensation** — earnings and deductions defined in reference tables.
- **Effective-dated salary history** (`valid_from` / `valid_to`).
- Core entities: employees, departments, job grades, pay components, salary structures, pay
  periods, pay runs, payslips, leave types & requests, loans/advances, funds, audit log.

An entity-relationship diagram (ERD) will be added at `docs/images/erd.png`.
