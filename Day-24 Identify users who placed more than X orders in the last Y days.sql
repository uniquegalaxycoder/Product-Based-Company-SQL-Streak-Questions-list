"""
   Q.Identify users who placed more than X orders in the last Y days.

  CASE :
      To make this interesting, let's assume our business goal is to find 
      users who placed more than 2 orders (X=2) in the last 30 days (Y=30).

"""


CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    order_date DATE,
    order_amount DECIMAL(10, 2)
);

INSERT INTO orders VALUES 
(1, 101, '2026-01-10', 50.00), 
(2, 101, '2026-01-05', 30.00), 
(3, 101, '2025-12-25', 40.00), 
(4, 102, '2026-01-11', 100.00),
(5, 102, '2025-11-01', 150.00),
(6, 103, '2026-01-01', 20.00), 
(7, 103, '2026-01-02', 25.00), 
(8, 104, '2026-01-12', 300.00);

SELECT * FROM orders ;

WITH CTE1 AS (
  SELECT 
    user_id,
    COUNT(DISTINCT order_id) AS TOTAL_ORDERS,
    SUM(order_amount) AS TOTAL_AMOUNT
  FROM ORDERS 
  WHERE 
    order_date >= date_sub( '2026-01-12', interval 30 day) 
  GROUP BY user_id
  HAVING COUNT(DISTINCT order_id) > 2 
)

SELECT * FROM CTE1;

"""
  Output =>
  +---------+--------------+--------------+
  | user_id | TOTAL_ORDERS | TOTAL_AMOUNT |
  +---------+--------------+--------------+
  |     101 |            3 |       120.00 |
  +---------+--------------+--------------+
  
  """
