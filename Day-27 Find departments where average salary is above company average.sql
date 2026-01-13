"""
    Q.Find departments where average salary is above company average.
"""

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10, 2)
);

INSERT INTO employees VALUES 
(1, 'Amit', 'IT', 90000),
(2, 'Neha', 'IT', 80000),
(3, 'Priya', 'Sales', 85000),
(4, 'Vikram', 'Sales', 75000),
(5, 'Rahul', 'HR', 60000),
(6, 'Suman', 'HR', 50000),
(7, 'Arjun', 'Admin', 40000);

SELECT * FROM employees ;

WITH CTE1 AS (
  SELECT 
    department,
    salary,
    ROUND(AVG(salary)OVER(),2) AS COMPANY_AVG_SALARY
  FROM employees
)
, CTE2 AS (
SELECT
  DISTINCT department,
  ROUND(AVG(SALARY)OVER(PARTITION BY department ),2) AS department_AVG_SALARY,
  COMPANY_AVG_SALARY
FROM CTE1
)

SELECT 
  *
FROM CTE2 
WHERE department_AVG_SALARY > COMPANY_AVG_SALARY ;

"""
  Output =>
  +------------+-----------------------+--------------------+
  | department | department_AVG_SALARY | COMPANY_AVG_SALARY |
  +------------+-----------------------+--------------------+
  | IT         |              85000.00 |           68571.43 |
  | Sales      |              80000.00 |           68571.43 |
  +------------+-----------------------+--------------------+
  
  """
