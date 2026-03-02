use e_commerce_marketing_analysis;

--changing date format (signup_date)
select customer_id, trim(format(signup_date, 'dd/MM/yyyy')) as signup_date,
		country, age, gender, loyalty_tier, acquisition_channel
from customers;