clear screen;
SET SERVEROUTPUT ON;
SET VERIFY OFF;

DECLARE
	v_eid EMPLOYEE.eid %TYPE;
	v_ename EMPLOYEE.ename %TYPE :='&Name';
    v_gender EMPLOYEE.gender %TYPE :='&Gender';
	v_email EMPLOYEE.email %TYPE :='&Email';
	v_joinDate EMPLOYEE.join_date %TYPE:='&JoinDate';
	v_sid  employee_salary.sid%TYPE:='&Salary';

BEGIN
	SELECT eid 
	into v_eid 
	FROM (select * from EMPLOYEE ORDER BY eid DESC) Emp1 
	WHERE rownum <= 1 ORDER BY rownum DESC;
	v_eid:=v_eid+1;
	insert into employee  values (v_eid, v_ename, v_gender,v_email, v_joinDate); 
	insert into employee_salary values(v_eid,v_sid); 
	commit;
	
	EXCEPTION
	When no_data_found then
		DBMS_OUTPUT.PUT_LINE('No Data Found');
	When others then
		DBMS_OUTPUT.PUT_LINE('Something wrong happened');
END;
/