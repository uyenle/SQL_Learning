-- 1) Users have viewed products related to 'widget'?

SELECT 
  COALESCE(users.parent_user_id,users.id) AS user_id,
  users.email_address,
  items.id AS item_id,
  items.name AS item_name,
  items.category AS item_category
FROM
  (SELECT
    user_id,
    item_id,
    event_time,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC)
    AS row_number,
    RANK() OVER (PARTITION BY user_id ORDER BY event_time DESC)
    AS rank,
    DENSE_RANK() OVER (PARTITION BY user_id ORDER BY event_time DESC)
    AS dense_rank
  FROM dsv1069.view_item_events
  ) recent_view
JOIN dsv1069.users
ON users.id = recent_view.user_id
JOIN dsv1069.items
ON items.id = recent_view.item_id
WHERE users.deleted_at IS NOT NULL 
AND items.category = 'widget'
;


-- 2) Users have ever ordered products related to 'widget'?

SELECT 
    user_id,
    item_id,
    item_category,
    COUNT(DISTINCT line_item_id) AS time_user_ordered
FROM dsv1069.orders
WHERE item_category ='widget'
GROUP BY  
    user_id,
    item_id,
    item_category
;
 

-- 3) Users have ever re-ordered products related to 'widget'?
SELECT 
  user_id,
  time_user_ordered
FROM
  (SELECT 
    user_id,
    item_id,
    item_category,
    COUNT(DISTINCT line_item_id) AS time_user_ordered
FROM dsv1069.orders
WHERE item_category ='widget'
GROUP BY  
    user_id,
    item_id,
    item_category
    ) user_level_order
WHERE time_user_ordered > 1
;
