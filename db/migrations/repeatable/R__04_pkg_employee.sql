--------------------------------------------------------------------------------
-- PaySQL :: Package :: pkg_employee
-- Employee lifecycle and effective-dated salary management.
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_employee AS
    FUNCTION add_employee(
        p_code        IN VARCHAR2,
        p_first_name  IN VARCHAR2,
        p_last_name   IN VARCHAR2,
        p_email       IN VARCHAR2,
        p_dept_code   IN VARCHAR2 DEFAULT NULL,
        p_grade_code  IN VARCHAR2 DEFAULT NULL,
        p_hire_date   IN DATE     DEFAULT TRUNC(SYSDATE),
        p_gender      IN VARCHAR2 DEFAULT 'UNDISCLOSED',
        p_currency    IN VARCHAR2 DEFAULT 'USD'
    ) RETURN NUMBER;

    -- Close the current salary revision and open a new one. Returns new revision id.
    FUNCTION new_salary_revision(
        p_employee_id IN NUMBER,
        p_valid_from  IN DATE,
        p_currency    IN VARCHAR2 DEFAULT 'USD',
        p_note        IN VARCHAR2 DEFAULT NULL
    ) RETURN NUMBER;

    -- Add / update a component line on a salary revision.
    PROCEDURE set_component(
        p_employee_salary_id IN NUMBER,
        p_component_code     IN VARCHAR2,
        p_amount             IN NUMBER DEFAULT NULL,
        p_rate               IN NUMBER DEFAULT NULL
    );

    PROCEDURE terminate(p_employee_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE));
END pkg_employee;
/

CREATE OR REPLACE PACKAGE BODY pkg_employee AS

    FUNCTION add_employee(
        p_code        IN VARCHAR2,
        p_first_name  IN VARCHAR2,
        p_last_name   IN VARCHAR2,
        p_email       IN VARCHAR2,
        p_dept_code   IN VARCHAR2 DEFAULT NULL,
        p_grade_code  IN VARCHAR2 DEFAULT NULL,
        p_hire_date   IN DATE     DEFAULT TRUNC(SYSDATE),
        p_gender      IN VARCHAR2 DEFAULT 'UNDISCLOSED',
        p_currency    IN VARCHAR2 DEFAULT 'USD'
    ) RETURN NUMBER IS
        v_id    employee.employee_id%TYPE;
        v_dept  department.department_id%TYPE;
        v_grade job_grade.job_grade_id%TYPE;
    BEGIN
        IF p_dept_code IS NOT NULL THEN
            SELECT department_id INTO v_dept FROM department WHERE code = p_dept_code;
        END IF;
        IF p_grade_code IS NOT NULL THEN
            SELECT job_grade_id INTO v_grade FROM job_grade WHERE code = p_grade_code;
        END IF;

        INSERT INTO employee (employee_code, first_name, last_name, gender, email,
                              department_id, job_grade_id, currency_code, hire_date)
        VALUES (p_code, p_first_name, p_last_name, p_gender, p_email,
                v_dept, v_grade, p_currency, p_hire_date)
        RETURNING employee_id INTO v_id;

        RETURN v_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20020, 'Unknown department or job grade code.');
        WHEN OTHERS THEN
            pkg_error.log_error('pkg_employee.add_employee');
            RAISE;
    END add_employee;

    FUNCTION new_salary_revision(
        p_employee_id IN NUMBER,
        p_valid_from  IN DATE,
        p_currency    IN VARCHAR2 DEFAULT 'USD',
        p_note        IN VARCHAR2 DEFAULT NULL
    ) RETURN NUMBER IS
        v_id employee_salary.employee_salary_id%TYPE;
    BEGIN
        -- Close any open revision the day before the new one starts.
        UPDATE employee_salary
        SET    valid_to = p_valid_from - 1
        WHERE  employee_id = p_employee_id
        AND    valid_to IS NULL
        AND    valid_from < p_valid_from;

        INSERT INTO employee_salary (employee_id, valid_from, currency_code, note)
        VALUES (p_employee_id, p_valid_from, p_currency, p_note)
        RETURNING employee_salary_id INTO v_id;

        RETURN v_id;
    EXCEPTION
        WHEN OTHERS THEN
            pkg_error.log_error('pkg_employee.new_salary_revision');
            RAISE;
    END new_salary_revision;

    PROCEDURE set_component(
        p_employee_salary_id IN NUMBER,
        p_component_code     IN VARCHAR2,
        p_amount             IN NUMBER DEFAULT NULL,
        p_rate               IN NUMBER DEFAULT NULL
    ) IS
        v_comp pay_component.pay_component_id%TYPE;
    BEGIN
        SELECT pay_component_id INTO v_comp FROM pay_component WHERE code = p_component_code;

        MERGE INTO employee_salary_component esc
        USING (SELECT p_employee_salary_id AS sid, v_comp AS cid FROM dual) s
        ON    (esc.employee_salary_id = s.sid AND esc.pay_component_id = s.cid)
        WHEN MATCHED THEN
            UPDATE SET esc.amount = p_amount, esc.rate = p_rate
        WHEN NOT MATCHED THEN
            INSERT (employee_salary_id, pay_component_id, amount, rate)
            VALUES (s.sid, s.cid, p_amount, p_rate);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20021, 'Unknown pay component code: ' || p_component_code);
        WHEN OTHERS THEN
            pkg_error.log_error('pkg_employee.set_component');
            RAISE;
    END set_component;

    PROCEDURE terminate(p_employee_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) IS
    BEGIN
        UPDATE employee
        SET    employment_status = 'TERMINATED',
               termination_date  = p_date,
               updated_at        = SYSTIMESTAMP
        WHERE  employee_id = p_employee_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20022, 'Employee not found: ' || p_employee_id);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            pkg_error.log_error('pkg_employee.terminate');
            RAISE;
    END terminate;

END pkg_employee;
/
