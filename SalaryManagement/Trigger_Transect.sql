SET SERVEROUTPUT ON;

create or replace trigger Trig_Tansect
after insert on transection
begin
	dbms_output.put_line('One Transection completed');
end;
/