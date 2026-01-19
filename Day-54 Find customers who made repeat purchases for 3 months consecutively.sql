"""
    Q.Find customers who made repeat purchases for 3 months consecutively.
"""

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE
);

INSERT INTO orders (order_id, customer_id, order_date) VALUES 
(1, 1, '2026-01-15'),
(2, 1, '2026-02-10'),
(3, 1, '2026-03-05'),
(4, 2, '2026-01-20'),
(5, 2, '2026-03-12'),
(6, 3, '2026-02-28'),
(7, 3, '2026-03-15');

SELECT * FROM orders ;

WITH CTE1 AS (
  SELECT 
    customer_id,
    order_id,
    order_date,
    LAG(order_date)OVER(PARTITION BY customer_id ORDER BY order_date) AS PREVIOUS_ORDER_DATE 
  FROM ORDERS 
)

, CTE2 AS (
SELECT 
  * ,
  CASE 
    WHEN  TIMESTAMPDIFF(MONTH, PREVIOUS_ORDER_DATE, order_date) = 1 OR  
          TIMESTAMPDIFF(MONTH, PREVIOUS_ORDER_DATE, order_date ) IS null OR
          TIMESTAMPDIFF(MONTH, PREVIOUS_ORDER_DATE, order_date) = 0 
          THEN 0 
    ELSE 1 
  END AS LENGTH
FROM CTE1
)

select 
  customer_id AS "CUSTOMER",
  min(order_date) as "STREAK START",
  max(order_date) as "STREAK END",
  COUNT(order_date) AS "TOTAL ORDERED MONTH",
  count(order_id) as "TOTAL ORDERS" 
from (
SELECT 
  *,
  sum(LENGTH)over(PARTITION by customer_id order by order_date) as streak_id  
FROM CTE2
) as t 
group by customer_id
having COUNT(order_date) >= 3 ;

"""
  Output =>
    +----------+--------------+------------+-------------+--------------+
    | CUSTOMER | STREAK START | STREAK END | TOTAL MONTH | TOTAL ORDERS |
    +----------+--------------+------------+-------------+--------------+
    |        1 | 2026-01-15   | 2026-03-05 |           3 |            3 |
    +----------+--------------+------------+-------------+--------------+
"""
