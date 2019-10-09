create or replace package myPackage as 

	function Generate_Salary(n1 in number, s1 in varchar2)
    return number; 

	Procedure Transect_Salary(n1 in number, n2 in number,s1 in varchar2);
	
end myPackage;
/