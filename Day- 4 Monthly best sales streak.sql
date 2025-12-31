"""
Compute a monthly best sales streak (days of continuous growth inside a month).
"""

CREATE TABLE daily_sales (
    sale_date DATE PRIMARY KEY,
    total_revenue DECIMAL(10,2)
);

INSERT INTO daily_sales (sale_date, total_revenue) VALUES

('2025-01-01', 1000.00),
('2025-01-02', 1200.00), 
('2025-01-03', 1500.00), 
('2025-01-04', 1800.00),
('2025-01-05', 2000.00), 
('2025-01-06', 1100.00), 
('2025-01-07', 1300.00), 
('2025-01-08', 1200.00), 


('2025-02-01', 500.00),
('2025-02-02', 700.00),  
('2025-02-03', 400.00), 
('2025-02-10', 2000.00), 
('2025-02-11', 2500.00),
('2025-02-12', 3000.00), 
('2025-02-13', 2800.00); 

with cte1 as (
select 
  *,
  lag(total_revenue)over(order by sale_date) as last_day_sales 
from daily_sales 
),
cte2 as (
select 
  *,
  case when (total_revenue > last_day_sales ) then 0 else 1 end as is_increase
from cte1
),

cte3 as (
select 
  sale_date,
  date_format(sale_date, '%M') as months,
  sum( is_increase )
  over( partition BY date_format(sale_date, '%M')  order by sale_date asc rows unbounded preceding) as streak_id
from cte2  
)

select 
  months,
  max(streak_length) as max_streak
from (
select 
  months,
  streak_id,
  count(*) as streak_length
from cte3
group by months,streak_id
) as x 
group by months;

"""
  Output =>
+----------+------------+
| months   | max_streak |
+----------+------------+
| February |          4 |
| January  |          5 |
+----------+------------+
"""
