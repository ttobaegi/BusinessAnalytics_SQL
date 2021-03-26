## ANALYZING WEBSITE PERFORMANCE

-- Using temporary tables to perform multi-step analyses
-- CREATE TEMPORARY TABLE newtablename
SELECT * FROM website_sessions
where website_session_id <= 100;

-- MOST COMMON PAGE :: WHERE YOU SHOULD FOCUS ON WEBSITE
SELECT pageview_url, count(distinct website_pageview_id) AS pvs
FROM website_pageviews 
group by 1
order by 2 desc ;

-- MOST COMMON ENTRY PAGE
	# MY SOLUTION
with a as (
select case when row_number() over(partition by website_session_id order by website_pageview_id) = 1 then pageview_url else null end as top_entry
FROM website_pageviews
) 
select top_entry, count(top_entry) cnt from a where top_entry is not null  group by 1 order by 2 desc;

	# SOLUTION BY OTHER USERS
    -- 1) temporary table for minimun pageview_id group by session_id
-- drop temporary table first_pageview;
CREATE temporary table first_pageview
SELECT website_session_id,
	min(website_pageview_id) as min_pv_id
FROM website_pageviews 
where created_at < '2012-06-09'
group by 1;
select * from first_pageview limit 3;
	-- 2) 
select website_pageviews.pageview_url as landing_page, -- entry page
	count(distinct first_pageview.website_session_id) as sessions_hitting_this_lander
from first_pageview
	left join website_pageviews
		on first_pageview.min_pv_id = website_pageviews.website_pageview_id
group by website_pageviews.pageview_url ;


-- ------------------------------------------------------------------------
### 1. IDENTIFYING TOP WEBSITE PAGES (THE MOST TRAFFIC)
-- Goal : most-viewed website page, rank by session volume, date < 2012.06.09

	# MY SOLUTION 
-- steps :: WITH & window function
with a as 
(
select pageview_url url, count(website_session_id) volume /** url 별 조회수 **/
from website_pageviews
where created_at < '2012-06-09'
group by 1
)
select url, volume, rank() over (order by volume desc) as volume_rank
			-- grouping 된 data set 참조하기때문에 partition by 필요없음
from a
order by volume_rank ;

-- > DIG INTO WHETHER THE LIST IS ALSO REPRESENTATIVE OF TOP ENTRY PAGES 
-- > PERFORMANCE OF EACH OF TOP PAGES TO LOOK FOR IMPROVEMENT OPPORTUNITIES

-- ------------------------------------------------------------------------
### 2. IDENTIFYING TOP Entry Pages (THE MOST TRAFFIC)
-- Goal : all entry pages, rank by session volume, date < 2012.06.12

	#MY SOLUTION
    -- 1)
	-- 동일한 session_id 내 pageview_id 리스트 중 첫번째 page_view_id = entry page
    -- STEPS : with + row_number & CASE when page_url else null
    -- 1. session_id 그룹 내 row number 추출하여 1인 것 entry 
    -- 2. filter out entry null
    -- 3. count(session_id) group by entry
with a as(
select 
	case when row_number() over (partition by website_session_id order by website_pageview_id) = 1 then pageview_url else null end landing_page
    from website_pageviews 
	where created_at < '2012-06-09'
)
select landing_page , count(landing_page) sessions_hitting_this_lander
from a 
where landing_page is not null 
group by 1 ;


-- ------------------------------------------------------------------------
### 3. BOUNCE RATE
-- key landing page의 Bounce Rate, Conversion Rate﻿ 파악 및 비교(A/B 테스트)
/** 1) Landing Page by session
	2) Pageview & Bounce by session
  	3) Total sessions & Bounced sessions by Landing Page **/

-- Goal : landing page, bounced sessions, bonced rate
	# MYSOLUTION
with a as (
select 
	website_pageview_id,
    website_session_id,
	row_number() over(partition by website_session_id order by website_pageview_id ) as pageview_seq
from website_pageviews 
where created_at <'2012-06-09'
) 
, b as (
select website_session_id, 
	case when max(pageview_seq) = 1 then 1 else 0 end as bounce
from a
group by 1

)
select count(*) sessions , 
	sum(case when bounce = 1 then 1 else 0 end ) as bounced_sessions,
    concat((sum(case when bounce = 1 then 1 else 0 end )/count(*)*100),'%') as bounce_rate
