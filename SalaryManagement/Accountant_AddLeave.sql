clear screen;
SET SERVEROUTPUT ON;
SET VERIFY OFF;

DECLARE
	v_lid LEAVE.lid %type; 
	v_eid LEAVE.eid %type:=&EmployeeID;
	v_l_month LEAVE.l_month %type:='&Month'; 
	v_l_day LEAVE.l_day %type:=&No_of_Leaves; 

BEGIN
	SELECT lid 
	into v_lid 
	FROM (select * from LEAVE ORDER BY lid DESC) leave1 
	WHERE rownum <= 1 ORDER BY rownum DESC;
	v_lid:=v_lid+1;
	AddLeave(v_lid,v_eid,v_l_month,v_l_day);
	
	EXCEPTION
	When no_data_found then
		DBMS_OUTPUT.PUT_LINE('No Data Found');
	When others then
		DBMS_OUTPUT.PUT_LINE('Something wrong happened');

END;
/