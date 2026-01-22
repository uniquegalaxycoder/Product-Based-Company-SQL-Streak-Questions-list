"""
  Q.Detect longest streak where refund % kept increasing daily.
"""

CREATE TABLE daily_operations (
    log_id INT PRIMARY KEY,
    store_location VARCHAR(50),
    units_sold INT,
    units_returned INT,
    report_date DATE
);

INSERT INTO daily_operations (log_id, store_location, units_sold, units_returned, report_date) VALUES 

(1, 'Downtown', 1000, 20, '2026-01-01'), 
(2, 'Downtown', 1000, 40, '2026-01-02'), 
(3, 'Downtown', 1000, 70, '2026-01-03'), 
(4, 'Downtown', 1000, 90, '2026-01-04'), 
(5, 'Downtown', 1100, 132,'2026-01-05'), 
(6, 'Downtown', 1000, 150,'2026-01-06'), 
(7, 'Uptown', 500, 50, '2026-01-01'), 
(8, 'Uptown', 500, 80, '2026-01-02'), 
(9, 'Uptown', 500, 30, '2026-01-03'), 
(10, 'Uptown', 500, 40, '2026-01-04');

SELECT * FROM daily_operations ;

WITH CTE1 AS (
    SELECT 
      store_location,
      report_date,
      ROUND(( TOTLA_RETURNED / TOTAL_SOLD)*100,2) AS REFUND_PERCENT
    FROM (
            SELECT 
              store_location,
              report_date,
              SUM(units_sold) AS TOTAL_SOLD,
              SUM(units_returned) AS TOTLA_RETURNED 
            FROM daily_operations 
            GROUP BY 
              store_location, report_date
          ) AS TABLE_1 
)
, CTE2 AS (
    SELECT 
      *,
      LAG(report_date) OVER(partition BY store_location order BY report_date) AS PREVIOUS_DATE,
      LAG(REFUND_PERCENT) OVER(partition BY store_location order BY report_date) AS PREVIOUS_PERCENT
    FROM CTE1 
)

, CTE3 AS (
    SELECT 
      *,
      CASE 
        WHEN (DATEDIFF(report_date, PREVIOUS_DATE)= 1 OR DATEDIFF(report_date, PREVIOUS_DATE) IS NULL )
        AND REFUND_PERCENT > PREVIOUS_PERCENT 
        THEN 0 
        ELSE 1 
      END AS IS_GAP 
    FROM CTE2 
)

, CTE4 AS (
    SELECT 
      store_location,
      MIN(report_date) AS START_DATE,
      MAX(report_date) AS END_DATE,
      COUNT(*) AS TOTAL 
    FROM (
        SELECT 
          *,
          SUM(IS_GAP) OVER(partition BY store_location ORDER BY report_date) AS STREAK_ID 
        FROM CTE3 
      ) AS TABLE_2 
    WHERE IS_GAP = 0 
    GROUP BY store_location, STREAK_ID
)

SELECT * FROM CTE4 ;

"""
  Output =>
  +----------------+------------+------------+-------+
  | store_location | START_DATE | END_DATE   | TOTAL |
  +----------------+------------+------------+-------+
  | Downtown       | 2026-01-02 | 2026-01-06 |     5 |
  | Uptown         | 2026-01-02 | 2026-01-02 |     1 |
  | Uptown         | 2026-01-04 | 2026-01-04 |     1 |
  +----------------+------------+------------+-------+

"""








