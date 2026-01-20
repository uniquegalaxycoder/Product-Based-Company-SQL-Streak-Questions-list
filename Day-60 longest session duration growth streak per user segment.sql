"""
    Q.Identify the longest session duration growth streak per usersegment.

BUSINESS CASE :
   To find the longest streak of session duration growth per user segment, we need to track if 
   a user's average session time is increasing day-over-day and then group those "islands" of growth.

"""

CREATE TABLE user_sessions (
    session_id INT PRIMARY KEY,
    user_id INT,
    segment VARCHAR(20),
    session_date DATE,
    duration_minutes INT
);

INSERT INTO user_sessions (session_id, user_id, segment, session_date, duration_minutes) VALUES 
(1, 101, 'Enterprise', '2026-01-01', 10),
(2, 101, 'Enterprise', '2026-01-02', 20),
(3, 101, 'Enterprise', '2026-01-03', 30),
(4, 101, 'Enterprise', '2026-01-04', 40),
(5, 201, 'Premium', '2026-01-01', 15),
(6, 201, 'Premium', '2026-01-02', 25),
(7, 201, 'Premium', '2026-01-03', 35),
(8, 201, 'Premium', '2026-01-04', 5), 
(9, 301, 'Free', '2026-01-01', 5),
(10, 301, 'Free', '2026-01-02', 12);

SELECT * FROM user_sessions ;

WITH CTE1 AS (
  SELECT 
    segment,
    session_date,
    avg(duration_minutes) as avg_duration
  FROM user_sessions
  group by 
    segment,
    session_date
)
, cte2 as (
      select 
        *,
        lag(session_date)over(partition by segment order by session_date) as previous_date,
        lag(avg_duration)over(partition by segment order by session_date) as previous_duration_minutes
      from cte1 
)
, cte3 as (
select 
  * ,
  case 
    when  datediff(session_date, previous_date) = 1 AND 
          avg_duration > previous_duration_minutes 
        THEN 0 
        ELSE 1 
    END AS LENGTH
from cte2 
)

SELECT 
  segment,
  MIN(session_date) AS START_DATE,
  MAX(session_date) AS END_DATE,
  COUNT(*) AS TOTAL_DAY_GROWING
FROM (
      SELECT 
        *,
        SUM(LENGTH)OVER(partition BY segment ORDER BY session_date) AS STREAK_ID
      FROM CTE3
    ) AS ST
WHERE LENGTH = 0 
GROUP BY segment, STREAK_ID
ORDER BY COUNT(*) DESC ;

"""
  Output =>
  +------------+------------+------------+-------------------+
  | segment    | START_DATE | END_DATE   | TOTAL_DAY_GROWING |
  +------------+------------+------------+-------------------+
  | Enterprise | 2026-01-02 | 2026-01-04 |                 3 |
  | Premium    | 2026-01-02 | 2026-01-03 |                 2 |
  | Free       | 2026-01-02 | 2026-01-02 |                 1 | 
  +------------+------------+------------+-------------------+

"""
