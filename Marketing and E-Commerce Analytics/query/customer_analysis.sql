use e_commerce_customer_and_marketing_analytics;

-- New Customer vs Returning Customer by Total Order
with first_transaction as (
select 
customer_id, 
min(timestamp) as first_transaction_date 
from fact_transactions
group by customer_id),
customer_status as (
select 
t.timestamp,
t.customer_id,
case when t.timestamp = f.first_transaction_date then 'New Customer' else 'Returning Customer' end as customer_status
from fact_transactions t
join first_transaction f on t.customer_id = f.customer_id),
agg_customer as (
select 
datetrunc(month, timestamp) as monthly_date,
count(distinct case when customer_status = 'Returning Customer' then customer_id end) as total_returning_customer,
count(distinct case when customer_status = 'New Customer' then customer_id end) as total_new_customer
from customer_status
group by datetrunc(month, timestamp)
)
select 
*,
round((total_returning_customer - lag(total_returning_customer) over (order by monthly_date)) * 1.0 / lag(total_returning_customer) over (order by monthly_date), 2) * 100 as returning_diff,
round((total_new_customer - lag(total_new_customer) over (order by monthly_date)) * 1.0 / lag(total_new_customer) over (order by monthly_date), 2) * 100 as new_diff
from agg_customer;

-- Insight 
-- perbandingan proporsi antara new customer dan returning customer sangat berbeda, new customer ~2500 dan returning customer ~900
-- persentase kenaikan returning customer yang melakukan transaksi mencapai yang tertinggi 54% pada bulan 11 tahun 2021, kenaikan revenue pada periode tersebut kemungkinan dikarenakan retention customer (customer sudah trust, customer lama repeat purchase) atau adanya campaign atau promo sehingga dapat mendapatkan acquision new customer
-- kenaikan customer pada bulan 11 tahun 2022  didominasi oleh kenaikan new customer 30% dibandingkan returning 27%, kenaikan revenue pada periode tersebut disebabkan acquisition-driven
-- knaikan customer pada bulan 11 tahun 2023  didominasi oleh kenaikan returning 25% dibandingkan kenaikan new customer 24% dengan proporsi returning customer ~2100 dan new customer ~1300, kembali kenaikan revenue disebabkan retention customer
-- pola ini mengindikasikan bahwa strategi akuisisi new customer pada tahun sebelumnya dapat membangun customer yang loyal/retention


-- New Customer vs Returning Customer by Revenue
with first_transaction as (
select 
customer_id, 
min(timestamp) as first_transaction_date 
from fact_transactions
group by customer_id),
customer_status as (
select 
t.timestamp,
t.customer_id,
t.gross_revenue,
case when t.timestamp = f.first_transaction_date then 'New Customer' else 'Returning Customer' end as customer_status
from fact_transactions t
join first_transaction f on t.customer_id = f.customer_id),
agg_customer as (
select 
datetrunc(month, timestamp) as monthly_date,
sum(case when customer_status = 'Returning Customer' then gross_revenue end) as returning_customer_revenue,
round(sum(case when customer_status = 'Returning Customer' then gross_revenue end)/count( distinct case when customer_status = 'Returning Customer' then customer_id end), 2) as AOV_returning_customer,
sum(case when customer_status = 'New Customer' then gross_revenue end) as new_customer_revenue, 
round(sum(case when customer_status = 'New Customer' then gross_revenue end) / count(distinct case when customer_status = 'New Customer' then customer_id end),2) as AOV_new_customer
from customer_status
group by datetrunc(month, timestamp)
)
select 
*,
round((returning_customer_revenue - lag(returning_customer_revenue) over (order by monthly_date)) * 1.0 / lag(returning_customer_revenue) over (order by monthly_date), 2) * 100 as returning_diff,
round((new_customer_revenue - lag(new_customer_revenue) over (order by monthly_date)) * 1.0 / lag(new_customer_revenue) over (order by monthly_date), 2) * 100 as new_diff,
round(returning_customer_revenue*1.0 / (returning_customer_revenue + new_customer_revenue), 2) as returning_revenue_share_contribution,
round(new_customer_revenue*1.0 / (returning_customer_revenue + new_customer_revenue), 2) as new_revenue_share_contribution
from agg_customer;

-- Insight 
-- persentase kenaikan revenue pada masing masing tipe new dan returning berbeda beda pada tiap bulan 11 selama 3 tahun 
-- tahun 2021, bulan 11 kenaikan persentase revenue didominasi pada returning customer sebesar 45% dan new customer 19% tetapi revenue share contribution 74% pada new customer
-- tahun 2022, bulan 11 kenaikan persentase revenue didominasi pada new customer sebesar 34% dan returning customer 12%, dengan revenue contribution didomnasi oleh new customer 55%
-- tahun 2023, bulan 11 kenaikan persentase revenue didominasi pada new customer sebesar 27% dan returning customer 25%, dengan revenue contribution didominasi oleh returning custoemr 62%
-- Peningkatan new customer di tahun awal membuat returning customer semakin meningkat pada tahun 2023, customer loyal/memercayakan pada produk 

