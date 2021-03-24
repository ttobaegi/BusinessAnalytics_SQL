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
## how thos customers behaved over time
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

## Retention graph by months : X months Y users(number)

-- --------------------------------------------------------------------
## 3. whether there are any trends in customer retention
## ? : Of those who came in Jan, how many returned in Feb? 
## One month interval > iterative model
/**
1) table where each user's visits are logged by month
2) identify the time lapse between each visit
**/
select min(created_at), max(created_at)
from orders;

SELECT user_id
		/**	month difference of two dates in mysql **/
		, timestampdiff(month,'2013-01-01', created_at) as visit_month
FROM orders
where created_at >= '2014-01-01'
group by 1,2
order by 1,2;



	
