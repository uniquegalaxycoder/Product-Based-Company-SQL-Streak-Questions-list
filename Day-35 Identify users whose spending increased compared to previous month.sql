"""
    Q.Identify users whose spending increased compared to previous month.
"""

CREATE TABLE daily_spending (
    transaction_id INT PRIMARY KEY,
    user_id INT,
    spend_amount DECIMAL(10, 2),
    spend_date DATE
);

INSERT INTO daily_spending (transaction_id, user_id, spend_amount, spend_date) VALUES 
(1, 101, 50.00, '2025-10-05'), (2, 101, 50.00, '2025-10-20'), 
(3, 101, 75.00, '2025-11-10'), (4, 101, 75.00, '2025-11-25'), 
(5, 101, 100.00, '2025-12-05'), (6, 101, 110.00, '2025-12-15'),
(7, 102, 200.00, '2025-10-01'),                               
(8, 102, 150.00, '2025-11-05'), (9, 102, 150.00, '2025-11-15'),
(10, 102, 50.00, '2025-12-01'),                               
(11, 103, 500.00, '2025-10-10'),                              
(12, 103, 400.00, '2025-11-12'),                              
(13, 103, 300.00, '2025-12-14');                              

SELECT * FROM daily_spending ;

WITH CTE1 AS (
  SELECT
    user_id,
    DATE_FORMAT(spend_date, '%b-%Y') AS MONTHS,
    SUM(spend_amount) AS CURRENT_SPEND 
  FROM daily_spending
  GROUP BY user_id, DATE_FORMAT(spend_date, '%b-%Y')
)
, CTE2 AS (
SELECT 
  *
FROM (
SELECT 
  *,
  lag(CURRENT_SPEND)over(partition by user_id ORDER BY MONTHS) AS LAST_MONTH_SPEND
FROM CTE1) AS TABLE_1 
WHERE LAST_MONTH_SPEND IS NOT NULL
)

SELECT 
  user_id,
  MONTHS,
  CURRENT_SPEND AS "CURRENT MONTH SPEND",
  LAST_MONTH_SPEND AS "LAST MONTH SPEND",
  TOTAL_INCREASED AS "TOTAL SPENDING INCREASED"
FROM (
      SELECT 
        *,
        ROUND((LAST_MONTH_SPEND - CURRENT_SPEND)) AS TOTAL_INCREASED,
        CASE 
            WHEN LAST_MONTH_SPEND > CURRENT_SPEND 
            THEN 1 
            ELSE 0 
        END AS IS_INCREASED
      FROM CTE2 
      ) as table_2 
WHERE IS_INCREASED = 1
ORDER BY user_id, MONTHS DESC;

"""
  Output => 
  +---------+----------+---------------------+------------------+--------------------------+
  | user_id | MONTHS   | CURRENT MONTH SPEND | LAST MONTH SPEND | TOTAL SPENDING INCREASED |
  +---------+----------+---------------------+------------------+--------------------------+
  |     101 | Oct-2025 |              100.00 |           150.00 |                       50 |
  |     101 | Nov-2025 |              150.00 |           210.00 |                       60 |
  |     102 | Oct-2025 |              200.00 |           300.00 |                      100 |
  +---------+----------+---------------------+------------------+--------------------------+
  
  """
