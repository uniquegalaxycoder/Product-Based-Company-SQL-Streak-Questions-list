"""
    Q.Detects a lead quality drop streak (qualified leads decreasing daily).
"""

CREATE TABLE marketing_attribution_daily (
    log_id INT PRIMARY KEY,
    report_date DATE,
    region VARCHAR(50),
    channel VARCHAR(50),      -- e.g., 'Paid Search', 'Social'
    sub_source VARCHAR(50),   -- e.g., 'Google_Ads', 'FB_Video'
    total_leads_generated INT,
    qualified_leads INT,      -- THIS is the metric for our streak
    opportunity_leads INT,    -- High intent leads
    total_spend DECIMAL(10, 2)
);

INSERT INTO marketing_attribution_daily 
(log_id, report_date, region, channel, sub_source, total_leads_generated, qualified_leads, opportunity_leads, total_spend) 
VALUES 
(1, '2026-01-10', 'NA', 'Paid Search', 'Google_Ads', 200, 50, 10, 500.00),
(2, '2026-01-11', 'NA', 'Paid Search', 'Google_Ads', 210, 40, 8, 550.00),
(3, '2026-01-12', 'NA', 'Paid Search', 'Google_Ads', 190, 30, 5, 520.00),
(4, '2026-01-13', 'NA', 'Paid Search', 'Google_Ads', 250, 20, 4, 600.00),
(5, '2026-01-14', 'NA', 'Paid Search', 'Google_Ads', 220, 10, 2, 580.00),
(6, '2026-01-15', 'NA', 'Paid Search', 'Google_Ads', 200, 5, 1, 500.00),
(7, '2026-01-10', 'EMEA', 'Paid Social', 'FB_Video', 100, 20, 5, 300.00),
(8, '2026-01-11', 'EMEA', 'Paid Social', 'FB_Video', 120, 25, 6, 350.00), 
(9, '2026-01-12', 'EMEA', 'Paid Social', 'FB_Video', 110, 15, 3, 320.00),
(10, '2026-01-10', 'APAC', 'Paid Social', 'LinkedIn', 50, 10, 2, 400.00),
(11, '2026-01-11', 'APAC', 'Paid Social', 'LinkedIn', 55, 10, 2, 420.00); 

SELECT * FROM marketing_attribution_daily ;

WITH CTE1 AS (
    SELECT 
      report_date,
      channel,
      sub_source,
      qualified_leads,
      LAG(report_date) OVER(partition BY sub_source ORDER BY report_date) AS PREVIOUS_DATE,
      LAG(qualified_leads) OVER(partition BY sub_source ORDER BY report_date) AS PREVIOUS_QULIFIED_LEADS
    FROM marketing_attribution_daily
)

, CTE2 AS (
    SELECT 
      * ,
      CASE 
          WHEN  DATEDIFF(report_date, PREVIOUS_DATE) = 1 AND 
                qualified_leads < PREVIOUS_QULIFIED_LEADS 
              THEN 0 
              ELSE 1 
        END AS IS_GAP 
    FROM CTE1 
)

SELECT 
  channel,
  sub_source,
  MIN(report_date) AS START_DATE,
  MAX(report_date) AS END_DATE,
  COUNT(*) AS TOTAL_DAYS 
FROM (
SELECT 
  *,
  SUM(IS_GAP)OVER(partition BY sub_source ORDER BY report_date) AS STREAK_ID
FROM CTE2 
) AS TABLE_1 
WHERE IS_GAP = 0 
GROUP BY channel, sub_source, STREAK_ID 
ORDER BY COUNT(*) DESC ;
"""
  Output =>
  
    +-------------+------------+------------+------------+------------+
    | channel     | sub_source | START_DATE | END_DATE   | TOTAL_DAYS |
    +-------------+------------+------------+------------+------------+
    | Paid Search | Google_Ads | 2026-01-11 | 2026-01-15 |          5 |
    | Paid Social | FB_Video   | 2026-01-12 | 2026-01-12 |          1 | 
    +-------------+------------+------------+------------+------------+

  """
