"""
      Q.The Price Change History (SCD Type 2)
"""

CREATE TABLE price_history (
    product_id INT,
    price_date DATE,
    price DECIMAL(10, 2)
);

INSERT INTO price_history (product_id, price_date, price) VALUES 
(1, '2026-01-01', 1000.00),
(1, '2026-01-02', 1000.00),
(1, '2026-01-03', 1000.00), 
(1, '2026-01-04', 1200.00), 
(1, '2026-01-05', 1200.00),
(1, '2026-01-06', 1000.00), 
(1, '2026-01-07', 1000.00),
(2, '2026-01-01', 500.00),  
(2, '2026-01-02', 500.00),
(2, '2026-01-03', 550.00);

select * from price_history ;

with cte1 as (
  select 
    product_id,
    price_date,
    price,
    lag(price_date)over(partition by product_id order by price_date) as last_date,
    lag(price)over(partition by product_id order by price_date) as last_price
  from price_history
)

, cte2 as (
select 
  * ,
  case when (price - last_price ) = 0 then 0 else 1 end as price_diff
from cte1
)
, cte3 as (
select 
  *,
  sum(price_diff)over(partition by product_id order by price_date) as streak_id
from cte2)

, cte4 as (
select 
  product_id,
  streak_id,
  max(price) as price,
  min(price_date) as 1st_date,
  max(price_date) as last_date,
  count(*) as total_streak
from cte3
group by product_id, streak_id
)

select 
  product_id,
  price,
  1st_date as "Start date",
  last_date as "End date",
  total_streak as "Total Day"
from cte4 ;

"""
  Output =>
    +------------+---------+------------+------------+-----------+
    | product_id | price   | Start date | End date   | Total Day |
    +------------+---------+------------+------------+-----------+
    |          1 | 1000.00 | 2026-01-01 | 2026-01-03 |         3 |
    |          1 | 1200.00 | 2026-01-04 | 2026-01-05 |         2 |
    |          1 | 1000.00 | 2026-01-06 | 2026-01-07 |         2 |
    |          2 |  500.00 | 2026-01-01 | 2026-01-02 |         2 |
    |          2 |  550.00 | 2026-01-03 | 2026-01-03 |         1 |
    +------------+---------+------------+------------+-----------+
  
  """
