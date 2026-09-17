/*
===============================================================================
Quality Checks: Bronze Layer
===============================================================================
Script Purpose:
    This script performs basic quality checks on the Bronze layer
    after the source data has been loaded.

Checks Performed:
    - Verifies the row count of each Bronze table.
    - Compares the loaded row counts with the expected source data.
    - Checks for NULLs and duplicates in customer IDs.
    - Checks for unwanted spaces in customer attributes.
    - Checks data standardization and consistency.

Bronze Tables Checked:
    - bronze_crm_cust_info
    - bronze_crm_prd_info
    - bronze_crm_sales_details
    - bronze_erp_cust_az12
    - bronze_erp_loc_a101
    - bronze_erp_px_cat_g1v2

Expected Row Counts:
    - bronze_crm_cust_info       : 18,494
    - bronze_crm_prd_info        : 397
    - bronze_crm_sales_details   : 60,398
    - bronze_erp_cust_az12       : 18,484
    - bronze_erp_loc_a101        : 18,484
    - bronze_erp_px_cat_g1v2     : 37

Important:
    Run this script after executing proc_load_bronze.sql.

===============================================================================
*/

USE DataWarehouse;


-- ============================================================================
-- 1. ROW COUNT CHECKS
-- ============================================================================

SELECT 'bronze_crm_cust_info' AS table_name, COUNT(*) AS row_count
FROM bronze_crm_cust_info

UNION ALL

SELECT 'bronze_crm_prd_info', COUNT(*)
FROM bronze_crm_prd_info

UNION ALL

SELECT 'bronze_crm_sales_details', COUNT(*)
FROM bronze_crm_sales_details

UNION ALL

SELECT 'bronze_erp_cust_az12', COUNT(*)
FROM bronze_erp_cust_az12

UNION ALL

SELECT 'bronze_erp_loc_a101', COUNT(*)
FROM bronze_erp_loc_a101

UNION ALL

SELECT 'bronze_erp_px_cat_g1v2', COUNT(*)
FROM bronze_erp_px_cat_g1v2;


-- ============================================================================
-- 2. CRM CUSTOMER QUALITY CHECKS
-- ============================================================================


-- Check for NULLs or duplicates in cst_id
-- Expectation: No results

SELECT
    cst_id,
    COUNT(*) AS record_count
FROM bronze_crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


-- Check for unwanted spaces in cst_key
-- Expectation: No results

SELECT
    cst_key
FROM bronze_crm_cust_info
WHERE cst_key <> TRIM(cst_key);


-- Check for unwanted spaces in cst_firstname
-- Expectation: No results

SELECT
    cst_firstname
FROM bronze_crm_cust_info
WHERE cst_firstname <> TRIM(cst_firstname);


-- Check for unwanted spaces in cst_lastname
-- Expectation: No results

SELECT
    cst_lastname
FROM bronze_crm_cust_info
WHERE cst_lastname <> TRIM(cst_lastname);


-- Check for unwanted spaces in cst_marital_status
-- Expectation: No results

SELECT
    cst_marital_status
FROM bronze_crm_cust_info
WHERE cst_marital_status <> TRIM(cst_marital_status);


-- Check for unwanted spaces in cst_gndr
-- Expectation: No results

SELECT
    cst_gndr
FROM bronze_crm_cust_info
WHERE cst_gndr <> TRIM(cst_gndr);


-- ============================================================================
-- 3. DATA STANDARDIZATION & CONSISTENCY
-- ============================================================================

-- Check marital status values

SELECT DISTINCT
    cst_marital_status
FROM bronze_crm_cust_info;


-- Check gender values

SELECT DISTINCT
    cst_gndr
FROM bronze_crm_cust_info;
