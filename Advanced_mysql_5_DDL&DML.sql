/** BASIC **/
-- Timestamp

-- Timezone check
show variables like '%time_zone%'
select @@time_zone;

set time_zone = KST; 
set global time_zone = 'UTC'   		-- root authority


-- alter table Dept add column workdate timestamp not null default current_timestamp
			on update current_timestamp;
            
select * from Dept
-- update Dept set dname = '클라팀' 
where id = 7;

-- create table test (
	id int unsigned not null auto_increment,
    ttt varchar(31) not null,
    primary key(id)
    );
select * from test;

# write 문 주석처리하기
-- insert into test(ttt) values ('aaa1'), ('aaa2'), ('aaa3');
-- update Test set dept = f_rand1('34567') ;

# FK 생성하기
# FK test dept - dept id 
# CASCADE 설정 > dept id 삭제/업데이트 시 반영됨
# FK 생성시 인덱스도 생성됨

show create table test;

-- TRUNCATE table test;
insert into test(ttt,dept) values ('aaa1',1), ('aaa2',2), ('aaa3',3);

-- DELETE from test where id> 0 ;
