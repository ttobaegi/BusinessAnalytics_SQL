# DAU
# MAU 
# LTV
# AARRR

select *
from website_sessions
limit 5;


## 1. Identify the original pool of customers
SELECT count(DISTINCT user_id)
FROM orders
where month(created_at) = 1 and year(created_at) = 2013;


-- --------------------------------------------------------------------
## how those customers behaved over time
## 2. How many of them returned per month over the rest of the year?
/**
1) with : 2014 1월 고객 
2) 2013년 월별 고객 group by year & month
3) 2) in 1) 
**/
WITH a as(
SELECT count(DISTINCT user_id) 
FROM orders
where month(created_at) = 1 and year(created_at) = 2014
)
SELECT YEAR(created_at),
		MONTH(created_at),
		count(distinct user_id) as number
FROM orders o 
where year(o.created_at) = 2014 and user_id in (select user_id from a)
group by 1,2;

############## Retention graph by months : X months Y users(number)

-- --------------------------------------------------------------------
### EVOLUTION OF CUSTOMER RETENTION OVER TIME
## 3. whether there are any trends in customer retention
## ? : Of those who came in Jan, how many returned in Feb? 
## One month interval > iterative model
/**
1) VISIT LOG table : where each user's visits are logged by month
2) identify the time lapse between each visit
**/
select min(created_at), max(created_at)
from orders;


-- 1) VISIT LOG
SELECT user_id
		/**	month difference of two dates in mysql : TIMESTAMPDIFF(UNIT, 'DATE1', 'DATE2') **/
		, timestampdiff(month,'2012-03-20', created_at) as visit_month
FROM orders
group by 1,2
order by 1,2;


-- 2) TIME LAPSE
-- for each person and for each month, see when the next visit is
-- b : timpelapse table
with visit_log as 
(
SELECT user_id
		/**	month difference of two dates in mysql : TIMESTAMPDIFF(UNIT, 'DATE1', 'DATE2') **/
        -- 2012-03-20 (데이터시작), user_id별 주문월 : visit_month
		, timestampdiff(month,'2012-03-20', created_at) as visit_month
FROM orders
group by 1,2
order by 1,2
) 
	-- user_id 별 구매월, 다음구매월
select user_id, visit_month, lead(visit_month,1) over w  as next_visit_month from visit_log 
window w as (partition by user_id order by user_id, visit_month) 
order by 1, 2, 3 desc;

-- 3) TIME GAPS
with visit_log as 
(
SELECT user_id
		, timestampdiff(month,'2012-03-20', created_at) as visit_month
FROM orders
group by 1,2
) 
, time_lapse as (
-- user_id 별 구매월, 다음구매월
select user_id, visit_month, lead(visit_month,1) over w  as next_visit_month from visit_log 
window w as (partition by user_id order by user_id, visit_month) 
)
select user_id, visit_month, next_visit_month, next_visit_month-visit_month  as time_gap 
from time_lapse
-- where next_visit_month is not null
-- where time_gap is not null -- select 문 계산필드의 alias에 조건 걸 수 없음 !!!!!!
order by 1,2;

-- 고객 Retention 분석의 목적은 일정기간이 지난 후에 돌아오는 고객의 비율을 측정하고자함
## proportion of customers who return after x lag of time
-- 1. COMPARE the number of customers visiting in a given month to how many of those return the next month
-- 2. CATEGORIZE depending on their visit patterns
-- 4) categorized customer
with visit_log as 
(
SELECT user_id
		, timestampdiff(month,'2012-03-20', created_at) as visit_month
FROM orders
group by 1,2
) 
, time_lapse as (
select user_id, visit_month, lead(visit_month,1) over w  as next_visit_month from visit_log 
window w as (partition by user_id order by user_id, visit_month) 
)
, time_diff as (													-- with 구문 다중 : AS !!!!!!!!!!
select user_id, visit_month, next_visit_month, next_visit_month-visit_month  as time_gap 
from time_lapse
)
select user_id,	
		visit_month,
					-- time_gap 을 기준으로 Customer Segmentation
		case when time_gap is null then 'lost' 
			when time_gap = 1 then 'retained'
            else 'lagger' end  as cust_type
from time_diff;

-- 5) # of customers who visited in a given month & how many of those return the next month
with visit_log as 
(
SELECT user_id
		, timestampdiff(month,'2012-03-20', created_at) as visit_month
FROM orders
group by 1,2
) 
, time_lapse as (
select user_id, visit_month, lead(visit_month,1) over w  as next_visit_month from visit_log 
window w as (partition by user_id order by user_id, visit_month) 
)
, time_diff as (												
select user_id, visit_month, next_visit_month, next_visit_month-visit_month  as time_gap 
from time_lapse
)
, segment as (
select user_id,	
		visit_month,
		case when time_gap is null then 'lost' 
			when time_gap = 1 then 'retained'
            else 'lagger' end  as cust_type
from time_diff
)
-- proportion of cust_type = retained : SUM(CASE WHEN - THEN 1 ELSE 0)
select visit_month , sum(case when cust_type = 'retained' then 1 else 0 end ) /count(user_id) as retention from segment group by 1;

############## Retention graph by months : X months Y retention rate(number) : MONTH-TO-MONTH Customer retention
select * from orders limit 1;
## ARPU 
with month_arpu as 
(
SELECT user_id,
		datediff(mon

SELECT user_id
		, timestampdiff(month,'2012-03-20', created_at) as visit_month
        , round(sum(price_usd),2) as revenue
FROM orders
where  timestampadd(year, -1, '2012-12-31') 
group by 1,2
) 
, time_lapse as (
select user_id, visit_month, lead(visit_month,1) over w  as next_visit_month from visit_log 
window w as (partition by user_id order by user_id, visit_month) 
)
, time_diff as (												
select user_id, visit_month, next_visit_month, next_visit_month-visit_month  as time_gap 
from time_lapse
)
, segment as (
select user_id,	
		visit_month,
		case when time_gap is null then 'lost' 
			when time_gap = 1 then 'retained'
            else 'lagger' end  as cust_type
from time_diff
)
-- proportion of cust_type = retained : SUM(CASE WHEN - THEN 1 ELSE 0)
select visit_month , sum(case when cust_type = 'retained' then 1 else 0 end ) /count(user_id) as retention from segment group by 1;

