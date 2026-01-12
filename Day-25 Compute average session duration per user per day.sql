"""
  Q.Compute average session duration per user per day.
"""
  
CREATE TABLE user_logs (
    log_id INT PRIMARY KEY,
    user_id INT,
    action_type VARCHAR(10), 
    event_time DATETIME
);

INSERT INTO user_logs (log_id, user_id, action_type, event_time) VALUES 
(1, 101, 'Login',  '2026-01-10 08:00:00'),
(2, 101, 'Logout', '2026-01-10 08:10:00'),
(3, 101, 'Login',  '2026-01-10 12:00:00'),
(4, 101, 'Logout', '2026-01-10 12:20:00'),
(5, 102, 'Login',  '2026-01-10 09:00:00'),
(6, 102, 'Logout', '2026-01-10 10:00:00'),
(7, 101, 'Login',  '2026-01-11 08:00:00'),
(8, 101, 'Logout', '2026-01-11 08:30:00');

SELECT * FROM user_logs ;

WITH CTE1 AS (
  SELECT 
    log_id,
    user_id,
    action_type,
    CAST(event_time AS DATE ) AS EVENT_DATE,
    TIME(event_time) AS LOGIN_TIME,
    TIME(LEAD(EVENT_TIME) OVER(PARTITION BY user_id ORDER BY EVENT_TIME)) AS LOGOUT_TIME
  FROM user_logs 
)

, CTE2 AS (
SELECT 
  * ,
  TIMESTAMPDIFF(MINUTE, LOGIN_TIME, LOGOUT_TIME) AS TIMEDEIFFERENCE
FROM CTE1
WHERE action_type = 'Login'
)

SELECT 
  user_id,
  EVENT_DATE,
  ROUND(AVG(TIMEDEIFFERENCE)) AS "AVG DURATION"
FROM CTE2
GROUP BY user_id, EVENT_DATE ;


"""
  Output =>

  +---------+------------+--------------+
  | user_id | EVENT_DATE | AVG DURATION |
  +---------+------------+--------------+
  |     101 | 2026-01-10 |           15 |
  |     101 | 2026-01-11 |           30 |
  |     102 | 2026-01-10 |           60 |
  +---------+------------+--------------+
  """
