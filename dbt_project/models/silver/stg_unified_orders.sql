WITH unioned_raw AS (
    SELECT order_id, platform AS channel, delivery_type, item_name, gross_amount, order_date FROM {{ source('raw', 'raw_ubereats') }}
    UNION ALL
    SELECT order_id, platform AS channel, delivery_type, item_name, gross_amount, order_date FROM {{ source('raw', 'raw_deliveroo') }}
    UNION ALL
    SELECT order_id, platform AS channel, delivery_type, item_name, gross_amount, order_date FROM {{ source('raw', 'raw_justeat') }}
    UNION ALL
    SELECT order_id, platform AS channel, delivery_type, item_name, gross_amount, order_date FROM {{ source('raw', 'raw_foodhub') }}
),

mapped_items AS (
    SELECT 
        u.*,
        COALESCE(m.canonical_item_name, 'UNMAPPED: ' || u.item_name) AS canonical_item_name,
        COALESCE(m.category, 'Uncategorized') AS category
    FROM unioned_raw u
    LEFT JOIN {{ ref('menu_mapping') }} m 
        ON u.item_name = m.raw_item_name
)

SELECT 
    m.order_id,
    m.channel,
    m.delivery_type,
    m.order_date,
    m.item_name AS raw_item_name,
    m.canonical_item_name,
    m.category,
    m.gross_amount,
    -- Financial Calculations using Commission Matrix Seed
    COALESCE(c.commission_pct, 0.30) AS commission_pct,
    COALESCE(c.vat_pct, 0.20) AS vat_pct,
    COALESCE(c.fixed_fee_per_order, 0.00) AS fixed_fee_per_order,
    
    -- Total Commission & VAT Fee Deducted
    (m.gross_amount * COALESCE(c.commission_pct, 0.30) * (1 + COALESCE(c.vat_pct, 0.20))) + COALESCE(c.fixed_fee_per_order, 0.00) AS total_fees,
    
    -- Net Payout Landing in Bank
    m.gross_amount - ((m.gross_amount * COALESCE(c.commission_pct, 0.30) * (1 + COALESCE(c.vat_pct, 0.20))) + COALESCE(c.fixed_fee_per_order, 0.00)) AS net_payout
FROM mapped_items m
LEFT JOIN {{ ref('platform_commissions') }} c 
    ON m.channel = c.channel 
   AND m.delivery_type = c.delivery_type