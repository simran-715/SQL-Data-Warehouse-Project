/*
===========================================================
DDL Script: Create Gold Views
===========================================================
Script Purpose: 
    This script create views for gold layer in data warehouse
    Gold layer represent final dimensions and fact tables (star schema)

    Each view perform transformation and combines data from silver layer.
    to produce a clean, enriched and buisness ready dataset.

Usage:
  This view can be queried directly for analytics and reporting.
===========================================================
*/


/*
=============================================================
				Create Dimension: gold.dim_customers
=============================================================
*/

CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER(Order By cst_id) AS customer_key,   --surrogate key ( dim table)
	cst_id AS customer_id ,
	ci.cst_key AS customer_number ,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name ,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE
		WHEN ci.cst_gndr !='n/a' THEN ci.cst_gndr  --CRM is master for gender info
		ELSE COALESCE(gen,'n/a')
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date	
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key=ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key= la.cid;

/*
=============================================================
				Create Dimension: gold.dim_products
=============================================================
*/

CREATE VIEW gold.dim_products AS
SELECT  
	ROW_NUMBER() OVER(Order by pn.prd_start_dt,pn.prd_key) AS product_key,       --CRM is master for gender info
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id ,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS product_cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date 
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id=pc.id
WHERE pn.prd_end_dt IS NULL;  --FILTER OUT ALL HISTORICAL DATA


/*
=============================================================
				Create Fact: gold.dim_products
=============================================================
*/
CREATE VIEW gold.fact_sales AS
select 
	sd.sls_ord_num AS order_number,
	pr.product_key ,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity, 
	sd.sls_price AS price
from silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key=pr.product_number
LEFT JOIN gold.dim_customers cu
on sd.sls_cust_id= cu.customer_id;
