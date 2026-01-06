"""
    Q.Identify the longest subscription renewal streak for each customer.
"""
  
create table subscriptions (
  user_id bigint,
  user_signup_date date,
  subscription_start date,
  subscription_end date,
  payment decimal(10,2)
);

INSERT INTO subscriptions (user_id, user_signup_date, subscription_start, subscription_end, payment)
VALUES 
(101, '2025-01-01', '2025-01-01', '2025-01-31', 99.00),
(101, '2025-01-01', '2025-02-01', '2025-02-28', 99.00),
(101, '2025-01-01', '2025-03-01', '2025-03-31', 99.00),
(101, '2025-01-01', '2025-04-01', '2025-04-30', 99.00),
(102, '2025-01-05', '2025-01-05', '2025-02-04', 99.00),
(102, '2025-01-05', '2025-02-05', '2025-03-04', 99.00),
(102, '2025-01-05', '2025-05-01', '2025-05-31', 99.00),
(102, '2025-01-05', '2025-06-01', '2025-06-30', 99.00),
(103, '2025-02-10', '2025-02-10', '2025-03-09', 150.00),
(103, '2025-02-10', '2025-03-10', '2025-04-09', 150.00),
(103, '2025-02-10', '2025-04-10', '2025-05-09', 150.00),
(103, '2025-02-10', '2025-07-01', '2025-07-31', 150.00);

select * from subscriptions ;

with cte1 as (
select 
  user_id,
  user_signup_date,
  subscription_start,
  subscription_end
from subscriptions
)
, cte2 as (
select 
  user_id,
  subscription_start,
  subscription_end,
  lag(subscription_end)over(partition by user_id order by subscription_start ) as last_end_date,
  case 
      when (datediff(subscription_start, lag(subscription_end)over(partition by user_id order by subscription_start ))) <= 1
        then 0 
        else 1 
      end as day_diff
from cte1 
)
, cte3 as (
select 
  *,
  sum(day_diff)over(partition by user_id order by subscription_start) as total_length
from cte2
)

-- select * from cte3

select 
  user_id,
  max(streak) as "Longest Sub. Streak"
from (
select 
  user_id,
  total_length,
  count(*) as streak
from cte3 
group by user_id, total_length 
) as b 
group by user_id ;


"""
  Output =>
    +---------+---------------------+
    | user_id | Longest Sub. Streak |
    +---------+---------------------+
    |     101 |                   4 |
    |     102 |                   2 |
    |     103 |                   3 |
    +---------+---------------------+
  
  """









