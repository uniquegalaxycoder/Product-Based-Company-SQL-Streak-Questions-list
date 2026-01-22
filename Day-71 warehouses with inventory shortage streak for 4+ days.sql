"""
    Q.Find warehouses with inventory shortage streak for 4+ days.

   BUSINESS CASE :
       In supply chain analytics, an Inventory Shortage Streak occurs when the stock level of a 
       high-demand item falls below a specific Reorder Point (ROP) for several consecutive days.
       This helps managers identify where the supply chain is failing to replenish fast enough.

"""

CREATE TABLE warehouse_inventory (
    log_id INT PRIMARY KEY,
    warehouse_name VARCHAR(50),
    product_id VARCHAR(20),
    current_inventory INT,
    reorder_level INT, 
    report_date DATE
);

INSERT INTO warehouse_inventory (log_id, warehouse_name, product_id, current_inventory,
reorder_level, report_date) VALUES 
(1, 'Dallas', 'PROD_01', 90, 100, '2026-01-10'), 
(2, 'Dallas', 'PROD_01', 85, 100, '2026-01-11'), 
(3, 'Dallas', 'PROD_01', 70, 100, '2026-01-12'), 
(4, 'Dallas', 'PROD_01', 60, 100, '2026-01-13'), 
(5, 'Dallas', 'PROD_01', 40, 100, '2026-01-14'), 
(6, 'Dallas', 'PROD_01', 150, 100, '2026-01-15'),
(7, 'Chicago', 'PROD_01', 95, 100, '2026-01-10'),
(8, 'Chicago', 'PROD_01', 80, 100, '2026-01-11'),
(9, 'Chicago', 'PROD_01', 200, 100, '2026-01-12');

SELECT * FROM warehouse_inventory ;

WITH CTE1 AS (
    SELECT 
      warehouse_name,
      current_inventory,
      reorder_level,
      (reorder_level- current_inventory) AS SHORTAGE ,
      report_date,
      LAG(report_date) OVER(partition BY warehouse_name ORDER BY report_date ) AS PREVIOUS_DATE
    FROM warehouse_inventory
)

, CTE2 AS (
    SELECT 
      * ,
      CASE 
        WHEN ( DATEDIFF(report_date , PREVIOUS_DATE) = 1 OR DATEDIFF(report_date , PREVIOUS_DATE) IS NULL)
        AND SHORTAGE > 0
        THEN 0 
        ELSE 1 
      END AS IS_GAP 
    FROM CTE1 
)

, CTE3 AS (
  SELECT 
    warehouse_name,
    MIN(report_date) AS SHORTAGE_DAY_START,
    MAX(report_date) AS SHORTAGE_BREAK,
    COUNT(*) AS TOTAL_DAYS
  FROM (
    SELECT 
      *,
      SUM(IS_GAP) OVER(partition BY warehouse_name ORDER BY report_date) AS STREAK_ID 
    FROM CTE2
    ) AS TABLE_1 
  WHERE IS_GAP = 0 
  GROUP BY warehouse_name, STREAK_ID
  HAVING COUNT(*) >= 4 
)

SELECT 
  warehouse_name,
  SHORTAGE_DAY_START,
  SHORTAGE_BREAK,
  TOTAL_DAYS
FROM 
  CTE3
;

"""

  Output =>
    +----------------+--------------------+----------------+------------+
    | warehouse_name | SHORTAGE_DAY_START | SHORTAGE_BREAK | TOTAL_DAYS |
    +----------------+--------------------+----------------+------------+
    | Dallas         | 2026-01-10         | 2026-01-14     |          5 |
    +----------------+--------------------+----------------+------------+

"""