-- Customer Purchase Frequency
-- Avg Order
select count(distinct transaction_id) * 1.0/count(distinct customer_id) as avg_order from fact_transactions
where refund_flag = 0;
-- Insight
-- rata rata pemesanan dilakukan 1x 

-- New Customer vs Returning Customer by average order and AOV Trend
with first_transaction_customer as (
select 
customer_id, 
min(timestamp) as first_transaction_date
from fact_transactions
group by customer_id),
customer_labelling as (select 
datetrunc(month, t.timestamp) as monthly_date, 
t.transaction_id,
t.gross_revenue,
t.customer_id,
case when t.timestamp = f.first_transaction_date then 'New Customer' else 'Returning Customer' end as customer_type
from fact_transactions t
join first_transaction_customer f on t.customer_id = f.customer_id),
customer_order as (select 
monthly_date, 
customer_type,
customer_id,
count(distinct transaction_id) as total_order,
round(sum(gross_revenue)*1.0/count(distinct transaction_id), 2) as AOV
from customer_labelling
group by monthly_date, customer_type, customer_id)
select 
monthly_date, 
customer_type, 
avg(total_order) as avg_order_per_customer,
avg(AOV) as avg_aov
from customer_order
group by monthly_date, customer_type
order by monthly_date
-- Insight 
-- Rata rata transaksi yang dilakukan oleh new customer dan returning perbulannya hanya sekali selama 3 tahun 
-- AOV pada tahun 2021-2022 lebih didominasi oleh new customer dan AOV pada tahun 2023 didominasi oleh returning customer


-- Apakah customer membeli langsung beberapa produk dalam sekali pesanan ?

-- Avg quantity product sold by a customer trend
select
datetrunc(month,timestamp) as monthly_date,
sum(quantity)*1.0/count(distinct customer_id) as avg_quantity_per_customer
from fact_transactions
where refund_flag = 0
group by datetrunc(month,timestamp)
order by datetrunc(month,timestamp);
-- rata rata total item yang terjual di tiap bulanya = 1 dan stagnan selama 3 tahun  
-- kenaikan revenue pada tiap bulan 11, tidak dipengaruhi oleh purchase frequency tetapi kemungkinan harga produk yang mahal laris 
-- retention customer dan new customer hanya melakukan sekali order dan quantity yang dibeli ~1 

-- CLV (Customer Lifetime Value)
-- Berapa keuntungan yang didapatkan pada 1 customer ?
with clv as (select 
customer_id,
datetrunc(month, min(timestamp)) as first_order_month,
sum(gross_revenue) as customer_lifetime_value,
count(distinct transaction_id) as total_order,
DATEDIFF(day, min(timestamp), max(timestamp)) as lifetime
from fact_transactions
group by customer_id)
select 
first_order_month,
avg(customer_lifetime_value) as avg_clv,
avg(total_order) as avg_order, 
avg(lifetime) as avg_lifetime
from clv
group by first_order_month
order by first_order_month;

-- Insight 
-- CLV pada bulan 11 ~143 dan CLV tertinggi pada bulan 1 ~166 pada tahun 2021
-- CLV pada bulan 11 ~114 dan CLV tertinggi pada bulan 1 ~136 pada tahun 2022
-- CLV pada bulan 11 ~85 dan CLV tertinggi pada bulan 1 ~106 pada tahun 2023
-- Dengan total order yang stagnan (1)
-- Kenikan revenue pada bulan 11 bukan karena kualitas customer yang bernilai melainkan banyak customer (customer datang, beli sekali, selesai)
-- kemungkinan dikarenan promo masif, campaign besar, acquisition tinggi, discount driven purchase 
-- CLV rendah pada bulan 1, customer lebih spending besar atau sedikit refund atau organic purchase/tanpa promo,campaign,acquisition (customer lebih bernilai)
-- penurunan revenue pada bulan januari bukan karena customer tetapi jumlah customer acquision tidak bertahan 


-- Cohort Retention Analysis 
-- Untuk melihat apakah customer pertama yang telah belanja di bulan 11 akan kembali lagi pada bulan 12, 1
-- sehingga dapat mengidentifikasi customer yang loyal atau hanya 1 time buyer

with first_transaction as (
	select customer_id, 
	datetrunc(month, min(timestamp)) as cohort_month
	from fact_transactions
	where refund_flag = 0
	group by customer_id
),
november_cohort as ( 
select * from first_transaction
where month(cohort_month) = 11),

