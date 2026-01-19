"""
    Q.Identify sellers whose revenue declined for 3 straight months.
"""

CREATE TABLE monthly_sales (
    seller_id INT,
    month_date DATE,
    revenue DECIMAL(10, 2)
);

INSERT INTO monthly_sales (seller_id, month_date, revenue) VALUES 
(1, '2025-10-01', 10000),
(1, '2025-11-01', 8000),
(1, '2025-12-01', 6000),
(1, '2026-01-01', 4000), 
(2, '2025-10-01', 5000),
(2, '2025-11-01', 4000),
(2, '2025-12-01', 3000),
(2, '2026-01-01', 7000), 
(3, '2025-11-01', 2000),
(3, '2025-12-01', 2000),
(3, '2026-01-01', 2000);

SELECT * FROM monthly_sales ;

with cte1 as (
    SELECT 
      seller_id,
      month_date,
      revenue,
      LAG(month_date)OVER(partition BY seller_id ORDER BY month_date ) AS LAST_MONTH,
      LAG(revenue)OVER(partition BY seller_id ORDER BY month_date) AS LAST_MONTH_REVENUE 
    FROM monthly_sales
)
, CTE2 AS (
SELECT 
  * ,
  ROUND(((revenue - LAST_MONTH_REVENUE)/ LAST_MONTH_REVENUE)*100) AS GROWTH,
  TIMESTAMPDIFF(MONTH, LAST_MONTH, month_date) AS MONTH_DIFF
FROM cte1 )

, CTE3 AS (
SELECT 
  * ,
  CASE WHEN GROWTH < 0 OR GROWTH IS NULL THEN 0 ELSE 1 END AS IS_GROWTH
FROM CTE2 
)

, CTE4 AS (
SELECT 
  *,
  SUM(IS_GROWTH)OVER(partition BY seller_id ORDER BY month_date) AS STREAK_ID
FROM CTE3
WHERE MONTH_DIFF = 1 
)

SELECT 
  seller_id,
  DECLINE_START,
  DECLINE_END,
  TOTAL AS "REV. DECLINED MONTHS"
FROM (
SELECT 
  seller_id,
  STREAK_ID,
  MIN(month_date) AS DECLINE_START,
  MAX(month_date) AS DECLINE_END,
  COUNT(*) AS TOTAL
FROM CTE4 
GROUP BY seller_id, STREAK_ID 
)AS T 
WHERE TOTAL >= 3;

"""
  Output =>

  +-----------+---------------+-------------+----------------------+
  | seller_id | DECLINE_START | DECLINE_END | REV. DECLINED MONTHS |
  +-----------+---------------+-------------+----------------------+
  |         1 | 2025-11-01    | 2026-01-01  |                    3 |
  +-----------+---------------+-------------+----------------------+

"""
