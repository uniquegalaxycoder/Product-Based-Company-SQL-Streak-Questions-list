"""
    Q.Write a query to find the first purchase date and last purchase date for each customer, including customers
      who never purchased anything.
"""

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10, 2)
);

INSERT INTO customers VALUES 
(1, 'Alice'), 
(2, 'Bob'), 
(3, 'Charlie'),
(4, 'REXA');

INSERT INTO orders (order_id, customer_id, order_date, amount) VALUES 
(101, 1, '2026-01-01', 150.50), 
(102, 2, '2026-01-02', 45.00),  
(103, 1, '2026-01-05', 300.00), 
(104, 3, '2026-01-10', 89.99),  
(105, 1, '2026-01-12', 12.50),  
(106, 1, '2026-01-15', 55.00),  
(107, 5, '2026-01-15', 210.00), 
(108, 3, '2026-01-18', 120.00), 
(109, 6, '2026-01-20', 999.99), 
(110, 2, '2026-01-25', 60.00);  

SELECT * FROM customers ;
SELECT * FROM orders ;


WITH CTE1 AS (
    SELECT
      A.customer_id,
      A.customer_name,
      B.order_id,
      B.order_date,
      B.amount
    FROM
      customers AS A 
    LEFT JOIN orders AS B 
    ON 
      A.customer_id = B.customer_id
)

SELECT 
  customer_name,
  MIN(order_date) AS FIRST_PURCHASE_DATE,
  MAX(order_date) AS LAST_PURCHASE_DATE
FROM CTE1 
GROUP BY customer_name

"""
    Output =>
    +---------------+---------------------+--------------------+
    | customer_name | FIRST_PURCHASE_DATE | LAST_PURCHASE_DATE |
    +---------------+---------------------+--------------------+
    | Alice         | 2026-01-01          | 2026-01-15         |
    | Bob           | 2026-01-02          | 2026-01-25         |
    | Charlie       | 2026-01-10          | 2026-01-18         |
    | REXA          | NULL                | NULL               |
    +---------------+---------------------+--------------------+
"""
