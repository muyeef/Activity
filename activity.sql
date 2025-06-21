--Data cleaning 

--Remove Duplicate Rows:
--Identifing and removing  duplicate rows where the combination of user_id and activity_time are the same.
WITH cte AS (
SELECT *,ROW_NUMBER() OVER (PARTITION BY user_id, activity_time ORDER BY USER_id) AS rn
 FROM activity_log)
DELETE FROM cte
WHERE RN >1

--Handle Missing Data:
--There are missing values in the activity_type column. So i replaced  missing values with "Unknown".
	UPDATE activity_log
SET activity_type = COALESCE(activity_type, 'Unknown')
WHERE activity_type IS NULL

/*Standardize Date Formats:
The activity_time column contains dates in different formats. 
Convert the activity_time column to a consistent YYYY-MM-DD HH:MM:SS datetime format*/
UPDATE activity_log
SET activity_time = FORMAT(activity_time, 'yyyy-MM-dd HH:mm:ss')

--Filter Out Data Outside of Valid Date Range:
--Remove any rows where the activity_time is earlier than January 1, 2025.
SELECT activity_time 
FROM activity_log 
WHERE CAST(activity_time AS DATETIME) < '2025-01-01';

--Ensuring Correct Data Types:
--Verify that the user_id and session_id columns are stored as integers. If not, convert them to the appropriate data type
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'activity_log' 
  AND COLUMN_NAME IN ('user_id', 'session_id')


---Key Insights

/* 1. Finding users with the longest session duration for each day.  
output includings the user ID, session duration, and the date of the session.*/

  WITH session_durations AS (
SELECT  user_id,CAST(login_time AS DATE) AS date,DATEDIFF(MINUTE, login_time, logout_time) AS duration_time
FROM sessions
),
ranked_time AS (
SELECT *,ROW_NUMBER() OVER (PARTITION BY date ORDER BY duration_time DESC) AS rn
    FROM session_durations
)
SELECT user_id,duration_time,date
FROM ranked_time
WHERE rn = 1

/*2.query to identify the user with the highest average session duration, 
but only include users who have used more than 3 features in the last 30 days.*/


select top 1 s.user_id,avg(datediff(MINUTE,login_time,logout_time))as avg from [sessions ] s
join feature_usage f on s.user_id=f.user_id
where login_time >=dateadd(day,-30,(select max(login_time)as max from [sessions ]))
group by s.user_id
having COUNT(feature_name) >3
order by avg desc




---3.Which day had the highest number of activities across all users?
SELECT TOP 1 CAST(activity_time AS DATE) AS activity_date,
 COUNT(*) AS activity_count
FROM activity_log
GROUP BY CAST(activity_time AS DATE)
ORDER BY activity_count DESC



---4.What is the overall trend of user activity (activities per day) in the past two months?
SELECT CAST(activity_time AS DATE) AS activity_date,
COUNT(*) AS activity_count
FROM activity_log
WHERE activity_time >= DATEADD(DAY, -60, GETDATE())  -- Last 60 days
GROUP BY CAST(activity_time AS DATE)
ORDER BY activity_count desc

---5. Find users who are active but have never submitted a support ticket
SELECT u.id
FROM users u
LEFT JOIN sessions s ON u.id = s.user_id
LEFT JOIN support_tickets st ON u.id = st.user_id
WHERE s.user_id IS NOT NULL  -- The user has session logs
  AND st.ticket_id IS NULL   -- The user has never submitted a support ticket


--6. Write a query to find users whose support tickets were resolved in under 2 days on average
--method 1
with cte as (
SELECT  user_id,created_at,status, CASE WHEN resolved_at IS NULL THEN NULL
WHEN ISDATE(resolved_at) = 1 THEN CAST(resolved_at AS DATE)
END AS converted_date
FROM support_tickets)

