"""
  Q.Find products that were never returned.
"""

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50)
);

CREATE TABLE returns (
    return_id INT PRIMARY KEY,
    product_id INT,
    return_date DATE,
    reason VARCHAR(100)
);

INSERT INTO products VALUES 
(1, 'Laptop', 'Electronics'),
(2, 'Mouse', 'Accessories'),
(3, 'Keyboard', 'Accessories'),
(4, 'Monitor', 'Electronics');

INSERT INTO returns VALUES 
(101, 1, '2026-01-05', 'Defective screen'),
(102, 2, '2026-01-10', 'Wrong color');

SELECT * FROM products;
SELECT * FROM returns ;

WITH CTE1 AS (
  SELECT 
    A.product_id,
    A.product_name,
    A.category,
    B.return_id,
    B.return_date,
    B.reason
  FROM products AS A 
  LEFT join
    returns AS B 
  ON A.product_id = B.product_id
  WHERE B.return_id IS NULL
)

SELECT 
  product_id,
  product_name,
  category
FROM CTE1 ;

"""
  Output =>
  +------------+--------------+-------------+
  | product_id | product_name | category    |
  +------------+--------------+-------------+
  |          3 | Keyboard     | Accessories |
  |          4 | Monitor      | Electronics |
  +------------+--------------+-------------+
"""
