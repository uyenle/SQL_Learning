-- Binary metric
-- 1- If user order after their test assignment?

SELECT 
  test_events.test_id,
  test_events.test_assignment,
  test_events.user_id,
  MAX(CASE WHEN orders.created_at > test_events.event_time THEN 1 ELSE 0 END) AS order_after_assignment  
FROM
  (SELECT 
    event_id,
    event_time,
    user_id,
    platform,
    MAX(CASE WHEN parameter_name = 'test_id'
            THEN CAST(parameter_value AS INT)
            ELSE NULL END) AS test_id,
    MAX(CASE WHEN parameter_name = 'test_assignment'
            THEN parameter_value
            ELSE NULL END) AS test_assignment
  FROM 
    dsv1069.events 
  WHERE 
    event_name = 'test_assignment'
  GROUP BY  
    event_id,
    event_time,
    user_id,
    platform
    ) test_events
LEFT JOIN dsv1069.orders
ON orders.user_id = test_events.user_id 
GROUP BY
  test_events.test_id,
  test_events.test_assignment,
  test_events.user_id
;


-- 2- the total number of order/invoice; ordered items and revenue of order after test assignment?

SELECT 
  test_events.test_id,
  test_events.test_assignment,
  test_events.user_id,
  COUNT(DISTINCT (CASE WHEN orders.created_at > test_events.event_time THEN invoice_id ELSE NULL END)) 
    AS order_after_assignment,  
  COUNT(DISTINCT (CASE WHEN orders.created_at > test_events.event_time THEN line_item_id ELSE NULL END)) 
    AS items_after_assignment,
  SUM(CASE WHEN orders.created_at > test_events.event_time THEN price ELSE 0 END)
    AS total_revenue
FROM
  (SELECT 
    event_id,
    event_time,
    user_id,
    platform,
    MAX(CASE WHEN parameter_name = 'test_id'
            THEN CAST(parameter_value AS INT)
            ELSE NULL END) AS test_id,
    MAX(CASE WHEN parameter_name = 'test_assignment'
            THEN parameter_value
            ELSE NULL END) AS test_assignment
  FROM 
    dsv1069.events 
  WHERE 
    event_name = 'test_assignment'
  GROUP BY  
    event_id,
    event_time,
    user_id,
    platform
    ) test_events
LEFT JOIN dsv1069.orders
ON orders.user_id = test_events.user_id 
GROUP BY
  test_events.test_id,
  test_events.test_assignment,
  test_events.user_id
;


-- 3- How many user order in each test_id? Here test_id = 7

SELECT 
  test_assignment,
  COUNT(user_id) AS users,
  SUM(order_after_assignment)
FROM
  (SELECT 
    test_events.test_id,
    test_events.test_assignment,
    test_events.user_id,
    MAX(CASE WHEN orders.created_at > test_events.event_time THEN 1 ELSE 0 END)
      AS order_after_assignment
  FROM
    (SELECT 
      event_id,
      event_time,
      user_id,
      platform,
      MAX(CASE WHEN parameter_name = 'test_id'
              THEN CAST(parameter_value AS INT)
              ELSE NULL END) AS test_id,
      MAX(CASE WHEN parameter_name = 'test_assignment'
              THEN parameter_value
              ELSE NULL END) AS test_assignment
    FROM 
      dsv1069.events 
    WHERE 
      event_name = 'test_assignment'
    GROUP BY  
      event_id,
      event_time,
      user_id,
      platform
      ) test_events
  LEFT JOIN dsv1069.orders
  ON orders.user_id = test_events.user_id 
  GROUP BY
    test_events.test_id,
    test_events.test_assignment,
    test_events.user_id
  ) user_level 
WHERE test_id = 7
GROUP BY test_assignment
;

-- A/B test app: https://thumbtack.github.io/abba/demo/abba.html

-- RESULTS
--                                No trials   No successes
-- Control   (no test_assignment)   19376	        2521
-- Treatment (no test_assignment)   19271	        2633
-- Interval confidence level: 0.95 

-- p-value = 0.059
-- the actual success lift of treatment lies  from -0.2% to 10%
