--------------------------------------------------------------------------------
-- PaySQL :: Security :: Database roles & grants
--
-- Defines least-privilege Oracle roles for the four PaySQL personas and grants
-- each only what it needs. Run by a DBA (CREATE ROLE requires the privilege),
-- or adapt the grants to your access model.
--
-- Employee self-service (an employee seeing only their own rows) is enforced at
-- the API layer here; database-level Row-Level Security (VPD) is a planned
-- hardening step.
--------------------------------------------------------------------------------

-- Roles -----------------------------------------------------------------------
CREATE ROLE paysql_hr;
CREATE ROLE paysql_accountant;
CREATE ROLE paysql_employee;
CREATE ROLE paysql_auditor;

-- HR / Admin: manage people and compensation -----------------------------------
GRANT EXECUTE ON paysql.pkg_employee TO paysql_hr;
GRANT SELECT, INSERT, UPDATE ON paysql.employee                    TO paysql_hr;
GRANT SELECT, INSERT, UPDATE ON paysql.employee_salary             TO paysql_hr;
GRANT SELECT, INSERT, UPDATE ON paysql.employee_salary_component   TO paysql_hr;
GRANT SELECT ON paysql.department   TO paysql_hr;
GRANT SELECT ON paysql.job_grade    TO paysql_hr;
GRANT SELECT ON paysql.pay_component TO paysql_hr;
GRANT SELECT ON paysql.v_current_salary TO paysql_hr;

-- Accountant: run payroll, funds, leave ----------------------------------------
GRANT EXECUTE ON paysql.pkg_payroll TO paysql_accountant;
GRANT EXECUTE ON paysql.pkg_leave   TO paysql_accountant;
GRANT SELECT, INSERT, UPDATE ON paysql.fund TO paysql_accountant;
GRANT SELECT ON paysql.employee            TO paysql_accountant;
GRANT SELECT ON paysql.v_payroll_register  TO paysql_accountant;
GRANT SELECT ON paysql.v_payslip_detail    TO paysql_accountant;

-- Employee: read own payslips (row filtering applied by the API) ----------------
GRANT SELECT ON paysql.v_payslip_detail TO paysql_employee;

-- Auditor: read-only, including audit trails -----------------------------------
GRANT SELECT ON paysql.v_payroll_register TO paysql_auditor;
GRANT SELECT ON paysql.v_payslip_detail   TO paysql_auditor;
GRANT SELECT ON paysql.v_current_salary   TO paysql_auditor;
GRANT SELECT ON paysql.audit_log          TO paysql_auditor;
GRANT SELECT ON paysql.error_log          TO paysql_auditor;
