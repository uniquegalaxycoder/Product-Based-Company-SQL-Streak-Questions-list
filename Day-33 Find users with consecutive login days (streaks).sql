"""
      Q.Find users with consecutive login days (streaks).
"""

CREATE TABLE user_logins (
    user_id INT,
    login_date DATE
);

INSERT INTO user_logins VALUES 
(101, '2026-01-01'), (101, '2026-01-02'), (101, '2026-01-03'),
(102, '2026-01-01'), (102, '2026-01-03'),
(103, '2026-01-04'), (103, '2026-01-05');

SELECT * FROM user_logins ;

WITH CTE1 AS (
  SELECT 
    user_id,
    login_date,
    LAG(login_date)OVER(PARTITION BY user_id ORDER BY login_date) AS YESTERDAY_DATE
  FROM user_logins
)

, CTE2 AS (
SELECT 
  *,
  CASE WHEN DATEDIFF(login_date, YESTERDAY_DATE) = 1 OR YESTERDAY_DATE IS NULL 
        THEN 1
        ELSE 0 
  END AS IS_ONE_DAY
FROM CTE1
)

SELECT 
  user_id,
  MIN(login_date) AS "STREAK START DATE",
  MAX(login_date) AS"STREAK END DATE",
  MAX(TOTAL_STREAK) AS "CONSICUTIVE DAY"
FROM (
SELECT 
  *,
  SUM(IS_ONE_DAY)OVER(PARTITION BY user_id ORDER BY login_date) AS TOTAL_STREAK
FROM CTE2
) AS G 
GROUP BY user_id 
HAVING MAX(TOTAL_STREAK) >= 2 ;

"""
  Output =>
  +---------+-------------------+-----------------+-----------------+
  | user_id | STREAK START DATE | STREAK END DATE | CONSICUTIVE DAY |
  +---------+-------------------+-----------------+-----------------+
  |     101 | 2026-01-01        | 2026-01-03      |               3 |
  |     103 | 2026-01-04        | 2026-01-05      |               2 |
  +---------+-------------------+-----------------+-----------------+
"""


