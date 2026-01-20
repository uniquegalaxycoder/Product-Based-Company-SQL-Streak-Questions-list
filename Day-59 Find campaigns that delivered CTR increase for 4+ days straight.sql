""" 
    Q.Find campaigns that delivered CTR increase for 4+ days straight.

BUSINESS CASE :
  To find a CTR (Click-Through Rate) increase streak, we need to compare each day's performance 
  to the previous day. For an analyst, this is a "Trend-Based Island" problem.

"""

CREATE TABLE campaign_performance (
    campaign_id INT,
    report_date DATE,
    impressions INT,
    clicks INT,
    PRIMARY KEY (campaign_id, report_date)
);

INSERT INTO campaign_performance (campaign_id, report_date, impressions, clicks) VALUES 
(101, '2026-01-01', 1000, 5),  
(101, '2026-01-02', 1000, 10), 
(101, '2026-01-03', 1000, 15), 
(101, '2026-01-04', 1000, 20), 
(101, '2026-01-05', 1000, 25), 
(102, '2026-01-01', 1000, 10), 
(102, '2026-01-02', 1000, 12), 
(102, '2026-01-03', 1000, 14), 
(102, '2026-01-04', 1000, 8);  

SELECT * FROM campaign_performance ;

WITH CTE1 AS (
    SELECT 
      campaign_id,
      report_date,
      impressions,
      clicks,
      ROUND((clicks/impressions)*100,2) AS CTR_RATIO,
      LAG(ROUND((clicks/impressions)*100,2)) OVER(partition BY campaign_id ORDER BY report_date) AS PREVIOUS_CTR,
      LAG(report_date) OVER(partition BY campaign_id ORDER BY report_date) AS PREVIOUS_DATE
    FROM campaign_performance
)

, CTE2 AS (
    SELECT 
      *,
      CASE 
        WHEN  DATEDIFF(report_date, PREVIOUS_DATE) = 1 AND
              CTR_RATIO > PREVIOUS_CTR 
              THEN 0 
              ELSE 1 
        END AS LENGTH
    FROM CTE1 
    
)    
SELECT 
  campaign_id,
  MIN(report_date) AS "START DATE",
  MAX(report_date) AS "END DATE",
  MIN(CTR_RATIO) AS "STARTING CTR",
  MAX(CTR_RATIO) AS "END CTR",
  COUNT(STREAK_ID) AS "TOTAL DAYS STREAK"
FROM (
SELECT 
  *,
  SUM(LENGTH)OVER(PARTITION BY campaign_id ORDER BY report_date) AS STREAK_ID
FROM CTE2
) AS TT 
WHERE LENGTH = 0 
GROUP BY campaign_id, STREAK_ID
HAVING COUNT(STREAK_ID) >= 4 ;

"""
  Output =>

  +-------------+------------+------------+--------------+---------+-------------------+
  | campaign_id | START DATE | END DATE   | STARTING CTR | END CTR | TOTAL DAYS STREAK |
  +-------------+------------+------------+--------------+---------+-------------------+
  |         101 | 2026-01-02 | 2026-01-05 |         1.00 |    2.50 |                 4 | 
  +-------------+------------+------------+--------------+---------+-------------------+

"""



