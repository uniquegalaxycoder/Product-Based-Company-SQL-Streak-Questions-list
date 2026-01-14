"""
    Q.Detect gaps in sequential IDs or dates.
"""

CREATE TABLE employee_attendance (
    emp_id INT,
    work_date DATE,
    PRIMARY KEY (emp_id, work_date)
);

INSERT INTO employee_attendance VALUES 
(101, '2026-01-01'),
(101, '2026-01-02'),
(101, '2026-01-03'),
(101, '2026-01-05'),
(101, '2026-01-08');

SELECT * FROM employee_attendance ;

WITH RECURSIVE CTE1 AS (
  SELECT 
    (SELECT MIN(work_date) FROM employee_attendance) AS DATES 
  UNION ALL 
    SELECT DATES + 1 
  FROM CTE1 
  WHERE DATES < ( SELECT MAX(work_date) FROM employee_attendance)
) 

SELECT 
  A.DATES AS "MISSING DATE",
  B.emp_id,
  B.work_date
FROM CTE1 AS A 
LEFT JOIN 
  employee_attendance AS B 
ON 
  A.DATES = B.work_date 
WHERE 
  B.work_date IS NULL ;

"""
  Output =>
  +--------------+--------+-----------+
  | MISSING DATE | emp_id | work_date |
  +--------------+--------+-----------+
  | 2026-01-04   |   NULL | NULL      |
  | 2026-01-06   |   NULL | NULL      |
  | 2026-01-07   |   NULL | NULL      |
  +--------------+--------+-----------+
"""
