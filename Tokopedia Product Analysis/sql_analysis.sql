use e_commerce_analysis;

-- total products
select count(distinct product_name) as total_products from products;

-- total units sold 
select sum(sold_count) as total_units_sold from products;

-- average product rating 
select avg(rating_number) as product_rating from products;

-- average satisfaction 
select round(avg(satisfaction*100),2) as average_satisfaction from products;

-- shop rating average
select round(avg(shop_rating),1) as shop_rating from products;

-- top 10 cheapest products by price 
select top 10 product_name,avg(product_price) as price from products
group by product_name
order by avg(product_price) asc

-- top 10 shops by total rating  
select top 10 shop_name, sum(shop_rating_counter) as total_rating from products
group by shop_name
order by sum(shop_rating_counter) desc

-- top 10 running shoes by units sold 
select top 10 product_name, sum(sold_count) as units_sold from products
group by product_name
order by sum(sold_count) desc

-- customer satisfaction percentage by units sold
with cte as(
	select satisfaction_range, sum(sold_count) as total_sold from products
	group by satisfaction_range 
)
select satisfaction_range, concat(round(total_sold*100.0/(select sum(total_sold) from cte), 2),'%') as percentage_share 
from cte
order by percentage_share desc;

-- rating percentage by units sold 
with cte as (
	select rating_number, count(product_name) as total_product from products
	group by rating_number
)
select rating_number, concat(total_product*100.0/(select sum(total_product) from cte),'%') as percentage_rating from cte
order by percentage_rating desc;

	