-------------------------change over time--------------------------------

--analyse sales performance over time
select year(order_date) order_year,month(order_date) order_year,SUM(sales_amount) monthly_performance
from gold.fact_sales
where order_date IS NOT NULL
group by year(order_date) ,month(order_date)
order by year(order_date) ,month(order_date)
