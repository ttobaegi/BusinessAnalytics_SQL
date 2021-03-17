/** BASIC **/
-- Timestamp

-- Timezone check
show variables like '%time_zone%'
select @@time_zone;

set time_zone = KST; 
set global time_zone = 'UTC'   		-- root authority


alter table Dept add column workdate timestamp not null default current_timestamp
			on update current_timestamp;
            
select * from Dept
-- update Dept set dname = '클라팀' 
where id = 7;

create table test (
	id int unsigned not null auto_increment,
    ttt varchar(31) not null,
    primary key(id)
    );
insert into test(ttt) values ('aaa1'), ('aaa2'), ('aaa3');
update Test set dept = f_rand1('34567') ;
select * from Test;
TRUNCATE table 