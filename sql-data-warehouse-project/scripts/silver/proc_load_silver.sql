/*
===============================================================================
Silver Layer: Data Loading and Transformation Script
===============================================================================
Script Purpose:
    This script transforms and loads data from the Bronze layer into
    the Silver layer of the DataWarehouse database.

    The Silver layer applies data cleansing, standardization,
    deduplication, and business-related transformations while preserving
    the detailed source information.

Actions Performed:
    - Truncates all existing Silver layer tables.
    - Removes duplicate customer records by keeping the latest record.
    - Trims unwanted spaces from text fields.
    - Standardizes marital status and gender values.
    - Standardizes product category identifiers.
    - Standardizes product line descriptions.
    - Handles missing and invalid product costs.
    - Calculates product end dates using LEAD().
    - Converts and validates sales date values.
    - Validates and standardizes sales amounts and prices.
    - Standardizes ERP customer identifiers and gender values.
    - Handles invalid ERP customer birth dates.
    - Standardizes ERP country values.
    - Loads cleaned ERP product category data.
    - Records loading duration for each Silver table.

Source Layer:
    - Bronze

Target Layer:
    - Silver

Tables Loaded:
    - silver_crm_cust_info
    - silver_crm_prd_info
    - silver_crm_sales_details
    - silver_erp_cust_az12
    - silver_erp_loc_a101
    - silver_erp_px_cat_g1v2

Important:
    This script performs a FULL REFRESH of the Silver layer.
    Existing Silver data will be removed before the transformed
    Bronze data is loaded.

    The script uses MySQL-compatible syntax and functions while
    maintaining the transformation logic of the original project.

===============================================================================
*/

USE DataWarehouse;


/* ============================================================
   SILVER LAYER
   BRONZE -> SILVER
   ============================================================ */

SET @silver_start_time = CURRENT_TIMESTAMP(6);

SELECT '=============================================' AS message;
SELECT 'Loading Silver Layer' AS message;
SELECT '=============================================' AS message;


/* ============================================================
   CRM CUSTOMER
   ============================================================ */

SELECT '=============================================' AS message;
SELECT 'LOAD: CRM CUSTOMER' AS message;
SELECT '=============================================' AS message;

SET @start_time = CURRENT_TIMESTAMP(6);

TRUNCATE TABLE silver_crm_cust_info;

INSERT INTO silver_crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,

    cst_key,

    TRIM(cst_firstname) AS cst_firstname,

    TRIM(cst_lastname) AS cst_lastname,

    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S'
            THEN 'Single'

        WHEN UPPER(TRIM(cst_marital_status)) = 'M'
            THEN 'Married'

        ELSE 'n/a'
    END AS cst_marital_status,

    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F'
            THEN 'Female'

        WHEN UPPER(TRIM(cst_gndr)) = 'M'
            THEN 'Male'

        ELSE 'n/a'
    END AS cst_gndr,

    cst_create_date

FROM (
    SELECT
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date,

        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS flag_last

    FROM bronze_crm_cust_info

    WHERE cst_id IS NOT NULL
) AS t

WHERE flag_last = 1;

SET @end_time = CURRENT_TIMESTAMP(6);

SELECT
    'CRM CUSTOMER' AS step,
    @start_time AS start_time,
    @end_time AS end_time,
    TIMESTAMPDIFF(
        MICROSECOND,
        @start_time,
        @end_time
    ) / 1000000 AS duration_seconds;


/* ============================================================
   CRM PRODUCT
   ============================================================ */

SELECT '=============================================' AS message;
SELECT 'LOAD: CRM PRODUCT' AS message;
SELECT '=============================================' AS message;

SET @start_time = CURRENT_TIMESTAMP(6);

TRUNCATE TABLE silver_crm_prd_info;

INSERT INTO silver_crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,

    REPLACE(
        SUBSTRING(prd_key, 1, 5),
        '-',
        '_'
    ) AS cat_id,

    SUBSTRING(
        prd_key,
        7,
        LENGTH(prd_key)
    ) AS prd_key,

    prd_nm,

    COALESCE(prd_cost, 0) AS prd_cost,

    CASE
        WHEN UPPER(TRIM(prd_line)) = 'M'
            THEN 'Mountain'

        WHEN UPPER(TRIM(prd_line)) = 'R'
            THEN 'Road'

        WHEN UPPER(TRIM(prd_line)) = 'S'
            THEN 'Other Sales'

        WHEN UPPER(TRIM(prd_line)) = 'T'
            THEN 'Touring'

        ELSE 'n/a'
    END AS prd_line,

    prd_start_dt,

    DATE_SUB(
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_dt
        ),
        INTERVAL 1 DAY
    ) AS prd_end_dt

FROM bronze_crm_prd_info;

SET @end_time = CURRENT_TIMESTAMP(6);

SELECT
    'CRM PRODUCT' AS step,
    @start_time AS start_time,
    @end_time AS end_time,
    TIMESTAMPDIFF(
        MICROSECOND,
        @start_time,
        @end_time
    ) / 1000000 AS duration_seconds;


/* ============================================================
   CRM SALES DETAILS
   ============================================================ */

SELECT '=============================================' AS message;
SELECT 'LOAD: CRM SALES DETAILS' AS message;
SELECT '=============================================' AS message;

