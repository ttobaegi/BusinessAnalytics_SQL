USE mavenfuzzyfactory;   /** Name of the schema**/

/** Analyzind business Patterns **/
-- Generating insights to help you maximize efficiency and anticipate future trends
-- Day-Parting analysis to understand how much support staff 
-- Analyzing seasonality to better prepare for upcoming spikes or slowdowns in demand

-- MySQL date functions 
-- QUARTER MONTH WEEK DATE WEEKDAY HOUR

SELECT 
	website_session_id,
	created_at,
    HOUR(created_at) AS hr,
    WEEKDAY(created_at) AS wkday,   -- 0 = Monday, 2=Tuesday, etc
    CASE 
		WHEN WEEKDAY(created_at) IN ('6','7') THEN 'weekend'
        ELSE 'weekday'
        END AS wkday2,				-- CASE WHEN THEN ELSE END***  
	QUARTER(created_at) AS qtr,
    MONTH(created_at) AS mo,
    DATE(created_at) AS date,
    WEEK(created_at) AS wk
    
FROM website_sessions

WHERE website_session_id between 150000 AND 155000 -- arbitrary


/** Assignment1 **/
-- BUSINESS SITUATION
-- Understanding Seasonality : take a look at 2012's monthly and weekly Session/Order volume patterns > Seasonal Patterns
SELECT 
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,   -- **You can't have a space between COUNT and (, ignore space SQL mode setting
	COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2013-01-01'
GROUP BY 1,2
ORDER BY 1,2,3,4

SELECT 
	YEAR(website_sessions.created_at) AS yr,
    WEEK(website_sessions.created_at) AS wk,
    MIN(DATE(website_sessions.created_at)) AS weekstart,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,   
	COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2013-01-01'
GROUP BY 1,2
ORDER BY 1,2,3,4,5

-- (CONCLUSION) FROM 2012-11-11 week to 18 week doubling of our order volume

/** Assignment2 **/
-- BUSINESS SITUATION
-- Analyzing Business Patterns 
-- adding live chat support to the website 
-- the average website session volume, by hour of day and by day wek
-- AVOID the holiday time and use a date range of Sep 15 - Nov 16, 2012

SELECT 						-- PIVOT OUT EACH OF THE DAYS OF WEEK INTO DIFFERENT COLUMNS
	hr,
	-- ROUND(AVG(website_sessions),1) AS abs_sessions,
    ROUND(AVG(CASE WHEN wkday=0 THEN website_sessions ELSE NULL END),1) AS mon,
    ROUND(AVG(CASE WHEN wkday=1 THEN website_sessions ELSE NULL END),1) AS tue,
    ROUND(AVG(CASE WHEN wkday=2 THEN website_sessions ELSE NULL END),1) AS wed,
    ROUND(AVG(CASE WHEN wkday=3 THEN website_sessions ELSE NULL END),1) AS thur,
    ROUND(AVG(CASE WHEN wkday=4 THEN website_sessions ELSE NULL END),1) AS fri,
    ROUND(AVG(CASE WHEN wkday=5 THEN website_sessions ELSE NULL END),1) AS sat,
    ROUND(AVG(CASE WHEN wkday=6 THEN website_sessions ELSE NULL END),1) AS sun
FROM (
		SELECT 
			DATE(created_at) AS created_date,
			WEEKDAY(created_at) AS wkday,
			HOUR(created_at) AS hr,
			COUNT(DISTINCT website_session_id) AS website_sessions
		FROM website_sessions
		WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
		GROUP BY 1,2,3
        ) daily_hourly_sessions
GROUP BY 1
ORDER BY 1

-- (CONCLUSION)
-- GETTING more sessions (traffic coming in)  : weekday from 10-17
-- lighter on weekend