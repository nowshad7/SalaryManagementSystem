SET SERVEROUTPUT ON;

create or replace trigger Trig_EmployeeInsert
after insert on Employee
begin
	dbms_output.put_line('One Employee Added');
end;
/