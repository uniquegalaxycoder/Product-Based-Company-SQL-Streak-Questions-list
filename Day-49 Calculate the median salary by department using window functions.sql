"""
    Q.Calculate the median salary by department using window functions.
"""

CREATE TABLE employee_salaries (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10, 2)
);

INSERT INTO employee_salaries VALUES 
(1, 'Alice', 'Engineering', 70000),
(2, 'Bob', 'Engineering', 80000),
(3, 'Charlie', 'Engineering', 90000),
(4, 'David', 'Engineering', 100000),
(5, 'Eve', 'Engineering', 250000),   
(6, 'Frank', 'Marketing', 50000),
(7, 'Grace', 'Marketing', 65000),    
(8, 'Heidi', 'Marketing', 75000),    
(9, 'Ivan', 'Marketing', 85000);

SELECT * FROM employee_salaries ;

WITH CTE1 AS (
  SELECT 
    *,
    ROUND(PERCENT_RANK() OVER(partition BY department ORDER BY emp_id)*100,2) AS MEDIAN_SAALRY
  FROM employee_salaries
)

SELECT 
  *
FROM CTE1 
WHERE 
  MEDIAN_SAALRY > 25 AND MEDIAN_SAALRY < 75

"""
  Output =>
  +--------+----------+-------------+----------+---------------+
  | emp_id | emp_name | department  | salary   | MEDIAN_SAALRY |
  +--------+----------+-------------+----------+---------------+
  |      3 | Charlie  | Engineering | 90000.00 |            50 |
  |      7 | Grace    | Marketing   | 65000.00 |         33.33 |
  |      8 | Heidi    | Marketing   | 75000.00 |         66.67 |
  +--------+----------+-------------+----------+---------------+
"""
