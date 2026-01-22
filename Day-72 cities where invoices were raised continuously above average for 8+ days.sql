"""
  Q.Identify cities where invoices were raised continuously above average for 8+ days.

   BUSINESS CASE :
       This is a fantastic 'Level 3' challenge. It combines Aggregation (calculating the average) with
       Trend Analysis (comparing individual days to that average) and Streak Detection.

       In this scenario, we arent comparing today to yesterday; we are comparing today to a static benchmark 
       (the city's overall average).
"""

CREATE TABLE city_invoices (
    invoice_id INT PRIMARY KEY,
    city_name VARCHAR(50),
    branch_id VARCHAR(10),
    invoice_amount DECIMAL(10, 2),
    raised_at DATE
);

INSERT INTO city_invoices (invoice_id, city_name, branch_id, invoice_amount, raised_at) VALUES 
(1, 'Mumbai', 'MUM-01', 6000, '2026-01-01'),
(2, 'Mumbai', 'MUM-01', 6200, '2026-01-02'),
(3, 'Mumbai', 'MUM-01', 6100, '2026-01-03'),
(4, 'Mumbai', 'MUM-01', 6300, '2026-01-04'),
(5, 'Mumbai', 'MUM-01', 6500, '2026-01-05'),
(6, 'Mumbai', 'MUM-01', 6400, '2026-01-06'),
(7, 'Mumbai', 'MUM-01', 6700, '2026-01-07'),
(8, 'Mumbai', 'MUM-01', 6800, '2026-01-08'),
(9, 'Mumbai', 'MUM-01', 6900, '2026-01-09'),
(10, 'Mumbai', 'MUM-01', 1000, '2026-01-15'),
(11, 'Mumbai', 'MUM-01', 1000, '2026-01-16'),
(12, 'London', 'LDN-01', 4000, '2026-01-01'), 
(13, 'London', 'LDN-01', 4500, '2026-01-02'), 
(14, 'London', 'LDN-01', 500,  '2026-01-03'), 
(15, 'London', 'LDN-01', 4200, '2026-01-04'); 

SELECT * FROM city_invoices ;

WITH CTE1 AS (
    SELECT 
      city_name,
      raised_at,
      SUM(invoice_amount) AS invoice_amount
    FROM city_invoices 
    GROUP BY city_name, raised_at 
)

, CTE2 AS (
    SELECT 
      city_name,
      invoice_amount,
      ROUND(AVG(invoice_amount) OVER(partition BY city_name)) AS AVG_INVOICES ,
      raised_at,
      LAG(raised_at)OVER(partition BY city_name ORDER BY raised_at) AS PREVIOUS_DATE
    FROM CTE1
)

, CTE3 AS (
    SELECT
      *,
      CASE 
        WHEN ( DATEDIFF(raised_at, PREVIOUS_DATE) = 1 OR DATEDIFF(raised_at, PREVIOUS_DATE) IS NULL ) 
        AND invoice_amount > AVG_INVOICES
        THEN 0 
        ELSE 1 
      END AS IS_GAP 
    FROM CTE2
)


SELECT 
  city_name,
  MIN(raised_at) AS "START DATE",
  MAX(raised_at) AS "END DATE",
  COUNT(*) AS "TOTAL DAY"
FROM (
SELECT
  * ,
  SUM(IS_GAP) OVER(partition BY city_name ORDER BY raised_at) AS STREAK_ID 
FROM CTE3 
) AS TABLE_1 
WHERE IS_GAP = 0 
GROUP BY city_name, STREAK_ID
HAVING COUNT(*) >= 8 
;

"""
  Output =>
  +-----------+------------+------------+-----------+
  | city_name | START DATE | END DATE   | TOTAL DAY |
  +-----------+------------+------------+-----------+
  | Mumbai    | 2026-01-01 | 2026-01-09 |         9 |
  +-----------+------------+------------+-----------+

"""






