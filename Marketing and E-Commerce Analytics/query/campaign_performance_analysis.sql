use e_commerce_customer_and_marketing_analytics;

-- Tahun 2021, membludaknya new customer sebanyak (~2000 an) dibandingkan dengan retention customer yang masih ratusan, sehingga revenue yang didapatkan lebih besar dibandingkan retention
-- di tahun 2022, total returning customer mengalami kenaikan hingga ~1700 pada bulan 12, namun total new customer turun dan stabil (<2000)
-- pada tahun 2023, retention customer mengalami peningkatan dengan peak ~2000an pada bulan 11-12, dan new customer stagnan	dan total lebih rendah dari retention customer 
-- Analisis bagaimana performa campaign dalam mendapatkan customer (new customer dan retention)


-- Apakah new customer datang dari campaign atau non campaign, tahun 2021
with year_transaction as (
select * from fact_transactions
where YEAR(timestamp) < 2022),
first_transaction as (
	select 
	customer_id, min(timestamp) as first_timestamp 
	from fact_transactions
	group by customer_id
)
select 
y.campaign_id,
count(distinct case when y.timestamp = f.first_timestamp then f.customer_id end) as new_total_customer,
sum(gross_revenue) as total_revenue
from year_transaction y
join first_transaction f on f.customer_id = y.customer_id
group by y.campaign_id
order by new_total_customer desc
-- Tahun 2021, total customer yang non-campaign lebih banyak dan menghasilkan revenue tertinggi dibandingkan dengan customer dengan campaign
-- Terdapat campaign dengan id 44 berhasil dalam mendapatkan customer terbanyak dengan total 663 dengan revenue ~62000
-- dan juga terdapat campaign yang menghasilkan total revenue yang lebih tinggi dengan customer yang sedikit dengan campaign 44 seperti campaign 18, 5, 29


-- analisis objective dan target segment campaign
select 
c.objective,
c.target_segment,
count(distinct f.customer_id) as total_customer,
sum(f.gross_revenue) as total_revenue,
count(distinct f.campaign_id) as total_campaign,
avg(c.expected_uplift) as avg_expected_uplift
from fact_transactions f
join dim_campaigns c on f.campaign_id = c.campaign_id
where year(f.timestamp) < 2022 and year(start_date) < 2022 
group by objective, target_segment
order by total_customer desc
-- Pada tahun 2021, tujuan campaign acquisitioni dan reactivation pada target segment new customers mencapai total customer tertinggi dan revenue tertinggi
-- Total campaign dengan objective acquision dengan target segment new customer ada 4 yang berjalan, 2 campaign dengan objectiive reactivatioin dengan target segments all, dan 2 campaign dengan objective reactivatioin dengan target segment new customer
-- Campaign dengan tujuan acquisition dan reactivation berhasil dalam menjangkau customer baru dan meningkatkan pertumbuhan revenue 
-- Dan campaign dengan tujuan retention terendah dalam mendapatkan revenue dan customer 

-- Campaign apa saja yang berjalan pada tahun 2021
select
f.campaign_id,
c.objective,
c.target_segment,
count(distinct f.customer_id) as total_customer,
sum(gross_revenue) as total_revenue
from fact_transactions f
join dim_campaigns c on f.campaign_id = c.campaign_id
where year(f.timestamp) < 2022 and year(c.start_date) < 2022 
group by objective, target_segment, f.campaign_id
order by total_customer desc;

-- campaign_id = 29 yang tertinggi dalam mendapatkan customer (763 customer) dengan objective acquisition dan target segement new customer
-- tertinggi kedua pada campaign id 44 dengan objective reactivationi dan target segment all sebesar 758 customer
-- campaign yang berjalan pada tahun 2023 dengan objective acquision dan target segment new customer seperti 29, 19, 28, 24
-- campaign yang berjalan pada tahun 2023 dengan objective reactivation dan target segment new customer seperti 2,20

-- Apakah new customer datang dari campaign atau non campaign, tahun 2022
with year_transaction as (
select 
f.*, 
c.start_date,
c.end_date,
from fact_transactions f
join dim_campaigns as c on c.campaign_id = f.campaign_id
where (YEAR(timestamp) >= 2022 and YEAR(timestamp) < 2023) and c.start_date >= 2022
),
first_transaction as (
	select 
	customer_id, min(timestamp) as first_timestamp 
	from fact_transactions
	group by customer_id
)
select 
y.campaign_id,
count(distinct case when y.timestamp = f.first_timestamp then f.customer_id end) as new_total_customer,
sum(gross_revenue) as total_revenue
from year_transaction y
join first_transaction f on f.customer_id = y.customer_id
group by y.campaign_id
order by new_total_customer desc
-- Tahun 2022, total customer yang non-campaign lebih banyak dan menghasilkan revenue yangg lebih rendah dibandingkan dengan beberapa campaign seperti (18, 49, 29, 44, 5, 7)

