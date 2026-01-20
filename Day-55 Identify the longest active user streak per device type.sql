"""
    Q.Identify the longest active user streak per device type (mobile/web).
"""

CREATE TABLE user_logins (
    login_id INT PRIMARY KEY,
    user_id INT,
    device_type VARCHAR(10), 
    login_date DATE
);

INSERT INTO user_logins (login_id, user_id, device_type, login_date) VALUES 
(1, 1, 'mobile', '2026-01-01'),
(2, 1, 'mobile', '2026-01-02'),
(3, 1, 'mobile', '2026-01-03'),
(4, 2, 'web', '2026-01-01'),
(5, 2, 'web', '2026-01-02'),
(6, 2, 'web', '2026-01-05'), 
(7, 3, 'mobile', '2026-01-10'),
(8, 3, 'mobile', '2026-01-11');

select * from user_logins ;

WITH CTE1 AS(
    SELECT 
      login_id,
      user_id,
      device_type,
      login_date,
      LAG(login_date)OVER(partition BY user_id ORDER BY login_date) AS PREVIOUS_LOGIN_DATE 
    FROM user_logins
)
, CTE2 AS ( 
SELECT 
  *,
  CASE WHEN DATEDIFF(login_date, PREVIOUS_LOGIN_DATE) = 1 OR
            DATEDIFF(login_date, PREVIOUS_LOGIN_DATE) IS NULL 
            THEN 0 
            ELSE 1 
  END AS DATEDIFFS 
FROM CTE1
)
, CTE3 AS (
SELECT 
  device_type,
  user_id,
  MIN(login_date) AS STREAK_START,
  MAX(login_date) AS STREAK_END,
  count(STREAK_ID) AS TOTAL_STREAK_DAY
FROM (
SELECT 
  * ,
  SUM(DATEDIFFS)OVER(partition BY user_id, device_type ORDER BY login_date) AS STREAK_ID
FROM CTE2
) AS T 
WHERE STREAK_ID = 0 
GROUP BY device_type, user_id, STREAK_ID
)

SELECT 
  DEVICE_TYPE,
  user_id,
  STREAK_START,
  STREAK_END,
  TOTAL_STREAK_DAY
FROM (
SELECT 
  *,
  RANK()OVER(partition BY device_type ORDER BY TOTAL_STREAK_DAY DESC ) AS RANKS
FROM 
  CTE3
) AS TT
WHERE RANKS = 1 ;

"""
Output =>

    +-------------+---------+--------------+------------+------------------+
    | DEVICE_TYPE | user_id | STREAK_START | STREAK_END | TOTAL_STREAK_DAY |
    +-------------+---------+--------------+------------+------------------+
    | mobile      |       1 | 2026-01-01   | 2026-01-03 |                3 |
    | web         |       2 | 2026-01-01   | 2026-01-02 |                2 |
    +-------------+---------+--------------+------------+------------------+
"""
