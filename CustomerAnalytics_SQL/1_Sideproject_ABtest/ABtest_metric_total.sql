/** 
- SIDE PROJECT : [ABTEST]
- connection : [aws] 
- create table & data insert : [ python to_sql &  sqlalchemy.create_engine ]
**/


-- 데이터베이스 생성 지정
-- create database abtest;
use abtest;

# python to mysql : to_sql 메소드 이용 
# 데이터프레임 insert 내역 확인하기
select * from experiments limit 10;
select * from events limit 5;
select * from users limit 5;
-- drop table users;

select count(*) from experiments;  	-- 실험결과 
select count(*) from events;  		-- 유저의 모든 행동로그
select count(*) from users;  		-- 가입된 유저 가입정보/상태(active& pending)
select distinct(state) from users;
SELECT distinct event_name FROM events ;	-- event type


/** Business Situation
-- This case focuses on an improvement to Yammer’s core “publisher”—the module at the top of a Yammer feed where users type their messages. 
-- To test this feature, the product team ran an A/B test from June 1 through June 30. 
-- During this period, some users who logged into Yammer were shown the old version of the publisher (the “control group”), 
-- while other other users were shown the new version (the “treatment group”).
-- On July 1, you check the results of the A/B test. 
-- You notice that message posting is 50% higher in the treatment group—a huge increase in posting.
**/

# NULL Hypothesis : there is no difference between two groups
# ALTERNATIVE Hypothesis : test group(treatment group) show higher engagement behavior than control group
# A/B tests with t-test vs z-test reference : https://bytepawn.com/ab-testing-and-the-ttest.html
# test statistics measurement : https://conductrics.com/pvalues
# Validating Test Results : https://mode.com/sql-tutorial/validating-ab-test-results

-- -------------------------------------------------------------------------------------------------------------------------
## Query 1: A/B Test Results - Messages Sent

