"""
    Q.Detect a streak where social engagement (likes+shares) dropped for 5+ days platform wise.

   BUSINESS CASE :
       To detect a Social Engagement Drop Streak, we need to calculate the sum of daily 
       interactions and identify sequences where this total decreases strictly for at least 5 consecutive days.
"""
  
CREATE TABLE social_engagement_logs (
    log_id INT PRIMARY KEY,
    handle_name VARCHAR(50), 
    platform VARCHAR(20),    
    likes INT,
    shares INT,
    report_date DATE
);

INSERT INTO social_engagement_logs (log_id, handle_name, platform, likes, shares, report_date) VALUES 
(1, '@Global_Tech', 'Instagram', 400, 100, '2026-01-01'), 
(2, '@Global_Tech', 'Instagram', 350, 50,  '2026-01-02'), 
(3, '@Global_Tech', 'Instagram', 250, 50,  '2026-01-03'), 
(4, '@Global_Tech', 'Instagram', 180, 20,  '2026-01-04'), 
(5, '@Global_Tech', 'Instagram', 90,  10,  '2026-01-05'), 
(6, '@Global_Tech', 'Instagram', 45,  5,   '2026-01-06'), 
(7, '@Travel_Daily', 'Twitter', 1000, 200, '2026-01-01'), 
(8, '@Travel_Daily', 'Twitter', 800, 100,  '2026-01-02'), 
(9, '@Travel_Daily', 'Twitter', 500, 50,   '2026-01-03'), 
(10, '@Travel_Daily', 'Twitter', 2000, 500, '2026-01-04'); 

SELECT * FROM social_engagement_logs ;

WITH CTE1 AS (
    SELECT
      platform,
      report_date,
      (LIKES + shares ) AS Engagement,
      LAG(report_date) OVER(partition BY platform ORDER BY report_date) AS PREVIOUS_DATE,
      LAG((LIKES + shares)) OVER(partition BY platform ORDER BY report_date) AS PREVIOUS_ENGAGEMENT
    FROM social_engagement_logs
)

,CTE2 AS ( 
    SELECT
      * ,
      CASE 
        WHEN DATEDIFF(report_date, PREVIOUS_DATE) = 1 AND 
              Engagement < PREVIOUS_ENGAGEMENT
            THEN 0 
            ELSE 1 
        END AS IS_GAP
    FROM CTE1
)

SELECT 
  platform,
  MIN(report_date) AS "STARTED DATE",
  MAX(report_date) AS "ENDED DATE",
  COUNT(*) AS TOTAL 
FROM (
SELECT 
  *,
  SUM(IS_GAP) OVER(partition BY platform ORDER BY report_date) AS STREAK_ID 
FROM CTE2 
) AS TABLE_1 
WHERE IS_GAP = 0 
GROUP BY platform ;

"""
  Output =>

+-----------+--------------+------------+-------+
| platform  | STARTED DATE | ENDED DATE | TOTAL |
+-----------+--------------+------------+-------+
| Instagram | 2026-01-02   | 2026-01-06 |     5 |
| Twitter   | 2026-01-02   | 2026-01-03 |     2 |
+-----------+--------------+------------+-------+

"""
