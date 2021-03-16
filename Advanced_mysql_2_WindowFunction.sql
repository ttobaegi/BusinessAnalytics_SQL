/** 윈도우 함수 **/
select count(distinct id) from emp
where ename like '박%'
order by dept, salary desc;

select id
	, ename
    , dept
	, salary
from emp
where ename like '박%'
order by dept, salary desc;

select row_number () over () '순번',
	, ename
    , dept
	, salary
from emp e;