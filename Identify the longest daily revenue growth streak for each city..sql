-- Identify the longest daily revenue growth streak for each city.

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
(845732101, '2025-08-03', 90001, 349.50, 'Bangalore', 'Biryani'),
(845732205, '2025-08-04', 90002, 400.00, 'Mumbai', 'Vada Pav'),
(845732309, '2025-08-10', 90003, 700.99, 'Pune', 'Misal Pav'),
(845732410, '2025-08-15', 90004, 678.00, 'Hyderabad', 'Haleem'),
(845732511, '2025-08-01 12:30:00', 90005, 850.00, 'Chennai', 'Dosa'),
(845732622, '2025-08-02 18:45:00', 90006, 299.00, 'Bangalore', 'Rolls'),
(845732733, '2025-08-03 14:20:00', 90007, 620.50, 'Noida', 'Chole Bhature'),
(845732844, '2025-08-04 20:15:00', 90008, 580.00, 'Gurgaon', 'Momos'),
(845732955, '2025-08-05 09:10:00', 90009, 999.00, 'Mumbai', 'Poha'),
(845733066, '2025-08-06 11:05:00', 90010, 799.75, 'Bangalore', 'Burgers'),
(845733177, '2025-08-07 19:50:00', 90011, 249.25, 'Pune', 'Idli'),
(845733288, '2025-08-08 13:30:00', 90012, 520.00, 'Chennai', 'Pongal'),
(845733399, '2025-08-09 22:10:00', 90013, 910.40, 'Hyderabad', 'Shawarma'),
(845733455, '2025-08-11 17:35:00', 90014, 975.60, 'Noida', 'Paneer Tikka'),
(845733567, '2025-08-12 21:25:00', 90015, 830.00, 'Mumbai', 'Thali'),
(845733678, '2025-08-13 12:00:00', 90016, 429.99, 'Pune', 'Upma'),
(845733789, '2025-08-14 16:40:00', 90017, 850.90, 'Bangalore', 'Pizza'),
(845733890, '2025-08-15 08:15:00', 90018, 975.00, 'Chennai', 'Medu Vada'),
(845734012, '2025-08-16 19:00:00', 90019, 399.00, 'Hyderabad', 'Chicken 65'),
(845734123, '2025-08-20 14:55:00', 90020, 880.80, 'Gurgaon', 'Maggie'),
(845734234, '2025-08-17 10:10:00', 90021, 890.00, 'Noida', 'Samosa'),
(845734345, '2025-08-18 18:05:00', 90022, 910.00, 'Pune', 'Pav Bhaji'),
(845734456, '2025-08-19 20:45:00', 90023, 960.00, 'Mumbai', 'Frankie'),
(845734567, '2025-08-21 07:30:00', 90024, 1120.00, 'Chennai', 'Filter Coffee'),
(845734678, '2025-08-22 22:55:00', 90025, 950.00, 'Bangalore', 'Kebabs');

with 
cte1 as (
select 
  city,
  order_date,
  product_name,
  sum(invoice_amount) as total_sale
from sales
group by city, order_date, product_name
),
cte2 as (
select 
  *,
  lag(total_sale)over(partition by city order by order_date) as yesterday_sales
from cte1
),

cte3 as (
select 
  *,
  (case 
       when total_sale >= yesterday_sales then "sales Growth" 
      when total_sale < yesterday_sales then "sales Drop"
    end ) as growth_bucket
from cte2
),

cte4 as (
select
  *,
  sum( case when growth_bucket = 'sales Growth' or growth_bucket is null then 0 else 1 end)
  over(partition by order_date, city) as streak_bucket
from cte3
)

select 
  city,
  max(streak_lenght) as long_growth_streak
from (
select 
  *,
  row_number()over(partition by city, streak_bucket order by order_date) as streak_lenght
from cte4
) as d
where growth_bucket = 'sales Growth'
group by city




