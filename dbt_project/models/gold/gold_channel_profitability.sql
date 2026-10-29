select
    platform,
    count(distinct order_id) as total_orders,
    sum(gross_amount) as total_gross_sales,
    sum(net_amount) as total_net_sales,
    round(avg(gross_amount),2) as average_order_value
from {{ ref('int_unified_orders')}}
group by platform 
order by total_net_sales desc
