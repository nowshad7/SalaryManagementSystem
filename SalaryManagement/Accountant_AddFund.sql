SET SERVEROUTPUT ON;
SET VERIFY OFF;

DECLARE

X number:= &Fund_Amount_to_add;

v_fund_amnt number;

Begin

	select fund_amnt into v_fund_amnt from fund where fid=1;
	dbms_output.put_line('Old Fund: '||v_fund_amnt);
	v_fund_amnt:= v_fund_amnt+X;
	dbms_output.put_line('New Fund: '||v_fund_amnt);
	update FUND set fund_amnt=v_fund_amnt where fid=1;
	commit;
	
	EXCEPTION
	When no_data_found then
		DBMS_OUTPUT.PUT_LINE('No Data Found');
	When others then
		DBMS_OUTPUT.PUT_LINE('Something wrong happened');
end;
/
