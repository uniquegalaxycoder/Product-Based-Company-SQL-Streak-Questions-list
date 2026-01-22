"""
    Q.Identify streaks where system uptime was < 99.9% for 3+ hours continuously.
"""

CREATE TABLE system_uptime (
    log_id INT PRIMARY KEY,
    server_cluster VARCHAR(50),
    uptime_percentage DECIMAL(5, 2), 
    log_hour DATETIME
);

INSERT INTO system_uptime (log_id, server_cluster, uptime_percentage, log_hour) VALUES 
(1, 'Prod-Alpha', 100.00, '2026-01-23 13:00:00'),
(2, 'Prod-Alpha', 99.85,  '2026-01-23 14:00:00'), 
(3, 'Prod-Alpha', 99.70,  '2026-01-23 15:00:00'), 
(4, 'Prod-Alpha', 98.50,  '2026-01-23 16:00:00'), 
(5, 'Prod-Alpha', 99.20,  '2026-01-23 17:00:00'), 
(6, 'Prod-Alpha', 100.00, '2026-01-23 18:00:00'), 
(7, 'Prod-Beta', 99.99,  '2026-01-23 14:00:00'),
(8, 'Prod-Beta', 99.50,  '2026-01-23 15:00:00'), 
(9, 'Prod-Beta', 100.00, '2026-01-23 16:00:00'); 

SELECT * FROM system_uptime ;

WITH CTE1 AS (
    SELECT 
      server_cluster ,
      CAST(log_hour AS DATE ) AS DAY,
      DATE_FORMAT(CAST(log_hour AS TIME), '%h:%i:%s') AS HRS,
      uptime_percentage
    FROM system_uptime
)

,CTE2 AS (
SELECT 
  * ,
  LAG(HRS) OVER(PARTITION BY server_cluster ORDER BY HRS) AS PREVIOUS_HRS
FROM CTE1
)

, CTE3 AS (
SELECT 
  * ,
  CASE WHEN (HRS - PREVIOUS_HRS) = 1 AND 
            uptime_percentage < 99.9    
      THEN 0 
      ELSE 1 
    END AS IS_GAP
FROM CTE2  
)

SELECT 
  server_cluster,
  MIN(HRS) AS START_TIME,
  MAX(HRS) AS END_TIME,
  COUNT(*) AS TOTAL 
FROM (
        SELECT 
          *,
          SUM(IS_GAP) OVER(PARTITION BY server_cluster ORDER BY HRS) AS STREAK_ID
        FROM CTE3
    ) AS TABLE_1
WHERE IS_GAP = 0 
GROUP BY server_cluster, STREAK_ID
HAVING COUNT(*) >= 3 
;

"""
  Output =>
  +----------------+------------+----------+-------+
  | server_cluster | START_TIME | END_TIME | TOTAL |
  +----------------+------------+----------+-------+
  | Prod-Alpha     | 02:00:00   | 05:00:00 |     4 |
  +----------------+------------+----------+-------+

"""






