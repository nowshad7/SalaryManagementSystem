SET SERVEROUTPUT ON;
SET VERIFY OFF;
clear screen;
DECLARE

	X number:= &Your_EmployeeID;

	--v_eid EMPLOYEE.eid %TYPE;
	v_ename EMPLOYEE.ename %TYPE;
    v_gender EMPLOYEE.gender %TYPE;
	v_email EMPLOYEE.email %TYPE;
	v_joinDate EMPLOYEE.join_date %TYPE;
	
	v_l_day leave.l_day%TYPE;
	v_basic salary.basic%TYPE;
	v_allowance salary.allowance%TYPE;
	v_sid  employee_salary.sid%TYPE;
	n1 number; 
	
	v_tid transection.tid %TYPE;
	v_eid transection.eid %TYPE;
	v_ammount transection.ammount %TYPE;
	v_t_date transection.t_date %TYPE;
	v_s_month transection.s_month %TYPE;
	--s1 varchar2;
	cursor payments_cur is
	select tid, eid, s_month,t_date,ammount from TRANSECTION@site_link where eid=X;
Begin

	select ename,gender,email,join_date 
	into v_ename,v_gender,v_email,v_joinDate
	from EMPLOYEE@site_link where eid=X;
	select sid into  v_sid from  employee_salary@site_link where eid=X;
	select  basic,allowance  into v_basic,v_allowance from  salary@site_link where sid=v_sid;
	
	dbms_output.put_line('_______________________________');
	dbms_output.put_line('Employee Details_______________');
	dbms_output.put_line('Employee ID   : '||X);
	dbms_output.put_line('Name          : '||v_ename);
	dbms_output.put_line('Gender        : '||v_gender);
	dbms_output.put_line('Email         : '||v_email);
	dbms_output.put_line('Joining Date  : '||v_joinDate);
	dbms_output.put_line('_______________________________');
	dbms_output.put_line('Salary Details_________________');
	dbms_output.put_line('Basic         : '||v_basic);
	dbms_output.put_line('Allowance     : '||v_allowance);
	n1:=v_basic+v_allowance;
	dbms_output.put_line('Total Salary  : '||n1);
	dbms_output.put_line('_______________________________');
	dbms_output.put_line('Payments Details_______________');
	dbms_output.put_line('TransectionID  EmployeeID  MonthOfSalary  Leaves  PaymentDate  Amount');	
	open payments_cur;

	loop
		fetch payments_cur into v_tid,v_eid,v_s_month,v_t_date,v_ammount;
		exit when payments_cur%notfound;
		select  l_day  into v_l_day from leave@site_link where eid=X and l_month=v_s_month;
		DBMS_OUTPUT.PUT_LINE(TO_CHAR(v_tid)||'              '||TO_CHAR(v_eid)||'           '||TO_CHAR(v_s_month)||'         '||TO_CHAR(v_l_day)||'       '||TO_CHAR(v_t_date)||'    '||TO_CHAR(v_ammount));
		end loop;
	close payments_cur;
	
EXCEPTION 
   WHEN no_data_found THEN 
      dbms_output.put_line('THIS EMPLOYEE DOESNT EXIST!'); 
   WHEN others THEN 
      dbms_output.put_line('ERROR!');
end;
/
