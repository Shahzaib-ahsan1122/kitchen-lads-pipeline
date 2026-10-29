select 
    canonical_item_name,
    category,
    sum(quantity)as total_quantity_sold,
    sum(gross_amount) as total_gross_revenue
from {{ref('int_unified_orders')}}
group by canonical_item_name, category
order by total_quantity_sold desc