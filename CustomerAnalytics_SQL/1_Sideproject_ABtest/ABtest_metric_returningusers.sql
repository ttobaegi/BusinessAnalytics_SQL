/** 
- SIDE PROJECT : [ABTEST]
- connection : [aws] 
- create table & data insert : [ python to_sql &  sqlalchemy.create_engine ]
**/


-- 데이터베이스 생성 지정
-- create database abtest;
use abtest;


# Testing for returned users : Removed new accounts
-------------------------------------------------------------------------------------------------------------------------
## Query 7: A/B Test Results - Messages Sent (Removed New Accounts)
-- experiment | experiment_group | users | total_treated_users | treatment_percent | total | average | rate_difference | rate_lift | stdev | t_stat | p_value
WITH a AS (
SELECT 
	experiment,
	experiment_group,
    ex.occurred_at AS treatment_start, 
    ex.user_id,
    u.activated_at,
    SUM(CASE WHEN event_name='send_message' THEN 1 ELSE 0 END) AS metric
FROM experiments ex
JOIN users u 
	ON ex.user_id = u.user_id 
    -- test 이전 기간 가입 user 대상 
    AND u.activated_at < '2014-06-01'
JOIN events e
	ON ex.user_id = e.user_id
    AND e.event_type = 'engagement'
    AND e.occurred_at >= ex.occurred_at
    AND e.occurred_at < '2014-07-01'
WHERE experiment = 'publisher_update' 
GROUP BY 1,2,3,4,5
)
, b AS (
SELECT experiment,
	experiment_group,
    COUNT(user_id) AS users,
    AVG(metric) AS average,
    SUM(metric) AS total,
    STDDEV(metric) AS stdev,
    VARIANCE(metric) AS variance
FROM a
GROUP BY 1,2
)
,c AS (
SELECT *,
	MAX(CASE WHEN experiment_group='control_group' THEN users ELSE NULL END) OVER () AS control_users,
	MAX(CASE WHEN experiment_group='control_group' THEN average ELSE NULL END) OVER () AS control_average,
	MAX(CASE WHEN experiment_group='control_group' THEN total ELSE NULL END) OVER () AS control_total,
	MAX(CASE WHEN experiment_group='control_group' THEN variance ELSE NULL END) OVER () AS control_variance,
	MAX(CASE WHEN experiment_group='control_group' THEN stdev ELSE NULL END) OVER () AS control_stdev,
    SUM(users) OVER() AS total_treated_users
FROM b
)
, d AS (
	SELECT experiment,
		experiment_group,
        users,
        total_treated_users,
        CAST(ROUND(average,4) AS FLOAT) AS average,
        CONCAT(ROUND(users/total_treated_users,4)*100,'%') AS treatment_percent,
        total,
        ROUND(average - control_average, 4) AS rate_difference,
        ROUND((average - control_average)/control_average) AS rate_lift,
        ROUND(stdev,4) AS stdev,
        -- t_stat test statistic for calculating if average of the treatment group is statistically different from the average of the control group
        ROUND( (average-control_average) / SQRT((variance/users) + (control_variance/control_users)) , 4) AS t_stat
FROM c 
) SELECT d.* ,
	-- p-value to determine the test's statistical significance
    -- COALESCE() : null이 아닌 첫 인자 추출 
	(1 - COALESCE(norm.value, 1))*2 AS p_value
FROM d
LEFT JOIN normal_distribution norm
	ON norm.score = ABS(ROUND(t_stat,3)) ;



-------------------------------------------------------------------------------------------------------------------------
## Query 8: A/B Test Results - Days Logged In (Removed New Accounts)
-- experiment | experiment_group | users | total_treated_users | treatment_percent | total | average | rate_difference | rate_lift | stdev | t_stat | p_value
WITH a AS (
SELECT 
	experiment,
	experiment_group,
    ex.occurred_at AS treatment_start, 
    ex.user_id,
    u.activated_at,
    -- Days logged in per user.
    COUNT(DISTINCT DATE(e.occurred_at)) AS metric
FROM experiments ex
JOIN users u 
	ON ex.user_id = u.user_id 
    -- test 이전 기간 가입 user 대상 
    AND u.activated_at < '2014-06-01'
JOIN events e
	ON ex.user_id = e.user_id
    AND e.event_type = 'engagement'
	-- event_name ='login'
    AND event_name='login' 
    AND e.occurred_at >= ex.occurred_at
    AND e.occurred_at < '2014-07-01'
WHERE experiment = 'publisher_update' 
GROUP BY 1,2,3,4,5
)
, b AS (
SELECT experiment,
	experiment_group,
    COUNT(user_id) AS users,
    AVG(metric) AS average,
    SUM(metric) AS total,
    STDDEV(metric) AS stdev,
    VARIANCE(metric) AS variance
FROM a
GROUP BY 1,2
)
,c AS (
SELECT *,
	MAX(CASE WHEN experiment_group='control_group' THEN users ELSE NULL END) OVER () AS control_users,
	MAX(CASE WHEN experiment_group='control_group' THEN average ELSE NULL END) OVER () AS control_average,
	MAX(CASE WHEN experiment_group='control_group' THEN total ELSE NULL END) OVER () AS control_total,
	MAX(CASE WHEN experiment_group='control_group' THEN variance ELSE NULL END) OVER () AS control_variance,
	MAX(CASE WHEN experiment_group='control_group' THEN stdev ELSE NULL END) OVER () AS control_stdev,
    SUM(users) OVER() AS total_treated_users
FROM b
)
, d AS (
	SELECT experiment,
		experiment_group,
        users,
        total_treated_users,
        CAST(ROUND(average,4) AS FLOAT) AS average,
        CONCAT(ROUND(users/total_treated_users,4)*100,'%') AS treatment_percent,
        total,
        ROUND(average - control_average, 4) AS rate_difference,
        ROUND((average - control_average)/control_average) AS rate_lift,
        ROUND(stdev,4) AS stdev,
        -- t_stat test statistic for calculating if average of the treatment group is statistically different from the average of the control group
        ROUND( (average-control_average) / SQRT((variance/users) + (control_variance/control_users)) , 4) AS t_stat
FROM c 
) SELECT d.* ,
	-- p-value to determine the test's statistical significance
    -- COALESCE() : null이 아닌 첫 인자 추출 
	(1 - COALESCE(norm.value, 1))*2 AS p_value
