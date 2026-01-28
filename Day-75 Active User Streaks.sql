"""
  Q.Active User Streaks: Given a table of user logins, find users who logged in for 3 or more consecutive days.
  
"""

-- Create the Logins table
CREATE TABLE user_logins (
    user_id INT,
    login_date DATE
);

-- Insert sample data
INSERT INTO user_logins (user_id, login_date) VALUES
(1, '2024-01-01'), (1, '2024-01-02'), (1, '2024-01-03'), 
(1, '2024-01-05'), (2, '2024-01-01'), (2, '2024-01-02'),                 
(3, '2024-01-10'), (3, '2024-01-11'), (3, '2024-01-12'), 
(3, '2024-01-13'), (4, '2024-01-01'), (4, '2024-01-03'),
(4, '2024-01-05'); 

select * from user_logins  ;

WITH CTE1 AS (
    SELECT 
      user_id,
      login_date,
      LAG(login_date) OVER(partition BY user_id ORDER BY login_date) AS PREVIOUS_DATE
    FROM user_logins
)

, CTE2 AS (
SELECT 
  * ,
  CASE 
    WHEN DATEDIFF(login_date, PREVIOUS_DATE) = 1 OR DATEDIFF(login_date, PREVIOUS_DATE)  IS NULL 
      THEN 0 
      ELSE 1 
    END AS IS_GAP 
FROM CTE1
) 

, CTE3 AS (
SELECT 
  user_id,
  MIN(login_date) AS START_DATE,
  MAX(login_date) AS END_DATE,
  COUNT(*) AS TOTAL_DAYS
FROM (
SELECT 
  *,
  SUM(IS_GAP) OVER(partition BY user_id ORDER BY login_date) AS STREAK_ID 
FROM CTE2 
) AS TABLE_1 
WHERE IS_GAP = 0 
GROUP BY user_id, STREAK_ID 
)

SELECT 
  *
FROM CTE3
WHERE TOTAL_DAYS >= 3;

"""
  Output =>
  +---------+------------+------------+------------+
  | user_id | START_DATE | END_DATE   | TOTAL_DAYS |
  +---------+------------+------------+------------+
  |       1 | 2024-01-01 | 2024-01-03 |          3 |
  |       3 | 2024-01-10 | 2024-01-13 |          4 |
  +---------+------------+------------+------------+
  
  """
