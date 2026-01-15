"""
      Q.Find sessions overlapping in time.
"""

CREATE TABLE user_sessions (
    session_id INT PRIMARY KEY,
    user_id INT,
    start_time DATETIME,
    end_time DATETIME
);

INSERT INTO user_sessions VALUES 
(1, 101, '2026-01-15 10:00:00', '2026-01-15 11:00:00'),
(2, 101, '2026-01-15 10:30:00', '2026-01-15 11:30:00'),
(3, 102, '2026-01-15 12:00:00', '2026-01-15 13:00:00'),
(4, 102, '2026-01-15 13:00:00', '2026-01-15 14:00:00'),
(5, 103, '2026-01-15 15:00:00', '2026-01-15 16:00:00'),
(6, 103, '2026-01-15 17:00:00', '2026-01-15 18:00:00');

SELECT * FROM user_sessions ;

WITH CTE1 AS (
  SELECT 
    session_id,
    user_id,
    CAST(start_time AS DATE ) SESSION_SCHEDULED_DATE,
    TIME(start_time) AS SESSION_START_TIME,
    TIME(end_time) AS SESSION_END_TIME
  FROM user_sessions
)


SELECT 
  A.user_id,
  A.SESSION_SCHEDULED_DATE,
  A.SESSION_START_TIME,
  B.SESSION_START_TIME AS NEXT_SESSION_START
FROM 
  CTE1 AS A 
LEFT JOIN 
  CTE1 AS B 
ON 
  A.user_id = B.user_id
AND 
  A.session_id < B.session_id
WHERE
    A.SESSION_START_TIME < B.SESSION_END_TIME
AND B.SESSION_START_TIME < A.SESSION_END_TIME
;

"""
    Output =>
    +---------+------------------------+--------------------+--------------------+
    | user_id | SESSION_SCHEDULED_DATE | SESSION_START_TIME | NEXT_SESSION_START |
    +---------+------------------------+--------------------+--------------------+
    |     101 | 2026-01-15             | 10:00:00           | 10:30:00           |
    +---------+------------------------+--------------------+--------------------+
"""
