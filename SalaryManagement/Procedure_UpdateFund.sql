create or replace  Procedure Update_Fund(n1 in number)
       
       is
	   v_fund_amnt fund.fund_amnt %TYPE;
Begin

select fund_amnt into v_fund_amnt from fund where fid=1;
v_fund_amnt:= v_fund_amnt-n1;

update FUND set fund_amnt=v_fund_amnt where fid=1;
commit;

EXCEPTION
	When no_data_found then
		DBMS_OUTPUT.PUT_LINE('No Data Found');
	When others then
		DBMS_OUTPUT.PUT_LINE('Something wrong happened');

end Update_Fund;
/