customer_activity as (
select
	n.customer_id, 
	n.cohort_month,
	datetrunc(month, t.timestamp) activity_month
from fact_transactions t
join november_cohort n on t.customer_id = n.customer_id
where t.refund_flag = 0 
),
cohort_index as (
	select customer_id, 
	cohort_month, 
	activity_month,
	DATEDIFF(month, cohort_month, activity_month) as cohort_idx
	from customer_activity
)

select 
cohort_month, 
cohort_idx, 
count(distinct customer_id) as active_customer
from cohort_index
group by cohort_month, cohort_idx
order by cohort_month

-- Insight :
-- Selama 3 tahun berturut, total customer yang active sangat masive di Bulan November (1000 - 2400) dan terjadi penurunan drastis di Bulan Selanjutnya, yang menandakan customer hanya melakukan sekali pembelian pada bulan November
-- Tetapi tetap masih ada customer yang loyal dari November sampai ke Desember walaupun sedikit <100 dan stabil

-- Bagaimana pola promo di bulan 11 apakah seasonal acquisioni terjadi karena promo ? 
select 
datetrunc(month, timestamp) as monthly_transaction,
sum(discount_applied) as total_discount_applied,
avg(discount_applied) as avg_discount_applied,
count(distinct(case when discount_applied > 0 then customer_id end)) as total_customer_use_discount,
count(distinct(case when discount_applied = 0 then customer_id end)) as total_customer_no_discount,
count(distinct(case when discount_applied > 0 then transaction_id end)) as total_order_use_discount,
count(distinct(case when discount_applied = 0 then transaction_id end)) as total_order_no_discount
from fact_transactions
group by datetrunc(month, timestamp)
order by datetrunc(month, timestamp)
-- Insight : 
-- Total discount applied dan avg discount mengalami kenaikan tertinggi pada bulan 11 selama 3 tahun
-- Total customer yang menggunakan discount mengalami kenaikan tertinggi tetapi lebih banyak customer yang melakukan transaksi tanpa promo selama 3 tahun pada bulan 11
-- Total order yang menggunakan discount mengalami kenaikan tertinggi tetapi lebih banyak total order tanpa promo selama 3 tahun pada bulan 11
-- Lalu penurunan pada bulan 1, tetap total customer dan total order lebih didominasi tanpa promo

-- Acquisition channel customer untuk memastikan apakah customer alami atau tidak
select 
datetrunc(MONTH, f.timestamp) as month_transaction,
count(distinct case when c.acquisition_channel = 'Email' then f.customer_id end) as total_from_email,
count(distinct case when c.acquisition_channel = 'Organic' then f.customer_id end) as total_from_organic,
count(distinct case when c.acquisition_channel = 'Paid Search' then f.customer_id end) as total_from_paid_search,
count(distinct case when c.acquisition_channel = 'Referral' then f.customer_id else 0 end) as total_from_referral,
count(distinct case when c.acquisition_channel = 'Social' then f.customer_id else 0 end) as total_from_social
from 
fact_transactions f
join dim_customers c on f.customer_id = c.customer_id
group by datetrunc(MONTH, f.timestamp)
order by datetrunc(MONTH, f.timestamp)
-- Insight :
-- Acquision tertinggi pada Organic dan Paid search secara konsisten (~1000 - ~1100) pada bulan november selama 3 tahun berturut-turut
-- Secara keseluruhan selama 3 tahun total order dari customer acquision pada bulan 11 didapatkan secara organic dan melalui paid search bukan promo driven 
-- Kenaikan revenue tidak sepenuhnya dipengaruhi oleh discount/promo. Meskipun nilai discount meningkat, mayoritas transaksi dan customer tidak dipengaruhi oleh promo.
-- Peningkatan akuisisi customer yang berasal dari Organic dan paid search mengindikasikan bahwa kenaikan revenue lebih dipengaruhi oleh peningkatan kebutuhan musiman dibandingkan dengan promo-driven purchasing 

-- Revenue by Loyalty Tier
select 
DATETRUNC(month, t.timestamp) as monthly_date,
sum(case when c.loyalty_tier = 'Platinum' then gross_revenue end) as revenue_platinum,
sum(case when c.loyalty_tier = 'Gold' then gross_revenue end) as revenue_gold,
sum(case when c.loyalty_tier = 'Silver' then gross_revenue end) as revenue_silver,
sum(case when c.loyalty_tier = 'Bronze' then gross_revenue end) as revenue_bronze
from fact_transactions t
join dim_customers c on t.customer_id = c.customer_id
group by DATETRUNC(month, t.timestamp)
order by DATETRUNC(month, t.timestamp);
-- Kenaikan revenue pada tiap bulan 11 paling dipengaruhi oleh customer dengan loyalty tipe tier bronze 

