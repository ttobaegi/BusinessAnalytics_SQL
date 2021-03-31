/** 윈도우 함수 
인접한 row 에 대해서 서로 제어할 수 있는 함수
-- OVER() 함께 쓴다
-- OVER(PARTITION BY 프레임구분기준 ORDER BY 순위기준) 활용

ROW_NUMBER()
RANK()
DENSE_RANK()
PERCENT_RANK()
CUME_DIST()

FIRST_VALUE(COL)
LAST_VALUE(COL)
NTH_VALUE(COL,N)

LAG(N)
LEAD(N)
NTILE(N)

**/

-- Q 박씨 성인 임직원 급여 부서내 순위 확인해보기
select count(distinct id) from emp
where ename like '박%'				-- 17명 임직원

select id 
	, ename
    , dept
	, salary
from emp e
where ename like '박%'
order by dept, salary desc;

select e.* from emp e where ename like '박%' order by dept, salary desc;		-- alias.*

-- 프레임 구분 없이 순번 나열 : partition by X
# ROW_NUMBER() OVER () 
select row_number () '순번' , e.* from emp e; -- 에러발생 over가 없다
-- OVER() 반드시 필요
select row_number () over () '순번'	
	, e.*
from emp e
where ename like '박%'
;

-- Q 부서내 급여 순위를 구하자 
-- 부서 프레임 구분
# RANK() OVER()
# RANK() OVER(PARTITION BY 프레임구분기준 ORDER BY 순위기준)
select row_number () over () '순번'
	, e.*
    , rank() over(partition by dept order by dept, salary desc) '부서내 순위'		
		-- 윈도우함수 여러개 사용 시, 마지막 윈도우함수가 sorting의 우선순위를 가짐
        -- row_number() , rank() 중 뒤에쓰인 rank()기준의 sorting
from emp e
where ename like '박%'

select row_number () over (order by dept, salary desc) '순번'
						-- 부서,급여 순서로 순번을 매겨라 
	, e.*
    , rank() over(partition by dept order by dept, salary desc) '부서내 순위'		
from emp e
where ename like '박%'
;

select row_number () over (order by dept, salary desc) '순번'
							-- 부서,급여 순서로 순번을 매겨라 
	, e.*
    , rank() over(order by dept, salary desc) '부서내 순위'		
					-- 부서 프레임(partition by dept)이 없을 경우 전체프레임내 순위을 보여줌
from emp e
where ename like '박%'
;

select row_number () over (order by dept, salary desc) '순번'
						-- 부서,급여 순서로 순번을 매겨라 
	, e.*
    , rank() over(partition by dept order by dept, salary desc) '부서내 순위'	
	-- 동일한 급여를 가진 id n명에 대해 동일한 순위 k부여 다음 순위 k+n
    -- 박자세 박라국 2명 3위(급여500) 다음순위 박다지 3+2=5위
    -- 공동순위가 있어도 다음 순위 k+1로 표기하고 싶을 경우에는?
    # DENSE_RANK()
    , dense_rank() over(partition by dept order by dept, salary desc) '부서내 순위d'
    , round(percent_rank() over(partition by dept order by dept, salary desc),1) '부서내 %순위'
from emp e
where ename like '박%'
;

-- partition by dept order by dept, salary desc의 반복 
-- 동일한 쿼리의 반복을 줄이자 
# WINDOW 정의
# WINDOW W AS (partition by .. order by)
select row_number () over (order by dept, salary desc) '순번'
						-- 부서,급여 순서로 순번을 매겨라 
	, e.*
    , rank() over w'부서내 순위'	
    , dense_rank() over w '부서내 순위d'
    , round(percent_rank() over w,1) '부서내 %순위' 	-- 부서 내 위치
    , cume_dist() over w '부서내 %경계' 	-- 부서 내 %경계
    , ntile(2) over w '급여 등급' 		-- n개의 타일로 나누기 
    
from emp e
where ename like '박%'
WINDOW w AS (partition by dept order by dept, salary desc)	
-- window로 프레임 및 정렬기준 정의 후 alias로 대체 
;

-- Q2
select row_number() over(order by dept, salary desc)
	, e.*
    , sum(salary) over w '급여 누적치'					-- group by 없이 집계함수로 쓸 수 있음
    , first_value(salary) over w '부서내 1등 급여'
    , last_value(salary) over w '부서내 현재까지의 꼴등 급여'
    , nth_value(salary, 2) over w '부서내 2등 급여'
    , ntile(3) over w '급여등급'
    , lag(salary,1) over w '이전급여'
    , lead(salary,2) over w '다음급여'
from emp e
where ename like '박%'
window w as ( partition by dept order by dept, salary desc ) ;









