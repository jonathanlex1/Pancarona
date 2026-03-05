use e_commerce_customer_and_marketing_analytics;

-- Kategori produk berdasarkan revenue 
select 
	p.category,
	sum(f.gross_revenue) as revenue,
	avg(cast (p.base_price as float)) as avg_price,
	sum(case when p.is_premium = 1 then f.quantity end) as total_premium_sold,
	sum(case when p.is_premium = 0 then f.quantity end) as total_regular_sold
from fact_transactions f
join dim_products p on p.product_id = f.product_id
where p.category != 'Unknown'
group by p.category
order by sum(f.gross_revenue) desc
-- Insight : 
-- Kategori elektronik menjadi revenue penjualan yang terbesar, dikarenakan harganya yang tinggi (rata rata ~130) dan banyaknya total produk premium terjual daripada produk regular, yang membuat pertumbuhan total revenue
-- Kategori Home dengan revenue tertinggi ke-2, dimakana karakteristiknya sama dengan kategori elektronik
-- Semantara itu, pada kategori fashion dengan revenue tertinggi 3 dengan karakteristik yang berbeda, dimana harganya murah dan banyak produk regular yang terjual sebagai pendukung terhadap total revenue


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
-- Penjualan produk electronic, home, fashion secara konsisten yang paling laris di tiap bulannya selama 3 tahun 
-- Dan mengalami revenue, order, quantity sold yang tertinggi di bulan 11

-- Total penjualan untuk barang reguler dan premium
select  
p.is_premium,
sum(case when f.refund_flag = 0 then f.quantity end) as total_sold,
sum(f.gross_revenue) as total_revenue, 
avg(cast (p.base_price as float)) as avg_price,
sum(case when f.refund_flag = 1 then f.quantity end)*1.0 / sum(quantity) * 100 as refund_rate
from fact_transactions f
join dim_products p on f.product_id = p.product_id 
where p.product_id != 0 
group by p.is_premium
-- Insight : 
-- Secara keseluruhan, product yang terjual lebih banyak yang premium (~62200) daripada regular (~62000) dan memberikan revenue yang lebih banyak ~4x dibandingkan barang reguler
-- rata rata harga produk premium (~111) dan produk (~33)

-- Product 
select  
datetrunc(month, f.timestamp) as monthly_date,
sum(case when f.refund_flag = 0 and p.is_premium = 1 then f.quantity end) as total_sold_premium,
sum(case when f.refund_flag = 0 and p.is_premium = 0 then f.quantity end) as total_sold_regular,
sum(case when p.is_premium = 1 then f.gross_revenue end) as total_revenue_premium, 
sum(case when p.is_premium = 0 then f.gross_revenue end) as total_revenue_regular,
sum(case when f.refund_flag = 1 and p.is_premium = 1 then f.quantity end)*1.0 / sum(quantity) * 100 as refund_rate_premium,
sum(case when f.refund_flag = 1 and p.is_premium = 0 then f.quantity end)*1.0 / sum(quantity) * 100 as refund_rate_premium,
sum(case when f.refund_flag = 1 then f.quantity end)*1.0 / sum(quantity) * 100 as refund_rate
from fact_transactions f
join dim_products p on f.product_id = p.product_id 
where p.product_id != 0 
group by datetrunc(month, f.timestamp)
order by datetrunc(month, f.timestamp) 

-- Revenue tertinggi di tahun 2021 yaitu penjulan barang premium di bulan 12 (yang mencapai ~220000) diikuti di penjualan di bulan 11 (~2100000). walaupun total produk yang terjual lebih banyak regular (~2200) daripada premium (~2100) di bulan 12 dan total produk premium yang terjual paling banyak (~2100) di bulan 11 
-- Pola yang sama terjadi pada tahun 2022, dimana revenue pada barang premium tertinggi (~220000) di bulan 12 diikuti dengan penjualan di bulan 11 (yang mencapai ~210000). Dimana total produk barang regular (~2100) lebih tinggi terjual di bulan 12 dibandingkan dengan premium (~2000) dan dibulan 11, terjual ~2000 produk premiun dan ~2100 produk regular
-- Pola yang hampir sama juga terjadi di tahun 2023, penjualan barang premium mencapai yang tertinggi(~223000) di bulan 11 dengan total produk premium yang terjual sebanyak(~2100) lebih besar dibandinkan barang regular (~2000) diikuti penjualan tertinggi kedua produk premium pada bulan 12 (~222000) dengan total produk premium yang terjual sebanyak (~2200) lebih besar dari barang regular (~2100)   
-- Kenaikan revenue pada bulan 11 dan 12, disebabkan barang premium yang lebih laku terjual dan barang tersebut lebih mahal 

-- Kerugian yang terjadi di setiap awal bulan Januari, terjadi refund produk yang meningkat dari bulan 11 dan 12 ke bulan 1 awal tahun dari ~2% ke ~3% 

select 
*, datediff(DAY, timestamp, launch_date)
from fact_transactions f
join dim_products p on f.product_id = p.product_id
where p.product_id != 0 and f.timestamp < p.launch_date

-- Ditemukan 49% dataset yang dimana transaksi terjadi sebelum tanggal peluncuran produk, oleh karena itu kolom tidak akan digunakan untuk menganalisis product lifecycle (seperti new product performance, product adoption)  