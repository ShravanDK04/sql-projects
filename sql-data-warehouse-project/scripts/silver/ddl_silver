/*
===============================================================================
DDL Script: Create Silver Layer Tables
===============================================================================
Script Purpose:
    This script creates the Silver layer tables in the DataWarehouse database.

    The Silver layer stores cleansed, standardized, and transformed data
    from the Bronze layer.

Actions Performed:
    - Drops existing Silver tables if they already exist.
    - Creates the six Silver layer tables.
    - Adds data warehouse technical metadata using dwh_create_date.
    - Defines structures for cleaned CRM and ERP data.

Source Systems:
    - CRM
    - ERP

Tables Created:
    - silver_crm_cust_info
    - silver_crm_prd_info
    - silver_crm_sales_details
    - silver_erp_cust_az12
    - silver_erp_loc_a101
    - silver_erp_px_cat_g1v2

Silver Layer Purpose:
    - Clean and standardize source data.
    - Prepare data for business-oriented modeling in the Gold layer.
    - Provide a consistent and reliable dataset for downstream processing.

Important:
    Running this script will DROP and recreate the Silver tables,
    which removes any existing data in those tables.

===============================================================================
*/

CREATE DATABASE IF NOT EXISTS DataWarehouse;

USE DataWarehouse;


-- ============================================================================
-- CRM CUSTOMER
-- ============================================================================

DROP TABLE IF EXISTS silver_crm_cust_info;

CREATE TABLE silver_crm_cust_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- CRM PRODUCT
-- ============================================================================

DROP TABLE IF EXISTS silver_crm_prd_info;

CREATE TABLE silver_crm_prd_info (
    prd_id INT,
    cat_id VARCHAR(50),
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- CRM SALES DETAILS
-- ============================================================================

DROP TABLE IF EXISTS silver_crm_sales_details;

CREATE TABLE silver_crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- ERP CUSTOMER
-- ============================================================================

DROP TABLE IF EXISTS silver_erp_cust_az12;

CREATE TABLE silver_erp_cust_az12 (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50),
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- ERP LOCATION
-- ============================================================================

DROP TABLE IF EXISTS silver_erp_loc_a101;

CREATE TABLE silver_erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50),
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- ERP PRODUCT CATEGORY
-- ============================================================================

DROP TABLE IF EXISTS silver_erp_px_cat_g1v2;

CREATE TABLE silver_erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50),
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);
