"""
    Q.Get the Nth highest salary per department.
"""

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10, 2)
);

INSERT INTO employees VALUES 
(1, 'Amit', 'Engineering', 100000), 
(2, 'Neha', 'Engineering', 100000), 
(3, 'Vikram', 'Engineering', 90000),
(4, 'Siddharth', 'Engineering', 80000),
(5, 'Priya', 'Marketing', 85000),    
(6, 'Rahul', 'Marketing', 75000),    
(7, 'Suman', 'Marketing', 60000),
(8, 'Anjali', 'HR', 70000),      
(9, 'Rohan', 'HR', 65000);

SELECT * FROM employees ;

WITH CTE1 AS (
  SELECT 
    emp_id,
    emp_name,
    department,
    salary,
    DENSE_RANK()OVER(PARTITION BY department ORDER BY salary DESC) AS SALARY_RNAK
  FROM employees
)

SELECT 
  *
FROM CTE1
WHERE SALARY_RNAK = 1;

"""
  Output =>
  +--------+----------+-------------+-----------+-------------+
  | emp_id | emp_name | department  | salary    | SALARY_RNAK |
  +--------+----------+-------------+-----------+-------------+
  |      1 | Amit     | Engineering | 100000.00 |           1 |
  |      2 | Neha     | Engineering | 100000.00 |           1 |
  |      8 | Anjali   | HR          |  70000.00 |           1 |
  |      5 | Priya    | Marketing   |  85000.00 |           1 |
  +--------+----------+-------------+-----------+-------------+
"""