from b;

	# OTHERSSOLUTION
-- 1) first_pageview, sessions_landing_page, bounce_sessions 임시테이블 생성
-- drop temporary table sessions_landing_page;
/**first pageview**/
CREATE temporary table first_pageview
SELECT website_session_id,
	min(website_pageview_id) as min_pv_id
FROM website_pageviews 
where created_at < '2012-06-09'
group by 1;

/**sessions_landing_page**/
CREATE TEMPORARY TABLE sessions_landing_page
select f.website_session_id,
	w.pageview_url as landing_page
from first_pageview f
	left join website_pageviews w on w.website_pageview_id = f.min_pv_id 
where pageview_url = '/home' ;

/**bounce_sessions**/
CREATE TEMPORARY TABLE bounce_sessions
select l.website_session_id,
		l.landing_page,
        count(w.website_pageview_id) as cnt_viewed
from sessions_landing_page l 
	left join website_pageviews w 
		on w.website_session_id=l.website_session_id
group by 1,2
having count(w.website_pageview_id)  = 1; 	-- BOUNCE SESSION 

select 
count(distinct l.website_session_id) as sessions,
count(distinct b.website_session_id) as bounced_sessions,
count(distinct b.website_session_id) /count(distinct l.website_session_id) as bounce_rate
from sessions_landing_page l
	left join bounce_sessions b
		on l.website_session_id = b.website_session_id ;

-- ------------------------------------------------------------------------
### 4. LANDING PAGE TEST
-- 3의 결과, Bounce rate 가 높은 entry page > new custom landing page (/lander-1) 테스트 필요
-- GOAL : 50/50 Bounce rate comparison  (/lander-1) vs (/home) for gsearch nonbrand traffic.
-- STEPS
-- 1) find out when the new page lander launched
-- 2) finding the first website_pageview_id for relevant sessions
-- 3) identifying the landing page of each session
-- 4) counting pageviews for each session to identify bounces
-- 5) summarizing total sessions and bounced sessions by LP
select min(created_at) from website_pageviews where pageview_url='/lander-1';
-- 시작 시점 2012-06-19 분석시점 2012-07-28

-- * MYSOLUTION
WITH a as (
select 
	w.website_session_id,
    p.website_pageview_id ,
    pageview_url landing_page,
	row_number() over(partition by website_session_id order by website_pageview_id ) as pageview_seq
from website_sessions w
	left join website_pageviews p on p.website_session_id = w.website_session_id 
where utm_source = 'gsearch' and utm_campaign = 'nonbrand' and w.created_at between '2012-06-19' and '2012-07-28' 
	-- 1,2
)
, b as (
select 
	website_session_id,
    landing_page,
	case when max(pageview_seq) = 1 then 1 else 0 end as bounce
from a 
group by 1  
)
, c as(
select landing_page,
	count(distinct website_session_id) total_sessions,
	sum(bounce) bounce_sessions,
	concat(sum(bounce)/count(distinct website_session_id)*100,'%') bounce_rate
from b
group by 1
) 
select * from c where landing_page in ('/lander-1','/home')
;


-- * SOLUTION by others : temporary table 
-- 1) find out when the new page lander launched
select min(created_at), min(website_pageview_id) from website_pageviews where pageview_url = '/lander-1' and created_at is not null ;

-- CREATE temporary table first_test -- pageviews
SELECT w.website_session_id,
	min(website_pageview_id) as min_pv_id 			-- 2) finding the first website_pageview_id for relevant sessions
FROM website_pageviews p
	inner join website_sessions w
		on w.website_session_id = p.website_session_id
			and w.created_at < '2012-07-28' and p.website_pageview_id > 23504  -- after 1) min(website_pageview_id) of lander-1
            and utm_source = 'gsearch' and utm_campaign = 'nonbrand' 
group by 1;

-- create temporary table nonbrand_test_landing_page
select f.website_session_id, 
	p.pageview_url as landing_page  		
