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
