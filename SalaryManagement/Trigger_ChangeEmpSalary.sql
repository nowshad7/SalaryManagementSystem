SET SERVEROUTPUT ON;

CREATE OR REPLACE trigger EmpSalary_audit
BEFORE UPDATE ON EMPLOYEE_SALARY
FOR EACH ROW
DECLARE
	  v_date varchar2(30);
begin
	select sysdate into v_date from dual;
	insert into EMPLOYEE_SALARY_Audit values (:NEW.sid,:OLD.sid,v_date);
	dbms_output.put_line('Salary Change for The Employee');
	commit;
end;
/