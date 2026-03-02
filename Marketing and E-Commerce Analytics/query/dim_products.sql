use e_commerce_marketing_analysis;

-- Cleaning data
with cte as (select 
	product_id, category,
	replace(brand, '_', ' ') as brand, --Replacing symbol
	round(base_price, 2) as base_price,  -- round price
	FORMAT(launch_date, 'dd/MM/yyyy') as launch_date, -- changing date format
	is_premium
	from products)

select * from cte;

-- Checking duplicate number
with cte as (select 
	*,
	ROW_NUMBER() over (partition by product_id, category, brand, base_price order by product_id) as row_num
	from products)

select * from cte
where row_num > 1;