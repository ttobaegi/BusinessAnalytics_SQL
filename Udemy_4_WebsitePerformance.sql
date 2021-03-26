## ANALYZING WEBSITE PERFORMANCE

-- Using temporary tables to perform multi-step analyses
CREATE TEMPORARY TABLE newtablename
SELECT * FROM website_sessions
where website_session_id <= 100;

SELECT * FROM website_pageviews order by 1 ;-- where website_session_id <= 1000; 

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
CREATE temporary table first_pageview
SELECT website_session_id,
	min(website_pageview_id) as min_pv_id
FROM website_pageviews 
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
select landing_page , count(entry) sessions_hitting_this_lander
from a 
where entry is not null 
group by 1 ;