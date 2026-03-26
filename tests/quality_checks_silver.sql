
/*
==========================================
QUALITY CHECK SILVER LAYER
==========================================
Scripts Purpose: This script performs various quality checks for data consistency, accuracy 
and standardisation across the silver schema. It includes checks for:
            -Null or duplicate Primary Keys
            -Unwanted space in string fields
            -Data Standardisation and consistncy
            -Invalid data ranges and orders
            -Data consistency between related field

Uage Notes:
Run this script after Loading Data in Silver layer.
Investigate and resolve any discrepancies found during the checks
*/

--=================================cust_info=========================================
--Check for Null or Duplicates in Primary key
--Expectation: No Result
SELECT cst_id,COUNT(*) Flag
FROM silver.crm_cust_info
group by cst_id
having COUNT(*)>1 or cst_id IS NULL;

--Check for unwanted space in string
--Expectation: No Result
SELECT cst_firstname
FROM silver.crm_cust_info
where cst_firstname!= TRIM(cst_firstname);

SELECT cst_lastname
FROM silver.crm_cust_info
where cst_lastname!= TRIM(cst_lastname);

SELECT cst_gndr
FROM silver.crm_cust_info
where cst_gndr!= TRIM(cst_gndr);


--Data Standardization and Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;  --   F->Female, M->Male


SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;   -- S->Single , M->Married

--=====================================prd_info===========================================


--Check for Null or Duplicates in Primary key
--Expectation: No Result
SELECT prd_id,COUNT(*) Flag
FROM silver.crm_prd_info
group by prd_id
having COUNT(*)>1 or prd_id IS NULL;

--Check for unwanted space in string
--Expectation: No Result
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm!=TRIM(prd_nm)


--Ckeking negative or null values
--Expectation: No Result
SELECT prd_cost
FROM silver.crm_prd_info
where prd_cost<0 Or prd_cost IS NULL;


--Data Standardization and Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;  --M->Mountain, R->Road

--Checking InValid date order
--Expectation: No Result
SELECT *
from silver.crm_prd_info
where prd_start_dt>prd_end_dt;


--===================================sales_details==========================================


--Check for unwanted space in string
--Expectation: No Result
SELECT sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num!=TRIM(sls_ord_num)


--Ckeking negative or null values
--Expectation: No Result
SELECT prd_cost
FROM silver.crm_prd_info
where prd_cost<0 Or prd_cost IS NULL;


--Data Standardization and Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;  --M->Mountain, R->Road


SELECT *
from silver.crm_sales_details
where sls_order_dt>sls_ship_dt OR sls_order_dt>sls_due_dt;


--CHECK Data consistency  between sales, price and quantity

select *
from silver.crm_sales_details
where sls_sales!=sls_price*sls_quantity OR
sls_sales IS NULL OR sls_price IS NULL OR sls_quantity IS NULL OR
sls_sales<=0 OR sls_price <=0 OR sls_quantity <=0;

---------------------------cust_az12----------------------

--out of range dates
select bdate
from silver.erp_cust_az12
where bdate>GETDATE();


--data standardisation
select DISTINCT gen
from silver.erp_cust_az12;

----------------------------loc_a101----------------------

--data consistency
select cid
from silver.erp_loc_a101 
where cid not in (select cst_key from silver.crm_cust_info);

--data standardization and consistency
select DISTINCT cntry
from silver.erp_loc_a101;
