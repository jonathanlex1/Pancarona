use e_commerce_customer_and_marketing_analytics;


select * from fact_transactions
select * from fact_events
select * from dim_campaigns
select * from dim_customers



-- Adanya pola new customer pada tahun 2021-2022 yang paling banyak menghasilkan revenue kemudian pada tahun 2023 retention customer paling banyak mendapatkan revenue
-- Analisis bagaimana performa campaign dalam mendapatkan customer (new customer dan retention)


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
