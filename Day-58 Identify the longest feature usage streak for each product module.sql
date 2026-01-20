"""
  Q.Identify the longest feature usage streak for each product module.

Business Case : 
  To find the longest consecutive usage streak per product module, we need to track daily interactions 
  and identify 'islands' of consecutive dates.

  This is essentially the same "Gaps and Islands" logic we used for user logins, but now we partition by
  the module name to see which features are the most 'addictive.'

"""

CREATE TABLE feature_usage (
    usage_id INT PRIMARY KEY,
    module_name VARCHAR(50),
    user_id INT,
    usage_date DATE
);

INSERT INTO feature_usage (usage_id, module_name, user_id, usage_date) VALUES 
(1, 'Dashboard', 101, '2026-01-01'),
(2, 'Dashboard', 102, '2026-01-02'),
(3, 'Dashboard', 103, '2026-01-03'),
(4, 'Dashboard', 101, '2026-01-04'),
(5, 'Reports', 201, '2026-01-01'),
(6, 'Reports', 202, '2026-01-02'),
(7, 'Reports', 201, '2026-01-05'), 
(8, 'Analytics', 301, '2026-01-01'),
(9, 'Analytics', 302, '2026-01-02');

SELECT * FROM feature_usage ;

WITH CTE1 AS (
    SELECT 
      usage_id,
      module_name,
      user_id,
      usage_date,
      LAG(usage_date) OVER(partition BY module_name ORDER BY usage_date) AS LAST_FEATURE_USAGE
    FROM feature_usage )
, CTE2 AS (
SELECT 
  *,
  CASE 
    WHEN  DATEDIFF(usage_date, LAST_FEATURE_USAGE) = 1 OR 
          DATEDIFF(usage_date, LAST_FEATURE_USAGE) IS NULL 
          THEN 0 
          ELSE 1
    END AS LENGTH
FROM CTE1
)

SELECT 
  module_name,
  MIN(usage_date) AS START_DATE,
  MAX(usage_date) AS END_DATE,
  COUNT(usage_id) AS TOTAL_CONSICUTIVE_USE
FROM (
        SELECT 
          *,
          SUM(LENGTH)OVER(partition BY module_name ORDER BY usage_date) AS STREAK_ID
        FROM CTE2 
      ) AS TABLE_1
GROUP BY 
    module_name, 
    STREAK_ID
ORDER BY 
  COUNT(usage_id) DESC 
LIMIT 1 ;

-- FOR BETTER OUTPUT WE CAN USE HERE RANK FUNCTION TO ASSIGN A RANK AND FILTER THOSE RANK FOR TOP.
"""
  Output =>
  +-------------+------------+------------+----------------------+
  | module_name | START_DATE | END_DATE   |TOTAL_CONSICUTIVE_USE |
  +-------------+------------+------------+----------------------+
  | Dashboard   | 2026-01-01 | 2026-01-04 |                    4 | 
  +-------------+------------+------------+----------------------+

"""



