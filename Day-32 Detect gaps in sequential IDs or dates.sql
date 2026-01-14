"""
    Q.Detect gaps in sequential IDs or dates.
"""

CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY,
    amount DECIMAL(10, 2)
);
INSERT INTO invoices (invoice_id, amount) VALUES 
(1, 100.00),
(2, 150.00),
(4, 200.00),
(5, 50.00),
(9, 300.00),
(10, 120.00);


WITH RECURSIVE CTE1 AS (
  SELECT 
    1 AS ID 
  UNION ALL 
    SELECT ID + 1
  FROM CTE1 
  WHERE ID < 10
)

SELECT 
  A.ID AS "MISSING ID",
  B.invoice_id,
  B.amount
FROM 
  CTE1 AS A 
LEFT JOIN 
  invoices AS B 
ON 
  A.ID = B.invoice_id 
WHERE B.invoice_id IS NULL ;

"""
  Output =>
  +------------+------------+--------+
  | MISSING ID | invoice_id | amount |
  +------------+------------+--------+
  |          3 |       NULL |   NULL |
  |          6 |       NULL |   NULL |
  |          7 |       NULL |   NULL |
  |          8 |       NULL |   NULL |
  +------------+------------+--------+
  
  """

  
