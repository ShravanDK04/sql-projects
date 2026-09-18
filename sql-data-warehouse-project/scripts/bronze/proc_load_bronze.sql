/*
===============================================================================
Bronze Layer: Data Loading Script
===============================================================================
Script Purpose:
    This script loads raw CRM and ERP CSV data into the Bronze layer
    of the DataWarehouse database.

    The Bronze layer is designed to preserve source data with minimal
    transformation before it moves into the Silver layer.

Actions Performed:
    - Truncates all existing Bronze layer tables.
    - Loads CRM customer, product, and sales data.
    - Loads ERP customer, location, and product category data.
    - Handles empty source date values by converting them to NULL.
    - Converts CRM sales date values from YYYYMMDD format into MySQL DATE values.
    - Displays loading status and execution duration for each table.

Source Systems:
    - CRM
    - ERP

Tables Loaded:
    - bronze_crm_cust_info
    - bronze_crm_prd_info
    - bronze_crm_sales_details
    - bronze_erp_cust_az12
    - bronze_erp_loc_a101
    - bronze_erp_px_cat_g1v2

Important:
    This script performs a FULL REFRESH of the Bronze layer.
    Existing data in the Bronze tables will be removed before loading
    the source CSV files.

    In MySQL, LOAD DATA LOCAL INFILE is used instead of SQL Server's
    BULK INSERT command.

===============================================================================
*/

USE DataWarehouse;


/* ============================================================
   BRONZE LAYER
   SOURCE FILES -> BRONZE
   ============================================================ */

SELECT '=============================================' AS message;
SELECT 'Loading Bronze Layer' AS message;
SELECT '=============================================' AS message;


/* ============================================================
   CRM CUSTOMER
   ============================================================ */

SELECT '=============================================' AS message;
SELECT 'LOAD: CRM CUSTOMER' AS message;
SELECT '=============================================' AS message;

TRUNCATE TABLE bronze_crm_cust_info;

LOAD DATA LOCAL INFILE '/Users/shravankomejwar/Documents/sql project/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
INTO TABLE bronze_crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    @cst_create_date
)
SET cst_create_date = NULLIF(@cst_create_date, '');


/* ============================================================
   CRM PRODUCT
   ============================================================ */

SELECT '=============================================' AS message;
SELECT 'LOAD: CRM PRODUCT' AS message;
SELECT '=============================================' AS message;

TRUNCATE TABLE bronze_crm_prd_info;

LOAD DATA LOCAL INFILE '/Users/shravankomejwar/Documents/sql project/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
INTO TABLE bronze_crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    @prd_start_dt,
    @prd_end_dt
)
SET
    prd_start_dt = NULLIF(@prd_start_dt, ''),
    prd_end_dt = NULLIF(@prd_end_dt, '');


/* ============================================================
   CRM SALES DETAILS
   ============================================================ */

SELECT '=============================================' AS message;
SELECT 'LOAD: CRM SALES DETAILS' AS message;
SELECT '=============================================' AS message;

TRUNCATE TABLE bronze_crm_sales_details;

LOAD DATA LOCAL INFILE '/Users/shravankomejwar/Documents/sql project/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
INTO TABLE bronze_crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    @sls_order_dt,
    @sls_ship_dt,
    @sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SET
    sls_order_dt = NULLIF(@sls_order_dt, ''),
    sls_ship_dt = NULLIF(@sls_ship_dt, ''),
    sls_due_dt = NULLIF(@sls_due_dt, '');


/* ============================================================
   ERP CUSTOMER
   ============================================================ */

SELECT '=============================================' AS message;
SELECT 'LOAD: ERP CUSTOMER' AS message;
SELECT '=============================================' AS message;

TRUNCATE TABLE bronze_erp_cust_az12;

LOAD DATA LOCAL INFILE '/Users/shravankomejwar/Documents/sql project/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE bronze_erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    cid,
    @bdate,
    gen
)
SET bdate = NULLIF(@bdate, '');


/* ============================================================
   ERP LOCATION
   ============================================================ */

SELECT '=============================================' AS message;
SELECT 'LOAD: ERP LOCATION' AS message;
SELECT '=============================================' AS message;

TRUNCATE TABLE bronze_erp_loc_a101;

LOAD DATA LOCAL INFILE '/Users/shravankomejwar/Documents/sql project/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
INTO TABLE bronze_erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    cid,
    cntry
);


/* ============================================================
   ERP PRODUCT CATEGORY
   ============================================================ */

SELECT '=============================================' AS message;
SELECT 'LOAD: ERP PRODUCT CATEGORY' AS message;
SELECT '=============================================' AS message;

TRUNCATE TABLE bronze_erp_px_cat_g1v2;

LOAD DATA LOCAL INFILE '/Users/shravankomejwar/Documents/sql project/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze_erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    id,
    cat,
    subcat,
    maintenance
);


/* ============================================================
   COMPLETION
   ============================================================ */

SELECT '=============================================' AS message;
SELECT 'Loading Bronze Layer is Completed' AS message;
SELECT '=============================================' AS message;
