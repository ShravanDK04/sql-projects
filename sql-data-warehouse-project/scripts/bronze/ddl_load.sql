/*
===============================================================================
DDL Script: Create Bronze Layer Tables
===============================================================================
Script Purpose:
    This script creates the Bronze layer tables in the DataWarehouse database.

    The Bronze layer stores raw data loaded from the source CRM and ERP
    CSV files with minimal transformation.

Actions Performed:
    - Creates the DataWarehouse database if it does not exist.
    - Drops existing Bronze tables if they already exist.
    - Creates the six Bronze layer tables.
    - Uses naming conventions based on source system and source entity.

Source Systems:
    - CRM
    - ERP

Tables Created:
    - bronze_crm_cust_info
    - bronze_crm_prd_info
    - bronze_crm_sales_details
    - bronze_erp_cust_az12
    - bronze_erp_loc_a101
    - bronze_erp_px_cat_g1v2

Important:
    Running this script will DROP and recreate the Bronze tables,
    which removes any existing data in those tables.

===============================================================================
*/

CREATE DATABASE IF NOT EXISTS DataWarehouse;

USE DataWarehouse;


-- =========================================
-- BRONZE: CRM CUSTOMER
-- =========================================

DROP TABLE IF EXISTS bronze_crm_cust_info;

CREATE TABLE bronze_crm_cust_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);


-- =========================================
-- BRONZE: CRM PRODUCT
-- =========================================

DROP TABLE IF EXISTS bronze_crm_prd_info;

CREATE TABLE bronze_crm_prd_info (
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE
);


-- =========================================
-- BRONZE: CRM SALES DETAILS
-- =========================================

DROP TABLE IF EXISTS bronze_crm_sales_details;

CREATE TABLE bronze_crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);


-- =========================================
-- BRONZE: ERP CUSTOMER
-- =========================================

DROP TABLE IF EXISTS bronze_erp_cust_az12;

CREATE TABLE bronze_erp_cust_az12 (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50)
);


-- =========================================
-- BRONZE: ERP LOCATION
-- =========================================

DROP TABLE IF EXISTS bronze_erp_loc_a101;

CREATE TABLE bronze_erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50)
);


-- =========================================
-- BRONZE: ERP PRODUCT CATEGORY
-- =========================================

DROP TABLE IF EXISTS bronze_erp_px_cat_g1v2;

CREATE TABLE bronze_erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50)
);
