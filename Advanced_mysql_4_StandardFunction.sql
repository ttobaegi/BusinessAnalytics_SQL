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

# 형변환
-- CAST ( , AS)  
select CAST('2018-12-25 11:22:22.123' AS DATETIME);
-- Signed Integer
select CAST( 1.467 AS Signed Integer ), CAST( 1.513 AS Signed Integer), CONVERT(1.56, Signed Integer) -- 반올림
select CAST('2018-12-25 11:22:22.123' AS DATETIME);
update 

select * from dept;