"""
    Q.Identify streaks where daily API errors increased continuously for 5+ days.
"""

CREATE TABLE api_logs (
    log_id INT PRIMARY KEY,
    service_name VARCHAR(50),
    error_count INT,
    log_date DATE
);

INSERT INTO api_logs (log_id, service_name, error_count, log_date) VALUES 
(1, 'Payment-Gateway', 10, '2026-01-01'),
(2, 'Payment-Gateway', 20, '2026-01-02'),
(3, 'Payment-Gateway', 30, '2026-01-05'),
(4, 'Payment-Gateway', 40, '2026-01-06'),
(5, 'Payment-Gateway', 50, '2026-01-07'),
(6, 'Payment-Gateway', 60, '2026-01-08'),
(7, 'Payment-Gateway', 70, '2026-01-09'),
(8, 'Payment-Gateway', 80, '2026-01-10'),
(9, 'Auth-Service', 100, '2026-01-01'),
(10, 'Auth-Service', 150, '2026-01-02'),
(11, 'Auth-Service', 200, '2026-01-03'),
(12, 'Auth-Service', 180, '2026-01-04');

SELECT * FROM api_logs ;

WITH CTE1 AS (
    SELECT
      log_id,
      service_name,
      error_count,
      log_date,
      LAG(error_count)OVER(partition BY service_name ORDER BY log_date) AS PREVIOUS_ERRORS_COUNT,
      LAG(log_date) OVER(partition BY service_name ORDER BY log_date) AS PREVIOUS_DATE
    FROM api_logs
)

, CTE2 AS (
SELECT 
  * ,
  CASE WHEN DATEDIFF(log_date, PREVIOUS_DATE) = 1 AND 
        error_count > PREVIOUS_ERRORS_COUNT 
        THEN 0 
        ELSE 1 
    END AS LENGTH
FROM CTE1 
)

SELECT 
  service_name,
  MIN(log_date) AS START_DATE,
  MAX(log_date) AS END_DATE,
  COUNT(*) AS TOTAL_STREAK 
FROM (
      SELECT 
        *,
        SUM(LENGTH) OVER(partition BY service_name ORDER BY log_date) AS STREAK_ID 
      FROM CTE2 
    ) AS TABLE_1 
GROUP BY service_name, STREAK_ID
HAVING COUNT(*) >= 5 ; 

"""
  Output =>
    +-----------------+------------+------------+--------------+
    | service_name    | START_DATE | END_DATE   | TOTAL_STREAK |
    +-----------------+------------+------------+--------------+
    | Payment-Gateway | 2026-01-05 | 2026-01-10 |            6 |
    +-----------------+------------+------------+--------------+
"""
