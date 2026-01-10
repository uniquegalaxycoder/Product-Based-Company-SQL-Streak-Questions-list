"""
 Q.Find users who made purchases but never logged in.

Case :
This is a classic 'Data Integrity' or 'Join Gap' question. It’s tricky because, in a perfect system, 
a user cannot purchase without logging in. However, in the real world, this happens due to Guest Checkouts,  API orders, or system sync errors.

"""


CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50),
    last_login_date DATE
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT, 
    order_date DATE,
    order_amount DECIMAL(10,2)
);

-- Users Table
INSERT INTO users (user_id, username, last_login_date) VALUES 
(1, 'Amit', '2026-01-05'),
(2, 'Priya', '2026-01-07'),
(3, 'Rahul', NULL),          
(4, 'Suman', '2026-01-01'),
(5, 'Vikram', NULL);         

-- Orders Table
INSERT INTO orders (order_id, user_id, order_date, order_amount) VALUES 
(101, 1, '2026-01-06', 500.00),  
(102, 2, '2026-01-08', 300.00),  
(103, 3, '2026-01-09', 150.00),  
(104, 3, '2026-01-10', 100.00),  
(105, 6, '2026-01-05', 1200.00), 
(106, 7, '2026-01-06', 450.00),  
(107, 4, '2026-01-02', 200.00),  
(108, 5, '2026-01-10', 99.00),   
(109, 8, '2026-01-11', 50.00),   
(110, 1, '2026-01-07', 25.00);   

select * from users ;
select * from orders ;


with cte1 as (
  select 
    a.user_id,
    b.username,
    b.last_login_date,
    count(a.order_id) as total_orders,
    sum(a.order_amount) as total_amount
  from 
    orders as a 
  left join 
    users as b 
  on 
    a.user_id = b.user_id
  where b.last_login_date is null or a.user_id is null 
  group by 
    a.user_id,
    b.username,
    b.last_login_date
)

select 
  * 
from cte1;

"""
  Output =>
    +-----------------+----------+-----------------+-------------+
    | purchasing_user | username | last_login_date | total_spent |
    +-----------------+----------+-----------------+-------------+
    |               3 | Rahul    | NULL            |      250.00 |
    |               6 | NULL     | NULL            |     1200.00 |
    |               7 | NULL     | NULL            |      450.00 |
    |               5 | Vikram   | NULL            |       99.00 |
    |               8 | NULL     | NULL            |       50.00 |
    +-----------------+----------+-----------------+-------------+
  
  """


