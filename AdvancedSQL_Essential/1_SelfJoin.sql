## Self - Join Practice
-- SelfJoin ::  joins a table to itself using the inner join or left join.
-- When ? 
-- - query hierarchical data 
-- - to compare a row with other rows within the same tables



-- -----------------------------------------------------------------------------------------
# 1) MoM Percent Change 
-- how much a key metric changes between months (Monthly active user :: MAU)
-- Find the month-over-month percentage change for monthly active users
-- Fields : user_id | date 
-- > compare a row with other rows
with a as(
select month(date) month , count(user_id) as visit_month
from logins
group by 1			/** MONTHLY USERS : GROUP BY MONTH **/
order by 1
) 
, b as (
select month, visit_month, lag(visit_month) over (order by month) as previous
from a
) select month, previous, visit_month, concat((visit_month-previous)/previous, "%" ) as MoM 
from b
where next_month is not null 
order by month ;
	# MY SOLUTION 1 : WITH STATEMENT
with a as (
select month(created_at) month , count(user_id) as visit_month
from orders
where year(created_at) ='2014'
group by 1			/** MONTHLY USERS : GROUP BY MONTH **/
order by 1
), b as(
select month, visit_month current , lag(visit_month) over (order by month) as previous 
																/** Partition by 쓰는 경우?? **/
from a
) select month, previous, current, concat(round((current-previous)/previous *100,2), "%" ) as MoM  
																/** Percentage :: * 100 **/
from b
where previous is not null 
order by month ;

	# MY SOLUTION 2 : SELF JOIN
with a as (
select month(created_at) month , count(user_id) as visit_month
from orders
where year(created_at) ='2014'
group by 1		
order by 1
)
select a1.month, 
		a1.visit_month current, a2.visit_month as previous ,
        concat( round((a1.visit_month - a2.visit_month)/a2.visit_month * 100,2) , '%' ) as MoM
from a a1 
join a a2
on a1.month = a2.month +1 
	/** Self Join on 절 조건에 필드 = 필드+1 , 테이블 alias!!!!! **/


-- -----------------------------------------------------------------------------------------
# 2) Tree Structure Labeling
-- table tree with a column of nodes and a column corresponding parent nodes 
-- Write SQL such that we label each node as a “leaf”, “inner” or “Root” node, such that for the nodes above we get

	# MY SOLUTION 1
select node, 
		case when (parent = 2 or parent = 3) then 'Leaf' 
		when (parent = 5 ) then 'Inner'
		else 'Root' END as label
from tree t1
order by 1

	# MY SOLUTION 2 MORE GENERALIZABLE
/** create table `tree`(node integer, parent integer);
insert into tree values(1, 2);
insert into tree values(2, 5);
insert into tree values(3, 5);
insert into tree values(4, 3);
insert into tree values(5, NULL); **/
SELECT 
    a.node a_node,
    a.parent a_parent,
    b.node b_node, 
    b.parent b_parent
 FROM
    tree a 
 LEFT JOIN 
    tree b ON a.parent = b.node ;
SELECT * FROM TREE;
select 
from tree t1 
join tree t2
on t1.parent = t2.node

