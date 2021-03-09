## Dashboarding with Tableau
SELECT * FROM website_pageviews LIMIT 10


SELECT MAX(created_at)-MIN(created_at) AS Duration
FROM website_pageviews
GROUP BY website_session_id


SELECT * FROM ( SELECT website_session_id,
		COUNT(DISTINCT website_pageview_id)
FROM website_pageviews
GROUP BY website_session_id
) A
LEFT JOIN website_sessions ON A.website_session_id = website_sessions.website_session_id


