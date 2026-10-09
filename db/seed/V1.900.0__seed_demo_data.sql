--------------------------------------------------------------------------------
-- PaySQL :: Seed :: Demo data
-- Optional demo dataset (a small company). Load via the "db/seed" Flyway location
-- or run manually. The original coursework's 10 employees are migrated here into
-- the modern, component-based, effective-dated schema.
--
-- Foreign keys are resolved by natural keys (codes) so identity columns generate
-- cleanly and never collide with rows added later via the API/engine.
--
-- For production installs, exclude this location so no demo rows are created.
--------------------------------------------------------------------------------

-- Currencies ------------------------------------------------------------------
INSERT INTO currency (currency_code, currency_name, symbol) VALUES ('USD', 'US Dollar', '$');
INSERT INTO currency (currency_code, currency_name, symbol) VALUES ('BDT', 'Bangladeshi Taka', 'Tk');

-- Departments -----------------------------------------------------------------
INSERT INTO department (code, name) VALUES ('ENG', 'Engineering');
INSERT INTO department (code, name) VALUES ('FIN', 'Finance');
INSERT INTO department (code, name) VALUES ('HR',  'Human Resources');

-- Job grades ------------------------------------------------------------------
INSERT INTO job_grade (code, name, min_salary, max_salary) VALUES ('J1', 'Junior', 15000, 25000);
INSERT INTO job_grade (code, name, min_salary, max_salary) VALUES ('J2', 'Mid',    20000, 40000);
INSERT INTO job_grade (code, name, min_salary, max_salary) VALUES ('J3', 'Senior', 35000, 60000);

-- Pay components (compensation as data) ---------------------------------------
INSERT INTO pay_component (code, name, component_type, calculation_method, is_taxable, display_order)
VALUES ('BASIC', 'Basic Salary', 'EARNING', 'FIXED', 1, 10);
INSERT INTO pay_component (code, name, component_type, calculation_method, is_taxable, display_order)
VALUES ('HRA', 'Housing Allowance', 'EARNING', 'FIXED', 1, 20);
INSERT INTO pay_component (code, name, component_type, calculation_method, default_rate, is_taxable, display_order)
VALUES ('PF', 'Provident Fund', 'DEDUCTION', 'PERCENT_OF_BASIC', 0.05, 0, 30);
INSERT INTO pay_component (code, name, component_type, calculation_method, is_taxable, display_order)
VALUES ('TAX', 'Income Tax', 'DEDUCTION', 'FORMULA', 0, 40);
INSERT INTO pay_component (code, name, component_type, calculation_method, is_taxable, display_order)
VALUES ('LOP', 'Loss of Pay', 'DEDUCTION', 'FORMULA', 0, 50);

-- Leave types -----------------------------------------------------------------
INSERT INTO leave_type (code, name, is_paid) VALUES ('ANNUAL', 'Annual Leave', 1);
INSERT INTO leave_type (code, name, is_paid) VALUES ('SICK',   'Sick Leave',   1);
INSERT INTO leave_type (code, name, is_paid) VALUES ('UNPAID', 'Unpaid Leave', 0);

-- Tax slabs (illustrative, USD) -----------------------------------------------
INSERT INTO tax_slab (country_code, lower_bound, upper_bound, rate, effective_from)
VALUES ('US', 0,     20000, 0.00, DATE '2026-01-01');
INSERT INTO tax_slab (country_code, lower_bound, upper_bound, rate, effective_from)
VALUES ('US', 20000, 40000, 0.10, DATE '2026-01-01');
INSERT INTO tax_slab (country_code, lower_bound, upper_bound, rate, effective_from)
VALUES ('US', 40000, NULL,  0.15, DATE '2026-01-01');

-- Employees (migrated from the original coursework dataset) --------------------
INSERT INTO employee (employee_code, first_name, last_name, gender, email, department_id, job_grade_id, currency_code, hire_date)
VALUES ('EMP0001','Sajid','Abdullah','MALE','sajid@example.com',   (SELECT department_id FROM department WHERE code='ENG'), (SELECT job_grade_id FROM job_grade WHERE code='J1'), 'USD', DATE '2019-01-01');
INSERT INTO employee (employee_code, first_name, last_name, gender, email, department_id, job_grade_id, currency_code, hire_date)
VALUES ('EMP0002','Samia','Zahan','FEMALE','samia@example.com',    (SELECT department_id FROM department WHERE code='ENG'), (SELECT job_grade_id FROM job_grade WHERE code='J2'), 'USD', DATE '2019-01-01');
INSERT INTO employee (employee_code, first_name, last_name, gender, email, department_id, job_grade_id, currency_code, hire_date)
VALUES ('EMP0003','Muna','Saha','FEMALE','muna@example.com',       (SELECT department_id FROM department WHERE code='FIN'), (SELECT job_grade_id FROM job_grade WHERE code='J3'), 'USD', DATE '2019-01-01');
INSERT INTO employee (employee_code, first_name, last_name, gender, email, department_id, job_grade_id, currency_code, hire_date)
VALUES ('EMP0004','Robiul','Hasan','MALE','robiul@example.com',    (SELECT department_id FROM department WHERE code='ENG'), (SELECT job_grade_id FROM job_grade WHERE code='J2'), 'USD', DATE '2019-01-01');
INSERT INTO employee (employee_code, first_name, last_name, gender, email, department_id, job_grade_id, currency_code, hire_date)
VALUES ('EMP0005','Shahriar','Shibli','MALE','shibli@example.com', (SELECT department_id FROM department WHERE code='ENG'), (SELECT job_grade_id FROM job_grade WHERE code='J1'), 'USD', DATE '2019-01-01');
INSERT INTO employee (employee_code, first_name, last_name, gender, email, department_id, job_grade_id, currency_code, hire_date)
VALUES ('EMP0006','Shourav','Saha','MALE','shourav@example.com',   (SELECT department_id FROM department WHERE code='FIN'), (SELECT job_grade_id FROM job_grade WHERE code='J3'), 'USD', DATE '2019-01-01');
INSERT INTO employee (employee_code, first_name, last_name, gender, email, department_id, job_grade_id, currency_code, hire_date)
VALUES ('EMP0007','Apurbo','Roy','MALE','apurbo@example.com',      (SELECT department_id FROM department WHERE code='HR'),  (SELECT job_grade_id FROM job_grade WHERE code='J3'), 'USD', DATE '2019-01-01');
INSERT INTO employee (employee_code, first_name, last_name, gender, email, department_id, job_grade_id, currency_code, hire_date)
VALUES ('EMP0008','Tanvir','Rahman','MALE','tanvir@example.com',   (SELECT department_id FROM department WHERE code='ENG'), (SELECT job_grade_id FROM job_grade WHERE code='J3'), 'USD', DATE '2019-01-01');
INSERT INTO employee (employee_code, first_name, last_name, gender, email, department_id, job_grade_id, currency_code, hire_date)
VALUES ('EMP0009','Sonia','Khatun','FEMALE','sonia@example.com',   (SELECT department_id FROM department WHERE code='FIN'), (SELECT job_grade_id FROM job_grade WHERE code='J2'), 'USD', DATE '2019-01-01');
INSERT INTO employee (employee_code, first_name, last_name, gender, email, department_id, job_grade_id, currency_code, hire_date)
VALUES ('EMP0010','Humayan','Nila','FEMALE','nila@example.com',    (SELECT department_id FROM department WHERE code='HR'),  (SELECT job_grade_id FROM job_grade WHERE code='J3'), 'USD', DATE '2019-01-01');

