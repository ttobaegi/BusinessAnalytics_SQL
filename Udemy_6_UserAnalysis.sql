## USER ANALYSIS
-- user behavior and identify some of your most valuable customers

select order_id, order_item_id
from orders;

-- 1. REPEAT VISITOR valuable customers 
with repeated as (
select user_id, sum(is_repeat_session) repeat_sessions
from website_sessions 
where created_at between '2014-1-1' and '2014-11-1'
group by user_id
)
select repeat_sessions, count(distinct user_id) users
from repeated
group by 1 
order by 1;

-- Deeper dive on repeat
-- min max avg time between 1st 2nd session 
with diff as (
select datediff(lead(created_at,1) over (order by user_id, website_session_id) , created_at) 
from website_sessions
where created_at between '2014-1-1' and '2014-11-03'
	and is_repeat_session =1
group by user_id, website_session_id
)
select avg(days), min(days), max(days)
from diff;


-- ---------------------------------------------------------------------------------------------------
### the minimum, maximum, and average time between the first and second session 
-- time between the first and second session  :: group by user_id & order by user_id and created_at
-- 1) Identify relevant new sessions


	## MY SOLUTION 1 ( Multiple with statement )
with diff as (
select user_id, created_at fi , lead(created_at,1) over (partition by user_id order by user_id, created_at) sec
from website_sessions
where created_at between '2014-1-1' and '2014-11-03'  
group by 1,2
order by 1,2
)
, diff2 as (
/**	month difference of two dates in mysql : TIMESTAMPDIFF(UNIT, 'DATE1', 'DATE2')
Date Difference 알고싶은 경우 UNIT: DAY! DATE 아님 **/
select timestampdiff(day, fi, sec) gap
from diff
where sec is not null
) 
select avg(gap) avg_days_first_to_second, min(gap) min_days_first_to_second, max(gap) max_days_first_to_second
from diff2 ;

	## MY SOLUTION 2 ( single with statement )
with diff as (
select timestampdiff(day, created_at  , lead(created_at,1) over (partition by user_id order by user_id, created_at) ) gap
from website_sessions
where created_at between '2014-1-1' and '2014-11-03'  
group by user_id, created_at
)
select avg(gap) avg_days_first_to_second, min(gap) min_days_first_to_second, max(gap) max_days_first_to_second
from diff
where gap is not null;
-- first second 함수
-- SYNTAX :: lead (변수, num) 
-- partition by group by
-- mysql 시간 차이 계산 timestampdiff(month,'2012-03-20', created_at) 


-- ---------------------------------------------------------------------------------------------------
### Comparing new vs. repeat sessions by channel 
-- Channel | new sessions | repeat_sessions
-- 1) channel_group variable by utm_source, utm_campaign, http_referer
-- 2) by user_id, created_at 
-- 3) lead is null new else repeat
-- 4) count distinct case when new & repeat
-- 5) aggregate by channel 
							
select distinct utm_campaign from website_sessions;
with pattern as (
select case when

end as channel_group,
	case when lead(created_at,1) over (partition by user_id order by user_id, created_at)  is null then 'new' else 'repeat' end as nr
					/** partition by user_id : 유저 아이디 customer 별 세션(방문) 패턴 분석**/
from website_sessions
where created_at between '2014-1-1' and '2014-11-05'
group by user_id, created_at
)
select 
group by utm_source





-- ---------------------------------------------------------------------------------------------------
### 
comparison of conversion rates and revenue per session for repeat sessions vs new sessions.



-- ---------------------------------------------------------------------------------------------------
### comparison of conversion rates and revenue per 



