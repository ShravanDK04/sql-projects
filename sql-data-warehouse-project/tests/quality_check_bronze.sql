/*
===============================================================================
Quality Checks: Bronze Layer
===============================================================================
Script Purpose:
    This script performs data-quality checks on the Bronze layer
    of the DataWarehouse database.

    The checks are used to verify that the raw CRM and ERP data was
    loaded correctly before applying transformations in the Silver layer.

Checks Performed:
    - Validates record counts for Bronze tables.
    - Checks for NULL values in important columns.
    - Checks for duplicate records and identifiers.
    - Checks for unwanted spaces in text columns.
    - Checks date values for invalid or unexpected values.
    - Reviews source values before transformation.
    - Validates the overall Bronze data load.

Tables Checked:
    - bronze_crm_cust_info
    - bronze_crm_prd_info
    - bronze_crm_sales_details
    - bronze_erp_cust_az12
    - bronze_erp_loc_a101
    - bronze_erp_px_cat_g1v2

Expected Result:
    The Bronze layer should contain the expected source records
    without unexpected data loss or loading errors.

Important:
    Bronze is intended to represent raw source data, so these checks
    validate the loaded data rather than performing transformations.

===============================================================================
*/

USE DataWarehouse;


/*=============================================================================
    1. ROW COUNT CHECKS
=============================================================================*/

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


/*=============================================================================
    2. CRM CUSTOMER - bronze_crm_cust_info
=============================================================================*/


-- Check NULLs and duplicates in customer ID

SELECT
    cst_id,
    COUNT(*) AS record_count
FROM bronze_crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


-- Check unwanted spaces

SELECT *
FROM bronze_crm_cust_info
WHERE cst_key <> TRIM(cst_key)
   OR cst_firstname <> TRIM(cst_firstname)
   OR cst_lastname <> TRIM(cst_lastname)
   OR cst_marital_status <> TRIM(cst_marital_status)
   OR cst_gndr <> TRIM(cst_gndr);


-- Check marital status values

SELECT DISTINCT
    cst_marital_status
FROM bronze_crm_cust_info
ORDER BY cst_marital_status;


-- Check gender values

SELECT DISTINCT
    cst_gndr
FROM bronze_crm_cust_info
ORDER BY cst_gndr;


/*=============================================================================
    3. CRM PRODUCT - bronze_crm_prd_info
=============================================================================*/


-- Check NULLs and duplicates in product ID

SELECT
    prd_id,
    COUNT(*) AS record_count
FROM bronze_crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


-- Check unwanted spaces

SELECT *
FROM bronze_crm_prd_info
WHERE prd_key <> TRIM(prd_key)
   OR prd_nm <> TRIM(prd_nm)
   OR prd_line <> TRIM(prd_line);


-- Check NULL or negative product cost

SELECT *
FROM bronze_crm_prd_info
WHERE prd_cost < 0
   OR prd_cost IS NULL;


-- Check product line values

SELECT DISTINCT
    prd_line
FROM bronze_crm_prd_info
ORDER BY prd_line;


-- Check invalid product date ranges

SELECT *
FROM bronze_crm_prd_info
WHERE prd_end_dt < prd_start_dt;


/*=============================================================================
    4. CRM SALES - bronze_crm_sales_details
=============================================================================*/


-- Check NULL order numbers

SELECT *
FROM bronze_crm_sales_details
WHERE sls_ord_num IS NULL;


-- Check unwanted spaces

SELECT *
FROM bronze_crm_sales_details
WHERE sls_ord_num <> TRIM(sls_ord_num)
   OR sls_prd_key <> TRIM(sls_prd_key);


-- Check invalid order / shipping / due date sequence

SELECT *
FROM bronze_crm_sales_details
WHERE sls_ship_dt < sls_order_dt
   OR sls_due_dt < sls_order_dt;


-- Check invalid sales values

SELECT *
FROM bronze_crm_sales_details
WHERE sls_sales IS NULL
   OR sls_sales <= 0;


-- Check invalid quantity values

SELECT *
FROM bronze_crm_sales_details
WHERE sls_quantity IS NULL
   OR sls_quantity <= 0;


-- Check invalid price values

SELECT *
FROM bronze_crm_sales_details
WHERE sls_price IS NULL
   OR sls_price <= 0;


-- Check sales consistency
-- Expected: sales = quantity * price

SELECT *
FROM bronze_crm_sales_details
WHERE sls_sales <> sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL;


/*=============================================================================
    5. CRM RELATIONSHIP CHECKS
=============================================================================*/


-- Sales customer IDs not found in CRM customer table

SELECT DISTINCT
    s.sls_cust_id
FROM bronze_crm_sales_details AS s
LEFT JOIN bronze_crm_cust_info AS c
    ON s.sls_cust_id = c.cst_id
WHERE c.cst_id IS NULL;


-- Sales product keys not found in CRM product table

SELECT DISTINCT
    s.sls_prd_key
FROM bronze_crm_sales_details AS s
LEFT JOIN bronze_crm_prd_info AS p
    ON s.sls_prd_key = p.prd_key
WHERE p.prd_key IS NULL;


/*=============================================================================
    6. ERP CUSTOMER - bronze_erp_cust_az12
=============================================================================*/


-- Check NULLs and duplicates in customer ID

SELECT
    cid,
    COUNT(*) AS record_count
FROM bronze_erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1
    OR cid IS NULL;


-- Check unwanted spaces

SELECT *
FROM bronze_erp_cust_az12
WHERE cid <> TRIM(cid)
   OR gen <> TRIM(gen);


-- Check birth date range

SELECT *
FROM bronze_erp_cust_az12
WHERE bdate > CURRENT_DATE
   OR bdate < '1924-01-01';


-- Check gender values

SELECT DISTINCT
    gen
FROM bronze_erp_cust_az12
ORDER BY gen;


/*=============================================================================
    7. ERP LOCATION - bronze_erp_loc_a101
=============================================================================*/


-- Check NULLs and duplicates in customer ID

SELECT
    cid,
    COUNT(*) AS record_count
FROM bronze_erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1
    OR cid IS NULL;


-- Check unwanted spaces

SELECT *
FROM bronze_erp_loc_a101
WHERE cid <> TRIM(cid)
   OR cntry <> TRIM(cntry);


-- Check country values

SELECT DISTINCT
    cntry
FROM bronze_erp_loc_a101
ORDER BY cntry;


/*=============================================================================
    8. ERP PRODUCT CATEGORY - bronze_erp_px_cat_g1v2
=============================================================================*/


-- Check NULLs and duplicates in category ID

SELECT
    id,
    COUNT(*) AS record_count
FROM bronze_erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1
    OR id IS NULL;


-- Check unwanted spaces

SELECT *
FROM bronze_erp_px_cat_g1v2
WHERE id <> TRIM(id)
   OR cat <> TRIM(cat)
   OR subcat <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);


-- Check category values

SELECT DISTINCT
    cat
FROM bronze_erp_px_cat_g1v2
ORDER BY cat;


-- Check subcategory values

SELECT DISTINCT
    subcat
FROM bronze_erp_px_cat_g1v2
ORDER BY subcat;


-- Check maintenance values

SELECT DISTINCT
    maintenance
FROM bronze_erp_px_cat_g1v2
ORDER BY maintenance;


/*=============================================================================
    END OF BRONZE QUALITY CHECKS
=============================================================================*/
