--------------------------------------------------------------------------------
-- PaySQL :: Triggers :: audit trail
-- Replace the original print-only (dbms_output) triggers with real audit records
-- written to audit_log within the same transaction as the change.
--------------------------------------------------------------------------------

-- Salary revisions ------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_employee_salary_audit
AFTER INSERT OR UPDATE ON employee_salary
FOR EACH ROW
DECLARE
    v_action VARCHAR2(10) := CASE WHEN INSERTING THEN 'INSERT' ELSE 'UPDATE' END;
BEGIN
    INSERT INTO audit_log (table_name, action, record_id, old_value, new_value)
    VALUES ('EMPLOYEE_SALARY',
            v_action,
            TO_CHAR(:NEW.employee_salary_id),
            CASE WHEN UPDATING THEN
                'employee_id=' || :OLD.employee_id ||
                ';valid_from=' || TO_CHAR(:OLD.valid_from, 'YYYY-MM-DD') ||
                ';valid_to='   || TO_CHAR(:OLD.valid_to,   'YYYY-MM-DD')
            END,
            'employee_id=' || :NEW.employee_id ||
            ';valid_from=' || TO_CHAR(:NEW.valid_from, 'YYYY-MM-DD') ||
            ';valid_to='   || TO_CHAR(:NEW.valid_to,   'YYYY-MM-DD'));
END;
/

-- Fund balance changes --------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_fund_audit
AFTER UPDATE ON fund
FOR EACH ROW
WHEN (OLD.balance <> NEW.balance)
BEGIN
    INSERT INTO audit_log (table_name, action, record_id, old_value, new_value)
    VALUES ('FUND',
            'UPDATE',
            TO_CHAR(:NEW.fund_id),
            'balance=' || :OLD.balance,
            'balance=' || :NEW.balance);
END;
/

-- Salary payments -------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_salary_payment_audit
AFTER INSERT ON salary_payment
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, action, record_id, new_value)
    VALUES ('SALARY_PAYMENT',
            'INSERT',
            TO_CHAR(:NEW.salary_payment_id),
            'employee_id=' || :NEW.employee_id ||
            ';period_id=' || :NEW.pay_period_id ||
            ';amount='    || :NEW.amount);
END;
/
