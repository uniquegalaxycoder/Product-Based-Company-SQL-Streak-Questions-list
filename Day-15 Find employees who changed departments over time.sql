"""
    Q.Find employees who changed departments over time.

  Case :  To identify employees who have changed departments, we look for 'Islands' of different department 
          names within a single employee's timeline. This is a classic SCD Type 2 (Slowly Changing Dimension) analysis.
  
"""

CREATE TABLE employee_history (
    emp_id INT,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    effective_date DATE
);

INSERT INTO employee_history VALUES 
(1, 'Amit', 'Sales', '2024-01-01'),
(1, 'Amit', 'Marketing', '2025-06-01'),
(2, 'Priya', 'IT', '2024-01-01'),
(2, 'Priya', 'IT', '2025-01-01'),
(3, 'Rahul', 'HR', '2023-01-01'),
(3, 'Rahul', 'Finance', '2024-01-01'),
(3, 'Rahul', 'HR', '2025-01-01'),
(4, 'Suman', 'Sales', '2026-01-01');

select * from employee_history ;

with cte1 as (
  select 
    *,
    lead(department)over(partition by emp_id order by emp_id asc, effective_date asc) as previous_dept,
    lead(effective_date)over(partition by emp_id order by effective_date asc) as previous_dept_eff_date
  from employee_history
)

select 
  emp_id,
  emp_name,
  effective_date as "department Joining date",
  department as "From Dept.",
  previous_dept as "To Dept",
  previous_dept_eff_date as "New Dept Join Date"
from cte1 
where 
    previous_dept is not null 
and 
  department != previous_dept ;

"""
  Output =>
  
  +--------+----------+-------------------------+------------+-----------+--------------------+
  | emp_id | emp_name | department Joining date | From Dept. | To Dept   | New Dept Join Date |
  +--------+----------+-------------------------+------------+-----------+--------------------+
  |      1 | Amit     | 2024-01-01              | Sales      | Marketing | 2025-06-01         |
  |      3 | Rahul    | 2023-01-01              | HR         | Finance   | 2024-01-01         |
  |      3 | Rahul    | 2024-01-01              | Finance    | HR        | 2025-01-01         |
  +--------+----------+-------------------------+------------+-----------+--------------------+
  """

