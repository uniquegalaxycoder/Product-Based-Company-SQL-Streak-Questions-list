"""
    Q.Show the department with the highest number of employees and the count.
"""

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(50)
);

INSERT INTO employees (emp_id, emp_name, department) VALUES 
(1, 'Alice', 'Engineering'),
(2, 'Bob', 'Engineering'),
(3, 'Charlie', 'Engineering'),
(4, 'David', 'Engineering'),
(5, 'Eve', 'Marketing'),
(6, 'Frank', 'Marketing'),
(7, 'Grace', 'HR');

SELECT * FROM employees ;

WITH CTE1 AS (
  SELECT 
    department,
    COUNT(emp_id) AS TOTAL_EMP
  FROM employees
  GROUP BY department
)

SELECT * FROM CTE1
ORDER BY TOTAL_EMP DESC
LIMIT 1;

"""
  Output =>
    +-------------+-----------+
    | department  | TOTAL_EMP |
    +-------------+-----------+
    | Engineering |         4 |
    +-------------+-----------+
"""
