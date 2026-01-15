"""
    Q.Calculate retention cohorts (Day 1, Day 7, Day 30).
"""

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    signup_date DATE
);

CREATE TABLE activity_log (
    user_id INT,
    activity_date DATE
);


INSERT INTO users VALUES 
(1, '2026-01-01'), (2, '2026-01-01'), (3, '2026-01-01'), (4, '2026-01-01');

INSERT INTO activity_log VALUES 
(1, '2026-01-02'), (2, '2026-01-02'), (3, '2026-01-02'),
(1, '2026-01-08'), (2, '2026-01-08'),
(1, '2026-01-31');


SELECT * FROM USERS ;
SELECT * FROM activity_log ;

WITH CTE1 AS (
  SELECT 
    A.user_id,
    A.signup_date,
    B.activity_date
  FROM users AS A 
  LEFT JOIN 
    activity_log AS B 
  ON 
    A.user_id  = B.user_id
)

, CTE2 AS (
SELECT 
  *,
  DATEDIFF(activity_date, signup_date) AS DAYDIFF
FROM CTE1 
)

, CTE3 AS (
SELECT 
  signup_date,
  COUNT(DISTINCT user_id) AS TOTAL_USERS,
  COUNT(CASE WHEN DAYDIFF = 1 THEN user_id END ) AS RETENTION_COHORT_1DAY,
  COUNT(CASE WHEN DAYDIFF > 1 AND DAYDIFF <= 7 THEN user_id END ) AS RETENTION_COHORT_7DAY,
  COUNT(CASE WHEN DAYDIFF > 7 AND DAYDIFF <= 30 THEN user_id END ) AS RETENTION_COHORT_30DAY
FROM CTE2 
GROUP BY signup_date 
)

SELECT 
  signup_date,
  TOTAL_USERS,
  CONCAT(ROUND(((RETENTION_COHORT_1DAY * 100) / TOTAL_USERS)), "%") AS DAY_1_RETEN_COHORT,
  CONCAT(ROUND(((RETENTION_COHORT_7DAY * 100) / TOTAL_USERS)), "%")  AS DAY_7_RETEN_COHORT,
  CONCAT(ROUND(((RETENTION_COHORT_30DAY * 100) / TOTAL_USERS)), "%") AS DAY_30_RETEN_COHORT
FROM CTE3
;

"""
  Output =>
  +-------------+-------------+--------------------+--------------------+---------------------+
  | signup_date | TOTAL_USERS | DAY_1_RETEN_COHORT | DAY_7_RETEN_COHORT | DAY_30_RETEN_COHORT |
  +-------------+-------------+--------------------+--------------------+---------------------+
  | 2026-01-01  |           4 | 75%                | 50%                | 25%                 |
  +-------------+-------------+--------------------+--------------------+---------------------+

"""








