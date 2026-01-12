"""
    Q.Find the top 10% of users by total spend.
"""

  
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(50)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    order_amount DECIMAL(10, 2)
);

INSERT INTO users VALUES 
(1, 'Amit'), (2, 'Priya'), (3, 'Rahul'), (4, 'Suman'), (5, 'Vikram'),
(6, 'Neha'), (7, 'Arjun'), (8, 'Sneha'), (9, 'Rohan'), (10, 'Isha');

INSERT INTO orders VALUES 
(101, 1, 5000.00), 
(102, 2, 4500.00), 
(103, 3, 3000.00), (104, 3, 500.00), 
(105, 4, 2500.00), (106, 5, 2000.00),
(107, 6, 1500.00), (108, 7, 1000.00),
(109, 8, 500.00),  (110, 9, 200.00),
(111, 10, 100.00);


SELECT * FROM USERS ;
SELECT * FROM orders ;


WITH CTE1 AS (
  SELECT 
    A.user_id,
    A.user_name,
    SUM(B.order_amount) AS TOTAL_SPEND 
  FROM USERS AS A 
  LEFT JOIN 
    orders AS B 
  ON 
    A.user_id = B.user_id
  GROUP BY 
    A.user_id,
    A.user_name
)

,CTE2 AS (
SELECT 
  user_id,
  user_name,
  NTILE(10)OVER(ORDER BY TOTAL_SPEND DESC) AS SPEND_PERCENT
FROM CTE1
)

SELECT 
  user_id,
  user_name
FROM CTE2 
WHERE SPEND_PERCENT = 1;

"""
  Output =>
    +---------+-----------+
    | user_id | user_name |
    +---------+-----------+
    |       1 | Amit      |
    +---------+-----------+
  """


