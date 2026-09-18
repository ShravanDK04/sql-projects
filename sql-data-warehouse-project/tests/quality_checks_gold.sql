/*
================================================================================
Gold Layer - Quality Checks
================================================================================
Purpose:
    Validate the quality and integrity of the Gold layer views.

Checks:
    - Check for duplicate customer surrogate keys
    - Check for duplicate product surrogate keys
    - Check fact-to-customer relationships
    - Check fact-to-product relationships

Expectation:
    All checks should return no records.
================================================================================
*/

USE DataWarehouse;

-- ================================================================
-- GOLD LAYER QUALITY CHECKS
-- ================================================================


-- ================================================================
-- Checking gold_dim_customers
-- ================================================================

-- Check for duplicate customer keys
-- Expectation: No results

SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold_dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ================================================================
-- Checking gold_dim_products
-- ================================================================

-- Check for duplicate product keys
-- Expectation: No results

SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold_dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ================================================================
-- Checking gold_fact_sales
-- ================================================================

-- Check connectivity between fact and dimensions
-- Expectation: No results

SELECT
    f.order_number,
    f.customer_key,
    f.product_key
FROM gold_fact_sales f
LEFT JOIN gold_dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold_dim_products p
    ON p.product_key = f.product_key
WHERE c.customer_key IS NULL
   OR p.product_key IS NULL;
