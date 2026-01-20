"""
    Q.Detect the longest streak where users added items to cart but did not purchase.
  
  BUSINESS CASE 
     To detect an Abandoned Cart Streak, we need to identify consecutive days where a user performed 
     an 'Add to Cart' action but had zero 'Purchase' actions.
"""

CREATE TABLE user_activity (
    activity_id INT PRIMARY KEY,
    user_id INT,
    event_type VARCHAR(20), 
    event_date DATE
);

INSERT INTO user_activity (activity_id, user_id, event_type, event_date) VALUES 
(1, 1, 'add_to_cart', '2026-01-01'),
(2, 1, 'add_to_cart', '2026-01-02'),
(3, 1, 'add_to_cart', '2026-01-03'),
(4, 1, 'add_to_cart', '2026-01-04'),
(5, 2, 'add_to_cart', '2026-01-01'),
(6, 2, 'purchase',    '2026-01-01'),
(7, 2, 'add_to_cart', '2026-01-02'),
(8, 2, 'add_to_cart', '2026-01-03'),
(9, 3, 'add_to_cart', '2026-01-01'),
(10, 3, 'add_to_cart', '2026-01-02'),
(11, 3, 'add_to_cart', '2026-01-03'),
(12, 3, 'purchase',    '2026-01-03');

SELECT * FROM user_activity ;

WITH CTE1 AS (
    SELECT 
      A.user_id,
      A.event_date
    FROM 
      user_activity AS A
    WHERE 
      A.event_type = 'add_to_cart'
      AND 
        NOT exists ( SELECT 1 
                        FROM user_activity AS B 
                        WHERE A.user_id = B.user_id 
                        AND B.event_type = 'purchase'
                        AND A.event_DATE = B.event_date 
                      ) 
)

, CTE2 AS (
    SELECT
      *,
      LAG(event_date) OVER(partition BY user_id ORDER BY event_date) AS PREVIOUS_EVENT_DATE
    FROM CTE1 
)

, CTE3 AS (
SELECT 
  * ,
  CASE
      WHEN  DATEDIFF(event_date, PREVIOUS_EVENT_DATE) = 1 
            THEN 0
            ELSE 1 
      END AS LENGTH
FROM CTE2
)

, CTE4 AS (
      SELECT 
        *,
        SUM(LENGTH) OVER(partition BY user_id ORDER BY event_date) AS STREAK_ID 
      FROM CTE3 
)

SELECT 
  user_id,
  MIN(event_date) AS "START DATE",
  MAX(event_date) AS "END DATE",
  COUNT(*) AS "TOTAL STREAK" 
FROM CTE4 
GROUP BY 
    user_id,
    STREAK_ID
;

"""
  Output =>
  +---------+------------+------------+--------------+
  | user_id | START DATE | END DATE   | TOTAL STREAK |
  +---------+------------+------------+--------------+
  |       1 | 2026-01-01 | 2026-01-04 |            4 |
  |       2 | 2026-01-02 | 2026-01-03 |            2 |
  |       3 | 2026-01-01 | 2026-01-02 |            2 |
  +---------+------------+------------+--------------+
"""


