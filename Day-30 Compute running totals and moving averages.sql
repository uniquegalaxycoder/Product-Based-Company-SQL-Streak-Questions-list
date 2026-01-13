"""
    Q.Compute running totals and moving averages.
"""

CREATE TABLE daily_sales (
    sale_date DATE PRIMARY KEY,
    revenue DECIMAL(10, 2)
);

INSERT INTO daily_sales (sale_date, revenue) VALUES 
('2026-01-01', 100.00),
('2026-01-02', 150.00),
('2026-01-03', 200.00),
('2026-01-04', 50.00),  
('2026-01-05', 300.00), 
('2026-01-06', 250.00),
('2026-01-07', 400.00);

SELECT * FROM daily_sales ;

WITH CTE1 AS (
  SELECT 
    sale_date,
    revenue,
    ROUND(SUM(revenue)OVER(ORDER BY sale_date)) AS "MOVING REVENUE TOTAL",
    ROUND(AVG(revenue)OVER(ORDER BY sale_date)) AS "AVG RUNNING REVENUE"
  FROM daily_sales
)

SELECT * FROM CTE1 ;

"""
  Output =>
  +------------+---------+----------------------+---------------------+
  | sale_date  | revenue | MOVING REVENUE TOTAL | AVG RUNNING REVENUE |
  +------------+---------+----------------------+---------------------+
  | 2026-01-01 |  100.00 |                  100 |                 100 |
  | 2026-01-02 |  150.00 |                  250 |                 125 |
  | 2026-01-03 |  200.00 |                  450 |                 150 |
  | 2026-01-04 |   50.00 |                  500 |                 125 |
  | 2026-01-05 |  300.00 |                  800 |                 160 |
  | 2026-01-06 |  250.00 |                 1050 |                 175 |
  | 2026-01-07 |  400.00 |                 1450 |                 207 |
  +------------+---------+----------------------+---------------------+
  """
