"""
  Find users active at least X times every week.
  X >= 3 & ATLEAST 3 weekS
"""

  
CREATE TABLE activity_log (
    user_id INT,
    activity_date DATE
);

INSERT INTO activity_log (user_id, activity_date) VALUES 
(101, '2026-01-04'), (101, '2026-01-05'), (101, '2026-01-06'), (101, '2026-01-07'),
(101, '2026-01-11'), (101, '2026-01-12'), (101, '2026-01-13'),
(102, '2026-01-04'), (102, '2026-01-05'), (102, '2026-01-06'), (102, '2026-01-07'), (102, '2026-01-08'),
(102, '2026-01-11'),
(103, '2026-01-05'), (103, '2026-01-12');

SELECT * FROM activity_log ;

WITH CTE1 AS (
    SELECT 
      user_id,
      DAYOFWEEK(activity_date) AS weekS,
      COUNT(user_id) AS TOTAL_ACTIVE
    FROM activity_log
    GROUP BY user_id, DAYOFWEEK(activity_date) 
)

SELECT 
  user_id
FROM CTE1
WHERE TOTAL_ACTIVE >= 2
GROUP BY user_id
HAVING COUNT(weekS) >= 3;

"""
  Output =>
  +---------+
  | user_id |
  +---------+
  |     101 |
  +---------+
  """
