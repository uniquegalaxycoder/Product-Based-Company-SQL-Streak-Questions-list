"""
  The "Consecutive Active Days" (Classic)
  The Scenario: You have a table of user logins. Find users who logged in for 5 or more consecutive days.
"""
  
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50)
);

CREATE TABLE logins (
    login_id INT PRIMARY KEY,
    user_id INT,
    login_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO users VALUES (1, 'Amit'), (2, 'Priya');

INSERT INTO logins (login_id, user_id, login_date) VALUES 
(1, 1, '2026-01-01'),
(2, 1, '2026-01-02'), (3, 1, '2026-01-02'), 
(4, 1, '2026-01-03'),
(5, 1, '2026-01-04'), (6, 1, '2026-01-04'), (7, 1, '2026-01-04'), 
(8, 1, '2026-01-05'), 
(9, 1, '2026-01-08'),
(10, 1, '2026-01-09'),
(11, 2, '2026-01-01'),
(12, 2, '2026-01-02'),
(13, 2, '2026-01-04'),
(14, 2, '2026-01-05'),
(15, 2, '2026-01-06'),
(16, 2, '2026-01-07'),
(17, 2, '2026-01-10'),
(18, 2, '2026-01-11'),
(19, 2, '2026-01-12'),
(20, 2, '2026-01-13');

select * from users ;
select * from logins ;

with cte1 as (
  select 
    a.user_id,
    a.username,
    b.login_id,
    b.login_date 
  from users as a 
  left join 
    logins as b 
  on 
    a.user_id = b.user_id
)

, cte2 as (
select 
  username,
  login_date,
  count(user_id) as total_login_per_day
from cte1 
group by username, login_date 
)
,cte3 as (
select 
  *,
  lag(login_date)over(partition by username order by login_date) as yesterday_date
from cte2 
),

cte4 as (
select 
  *,
  datediff(login_date, yesterday_date) as day_diff ,
  case when datediff(login_date, yesterday_date) = 1 
        or datediff(login_date, yesterday_date) is null
      then 0 
      else 1 
  end as is_diff_one
from cte3)

, cte5 as (
select 
  *,
  sum(is_diff_one)over(partition by username order by login_date) as streak_id
from cte4
)

select 
  username,
  start_date as "Start Date",
  end_date as "End date",
  total_days as "total days"
from (
select 
  username,
  streak_id,
  min(login_date) as start_date,
  max(login_date) as end_date,
  count(*) as total_days 
from cte5 
group by 
  username,
  streak_id
having count(*) >= 5
) as final_table  ;

"""
  Output =>
    +----------+------------+------------+------------+
    | username | Start Date | End date   | total days |
    +----------+------------+------------+------------+
    | Amit     | 2026-01-01 | 2026-01-05 |          5 |
    +----------+------------+------------+------------+

"""




