from first_test f 
	left join website_pageviews p 
		on p.website_pageview_id = f.min_pv_id  -- 3) identifying the landing page of each session
where p.pageview_url  in ('/lander-1','/home');
drop temporary table nonbrand_test_bounced

create temporary table nonbrand_test_bounced
select l.website_session_id,
		l.landing_page,
        count(p.website_pageview_id) as cnt_viewed 	-- 4) counting pageviews for each session to identify bounces

from nonbrand_test_landing_page l left join website_pageviews p on p.website_session_id = l.website_session_id 
group by 1,2
having count(p.website_pageview_id) = 1 ; -- count(website_pageview_id) =1  :: BOUNCED


select l.landing_page, 								-- 5) summarizing total sessions and bounced sessions by LP
	COUNT(DISTINCT l.website_session_id) as sessions,
    COUNT(DISTINCT b.website_session_id) as bounced_sessions,
	COUNT(DISTINCT b.website_session_id) / COUNT(DISTINCT l.website_session_id) as bounce_rate
FROM nonbrand_test_landing_page l
left join nonbrand_test_bounced b on l.website_session_id = b.website_session_id
group by 1;



-- ------------------------------------------------------------------------
### 5. LANDING PAGE TREND ANALYSIS
-- GOAL : paid search nonbrand traffic landing on /home /lander-1 , trended weekly & bouncerate weekly
-- week_start_date | bounce_rate | home_sessions | lander_sessions
-- 1) finding the first website_pageview_id for relevant sessions
-- 2) identifying the landing page of each session >> home or lander-1
-- 3) counting pageviews for each session & identify bounces
-- 4) summarizing by week :: bounce rate, sessions to each lander

with landing_page as(
select w.website_session_id,
	w.created_at,			 					-- session created_at
    p.website_pageview_id,
    p.pageview_url,
    case when row_number() over (partition by w.website_session_id order by w.website_session_id, p.website_pageview_id) = 1 then 1 else 0 end as landing
from website_sessions w 
	left join website_pageviews p on w.website_session_id = p.website_session_id
where utm_campaign = 'nonbrand' and w.created_at < '2012-08-31'
) , bounce as(
select website_session_id, 
	case when count(distinct website_pageview_id) = 1 then 1 else 0 end bounced -- count of pageviewid = 1 : BOUNCED
from landing_page
group by website_session_id
)
select min(date(created_at)) as week_start_date,
		concat(sum(bounced)/ count(distinct l.website_session_id)*100,'%') bounce_rate,
		sum(case when pageview_url='/home' then 1 else 0 end) home_sessions,
		sum(case when pageview_url='/lander-1' then 1 else 0 end) lander_sessions
from landing_page l left join bounce b on b.website_session_id = l.website_session_id 
group by yearweek(created_at);

-- ------------------------------------------------------------------------
### 6. CONVERSION FUNNELS
-- sessions | click rate by pagenames 
-- full conversion funnel :: from /lander-1 to order
-- analyzing how many customers make it to each step
-- between '2012-08-05' and '2012-09-05'

-- with : total sessions & sessions by pageview_url 
-- case when > pivot
select distinct pageview_url from website_pageviews;
with total as(
select pageview_url, website_session_id, count(distinct website_pageview_id) cv
from website_pageviews p
where p.created_at between '2012-08-05' and '2012-09-05' 
	and pageview_url in ('/lander-1','/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')
group by 1, 2
)
, b as (
select count(distinct website_session_id),
		sum(case when pageview_url = '/products' then 1 else 0 end) as to_products,
		sum(case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end) as to_mrfuzzy,
		sum(case when pageview_url = '/cart' then 1 else 0 end) as to_cart,
		sum(case when pageview_url = '/shipping' then 1 else 0 end) as to_shipping,
		sum(case when pageview_url = '/billing' then 1 else 0 end) as to_billing,
        sum(case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end) as to_thankyou
from total
)
select to_products+ to_mrfuzzy+to_cart+to_shipping+to_billing+to_thankyou from b;

(select pageview_url, website_session_id, count(distinct website_pageview_id) cv
from website_pageviews p
where p.created_at between '2012-08-05' and '2012-09-05' 
group by 1, 2
)a