"""
    Q.Retrieve customers who bought product A and product B but not product C.

    This is a classic Relational Division or Set Theory problem. It tests your ability to compare multiple rows for the same 
    user—which is exactly how analysts identify specific purchase behaviors or 'cross-sell' opportunities.

"""
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    customer_id INT,
    product_name VARCHAR(10),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


INSERT INTO customers VALUES (1, 'Amit'), (2, 'Priya'), (3, 'Rahul'), (4, 'Suman');


INSERT INTO sales VALUES 
(1, 1, 'A'), (2, 1, 'B'), (3, 1, 'C'), 
(4, 2, 'A'), (5, 2, 'B'),             
(6, 3, 'A'), (7, 3, 'B'), (8, 3, 'D'), 
(9, 4, 'A');                           

select * from customers;
select * from sales ;

with cte1 as (
  select 
    a.customer_id,
    a.customer_name,
    b.sale_id,
    b.product_name
  from customers as a 
  left join 
    sales as b 
  on  
    a.customer_id = b.customer_id
)

select 
  customer_id,
  customer_name
from cte1 
where 
  product_name = "A"
and 
  customer_id in (
                    select
                      customer_id
                    from cte1 
                    where 
                      product_name = "B"
                    and 
                      customer_id not in (  
                                            select 
                                              customer_id 
                                            from cte1 
                                            where 
                                              product_name = "C"
                                            and customer_id is not null
                                          )
                  );

"""
  Output =>

    +-------------+---------------+
    | customer_id | customer_name |
    +-------------+---------------+
    |           2 | Priya         |
    |           3 | Rahul         |
    +-------------+---------------+
  
  """


