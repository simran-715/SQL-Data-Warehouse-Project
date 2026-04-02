/*
=======================================================================================
								     Project Report
=======================================================================================

Purpose: Consolidate key product metrics and behaviour

---------------------------------------------------------------------------------------
Highlights:
		1.Gather essential details: prouct_name, category, subcategory and cost
		2. Segment product by revenue to identify high-performers, mid-range, low-performers
		3. Aggregate product level metrics:
				-total orders
				-total sales
				-total quantity sold
				-total customers
				-lifespan (in months)
		4.Calcute valuable KPI's
				-recency (months since last sale)
				-average order revenue     (total sales/ total no. of orders)
				-average monthly revenue
				*/

CREATE VIEW gold.report_products AS

WITH base_query AS(

/*
-----------------------------------------------------------
 BASE QUERY
----------------------------------------------------------
*/

SELECT 
s.order_number,
s.product_key,
s.customer_key,
s.order_date,
s.sales_amount,
s.quantity,
p.product_name,
p.category,
p.subcategory,
p.product_cost
FROM gold.fact_sales s
left join gold.dim_products p
on s.product_key=p.product_key
)

,aggregate_query AS
(
/*
-----------------------------------------------------------
 AGGREGATED QUERY
----------------------------------------------------------
*/
select 
product_key,
product_name,
category,
subcategory,
product_cost,
COUNT(DISTINCT order_number) total_order,
SUM(sales_amount) total_sales,
SUM(quantity) total_quantity_sold,
COUNT(DISTINCT customer_key) total_customers,
DATEDIFF(month, MIN(order_date),MAX(order_date)) AS lifespan,
MAX(order_date) AS last_order_date,
ROUND(AVG(CAST(sales_amount AS float)/NULLIF(quantity,0)),1) AS avg_selling_price
from base_query
GROUP BY product_key,product_name,category,subcategory,product_cost
)

SELECT 
product_key,
product_name,
category,
subcategory,
product_cost,
total_order,
total_sales,
total_quantity_sold,
total_customers,
lifespan,
avg_selling_price,
CASE WHEN total_sales>5000 THEN 'High-performer'
WHEN total_sales >=10000 THEN 'mid-range'
ELSE 'Low-performers'
END AS product_segment,

DATEDIFF(month,last_order_date,GETDATE()) AS recency,
	--AVERAGE ORDER VALUE
	CASE
		WHEN total_order=0 THEN 0
		ELSE total_sales/total_order 
	END AS avg_order_revenue,

	--average monthly spent
	CASE WHEN lifespan=0 THEN total_sales
	ELSE total_sales/lifespan
	END AS avg_monthly_revenue
FROM aggregate_query 
