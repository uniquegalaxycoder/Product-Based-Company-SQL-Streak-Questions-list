"""
    Q.Get all managers who don’t have any direct reports.
"""

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    job_title VARCHAR(50),
    manager_id INT
);

INSERT INTO employees VALUES 
(1, 'Amit', 'Senior Manager', NULL), 
(2, 'Priya', 'Manager', 1),          
(3, 'Rahul', 'Manager', 1),          
(4, 'Suman', 'Analyst', 1),          
(5, 'Vikram', 'Developer', 1),       
(6, 'Neha', 'Director', NULL);       

SELECT 
  * 
FROM employees ;


WITH CTE1 AS (
  SELECT
    A.emp_id,
    A.emp_name,
    A.job_title,
    A.manager_id,
    B.emp_name AS MANAGER_NAME
    -- B.manager_id 
  FROM employees AS A  
  LEFT JOIN 
    employees AS B 
  ON 
    A.manager_id = B.emp_id
  WHERE 
    ( A.job_title LIKE '%Manager%'
      or a.job_title LIKE '%Director%' )
  and a.manager_id is not null
)

SELECT * FROM CTE1 ;

"""
  Output =>
    +--------+----------+-----------+------------+--------------+
    | emp_id | emp_name | job_title | manager_id | MANAGER_NAME |
    +--------+----------+-----------+------------+--------------+
    |      2 | Priya    | Manager   |          1 | Amit         |
    |      3 | Rahul    | Manager   |          1 | Amit         |
    +--------+----------+-----------+------------+--------------+
  """




