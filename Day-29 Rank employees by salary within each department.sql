"""
    Q.Rank employees by salary within each department.
"""
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10, 2)
);

INSERT INTO employees VALUES 
(1, 'Amit', 'IT', 95000),    
(2, 'Neha', 'IT', 95000),    
(3, 'Vikram', 'IT', 80000),  
(4, 'Priya', 'Sales', 90000),
(5, 'Arjun', 'Sales', 70000),
(6, 'Suman', 'HR', 60000);

SELECT * FROM employees ;

WITH CTE1 AS (
  SELECT 
    emp_id,
    emp_name,
    department,
    salary,
    DENSE_RANK()OVER(PARTITION BY department ORDER BY salary DESC) AS SALARY_RANK
  FROM employees
)

SELECT * FROM CTE1 
ORDER BY emp_id, department;

"""
  Output =>
  +--------+----------+------------+----------+-------------+
  | emp_id | emp_name | department | salary   | SALARY_RANK |
  +--------+----------+------------+----------+-------------+
  |      1 | Amit     | IT         | 95000.00 |           1 |
  |      2 | Neha     | IT         | 95000.00 |           1 |
  |      3 | Vikram   | IT         | 80000.00 |           2 |
  |      4 | Priya    | Sales      | 90000.00 |           1 |
  |      5 | Arjun    | Sales      | 70000.00 |           2 |
  |      6 | Suman    | HR         | 60000.00 |           1 |
  +--------+----------+------------+----------+-------------+
"""








