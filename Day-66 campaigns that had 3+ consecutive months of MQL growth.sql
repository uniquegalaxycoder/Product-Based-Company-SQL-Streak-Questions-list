"""
    Q.Identify campaigns that had 3+ consecutive months of MQL growth.( Marketing Qualified Leads)
"""

CREATE TABLE marketing_leads (
    lead_id INT PRIMARY KEY,
    campaign_name VARCHAR(50),
    is_mql INT,
    created_at DATE
);

INSERT INTO marketing_leads (lead_id, campaign_name, is_mql, created_at) VALUES 
(1, 'Alpha', 1, '2025-10-01'), (2, 'Alpha', 1, '2025-10-15'),
(3, 'Alpha', 1, '2025-11-05'), (4, 'Alpha', 1, '2025-11-10'), (5, 'Alpha', 1, '2025-11-20'), 
(6, 'Alpha', 1, '2025-12-01'), (7, 'Alpha', 1, '2025-12-05'), (8, 'Alpha', 1, '2025-12-10'), 
(9, 'Alpha', 1, '2025-12-15'), (10, 'Alpha', 1, '2026-01-01'), (11, 'Alpha', 1, '2026-01-05'),
(12, 'Alpha', 1, '2026-01-10'), (13, 'Alpha', 1, '2026-01-15'), (14, 'Alpha', 1, '2026-01-20'),
(15, 'Beta', 1, '2025-10-01'), (16, 'Beta', 1, '2025-11-01'), (17, 'Beta', 1, '2025-12-01');

SELECT * FROM marketing_leads ;

WITH CTE1 AS (
  SELECT 
    campaign_name,
    DATE_FORMAT(created_at, '%Y-%m-01') AS MONTHS,
    COUNT(is_mql) AS TOTAL_MQL 
  FROM marketing_leads
  GROUP BY 
      campaign_name,
      DATE_FORMAT(created_at, '%Y-%m-01')
  ORDER BY DATE_FORMAT(created_at, '%Y-%m-01') ASC 
)







,CTE2 AS (
  SELECT 
    * ,
    LAG(MONTHS)OVER(partition BY campaign_name ORDER BY MONTHS ) AS PREVIOUS_MONTH,
    LAG(TOTAL_MQL) OVER(partition BY campaign_name ORDER BY MONTHS ) AS PREVIOUS_MQL
  FROM CTE1
)
, CTE3 AS (
  SELECT 
    * ,
    TIMESTAMPDIFF(MONTH, PREVIOUS_MONTH, MONTHS),
    CASE 
      WHEN  TIMESTAMPDIFF(MONTH, PREVIOUS_MONTH, MONTHS) = 1 AND 
            TOTAL_MQL > PREVIOUS_MQL 
          THEN 0 
          ELSE 1 
        END AS IS_GAP
  FROM CTE2 )
SELECT 
  campaign_name,
  MIN(MONTHS) AS STARTED,
  MAX(MONTHS) AS ENDED,
  COUNT(*) AS TT 
FROM (
SELECT 
  *,
  SUM(IS_GAP) OVER(partition BY campaign_name ORDER BY MONTHS) AS STREAK_ID
FROM CTE3
) AS TABLE_1 
WHERE IS_GAP = 0
GROUP BY campaign_name, STREAK_ID 
HAVING COUNT(*) >= 3;

"""
  Output =>
    +---------------+------------+------------+----+
    | campaign_name | STARTED    | ENDED      | TT |
    +---------------+------------+------------+----+
    | Alpha         | 2025-11-01 | 2026-01-01 |  3 | 
    +---------------+------------+------------+----+

"""