WITH a AS (
SELECT  experiment,
        experiment_group,
        ex.occurred_at treatment_start,
        u.user_id,
        u.activated_at,
        -- event name : send_message :: dependent variable 
        SUM(CASE WHEN e.event_name = 'send_message' THEN 1 ELSE 0 END)	as metric			
FROM experiments ex
-- inner join 
JOIN users u 
	ON ex.user_id = u.user_id
JOIN events e 
	ON ex.user_id = e.user_id 
	AND e.event_type= 'engagement' 
	AND e.occurred_at < '2014-07-01'		-- testing period : June
    AND e.occurred_at >= ex.occurred_at  	-- test 시작 이후에 발생한 event
GROUP BY 1,2,3,4,5
)
, b AS(
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
, c AS (
	SELECT * ,
		-- 비교 기준이 될 control_group(old version)의 metric 결과 변수 생성
		MAX(CASE WHEN experiment_group = 'control_group' THEN users ELSE NULL END) OVER () AS control_users,			-- n
		MAX(CASE WHEN experiment_group = 'control_group' THEN average ELSE NULL END) OVER () AS control_average,		-- 표본평균
		MAX(CASE WHEN experiment_group = 'control_group' THEN total ELSE NULL END) OVER () AS control_total,			-- N
		MAX(CASE WHEN experiment_group = 'control_group' THEN variance ELSE NULL END) OVER () AS control_variance,  	-- 분산
		MAX(CASE WHEN experiment_group = 'control_group' THEN stdev ELSE NULL END) OVER () AS control_stdev,   			-- 편차
        SUM(users) OVER () total_treated_users
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
    -- COALESCE() : null이 아닌 인자 추출 
	(1 - COALESCE(norm.value,1))*2 AS p_value
FROM d
LEFT JOIN normal_distribution norm
	ON norm.score = ABS(ROUND(t_stat,3)) ;



-------------------------------------------------------------------------------------------------------------------------
## Query 2: Control Group Users and Messages Sent
-- user_id | metric

SELECT DISTINCT experiment FROM experiments;
SELECT ex.user_id,
	SUM(CASE WHEN e.event_name = 'send_message' THEN 1 ELSE 0 END) AS metric
FROM experiments ex
JOIN events e 
	ON ex.user_id = e.user_id
    AND e.occurred_at >= ex.occurred_at
    AND e.occurred_at < '2014-07-01'
    AND e.event_type = 'engagement' 
WHERE experiment_group = 'control_group' AND experiment ='publisher_update'
GROUP BY 1
ORDER BY 2 ;



-------------------------------------------------------------------------------------------------------------------------
## Query 3: Test Group Users and Messages Sent
-- user_id | metric

SELECT DISTINCT experiment FROM experiments;
SELECT ex.user_id,
	SUM(CASE WHEN e.event_name = 'send_message' THEN 1 ELSE 0 END) AS metric
FROM experiments ex
JOIN events e 
	ON ex.user_id = e.user_id
    AND e.occurred_at >= ex.occurred_at
    AND e.occurred_at < '2014-07-01'
    AND e.event_type = 'engagement' 
WHERE experiment_group = 'test_group' AND experiment ='publisher_update'
GROUP BY 1
ORDER BY 2 ;



-------------------------------------------------------------------------------------------------------------------------
## Query 4: Experiment Group by Month Activated
-- month_activated | control_users | test_users

# 1) EXTRACT( FROM )
SELECT EXTRACT(YEAR_MONTH FROM activated_at) AS month_activated,
	SUM(CASE WHEN experiment_group = 'control_group' THEN 1 ELSE 0 END) AS control_users,
	SUM(CASE WHEN experiment_group = 'test_group' THEN 1 ELSE 0 END) AS test_users
FROM users  u 
JOIN experiments ex 
	ON u.user_id = ex.user_id 
GROUP BY 1;

# 2) DATE_FORMAT(  , '%Y-%m')
SELECT DATE_FORMAT( activated_at, '%Y-%m-01 00:00:00') AS month_activated,
	SUM(CASE WHEN experiment_group = 'control_group' THEN 1 ELSE 0 END) AS control_users,
	SUM(CASE WHEN experiment_group = 'test_group' THEN 1 ELSE 0 END) AS test_users
FROM users  u 
JOIN experiments ex 
	ON u.user_id = ex.user_id 
GROUP BY 1;



-------------------------------------------------------------------------------------------------------------------------
## Query 5: Experiment Group by Device Type
-- device_type | control_users | test_users

SELECT * FROM experiments LIMIT 5;
SELECT DISTINCT device FROM experiments; -- DEVICE TYPE

WITH a AS (
	SELECT experiment_group,
		CASE 
			WHEN (device like '%notebook%' OR device like '%desktop%' OR device like '%mac%' OR device like '%asus%' OR device like '%lenovo%') THEN 'computer' 
			WHEN (device like '%phone%' OR device like '%nokia%' OR device like '%htc%' OR device like '%note%' OR device like '%nexus%' OR device like '%s4%') THEN 'mobile' 
			ELSE 'tablet' END AS device_type
	FROM experiments
    WHERE experiment = 'publisher_update'
)
SELECT DISTINCT device_type,
	SUM(CASE WHEN experiment_group = 'control_group' THEN 1 ELSE 0 END) AS control_group,
	SUM(CASE WHEN experiment_group = 'test_group' THEN 1 ELSE 0 END) AS test_group
FROM a
GROUP BY 1
ORDER BY 2;


-------------------------------------------------------------------------------------------------------------------------
## Query 6: Experiment Group by Lanugage
-- language | control_users | test_users
SELECT DISTINCT language FROM users;
SELECT language,
		SUM(CASE WHEN experiment_group = 'control_group' THEN 1 ELSE 0 END) AS control_users,
        SUM(CASE WHEN experiment_group = 'test_group' THEN 1 ELSE 0 END) AS test_users
FROM users u
	JOIN experiments ex 
		ON u.user_id = ex.user_id 
        AND experiment = 'publisher_update'
GROUP BY 1
ORDER BY 1;


