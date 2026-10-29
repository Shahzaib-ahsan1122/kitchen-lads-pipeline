select  
    platform ,
    extract(hour from order_date) as order_hour,
    count(distinct order_id) as total_orders,
    sum(gross_amount) as total_gross_revenue
from {{ref('int_unified_orders')}}
group by platform, extract(hour from order_date)
order by order_hour asc, total_gross_revenue desc