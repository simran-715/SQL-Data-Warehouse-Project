--------------------------------part to whole : [Measure]/[Total Value] *100 ------------------------------------

--which category contribute the most to the sales
select 
	category_name,
	category_sales,
	CONCAT(ROUND((CAST(category_sales AS float)/SUM(category_sales) OVER())*100,2),'%') AS contribe_percentage
from
(select
	p.category as category_name,
	SUM(s.sales_amount) category_sales
from gold.fact_sales s
left join gold.dim_products p
	on s.product_key=p.product_key
group by p.category
)t
order by contribe_percentage desc
