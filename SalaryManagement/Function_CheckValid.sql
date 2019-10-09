create or replace  function Check_Valid(n1 in number, s1 in varchar2)
       return number
       is
	 	
	temp_eid transection.eid %TYPE:= n1;
	temp_s_month transection.s_month %TYPE:=s1;
	
	v_eid transection.eid %TYPE;
	v_s_month transection.s_month %TYPE;
	
	return_val number:=0;
	
	cursor my_cur is
	select eid, s_month from TRANSECTION;
	
BEGIN

	OPEN my_cur;
		loop
			fetch my_cur into v_eid,v_s_month;
			exit when (my_cur%notfound or return_val=1) ;
			if((v_eid=temp_eid) and  (v_s_month=temp_s_month)) then
			return_val:=1; 
			else
			return_val:=2; 
			end if;
		end loop;
	CLOSE my_cur;
	
	return return_val;
	
	EXCEPTION
	When no_data_found then
		DBMS_OUTPUT.PUT_LINE('No Data Found');
	When others then
		DBMS_OUTPUT.PUT_LINE('Something wrong happened');

end Check_Valid;
/