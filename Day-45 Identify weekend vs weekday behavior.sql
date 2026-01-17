"""
    Q.Identify weekend vs weekday behavior.
"""

CREATE TABLE activity_logs (
    activity_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    activity_date DATE,
    session_minutes INT
);

INSERT INTO activity_logs (user_id, activity_date, session_minutes) VALUES 
(101, '2026-01-12', 30), 
(102, '2026-01-13', 25), 
(103, '2026-01-14', 35), 
(101, '2026-01-15', 20), 
(102, '2026-01-16', 40), 
(103, '2026-01-17', 120),
(101, '2026-01-18', 110),
(102, '2026-01-19', 30); 

SELECT * FROM activity_logs ;

WITH CTE1 AS (
  SELECT 
    activity_id,
    user_id,
    activity_date,
    CASE WHEN DAYOFWEEK(activity_date) IN (1,7) THEN 'WEEKEND' ELSE 'WEEKDAY' END AS DAY,
    session_minutes
  FROM activity_logs
)

SELECT 
  DAY,
  ROUND(AVG(session_minutes),2) AS AVG_MINUTES,
  SUM(session_minutes) AS TOTAL_MINUTES
FROM CTE1 
GROUP BY DAY
;

"""
  Output =>
  +---------+-------------+---------------+
  | DAY     | AVG_MINUTES | TOTAL_MINUTES |
  +---------+-------------+---------------+
  | WEEKDAY |       30.00 |           180 |
  | WEEKEND |      115.00 |           230 |
  +---------+-------------+---------------+

"""

