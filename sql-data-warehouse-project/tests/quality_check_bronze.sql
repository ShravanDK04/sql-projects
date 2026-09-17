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
