--------------------------performance analysis : [Measure]-[performance factor]---------------------------------
--compare current value with the target value


--analyse yearly performance of products by comparing each product sales to both average sales performance & previous year sales
WITH yearly_product_sales AS
(select 
	DATETRUNC(year,order_date)AS order_date,
	p.product_name AS product_name,
	sum(sales_amount) AS month_sales
from gold.fact_sales s
LEFT JOIN gold.dim_products p
	ON s.product_key=p.product_key
where order_date IS NOT NULL
group by DATETRUNC(year,order_date),p.product_name
)

select 
	order_date,
	product_name,
	month_sales,
	AVG(month_sales) OVER(partition by product_name ) product_avg,
	month_sales-AVG(month_sales) OVER(partition by product_name ) diff_avg,
	CASE 
		WHEN month_sales<AVG(month_sales) OVER(partition by product_name ) THEN 'below Average'
		WHEN month_sales>AVG(month_sales) OVER(partition by product_name ) THEN 'Above Average'
		ELSE 'Average'
	END AS avg_change,
	LAG(month_sales) OVER(partition by product_name order by order_date) AS prev_sales,
	month_sales -LAG(month_sales) OVER(partition by product_name order by order_date) AS diff_py_sales,
	CASE
		WHEN month_sales -LAG(month_sales) OVER(partition by product_name order by order_date)>0 THEN 'Increase'
		WHEN month_sales -LAG(month_sales) OVER(partition by product_name order by order_date)<0 THEN 'Decrease'
		ELSE 'No Change'
	END AS py_sales_compare
from yearly_product_sales
