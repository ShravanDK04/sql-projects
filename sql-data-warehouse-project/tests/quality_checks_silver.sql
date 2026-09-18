/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Script Purpose:
    This script performs data-quality checks on the Silver layer
    of the DataWarehouse database.

    The checks verify that the cleansing, standardization, and
    transformation logic applied during the Silver loading process
    produced reliable and consistent data.

Checks Performed:
    - Validates record counts for Silver tables.
    - Checks for NULL values in important columns.
    - Checks for duplicate identifiers.
    - Checks for unwanted spaces in text fields.
    - Validates standardized marital status and gender values.
    - Validates standardized product line values.
    - Checks product costs and date ranges.
    - Validates sales amounts, quantities, prices, and dates.
    - Checks customer and product relationships.
    - Checks ERP customer birth dates and gender values.
    - Validates ERP country values.
    - Checks ERP product category data.
    - Reviews transformed records for correctness.

Tables Checked:
    - silver_crm_cust_info
    - silver_crm_prd_info
    - silver_crm_sales_details
    - silver_erp_cust_az12
    - silver_erp_loc_a101
    - silver_erp_px_cat_g1v2

Expected Result:
    The Silver layer should contain clean, standardized, and
    consistent data with no unexpected duplicates, invalid values,
    or transformation issues.

Important:
    These checks should be performed after the Silver loading script
    has completed successfully and before beginning the Gold layer.

===============================================================================
*/

USE DataWarehouse;


/*=============================================================================
    1. ROW COUNT CHECK
=============================================================================*/

SELECT
    'silver_crm_cust_info' AS table_name,
    COUNT(*) AS row_count
FROM silver_crm_cust_info

UNION ALL

SELECT
    'silver_crm_prd_info',
    COUNT(*)
FROM silver_crm_prd_info

UNION ALL

SELECT
    'silver_crm_sales_details',
    COUNT(*)
FROM silver_crm_sales_details

UNION ALL

SELECT
    'silver_erp_cust_az12',
    COUNT(*)
FROM silver_erp_cust_az12

UNION ALL

SELECT
    'silver_erp_loc_a101',
    COUNT(*)
FROM silver_erp_loc_a101

UNION ALL

SELECT
    'silver_erp_px_cat_g1v2',
    COUNT(*)
FROM silver_erp_px_cat_g1v2;


/*=============================================================================
    2. CRM CUSTOMER CHECKS
=============================================================================*/


-- Check NULLs and duplicates in customer ID

SELECT
    cst_id,
    COUNT(*) AS record_count
FROM silver_crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


-- Check unwanted spaces

SELECT *
FROM silver_crm_cust_info
WHERE cst_key <> TRIM(cst_key)
   OR cst_firstname <> TRIM(cst_firstname)
   OR cst_lastname <> TRIM(cst_lastname)
   OR cst_marital_status <> TRIM(cst_marital_status)
   OR cst_gndr <> TRIM(cst_gndr);


-- Check marital status

SELECT DISTINCT
    cst_marital_status
FROM silver_crm_cust_info
ORDER BY cst_marital_status;


-- Check gender

SELECT DISTINCT
    cst_gndr
FROM silver_crm_cust_info
ORDER BY cst_gndr;


-- Verify duplicate customer 29466

SELECT *
FROM silver_crm_cust_info
WHERE cst_id = 29466;


/*=============================================================================
    3. CRM PRODUCT CHECKS
=============================================================================*/


-- Check NULLs and duplicates in product ID

SELECT
    prd_id,
    COUNT(*) AS record_count
FROM silver_crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


-- Check unwanted spaces

SELECT *
FROM silver_crm_prd_info
WHERE prd_key <> TRIM(prd_key)
   OR prd_nm <> TRIM(prd_nm)
   OR prd_line <> TRIM(prd_line);


-- Check NULL or negative product cost

SELECT *
FROM silver_crm_prd_info
WHERE prd_cost IS NULL
   OR prd_cost < 0;


-- Check invalid product date ranges

SELECT *
FROM silver_crm_prd_info
WHERE prd_end_dt < prd_start_dt;


/*=============================================================================
    4. CRM SALES DETAILS CHECKS
=============================================================================*/


-- Check NULL order numbers

SELECT *
FROM silver_crm_sales_details
WHERE sls_ord_num IS NULL;


