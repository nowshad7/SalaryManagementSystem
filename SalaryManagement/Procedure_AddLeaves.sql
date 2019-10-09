create or replace  Procedure AddLeave(v_lid in number, v_eid in number,v_l_month in varchar2,v_l_day in number)
is
begin
insert into leave values(v_lid,v_eid, v_l_month, v_l_day);
commit; 
end AddLeave;
/
