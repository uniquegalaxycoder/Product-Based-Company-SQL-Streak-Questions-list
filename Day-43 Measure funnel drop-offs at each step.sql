"""
   Q.Measure funnel drop-offs at each step.

CASE :
  Home page-> Product Search-> Add to Cart-> complete the Purchase

  """


CREATE TABLE website_events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    event_name VARCHAR(50),
    event_time DATETIME
);

INSERT INTO website_events (user_id, event_name, event_time) VALUES 
(101, 'home_view', '2026-01-17 10:00:00'),
(101, 'product_search', '2026-01-17 10:05:00'),
(101, 'add_to_cart', '2026-01-17 10:10:00'),
(101, 'purchase', '2026-01-17 10:15:00'),

(102, 'home_view', '2026-01-17 11:00:00'),
(102, 'product_search', '2026-01-17 11:05:00'),
(102, 'add_to_cart', '2026-01-17 11:10:00'), 

(103, 'home_view', '2026-01-17 12:00:00'),
(103, 'product_search', '2026-01-17 12:05:00'), 

(104, 'home_view', '2026-01-17 13:00:00'); 

SELECT * FROM website_events ;

WITH CTE1 AS (
  SELECT 
    COUNT(distinct user_id) AS TOTAL_USERS,
    COUNT(distinct CASE WHEN event_name = 'home_view' THEN user_id END ) AS home_view,
    COUNT(distinct CASE WHEN event_name = 'product_search' THEN user_id END ) AS product_search,
    COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN user_id END ) AS ADD_TO_CART,
    COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_id END ) AS TOTAL_PURCHES
  FROM website_events
)

SELECT 
  TOTAL_USERS,
  ROUND((home_view / TOTAL_USERS )*100, 2) AS USESR_TO_HOME_VIEW_DROP,
  ROUND((product_search / home_view)*100, 2) AS HOME_TO_PRODUCT_SEARCH_DROP,
  ROUND((ADD_TO_CART / product_search)*100, 2) AS SEARCH_TO_ADD_CART_DROP,
  ROUND((TOTAL_PURCHES / ADD_TO_CART)*100, 2) AS ADD_TO_CART_PURCHES
FROM CTE1 ;

"""
  Output =>
    +-------------+-------------------------+-----------------------------+-------------------------+---------------------+
    | TOTAL_USERS | USESR_TO_HOME_VIEW_DROP | HOME_TO_PRODUCT_SEARCH_DROP | SEARCH_TO_ADD_CART_DROP | ADD_TO_CART_PURCHES |
    +-------------+-------------------------+-----------------------------+-------------------------+---------------------+
    |           4 |                  100.00 |                       75.00 |                   66.67 |               50.00 |
    +-------------+-------------------------+-----------------------------+-------------------------+---------------------+
"""


