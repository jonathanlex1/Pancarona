use e_commerce_customer_and_marketing_analytics;

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
-- persentase kenaikan returning customer yang melakukan transaksi mencapai yang tertinggi 54% pada bulan 11 tahun 2021, kenaikan revenue pada periode tersebut dikarenakan retention customer (customer sudah trust, customer lama repeat purchase)
-- kenaikan customer pada tahun 2022 bulan 11 didominasi oleh kenaikan new customer 30% dibandingkan returning 27%, kenaikan revenue pada periode tersebut disebabkan acquisition-driven
-- knaikan customer pada tahun 2023 bulan 11 didominasi oleh kenaikan returning 25% dibandingkan kenaikan new customer 24%, kembali kenaikan revenue disebabkan retention customer
-- pola ini mengindikasikan bahwa strategit akuisisi new customer pada tahun sebelumnya dapat membangun customer yang loyal/retention

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
sum(case when customer_status = 'New Customer' then gross_revenue end) as new_customer_revenue
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
-- tahun 2021, bulan 11 kenaikan persentase revenue didominasi pada returning customer sebesar 45% dan new customer 19%, revenue meningkat dikarenakan retention driven, customer yang loyal kembali untuk belanja, tetapi revenue share contribution terbanyak oleh new customer 74%
-- tahun 2022, bulan 11 kenaikan persentase revenue didominasi pada returning customer sebesar 12% dan new customer 34%, revenue meningkat dikarenakan akuisis new customer driven, dimana acquisition campaign berhasil dan banyak customer pertama kali membeli dan revenue share contribution terbanyak pada new customer 55%
-- tahun 2023, bulan 11 kenaikan persentase revenue didominasi pada returning customer sebesar 25% dan new customer 27%, revenue meningkat dikarenekan kestabilan antara new customer dan retention, mengindikasikan keberhasilan acquisiont driven campaign pada tahun sebelumnya dan customer yang loyal, dengan revenue contribution yang terbanyak oleh customer yang loyal sebesar 62%

-- Customer Purchase Frequency

-- Avg Order
select count(distinct transaction_id) * 1.0/count(distinct customer_id) as avg_order from fact_transactions
where refund_flag = 0;
-- Insight
-- rata rata pemesanan dilakukan 1x 

-- New Customer vs Returning Customer by average order Trend
with first_transaction_customer as (
select 
customer_id, 
min(timestamp) as first_transaction_date
from fact_transactions
group by customer_id),
customer_labelling as (select 
datetrunc(month, t.timestamp) as monthly_date, 
t.transaction_id,
t.customer_id,
case when t.timestamp = f.first_transaction_date then 'New Customer' else 'Returning Customer' end as customer_type
from fact_transactions t
join first_transaction_customer f on t.customer_id = f.customer_id),
customer_order as (select 
monthly_date, 
customer_type,
customer_id,
count(distinct transaction_id) as total_order
from customer_labelling
group by monthly_date, customer_type, customer_id)
select 
monthly_date, 
customer_type, 
avg(total_order) as avg_order_per_customer
from customer_order
group by monthly_date, customer_type
order by monthly_date
-- Insight 
-- Rata rata transaksi yang dilakukan oleh new customer dan returning perbulannya hanya selama 3 tahun 
-- Kenaikan revenue tidak bergantung pada loyalty tetapi acquisition


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
order by first_order_month

-- Insight 
-- CLV pada bulan 11 ~143 dan CLV tertinggi pada bulan 1 ~166 pada tahun 2021
-- CLV pada bulan 11 ~114 dan CLV tertinggi pada bulan 1 ~136 pada tahun 2022
-- CLV pada bulan 11 ~85 dan CLV tertinggi pada bulan 1 ~106 pada tahun 2023
-- Dengan total order yang stagnan (1)
-- Kenikan revenue pada bulan 11 bukan karena kualitas customer yang bernilai melainkan banyak customer (customer datang, beli sekali, selesai)
-- kemungkinan dikarenan promo masif, campaign besar, acquisition tinggi, discount driven purchase 
-- CLV rendah pada bulan 1, customer lebih spending besar atau sedikit refund atau organic purchase/tanpa promo,campaign,acquisition (customer lebih bernilai)
-- penurunan revenue pada bulan januari bukan karena customer tetapi jumlah customer acquision tidak bertahan 

-- Akan dianalisi bagaimana pola campaign sebelum bulan 11 dan setelah bulan 11 ?