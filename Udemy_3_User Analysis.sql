## User Analysis 
-- 1. how many of our website visitors come back for another session?
/** 
1) Identify the relevant new sessions
2) User_id values form step 1 > find repeat sessions those users had
3) Analyze the data at the user level 
4) 
**/
with a as (SELECT sum(is_repeat_session) repeat_sessions, user_id users
FROM website_sessions
WHERE created_at < '2014-11-01' and created_at >= '2014-01-01'
GROUP BY user_id
)
select repeat_sessions , count(users) users from a group by repeat_sessions 
order by 1,2;