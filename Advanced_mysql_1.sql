## Advanced_mysql_1
# Test data 생성

CREATE SCHEMA testdb;
use testdb;

create table Dept(
  id tinyint unsigned not null auto_increment,
  pid tinyint unsigned not null default 0 comment '상위부서id',
  dname varchar(31) not null,
  PRIMARY KEY(id)
);

create table Emp(
  id int unsigned not null auto_increment,
  ename varchar(31) not null,
  dept tinyint unsigned not null,
  salary int not null default 0,
  primary key(id),
  foreign key(dept) references Dept(id)
);

insert into Dept(pid, dname) values (0, '영업부'), (0, '개발부');

select * from Dept;
insert into Dept(pid, dname) values (1, '영업1팀'), (1, '영업2팀'), (1, '영업3팀'),  (2, '서버팀'),  (2, '클라이언트팀');

select d1.dname as '상위부서', d2.*
  from Dept d1 inner join Dept d2 on d1.id = d2.pid;
  
select * from Emp;

select rand()						# 0-1 난수 생성
select rand()*10					# 1-10 난수 생성 
select CEIL(rand() * 7);			# 소숫점 올림 CEIL 
select length('한들abc');			# 바이트 수 LENGTH
select char_length('한들abc');		# 글자 수 CHAR_LENGTH

select CEIL(rand()*10);

SET GLOBAL log_bin_trust_function_creators = 1;

/** Stored Function 생성 
CREATE FUNCTION `f_rand1` (_str varchar(255))		
RETURNS varchar(31)						
BEGIN
	DECLARE v_ret varchar(31);					
    DECLARE v_len tinyint;
    
    SET v_len = char_length(_str);
    SET v_ret = substring(_str, CEIL(rand() * v_len), 1);
    
RETURN v_ret;
END
**/

select f_rand1('1234567');		# 부서 1-7

/** Stored Function 생성 
CREATE FUNCTION `f_randname`() 
RETURNS varchar(31) 
BEGIN
	DECLARE v_ret varchar(31);
    DECLARE v_lasts varchar(244) default '김이박조전최천방지마유배원';
    DECLARE v_firsts varchar(244) default '순신세종성호지혜가온세호은국가나다라마바사아자차파태결찬희';
    
    set v_ret = concat(f_rand1(v_lasts), f_rand1(v_firsts), f_rand1(v_firsts) );

RETURN v_ret;
END
**/

select f_randname();

desc Emp;
insert into Emp(ename, dept, salary) values (f_randname(), f_rand1('34567'), f_rand1('123456789') * 100);
/** Stored Procedure 반복작업 수행
CREATE PROCEDURE `sp_test_emp`(_cnt int)
BEGIN
	declare v_idx int default 0;		# 변수 선언 
	
    while v_idx < cnt
    do 
		insert into Emp(ename, dept, salary) values (f_randname(), f_rand1('34567'), f_rand1('123456789') * 100);
		set v_idx = v_idx + 1 ;
    end while;
END

**/
call sp_test_emp(250);
select * from emp;			

select dept, count(*) from Emp group by dept;

select dept, max(salary)
  from Emp
group by dept;

select * from Emp where id in (4,2,1,6,9);





-- ----------------------------------------------- 임의의 1글자 반환

CREATE DEFINER=`mydeal`@`%` FUNCTION `f_rand1`(_str varchar(255)) RETURNS varchar(31) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
BEGIN
  declare v_ret varchar(31);
  declare v_len tinyint;
  
  set v_len = char_length(_str);
  set v_ret = substring(_str, CEIL(rand() * v_len), 1);

RETURN v_ret;
END


-- ----------------------------------------------- 임의의 이름 반환
CREATE DEFINER=`mydeal`@`%` FUNCTION `f_randname`() RETURNS varchar(31) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
BEGIN
  declare v_ret varchar(31);
  declare v_lasts varchar(255) default '김이박조최전천방지마유배원';
  declare v_firsts varchar(255) default '순신세종성호지혜가은세호윤국가나다라마바사아자차파태하결찬희';
  
  set v_ret = concat( f_rand1(v_lasts), f_rand1(v_firsts), f_rand1(v_firsts) );

RETURN v_ret;
END