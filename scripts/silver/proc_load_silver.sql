/*
=======================================================================
Stored Proedure: Load Silver Layer ( Bronze-> Silver)
=======================================================================
Script Purpose:
    Perform ETL( Extract, Transform and Load) process
    to populate silver schema tables from bronze schema tables.

Actions Performed:
    -Truncate Silver Tables
    -Insert transformed and cleaned data from Bronze into Silver Tables

Parameter:
    None
    Does not accept or return value

Usage Example:
    EXEC silver.load_silver;
=======================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

	DECLARE @starttime DATETIME, @endtime DATETIME,@load_start DATETIME, @load_end DATETIME;
	BEGIN TRY
	 
		SET @load_start=GETDATE();
		PRINT '====================================================='
		PRINT '                Loading Silver Layer';
		PRINT '=====================================================';

		PRINT '====================================================='
		PRINT '                      CRM TABLES';
		PRINT '=====================================================';

		
		---------------cust_info-----------------
		SET @starttime=GETDATE();
		PRINT '>>TRUNCATING TABLE: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;

		PRINT '>>Inserting Data Into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info ( 
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)

		SELECT cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE
				WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
				ELSE 'n/a'
			END AS cst_marital_status,  --normalise marital status values to readable format

			CASE
				WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
				ELSE 'n/a'
			END AS cst_gndr,            --normalise gender values to readable format

			cst_create_date
		FROM
			(SELECT *,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL)t
		WHERE flag_last=1;
		SET @endtime=GETDATE();
		PRINT'------------------------------------------------------';
		PRINT'Total Duration: '+ CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR);
		PRINT'------------------------------------------------------';


		------------------prd_info---------------------
		SET @starttime=GETDATE();
		PRINT '>>TRUNCATING TABLE: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;

		PRINT '>>Inserting Data Into: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info(
			prd_id ,
			cat_id ,
			prd_key,
			prd_nm ,
			prd_cost ,
			prd_line,
			prd_start_dt,
			prd_end_dt 
			)
		SELECT
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
			SUBSTRING(prd_key,7,len(prd_key)) AS prd_key,
			prd_nm,
			ISNULL(prd_cost,0) AS prd_cost,
			CASE
				WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
				WHEN UPPER(TRIM(prd_line))='S' THEN 'Road'
				WHEN UPPER(TRIM(prd_line))='R' THEN 'other Sales'
				WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS Date) AS prd_end_dt
		FROM bronze.crm_prd_info;
		SET @endtime=GETDATE();
		PRINT'------------------------------------------------------';
		PRINT'Total Duration: '+ CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR);
		PRINT'------------------------------------------------------';



		---------------------------sales.details--------------------------------------------
		SET @starttime=GETDATE();
		PRINT '>>TRUNCATING TABLE: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;

		PRINT '>>Inserting Data Into: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details(
			sls_ord_num, 
			sls_prd_key ,
			sls_cust_id ,
			sls_order_dt,
			sls_ship_dt ,
			sls_due_dt ,
			sls_sales ,
			sls_quantity ,
			sls_price)

		SELECT
			sls_ord_num, 
			sls_prd_key ,
			sls_cust_id ,
			CASE 
				WHEN sls_order_dt=0 OR LEN(sls_order_dt)!=8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE 
				WHEN sls_ship_dt=0 OR LEN(sls_ship_dt)!=8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt ,
			CASE 
				WHEN sls_due_dt=0 OR LEN(sls_due_dt)!=8 
					THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt ,
	
			CASE 
				WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales!=ABS(sls_price)*sls_quantity 
					THEN ABS(sls_price)*sls_quantity
				ELSE sls_sales
			END AS sls_sales ,
			sls_quantity ,
			CASE
				WHEN sls_price IS NULL OR sls_price <=0 
					THEN sls_sales/NULLIF(sls_quantity,0)
				ELSE ABS(sls_price)
			END AS sls_price
		FROM bronze.crm_sales_details
		SET @endtime=GETDATE();
		PRINT'------------------------------------------------------';
		PRINT'Total Duration: '+ CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR);
		PRINT'------------------------------------------------------';
		
		PRINT '====================================================='
		PRINT '                     ERP TABLES';
		PRINT '=====================================================';

		-------------------------cust_az12------------------------------

		SET @starttime=GETDATE();
		PRINT '>>TRUNCATING TABLE: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;

		PRINT '>>Inserting Data Into: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12( cid,bdate,gen)

		select 
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid)) 
			ELSE cid
		END AS cid,
		CASE WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
		END bdate,
		CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
			WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
			ELSE 'n/a' 
		END  AS gen
		from bronze.erp_cust_az12;
		SET @endtime=GETDATE();
		PRINT'------------------------------------------------------';
		PRINT'Total Duration: '+ CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR);
		PRINT'------------------------------------------------------';


		--------------------------------loc_a101-----------------------------
		SET @starttime=GETDATE();
		PRINT '>>TRUNCATING TABLE: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;

		PRINT '>>Inserting Data Into: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101(cid, cntry)

		select 
		Replace(cid,'-','') cid,
		CASE WHEN TRIM(cntry) IN ('USA','US') THEN 'United States'
			WHEN TRIM(cntry) ='DE' THEN 'Germany'
			WHEN TRIM(cntry) IS NULL OR TRIM(cntry) ='' THEN 'n/a'
			Else Trim(cntry)
		END AS cntry
		from bronze.erp_loc_a101;
		SET @endtime=GETDATE();
		PRINT'------------------------------------------------------';
		PRINT'Total Duration: '+ CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR);
		PRINT'------------------------------------------------------';

		-----------------------------px_cat----------------------------------
		SET @starttime=GETDATE();
		PRINT '>>TRUNCATING TABLE: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		PRINT '>>Inserting Data Into: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2(id,cat,subcat,maintenance)

		select 
		id,
		cat,
		subcat,
		maintenance
		from bronze.erp_px_cat_g1v2;
		SET @endtime=GETDATE();
		PRINT'------------------------------------------------------';
		PRINT'Total Duration: '+ CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR);
		PRINT'------------------------------------------------------';

		SET @load_end=GETDATE();
		PRINT '======================================================';
		PRINT 'Loading Silver Layer Completed';
		PRINT 'Complete batch load Duration: '+ CAST(DATEDIFF(SECOND,@load_start,@load_end) AS VARCHAR);
		PRINT '======================================================';

	END TRY

	BEGIN CATCH
		PRINT '================================';
		PRINT 'Error in Loading the Broze Layer';
		PRINT '================================';
		PRINT'Error Message: '+ Error_Message();
		PRINT 'Error Number: '+ CAST(ERROR_NUMBER() AS NVARCHAR);
	END CATCH

END
