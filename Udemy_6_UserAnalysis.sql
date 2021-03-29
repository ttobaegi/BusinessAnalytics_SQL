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
select user_id, website_session_id, created_at first_visit 
		, lead(1,created_at) over (partition by user_id order user_id, website_session_id) as second_visit
from website_sessions
where created_at between '2014-1-1' and '2014-11-03'
	and is_repeat_session =1
group by 1,2
order by 1,3 ;




-- first second 함수