-- Fund ------------------------------------------------------------------------
INSERT INTO fund (code, name, currency_code, balance) VALUES ('MAIN', 'Main Payroll Fund', 'USD', 1000000);

-- Pay period ------------------------------------------------------------------
INSERT INTO pay_period (period_code, period_name, start_date, end_date, pay_date, status)
VALUES ('2026-01', 'January 2026', DATE '2026-01-01', DATE '2026-01-31', DATE '2026-02-01', 'OPEN');

-- Effective-dated salaries (one revision per employee) ------------------------
INSERT INTO employee_salary (employee_id, valid_from, currency_code, note)
SELECT employee_id, DATE '2019-01-01', 'USD', 'Initial salary' FROM employee;

-- BASIC component per employee (original salary bands) -------------------------
INSERT INTO employee_salary_component (employee_salary_id, pay_component_id, amount)
SELECT es.employee_salary_id,
       (SELECT pay_component_id FROM pay_component WHERE code='BASIC'),
       CASE e.employee_code
            WHEN 'EMP0001' THEN 18000 WHEN 'EMP0002' THEN 22000 WHEN 'EMP0003' THEN 50000
            WHEN 'EMP0004' THEN 20000 WHEN 'EMP0005' THEN 18000 WHEN 'EMP0006' THEN 22000
            WHEN 'EMP0007' THEN 50000 WHEN 'EMP0008' THEN 35000 WHEN 'EMP0009' THEN 20000
            WHEN 'EMP0010' THEN 35000 END
FROM   employee_salary es
JOIN   employee e ON e.employee_id = es.employee_id;

-- HRA / housing allowance per employee ----------------------------------------
INSERT INTO employee_salary_component (employee_salary_id, pay_component_id, amount)
SELECT es.employee_salary_id,
       (SELECT pay_component_id FROM pay_component WHERE code='HRA'),
       CASE e.employee_code
            WHEN 'EMP0001' THEN 5000 WHEN 'EMP0002' THEN 6000 WHEN 'EMP0003' THEN 7000
            WHEN 'EMP0004' THEN 5000 WHEN 'EMP0005' THEN 5000 WHEN 'EMP0006' THEN 6000
            WHEN 'EMP0007' THEN 7000 WHEN 'EMP0008' THEN 6500 WHEN 'EMP0009' THEN 5000
            WHEN 'EMP0010' THEN 6500 END
FROM   employee_salary es
JOIN   employee e ON e.employee_id = es.employee_id;

-- A few leave requests (mirrors the spirit of the original LEAVE rows) ---------
INSERT INTO leave_request (employee_id, leave_type_id, start_date, end_date, days, status, reason)
VALUES ((SELECT employee_id FROM employee WHERE employee_code='EMP0001'),
        (SELECT leave_type_id FROM leave_type WHERE code='ANNUAL'),
        DATE '2026-01-06', DATE '2026-01-08', 3, 'APPROVED', 'Annual leave');
INSERT INTO leave_request (employee_id, leave_type_id, start_date, end_date, days, status, reason)
VALUES ((SELECT employee_id FROM employee WHERE employee_code='EMP0003'),
        (SELECT leave_type_id FROM leave_type WHERE code='SICK'),
        DATE '2026-01-10', DATE '2026-01-13', 4, 'APPROVED', 'Sick leave');
INSERT INTO leave_request (employee_id, leave_type_id, start_date, end_date, days, status, reason)
VALUES ((SELECT employee_id FROM employee WHERE employee_code='EMP0002'),
        (SELECT leave_type_id FROM leave_type WHERE code='UNPAID'),
        DATE '2026-01-20', DATE '2026-01-24', 5, 'APPROVED', 'Unpaid leave');

COMMIT;
