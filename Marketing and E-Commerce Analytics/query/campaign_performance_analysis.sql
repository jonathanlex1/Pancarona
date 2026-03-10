use e_commerce_customer_and_marketing_analytics;

-- Tahun 2021, membludaknya new customer sebanyak (~2000 an) dibandingkan dengan retention customer yang masih ratusan, sehingga revenue yang didapatkan lebih besar dibandingkan retention
-- di tahun 2022, total returning customer mengalami kenaikan hingga ~1700 pada bulan 12, namun total new customer turun dan stabil (<2000)
-- pada tahun 2023, retention customer mengalami peningkatan dengan peak ~2000an pada bulan 11-12, dan new customer stagnan	dan total lebih rendah dari retention customer 
-- Analisis bagaimana performa campaign dalam mendapatkan customer (new customer dan retention)


-- Apakah new customer datang dari campaign atau non campaign, tahun 2021
with first_transaction as (
select 
customer_id, min(timestamp) as first_timestamp 
from fact_transactions
group by customer_id
)
select
c.objective, 
c.target_segment,
count(distinct ft.campaign_id) as total_campaign,
count(distinct case when ft.timestamp > t.first_timestamp then ft.customer_id end) as total_retention_customer,
count(distinct case when ft.timestamp = t.first_timestamp then ft.customer_id end) as total_new_customer,
sum(ft.gross_revenue) as total_revenue
from fact_transactions ft
join first_transaction t
on t.customer_id = ft.customer_id
left join dim_campaigns c 
on (ft.campaign_id = c.campaign_id) and (ft.timestamp between c.start_date and c.end_date)
where year(ft.timestamp) = 2021
group by
c.objective, 
c.target_segment
order by total_new_customer desc;
-- Tahun 2021, total new customer yang non-campaign lebih banyak dan menghasilkan revenue tertinggi dibandingkan dengan campaign
-- Semua campaign active pada tahun 2021 mendapatkan new customer yang banyak dibandingkan dengan retention customer, dimana total new customer (~164) semantara itu retention (~23)
-- Campaign dengan revenue tertinggi pada campaing objective reactivation dan target segment all dan new_customer dan campaign acquisition-new customers
-- Tingginya revenue lebih didapatkan new customer yang alami/tanpa  melalui campaign. tetapi banyak campaign yang berhasil mendapatkan new customer yang lebih banyak


-- analisis campaign yang aktif pada tahun 2021 monthly 
with first_transaction as (
select  
customer_id,
min(timestamp) as first_timestamp
from fact_transactions
group by customer_id
)
select 
DATETRUNC(month,t.timestamp) as monthly_transaction, 
d.objective,
d.target_segment,
count(distinct case when ft.first_timestamp = t.timestamp then t.customer_id end) as total_new_customer,
count(distinct case when ft.first_timestamp < t.timestamp then t.customer_id end) as total_retention_customer,
sum(t.gross_revenue) as total_revenue
from fact_transactions t
join first_transaction ft on t.customer_id = ft.customer_id
left join dim_campaigns d on t.campaign_id = d.campaign_id and t.timestamp between d.start_date and d.end_date
where year(t.timestamp) = 2021 
group by 
DATETRUNC(month,timestamp), 
d.objective,
d.target_segment
order by DATETRUNC(month,timestamp), total_revenue desc;
-- Insight : 
-- total customer revenue dan new customer tertinggi pada customer yanng tidak ada campaign/ campaign_id = 0
-- lonjakan tertinggi new customer tanpa campaign pada bulan 1 dengan total ~2700 tetapi revenue yang didapatkan masih rendah
-- revenue tertinggi terjadi di bulan 11 dan 12 yanng mencapai ~275000 pada customer tanpa campaign dengan total customer ~2300 - 2400 

-- Apakah new customer datang dari campaign atau non campaign, tahun 2022
with first_transaction as (
select 
customer_id, min(timestamp) as first_timestamp 
from fact_transactions
group by customer_id
)
select
c.objective, 
c.target_segment,
count(distinct t.campaign_id) as total_campaign,
count(distinct case when t.timestamp > f.first_timestamp then t.customer_id end) as total_retention_customer,
count(distinct case when t.timestamp = f.first_timestamp then t.customer_id end) as total_new_customer,
sum(t.gross_revenue) as total_revenue
from fact_transactions t
join first_transaction f
on f.customer_id = t.customer_id
left join dim_campaigns c 
on (t.campaign_id = c.campaign_id) and (t.timestamp between c.start_date and c.end_date)
where year(t.timestamp) = 2022 
group by
c.objective, 
c.target_segment
order by total_new_customer desc;
-- Secara keseluruhan, pada tahun 2022, campaign difokuskan pada campaign acquisition dan target segment new customers, dengan total campaign = 5, menghasilkan revenue tertinggi (~35700) dari campaign yang lainnya
-- Tetapi revenue yang dihasilkan tanpa campaign tertinggi secara keseluruhan dengan revenue ~2647000 dengan total retention customer ~11000 dan new customer ~19300

-- Analisis active campaign monthly 2022
with first_transaction as (
select  
customer_id,
min(timestamp) as first_timestamp
from fact_transactions
group by customer_id
)
select 
DATETRUNC(month,t.timestamp) as monthly_transaction, 
d.objective,
d.target_segment,
count(distinct t.campaign_id) as total_campaign,
count(distinct case when f.first_timestamp = t.timestamp then f.customer_id end) as total_new_customer,
count(distinct case when f.first_timestamp < t.timestamp then f.customer_id end) as total_retention_customer,
sum(t.gross_revenue) as total_revenue
from fact_transactions t
join first_transaction f on f.customer_id = t.customer_id
left join dim_campaigns d on t.campaign_id = d.campaign_id and t.timestamp between d.start_date and d.end_date
where year(t.timestamp) = 2022
group by 
DATETRUNC(month,timestamp), 
d.objective,
d.target_segment
order by DATETRUNC(month,timestamp), total_revenue desc;


