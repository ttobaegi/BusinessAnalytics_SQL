USE mavenfuzzyfactory;   /** Name of the schema**/

/** Traffic Analysis **/
select * from website_sessions;
select * from website_sessions where website_session_id=1059

SELECT * 
FROM website_sessions
WHERE website_session_id BETWEEN 1000 AND 2000 -- arbitrary

-- Size various traffic sources
-- ad unit : utm_contenct >> GROUP BY
USE mavenfuzzyfactory;   /** Name of the schema**/

SELECT 
	utm_content,
	COUNT(DISTINCT website_session_id) AS sessions 		-- Distinct : Fail SAVER :)
FROM website_sessions
WHERE website_session_id BETWEEN 1000 AND 2000 -- arbitrary
GROUP BY 1				-- utm_content
ORDER BY 2 DESC; 		-- ORDER BY VOLUME (aggregation OR Alias OR Field Number)

-- CONVERSION RATE
-- Size various traffic source and orders 
SELECT 
	website_sessions.utm_content,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions, 		-- Distinct : Fail SAVER :)
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
        
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000 -- arbitrary
GROUP BY 1				-- utm_content
ORDER BY 2 DESC; 		-- ORDER BY VOLUME (aggregation OR Alias OR Field Number)


/** Assignment1 **/
-- BUSINESS SITUATION
-- Finding Top Traffic Sources 
SELECT 
	utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
		
FROM website_sessions
WHERE created_at < '2012-04-12'  			-- QUOTATION MARK REQUIRED!! DATE AS STRING !
GROUP BY 1,2,3
ORDER BY sessions DESC;

-- !! REPORTING
-- Based on my finding, it seems like we should probably dig into gsearch nonbrand a bit deeper 
-- to see what we can do to optimize there.


/** Assignment2 **/
-- BUSINESS SITUATION
-- Traffic converaion rates of Gsearch 
-- Calcuate the CVR from session to order 
-- MORE THAN 4% INCREASE BIDS TO DRIVE MORE VOLUME AND less than 4 % bid down

SELECT 
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,		-- COUNT GROUP BY 없이 사용 가능
	COUNT(DISTINCT orders.order_id) AS orders,								-- CONTEXT 이해하기 : 세션이 얼마나 주문으로 이어졌는지
	COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt
FROM website_sessions
	LEFT JOIN orders													-- FAIL SAVER : multiple table 다룰 때 구조, PK 체크
       ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.created_at < '2012-04-14'	-- FAIL SAVER : 조건절 먼저 작성하기
	AND utm_source='gsearch' 
    AND utm_campaign = 'nonbrand'
;
-- !! REPORTING
-- looks like we're below the 4% threshold 
-- we need to make the economics work
-- Based on the analysis, we will need to dial down our search bids a bit.
-- Overspending based ont he current CVR
-- >> Impact of bid reductions
-- >> Analyze performance trending by device type in order to refine bidding strategy



/** Assignment3 **/
-- BUSINESS SITUATION

