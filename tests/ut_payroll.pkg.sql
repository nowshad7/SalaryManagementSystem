--------------------------------------------------------------------------------
-- PaySQL :: Tests :: ut_payroll (utPLSQL suite)
--
-- Requires utPLSQL v3 (https://www.utplsql.org/) installed and granted to the
-- PAYSQL user, plus the demo seed data loaded. Run with:
--     exec ut.run('ut_payroll');
-- or via the utPLSQL-cli. Each test auto-rolls back, so the seed stays intact.
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE ut_payroll AS
    --%suite(PaySQL payroll engine)

    --%test(Tax brackets are progressive)
    PROCEDURE tax_brackets;

    --%test(Calculate creates a payslip per active employee)
    PROCEDURE calculate_creates_payslips;

    --%test(Known employee net pay is correct)
    PROCEDURE known_net_pay;

    --%test(Recalculating an approved period is blocked)
    PROCEDURE recalc_blocked;

    --%test(Full lifecycle pays each employee exactly once)
    PROCEDURE lifecycle_pays_once;

    --%test(Salary change preserves history)
    PROCEDURE salary_change_history;
END ut_payroll;
/

CREATE OR REPLACE PACKAGE BODY ut_payroll AS

    PROCEDURE tax_brackets IS
    BEGIN
        -- 0-20000 @ 0%, 20000-40000 @ 10%, 40000+ @ 15%
        ut.expect(pkg_tax.calc_tax(10000)).to_equal(0);
        ut.expect(pkg_tax.calc_tax(30000)).to_equal(1000);     -- (30000-20000)*0.10
        ut.expect(pkg_tax.calc_tax(50000)).to_equal(3500);     -- 2000 + 1500
    END tax_brackets;

    PROCEDURE calculate_creates_payslips IS
        v_run      NUMBER;
        v_slips    NUMBER;
        v_active   NUMBER;
    BEGIN
        v_run := pkg_payroll.calculate('2026-01');

        SELECT COUNT(*) INTO v_slips  FROM payslip WHERE pay_run_id = v_run;
        SELECT COUNT(*) INTO v_active FROM employee WHERE employment_status = 'ACTIVE';

        ut.expect(v_slips).to_equal(v_active);
    END calculate_creates_payslips;

    PROCEDURE known_net_pay IS
        v_run NUMBER;
        v_net NUMBER;
    BEGIN
        -- EMP0001: basic 18000 + HRA 5000 = 23000 gross; paid leave only (no LOP).
        -- PF 5% of basic = 900; tax on 23000 = (23000-20000)*0.10 = 300.
        -- net = 23000 - 900 - 300 = 21800.
        v_run := pkg_payroll.calculate('2026-01');

        SELECT ps.net_pay INTO v_net
        FROM   payslip ps
        JOIN   employee e ON e.employee_id = ps.employee_id
        WHERE  ps.pay_run_id = v_run
        AND    e.employee_code = 'EMP0001';

        ut.expect(v_net).to_equal(21800);
    END known_net_pay;

    PROCEDURE recalc_blocked IS
        v_run NUMBER;
        v_x   NUMBER;
    BEGIN
        v_run := pkg_payroll.calculate('2026-01');
        pkg_payroll.approve(v_run, 'tester');

        BEGIN
            v_x := pkg_payroll.calculate('2026-01');
            ut.fail('Expected ORA-20034 when recalculating an approved period');
        EXCEPTION
            WHEN OTHERS THEN
                ut.expect(SQLCODE).to_equal(-20034);
        END;
    END recalc_blocked;

    PROCEDURE lifecycle_pays_once IS
        v_run      NUMBER;
        v_payments NUMBER;
        v_slips    NUMBER;
    BEGIN
        v_run := pkg_payroll.calculate('2026-01');
        pkg_payroll.approve(v_run, 'tester');
        pkg_payroll.post(v_run);
        pkg_payroll.pay(v_run, 'MAIN');

        SELECT COUNT(*) INTO v_slips FROM payslip WHERE pay_run_id = v_run;
        SELECT COUNT(*) INTO v_payments
        FROM   salary_payment sp
        JOIN   pay_run pr ON pr.pay_period_id = sp.pay_period_id
        WHERE  pr.pay_run_id = v_run;

        ut.expect(v_payments).to_equal(v_slips);
    END lifecycle_pays_once;

    PROCEDURE salary_change_history IS
        v_emp     NUMBER;
        v_before  NUMBER;
        v_after   NUMBER;
        v_new_rev NUMBER;
        v_old_to  DATE;
    BEGIN
        SELECT employee_id INTO v_emp FROM employee WHERE employee_code = 'EMP0005';
        SELECT COUNT(*) INTO v_before FROM employee_salary WHERE employee_id = v_emp;

        v_new_rev := pkg_employee.new_salary_revision(v_emp, DATE '2026-02-01', 'USD', 'raise');
        pkg_employee.set_component(v_new_rev, 'BASIC', 20000);

        SELECT COUNT(*) INTO v_after FROM employee_salary WHERE employee_id = v_emp;
        ut.expect(v_after).to_equal(v_before + 1);

        -- The prior revision should now be closed the day before the new one.
        SELECT valid_to INTO v_old_to
        FROM   employee_salary
        WHERE  employee_id = v_emp AND valid_from = DATE '2019-01-01';
        ut.expect(v_old_to).to_equal(DATE '2026-01-31');
    END salary_change_history;

END ut_payroll;
/
