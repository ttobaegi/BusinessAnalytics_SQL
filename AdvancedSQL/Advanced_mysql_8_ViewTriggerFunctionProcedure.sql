/** VIEW TRIGGER FUNCTION PROCEDURE **/

/** VIEW 
1. 보안 - 모든 테이블/DB에 직접적 접근권한이 없는 사용자들에게 뷰 생성하여 전달 가능 
2. 쿼리 단순
3. 성능 향상 : Compiled Query  
**/
# CREATE VIEW
select e.*, d.dname from EMP E INNER JOIN Dept d on e.dept = d.id;
-- dname 조회를 위해 매번 join 작업
-- 자주 조회되는 내역 뷰 생성하기
create view v_EMP AS
select e.*, d.dname from EMP E INNER JOIN Dept d on e.dept = d.id;

-- view 조회 (Schema navigator 내 Views - 도구버튼)
SHOW TABLES ; 
SHOW CREATE VIEW v_EMP;
select * from information_schema.views where table_schema='testdb';
select * from v_EMP;

## CURSOR
-- 결과값 하나씩 처리하고싶으면 사용
DECLARE  CURSOR FOR
select;


## @rownum
select e.*, (@rownum := @rownum + 1)
 from emp e, (select @rownum := 0) rn;  -- 행번호 



