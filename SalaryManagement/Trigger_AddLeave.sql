SET SERVEROUTPUT ON;

create or replace trigger Trig_AddLeave
after insert on Leave
begin
	dbms_output.put_line('Employee leaves added according to month');
end;
/