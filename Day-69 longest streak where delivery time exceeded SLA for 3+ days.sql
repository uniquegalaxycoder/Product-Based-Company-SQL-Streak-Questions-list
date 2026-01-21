"""

      Q.Detect longest streak where delivery time exceeded SLA for 3+ days.

   BUSINESS CASE :
     To detect an SLA Breach Streak, we need to identify consecutive days where the actual delivery 
     time was higher than the Promised SLA. This is a critical metric for Logistics and Operations teams 
     to identify bottlenecks in the supply chain.
"""

CREATE TABLE delivery_performance (
    order_id INT PRIMARY KEY,
    carrier_name VARCHAR(50), -- e.g., 'FedEx', 'DHL'
    region VARCHAR(50),
    promised_sla_hours INT,
    actual_delivery_hours INT,
    delivery_date DATE
);

INSERT INTO delivery_performance 
(order_id, carrier_name, region, promised_sla_hours, actual_delivery_hours, delivery_date) 
VALUES 
-- DHL: 4-Day Breach Streak
(1, 'DHL', 'North', 24, 30, '2026-01-01'), 
(2, 'DHL', 'North', 24, 28, '2026-01-02'), 
(3, 'DHL', 'North', 24, 35, '2026-01-03'), 
(4, 'DHL', 'North', 24, 40, '2026-01-04'), 
(5, 'DHL', 'North', 24, 20, '2026-01-05'), 
(6, 'FedEx', 'South', 48, 55, '2026-01-01'), 
(7, 'FedEx', 'South', 48, 40, '2026-01-02'), 
(8, 'FedEx', 'South', 48, 60, '2026-01-03'), 
(9, 'FedEx', 'South', 48, 65, '2026-01-04'); 

SELECT * FROM delivery_performance ;

WITH CTE1 AS (
    SELECT 
      carrier_name,
      promised_sla_hours,
      actual_delivery_hours,
      delivery_date,
      LAG(delivery_date) OVER(partition BY carrier_name ORDER BY delivery_date) AS PREVIOUS_DATE
    FROM delivery_performance
    WHERE actual_delivery_hours > promised_sla_hours
)

, CTE2 AS (
    SELECT
      *,
      CASE 
        WHEN DATEDIFF(delivery_date, PREVIOUS_DATE) = 1 OR
              DATEDIFF(delivery_date, PREVIOUS_DATE) IS NULL 
            THEN 0 
            ELSE 1 
          END AS IS_GAP 
    FROM CTE1 
)


SELECT 
  carrier_name,
  MIN(delivery_date) AS "SLA BREACH START",
  MAX(delivery_date) AS "SLA BREACH END",
  COUNT(*) AS TOTAL_DAY_SLA_EXCEEDS 
FROM (
SELECT 
  *,
  SUM(IS_GAP) OVER(partition BY carrier_name ORDER BY delivery_date) AS STREAK_ID 
FROM CTE2 
) AS TABLE_1 
WHERE IS_GAP = 0 
GROUP BY carrier_name, STREAK_ID
HAVING COUNT(*) >= 3  ;

"""
  Output =>
  +--------------+------------------+----------------+-----------------------+
  | carrier_name | SLA BREACH START | SLA BREACH END | TOTAL_DAY_SLA_EXCEEDS |
  +--------------+------------------+----------------+-----------------------+
  | DHL          | 2026-01-01       | 2026-01-04     |                     4 |
  +--------------+------------------+----------------+-----------------------+
"""
