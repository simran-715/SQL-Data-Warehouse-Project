-------------------------------data segmentation: [Measure] by [Measure]-------------------------------------

--segment product into cost ranges and count how many product fall into each category

WITH product_segments AS
(select 
product_id,
product_name,
product_cost,
CASE WHEN product_cost<100 THEN 'Below 100'
WHEN product_cost BETWEEN 100 and 500 THEN '100-500'
WHEN product_cost BETWEEN 500 AND 1000 THEN '500-1000'
ELSE 'Above 1000'
END cost_range
from gold.dim_products
)

SELECT 
cost_range,
COUNT(product_name) Nr_of_Products
from product_segments
group by cost_range
order by Nr_of_Products desc

--customer degmentation based on spending and years

WITH customer_spending AS
(
select s.customer_key,
MIN(order_date) first_order,
MAX(order_date) last_order,
SUM(sales_amount) total_spent
from gold.fact_sales s
left join gold.dim_customers c
on s.customer_key=c.customer_key
group by s.customer_key
)

select customer_category,
COUNT(customer_key) as Nr_of_customers
from
(
select 
customer_key,
DATEDIFF(month,first_order,last_order) lifespan,
total_spent,
CASE 
	WHEN DATEDIFF(month,first_order,last_order)>=12 AND total_spent>5000 THEN 'VIP'
	WHEN DATEDIFF(month,first_order,last_order)>=12 AND total_spent<=5000 THEN 'Regular' 
	ELSE 'New'
END AS Customer_category
FROM customer_spending
)t
group by customer_category
