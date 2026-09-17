/*
===============================================================================
Bronze Layer Load Script
===============================================================================
Script Purpose:
    This script loads raw data from external CRM and ERP CSV files
    into the Bronze layer tables.

    This is the MySQL equivalent of the Bronze loading procedure used
    in the original SQL Server project.

Actions Performed:
    - Records the start time of the Bronze loading batch.
    - Truncates all Bronze tables before loading.
    - Loads data from six CSV source files.
    - Displays progress messages during execution.
    - Measures the loading duration for each table.
    - Measures the total Bronze batch loading duration.

Source Systems:
    - CRM
    - ERP

Files Loaded:
    CRM:
        - cust_info.csv
        - prd_info.csv
        - sales_details.csv

    ERP:
        - CUST_AZ12.csv
        - LOC_A101.csv
        - PX_CAT_G1V2.csv

Important:
    This script uses LOAD DATA LOCAL INFILE.
    The MySQL client must be started with --local-infile=1.

    Example:
    /usr/local/mysql/bin/mysql --local-infile=1 -u root -p

Note:
    MySQL does not allow LOAD DATA inside stored procedures,
    therefore this file is an executable load script rather than
    a stored procedure.

===============================================================================
*/

USE DataWarehouse;


-- ============================================================
-- START BATCH
-- ============================================================

SET @batch_start_time = NOW();

SELECT '=============================================' AS message;
SELECT 'Loading Bronze Layer' AS message;
SELECT '=============================================' AS message;


-- ============================================================
-- TRUNCATE BRONZE TABLES
-- ============================================================

SELECT '=============================================' AS message;
SELECT 'TRUNCATE BRONZE TABLES' AS message;
SELECT '=============================================' AS message;


SELECT '>> Truncating Table: bronze_crm_cust_info' AS message;
TRUNCATE TABLE bronze_crm_cust_info;

SELECT '>> Truncating Table: bronze_crm_prd_info' AS message;
TRUNCATE TABLE bronze_crm_prd_info;

SELECT '>> Truncating Table: bronze_crm_sales_details' AS message;
TRUNCATE TABLE bronze_crm_sales_details;

SELECT '>> Truncating Table: bronze_erp_cust_az12' AS message;
TRUNCATE TABLE bronze_erp_cust_az12;

SELECT '>> Truncating Table: bronze_erp_loc_a101' AS message;
TRUNCATE TABLE bronze_erp_loc_a101;

SELECT '>> Truncating Table: bronze_erp_px_cat_g1v2' AS message;
TRUNCATE TABLE bronze_erp_px_cat_g1v2;


-- ============================================================
-- LOAD: CRM CUSTOMER
-- ============================================================

SELECT '=============================================' AS message;
SELECT 'LOAD: CRM CUSTOMER' AS message;
SELECT '=============================================' AS message;

SET @start_time = NOW();

SELECT '>> Inserting Data Into: bronze_crm_cust_info' AS message;

LOAD DATA LOCAL INFILE '/Users/shravankomejwar/Documents/sql project/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
INTO TABLE bronze_crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT
    'CRM CUSTOMER' AS table_name,
    TIMESTAMPDIFF(SECOND, @start_time, @end_time) AS duration_seconds;


-- ============================================================
-- LOAD: CRM PRODUCT
-- ============================================================

SELECT '=============================================' AS message;
SELECT 'LOAD: CRM PRODUCT' AS message;
SELECT '=============================================' AS message;

SET @start_time = NOW();

SELECT '>> Inserting Data Into: bronze_crm_prd_info' AS message;

LOAD DATA LOCAL INFILE '/Users/shravankomejwar/Documents/sql project/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
INTO TABLE bronze_crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT
    'CRM PRODUCT' AS table_name,
    TIMESTAMPDIFF(SECOND, @start_time, @end_time) AS duration_seconds;


-- ============================================================
-- LOAD: CRM SALES DETAILS
-- ============================================================

SELECT '=============================================' AS message;
SELECT 'LOAD: CRM SALES DETAILS' AS message;
SELECT '=============================================' AS message;

SET @start_time = NOW();

SELECT '>> Inserting Data Into: bronze_crm_sales_details' AS message;

LOAD DATA LOCAL INFILE '/Users/shravankomejwar/Documents/sql project/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
INTO TABLE bronze_crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT
    'CRM SALES DETAILS' AS table_name,
    TIMESTAMPDIFF(SECOND, @start_time, @end_time) AS duration_seconds;


-- ============================================================
-- LOAD: ERP CUSTOMER
-- ============================================================

SELECT '=============================================' AS message;
SELECT 'LOAD: ERP CUSTOMER' AS message;
SELECT '=============================================' AS message;

SET @start_time = NOW();

SELECT '>> Inserting Data Into: bronze_erp_cust_az12' AS message;

LOAD DATA LOCAL INFILE '/Users/shravankomejwar/Documents/sql project/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE bronze_erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT
    'ERP CUSTOMER' AS table_name,
    TIMESTAMPDIFF(SECOND, @start_time, @end_time) AS duration_seconds;


-- ============================================================
-- LOAD: ERP LOCATION
-- ============================================================

SELECT '=============================================' AS message;
SELECT 'LOAD: ERP LOCATION' AS message;
SELECT '=============================================' AS message;

SET @start_time = NOW();

SELECT '>> Inserting Data Into: bronze_erp_loc_a101' AS message;

LOAD DATA LOCAL INFILE '/Users/shravankomejwar/Documents/sql project/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
INTO TABLE bronze_erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT
    'ERP LOCATION' AS table_name,
    TIMESTAMPDIFF(SECOND, @start_time, @end_time) AS duration_seconds;


-- ============================================================
-- LOAD: ERP PRODUCT CATEGORY
-- ============================================================

SELECT '=============================================' AS message;
SELECT 'LOAD: ERP PRODUCT CATEGORY' AS message;
SELECT '=============================================' AS message;

SET @start_time = NOW();

SELECT '>> Inserting Data Into: bronze_erp_px_cat_g1v2' AS message;

LOAD DATA LOCAL INFILE '/Users/shravankomejwar/Documents/sql project/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze_erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT
    'ERP PRODUCT CATEGORY' AS table_name,
    TIMESTAMPDIFF(SECOND, @start_time, @end_time) AS duration_seconds;


-- ============================================================
-- END BATCH
-- ============================================================

SET @batch_end_time = NOW();

SELECT '=============================================' AS message;
SELECT 'Bronze Layer Loading Completed' AS message;
SELECT '=============================================' AS message;

SELECT
    'Bronze Layer Total Duration' AS message,
    TIMESTAMPDIFF(SECOND, @batch_start_time, @batch_end_time) AS duration_seconds;
