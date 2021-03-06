## TACADEMY SQL ANALYSIS COURSE
-- KPI ANALYSIS (PRACTICE)
-- 시계열 데이터의 경우, timstamp 타입에서 연,월,일 등을 따로 컬럼으로 추출하여 활용하는 것이 분석에 도움이 될 수 있다.

-- rowcount 472871 
SELECT count(*) FROM website_sessions;
-- 데이터 기간 확인 
SELECT min(created_at), max(created_at)
FROM website_sessions ;

-- DAU : Daily Active User 일간 방문자 수 
-- 단위 설정 : 로그인 ID 기준
SELECT * FROM website_sessions	LIMIT 1 ;
SELECT COUNT(DISTINCT user_id) 
FROM website_sessions ;

-- WITH 구문으로 임시테이블 생성
-- define what an active user is 
WITH dau_table AS (
			SELECT Year(Created_at) AS year ,
					MONTH(Created_at) AS month ,
					DATE(Created_at) AS date ,
					HOUR(Created_at) AS hour,					
					COUNT(DISTINCT user_id)	AS activity_users
			FROM website_sessions
            WHERE website_sessions.created_at BETWEEN '2013-01-01' AND '2013-12-31'
			GROUP BY 1,2,3,4					
) 
SELECT * FROM dau_table

-- Daily
WITH dau_table AS (
			SELECT Year(Created_at) AS year ,
					MONTH(Created_at) AS month ,
					DATE(Created_at) AS date ,
					WEEK(Created_at) AS week ,
					HOUR(Created_at) AS hour,					
					COUNT(DISTINCT user_id)	AS activity_users
			FROM website_sessions
			WHERE website_sessions.created_at BETWEEN '2013-01-01' AND '2013-12-31'
			GROUP BY 1,2,3,4,5				
) 
SELECT date, SUM(activity_users)
FROM dau_table
GROUP BY date
ORDER BY date;

-- MONTHLY
WITH dau_table AS (
			SELECT Year(Created_at) AS year ,
					MONTH(Created_at) AS month ,
					DATE(Created_at) AS date ,
					WEEK(Created_at) AS week ,
					HOUR(Created_at) AS hour,					
					COUNT(DISTINCT user_id)	AS activity_users
			FROM website_sessions
			WHERE website_sessions.created_at BETWEEN '2013-01-01' AND '2013-12-31'
			GROUP BY 1,2,3,4,5						
) 
SELECT month, SUM(activity_users)
FROM dau_table
GROUP BY month
ORDER BY month;




WITH dau_table AS (
			SELECT Year(Created_at) AS year ,
					MONTH(Created_at) AS month ,
					DATE(Created_at) AS date ,
					HOUR(Created_at) AS hour,					
					WEEK(Created_at) AS week ,
					COUNT(DISTINCT user_id)	AS activity_users
			FROM website_sessions
			WHERE website_sessions.created_at BETWEEN '2013-01-01' AND '2013-12-31'
			GROUP BY 1,2,3,4,5						
) 

-- user activity table
DROP TABLE IF EXISTS dau
CREATE TEMPORARY TABLE dau
SELECT Year(Created_at) AS year ,
	MONTH(Created_at) AS month ,
	DATE(Created_at) AS date ,
  	WEEK(Created_at) AS week ,
	HOUR(Created_at) AS hour,					
	COUNT(DISTINCT user_id)	AS activity_users
FROM website_sessions
WHERE website_sessions.created_at BETWEEN '2013-01-01' AND '2013-12-31'
GROUP BY 1,2,3,4,5		

SELECT MIN(date), MAX(date) FROM dau;		

-- DAU Analysis by Segment		
-- 신규, 복귀, 이탈
-- lag, dateiff
-- CASE WHEN 

select year, count(*)
from users 
group by year

DROP TABLE IF EXISTS users
CREATE TEMPORARY TABLE users
SELECT 
	Year(Created_at) AS year ,
	MONTH(Created_at) AS month ,
	DATE(Created_at) AS date ,
  	WEEK(Created_at) AS week ,
	HOUR(Created_at) AS hour,
	website_session_id,
    user_id,
    is_repeat_session
FROM website_sessions
WHERE year(created_at) = '2014'
SELECT * FROM users LIMIT 1

-- new user
SELECT 
	if(new_user='1','new_user','existing_user') as Segment,
    COUNT(user_id)
FROM
(
SELECT date
	, user_id
	, CASE WHEN lag(date) over ( partition by user_id order by date ) is null THEN 1 ELSE 0 END AS new_user 
		-- Lag 함수 이전의 행을 돌아 봄 
        -- user_id 파티션 내 현재 행 앞의 date 반환
        -- 현재 행 앞의 date가 null이면 신규 유입 유저
FROM users
) AS NEW
GROUP BY NEW.new_user

-- existing user & Churn user 추가
select
		date
		, user_id
       	, CASE WHEN lag(date) over ( partition by user_id order by date ) is null THEN 1 ELSE 0 END AS new_YN 
        , CASE WHEN lag(date) over (partition by user_id order by date) IS NULL THEN null
			WHEN datediff(date,lag(date) over (partition by user_id order by date)) > 14 THEN 0 ELSE 1 END AS existing_YN
		, datediff(date,lag(date) over (partition by user_id order by date)) AS comback_day
        , ABS(datediff('2014-12-31',lag(date) over (partition by user_id order by date))) AS blank_day
        , CASE WHEN ABS(datediff('2014-12-31',lag(date) over (partition by user_id order by date))) > 14 THEN 1 ELSE 0 END AS churn_YN
FROM users
ORDER BY user_id


## Segment 테이블 만들기
SHOW DATABASES; 			-- DB리스트 조회
CREATE DATABASE JL2021;
USE JL2021;
SHOW TABLES;				-- TABLE 리스트 조회

CREATE TABLE segment (
			date date
            , user_id char
            , new_YN binary
            , existing_YN binary
            , comeback_day numeric
            , blank_day numeric
            , churn_YN binary
)
-- my sql에서 csv 파일 테이블로 bulk insert 하는 방법 알아보기


## 태블로 CUSTOM SQL 쿼리로 데이터 연결
WITH users AS
			(
				SELECT 
					Year(Created_at) AS year ,
					MONTH(Created_at) AS month ,
					DATE(Created_at) AS date ,
					WEEK(Created_at) AS week ,
					HOUR(Created_at) AS hour,
					website_session_id,
					cast(user_id as char) AS user_id, 			-- 숫자로 된 필드 별도 문자형식 설정 CAST
					is_repeat_session
				FROM website_sessions
                WHERE year(created_at)='2014'
			) 
select
		date
		, user_id
       	, CASE WHEN lag(date) over ( partition by user_id order by date ) is null THEN 1 ELSE 0 END AS new_YN 
        , CASE WHEN lag(date) over (partition by user_id order by date) IS NULL THEN null
			WHEN datediff(date,lag(date) over (partition by user_id order by date)) > 14 THEN 0 ELSE 1 END AS existing_YN
		, datediff(date,lag(date) over (partition by user_id order by date)) AS comback_day
        , ABS(datediff('2014-12-31',lag(date) over (partition by user_id order by date))) AS blank_day
        , CASE WHEN ABS(datediff('2014-12-31',lag(date) over (partition by user_id order by date))) > 14 THEN 1 ELSE 0 END AS churn_YN
FROM users
ORDER BY user_id