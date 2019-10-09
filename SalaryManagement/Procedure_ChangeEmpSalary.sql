create or replace  Procedure ChangeEmployeeSalary(v_eid in number,v_sid in number)
is
Begin

update EMPLOYEE_SALARY set sid=v_sid where eid=v_eid;
commit;
EXCEPTION
	When no_data_found then
		DBMS_OUTPUT.PUT_LINE('No Data Found');
	When others then
		DBMS_OUTPUT.PUT_LINE('Something wrong happened');

end ChangeEmployeeSalary;
/