use e_commerce_marketing_analysis;

-- checking duplicates 
with cte as (select *,
	 ROW_NUMBER() over (partition by event_id, timestamp, customer_id, session_id, event_type, product_id, device_type, campaign_id, session_duration_sec, experiment_group order by event_id) as row_num 
from events) 
select * from cte 
where row_num > 1;

select distinct event_type from events;

-- Cleaning data
with cte as (select event_id, 
format(CAST(timestamp as date), 'dd/MM/yyyy') as event_date,
CAST(timestamp as time) as event_time,
customer_id, session_id,  
replace(concat(upper(left(event_type, 1)), right(event_type, len(event_type)-1)), '_', ' ') as event_type, 
product_id, nullif(concat(upper(left(device_type,1)), right(device_type, len(device_type)-1)), '') as device_type,
concat(upper(left(lower(traffic_source), 1)), right(lower(traffic_source), len(traffic_source)-1)) as traffic_source , 
campaign_id, page_category, 
round(session_duration_sec,2) as session_duration, 
replace(experiment_group, '_', ' ') as experiment_group
from events)

select * from cte;



