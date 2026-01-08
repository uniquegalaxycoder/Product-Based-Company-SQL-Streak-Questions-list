"""
      5. Sensor 'High Temperature' Duration
      The Scenario: An IoT sensor records temperature every minute. 
      Find the longest continuous duration (in minutes) where the temperature exceeded 100.99°C.
"""
  
CREATE TABLE sensor_data (
    sensor_id INT,
    recorded_at DATETIME,
    temperature DECIMAL(5, 2)
);

INSERT INTO sensor_data (sensor_id, recorded_at, temperature) VALUES 
(101, '2026-01-08 10:00:00', 98.5),
(101, '2026-01-08 10:01:00', 101.2),
(101, '2026-01-08 10:02:00', 102.5),
(101, '2026-01-08 10:03:00', 100.8),
(101, '2026-01-08 10:04:00', 103.1),
(101, '2026-01-08 10:05:00', 105.0),
(101, '2026-01-08 10:06:00', 104.2),
(101, '2026-01-08 10:07:00', 102.0),
(101, '2026-01-08 10:08:00', 101.5),
(101, '2026-01-08 10:09:00', 100.2),
(101, '2026-01-08 10:10:00', 100.1), 
(101, '2026-01-08 10:11:00', 99.8),  
(101, '2026-01-08 10:12:00', 97.0),
(101, '2026-01-08 10:13:00', 101.0), 
(101, '2026-01-08 10:14:00', 102.0), 
(101, '2026-01-08 10:15:00', 99.0);

select * from sensor_data ;

with cte1 as (
select 
    recorded_at as currenttime,
    temperature,
    date_sub(recorded_at, interval row_number()over( order by recorded_at) minute) as streak
from sensor_data 
where temperature > 100.00
)

select 
  start_time,
  end_time,
  total_minutes
from (
      select 
        min(currenttime) as start_time,
        max(currenttime) as end_time,
        count(*) as total_minutes 
      from cte1
      group by streak 
) as final_view ;


"""
  Output =>
    +---------------------+---------------------+---------------+
    | start_time          | end_time            | total_minutes |
    +---------------------+---------------------+---------------+
    | 2026-01-08 10:01:00 | 2026-01-08 10:10:00 |            10 |
    | 2026-01-08 10:13:00 | 2026-01-08 10:14:00 |             2 |
    +---------------------+---------------------+---------------+
  
  """  
























