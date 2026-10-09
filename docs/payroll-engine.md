# Payroll Engine

!!! note "Built in Phase 2"
    The calculation engine and pay-run lifecycle will be documented here.

## Pay-run lifecycle

```
DRAFT ─► CALCULATED ─► APPROVED ─► POSTED ─► PAID ─► CLOSED
```

Each transition is idempotent and reversible, with full audit logging.

## Calculation

Salary is computed from configurable **components** and **rules** (tax slabs, loss-of-pay from
leave, provident fund, loans), not hardcoded percentages. The engine entry point is planned as
`pkg_payroll.run(period)`.
