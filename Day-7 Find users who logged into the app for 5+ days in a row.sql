"""
      Q.Find users who logged into the app for 5+ days in a row.
"""

create table users (
  user_id bigint primary key,
  user_signup_date date,
  user_device varchar(50)
);

create table user_activity (
  login_date date,
  user_id bigint,
  foreign key (user_id) references users(user_id)
);

INSERT INTO users VALUES 
(1, '2026-01-01', 'Android'),
(2, '2026-01-01', 'iOS'),
(3, '2026-01-01', 'Web'),
(4, '2026-01-02', 'Android'),
(5, '2026-01-05', 'iOS');


INSERT INTO user_activity (user_id, login_date) VALUES 
(1, '2026-01-01'), (1, '2026-01-02'), (1, '2026-01-03'), (1, '2026-01-04'), 
(1, '2026-01-05'), (1, '2026-01-06'), (1, '2026-01-07'),
(2, '2026-01-01'), (2, '2026-01-02'), 
(2, '2026-01-05'), (2, '2026-01-06'), (2, '2026-01-07'),
(3, '2026-01-01'), (3, '2026-01-02'), (3, '2026-01-04'), 
(3, '2026-01-10'), (3, '2026-01-05'), (2, '2026-01-04'), 
(4, '2026-01-02'), (4, '2026-01-03'), (4, '2026-01-15'),
(5, '2026-01-18'), (5, '2026-01-19'), (5, '2026-01-20');

select * from users ;
select * from user_activity ;

with cte1 as (
  select 
    a.user_id,
    a.user_signup_date,
    a.user_device,
    b.login_date
  from users as a 
  left join 
    user_activity as b 
  on 
    a.user_id = b.user_id
)
, cte2 as (
select 
  * ,
  lag(login_date)over(partition by user_id order by login_date) as last_login_date
from cte1 
)
, cte3 as (
select 
  * ,
  datediff(login_date, last_login_date) as day_diff
from cte2
)
, cte4 as (
select 
  *,
  case when day_diff = 1 or day_diff is null then 1 else 0 end as is_one
from cte3
)
, cte5 as (
select
  *,
  sum(is_one)over(partition by user_id order by login_date rows unbounded PRECEDING ) as length_streak
from cte4
)

select 
  user_id,
  max(length_streak) as length_id
from cte5 
where is_one = 1 
group by user_id
having max(length_streak) >= 5
  ;

"""
  output => 
    +---------+-----------+
    | user_id | length_id |
    +---------+-----------+
    |       1 |         7 |
    |       2 |         5 |
    +---------+-----------+
  
  """



















