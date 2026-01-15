"""
    Q.Detect abnormal traffic spikes.
"""

CREATE TABLE web_traffic (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    event_hour DATETIME,
    request_count INT
);

INSERT INTO web_traffic (event_hour, request_count) VALUES 
('2026-01-15 09:00:00', 510),
('2026-01-15 10:00:00', 490),
('2026-01-15 11:00:00', 505),
('2026-01-15 12:00:00', 520),
('2026-01-15 13:00:00', 480),
('2026-01-15 14:00:00', 515),
('2026-01-15 15:00:00', 2500), 
('2026-01-15 16:00:00', 530),
('2026-01-15 17:00:00', 510);

SELECT * FROM web_traffic;

WITH CTE1 AS (
  SELECT 
    log_id,
    event_hour,
    request_count,
    ROUND(AVG(request_count)OVER(ORDER BY event_hour ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) ,2)
    AS ROLLING_AVG_TRAFFIC,
    ROUND(STDDEV(request_count)OVER(ORDER BY event_hour ROWS BETWEEN 5 PRECEDING AND CURRENT ROW),2) AS STD
  FROM web_traffic
)

SELECT 
  log_id,
  event_hour,
  request_count,
  ROLLING_AVG_TRAFFIC,
  STD,
  ABNORMAL_FLAG
FROM(
      SELECT 
        * ,
        CASE 
          WHEN request_count > (ROLLING_AVG_TRAFFIC + ( 2 * STD)) 
              THEN 1 
              ELSE 0 
        END AS ABNORMAL_FLAG
      FROM CTE1
) AS TABLE_1
WHERE ABNORMAL_FLAG = 1;

"""
  Output =>
    +--------+---------------------+---------------+---------------------+--------+---------------+
    | log_id | event_hour          | request_count | ROLLING_AVG_TRAFFIC | STD    | ABNORMAL_FLAG |
    +--------+---------------------+---------------+---------------------+--------+---------------+
    |      7 | 2026-01-15 15:00:00 |          2500 |              835.00 | 744.74 |             1 |
    +--------+---------------------+---------------+---------------------+--------+---------------+
"""
"""
  lOGIC : 

  - Choosing the specific size of a window (in this case, 6 hours) is a strategic decision based on the granularity and periodicity of your data. 
    In data science and analytics, this is known as choosing the 'look-back period'.
  
  - Here is why a 6-hour window is often the 'sweet spot' for detecting hourly traffic spikes:
        1. Capturing 'Intra-day' Seasonality Web traffic isn't flat; it follows a natural curve (rising in the morning, peaking in the evening, 
                  and dropping at night).

              - Too Small (1–2 hours): The window is too sensitive. If traffic naturally rises from 8:00 AM to 9:00 AM, a 1-hour window might
                  flag this normal morning growth as an 'abnormal spike'.

              - Too Large (24+ hours): The window includes night-time lows and day-time highs. This inflates the Standard Deviation so much that 
                  a real spike at 3:00 PM might get hidden in the 'noise' of the 24-hour average.

              - The 6-Hour Choice: It captures the immediate local context. It compares the 3:00 PM traffic to the late morning and early afternoon,
                  which are the most relevant benchmarks for that time of day.

        2. Balancing Sensitivity vs. Lag Window functions have an inherent 'lag.'

              - If you use a short window, the 'Moving Average' reacts almost instantly to a spike. If the spike lasts for 3 hours, 
                  by the 3rd hour, the moving average has risen so much that the spike is no longer 'abnormal.'

              - If you use a 6-hour window, the spike has to be truly massive to 'pull' the 6-hour average up quickly enough to hide itself.
                This gives your alerting system more time to catch the anomaly before it becomes the 'new normal'.

        3. Handling 'Burstiness' 
              - In technical infrastructure, traffic often comes in 'bursts' (e.g., a batch job starting, or a cache clearing).
  
              - A 6-hour window provides enough data points ($n=6$) to calculate a meaningful Standard Deviation.
  
              - Statistically, calculating Standard Deviation on only 2 or 3 points is highly unreliable and leads to 'False Positives' (crying wolf).

  """