-- Analisis campaign di 2023
-- Apakah new customer datang dari campaign atau non campaign, tahun 2023
with first_transaction as (
select 
customer_id, min(timestamp) as first_timestamp 
from fact_transactions
group by customer_id
)
select
c.objective, 
c.target_segment,
count(distinct t.campaign_id) as total_campaign,
count(distinct case when t.timestamp > f.first_timestamp then t.customer_id end) as total_retention_customer,
count(distinct case when t.timestamp = f.first_timestamp then t.customer_id end) as total_new_customer,
sum(t.gross_revenue) as total_revenue
from fact_transactions t
join first_transaction f
on f.customer_id = t.customer_id
left join dim_campaigns c 
on (t.campaign_id = c.campaign_id) and (t.timestamp between c.start_date and c.end_date)
where year(t.timestamp) = 2023 
group by
c.objective, 
c.target_segment
order by total_new_customer desc;


-- Analisis objective dan target segments campaign pada tahun 2023
select 
c.objective,
c.target_segment,
count(distinct f.customer_id) as total_customer,
sum(f.gross_revenue) as total_revenue,
count(distinct f.campaign_id) as total_campaign,
avg(c.expected_uplift) as avg_expected_uplift
from fact_transactions f
join dim_campaigns c on f.campaign_id = c.campaign_id
where (year(f.timestamp) <= 2023 and year(f.timestamp) > 2022) and year(c.start_date) > 2022
group by objective, target_segment
order by total_revenue desc;


-- Analisis campaign monthly 2023
with first_transaction as (
select  
customer_id,
min(timestamp) as first_timestamp
from fact_transactions
group by customer_id
)
select 
DATETRUNC(month,t.timestamp) as monthly_transaction, 
d.objective,
d.target_segment,
count(distinct t.campaign_id) as total_campaign,
count(distinct case when f.first_timestamp = t.timestamp then f.customer_id end) as total_new_customer,
count(distinct case when f.first_timestamp < t.timestamp then f.customer_id end) as total_retention_customer,
sum(t.gross_revenue) as total_revenue
from fact_transactions t
join first_transaction f on f.customer_id = t.customer_id
left join dim_campaigns d on t.campaign_id = d.campaign_id and t.timestamp between d.start_date and d.end_date
where year(t.timestamp) = 2023
group by 
DATETRUNC(month,timestamp), 
d.objective,
d.target_segment
order by DATETRUNC(month,timestamp), total_revenue desc;



-- Avg revenue per campaign 
select 
round(sum(gross_revenue)*1.0 / count(distinct case when campaign_id != 0 then campaign_id end), 2) as revenue_per_campaign 
from fact_transactions

-- Avg revenue per organic/ without campaign 
select 
round(sum(gross_revenue)*1.0 / count(distinct case when campaign_id = 0 then campaign_id end), 2) as revenue_per_campaign 
from fact_transactions


-- Campaign by Revenue 
select  
campaign_id, 
sum(gross_revenue) as total_revenue,
sum(gross_revenue)*1.0 / count(distinct transaction_id) as AOV
from fact_transactions
group by campaign_id
order by sum(gross_revenue) desc
-- Insight : 
-- Revenue terbesar pada customer yang tidak terkena campaign/alami dengan total revenue 1690120.04 tetapi AOV 80.6547382486283 lebih rendah dari campaign id 18(82) dan campaign id 5(82)
-- Diikuti campaign_id = 18 sebesar 187497.2, lalu 5 sebesar 184244.86


-- Objective campaign by revenue
select 
c.objective,
sum(t.gross_revenue) as total_revenue
from fact_transactions t
join dim_campaigns c on t.campaign_id = c.campaign_id
group by c.objective
order by sum(t.gross_revenue) desc

-- total customer campaign and not campaign trend
select 
DATETRUNC(month, timestamp),
count(distinct case when campaign_id = 0 then customer_id end) as total_customer_no_campaign,
sum(distinct case when campaign_id = 0 then gross_revenue end) as revenue_no_campaign,
count(distinct case when campaign_id != 0 then customer_id end) as total_customer_campaign,
sum(distinct case when campaign_id != 0 then gross_revenue end) as revenue_campaign,
count(distinct case when campaign_id != 0 then campaign_id end) as total_campaign
from fact_transactions
group by DATETRUNC(month, timestamp)
order by DATETRUNC(month, timestamp) 
-- Setiap bulan selama 3 tahun, seluruh campaign terus berjalan sebanyak 50 campaign 
-- Customer yang didapat lebih banyak dari campaign, dan total customer campaign tertinggi pada bulan 11 dan 12 (~2700 - ~2800)
-- Revenue tertinggi didapatkan dari customer yang mendapatkan campaign (~195000 - ~200000 revenue) pada bulan 11 dan 12 selama 3 tahun 

-- Apakah customer acquision besar di november dikarenakan campaign dengan tujuan acquisition
select 
datetrunc(month, f.timestamp) as monthly_transaction,
c.objective,
count(distinct f.customer_id) as total_customer,
sum(f.gross_revenue) as total_revenue
from fact_transactions f
join dim_campaigns c on f.campaign_id = c.campaign_id 
group by datetrunc(month, f.timestamp), c.objective
order by datetrunc(month, f.timestamp), total_revenue desc
-- Kenaikan revenue pada bulan 11 dan 12 selama 3 tahun, diakibatkan customer yang memiliki campaign tujuan reactivation, sempat revenue tertinggi pada bulan 11 tahun 2021 dikarenakan custoemr dengan campaign retention
