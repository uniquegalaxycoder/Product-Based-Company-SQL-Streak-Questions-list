"""
    Q.Find the longest traffic growth streak per region.
  BUSINESS CASE :
       To find the longest streak of traffic growth (increasing website sessions), 
       we need to compare total sessions day-over-day within each geographic region.
"""

CREATE TABLE regional_traffic (
    log_id INT PRIMARY KEY,
    region VARCHAR(50),
    channel VARCHAR(50),
    sessions INT,
    report_date DATE
);

INSERT INTO regional_traffic (log_id, region, channel, sessions, report_date) VALUES 
(1, 'NA', 'Direct', 100, '2026-01-01'),
(2, 'NA', 'Search', 120, '2026-01-02'),
(3, 'NA', 'Social', 140, '2026-01-03'),
(4, 'NA', 'Direct', 160, '2026-01-04'),
(5, 'NA', 'Search', 180, '2026-01-05'),
(6, 'NA', 'Social', 200, '2026-01-06'),
(7, 'EU', 'Direct', 500, '2026-01-01'),
(8, 'EU', 'Search', 550, '2026-01-02'), 
(9, 'EU', 'Social', 600, '2026-01-03'), 
(10, 'EU', 'Direct', 400, '2026-01-04'),
(11, 'EU', 'Search', 450, '2026-01-05'), 
(12, 'EU', 'Social', 500, '2026-01-06'); 

SELECT * FROM regional_traffic ;

WITH CTE1 AS (
    SELECT 
      region,
      sessions,
      report_date,
      LAG(report_date) OVER(PARTITION BY region ORDER BY report_date) AS PREVIOUS_DATE,
      LAG(sessions) OVER(PARTITION BY region ORDER BY report_date) AS PREVIOUS_SESSIONS 
    FROM regional_traffic
)
, CTE2 AS (
SELECT 
  * ,
  CASE 
    WHEN  (DATEDIFF(report_date, PREVIOUS_DATE) = 1 OR DATEDIFF(report_date, PREVIOUS_DATE) IS NULL)
          AND 
          sessions > PREVIOUS_SESSIONS 
        THEN 0 
        ELSE 1  
      END AS IS_GAP 
FROM CTE1 
)
, CTE3 AS (
  SELECT 
    region,
    MIN(report_date) AS "GROWTH START",
    MAX(report_date) AS "GROWTH END",
    COUNT(*)+1 AS "STREAK"    
    -- By adding +1 to the count, you tell the business how many days the traffic was ‘at an elevated or growing state’ INSIGHTS
  FROM (
        SELECT 
          *,
          SUM(IS_GAP)OVER(PARTITION BY region ORDER BY report_date) AS STREAK_ID 
        FROM CTE2 
      ) AS TABLE_1 
  WHERE 
      IS_GAP = 0 
  GROUP BY
      region, STREAK_ID
  ORDER BY
      COUNT(*) DESC
)
SELECT * FROM CTE3 ; 

"""
  Output =>
  +--------+--------------+------------+--------+
  | region | GROWTH START | GROWTH END | STREAK |
  +--------+--------------+------------+--------+
  | NA     | 2026-01-02   | 2026-01-06 |      6 |
  | EU     | 2026-01-02   | 2026-01-03 |      3 |
  | EU     | 2026-01-05   | 2026-01-06 |      3 | 
  +--------+--------------+------------+--------+

"""
