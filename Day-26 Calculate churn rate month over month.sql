"""
    Q.Calculate churn rate month over month.

"""

CREATE TABLE sales (
    customer_id BIGINT,
    order_id BIGINT,
    order_date DATE,
    order_amount DECIMAL(10,2)
);

INSERT INTO sales (customer_id, order_id, order_date, order_amount) VALUES
-- January 2026
(101, 1, '2026-01-05', 1200.00),
(102, 2, '2026-01-10', 1500.00),
(103, 3, '2026-01-15', 800.00),
(104, 4, '2026-01-20', 2000.00),
(105, 5, '2026-01-25', 950.00),

-- February 2026
(101, 6, '2026-02-06', 1300.00),
(102, 7, '2026-02-12', 1400.00),
(104, 8, '2026-02-18', 2100.00),
(106, 9, '2026-02-22', 1600.00),

-- March 2026
(101, 10, '2026-03-04', 1250.00),
(104, 11, '2026-03-10', 2200.00),
(106, 12, '2026-03-15', 1700.00),
(107, 13, '2026-03-20', 900.00),

-- April 2026
(104, 14, '2026-04-05', 2300.00),
(106, 15, '2026-04-12', 1800.00),
(108, 16, '2026-04-18', 1100.00);


SELECT * FROM sales ;

WITH MONTHLY_ACTIVE_USERS AS (
  SELECT 
    customer_id,
    DATE_FORMAT(order_date, '%Y-%m') AS MONTH 
  FROM sales
)

,CHURN_BASE AS (
    SELECT
      PREV.customer_id,
      DATE_FORMAT(DATE_ADD(STR_TO_DATE(PREV.MONTH, '%Y-%m'), interval 1 MONTH), '%Y-%m') MONTH
    FROM MONTHLY_ACTIVE_USERS AS PREV
    LEFT JOIN 
      MONTHLY_ACTIVE_USERS AS CURR
    ON PREV.customer_id = CURR.customer_id 
    AND CURR.MONTH = DATE_FORMAT(DATE_ADD(STR_TO_DATE(PREV.MONTH, '%Y-%m'), interval 1 MONTH), '%Y-%m')
    WHERE CURR.customer_id IS NULL
)

SELECT 
  MONTH,
  COUNT(DISTINCT customer_id) AS CHURRNED_CUSTOMERS
FROM CHURN_BASE 
GROUP BY MONTH
ORDER BY MONTH ;

























