WITH unioned_orders AS (
    SELECT * FROM {{ ref('stg_ubereats') }}
    UNION ALL
    SELECT * FROM {{ ref('stg_deliveroo') }}
    UNION ALL 
    SELECT * FROM {{ ref('stg_justeat') }}
    UNION ALL
    SELECT * FROM {{ ref('stg_foodhub') }}
),

mapped_menu AS (
    SELECT * FROM {{ ref('menu_mapping') }}
),

commissions AS (
    SELECT * FROM {{ ref('platform_commissions') }}
)

SELECT 
    o.order_id,
    o.order_date,
    o.platform,
    o.delivery_type,
    o.item_name AS raw_item_name,
    COALESCE(m.canonical_item_name, o.item_name) AS canonical_item_name,
    COALESCE(m.category, 'Uncategorized') AS category,
    o.quantity,
    o.gross_amount,
    COALESCE(c.commission_pct, 0.30) AS commission_percentage,
    COALESCE(c.fixed_fee_per_order, 0.00) AS fixed_fee_per_order,
    -- Financial calculations: gross amount minus platform commission percentage and fixed fees
    ROUND(o.gross_amount * (1 - COALESCE(c.commission_pct, 0.30)) - COALESCE(c.fixed_fee_per_order, 0.00), 2) AS net_amount
FROM unioned_orders o
LEFT JOIN mapped_menu m 
    ON LOWER(TRIM(o.item_name)) = LOWER(TRIM(m.raw_item_name))
LEFT JOIN commissions c
    ON LOWER(TRIM(o.platform)) = LOWER(TRIM(c.channel))
    AND LOWER(TRIM(o.delivery_type)) = LOWER(TRIM(c.delivery_type))