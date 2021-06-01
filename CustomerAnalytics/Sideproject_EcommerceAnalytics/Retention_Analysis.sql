## Retention Analysis
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

# DAU DAILY ACTIVE USER
CREATE TEMPORARY TABLE dau
SELECT Year(Created_at) AS year ,
	MONTH(Created_at) AS month ,
	DATE(Created_at) AS date ,
  	WEEK(Created_at) AS week ,
	HOUR(Created_at) AS hour,					
	COUNT(DISTINCT user_id)	AS activity_users
FROM website_sessions
GROUP BY 1,2,3,4,5		

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

SELECT * FROM dau

# RETENTION 재방문율 
-- 특정날짜(D+1,..,D+14)에 다시 방문하는 유저의 비율
-- 주로 신규 유저의 RETENTION을 봄

# 테이블 압축 > 용량을 줄이는 것  : 빈 공간을 줄이는 것
## (중요) 클러스터 인덱싱 
-- 클러스터 인덱스 : 테이블 당 한 개만 생성 가능
-- 행 데이터를 인덱스로 지정한 열에 맞춰서 자동 정렬 (중복X)
-- 순서대로 정렬됨
## join 시 사용할 PK, where orderby groupby 등 자주 사용되는 컬럼 사용하면 쿼리 연산 속도가 빨라짐 

# WITH 문 