FROM d
LEFT JOIN normal_distribution norm
	ON norm.score = ABS(ROUND(t_stat,3)) ;



-------------------------------------------------------------------------------------------------------------------------
## Query 9: A/B Test Results - Engagement Events (Removed New Accounts)
-- experiment | experiment_group | users | total_treated_users | treatment_percent | total | average | rate_difference | rate_lift | stdev | t_stat | p_value
WITH a AS (
SELECT 
	experiment,
	experiment_group,
    ex.occurred_at AS treatment_start, 
    ex.user_id,
    u.activated_at,
    -- Number of engagement events per user
    COUNT(e.occurred_at) AS metric
FROM experiments ex
JOIN users u 
	ON ex.user_id = u.user_id 
    -- test 이전 기간 가입 user 대상 
    AND u.activated_at < '2014-06-01'
JOIN events e
	ON ex.user_id = e.user_id
    AND e.event_type = 'engagement'
    AND e.occurred_at >= ex.occurred_at
    AND e.occurred_at < '2014-07-01'
WHERE experiment = 'publisher_update' 
GROUP BY 1,2,3,4,5
)
, b AS (
SELECT experiment,
	experiment_group,
    COUNT(user_id) AS users,
    AVG(metric) AS average,
    SUM(metric) AS total,
    STDDEV(metric) AS stdev,
    VARIANCE(metric) AS variance
FROM a
GROUP BY 1,2
)
,c AS (
SELECT *,
	MAX(CASE WHEN experiment_group='control_group' THEN users ELSE NULL END) OVER () AS control_users,
	MAX(CASE WHEN experiment_group='control_group' THEN average ELSE NULL END) OVER () AS control_average,
	MAX(CASE WHEN experiment_group='control_group' THEN total ELSE NULL END) OVER () AS control_total,
	MAX(CASE WHEN experiment_group='control_group' THEN variance ELSE NULL END) OVER () AS control_variance,
	MAX(CASE WHEN experiment_group='control_group' THEN stdev ELSE NULL END) OVER () AS control_stdev,
    SUM(users) OVER() AS total_treated_users
FROM b
)
, d AS (
	SELECT experiment,
		experiment_group,
        users,
        total_treated_users,
        CAST(ROUND(average,4) AS FLOAT) AS average,
        CONCAT(ROUND(users/total_treated_users,4)*100,'%') AS treatment_percent,
        total,
        ROUND(average - control_average, 4) AS rate_difference,
        ROUND((average - control_average)/control_average) AS rate_lift,
        ROUND(stdev,4) AS stdev,
        -- t_stat test statistic for calculating if average of the treatment group is statistically different from the average of the control group
        ROUND( (average-control_average) / SQRT((variance/users) + (control_variance/control_users)) , 4) AS t_stat
FROM c 
) SELECT d.* ,
	-- p-value to determine the test's statistical significance
    -- COALESCE() : null이 아닌 첫 인자 추출 
	(1 - COALESCE(norm.value, 1))*2 AS p_value
FROM d
LEFT JOIN normal_distribution norm
	ON norm.score = ABS(ROUND(t_stat,3)) ;



-------------------------------------------------------------------------------------------------------------------------
## Query 10: Control Group Users and Engagement Events (Removed New Accounts)
-- user_id | metric
SELECT ex.user_id,
	-- Number of engagement events per user
    COUNT(e.occurred_at) AS metric
FROM experiments ex 
	JOIN users u 
		ON ex.user_id = u.user_id
		-- test 이전 기간 가입 user 대상 
		AND u.activated_at < '2014-06-01'
	JOIN events e
        ON ex.user_id = e.user_id 
        AND e.occurred_at >= ex.occurred_at
        AND e.occurred_at < '2014-07-01'
		AND e.event_type = 'engagement'
	-- control group 
WHERE experiment_group ='test_group' 
    AND experiment = 'publisher_update'	
GROUP BY 1
ORDER BY 2
;


-------------------------------------------------------------------------------------------------------------------------
## Query 11: Test Group Users and Engagement Events (Removed New Accounts)
-- user_id | metric
SELECT ex.user_id,
	-- Number of engagement events per user
    COUNT(e.occurred_at) AS metric
FROM experiments ex 
	JOIN users u 
		ON ex.user_id = u.user_id
		-- test 이전 기간 가입 user 대상 
		AND u.activated_at < '2014-06-01'
	JOIN events e
        ON ex.user_id = e.user_id 
        AND e.occurred_at >= ex.occurred_at
        AND e.occurred_at < '2014-07-01'
		AND e.event_type = 'engagement'
	-- test group 
WHERE experiment_group ='test_group' 
    AND experiment = 'publisher_update'	
GROUP BY 1
ORDER BY 2
;


