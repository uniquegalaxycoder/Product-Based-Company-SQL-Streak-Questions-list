"""
  Q.Find locations where CPL (cost per lead) improved for 6+ days straight.
"""

CREATE TABLE lead_generation_data (
    location_id VARCHAR(50),
    spend DECIMAL(10, 2),
    leads INT,
    report_date DATE
);

INSERT INTO lead_generation_data (location_id, spend, leads, report_date) VALUES 
('NYC', 1000, 100, '2026-01-01'), 
('NYC', 1000, 111, '2026-01-02'), 
('NYC', 1000, 125, '2026-01-03'), 
('NYC', 1000, 143, '2026-01-04'), 
('NYC', 1000, 167, '2026-01-05'), 
('NYC', 1000, 200, '2026-01-06'), 
('NYC', 1000, 250, '2026-01-07'), 
('LDN', 500, 50, '2026-01-01'),  
('LDN', 500, 62, '2026-01-02'),  
('LDN', 500, 83, '2026-01-03'),  
('LDN', 500, 40, '2026-01-04');  

SELECT * FROM lead_generation_data ;


WITH CTE1 AS (
    SELECT 
      location_id,
      report_date,
      spend,
      leads,
      ROUND((leads / spend)*100,2) AS CPL 
    FROM lead_generation_data
)

, CTE2 AS (
    SELECT 
      *,
      LAG(report_date)OVER(PARTITION BY location_id ORDER BY report_date ) AS PREVIOUS_DATE,
      LAG(CPL)OVER(PARTITION BY location_id ORDER BY report_date ) AS PREVIOUS_CPL 
    FROM CTE1
)

, CTE3 AS (
    SELECT 
      *,
      CASE 
        WHEN  DATEDIFF(report_date, PREVIOUS_DATE) = 1 AND 
              CPL > PREVIOUS_CPL 
            THEN 0 
            ELSE 1 
        END AS IS_GAP
    FROM CTE2 
)

, CTE4 AS (
SELECT 
  location_id,
  COUNT(*) AS "TOTAL CONSECUTIVE DAY" 
FROM (
SELECT 
  *,
  SUM(IS_GAP) OVER(PARTITION BY location_id ORDER BY report_date ) AS STREAK_ID
FROM CTE3 
) AS TABLE_1 
GROUP BY location_id, STREAK_ID
HAVING COUNT(*) >= 6
)

SELECT * FROM CTE4 ;

"""
  Output =>

    +-------------+-----------------------+
    | location_id | TOTAL CONSECUTIVE DAY |
    +-------------+-----------------------+
    | NYC         |                     7 |
    +-------------+-----------------------+
"""
