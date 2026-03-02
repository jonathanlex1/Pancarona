use e_commerce_customer_and_marketing_analytics;


select 
	t.timestamp,
	c.signup_date,
	t.transaction_id, 
	t.customer_id, 
	t.quantity, 
	t.gross_revenue, 
	t.refund_flag,
	c.loyalty_tier,
	c.age
from fact_transactions t
join dim_customers c on t.customer_id = c.customer_id

select * from dim_customers


select 
DATETRUNC(month, t.timestamp) as monthly_date,
sum(case when c.loyalty_tier = 'Platinum' then 1 else 0 end) as total_platinum,
sum(case when c.loyalty_tier = 'Gold' then 1 else 0 end) as total_gold,
sum(case when c.loyalty_tier = 'Silver' then 1 else 0 end) as total_silver,
sum(case when c.loyalty_tier = 'Bronze' then 1 else 0 end) as total_bronze
from fact_transactions t
join dim_customers c on t.customer_id = c.customer_id
group by DATETRUNC(month, t.timestamp)
order by DATETRUNC(month, t.timestamp);


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
from agg_customer

-- Insight 
-- persentase kenaikan revenue pada masing masing tipe new dan returning berbeda beda pada tiap bulan 11 selama 3 tahun 
-- tahun 2021, bulan 11 kenaikan persentase revenue didominasi pada returning customer sebesar 45% dan new customer 19%, revenue meningkat dikarenakan retention driven, customer yang loyal kembali untuk belanja, tetapi revenue share contribution terbanyak oleh new customer 74%
-- tahun 2022, bulan 11 kenaikan persentase revenue didominasi pada returning customer sebesar 12% dan new customer 34%, revenue meningkat dikarenakan akuisis new customer driven, dimana acquisition campaign berhasil dan banyak customer pertama kali membeli dan revenue share contribution terbanyak pada new customer 55%
-- tahun 2023, bulan 11 kenaikan persentase revenue didominasi pada returning customer sebesar 25% dan new customer 27%, revenue meningkat dikarenekan kestabilan antara new customer dan retention, mengindikasikan keberhasilan acquisiont driven campaign pada tahun sebelumnya dan customer yang loyal, dengan revenue contribution yang terbanyak oleh customer yang loyal sebesar 62%
