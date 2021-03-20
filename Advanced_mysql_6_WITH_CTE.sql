/** WITH CTE
CTE common table expression
절차 순서대로 작성하여 쿼리작성하고 읽기 쉬움, 유지보수 쉬움
 **/
 
 select d.id
		, d.dname
        , format(avg(e.salary) *10000, 0 )			-- 천단위 구분
	from dept d inner join emp e on d.id=e.dept
group by d.id;

# 최저 최대 급여 구하기
-- limit & union 으로는 구할 수 없음 > order by는 한번만 적용 가능
 select d.id
		, d.dname
        , format(avg(e.salary) * 10000, 0 )	avgsal	-- 천단위 구분
	from dept d inner join emp e on d.id=e.dept
group by d.id;

-- with 문으로 
WITH AvgSal AS (
		select d.id, d.dname, format(avg(e.salary) * 10000,0) avgsal
		from dept d inner join emp e on d.id=e.dept
		group by d.id
),
	MaxAvgSal AS (
		select * from AvgSal order by avgsal desc limit 1 
),
	MinAvgSal AS (
		select * from AvgSal order by avgsal limit 1
),
SumUp AS (
		select * from MaxAvgSal
        Union
        select * from MinAvgSal
)
select * from SumUp;


WITH AvgSal AS (
		select d.dname, avg(e.salary) avgsal
		from dept d inner join emp e on d.id=e.dept
		group by d.id
),
	MaxAvgSal AS (
		select * from AvgSal order by avgsal desc limit 1 
),
	MinAvgSal AS (
		select * from AvgSal order by avgsal limit 1
),
SumUp AS (
		select '최고' as gb, m1.* from MaxAvgSal m1			-- 최고/최저 row 표시하기 위해 컬럼 추가
        Union
        select '최저' as gb, m2.* from MinAvgSal m2
)
select gb, dname, format(avgsal*10000,0) from SumUp
UNION
select '', '평균급여차액' , format( (max(avgsal)-min(avgsal))*10000, 0) from SumUp ;



# 재귀 CTE
