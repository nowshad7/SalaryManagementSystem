# Payroll Engine

The engine lives in PL/SQL packages under
[`db/migrations/repeatable/`](../db/migrations/repeatable) (repeatable migrations, so
`CREATE OR REPLACE` re-applies them on change).

## Packages

| Package | Responsibility |
|---|---|
| `pkg_error` | Logs exceptions to `error_log` (autonomous transaction), then re-raises |
| `pkg_tax` | Progressive tax from the `tax_slab` table |
| `pkg_leave` | Leave requests + unpaid-days calculation (feeds loss-of-pay) |
| `pkg_employee` | Add employees, effective-dated salary revisions, components, termination |
| `pkg_payroll` | The pay-run engine and lifecycle |

## Pay-run lifecycle

```
DRAFT ─► CALCULATED ─► APPROVED ─► POSTED ─► PAID ─► CLOSED
```

Each transition is a guarded procedure (`assert_status` rejects out-of-order calls), and every
procedure logs failures to `error_log` before re-raising.

```sql
-- End-to-end run for a period
DECLARE
    v_run NUMBER;
BEGIN
    v_run := pkg_payroll.calculate('2026-01');   -- builds payslips  -> CALCULATED
    pkg_payroll.approve(v_run, 'alice');         -- -> APPROVED
    pkg_payroll.post(v_run);                      -- payslips FINAL   -> POSTED
    pkg_payroll.pay(v_run, 'MAIN');               -- pays from fund   -> PAID
    pkg_payroll.close_run(v_run);                 -- locks period     -> CLOSED
END;
/
```

`calculate` is **re-runnable** while the run is `DRAFT`/`CALCULATED` (it clears and rebuilds
payslips). Once a run is `APPROVED` or beyond, recalculating the period is blocked.

## Calculation rules

For each active employee with a salary revision effective on the period end date:

1. **Earnings** come from the salary structure (`employee_salary_component`), evaluated by each
   component's `calculation_method` (`FIXED`, `PERCENT_OF_BASIC`).
2. **Loss of pay (LOP)** = `basic / days_in_period × unpaid_leave_days`.
3. **Provident fund (PF)** = `basic × PF.default_rate`.
4. **Tax** = `pkg_tax.calc_tax(taxable_earnings − LOP)` using the slabs effective that period.
5. **Net pay** = gross earnings − (LOP + PF + tax). Each line is written to `payslip_line`.

## Idempotent payments

`pkg_payroll.pay` inserts one `salary_payment` per employee per period. The
`UNIQUE (employee_id, pay_period_id)` constraint makes double payment impossible — the engine
catches `DUP_VAL_ON_INDEX` and skips, so re-running is safe. This replaces the original
`Check_Valid` cursor scan.

## Audit

Triggers (`trg_employee_salary_audit`, `trg_fund_audit`, `trg_salary_payment_audit`) record
changes to `audit_log` within the same transaction — replacing the original print-only triggers.
