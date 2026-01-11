"""
    Q.Detect duplicate records using composite keys.
"""

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date DATE
);

INSERT INTO enrollments VALUES 
(1, 101, 50, '2026-01-01'), 
(2, 101, 50, '2026-01-02'), 
(3, 102, 50, '2026-01-01'), 
(4, 103, 60, '2026-01-03'), 
(5, 103, 60, '2026-01-04'), 
(6, 103, 60, '2026-01-05'), 
(7, 104, 70, '2026-01-01'); 

select * from enrollments ;

with cte1 as (
  SELECT 
    enrollment_id,
    student_id,
    course_id,
    enrollment_date,
    ROW_NUMBER()OVER(PARTITION BY student_id, course_id ) AS duplicate_ID
  FROM enrollments 
)

SELECT 
  enrollment_id,
  student_id,
  course_id,
  enrollment_id
FROM CTE1
WHERE duplicate_ID > 1 ;
"""
  Output =>
    +---------------+------------+-----------+---------------+
    | enrollment_id | student_id | course_id | enrollment_id |
    +---------------+------------+-----------+---------------+
    |             2 |        101 |        50 |             2 |
    |             5 |        103 |        60 |             5 |
    |             6 |        103 |        60 |             6 |
    +---------------+------------+-----------+---------------+
  """



