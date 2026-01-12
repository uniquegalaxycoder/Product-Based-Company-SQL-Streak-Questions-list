"""
    Q.Calculate daily, weekly, and monthly active users (DAU/WAU/MAU).
"""

CREATE TABLE activity_log (
    activity_id INT PRIMARY KEY,
    user_id INT,
    activity_date DATE
);

INSERT INTO activity_log (activity_id, user_id, activity_date) VALUES 
(1, 101, '2026-01-01'), (2, 102, '2026-01-01'), 
(3, 101, '2026-01-02'), (4, 103, '2026-01-02'), 
(5, 104, '2026-01-08'), (6, 101, '2026-01-08'), 
(7, 105, '2026-01-15'), (8, 102, '2026-01-15'), 
(9, 101, '2026-01-20'), (10, 106, '2026-01-22'), 
(11, 107, '2026-02-01');                        

select * from activity_log ;

WITH DAU AS (
  SELECT 
    activity_date,
    COUNT(DISTINCT user_id) AS DAU 
  FROM activity_log
  GROUP BY activity_date
)

SELECT * FROM DAU ;

WITH WAU AS (
  SELECT 
    EXTRACT(WEEK FROM activity_date) AS WEEKS,
    COUNT(DISTINCT USER_ID) AS WAU
  FROM activity_log 
  GROUP BY EXTRACT(WEEK FROM activity_date) 
)

SELECT * FROM WAU ;

WITH MAU AS(
  SELECT 
    EXTRACT(MONTH FROM activity_date) AS MONTHS,
    COUNT(DISTINCT user_id) AS MAU
  FROM activity_log
  GROUP BY EXTRACT(MONTH FROM activity_date)
)

SELECT * FROM MAU ;

"""
  Output =>
  +---------------+-----+
| activity_date | DAU |
+---------------+-----+
| 2026-01-01    |   2 |
| 2026-01-02    |   2 |
| 2026-01-08    |   2 |
| 2026-01-15    |   2 |
| 2026-01-20    |   1 |
| 2026-01-22    |   1 |
| 2026-02-01    |   1 |
+---------------+-----+
+-------+-----+
| WEEKS | WAU |
+-------+-----+
|     0 |   3 |
|     1 |   2 |
|     2 |   2 |
|     3 |   2 |
|     5 |   1 |
+-------+-----+
+--------+-----+
| MONTHS | MAU |
+--------+-----+
|      1 |   6 |
|      2 |   1 |
+--------+-----+
  
  """
