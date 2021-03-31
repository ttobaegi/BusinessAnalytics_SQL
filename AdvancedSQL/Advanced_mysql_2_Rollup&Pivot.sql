use testdb;

# Roll up & Pivot
/* Roll up : SubTotal, Grandtotal 추가 */

SELECT * FROM Emp LIMIT 5;
SELECT * FROM Dept LIMIT 5; 

select id, pid
from dept


select d.id
	, max(d.dname) '부서명'
	, IF(d.pid=0,d.id,pid)	'상위부서'
	, sum(e.salary) '급여합'
from dept d 
inner join emp e on d.id = e.dept	
group by 1 ,3

select d.id
	, d.pid	'상위부서'
    , max(d.dname) '부서명'
	, sum(e.salary) '급여합'
from dept d 
inner join emp e on d.id = e.dept	
group by 1,2
WITH ROLLUP;

select d.id
	, d.pid
	, (select dname from dept where id=d.pid)	'상위부서'
    , CASE WHEN d.pid is not null THEN max(d.dname) ELSE '- 소계 -' END '부서명'
	, sum(e.salary) '급여합'
from dept d 
inner join emp e on d.id = e.dept	
group by 1, 2
WITH ROLLUP;

# subquery 자제하자 
# 1. selfjoin 
select d.id,
		p.id
from dept d
inner join dept p where d.id=

select d.id
	, d.pid
	, (select dname from dept where id=d.pid)	'상위부서'
    , CASE WHEN d.pid is not null THEN max(d.dname) ELSE '- 소계 -' END '부서명'
	, sum(e.salary) '급여합'
from dept d 
inner join emp e on d.id = e.dept	
group by 1, 2 
WITH ROLLUP;