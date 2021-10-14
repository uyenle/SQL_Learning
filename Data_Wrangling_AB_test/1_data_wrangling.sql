-- 1) Replicating the creaation of table view_item_events

CREATE TABLE view_item_events AS
  SELECT 
    event_id,
    event_time,
    user_id,
    platform,
    MAX(CASE WHEN parameter_name = 'item_id'
      THEN CAST(parameter_value AS INT)
      ELSE NULL END) AS item_id,
    MAX(CASE WHEN parameter_name = 'referrer'
      THEN parameter_value
      ELSE NULL END) AS referrer
  FROM 
    dsv1069.events 
  WHERE 
    event_name = 'view_item'
  GROUP BY  
    event_id,
    event_time,
    user_id,
    platform
;


-- 2a) How many items in all category did we sell? 

SELECT 
  item_category,
  item_name,
  COUNT(DISTINCT 
  COALESCE(parent_user_id,user_id)) AS user_with_order 
    FROM dsv1069.orders
JOIN dsv1069.users 
ON users.id = orders.user_id
GROUP BY 
item_category,
item_name
;


-- 2b) How many items in 'widget' category did we sell? 

SELECT 
  COUNT(DISTINCT user_id) AS user_with_order 
    FROM dsv1069.orders
WHERE item_category = 'widget'
;


-- 3) Rollup table - Table of order per day

SELECT 
  dates_rollup.date,
  SUM(orders)         AS orders,
  SUM(line_item)      AS items_ordered
FROM dsv1069.dates_rollup
LEFT OUTER JOIN
  (SELECT 
    date(paid_at)                 AS day,
    COUNT(DISTINCT invoice_id)    AS orders,
    COUNT(DISTINCT line_item_id)  AS line_item 
  FROM  dsv1069.orders
  GROUP BY date(paid_at)
  ) daily_order
ON daily_order.day  <=  dates_rollup.date
AND daily_order.day  > dates_rollup.d7_ago
GROUP BY dates_rollup.date
;



