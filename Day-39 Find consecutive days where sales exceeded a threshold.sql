"""
    Q.Find consecutive days where sales exceeded a threshold.

CASE :
  - In this dataset, we will look for days where revenue > 500.
  - Jan 1 - Jan 3: Above threshold (Streak of 3 days).
  - Jan 4: Below threshold (Breaks the streak).
  - Jan 5 - Jan 6: Above threshold (Streak of 2 days).

"""

CREATE TABLE daily_sales (
    sale_date DATE PRIMARY KEY,
    revenue DECIMAL(10, 2)
);

INSERT INTO daily_sales (sale_date, revenue) VALUES 
('2026-01-01', 600.00), 
('2026-01-02', 750.00),
('2026-01-03', 550.00), 
('2026-01-04', 300.00),                                             
('2026-01-05', 800.00), 
('2026-01-06', 900.00),                     
('2026-01-07', 450.00); 

SELECT * FROM daily_sales ;

WITH CTE1 AS (
  SELECT 
    sale_date,
    revenue
  FROM daily_sales
)

, CTE2 AS (
SELECT 
  * ,
  CASE WHEN revenue > 500 THEN 1 ELSE 0 END AS threshold ,
  LAG(sale_date)OVER(ORDER BY sale_date) AS YESTERDAY_DATE
FROM CTE1
where revenue > 500
)

, CTE3 AS (
SELECT 
  *,
  SUM(CASE WHEN threshold = 1 AND 
            ( DATEDIFF(sale_date , YESTERDAY_DATE)= 1 
        or  DATEDIFF(sale_date , YESTERDAY_DATE) is null )
        THEN 0 ELSE 1 END )
  OVER(ORDER BY sale_date) AS STREAK_ID 
FROM CTE2
)

SELECT 
  min(sale_date) as "START DATE",
  max(sale_date) as "END DATE",
  count(*) as "TOTAL DAYS"
FROM CTE3 
group by STREAK_ID ;

"""
  Output =>
    +------------+------------+------------+
    | START DATE | END DATE   | TOTAL DAYS |
    +------------+------------+------------+
    | 2026-01-01 | 2026-01-03 |          3 |
    | 2026-01-05 | 2026-01-06 |          2 |
    +------------+------------+------------+
"""



