--------------------------------------------------------------------------------
-- PaySQL :: Repeatable :: Reporting views
-- Re-applied by Flyway whenever this file changes (CREATE OR REPLACE is idempotent).
--------------------------------------------------------------------------------

-- Each employee's currently-active salary revision.
CREATE OR REPLACE VIEW v_current_salary AS
SELECT es.employee_salary_id,
       es.employee_id,
       e.employee_code,
       e.first_name,
       e.last_name,
       es.currency_code,
       es.valid_from,
       es.valid_to
FROM   employee_salary es
JOIN   employee e ON e.employee_id = es.employee_id
WHERE  TRUNC(SYSDATE) >= es.valid_from
AND    (es.valid_to IS NULL OR TRUNC(SYSDATE) <= es.valid_to);

-- Flattened payslip breakdown: one row per component on each payslip.
CREATE OR REPLACE VIEW v_payslip_detail AS
SELECT ps.payslip_id,
       ps.pay_run_id,
       pp.period_code,
       e.employee_code,
       e.first_name,
       e.last_name,
       pc.code        AS component_code,
       pc.name        AS component_name,
       pc.component_type,
       pl.amount,
       ps.gross_earnings,
       ps.total_deductions,
       ps.net_pay,
       ps.currency_code
FROM   payslip ps
JOIN   pay_run pr      ON pr.pay_run_id = ps.pay_run_id
JOIN   pay_period pp   ON pp.pay_period_id = pr.pay_period_id
JOIN   employee e      ON e.employee_id = ps.employee_id
JOIN   payslip_line pl ON pl.payslip_id = ps.payslip_id
JOIN   pay_component pc ON pc.pay_component_id = pl.pay_component_id;

-- Payroll register: totals per pay run.
CREATE OR REPLACE VIEW v_payroll_register AS
SELECT pr.pay_run_id,
       pp.period_code,
       pp.period_name,
       pr.status,
       COUNT(ps.payslip_id)        AS employees,
       SUM(ps.gross_earnings)      AS total_gross,
       SUM(ps.total_deductions)    AS total_deductions,
       SUM(ps.net_pay)             AS total_net
FROM   pay_run pr
JOIN   pay_period pp ON pp.pay_period_id = pr.pay_period_id
LEFT   JOIN payslip ps ON ps.pay_run_id = pr.pay_run_id
GROUP  BY pr.pay_run_id, pp.period_code, pp.period_name, pr.status;
