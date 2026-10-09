--------------------------------------------------------------------------------
-- PaySQL :: Package :: pkg_payroll
-- The rules-driven payroll engine and pay-run lifecycle:
--   DRAFT -> CALCULATED -> APPROVED -> POSTED -> PAID -> CLOSED
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_payroll AS
    -- Build (or rebuild, while DRAFT/CALCULATED) payslips for a period.
    -- Returns the pay_run id. Leaves the run in status CALCULATED.
    FUNCTION calculate(p_period_code IN VARCHAR2) RETURN NUMBER;

    PROCEDURE approve(p_pay_run_id IN NUMBER, p_approved_by IN VARCHAR2);
    PROCEDURE post(p_pay_run_id IN NUMBER);
    PROCEDURE pay(p_pay_run_id IN NUMBER, p_fund_code IN VARCHAR2 DEFAULT 'MAIN');
    PROCEDURE close_run(p_pay_run_id IN NUMBER);
END pkg_payroll;
/

CREATE OR REPLACE PACKAGE BODY pkg_payroll AS

    c_country CONSTANT VARCHAR2(2) := 'US';

    -- Guard: confirm a run is in the expected status before a transition.
    PROCEDURE assert_status(p_pay_run_id IN NUMBER, p_expected IN VARCHAR2) IS
        v_status pay_run.status%TYPE;
    BEGIN
        SELECT status INTO v_status FROM pay_run WHERE pay_run_id = p_pay_run_id;
        IF v_status <> p_expected THEN
            RAISE_APPLICATION_ERROR(-20032,
                'Pay run ' || p_pay_run_id || ' is ' || v_status ||
                '; expected ' || p_expected || '.');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20033, 'Pay run not found: ' || p_pay_run_id);
    END assert_status;

    FUNCTION calculate(p_period_code IN VARCHAR2) RETURN NUMBER IS
        v_period_id   pay_period.pay_period_id%TYPE;
        v_start       pay_period.start_date%TYPE;
        v_end         pay_period.end_date%TYPE;
        v_pstatus     pay_period.status%TYPE;
        v_run_id      pay_run.pay_run_id%TYPE;
        v_locked      PLS_INTEGER;
        v_days        NUMBER;

        v_pf_id       pay_component.pay_component_id%TYPE;
        v_pf_rate     pay_component.default_rate%TYPE;
        v_tax_id      pay_component.pay_component_id%TYPE;
        v_lop_id      pay_component.pay_component_id%TYPE;

        v_slip_id     payslip.payslip_id%TYPE;
        v_basic       NUMBER;
        v_gross       NUMBER;
        v_taxable     NUMBER;
        v_ded         NUMBER;
        v_pf          NUMBER;
        v_tax         NUMBER;
        v_lop         NUMBER;
        v_unpaid      NUMBER;
        v_rev_id      employee_salary.employee_salary_id%TYPE;
    BEGIN
        -- Resolve the period.
        BEGIN
            SELECT pay_period_id, start_date, end_date, status
            INTO   v_period_id, v_start, v_end, v_pstatus
            FROM   pay_period WHERE period_code = p_period_code;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20030, 'Unknown pay period: ' || p_period_code);
        END;

        IF v_pstatus = 'CLOSED' THEN
            RAISE_APPLICATION_ERROR(-20031, 'Pay period is closed: ' || p_period_code);
        END IF;

        -- A period may not be recalculated once a run is approved or beyond.
        SELECT COUNT(*) INTO v_locked
        FROM   pay_run
        WHERE  pay_period_id = v_period_id
        AND    status NOT IN ('DRAFT','CALCULATED');
        IF v_locked > 0 THEN
            RAISE_APPLICATION_ERROR(-20034,
                'Period ' || p_period_code || ' already has an approved/posted run.');
        END IF;

        -- Reuse an existing DRAFT/CALCULATED run, or create one.
        BEGIN
            SELECT pay_run_id INTO v_run_id
            FROM   pay_run
            WHERE  pay_period_id = v_period_id
            AND    status IN ('DRAFT','CALCULATED')
            FETCH FIRST 1 ROWS ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                INSERT INTO pay_run (pay_period_id, status)
                VALUES (v_period_id, 'DRAFT')
                RETURNING pay_run_id INTO v_run_id;
        END;

        -- Clear any prior calculation for this run.
        DELETE FROM payslip_line WHERE payslip_id IN
            (SELECT payslip_id FROM payslip WHERE pay_run_id = v_run_id);
        DELETE FROM payslip WHERE pay_run_id = v_run_id;

        v_days := (v_end - v_start) + 1;

        -- Standard deduction components (may be absent in minimal installs).
        BEGIN
            SELECT pay_component_id, default_rate INTO v_pf_id, v_pf_rate
            FROM pay_component WHERE code = 'PF' AND is_active = 1;
        EXCEPTION WHEN NO_DATA_FOUND THEN v_pf_id := NULL; END;
        BEGIN
            SELECT pay_component_id INTO v_tax_id
            FROM pay_component WHERE code = 'TAX' AND is_active = 1;
        EXCEPTION WHEN NO_DATA_FOUND THEN v_tax_id := NULL; END;
        BEGIN
            SELECT pay_component_id INTO v_lop_id
            FROM pay_component WHERE code = 'LOP' AND is_active = 1;
        EXCEPTION WHEN NO_DATA_FOUND THEN v_lop_id := NULL; END;

        FOR emp IN (
            SELECT employee_id, currency_code
            FROM   employee
            WHERE  employment_status = 'ACTIVE'
            AND    hire_date <= v_end
        ) LOOP
            -- Current salary revision effective on the period end date.
            BEGIN
                SELECT employee_salary_id INTO v_rev_id
                FROM   employee_salary
                WHERE  employee_id = emp.employee_id
                AND    valid_from <= v_end
                AND    (valid_to IS NULL OR valid_to >= v_end)
                FETCH FIRST 1 ROWS ONLY;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    CONTINUE;  -- no active salary: skip this employee
            END;

            v_gross   := 0;
            v_taxable := 0;
            v_ded     := 0;

            SELECT NVL(MAX(esc.amount), 0) INTO v_basic
            FROM   employee_salary_component esc
            JOIN   pay_component pc ON pc.pay_component_id = esc.pay_component_id
            WHERE  esc.employee_salary_id = v_rev_id
            AND    pc.code = 'BASIC';

            INSERT INTO payslip (pay_run_id, employee_id, currency_code, status)
            VALUES (v_run_id, emp.employee_id, emp.currency_code, 'DRAFT')
            RETURNING payslip_id INTO v_slip_id;

            -- Earnings from the salary structure.
            FOR comp IN (
                SELECT pc.pay_component_id, pc.calculation_method, pc.default_rate,
                       pc.is_taxable, esc.amount, esc.rate
                FROM   employee_salary_component esc
                JOIN   pay_component pc ON pc.pay_component_id = esc.pay_component_id
                WHERE  esc.employee_salary_id = v_rev_id
                AND    pc.component_type = 'EARNING'
                AND    pc.is_active = 1
            ) LOOP
                DECLARE
                    v_amt NUMBER;
                BEGIN
                    v_amt := CASE comp.calculation_method
                                WHEN 'PERCENT_OF_BASIC' THEN NVL(comp.rate, comp.default_rate) * v_basic
                                ELSE NVL(comp.amount, 0)
                             END;
                    v_amt := ROUND(v_amt, 2);

                    INSERT INTO payslip_line (payslip_id, pay_component_id, amount)
                    VALUES (v_slip_id, comp.pay_component_id, v_amt);

                    v_gross := v_gross + v_amt;
                    IF comp.is_taxable = 1 THEN
                        v_taxable := v_taxable + v_amt;
                    END IF;
                END;
            END LOOP;

            -- Deductions computed by engine rules.
            v_unpaid := pkg_leave.unpaid_days(emp.employee_id, v_period_id);

            v_lop := 0;
            IF v_lop_id IS NOT NULL AND v_days > 0 AND v_unpaid > 0 THEN
                v_lop := ROUND((v_basic / v_days) * v_unpaid, 2);
                IF v_lop > 0 THEN
                    INSERT INTO payslip_line (payslip_id, pay_component_id, amount)
                    VALUES (v_slip_id, v_lop_id, v_lop);
                    v_ded := v_ded + v_lop;
                END IF;
            END IF;

            v_pf := 0;
            IF v_pf_id IS NOT NULL THEN
                v_pf := ROUND(NVL(v_pf_rate, 0) * v_basic, 2);
                IF v_pf > 0 THEN
                    INSERT INTO payslip_line (payslip_id, pay_component_id, amount)
                    VALUES (v_slip_id, v_pf_id, v_pf);
                    v_ded := v_ded + v_pf;
                END IF;
            END IF;

            v_tax := 0;
            IF v_tax_id IS NOT NULL THEN
                v_tax := pkg_tax.calc_tax(v_taxable - v_lop, c_country, v_end);
                IF v_tax > 0 THEN
                    INSERT INTO payslip_line (payslip_id, pay_component_id, amount)
                    VALUES (v_slip_id, v_tax_id, v_tax);
                    v_ded := v_ded + v_tax;
                END IF;
            END IF;

            UPDATE payslip
            SET    gross_earnings   = v_gross,
                   total_deductions = v_ded,
                   net_pay          = v_gross - v_ded,
                   leave_days       = v_unpaid
            WHERE  payslip_id = v_slip_id;
        END LOOP;

        UPDATE pay_run SET status = 'CALCULATED', run_at = SYSTIMESTAMP
        WHERE  pay_run_id = v_run_id;

        RETURN v_run_id;
    EXCEPTION
        WHEN OTHERS THEN
            pkg_error.log_error('pkg_payroll.calculate');
            RAISE;
    END calculate;

    PROCEDURE approve(p_pay_run_id IN NUMBER, p_approved_by IN VARCHAR2) IS
    BEGIN
        assert_status(p_pay_run_id, 'CALCULATED');
        UPDATE pay_run
        SET    status = 'APPROVED', approved_by = p_approved_by, approved_at = SYSTIMESTAMP
        WHERE  pay_run_id = p_pay_run_id;
    EXCEPTION
        WHEN OTHERS THEN
            pkg_error.log_error('pkg_payroll.approve');
            RAISE;
    END approve;

    PROCEDURE post(p_pay_run_id IN NUMBER) IS
    BEGIN
        assert_status(p_pay_run_id, 'APPROVED');
        UPDATE payslip SET status = 'FINAL' WHERE pay_run_id = p_pay_run_id;
        UPDATE pay_run SET status = 'POSTED' WHERE pay_run_id = p_pay_run_id;
    EXCEPTION
        WHEN OTHERS THEN
            pkg_error.log_error('pkg_payroll.post');
            RAISE;
    END post;

    PROCEDURE pay(p_pay_run_id IN NUMBER, p_fund_code IN VARCHAR2 DEFAULT 'MAIN') IS
        v_period_id pay_run.pay_period_id%TYPE;
        v_fund_id   fund.fund_id%TYPE;
        v_balance   fund.balance%TYPE;
        v_total     NUMBER;
        v_paid      NUMBER := 0;
    BEGIN
        assert_status(p_pay_run_id, 'POSTED');

        SELECT pay_period_id INTO v_period_id FROM pay_run WHERE pay_run_id = p_pay_run_id;

        BEGIN
            SELECT fund_id, balance INTO v_fund_id, v_balance
            FROM   fund WHERE code = p_fund_code;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20036, 'Unknown fund: ' || p_fund_code);
        END;

        SELECT NVL(SUM(net_pay), 0) INTO v_total FROM payslip WHERE pay_run_id = p_pay_run_id;

        IF v_balance < v_total THEN
            RAISE_APPLICATION_ERROR(-20035,
                'Insufficient fund balance (' || v_balance || ') for payroll total ' || v_total || '.');
        END IF;

        FOR ps IN (SELECT payslip_id, employee_id, net_pay FROM payslip WHERE pay_run_id = p_pay_run_id) LOOP
            BEGIN
                INSERT INTO salary_payment (employee_id, pay_period_id, payslip_id, fund_id, amount, method)
                VALUES (ps.employee_id, v_period_id, ps.payslip_id, v_fund_id, ps.net_pay, 'BANK');
                v_paid := v_paid + ps.net_pay;
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    NULL;  -- already paid for this period: idempotent, skip
            END;
        END LOOP;

        UPDATE fund SET balance = balance - v_paid WHERE fund_id = v_fund_id;
        UPDATE pay_run SET status = 'PAID' WHERE pay_run_id = p_pay_run_id;
    EXCEPTION
        WHEN OTHERS THEN
            pkg_error.log_error('pkg_payroll.pay');
            RAISE;
    END pay;

    PROCEDURE close_run(p_pay_run_id IN NUMBER) IS
        v_period_id pay_run.pay_period_id%TYPE;
    BEGIN
        assert_status(p_pay_run_id, 'PAID');
        SELECT pay_period_id INTO v_period_id FROM pay_run WHERE pay_run_id = p_pay_run_id;
        UPDATE pay_run    SET status = 'CLOSED' WHERE pay_run_id = p_pay_run_id;
        UPDATE pay_period SET status = 'CLOSED' WHERE pay_period_id = v_period_id;
    EXCEPTION
        WHEN OTHERS THEN
            pkg_error.log_error('pkg_payroll.close_run');
            RAISE;
    END close_run;

END pkg_payroll;
/