-- Check unwanted spaces

SELECT *
FROM silver_crm_sales_details
WHERE sls_ord_num <> TRIM(sls_ord_num)
   OR sls_prd_key <> TRIM(sls_prd_key);


-- Check invalid date relationships

SELECT *
FROM silver_crm_sales_details
WHERE sls_ship_dt < sls_order_dt
   OR sls_due_dt < sls_order_dt;


-- Check invalid sales values

SELECT *
FROM silver_crm_sales_details
WHERE sls_sales IS NULL
   OR sls_sales <= 0;


-- Check invalid quantity values

SELECT *
FROM silver_crm_sales_details
WHERE sls_quantity IS NULL
   OR sls_quantity <= 0;


-- Check invalid price values

SELECT *
FROM silver_crm_sales_details
WHERE sls_price IS NULL
   OR sls_price <= 0;


/*=============================================================================
    5. CRM RELATIONSHIP CHECKS
=============================================================================*/


-- Check sales customer IDs against customer table

SELECT DISTINCT
    s.sls_cust_id
FROM silver_crm_sales_details AS s
LEFT JOIN silver_crm_cust_info AS c
    ON s.sls_cust_id = c.cst_id
WHERE c.cst_id IS NULL;


-- Check sales product keys against product table

SELECT DISTINCT
    s.sls_prd_key
FROM silver_crm_sales_details AS s
LEFT JOIN silver_crm_prd_info AS p
    ON s.sls_prd_key = p.prd_key
WHERE p.prd_key IS NULL;


/*=============================================================================
    6. ERP CUSTOMER CHECKS
=============================================================================*/


-- Check NULLs and duplicates

SELECT
    cid,
    COUNT(*) AS record_count
FROM silver_erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1
    OR cid IS NULL;


-- Check unwanted spaces

SELECT *
FROM silver_erp_cust_az12
WHERE cid <> TRIM(cid)
   OR gen <> TRIM(gen);


-- Check future birth dates

SELECT *
FROM silver_erp_cust_az12
WHERE bdate > CURRENT_DATE;


-- Check gender standardization

SELECT DISTINCT
    gen
FROM silver_erp_cust_az12
ORDER BY gen;


/*=============================================================================
    7. ERP LOCATION CHECKS
=============================================================================*/


-- Check NULLs and duplicates

SELECT
    cid,
    COUNT(*) AS record_count
FROM silver_erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1
    OR cid IS NULL;


-- Check unwanted spaces

SELECT *
FROM silver_erp_loc_a101
WHERE cid <> TRIM(cid)
   OR cntry <> TRIM(cntry);


-- Check country values

SELECT DISTINCT
    cntry
FROM silver_erp_loc_a101
ORDER BY cntry;


/*=============================================================================
    8. ERP PRODUCT CATEGORY CHECKS
=============================================================================*/


-- Check NULLs and duplicates

SELECT
    id,
    COUNT(*) AS record_count
FROM silver_erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1
    OR id IS NULL;


-- Check unwanted spaces

SELECT *
FROM silver_erp_px_cat_g1v2
WHERE id <> TRIM(id)
   OR cat <> TRIM(cat)
   OR subcat <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);


-- Check NULL category values

SELECT *
FROM silver_erp_px_cat_g1v2
WHERE cat IS NULL
   OR cat = '';


-- Check NULL subcategory values

SELECT *
FROM silver_erp_px_cat_g1v2
WHERE subcat IS NULL
   OR subcat = '';


-- Check NULL maintenance values

SELECT *
FROM silver_erp_px_cat_g1v2
WHERE maintenance IS NULL
   OR maintenance = '';


/*=============================================================================
    9. SILVER DATA PREVIEW
=============================================================================*/


SELECT *
FROM silver_crm_cust_info
LIMIT 100;

SELECT *
FROM silver_crm_prd_info
LIMIT 100;

SELECT *
FROM silver_crm_sales_details
LIMIT 100;

SELECT *
FROM silver_erp_cust_az12
LIMIT 100;

SELECT *
FROM silver_erp_loc_a101
LIMIT 100;

SELECT *
FROM silver_erp_px_cat_g1v2
LIMIT 100;


/*=============================================================================
    END OF SILVER QUALITY CHECKS
=============================================================================*/
*/
