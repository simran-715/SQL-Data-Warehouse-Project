/*
============================================================================
Stored Procedure :  Load Bronze Layer  (Source->Bronze)
============================================================================
Script Prupose:
    -Load data into bronze schema from external CSV files
    -Truncate alreadyexisting table
    -use `Bulk Insert` command to load data from CSV files to bronze tables.

Parmeter: None  ( does not accept or return any value)
Usage Example:  EXEC bronze.load_bronze
=============================================================================
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
	BEGIN TRY

		
		PRINT '============================================';
		PRINT 'Loading Bronze Layer';
		PRINT '============================================';

		PRINT '--------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '--------------------------------------------';

		SET @batch_start_time=GETDATE();

		SET @start_time=GETDATE();
		PRINT '>>Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		Print '>>Insert Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\T S P\OneDrive\Documents\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT '>>Load Duration:'+Cast(DATEDIFF(second,@start_time,@end_time)  AS NVARCHAR)+' seconds';
		PRINT'-------------------------';


		--prd_info
		SET @start_time=GETDATE();
		PRINT '>>Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		Print '>>Insert Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\T S P\OneDrive\Documents\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT '>>Load Duration:'+Cast(DATEDIFF(second,@start_time,@end_time)  AS NVARCHAR)+' seconds';
		PRINT'---------------------------';


		--sales_details
		SET @start_time=GETDATE();
		PRINT '>>Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		Print '>>Insert Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\T S P\OneDrive\Documents\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT '>>Load Duration:'+Cast(DATEDIFF(second,@start_time,@end_time)  AS NVARCHAR)+' seconds';


		
		
		PRINT '--------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '--------------------------------------------';


		--cust_az12
		SET @start_time=GETDATE();
		PRINT '>>Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		Print '>>Insert Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\T S P\OneDrive\Documents\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT '>>Load Duration:'+Cast(DATEDIFF(second,@start_time,@end_time)  AS NVARCHAR)+' seconds';
		PRINT '--------------------------------';


		--loc_a101
		SET @start_time=GETDATE();
		PRINT '>>Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		Print '>>Insert Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\T S P\OneDrive\Documents\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT '>>Load Duration:'+Cast(DATEDIFF(second,@start_time,@end_time)  AS NVARCHAR)+' seconds';
		PRINT '---------------------------------';


		--px_cat_g1v2
		SET @start_time=GETDATE();
		PRINT '>>Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		Print '>>Insert Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\T S P\OneDrive\Documents\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT '>>Load Duration:'+Cast(DATEDIFF(second,@start_time,@end_time)  AS NVARCHAR)+' seconds';
		SET @batch_end_time=GETDATE();
		
		PRINT '======================================';
		PRINT 'Loading Bronze Layer is Completed';

		PRINT '>>Total Batch Duration:'+Cast(DATEDIFF(second,@batch_start_time,@batch_end_time)  AS NVARCHAR)+' seconds';
		PRINT '=======================================';

	END TRY
	BEGIN CATCH
		PRINT '================================';
		PRINT 'Error in Loading the Broze Layer';
		PRINT '================================';
		PRINT'Error Message: '+ Error_Message();
		PRINT 'Error Number: '+ CAST(ERROR_NUMBER() AS NVARCHAR);
	END CATCH

END
