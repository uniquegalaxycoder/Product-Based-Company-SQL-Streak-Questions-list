"""
    Q.Calculate time between events (signup → first purchase).
"""

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    signup_time DATETIME
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    order_time DATETIME,
    amount DECIMAL(10, 2)
);

INSERT INTO users VALUES 
(1, '2026-01-01 10:00:00'),
(2, '2026-01-01 12:00:00'),
(3, '2026-01-02 09:00:00'),
(4, '2026-01-03 15:00:00');

INSERT INTO orders VALUES 
(101, 1, '2026-01-01 10:45:00', 50.00), 
(102, 2, '2026-01-02 14:00:00', 30.00), 
(103, 3, '2026-01-02 11:00:00', 20.00), 
(104, 3, '2026-01-02 15:00:00', 60.00); 

SELECT * FROM USERS ;
SELECT * FROM orders ;

WITH CTE1 AS (
  SELECT 
    A.user_id,
    A.signup_time,
    B.order_id,
    B.order_time,
    B.amount
  FROM USERS AS A 
  INNER JOIN 
    orders AS B 
  ON A.user_id = B.user_id
)

, CTE2 AS (
SELECT 
  user_id,
  signup_time,
  MIN(order_time) AS FIRST_ORDER_TIME,
  SUM(amount) AS TOTAL_AMOUNT
FROM CTE1 
GROUP BY user_id, signup_time
)

SELECT 
  user_id,
  signup_time,
  FIRST_ORDER_TIME,
  TIMESTAMPDIFF(MINUTE, signup_time, FIRST_ORDER_TIME) AS MINUTES,
  TIMESTAMPDIFF(HOUR, signup_time, FIRST_ORDER_TIME) AS HOURSE
FROM CTE2
;

"""
    Output =>
    +---------+---------------------+---------------------+---------+--------+
    | user_id | signup_time         | FIRST_ORDER_TIME    | MINUTES | HOURSE |
    +---------+---------------------+---------------------+---------+--------+
    |       1 | 2026-01-01 10:00:00 | 2026-01-01 10:45:00 |      45 |      0 |
    |       2 | 2026-01-01 12:00:00 | 2026-01-02 14:00:00 |    1560 |     26 |
    |       3 | 2026-01-02 09:00:00 | 2026-01-02 11:00:00 |     120 |      2 |
    +---------+---------------------+---------------------+---------+--------+
  
"""




















