"""
    Q.Find the first and last transaction for every user.
"""

CREATE TABLE user_transactions (
    transaction_id INT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(10, 2),
    transaction_time DATETIME
);

INSERT INTO user_transactions VALUES 
(1, 101, 50.00,  '2026-01-01 10:00:00'),
(2, 101, 25.00,  '2026-01-05 14:30:00'),
(3, 101, 100.00, '2026-01-10 09:15:00'), 
(4, 102, 150.00, '2026-01-02 11:00:00'), 
(5, 102, 200.00, '2026-01-12 16:45:00'), 
(6, 103, 30.00,  '2026-01-08 12:00:00');

SELECT * FROM user_transactions ;

WITH CTE1 AS (
  SELECT 
    user_id,
    MIN(CAST(transaction_time AS DATE)) AS FIRST_TRANSAC_DATE,
    MIN(date_format(transaction_time,'%H:%i:%s')) AS FIRST_TRANSACTION_TIME,
    SUM(AMOUNT) AS TOTAL_AMOUNT
  FROM 
    user_transactions
  GROUP BY 
    user_id
)

, CTE2 AS (
  SELECT 
    user_id,
    MAX(CAST(transaction_time AS DATE)) AS LAST_TRANSAC_DATE,
    MAX(date_format(transaction_time, '%H:%s:%I')) AS LAST_TRANSACTION_TIME,
    SUM(AMOUNT) AS TOTAL_AMOUNT
  FROM user_transactions
  GROUP BY 
    user_id
)

SELECT 
  A.user_id,
  A.FIRST_TRANSAC_DATE,
  A.FIRST_TRANSACTION_TIME,
  A.TOTAL_AMOUNT,
  B.LAST_TRANSAC_DATE,
  B.LAST_TRANSACTION_TIME,
  B.TOTAL_AMOUNT
FROM CTE1 AS A 
LEFT JOIN 
  CTE2 AS B 
ON 
  A.user_id = B.user_id ;
  
"""
  Output =>
  +---------+--------------------+------------------------+--------------+-------------------+-----------------------+--------------+
  | user_id | FIRST_TRANSAC_DATE | FIRST_TRANSACTION_TIME | TOTAL_AMOUNT | LAST_TRANSAC_DATE | LAST_TRANSACTION_TIME | TOTAL_AMOUNT |
  +---------+--------------------+------------------------+--------------+-------------------+-----------------------+--------------+
  |     101 | 2026-01-01         | 09:15:00               |       175.00 | 2026-01-10        | 14:00:02              |       175.00 |
  |     102 | 2026-01-02         | 11:00:00               |       350.00 | 2026-01-12        | 16:00:04              |       350.00 |
  |     103 | 2026-01-08         | 12:00:00               |        30.00 | 2026-01-08        | 12:00:12              |        30.00 |
  +---------+--------------------+------------------------+--------------+-------------------+-----------------------+--------------+
"""
