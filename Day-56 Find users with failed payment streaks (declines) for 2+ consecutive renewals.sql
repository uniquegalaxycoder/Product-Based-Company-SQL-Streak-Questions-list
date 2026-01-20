"""
    Q.Find users with failed payment streaks (declines) for 2+ consecutive renewals.
"""

CREATE TABLE renewals (
    renewal_id INT PRIMARY KEY,
    user_id INT,
    renewal_date DATE,
    status VARCHAR(10) 
);

INSERT INTO renewals (renewal_id, user_id, renewal_date, status) VALUES 
(1, 1, '2025-11-01', 'Declined'),
(2, 1, '2025-12-01', 'Declined'),
(3, 1, '2026-01-01', 'Declined'),
(4, 2, '2025-11-15', 'Declined'),
(5, 2, '2025-12-15', 'Success'),
(6, 2, '2026-01-15', 'Declined'),
(7, 3, '2026-01-20', 'Declined'),
(8, 4, '2025-11-05', 'Declined'),
(9, 4, '2025-12-05', 'Declined'),
(10, 4, '2026-01-05', 'Success');

SELECT * FROM renewals ;

WITH CTE1 AS (
    SELECT 
      renewal_id,
      user_id,
      renewal_date,
      status,
      LAG(renewal_date) OVER(PARTITION BY user_id ORDER BY renewal_date) AS LAST_RENWAL_DATE,
      LAG(status) OVER(PARTITION BY user_id ORDER BY renewal_date) AS LAST_STATUS
    FROM renewals
)





, CTE2 AS (
SELECT 
  user_id,
  renewal_id,
  renewal_date,
  status,
  LAST_RENWAL_DATE, 
  LAST_STATUS,
  SUM(LENGTH) OVER(PARTITION BY user_id ORDER BY renewal_date ) AS STREAK_ID 
FROM (
        SELECT 
          *,
          CASE WHEN status = LAST_STATUS OR LAST_STATUS IS NULL 
                THEN 0 
                ELSE 1 
          END AS LENGTH 
        FROM CTE1
      ) AS T 
)

SELECT 
  user_id,
  MIN(renewal_date) AS "START DATE",
  MAX(renewal_date) AS "END DATE",
  COUNT(renewal_id) AS "TOTAL TRANS. FAILD"
FROM CTE2 
WHERE status = "Declined"
GROUP BY user_id, STREAK_ID
HAVING COUNT(renewal_id) >= 2;

"""
  Output =>
    +---------+------------+------------+--------------------+
    | user_id | START DATE | END DATE   | TOTAL TRANS. FAILD |
    +---------+------------+------------+--------------------+
    |       1 | 2025-11-01 | 2026-01-01 |                  3 |
    |       4 | 2025-11-05 | 2025-12-05 |                  2 |
    +---------+------------+------------+--------------------+
"""
