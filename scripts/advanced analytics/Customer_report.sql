

/*
=======================================================================================
								     Customer Report
=======================================================================================

Purpose: Consolidate key customer metrics and behaviour

---------------------------------------------------------------------------------------
Highlights:
		1.Gather essential details: name, age, transactional details
		2. Segment customers into categories( VIP, Regular, New) and age
		3. Aggregate customer level metrics:
				-total orders
				-total sales
				-total quantity purchased
				-total products
				-lifespan (in months)
		4.Calcute valuable KPI's
				-recency (months since last order)
				-average order value      (total sales/ total no. of orders)
				-average monthly spend


*/

CREATE VIEW gold.report_customers AS

WITH base_query AS (
/*
---------------------------------------------------------------------------------
BASE QUERY: Retrieving the core column from the table
---------------------------------------------------------------------------------
*/
SELECT 
	s.order_number,
	s.product_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	c.customer_number,
	c.customer_key,
	CONCAT(c.first_name,' ',c.last_name) AS customer_name,
	DATEDIFF(year,c.birthdate,GETDATE()) AS age
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
on s.customer_key=c.customer_key
WHERE order_date IS NOT NULL
)

,customer_aggregation AS(

/*
---------------------------------------------------------------------------------
Aggreration QUERY: Aggregation necessary value by cutomer
---------------------------------------------------------------------------------
*/
SELECT 
	customer_number,
	customer_key,
	customer_name,
	age,
	COUNT(DISTINCT order_number) total_orders,
	SUM(sales_amount) total_sales,
	SUM(quantity) total_quantity_purchased,
	COUNT(DISTINCT product_key) total_products,
	MAX(order_date) last_order_date,
	DATEDIFF(month, MIN(order_date),MAX(order_date)) lifespan
FROM base_query
GROUP BY customer_number,customer_key,customer_name,age
)

/*
---------------------------------------------------------------------------------
Main Query
---------------------------------------------------------------------------------
*/
SELECT 
	customer_number,
	customer_key,
	customer_name,
	age,
	total_orders,
	total_sales,
	total_quantity_purchased,
	total_products,
	last_order_date,
	lifespan ,

	--age group
	CASE
		WHEN age<20 THEN 'Below 20'
		WHEN age between 20 and 29 THEN '20-29'
		WHEN age between 30 and 39 THEN '30-39'
		WHEN age between 40 and 49 THEN '40-49'
	ELSE '50 and Above'
	END AS age_group,

	--customer segmentation
	CASE 
		WHEN lifespan>=12 AND total_sales>5000 THEN 'VIP'
		WHEN lifespan>=12 AND total_sales<=5000 THEN 'Regular'
		ELSE 'New' 
	END AS customer_segmentation,
	DATEDIFF(month,last_order_date,GETDATE()) AS recency,
	--AVERAGE ORDER VALUE
	CASE
		WHEN total_sales=0 THEN 0
		ELSE total_sales/total_orders 
	END AS avg_order_value,

	--average monthly spent
	CASE WHEN lifespan=0 THEN total_sales
	ELSE total_sales/lifespan
	END AS avg_monthly_spent
FROM customer_aggregation
