/** Standard Function 
SUM AVG MIN MAX 
MOD COUNT STDDEV VAR_SAMP
SIN COS TAN ACOS ASIN ATAN ATAN2 
EXP LN LOG LOG2 LOG10

CEIL FLOOR ROUND ABS 
올림 내림 반올림 절댓값
POWER SQRT MOD %
RAND()  0-1 난수 생성
BIN HEX OCT CONV('EF',16,10)

CAST
CONVERT
STR_TODATE DATE_FORMAT

CONCAT CONCAT_WS GROUP_CONCAT

IF IFNULL NULLIF
**/

-- sqrt 루트
select sqrt(4);
-- mod % 나누기
SELECT MOD(5,2), 5%2;
-- bin 이진수
select bin(5);  
-- conv - rgb ????
CONV('FF',16,10)

## 형변환
-- CAST ( a AS b)  
	-- String to Datetime	
	select CAST('2018-12-25 11:22:22.123' AS DATETIME);
	select CAST('45' AS DATETIME); 
	-- 날짜가 아닌게 들어오면 NULL 출력
-- CONVERT ( a , b )
	select CAST( 1.467 AS Signed Integer), CAST( 1.513 AS Signed Integer), CONVERT(1.56, Signed Integer); 
    -- INTEGER로 변환 시 반올림

-- STR_TO_DATE( a , b )
select str_to_date('2018-12-25 11:22:22.123' , '%Y-%m-%d');
	-- date 날짜만 출력
    -- **데이터 입력형식이 다를 때 전처리 작업시 많이 사용
select str_to_date('12/03/2018', '%d/%m/%Y'); 
select now();
	-- 현재 날짜 시간 분 초 출력
    
# CONCAT
-- CONCAT CONCAT_WS GROUP_CONCAT 자주 사용
SELECT concat('aaa','bb');
SELECT concat_ws('-','aaa','bb'); 
	-- separator 사용 가능
SELECT dept, ename, count(id) from emp group by dept; 
	-- dept 만 group by 해줬기 때문에 ename에도 MIN MAX (AGG함수) 써야함
SELECT dept, min(ename), count(id) from emp group by dept; 
	-- 불특정 한명 / order by 기준
SELECT dept, group_concat(ename) as employees, count(id) from emp group by dept; 
SELECT dept, replace(group_concat(ename),',','&') as employees, count(id) from emp group by dept; 

# IF
-- IF
select dept, if(dept=3,'*',''), group_concat(ename) as employees, count(id) from emp group by dept; 
-- IFNULL
SELECT name, ifnull(leader,'부재중');
