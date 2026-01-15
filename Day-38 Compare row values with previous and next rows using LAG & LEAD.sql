"""
      Q.Compare row values with previous and next rows using LAG & LEAD.
"""

CREATE TABLE stock_prices (
    symbol VARCHAR(10),
    trade_date DATE,
    closing_price DECIMAL(10, 2)
);

INSERT INTO stock_prices VALUES 
('TECH_CORP', '2026-01-01', 150.00),
('TECH_CORP', '2026-01-02', 155.00), 
('TECH_CORP', '2026-01-03', 152.00), 
('TECH_CORP', '2026-01-04', 160.00), 
('TECH_CORP', '2026-01-05', 158.00); 

SELECT * FROM stock_prices ;

WITH CTE1 AS (
  SELECT 
    symbol,
    trade_date,
    LAG(closing_price) OVER(ORDER BY trade_date) AS YESTERDAY_CLOSING_PRISE,
    closing_price AS CURRENT_CLOSING_PRICE,
    LEAD(closing_price) OVER(ORDER BY trade_date) AS DAY_AFTER_TODAY_CLOSING_PRICE
  FROM stock_prices
)

SELECT * FROM CTE1 ;

"""
  Output =>
  +-----------+------------+-------------------------+-----------------------+-------------------------------+
  | symbol    | trade_date | YESTERDAY_CLOSING_PRISE | CURRENT_CLOSING_PRICE | DAY_AFTER_TODAY_CLOSING_PRICE |
  +-----------+------------+-------------------------+-----------------------+-------------------------------+
  | TECH_CORP | 2026-01-01 |                    NULL |                150.00 |                        155.00 |
  | TECH_CORP | 2026-01-02 |                  150.00 |                155.00 |                        152.00 |
  | TECH_CORP | 2026-01-03 |                  155.00 |                152.00 |                        160.00 |
  | TECH_CORP | 2026-01-04 |                  152.00 |                160.00 |                        158.00 |
  | TECH_CORP | 2026-01-05 |                  160.00 |                158.00 |                          NULL |
  +-----------+------------+-------------------------+-----------------------+-------------------------------+
"""
