"""
    Q.Find the second most recent record per user.
"""

CREATE TABLE user_activity (
    activity_id INT PRIMARY KEY,
    user_id INT,
    activity_name VARCHAR(50),
    activity_time DATETIME
);

INSERT INTO user_activity VALUES 
(1, 101, 'Login', '2026-01-10 08:00:00'),
(2, 101, 'View Product', '2026-01-11 09:30:00'), 
(3, 101, 'Purchase', '2026-01-11 10:00:00'),     
(4, 102, 'Login', '2026-01-08 14:00:00'),        
(5, 102, 'Logout', '2026-01-09 15:00:00'),       
(6, 103, 'Login', '2026-01-11 12:00:00');        

SELECT 
  * 
FROM user_activity ;

WITH CTE1 AS (
  SELECT 
    activity_id,
    user_id,
    activity_name,
    activity_time,
    DENSE_RANK() OVER(PARTITION BY user_id ORDER BY activity_time DESC ) AS RECENT_ACTIVITY_RANK
  FROM user_activity
)

SELECT 
  user_id,
  activity_name,
  activity_time
FROM CTE1 
where RECENT_ACTIVITY_RANK = 2 ;

"""
  Output =>
  +---------+---------------+---------------------+
  | user_id | activity_name | activity_time       |
  +---------+---------------+---------------------+
  |     101 | View Product  | 2026-01-11 09:30:00 |
  |     102 | Login         | 2026-01-08 14:00:00 |
  +---------+---------------+---------------------+
  
"""