select distinct user_id,avg(datediff(day,created_at,converted_date)) as days_resolved from cte 
where status='resolved' and datediff(day,created_at,converted_date)<='2'
group by user_id


--Method 2
select user_id,avg(datediff(day,created_at,resolved_at))as datediff from [support_tickets ]
where status ='resolved' and isdate(resolved_at) =1
group by user_id
having avg(datediff(day,created_at,resolved_at)) <=2


---7. How many users have used more than 3 or more features in the past 30 days?
select count(user_id) as cnt from

(select user_id,count(feature_name)as cnt_features from feature_usage
where last_used >=dateadd(day,-30,(select max(last_used)as max from feature_usage ))
group by user_id
having count(feature_name)>=3) as features


--8. Find the average time between session login and logout for each user in the last 30 days
select user_id,avg(datediff(minute,login_time,logout_time)) as date_diff from sessions
where login_time >=dateadd(day,-30,(select max(login_time)as max from sessions))
group by user_id
order by date_diff desc

--9. Which day had the highest number of activities across all users?
select  cast(activity_time as date) as date,count(activity_time) as cnt from activity_log
group by cast(activity_time as date)
order by cnt desc


--10. Which users have the highest number of session logs but the least feature usage?
select  s.user_id,count(distinct s.session_id)as cnt,
count(distinct feature_name)as feature_cnt from sessions s
join feature_usage f on s.user_id= f.user_id
group by s.user_id
order by cnt desc,feature_cnt asc 


--11. Which user have had the longest session duration on average?
select top 1  user_id,avg(datediff(MINUTE,login_time,logout_time)) as session_duration from sessions
group by user_id
order by session_duration desc


--12. Your task is to identify the top 3 most used features in the past 30 days
select top 3 feature_name,sum(usage_count)as total from  feature_usage
where last_used >= dateadd(day,-30,(select max(last_used) as max from feature_usage))
group by feature_name
order by total desc

--13. Which day had the highest user activity based on sessions and activities
select top 1  cast(a.activity_time as date)as main_date,
 count(distinct a.activity_id) as total_activity ,count(distinct s.session_id) as total_session 
from activity_log a
 join sessions s on a.user_id = s.user_id
group by cast(a.activity_time as date)
order by total_activity desc, total_session desc  


--14. What is the average time taken to resolve support tickets?
select avg(datediff(day,created_at,resolved_at))as days from support_tickets 
where status='resolved'

alter table support_tickets
alter column resolved_at datetime
select * from [support_tickets ]

select resolved_at from [support_tickets ]
where isdate(resolved_at)=1

select cast(resolved_at as datetime)  from [support_tickets ]
update support_tickets 
set resolved_at = '2030-01-01 '
where resolved_at = 'null'

 

--15. What is the overall trend of user activity (activities per day) in the past two months?
select d.date ,count(a.activity_time )as trend from date_table d
 left join [activity_log ] a on cast(a.activity_time as date) =d.date
and activity_time >= dateadd(DAY,-60,(select max(activity_time)as max from activity_log))
group by d.date

DECLARE @start_date DATE = '2025-03-03';
DECLARE @end_date DATE = '2025-04-29';

WITH DateSeries AS (
    SELECT @start_date AS date_val
    UNION ALL
    SELECT DATEADD(DAY, 1, date_val)
    FROM DateSeries
    WHERE date_val < @end_date
)



select date_val as date into date_table
from dateseries


--16. Find users who have logged in but have never submitted a support ticket
select distinct user_id from [activity_log ]
where user_id not in (select user_id from [support_tickets ])



--17. Write a query to find the users who have not logged into the system in the past 2 months
select u.id from [sessions ] s
 right join users u on s.user_id = u.id
 where created_at >= dateadd(day,-60,created_at) and login_time is null


--18. Write a query to return the first and last login time for each user, along with the total number of sessions
select user_id,min(login_time) as first_login,max(login_time)as last_login_time,
count(*) as total_session
from [sessions ]
group by user_id



