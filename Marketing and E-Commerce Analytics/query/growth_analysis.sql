use e_commerce_customer_and_marketing_analytics;

-- Growth analisis

-- Total revenue, total order, total customer, AOV, berdasarkan waktu 
with cte as (select 
DATETRUNC(month, timestamp) as month_date,
round(sum(gross_revenue),2) as total_revenue, 
count(distinct case when refund_flag = 0 then transaction_id end) as total_order, 
count(distinct case when refund_flag = 0 then customer_id end) as total_customer 
from fact_transactions
group by 
DATETRUNC(month, timestamp))
select 
month_date, 
total_revenue,
total_order, 
total_customer,
round(total_revenue/total_order, 2) as AOV,
round(total_revenue/total_customer,2) as revenue_per_customer,
round((total_revenue - LAG(total_revenue) over (order by month_date))*1.0/LAG(total_revenue) over (order by month_date) * 100, 2) as mom_revenue_diff,
round((total_order - LAG(total_order) over (order by month_date))*1.0/LAG(total_order) over (order by month_date) * 100, 2) as mom_order_diff,
round((total_customer - LAG(total_customer) over (order by month_date))*1.0/LAG(total_customer) over (order by month_date) * 100, 2) as mom_customer_diff
from cte

-- Insight : 
-- Kenaikan revenue tertinggi terjadi selama 3 tahun berturut-turut pada bulan Nov (~19 - ~20) yang diikuti dengan kenaikan total pemesanan dan total customer
-- Kenaikan revenue tersebut diakibatkan total pesanan meningkatkan (peningkatan pesanan > peningkatan total customer)
-- Lalu terjadi penurunan yang drastis di tiap awal Bulan Januari selama 2 tahun berturut (~24-~29) yang diikuti dengan penurunan total pemesanan dan total customer
-- Penurunan tersebut tersebut diakibatkan total pesanan yang menurun (dimanaa persentase penurunan pemesanana = 29% > persentase penurunan customer = 28%)

