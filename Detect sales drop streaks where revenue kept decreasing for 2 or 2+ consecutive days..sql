-- Detect sales drop streaks where revenue kept decreasing for 2 or 2+ consecutive days.

create table sales(
  sales_id bigint,
  order_date date,
  invoice_id bigint,
  invoice_amount FLOAT(10,2),
  city varchar(20),
  product_name varchar(20)
);

INSERT INTO sales (sales_id, order_date, invoice_id, invoice_amount, city, product_name) 
VALUES
(845732111, '2025-08-01', 90001, 420.50, 'Bangalore', 'Biryani'),
(845732112, '2025-08-02', 90002, 220.00, 'Bangalore', 'Pizza'),
(845732113, '2025-08-03', 90003, 280.75, 'Bangalore', 'Burgers'),
(845732114, '2025-08-04', 90004, 210.40, 'Bangalore', 'Kebabs'),
(845732115, '2025-08-05', 90005, 85.00, 'Bangalore', 'Rolls'),
(845732116, '2025-08-06', 90006, 199.99, 'Bangalore', 'Biryani'),

(845732221, '2025-08-01', 90007, 15.00, 'Mumbai', 'Vada Pav'),
(845732222, '2025-08-02', 90008, 20.40, 'Mumbai', 'Poha'),
(845732223, '2025-08-03', 90009, 80.25, 'Mumbai', 'Frankie'),
(845732224, '2025-08-04', 90010, 150.00, 'Mumbai', 'Thali'),
(845732225, '2025-08-05', 90011, 15.60, 'Mumbai', 'Vada Pav'),
(845732226, '2025-08-06', 90012, 199.50, 'Mumbai', 'Biryani'),

(845732331, '2025-08-01', 90013, 60.99, 'Pune', 'Misal Pav'),
(845732332, '2025-08-02', 90014, 30.50, 'Pune', 'Upma'),
(845732333, '2025-08-03', 90015, 25.00, 'Pune', 'Idli'),
(845732334, '2025-08-04', 90016, 120.80, 'Pune', 'Pav Bhaji'),
(845732335, '2025-08-05', 90017, 90.25, 'Pune', 'Misal Pav'),
(845732336, '2025-08-06', 90018, 140.00, 'Pune', 'Thali'),

(845732441, '2025-08-01', 90019, 280.00, 'Hyderabad', 'Haleem'),
(845732442, '2025-08-02', 90020, 210.50, 'Hyderabad', 'Chicken 65'),
(845732443, '2025-08-03', 90021, 190.75, 'Hyderabad', 'Shawarma'),
(845732444, '2025-08-04', 90022, 20.00, 'Hyderabad', 'Maggie'),
(845732445, '2025-08-05', 90023, 275.30, 'Hyderabad', 'Biryani'),
(845732446, '2025-08-06', 90024, 320.00, 'Hyderabad', 'Chicken 65'),

(845732551, '2025-08-01', 90025, 30.00, 'Chennai', 'Dosa'),
(845732552, '2025-08-02', 90026, 55.25, 'Chennai', 'Idli'),
(845732553, '2025-08-03', 90027, 30.80, 'Chennai', 'Dosa'),
(845732554, '2025-08-04', 90028, 25.00, 'Chennai', 'Filter Coffee'),
(845732555, '2025-08-05', 90029, 99.99, 'Chennai', 'Pongal'),
(845732556, '2025-08-06', 90030, 120.00, 'Chennai', 'Medu Vada'),

(845732661, '2025-08-01', 90031, 30.00, 'Noida', 'Momos'),
(845732662, '2025-08-02', 90032, 25.50, 'Noida', 'Samosa'),
(845732663, '2025-08-03', 90033, 20.75, 'Noida', 'Chole Bhature'),
(845732664, '2025-08-04', 90034, 15.00, 'Noida', 'Maggie'),
(845732665, '2025-08-05', 90035, 60.25, 'Noida', 'Paneer Tikka'),
(845732666, '2025-08-06', 90036, 80.00, 'Noida', 'Biryani');



with cte1 as (
select 
  city,
  order_date,
  sum(invoice_amount) as total_sales
from sales 
group by city, order_date
)

, cte2 as (
select 
  city,
  order_date,
  total_sales,
  lag(total_sales)over(partition by city order by order_date) as yesterday_sales
from cte1
)

,cte3 as (
select 
  *,
  case when total_sales < yesterday_sales then 1 else 0 end  as is_drop 
from cte2
) 

, cte4 as (
select 
  *,
  sum( case when is_drop = 0 then 1 else 0 end )
  over(partition by city order by order_date asc rows unbounded preceding) as streak_group_id
from cte3
) 

, cte5 as (
select
  city,
  count(streak_group_id) as streak,
  min(order_date) as start_date,
  max(order_date) as end_date
from cte4 
where is_drop = 1
group by city
having count(*) >= 2
) 
select 
  city,
  strak,
  start_date,
  end_date
from cte5 ;


"""
Insights :

Sales tend to drop from the 2nd to 4th of every month across cities. 
Identifying any common trigger during these dates can help optimize future business 
strategies.

"""