-- Analisis objective dan target segments campaign pada tahun 2022
select 
c.objective,
c.target_segment,
count(distinct f.customer_id) as total_customer,
sum(f.gross_revenue) as total_revenue,
count(distinct f.campaign_id) as total_campaign,
avg(c.expected_uplift) as avg_expected_uplift
from fact_transactions f
join dim_campaigns c on f.campaign_id = c.campaign_id
where (year(f.timestamp) >= 2022 and year(f.timestamp) < 2023) and year(c.start_date) >= 2022
group by objective, target_segment
order by total_revenue desc;
-- Pada tahun 2022, campaign lebih berfokus dengana objective reactivation dengan target segment churn risk, objective cross-sell dengan target high value, retention dengan target all, retention dengan target high value, dan retention dengan target new customer
-- campaign dengan objective reactivation pada target customer churn risk memiliki revenue tertinggi ~167000 dan total customer ~2000
-- diikuti dengan campaign tertinggi kedua dengan objective cross-sell pada target customer high value dengan revenue ~153000 dan total customer ~1800
-- lalu ketiga tertinggi dengan objective retention dan target segment all dengan revenue ~147000 dan total customer ~1800
-- Kenaikan revenue pada retention customer di tahun 2023 dipengaruhi oleh campaign dengan objective reactivation dan target segment churn risk, campaign dengan tujuan cross-sell dan target high value, campaign dengan tujuan retention dengan target all dan high value

-- Analisis campaign monthly 2022
select  
datetrunc(month, f.timestamp) as monthly_timestamp,
f.campaign_id, 
c.objective,
c.target_segment,
sum(f.gross_revenue) as total_revenue
from fact_transactions f
join dim_campaigns c on f.campaign_id = c.campaign_id
where (year(f.timestamp) >= 2022 and year(f.timestamp) < 2023) and year(c.start_date) >= 2022
group by 
datetrunc(month, f.timestamp),
f.campaign_id, 
c.objective,
c.target_segment
order by 
datetrunc(month, f.timestamp), total_revenue desc
-- Pada bulan 12 tahun 2022, campaign yang berjalan didomniasi pada objective reactivation dan retention 
-- campaign dengan objective retention pada target new customers mencapai total revenue tertinggi (~7000) diikuti dengan campaign dengan objective yang sama dengan target segment high value yang mencapai revenue ~62000
-- Kerberhasil campaign tersebut, membuat total revenue tertinggi pada retention customer dibandingkan dengan revenue dari new customer


-- Analisis campaign di 2023
-- Apakah new customer datang dari campaign atau non campaign, tahun 2023
with year_transaction as (
select * from fact_transactions
where YEAR(timestamp) <= 2023 and YEAR(timestamp) > 2022)
select 
campaign_id,
count(distinct customer_id) as total_customer,
sum(gross_revenue) as total_revenue
from year_transaction
group by campaign_id
order by total_customer desc
-- Customer tanpa campaign lebih banyak totalnya dan menghasilkan revenue tertinggi ~572000
-- Campaign dengan revenue tertinggi adalah campaign id 5 dengan total customer 760 dan revenue sebesar ~60000
-- Terdapat beberapa campaign yang menghasilkan revenue yang tinggi tetapi total customernya lebih rendah seperti (campaign id 18)
-- Campaign id 7 menghasilkan revenue tertinggi yang kedua (~57500)


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
-- Ada 16 campaign yang dimulai di tahun 2023, dengan campaign didominasi pada campaign yang bertujuan cross-sell dan target high value, campaign dengan tujuan retention dan target high value, campaign dengan tujuan reactivation dan target deal seekers, campaign dnegan tujuan retentian dan target all, dan campaign dengan tujuan reactivation dan target churn risk
-- Campaign yang mendapatkan total customer tertinggi (~1300) dengan revenue tertinggi (~105000) yaitu campaign dengan tujuan cross sell dan target high value
-- Diikuti campaign tertinggi kedua dengan tujuan retention dengan target high value dengan total customer (~1100) dan total revenue (~93000)
-- Campaign tertinggi ketiga dengan tujuan reactivation dengan target deal seekers dengan total customer (~1000) dan total revenue (~88000)

-- Analisis campaign monthly 2023
select  
datetrunc(month, f.timestamp) as monthly_timestamp,
f.campaign_id, 
c.objective,
c.target_segment,
sum(f.gross_revenue) as total_revenue
from fact_transactions f
join dim_campaigns c on f.campaign_id = c.campaign_id
where (year(f.timestamp) > 2022 and year(f.timestamp) <= 2023) and year(c.start_date) > 2022
group by 
datetrunc(month, f.timestamp),
f.campaign_id, 
c.objective,
c.target_segment
order by 
datetrunc(month, f.timestamp), total_revenue desc
-- Campaign pada bulan 11, tertinggi campaign yanng bertujuan reactivation dengan target all, campaign tujuan reactivation dan target deal seekers, camapaign dengan objective retention dan target all
-- Campaign pada bulan 12, tertinggi dicapai oleh campaign dengan tujuan reactivation dengan target all, campaign deengan tujuan cross sell dan target high value, dan campaign dengan target acquisition dengan target churn risk



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
