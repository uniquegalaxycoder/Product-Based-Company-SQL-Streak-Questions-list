"""
    Q.("Market Basket Analysis" problem) Find pairs of products that are most commonly bought together in the same order ?
"""

CREATE TABLE order_items (
    order_id INT,
    product_name VARCHAR(50)
);

INSERT INTO order_items (order_id, product_name) VALUES 
(1, 'Bread'), (1, 'Butter'), (1, 'Milk'),
(2, 'Bread'), (2, 'Butter'),
(3, 'Bread'), (3, 'Jam'),
(4, 'Butter'), (4, 'Bread'), 
(5, 'Bread'), (5, 'Jam'),
(6, 'Milk'), (6, 'Cookies');

SELECT * FROM order_items ;

WITH CTE1 AS (
    SELECT 
      A.order_id,
      A.product_name,
      B.product_name AS NEW_PRODUCT_NAME
    FROM order_items AS A 
    INNER JOIN                 ----------SELF jOIN
      order_items AS B 
    ON 
      A.order_id = B.order_id
    AND A.product_name < B.product_name
)

, CTE2 AS (
SELECT 
  *,
  RANK()OVER(ORDER BY TOTAL_ORDERS DESC ) AS ORDER_RANK
FROM (
        SELECT 
          CONCAT( product_name , '-', NEW_PRODUCT_NAME) AS BUCKET,
          COUNT(order_id) AS TOTAL_ORDERS 
        FROM CTE1 
        GROUP BY CONCAT( product_name , "-", NEW_PRODUCT_NAME)
      ) AS TABLE_1
)

SELECT * FROM CTE2 ;

"""
  Output =>
    +--------------+--------------+------------+
    | BUCKET       | TOTAL_ORDERS | ORDER_RANK |
    +--------------+--------------+------------+
    | Bread-Butter |            3 |          1 |
    | Bread-Jam    |            2 |          2 |
    | Butter-Milk  |            1 |          3 |
    | Bread-Milk   |            1 |          3 |
    | Cookies-Milk |            1 |          3 |
    +--------------+--------------+------------+
"""
