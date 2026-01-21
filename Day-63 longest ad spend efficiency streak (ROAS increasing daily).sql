"""
    Q.Identify the longest ad spend efficiency streak (ROAS increasing daily).

  BUSINESS CASE :
       To track an Ad Spend Efficiency Streak, we are looking for a continuous increase in ROAS 
       (Return on Ad Spend). 
       - ROAS is calculated as Revenue/Ad Spend.

"""

CREATE TABLE marketing_performance (
    campaign_name VARCHAR(50),
    spend DECIMAL(10, 2),
    revenue DECIMAL(10, 2),
    report_date DATE
);

INSERT INTO marketing_performance (campaign_name, spend, revenue, report_date) VALUES 
('Search_US', 100, 200, '2026-01-01'),
('Search_US', 100, 300, '2026-01-02'),
('Search_US', 100, 400, '2026-01-03'),
('Search_US', 100, 500, '2026-01-04'),
('Search_US', 100, 600, '2026-01-05'),
('Social_UK', 200, 1000, '2026-01-01'),
('Social_UK', 200, 1200, '2026-01-02'),
('Social_UK', 200, 1400, '2026-01-03'),
('Social_UK', 200, 800,  '2026-01-04'),
('Display_Global', 500, 1000, '2026-01-01'),
('Display_Global', 500, 1000, '2026-01-02');


SELECT * FROM marketing_performance ;

WITH CTE1 AS (
    SELECT 
      campaign_name,
      report_date,
      ROUND((revenue / NULLIF(spend,0))*100,2) AS RAOS 
    FROM marketing_performance
)

, CTE2 AS (
SELECT 
  *,
  LAG(report_date) OVER(PARTITION BY campaign_name ORDER BY report_date) AS PREVIOUS_DATE,
  LAG(RAOS) OVER(PARTITION BY campaign_name ORDER BY report_date) AS PREVIOUS_RAOS
FROM CTE1
)

, CTE3 AS (
SELECT 
  * ,
  CASE 
    WHEN  (DATEDIFF(report_date, PREVIOUS_DATE) = 1) AND 
          RAOS > PREVIOUS_RAOS 
        THEN 0
        ELSE 1
    END AS LENGTH
FROM CTE2 
)

, CTE4 AS (
SELECT 
  campaign_name,
  MIN(report_date) AS STARTS,
  MAX(report_date) AS ENDS,
  COUNT(STREAK_ID) AS LOGEST 
FROM (
SELECT 
  *,
  SUM(LENGTH)OVER(PARTITION BY campaign_name ORDER BY report_date) AS STREAK_ID 
FROM CTE3
) AS TABLE_1
GROUP BY campaign_name, STREAK_ID
)

SELECT 
  campaign_name,
  MAX(LOGEST) AS LONG_STREAK
FROM (
      SELECT 
        *,
        RANK()OVER( ORDER BY LOGEST DESC ) AS RANKS 
      FROM CTE4 
    ) AS TABLE_2 
-- WHERE RANKS = 1
GROUP BY campaign_name 
;

"""
  Output =>
    +----------------+-------------+
    | campaign_name  | LONG_STREAK |
    +----------------+-------------+
    | Search_US      |           5 |
    | Social_UK      |           3 |
    | Display_Global |           1 |
    +----------------+-------------+

"""
