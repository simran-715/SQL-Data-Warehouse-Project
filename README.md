# Data Warehouse Project (Medallion Architecture)
📌 Overview

This project implements a data warehouse using the Medallion Architecture (Bronze → Silver → Gold) to transform raw data into business-ready insights.

The pipeline integrates data from multiple sources, performs cleaning and transformation, and models it into a star schema for analytics.

# Architecture

🥉 **Bronze Layer (Raw Data)**

      Stores raw data as-is from source systems
      
      Data is loaded using TRUNCATE + INSERT
      
      No transformations applied
🥈 **Silver Layer (Cleaned Data)**
Applies data cleaning and transformations

Handles:

      -Null values

      -Data standardization
      
      -Filtering (e.g., removing historical records)
      
      -Data is reloaded using TRUNCATE + INSERT
      
🥇 ** Gold Layer (Business Layer)**
Creates business-ready views
Implements Star Schema
Performs:

      -Aggregation
      
      -Data modeling
      
      -Lookup using surrogate keys
      
# Data Sources
**Source: source_crm (CSV files)**

      cust_info → Customer data
      
      prd_info → Product data
      
      sales_details → Sales transactions
**Source: source_erp (CSV files)**

      cust_az12 → Additional customer info
      
      loc_a101 → Customer location
      
      px_cat_g1v2 → Product category
      
# ⭐ Gold Layer Data Model (Star Schema)
**Dimensions:**

        dim_customers
            -Contains cleaned and enriched customer data
            -Uses surrogate key: customer_key
            
        dim_products
            -Contains product details with categories
            -Uses surrogate key: product_key
      
**Fact Table:**

       **fact_sales**
      Stores transactional sales data
      Uses lookup joins to map:
            -customer_key
            -product_key
                        
# Key Concepts Used

        -Medallion Architecture (Bronze, Silver, Gold)
        
        -ETL Pipeline Design
        
        -Star Schema Modeling
        
        -Surrogate Keys for dimensions
        
        -Lookup transformations in fact tables
        
        -Data cleaning and standardization
  
# Data Loading Strategy

        -Bronze & Silver layers use:
        
        -TRUNCATE + INSERT
**Ensures:**

          -Simplicity
          
          -Full refresh of data
          
          -Consistency across layers
      

**The final output consists of 3 analytical views:**

        -dim_customers
        
        -dim_products
        
        -fact_sales

**These are optimized for:**

          -Reporting
          
          -Dashboarding
          
          -Business analysis
          
**How to Use**

          -Load raw CSV files into Bronze tables
          
          -Run transformation scripts for Silver layer
          
          -Execute Gold layer scripts to create views
          
          -Use Gold views for analytics and reporting
          
**Key Takeaways**

          Bronze = Raw data
          
          Silver = Cleaned data
          
          Gold = Business-ready data
          
          Star Schema = Fast analytics
          
          Surrogate keys = Efficient joins
