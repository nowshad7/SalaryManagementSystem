create database smdb


clear screen;

DROP TABLE EMPLOYEE CASCADE CONSTRAINTS;
DROP TABLE SALARY CASCADE CONSTRAINTS;
DROP TABLE EMPLOYEE_SALARY CASCADE CONSTRAINTS;
DROP TABLE TRANSECTION CASCADE CONSTRAINTS;
DROP TABLE LEAVE CASCADE CONSTRAINTS;
DROP TABLE FUND CASCADE CONSTRAINTS;


CREATE TABLE EMPLOYEE (
	eid int, 
	ename varchar2(20),
    gender varchar2(5),	
	email varchar2(20),
	join_date varchar2(20) ,
        PRIMARY KEY(eid)); 



CREATE TABLE SALARY(
	sid int, 
	basic int, 
	allowance int,
	PRIMARY KEY(sid));

 
CREATE TABLE EMPLOYEE_SALARY(
	eid int, 
	sid int,
	FOREIGN KEY(eid) REFERENCES EMPLOYEE(eid),
	FOREIGN KEY(sid) REFERENCES SALARY(sid));
	
CREATE TABLE LEAVE(
    lid int,
	eid int, 
	l_month varchar2(15), 
	l_day int,
	PRIMARY KEY(lid));
	
CREATE TABLE TRANSECTION (
	tid int, 
	eid int,
	ammount int,
	t_date date,  
	s_month varchar2(15),
	PRIMARY KEY(tid),
	FOREIGN KEY(eid) REFERENCES EMPLOYEE(eid));
	
CREATE TABLE FUND (
       fid int,
	   fund_amnt int,
	   PRIMARY KEY(fid));
	   
CREATE TABLE FUND_Audit (
	   amnt_new int,
	   amnt_old int,
	   Update_date varchar2(30));
	
CREATE TABLE EMPLOYEE_SALARY_Audit(
	new_sid int,
	old_sid int,
	Changing_date varchar2(30));


insert into employee  values (1, 'Sajid Abdullah', 'M','sajid@gamil.com', '1/1/2019'); 
insert into employee  values (2, 'Samia Zahan','F', 'samia@gamil.com', '1/1/2019');  
insert into employee  values (3, 'Muna Saha','F', 'muna@gamil.com', '1/1/2019'); 
insert into employee  values (4, 'Robiul Hasan','M', 'nowshad@gamil.com', '1/1/2019');  
insert into employee  values (5, 'Shahriar Shibli','M', 'shibli@gamil.com', '1/1/2019'); 
insert into employee  values (6, 'Shourav Saha','M', 'shourav@gamil.com', '1/1/2019');  
insert into employee  values (7, 'Apurbo Roy','M', 'apu@gamil.com', '1/1/2019');  
insert into employee  values (8, 'Tanvir Rahman','M', 'mrt@gamil.com', '1/1/2019'); 
insert into employee  values (9, 'Sonia Khatun','F', 'sonia@gamil.com', '1/1/2019');  
insert into employee  values (10, 'Humayan Nila','F', 'nila@gamil.com', '1/1/2019'); 
 
  
 
insert into salary values(1, 18000,5000); 
insert into salary values(2, 20000,5000); 
insert into salary values(3, 22000,6000); 
insert into salary values(4, 35000,6500); 
insert into salary values(5, 50000,7000); 

 
insert into employee_salary values(1,1); 
insert into employee_salary values(2, 3); 
insert into employee_salary values(3,5); 
insert into employee_salary values(4,2);
insert into employee_salary values(5,1); 
insert into employee_salary values(6,3);
insert into employee_salary values(7,5); 
insert into employee_salary values(8,4);
insert into employee_salary values(9,2); 
insert into employee_salary values(10,4);



insert into leave values(1,1, 'Jan/19', 3); 
insert into leave values(2,3, 'Jan/19', 4); 
insert into leave values(3,2, 'Jan/19', 5); 
insert into leave values(4,6, 'Jan/19', 3); 
insert into leave values(5,4, 'Jan/19', 1); 
insert into leave values(6,5, 'Jan/19', 5); 
insert into leave values(7,9, 'Jan/19', 3); 
insert into leave values(8,7, 'Jan/19', 3); 
insert into leave values(9,8, 'Jan/19', 4); 
insert into leave values(10,10, 'Jan/19', 3);
insert into leave values(11,1, 'Fab/19', 5);  

insert into fund values(1,1000000);



commit;
 
