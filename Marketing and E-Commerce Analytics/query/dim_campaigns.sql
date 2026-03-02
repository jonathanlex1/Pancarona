use e_commerce_marketing_analysis;

select * from campaigns;

-- formatting column
select	campaign_id,
		CONCAT('Campaign_', campaign_id) as campaign_name, 
		channel, objective,
		FORMAT(start_date, 'dd/MM/yyyy') as start_date, -- changing date format
		FORMAT(end_date, 'dd/MM/yyyy') as end_date, -- changing date format
		target_segment,
		round(expected_uplift, 2) as expected_uplift,
		DATEDIFF(DAY, start_date, end_date) as day_duration, -- adding new feature
		DATEDIFF(month, start_date, end_date) as month_duration -- adding new feature
from campaigns;

-- checking problem values in objective columns
select distinct objective from campaigns;

-- checking problem values in channel columns
select distinct channel from campaigns;

-- checking problem values in target_segment column
select distinct target_segment from campaigns;

-- checking duplicate values 
with cte as (select campaign_id, channel, objective, start_date, end_date, target_segment, expected_uplift,
		ROW_NUMBER() over (partition by channel, objective, start_date, end_date, target_segment, expected_uplift order by campaign_id) as row_num
from campaigns)
select * from cte 
where row_num > 1;

