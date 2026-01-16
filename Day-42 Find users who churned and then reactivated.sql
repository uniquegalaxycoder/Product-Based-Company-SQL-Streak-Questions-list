"""
    Q.Find users who churned and then reactivated.

 CASE :
      Identifying 'Reactivated' users is a key part of Retention Analysis. 
      A reactivated user is someone who was active in Month A, disappeared (churned) in Month B, 
      and returned in Month C.

"""


CREATE TABLE monthly_activity (
    user_id INT,
    activity_month DATE
);

INSERT INTO monthly_activity VALUES 
(101, '2026-01-01'), (101, '2026-02-01'), (101, '2026-03-01'),
(102, '2026-01-01'), (102, '2026-03-01'),
(103, '2026-01-01');

SELECT * FROM monthly_activity ;

WITH CTE1 AS (
    SELECT 
      user_id,
      activity_month,
      LAG(activity_month)OVER(PARTITION BY user_id ORDER BY activity_month) AS PREVIOUS_MONTH 
    FROM monthly_activity
)

, CTE2 AS (
SELECT 
  * ,
  TIMESTAMPDIFF(MONTH, PREVIOUS_MONTH, activity_month) AS MOTHS_AWAY
FROM CTE1
)

SELECT 
  * 
FROM CTE2 
WHERE PREVIOUS_MONTH IS NOT NULL
AND activity_month > DATE_ADD(PREVIOUS_MONTH, INTERVAL 1 MONTH);

"""
  Output =>
    +---------+----------------+----------------+------------+
    | user_id | activity_month | PREVIOUS_MONTH | MOTHS_AWAY |
    +---------+----------------+----------------+------------+
    |     102 | 2026-03-01     | 2026-01-01     |          2 |
    +---------+----------------+----------------+------------+
"""



