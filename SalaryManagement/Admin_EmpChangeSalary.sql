clear screen;
SET SERVEROUTPUT ON;
SET VERIFY OFF;

DECLARE
	v_eid EMPLOYEE.eid %TYPE:=&EmpolyeeID;
	v_sid  employee_salary.sid%TYPE:=&NewSalaryId;

BEGIN
  ChangeEmployeeSalary(v_eid,v_sid);
END;
/