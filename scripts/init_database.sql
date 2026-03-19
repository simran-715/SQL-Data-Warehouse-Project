
/*
===========================================================
Creating new database 'dataWrehouse' and Schemas
===========================================================

-----------------Script Purpose----------------------------
This script create a new database 'DataWarehouse' after checking if it exists. It database exists, then it is dropped and recreated. The scipts create 3 schemas bronze, silver and gold.

--------------------WARNING---------------------------------
Running this script will permanently delete entire database if exists. So before running it, ensure you have proper backups.

*/

USE master;
GO 

  --drop and recreate dataWarehouse database
  IF EXISTS (SELECT 1 FROM sys.databases where name='DataWarehouse')
  BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
  END;
GO

  --Create database
CREATE DATABASE DataWarehouse;
GO 
  
USE DataWarehouse;
GO

  --Create schemas bronze, silver and gold
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO 
CREATE SCHEMA gold;
GO
