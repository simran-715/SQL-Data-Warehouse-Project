/*
====================================================
                    quality checks
====================================================
Script Purpose:
    - Validate data quality in Gold Layer tables.
    - Check duplicates in products.
    - Verify dimension data (customers, products).
    - Uniqueness of Surrogate keys in dimention tables
    - Ensure referential integrity between fact_sales 
      and dimension tables.

Usage Notes:
    - Run after data load to Gold Layer.
    - Investigate duplicates and missing joins.
    - Ensure data is clean before reporting.
    - Investigate and resolve any discrepancies 
      found during the check.
====================================================

*/

--dim_customers------------------------------------------------------------
select distinct gender
from gold.dim_customers;

--products ( before buisness object)---------------------------------------
select prd_key, Count(*)
from
(SELECT  
pn.prd_id ,
pn.prd_key ,
pn.prd_nm,
pn.cat_id ,
pc.cat,
pc.subcat,
pn.prd_cost,
pn.prd_line ,
pn.prd_start_dt,
pn.prd_end_dt,
pc.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id=pc.id
WHERE pn.prd_end_dt IS NULL  --FILTER OUT ALL HISTORICAL DATA
)t
group by prd_key
having count(*)>1

--DIM_PRODUCTS
select *
from gold.dim_products;

--FACT_SALES---------------------------------------------------------------
--(lookups quality check)

select *
from gold.fact_sales s
left join gold.dim_customers c
ON s.customer_key=c.customer_key;

select *
from gold.fact_sales s
left join gold.dim_products p
ON s.product_key=p.product_key;
