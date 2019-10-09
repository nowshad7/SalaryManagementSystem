create or replace package body myPackage as 
	function Generate_Salary(n1 in number, s1 in varchar2)
    return number
    is
	
	 v_l_day leave.l_day%TYPE;
	   v_basic salary.basic%TYPE;
	   v_allowance salary.allowance%TYPE;
	   v_sid  employee_salary.sid%TYPE;
	   v_return number;
	   
	   
begin	
 
	select  l_day  into v_l_day from leave where eid=n1 and l_month=s1;
	select sid into  v_sid from  employee_salary where eid=n1;
	select  basic,allowance  into v_basic,v_allowance from  salary where sid=v_sid;

	if(v_l_day<3) then
	v_return:=v_basic+v_allowance;

	elsif(v_l_day>=3 and v_l_day<5) then
	v_basic:=v_basic-(v_basic*0.05);
	v_return:=v_basic+v_allowance;

	elsif(v_l_day>=5) then
	v_basic:=v_basic-(v_basic*0.07);
	v_return:=v_basic+v_allowance;

	end if;
	return v_return;

EXCEPTION
	When no_data_found then
		DBMS_OUTPUT.PUT_LINE('No Data Found');
	When others then
		DBMS_OUTPUT.PUT_LINE('Something wrong happened');

end Generate_Salary; 

		
	Procedure Transect_Salary(n1 in number, n2 in number,s1 in varchar2)
    is
	   
	t_id transection.tid %TYPE;
	v_count NUMBER:=0;
	new_id NUMBER;
	
	v_tid transection.tid %TYPE;
	v_eid transection.eid %TYPE:= n1;
	v_ammount transection.ammount %TYPE :=n2;
	v_t_date transection.t_date %TYPE;
	v_s_month transection.s_month %TYPE:=s1;
	
	checking number	;

BEGIN

    select sysdate into v_t_date from dual;
	select count(*) into t_id from transection  where tid=1;
	if(t_id=0) then
		insert into transection values(1,v_eid,v_ammount,v_t_date,v_s_month);
    
		Update_Fund(v_ammount);	
	else
	
	    checking := Check_Valid(v_eid,v_s_month);
	    if(checking=2) then
    
			SELECT tid 
	        into t_id 
	        FROM (select * from transection ORDER BY tid DESC) transection1 
	        WHERE rownum <= 1 ORDER BY rownum DESC;
	
    	
		    v_count:=v_count+1;
		    new_id := t_id + v_count;
		    insert into transection values(new_id,v_eid,v_ammount,v_t_date,v_s_month);	
		    Update_Fund(v_ammount);	
	    elsif (checking=1) then
		    dbms_output.put_line('Already done');
		end if;
	end if;
	commit;
	
end Transect_Salary; 

end myPackage; 
/