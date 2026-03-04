-- Kategori produk berdasarkan revenue 
select 
	p.category,
	sum(f.gross_revenue) as revenue
from fact_transactions f
join dim_products p on p.product_id = f.product_id
where p.category != 'Unknown'
group by p.category
order by sum(f.gross_revenue) desc

--Total order, revenue, total quantity sold by Category over Trend
with product_base as (select 
f.timestamp,
p.category,
f.transaction_id,
f.quantity,
f.gross_revenue,
f.refund_flag
from fact_transactions f 
join dim_products p on f.product_id = p.product_id
where p.category != 'Unknown')
select 
DATETRUNC(month, timestamp) as monthly_transaction,
category,
count(case when refund_flag = 0 then transaction_id end) as total_order,
sum(case when refund_flag = 0 then quantity end) as total_quantity,
sum(gross_revenue) as total_revenue,
count(case when refund_flag=1 then transaction_id end)*1.0/ count(transaction_id) * 100 as refund_rate
from product_base
group by DATETRUNC(month, timestamp), category
order by DATETRUNC(month, timestamp), sum(gross_revenue) desc


