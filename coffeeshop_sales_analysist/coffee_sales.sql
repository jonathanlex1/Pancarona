use coffee_sales_db;

-- What is the total revenue generated from all transactions ? 
select round(sum(total_payment), 2) as total_sales from lower_manhattan;

-- What is the total quantity of products sold across all transactions ? 
select sum(transaction_qty) as total_quantity_sold from lower_manhattan;

-- How many customers have made transactions ?
select count(transaction_id) as total_customers from lower_manhattan;

-- What is the average revenue generated per transaction ?
select round(sum(total_payment) / count(total_payment), 2) as avg_sales from lower_manhattan;

-- What is the average number of products sold per transaction ? 
select round(sum(transaction_qty) / count(transaction_qty), 2) as avg_customer_transaction_quantity from lower_manhattan;

-- How does each product category contribute to total sales, and what is the percentage contribution?
with cte as (select product_category, sum(transaction_qty) as total_transaction, sum(total_payment) as total_sales
from lower_manhattan
group by product_category
) 
select product_category,total_sales, concat(total_sales/(select sum(total_sales) from cte)*100, '%') as percentage from cte
order by total_sales/(select sum(total_sales) from cte)*100 desc;

-- During which hour do transactions generate the most revenue ? 
select sum(total_payment) as total_sales, datepart(hour, transaction_datetime) as hour from lower_manhattan
group by datepart(hour, transaction_datetime)
order by datepart(hour, transaction_datetime) asc

-- What is the monthly profit growth based on total sales ? 
with cte as (select datename(month,transaction_datetime) as month, round(sum(total_payment), 2) as total_sales, 
		datepart(month, transaction_datetime) as month_num  from lower_manhattan
group by datename(month,transaction_datetime),datepart(month,transaction_datetime))
select month, total_sales - lag(total_sales, 1) over (order by month_num) as profit from cte;

-- Which products have the highest and lowest total sales ? 
select top(10) sum(total_payment) as sales, product_detail from lower_manhattan 
group by product_detail	
order by sales desc;

select top(10) cast(sum(total_payment) as decimal (10,2)) as sales, product_detail from lower_manhattan 
group by product_detail	
order by sales asc;


-- Which products are the most expensive and cheapest based on unit price ? 
-- expensive products 
with cte as (
    select distinct unit_price, product_detail
    from lower_manhattan
)
select top 10 unit_price, product_detail
from cte
order by unit_price desc

--cheapest products 
select top 10 cast(unit_price as decimal (10,2)), product_detail from (select distinct unit_price, product_detail 
											from lower_manhattan) as unique_products
order by unit_price asc 

-- Which products are the most and least frequently purchased by customers ?
-- most 
select top 10 count(transaction_id) as customer_count, product_detail from lower_manhattan
group by product_detail 
order by customer_count desc

--least
select top 10 count(transaction_id) as customer_count, product_detail from lower_manhattan
group by product_detail 
order by customer_count asc

-- On which day of the week do transactions generate the highest revenue ?
select datename(weekday,transaction_datetime) as day, round(sum(total_payment), 2) as total_sales from lower_manhattan
group by datename(weekday,transaction_datetime) 
order by total_sales desc

-- On which day of the week do certain product categories sell the most ? 
select datename(weekday, transaction_datetime) as day, product_category, sum(transaction_qty) as total_transaction,
				datepart(day, transaction_datetime) as day_num from lower_manhattan
group by datename(weekday, transaction_datetime), product_category, datepart(day, transaction_datetime)
order by total_transaction desc

-- What is the average price of each product category ?   
with cte as (select distinct product_category, product_detail, round(unit_price, 2) as price from lower_manhattan) 
select product_category, round(sum(price)/count(product_detail), 2) as avg_price from cte 
group by product_category
order by avg_price desc

-- Which coffee products have the highest sales and transaction volumes ? 
select product_detail, round(sum(total_payment), 2) as total_sales, round(sum(transaction_qty), 2) as total_transaction from lower_manhattan 
where product_category = 'Coffee'
group by product_detail 
order by total_sales desc

-- Which tea products have the highest sales and transaction volumes ?  
select product_detail, round(sum(total_payment), 2) as total_sales, round(sum(transaction_qty), 2) as total_transaction from lower_manhattan 
where product_category = 'Tea'
group by product_detail 
order by total_sales desc

-- How is the price distribution of products based on unit price ? 
select unit_price, count(*) as product_count, sum(total_payment) as total_sales from lower_manhattan 
group by unit_price
order by unit_price

select * from lower_manhattan