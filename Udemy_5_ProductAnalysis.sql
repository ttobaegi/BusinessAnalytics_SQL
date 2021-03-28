## Product Analysis
-- how each product contributes to business
-- how product launches(adding new product) impact the overall portfolio
-- KPI : Orders Revenue Margin AOV(average revenue generted per order)

select 
	primary_product_id,
    count(order_id) as orders,
    sum(items_purchased*price_usd) as revenue,
    sum(items_purchased*(price_usd-cogs_usd)) as margin,
    avg(items_purchased*price_usd) 
FROM orders
where year(created_at) = '2013'
group by 1
order by 4;

-- item purchased? 구매 품목 갯수

-- Product Level Sales Analysis (Trend)
select year(created_at)yr,
	month(created_at) mo,
    count(distinct order_id) number_of_sales , 	# 주문 수 
    sum(price_usd) total_revenue, 				# 주문금액 = price_usd 단가 아님
    sum(price_usd-cogs_usd) total_margin 		# 주문당 마진
from orders
where created_at<'2013-1-4'
group by 1,2
order by 1,2;

select * from orders limit 1;
-- 구매 전환율 monthly  > 실제 세션이 구매로 
-- 1) website_sessionsorders & website_pageviews
-- 2) conv_rate count(distinct sessions) > 전체세션 대비 구매로 이어진 세션 :: o.session_id / p.session_id
-- 3) group by session_id 
-- 4) group by order_id

select  year(w.created_at), month(w.created_at),
	count(distinct order_id) orders,
   count(distinct o.website_session_id)/count(distinct w.website_session_id) *100 conv_rate,
   sum(price_usd) / count(distinct o.website_session_id) revenue_per_session,
   count(distinct case when primary_product_id =1 then order_id else null end) product_one_orders,
   count(distinct case when primary_product_id =2 then order_id else null end) product_two_orders
from website_sessions  w
	left join orders o on o.website_session_id = w.website_session_id 
where w.created_at between '2012-4-1' and '2013-04-05'
group by 1,2 ;

-- product level website analysis 
-- conversion rate by each product
-- multi-product showcase pages 
-- adding new product 

-- sessions hit the /product page & where they went next


