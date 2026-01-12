"""
    Q.Find products with increasing sales for 3 consecutive months.
"""

CREATE TABLE monthly_sales (
    product_name VARCHAR(50),
    month_date DATE,
    total_sales DECIMAL(10, 2)
);

INSERT INTO monthly_sales VALUES 
('Laptop', '2025-10-01', 5000),
('Laptop', '2025-11-01', 6000),
('Laptop', '2025-12-01', 7500),
('Phone', '2025-10-01', 8000),
('Phone', '2025-11-01', 9000),
('Phone', '2025-12-01', 8500),
('Tablet', '2025-10-01', 3000),
('Tablet', '2025-11-01', 2500),
('Tablet', '2025-12-01', 2000);

SELECT * FROM monthly_sales ;

WITH CTE1 AS (
  SELECT 
    product_name,
    month_date,
    total_sales,
    LAG(total_sales)OVER(PARTITION BY product_name ORDER BY month_date) AS LAST_MONTH_SALES
  FROM monthly_sales
)

, CTE2 AS (
SELECT 
  *,
  CASE WHEN total_sales > LAST_MONTH_SALES OR LAST_MONTH_SALES IS NULL THEN 0 ELSE 1 END AS IS_INCREASE
FROM CTE1
)

, CTE3 AS (
SELECT 
  *,
  SUM(IS_INCREASE) OVER( ORDER BY month_date ) AS STREAK_ID 
FROM CTE2
WHERE IS_INCREASE = 0
)


SELECT 
  product_name,
  COUNT(*) AS TOTAL_MONTHS_COUNT
FROM CTE3
GROUP BY product_name
ORDER BY COUNT(*) DESC 
LIMIT 1 ;

"""
  Output =>
  +--------------+--------------------+
  | product_name | TOTAL_MONTHS_COUNT |
  +--------------+--------------------+
  | Laptop       |                  3 |
  +--------------+--------------------+
  
"""
