"""
    Q.find the date range consicutive 3+ days empty warehouse stock
"""
create table warehouse (
  recorde_date date,
  yesterday_stock_avilable int,
  outward_today_stock int,
  invert_stock_today int
);

INSERT INTO warehouse (recorde_date, yesterday_stock_avilable, outward_today_stock, invert_stock_today) VALUES 
('2026-01-01', 100, 20, 10), 
('2026-01-02', 90, 50, 0),   
('2026-01-03', 40, 40, 0),   
('2026-01-04', 0, 0, 0),    
('2026-01-05', 0, 0, 0),    
('2026-01-06', 0, 0, 20),   
('2026-01-07', 20, 5, 5),    
('2026-01-08', 20, 20, 0),   
('2026-01-09', 0, 0, 0),  
('2026-01-10', 0, 10, 50); 

select * from warehouse ;  

with cte1 as (
  select 
    recorde_date,
    yesterday_stock_avilable,
    outward_today_stock,
    invert_stock_today,
    ( yesterday_stock_avilable - outward_today_stock + invert_stock_today) as total_stock
  from warehouse
)

, cte2 as (
select 
  *,
  case when total_stock < 1 then 0 else 1 end as is_stock_empty
from cte1
)

, cte3 as (
select 
  * ,
  sum(is_stock_empty)over(order by recorde_date) as streak_id
from cte2
)

, cte4 as (
select 
  streak_id,
  min(recorde_date) as min_date,
  max(recorde_date) as max_date,
  sum(total) as total_days
from (
select 
  recorde_date,
  streak_id,
  count(*) as total
from cte3 
where total_stock = 0
group by recorde_date, streak_id
) as d 
group by streak_id )


select 
  min_date as "start date",
  max_date as "end date",
  total_days as "Total Days"
from cte4 
where total_days >= 3 ;


"""
  Output =>

    +------------+------------+------------+
    | start date | end date   | Total Days |
    +------------+------------+------------+
    | 2026-01-03 | 2026-01-05 |          3 |
    +------------+------------+------------+
  """

