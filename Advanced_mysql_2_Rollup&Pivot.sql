use testdb;

# Roll up & Pivot
/* Roll up : SubTotal 추가 */

SELECT * FROM Emp LIMIT 5;
SELECT * FROM Dept LIMIT 5; 

select id, pid
from dept

select AVG(salary)from emp GROUP BY dept
select d.id
	, max(d.dname) '부서명'
	, IF(d.pid=0,d.id,pid)	'상위부서'
	, sum(e.salary) '급여합'
from dept d 
inner join emp e on d.id = e.id	
group by 1,3

select d.id
	, d.pid	'상위부서'
    , max(d.dname) '부서명'
	, sum(e.salary) '급여합'
from dept d 
inner join emp e on d.id = e.id	
group by 1,2
WITH ROLLUP;