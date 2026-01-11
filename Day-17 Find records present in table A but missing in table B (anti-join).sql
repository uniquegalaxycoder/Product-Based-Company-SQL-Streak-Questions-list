"""
    Q.Find records present in table A but missing in table B (anti-join).

"""

CREATE TABLE table_a_customers (
    cust_id INT PRIMARY KEY,
    cust_name VARCHAR(50)
);

CREATE TABLE table_b_orders (
    order_id INT PRIMARY KEY,
    cust_id INT
);

-- Table A: All Customers
INSERT INTO table_a_customers VALUES 
(1, 'Amit'), 
(2, 'Priya'), 
(3, 'Rahul'), 
(4, 'Suman');

-- Table B: Orders (Only Amit and Priya ordered)
INSERT INTO table_b_orders VALUES 
(101, 1), 
(102, 2);


select * from table_a_customers ;
select * from table_b_orders ;

with cte1 as (
  select 
    a.cust_id,
    a.cust_name,
    b.order_id
  from table_a_customers as a 
  left join 
  table_b_orders as b 
  on 
    a.cust_id = b.cust_id
  where 
    b.cust_id is null
)
select * from cte1;

"""
  Output =>
    +---------+-----------+----------+
    | cust_id | cust_name | order_id |
    +---------+-----------+----------+
    |       3 | Rahul     |     NULL |
    |       4 | Suman     |     NULL |
    +---------+-----------+----------+
  
  """


