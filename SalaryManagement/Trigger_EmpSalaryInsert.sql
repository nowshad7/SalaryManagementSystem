SET SERVEROUTPUT ON;

create or replace trigger Trig_EmpSalaryInsert
after insert on EMPLOYEE_SALARY
begin
	dbms_output.put_line('Salary Assigned To the Employee');
end;
/