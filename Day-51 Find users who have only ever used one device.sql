"""
    Q.Find users who have only ever used one device.
"""

CREATE TABLE user_logins (
    login_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    device_id VARCHAR(50),
    login_time DATETIME
);

INSERT INTO user_logins (user_id, device_id, login_time) VALUES 
(1, 'LAPTOP_A', '2026-01-10 08:00:00'),
(1, 'LAPTOP_A', '2026-01-11 09:00:00'), 
(2, 'PHONE_B', '2026-01-12 10:00:00'),
(2, 'TABLET_C', '2026-01-13 11:00:00'), 
(3, 'DESKTOP_D', '2026-01-14 12:00:00');

SELECT * FROM user_logins ;

WITH CTE1 AS (
  SELECT 
    user_id,
    COUNT(DISTINCT device_id) AS TOTAL_UNIQUE_DEVICE_USED
  FROM user_logins
  GROUP BY user_id
  HAVING COUNT(DISTINCT device_id) = 1
)

SELECT 
  DISTINCT device_id,
  user_id
FROM user_logins
WHERE user_id IN (SELECT user_id FROM CTE1); 

"""
  Output =>
    +-----------+---------+
    | device_id | user_id |
    +-----------+---------+
    | LAPTOP_A  |       1 |
    | DESKTOP_D |       3 |
    +-----------+---------+

"""