SET @start_time = CURRENT_TIMESTAMP(6);

TRUNCATE TABLE silver_crm_sales_details;

INSERT INTO silver_crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    sls_ord_num,

    sls_prd_key,

    sls_cust_id,

    sls_order_dt,

    sls_ship_dt,

    sls_due_dt,

    CASE
        WHEN sls_sales IS NULL
             OR sls_sales <= 0
             OR sls_sales <> sls_quantity * ABS(sls_price)

        THEN sls_quantity * ABS(sls_price)

        ELSE sls_sales
    END AS sls_sales,

    sls_quantity,

    CASE
        WHEN sls_price IS NULL
             OR sls_price <= 0

        THEN sls_sales / NULLIF(sls_quantity, 0)

        ELSE sls_price
    END AS sls_price

FROM bronze_crm_sales_details;

SET @end_time = CURRENT_TIMESTAMP(6);

SELECT
    'CRM SALES DETAILS' AS step,
    @start_time AS start_time,
    @end_time AS end_time,
    TIMESTAMPDIFF(
        MICROSECOND,
        @start_time,
        @end_time
    ) / 1000000 AS duration_seconds;


/* ============================================================
   ERP CUSTOMER
   ============================================================ */

SELECT '=============================================' AS message;
SELECT 'LOAD: ERP CUSTOMER' AS message;
SELECT '=============================================' AS message;

SET @start_time = CURRENT_TIMESTAMP(6);

TRUNCATE TABLE silver_erp_cust_az12;

INSERT INTO silver_erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT

    CASE
        WHEN cid LIKE 'NAS%'
            THEN SUBSTRING(
                cid,
                4,
                LENGTH(cid)
            )

        ELSE cid
    END AS cid,

    CASE
        WHEN bdate IS NULL
            THEN NULL

        WHEN bdate > CURRENT_DATE
            THEN NULL

        WHEN bdate < '1924-01-01'
            THEN NULL

        ELSE bdate
    END AS bdate,

    CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE')
            THEN 'Female'

        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')
            THEN 'Male'

        ELSE 'n/a'
    END AS gen

FROM bronze_erp_cust_az12;

SET @end_time = CURRENT_TIMESTAMP(6);

SELECT
    'ERP CUSTOMER' AS step,
    @start_time AS start_time,
    @end_time AS end_time,
    TIMESTAMPDIFF(
        MICROSECOND,
        @start_time,
        @end_time
    ) / 1000000 AS duration_seconds;


/* ============================================================
   ERP LOCATION
   ============================================================ */

SELECT '=============================================' AS message;
SELECT 'LOAD: ERP LOCATION' AS message;
SELECT '=============================================' AS message;

SET @start_time = CURRENT_TIMESTAMP(6);

TRUNCATE TABLE silver_erp_loc_a101;

INSERT INTO silver_erp_loc_a101 (
    cid,
    cntry
)
SELECT

    REPLACE(
        cid,
        '-',
        ''
    ) AS cid,

    CASE
        WHEN TRIM(cntry) = 'DE'
            THEN 'Germany'

        WHEN TRIM(cntry) IN ('US', 'USA')
            THEN 'United States'

        WHEN TRIM(cntry) = ''
             OR cntry IS NULL
            THEN 'n/a'

        ELSE TRIM(cntry)
    END AS cntry

FROM bronze_erp_loc_a101;

SET @end_time = CURRENT_TIMESTAMP(6);

SELECT
    'ERP LOCATION' AS step,
    @start_time AS start_time,
    @end_time AS end_time,
    TIMESTAMPDIFF(
        MICROSECOND,
        @start_time,
        @end_time
    ) / 1000000 AS duration_seconds;


/* ============================================================
   ERP PRODUCT CATEGORY
   ============================================================ */

SELECT '=============================================' AS message;
SELECT 'LOAD: ERP PRODUCT CATEGORY' AS message;
SELECT '=============================================' AS message;

SET @start_time = CURRENT_TIMESTAMP(6);

TRUNCATE TABLE silver_erp_px_cat_g1v2;

INSERT INTO silver_erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maintenance
)
SELECT
    id,
    cat,
    subcat,
    maintenance

FROM bronze_erp_px_cat_g1v2;

SET @end_time = CURRENT_TIMESTAMP(6);

SELECT
    'ERP PRODUCT CATEGORY' AS step,
    @start_time AS start_time,
    @end_time AS end_time,
    TIMESTAMPDIFF(
        MICROSECOND,
        @start_time,
        @end_time
    ) / 1000000 AS duration_seconds;


/* ============================================================
   SILVER LAYER COMPLETION
   ============================================================ */

SET @silver_end_time = CURRENT_TIMESTAMP(6);

SELECT '=============================================' AS message;
SELECT 'Loading Silver Layer is Completed' AS message;
SELECT '=============================================' AS message;


/* ============================================================
   TOTAL SILVER LAYER EXECUTION TIME
   ============================================================ */

SELECT
    @silver_start_time AS silver_start_time,
    @silver_end_time AS silver_end_time,
    TIMESTAMPDIFF(
        MICROSECOND,
        @silver_start_time,
        @silver_end_time
    ) / 1000000 AS total_duration_seconds;
