SET SERVEROUTPUT ON;

CREATE OR REPLACE trigger Fund_audit
BEFORE UPDATE ON FUND
FOR EACH ROW
DECLARE
	  v_date varchar2(30);
begin
	select sysdate into v_date from dual;
	insert into FUND_Audit values (:NEW.fund_amnt,:OLD.fund_amnt,v_date);
	dbms_output.put_line('Fund Updated');
	commit;
end;
/