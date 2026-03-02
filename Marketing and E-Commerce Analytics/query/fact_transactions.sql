use e_commerce_marketing_analysis;

-- Cleaning data
with cte as (
	select t.transaction_id, 
		FORMAT(CAST(t.timestamp as date), 'dd/MM/yyyy') as transaction_date,
		CAST(t.timestamp as time) as transaction_time,
		t.customer_id, t.product_id, t.quantity, 
		round(t.discount_applied, 2) as discount_applied, 
		round(t.gross_revenue, 2) as gross_revenue,
	campaign_id, refund_flag,
	(case 
		when refund_flag = 1 and quantity > 0 then refund_flag * quantity 
		else refund_flag
	end) as total_refund 
	from transactions t
	join products p on p.product_id = t.product_id)

select * from cte;

select * from products;
select * from transactions;

-- Checking duplicate values 
with cte as (select *,
	ROW_NUMBER() over (partition by timestamp,customer_id, product_id, quantity, 
	discount_applied,  gross_revenue, 
	campaign_id, refund_flag 
	order by transaction_id) as row_num
	from transactions)
select * from cte
where row_num > 1;


select * from transactions
where quantity < 1 or quantity is null; -- Checking apakah ada quantity yang null

select * from transactions;

-- Check apakah grosss revenue per produk konsisnten
with revenue_per_product as (
	select distinct product_id, abs(round(gross_revenue,2)) as gross_revenue from transactions
	where quantity = 1 and discount_applied = 0),
revenue_per_product2 as (
	select distinct product_id, abs(round((round(gross_revenue,2)/quantity),2)) as gross_revenue from transactions
	where discount_applied = 0)

select rp1.product_id, rp1.gross_revenue, rp2.gross_revenue from revenue_per_product rp1
left join revenue_per_product2 rp2 on rp1.product_id = rp2.product_id
where rp1.gross_revenue <> rp2.gross_revenue; 


-- Chekcing campaign_id, campaign_id = 0 adalah produk yang terjual tanpa ada campaign
select distinct campaign_id from transactions
order by campaign_id;

select * from transactions
where product_id is null and gross_revenue is null;