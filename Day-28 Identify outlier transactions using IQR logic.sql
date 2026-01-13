"""
  Q.Identify outlier transactions using IQR logic.
"""

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    amount DECIMAL(10, 2)
);

INSERT INTO transactions (transaction_id, amount) VALUES 
(1, 50.00), (2, 60.00), (3, 70.00), (4, 80.00), 
(5, 90.00), (6, 100.00), (7, 110.00), (8, 120.00), 
(9, 130.00), (10, 140.00), (11, 150.00),
(12, 10.00),    
(13, 2000.00);  

SELECT * FROM transactions ;

WITH CTE1 AS (
  SELECT 
    transaction_id,
    amount,
    NTILE(3)OVER(ORDER BY AMOUNT) AS STAKE
  FROM transactions
  ORDER BY amount
)

, CTE2 AS (
SELECT 
  transaction_id,
  (SELECT AVG(AMOUNT) FROM CTE1 WHERE STAKE = 1) AS Q1,
  (SELECT AVG(AMOUNT) FROM CTE1 WHERE STAKE = 3) AS Q3
FROM CTE1
)

, CTE3 AS (
SELECT 
  DISTINCT transaction_id,
  Q1,
  Q3,
  (Q3 - Q1) AS IQR
FROM CTE2
)

, CTE4 AS (
SELECT 
  transaction_id,
  (Q1 - 1.5 * IQR ) AS LOWER_BOUND,
  (Q3 + 1.5 * IQR) AS UPPER_BOUND
FROM CTE3 
)

SELECT 
  transaction_id,
  AMOUNT ,
  OUTLIER_STATUS
FROM (
SELECT 
  A.transaction_id,
  A.AMOUNT,
  B.LOWER_BOUND,
  B.UPPER_BOUND,
  CASE WHEN A.AMOUNT < LOWER_BOUND OR A.AMOUNT > UPPER_BOUND THEN "OUTLIER"
        ELSE "NO OUTLIER"
  END AS OUTLIER_STATUS
FROM CTE1 AS A 
LEFT JOIN CTE4 AS B 
ON 
  A.transaction_id = B.transaction_id
) AS TABLE_1
WHERE 
  TABLE_1.OUTLIER_STATUS = "OUTLIER" ;


"""
  Output =>
  +----------------+---------+----------------+
  | transaction_id | AMOUNT  | OUTLIER_STATUS |
  +----------------+---------+----------------+
  |             13 | 2000.00 | OUTLIER        |
  +----------------+---------+----------------+
  """












