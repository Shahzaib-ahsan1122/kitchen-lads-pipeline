SELECT
    CAST(order_id AS VARCHAR) AS order_id,
    CAST(order_date AS TIMESTAMP) AS order_date,
    'Foodhub' AS platform,
    CAST(delivery_type AS VARCHAR) AS delivery_type,
    CAST(item_name AS VARCHAR) AS item_name,
    CAST(quantity AS INTEGER) AS quantity,
    CAST(gross_amount AS DECIMAL(10,2)) AS gross_amount
FROM {{ source('kitchen_lads', 'raw_foodhub') }}