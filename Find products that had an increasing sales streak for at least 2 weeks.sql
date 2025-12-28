-- Find products that had an increasing sales streak for at least 2 weeks.


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
(9004512301, '2025-08-01', 501, 1200.50, 'Bangalore', 'Biryani'),
(9004513302, '2025-08-02', 502, 1100.00, 'Bangalore', 'Dosa'),
(9004514303, '2025-08-03', 503, 1300.75, 'Bangalore', 'Pizza'),
(9004515304, '2025-08-08', 504, 1500.00, 'Bangalore', 'Rolls'),
(9004516305, '2025-08-09', 505, 1400.25, 'Bangalore', 'Idli'),
(9004517306, '2025-08-10', 506, 1600.40, 'Bangalore', 'Burger'),
(9004518307, '2025-08-15', 507, 1800.90, 'Bangalore', 'Shawarma'),

(8003511101, '2025-08-01', 508, 900.00, 'Chennai', 'Dosa'),
(8003512102, '2025-08-05', 509, 800.50, 'Chennai', 'Idli'),
(8003513103, '2025-08-10', 510, 750.75, 'Chennai', 'Pongal'),
(8003514104, '2025-08-17', 511, 700.00, 'Chennai', 'Vada'),
(8003515105, '2025-08-24', 512, 650.25, 'Chennai', 'Upma'),
(8003516106, '2025-08-31', 513, 600.00, 'Chennai', 'Meals'),

(7002612201, '2025-08-02', 514, 500.99, 'Pune', 'Misal'),
(7002613202, '2025-08-09', 515, 450.00, 'Pune', 'Pav Bhaji'),
(7002614203, '2025-08-16', 516, 400.25, 'Pune', 'Upma'),
(7002615204, '2025-08-23', 517, 350.75, 'Pune', 'Poha'),
(7002616205, '2025-08-30', 518, 300.00, 'Pune', 'Vada Pav'),
(7002617206, '2025-09-29', 519, 2250.00, 'Pune', 'Idli'),
(7002618207, '2025-09-13', 520, 8200.00, 'Pune', 'Dosa'),
(7002617206, '2025-09-01', 519, 250.00, 'Pune', 'Biryani'),
(7002618207, '2025-09-11', 520, 9200.00, 'Pune', 'Sandwich'),

(6001412308, '2025-08-01', 521, 2500.00, 'Mumbai', 'Vada Pav'),
(6001413309, '2025-08-07', 522, 2400.50, 'Mumbai', 'Biryani'),
(6001414310, '2025-08-14', 523, 2300.00, 'Mumbai', 'Pizza'),
(6001415311, '2025-08-21', 524, 2200.25, 'Mumbai', 'Rolls'),
(6001416312, '2025-08-28', 525, 2100.75, 'Mumbai', 'Thali'),
(6001417313, '2025-09-04', 526, 2000.00, 'Mumbai', 'Burger'),
(6001418314, '2025-09-11', 527, 7900.00, 'Mumbai', 'Sandwich'),

(5007812315, '2025-08-03', 528, 1800.00, 'Hyderabad', 'Haleem'),
(5007813316, '2025-08-10', 529, 1750.25, 'Hyderabad', 'Biryani'),
(5007814317, '2025-08-17', 530, 1700.50, 'Hyderabad', 'Shawarma'),
(5007815318, '2025-08-24', 531, 1650.00, 'Hyderabad', 'Pizza'),
(5007816319, '2025-08-31', 532, 1600.75, 'Hyderabad', 'Kebab'),
(5007817320, '2025-09-07', 533, 1550.00, 'Hyderabad', 'Dosa'),
(5007818321, '2025-09-14', 534, 5000.00, 'Hyderabad', 'Burger');


with cte1 as 
(
select 
  product_name,
  Week_num,
  sum(total_sale)as week_sales,
  min(order_date) as week_start_date,
  max(order_date) as week_end_date
from(
      select
        * ,
        -- week(order_date) as Week_num
        case 
          when day(order_date) >= 1 and day(order_date) <=7 then 'week1'
          when day(order_date) >= 8 and day(order_date) <= 14 then 'week2'
          when day(order_date) >= 15 and day(order_date) <= 21 then 'week3'
          else 'week4'
        end as week_num
      from 
        (select 
            product_name,
            order_date,
            sum(invoice_amount) as total_sale
          from sales
          group by product_name, order_date
        ) as x
    ) as y 
group by  y.product_name, y.week_num
)

, cte2 as (
select 
  *,
  lag(week_sales)over(partition by product_name order by week_start_date  ) as prev_week_sales
from cte1
)

, cte3 as (
select
  * ,
  case when week_sales > prev_week_sales or prev_week_sales is null then 1 else 0 end as is_increse
from cte2
)

, cte4 as (
select 
  *,
  sum(case when is_increse = 0 then 1 else 0 end )
  over(partition by product_name order by week_start_date rows unbounded preceding) as streak_id
from cte3
)


select 
  product_name,
  count(streak_id) as total_streak_length,
  min(week_start_date) as first_order_date,
  max(week_end_date) as last_order_date 
from cte4 
where is_increse = 1
group by product_name
having count(streak_id) >= 2
















