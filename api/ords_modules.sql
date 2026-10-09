--------------------------------------------------------------------------------
-- PaySQL :: ORDS :: REST module (paysql.v1)
--
-- Run as the PAYSQL user after ords_enable.sql. Defines the versioned REST API
-- under /paysql/v1/ . GET handlers are SQL feeds; mutating handlers call the
-- PL/SQL engine from Phase 2. Re-runnable (deletes and recreates the module).
--
-- Base URL (default ORDS): https://<host>/ords/paysql/v1/
--------------------------------------------------------------------------------
BEGIN
    BEGIN
        ORDS.DELETE_MODULE(p_module_name => 'paysql.v1');
    EXCEPTION WHEN OTHERS THEN NULL;  -- ignore if it does not exist yet
    END;

    ORDS.DEFINE_MODULE(
        p_module_name    => 'paysql.v1',
        p_base_path      => '/v1/',
        p_items_per_page => 25,
        p_status         => 'PUBLISHED',
        p_comments       => 'PaySQL REST API v1');

    ----------------------------------------------------------------------------
    -- Employees
    ----------------------------------------------------------------------------
    ORDS.DEFINE_TEMPLATE(p_module_name => 'paysql.v1', p_pattern => 'employees');

    ORDS.DEFINE_HANDLER(
        p_module_name => 'paysql.v1',
        p_pattern     => 'employees',
        p_method      => 'GET',
        p_source_type => ORDS.source_type_collection_feed,
        p_source      => 'SELECT employee_id, employee_code, first_name, last_name, email,
                                 employment_status, currency_code
                          FROM   employee
                          ORDER  BY employee_id');

    ORDS.DEFINE_HANDLER(
        p_module_name => 'paysql.v1',
        p_pattern     => 'employees',
        p_method      => 'POST',
        p_source_type => ORDS.source_type_plsql,
        p_source      => q'[
            DECLARE
                v_id NUMBER;
            BEGIN
                v_id := pkg_employee.add_employee(
                    p_code       => :code,
                    p_first_name => :first_name,
                    p_last_name  => :last_name,
                    p_email      => :email,
                    p_dept_code  => :dept_code,
                    p_grade_code => :grade_code,
                    p_hire_date  => TO_DATE(:hire_date, 'YYYY-MM-DD'),
                    p_gender     => NVL(:gender, 'UNDISCLOSED'),
                    p_currency   => NVL(:currency, 'USD'));
                COMMIT;
                :status_code := 201;
                HTP.PRN('{"employee_id":' || v_id || '}');
            END;
        ]');

    ORDS.DEFINE_TEMPLATE(p_module_name => 'paysql.v1', p_pattern => 'employees/:id');

    ORDS.DEFINE_HANDLER(
        p_module_name => 'paysql.v1',
        p_pattern     => 'employees/:id',
        p_method      => 'GET',
        p_source_type => ORDS.source_type_query_one_row,
        p_source      => 'SELECT * FROM employee WHERE employee_id = :id');

    ORDS.DEFINE_TEMPLATE(p_module_name => 'paysql.v1', p_pattern => 'employees/:id/payslips');

    ORDS.DEFINE_HANDLER(
        p_module_name => 'paysql.v1',
        p_pattern     => 'employees/:id/payslips',
        p_method      => 'GET',
        p_source_type => ORDS.source_type_collection_feed,
        p_source      => 'SELECT ps.payslip_id, pp.period_code, ps.gross_earnings,
                                 ps.total_deductions, ps.net_pay, ps.status
                          FROM   payslip ps
                          JOIN   pay_run pr    ON pr.pay_run_id = ps.pay_run_id
                          JOIN   pay_period pp ON pp.pay_period_id = pr.pay_period_id
                          WHERE  ps.employee_id = :id
                          ORDER  BY pp.start_date DESC');

    ----------------------------------------------------------------------------
    -- Payslips
    ----------------------------------------------------------------------------
    ORDS.DEFINE_TEMPLATE(p_module_name => 'paysql.v1', p_pattern => 'payslips/:id');

    ORDS.DEFINE_HANDLER(
        p_module_name => 'paysql.v1',
        p_pattern     => 'payslips/:id',
        p_method      => 'GET',
        p_source_type => ORDS.source_type_collection_feed,
        p_source      => 'SELECT component_code, component_name, component_type, amount,
                                 gross_earnings, total_deductions, net_pay, currency_code
                          FROM   v_payslip_detail
                          WHERE  payslip_id = :id');

    ----------------------------------------------------------------------------
    -- Pay runs (lifecycle)
    ----------------------------------------------------------------------------
    ORDS.DEFINE_TEMPLATE(p_module_name => 'paysql.v1', p_pattern => 'payruns');

    ORDS.DEFINE_HANDLER(
        p_module_name => 'paysql.v1',
        p_pattern     => 'payruns',
        p_method      => 'GET',
        p_source_type => ORDS.source_type_collection_feed,
        p_source      => 'SELECT * FROM v_payroll_register ORDER BY pay_run_id DESC');

    ORDS.DEFINE_HANDLER(
        p_module_name => 'paysql.v1',
        p_pattern     => 'payruns',
        p_method      => 'POST',
        p_source_type => ORDS.source_type_plsql,
        p_source      => q'[
            DECLARE
                v_run NUMBER;
            BEGIN
                v_run := pkg_payroll.calculate(:period_code);
                COMMIT;
                :status_code := 201;
                HTP.PRN('{"pay_run_id":' || v_run || ',"status":"CALCULATED"}');
            END;
        ]');

    ORDS.DEFINE_TEMPLATE(p_module_name => 'paysql.v1', p_pattern => 'payruns/:id/register');

    ORDS.DEFINE_HANDLER(
        p_module_name => 'paysql.v1',
        p_pattern     => 'payruns/:id/register',
        p_method      => 'GET',
        p_source_type => ORDS.source_type_collection_feed,
        p_source      => 'SELECT * FROM v_payroll_register WHERE pay_run_id = :id');

    ORDS.DEFINE_TEMPLATE(p_module_name => 'paysql.v1', p_pattern => 'payruns/:id/approve');
    ORDS.DEFINE_HANDLER(
        p_module_name => 'paysql.v1',
        p_pattern     => 'payruns/:id/approve',
        p_method      => 'POST',
        p_source_type => ORDS.source_type_plsql,
        p_source      => q'[
            BEGIN
                pkg_payroll.approve(:id, :approved_by);
                COMMIT;
                HTP.PRN('{"pay_run_id":' || :id || ',"status":"APPROVED"}');
            END;
        ]');

    ORDS.DEFINE_TEMPLATE(p_module_name => 'paysql.v1', p_pattern => 'payruns/:id/post');
    ORDS.DEFINE_HANDLER(
        p_module_name => 'paysql.v1',
        p_pattern     => 'payruns/:id/post',
        p_method      => 'POST',
        p_source_type => ORDS.source_type_plsql,
        p_source      => q'[
            BEGIN
                pkg_payroll.post(:id);
                COMMIT;
                HTP.PRN('{"pay_run_id":' || :id || ',"status":"POSTED"}');
            END;
        ]');

    ORDS.DEFINE_TEMPLATE(p_module_name => 'paysql.v1', p_pattern => 'payruns/:id/pay');
    ORDS.DEFINE_HANDLER(
        p_module_name => 'paysql.v1',
        p_pattern     => 'payruns/:id/pay',
        p_method      => 'POST',
        p_source_type => ORDS.source_type_plsql,
        p_source      => q'[
            BEGIN
                pkg_payroll.pay(:id, NVL(:fund_code, 'MAIN'));
                COMMIT;
                HTP.PRN('{"pay_run_id":' || :id || ',"status":"PAID"}');
            END;
        ]');

    ORDS.DEFINE_TEMPLATE(p_module_name => 'paysql.v1', p_pattern => 'payruns/:id/close');
    ORDS.DEFINE_HANDLER(
        p_module_name => 'paysql.v1',
        p_pattern     => 'payruns/:id/close',
        p_method      => 'POST',
        p_source_type => ORDS.source_type_plsql,
        p_source      => q'[
            BEGIN
                pkg_payroll.close_run(:id);
                COMMIT;
                HTP.PRN('{"pay_run_id":' || :id || ',"status":"CLOSED"}');
            END;
        ]');

    COMMIT;
END;
/
