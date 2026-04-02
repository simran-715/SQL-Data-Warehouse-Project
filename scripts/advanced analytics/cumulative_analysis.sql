-------------------------cumulative Analysis-----------------------------------

--total sales each month and running total of sales over time
SELECT order_month,month_sales,
SUM(month_sales) OVER(order by order_month) running_total
FROM(
select DATETRUNC(MONTH,order_date) order_month,sum(sales_amount) month_sales
from gold.fact_sales
where order_date IS NOT NULL
group by DATETRUNC(MONTH,order_date)
)t
