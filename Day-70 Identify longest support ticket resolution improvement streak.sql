
"""
    Q.Identify longest support ticket resolution improvement streak.

   BUSINESS CASE :
       To identify a Support Ticket Resolution Improvement Streak, we are looking for a 
       sequence of days where the Average Resolution Time (ART) for tickets decreased compared to
       the previous day. This is a key "Efficiency" metric for Support Ops.

"""


CREATE TABLE support_tickets (
    ticket_id INT PRIMARY KEY,
    agent_name VARCHAR(50),
    category VARCHAR(50), -- e.g., 'Technical', 'Billing'
    resolution_time_minutes INT,
    resolved_date DATE
);

INSERT INTO support_tickets (ticket_id, agent_name, category, resolution_time_minutes, resolved_date) VALUES 
(1, 'Sarah', 'Technical', 65, '2026-01-01'),
(2, 'Sarah', 'Technical', 55, '2026-01-01'), 
(3, 'Sarah', 'Technical', 50, '2026-01-02'), 
(4, 'Sarah', 'Technical', 40, '2026-01-03'), 
(5, 'Sarah', 'Technical', 30, '2026-01-04'), 
(6, 'Sarah', 'Technical', 45, '2026-01-05'), 
(7, 'Mike', 'Billing', 20, '2026-01-01'),
(8, 'Mike', 'Billing', 25, '2026-01-02'), 
(9, 'Mike', 'Billing', 15, '2026-01-03'); 


SELECT * FROM support_tickets ;

WITH CTE1 AS (
    SELECT  
      category,
      resolved_date,
      AVG(resolution_time_minutes) AS AVG_RESOLVATION_TIME
    FROM support_tickets
    GROUP BY category, resolved_date
)
, CTE2 AS (
    select 
      *,
      lag(resolved_date) over(partition by category order by resolved_date) as previous_date,
      lag(AVG_RESOLVATION_TIME) over(partition by category order by resolved_date) as previous_time
    from cte1 
)

, CTE3 AS (
    SELECT 
      *,
      CASE 
        WHEN  DATEDIFF(resolved_date, previous_date) = 1 AND 
              AVG_RESOLVATION_TIME < previous_time 
            THEN 0 
            ELSE 1 
      END AS IS_GAP 
    FROM CTE2
)  

, CTE4 AS (
SELECT 
  category,
  MIN(resolved_date) AS START_DATE,
  MAX(resolved_date) AS END_DATE,
  COUNT(*)+1 AS TOTAL_DAYS
FROM (
SELECT 
  *,
  SUM(IS_GAP) OVER(partition BY category ORDER BY resolved_date) AS STREAK_ID 
FROM CTE3 ) AS TABLE_1 
WHERE IS_GAP = 0 
GROUP BY category , STREAK_ID 
)

SELECT 
  category,
  START_DATE,
  END_DATE,
  TOTAL_DAYS
FROM (
SELECT 
  *,
  RANK()OVER(partition BY category ORDER BY TOTAL_DAYS DESC) AS RANKS 
FROM CTE4 ) AS TABLE_2 
WHERE RANKS = 1 ;

"""
Output =>

  +-----------+------------+------------+------------+
  | category  | START_DATE | END_DATE   | TOTAL_DAYS |
  +-----------+------------+------------+------------+
  | Billing   | 2026-01-03 | 2026-01-03 |          2 |
  | Technical | 2026-01-02 | 2026-01-04 |          4 |
  +-----------+------------+------------+------------+
  
"""







