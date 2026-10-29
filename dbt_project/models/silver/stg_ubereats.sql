select
    cast(order_id as varchar) as order_id,
    cast(order_date as timestamp) as order_date,
    'Uber Eats' as platform,
    cast(delivery_type as varchar)as delivery_type,
    cast(item_name as varchar) as item_name,
    cast(quantity as integer) as quantity,
    cast(gross_amount as decimal (10,2)) as gross_amount
from {{source('kitchen_lads', 'raw_ubereats')}}

