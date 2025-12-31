"""
    Q. Identify the longest purchase streak per product category
"""

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE sales_data (
    sale_id INT PRIMARY KEY,
    sale_date DATE,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

INSERT INTO categories VALUES (1, 'Electronics'), (2, 'Fashion');

INSERT INTO sales_data (sale_id, sale_date, category_id) VALUES

(1, '2025-01-01', 1),
(2, '2025-01-02', 1),
(3, '2025-01-03', 1),
(4, '2025-01-05', 1),
(5, '2025-01-06', 1),
(6, '2025-01-01', 2),
(7, '2025-01-02', 2),
(8, '2025-01-05', 2), 
(9, '2025-01-06', 2),
(10, '2025-01-07', 2),
(11, '2025-01-08', 2),
(12, '2025-01-10', 2);

select * from categories;
select * from sales_data;

with cte1 as (
  select 
    b.category_id,
    b.category_name,
    a.sale_id,
    a.sale_date
  from sales_data as a 
  left join categories as b 
  on a.category_id = b.category_id
),

cte2 as (
select 
  *,
  lag(sale_date)over(partition by category_name order by sale_date) as prev_date
from cte1
),

cte3 as (
select 
  * ,
  coalesce(datediff(sale_date, prev_date),0) as days_diff,
  case when datediff(sale_date, prev_date) = 1 or prev_date is null then 1 else 0 end as is_one
from cte2
),

cte4 as (
select 
  *,
  sum(is_one)over(partition by category_name order by prev_date rows unbounded preceding) as length
from cte3
)

select
  category_name as "Category",
  long_product_streak as "Long Product Streak"
from (
      select 
        category_name,
        count(*) as long_product_streak
      from cte4
      where days_diff = 1
      group by category_name
) as y 
;

"""
Output => 
+-------------+---------------------+
| Category    | Long Product Streak |
+-------------+---------------------+
| Electronics |                   3 |
| Fashion     |                   4 |
+-------------+---------------------+

"""

