"""
    Q.Identify orders without corresponding payments.

  Case :
    In an e-commerce or financial system, identifying orders without payments is crucial for tracking
    abandoned carts, payment gateway failures, or pending cash-on-delivery transactions.

"""

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    cust_id INT
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_date DATE,
    payment_status VARCHAR(20), 
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Orders Table
INSERT INTO orders VALUES 
(501, '2026-01-01', 1500.00, 101),
(502, '2026-01-02', 2500.00, 102),
(503, '2026-01-03', 500.00,  103), 
(504, '2026-01-04', 1200.00, 104), 
(505, '2026-01-05', 300.00,  105); 

-- Payments Table
INSERT INTO payments VALUES 
(1, 501, '2026-01-01', 'Success'),
(2, 502, '2026-01-02', 'Success'),
(3, 503, '2026-01-03', 'Failed');


select * from orders;
select * from payments ;

with cte1 as (
  select 
    a.payment_id,
    a.order_id,
    a.payment_date,
    a.payment_status,
    b.order_date,
    b.total_amount
  from payments as a 
  left join 
    orders as b 
  on 
    a.order_id = b.order_id
  where a.payment_status = 'Failed'
)

select * from cte1 ;

"""
  Output =>
    +------------+----------+--------------+----------------+------------+--------------+
    | payment_id | order_id | payment_date | payment_status | order_date | total_amount |
    +------------+----------+--------------+----------------+------------+--------------+
    |          3 |      503 | 2026-01-03   | Failed         | 2026-01-03 |       500.00 |
    +------------+----------+--------------+----------------+------------+--------------+
  
  """
