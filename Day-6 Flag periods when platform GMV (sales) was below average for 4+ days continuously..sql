"""
  Flag periods when platform GMV (sales) was below average for 4+ days continuously.
"""
CREATE TABLE platform_sales (
    sale_date DATE PRIMARY KEY,
    daily_gmv DECIMAL(10,2)
);

INSERT INTO platform_sales (sale_date, daily_gmv) VALUES
('2025-01-01', 3000), 
('2025-01-02', 3200),
('2025-01-03', 2800),
('2025-01-04', 2900),
('2025-01-05', 3100),
('2025-01-06', 2700),
('2025-01-07', 2600),
('2025-01-08', 3500),
('2025-01-09', 3000),
('2025-01-10', 1200), 
('2025-01-11', 1100), 
('2025-01-12', 1300), 
('2025-01-13', 1000), 
('2025-01-14', 1250), 
('2025-01-15', 2800), 
('2025-01-16', 3000),
('2025-01-17', 3100),
('2025-01-18', 1500),
('2025-01-19', 1400),
('2025-01-20', 3200);

select * from platform_sales ;

with cte1 as (
select 
  * ,
  round(avg(daily_gmv)over(),2) as avg_sales
from platform_sales
)
, cte2 as (
select 
  * ,
  case when daily_gmv < avg_sales then 1 else 0 end as is_drop
from cte1
)

, cte3 as (
select
  *,
  date_sub( sale_date, INTERVAL ROW_NUMBER() OVER(PARTITION BY is_drop ORDER BY sale_date) day) 
  as streak_id 
from cte2
where is_drop = 1
)
, cte4 as (
select 
  min(sale_date) as min_date,
  max(sale_date) as max_date,
  count(*) as cc
from cte3
group by streak_id
)

select * from cte4
where cc >= 4;


"""
  Output => 

+------------+------------+----+
| min_date   | max_date   | cc |
+------------+------------+----+
| 2025-01-10 | 2025-01-14 |  5 |
+------------+------------+----+
  
  """




