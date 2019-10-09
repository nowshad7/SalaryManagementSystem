clear screen;
SET SERVEROUTPUT ON;
SET VERIFY OFF;

DECLARE

X number:= &Eid;
Y varchar2(15):= '&Month_of_Salary';

r number;

Begin

  r := myPackage.Generate_Salary(X,Y);
 
  DBMS_OUTPUT.PUT_LINE(r);
  myPackage.Transect_Salary(X,r,Y);
  commit;
end;
/
