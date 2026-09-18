USE DataWarehouse;

-- =========================================================
-- GOLD LAYER BUSINESS ANALYSIS
-- =========================================================


-- =========================================================
-- 1. TOTAL REVENUE
-- =========================================================

SELECT
    ROUND(SUM(sales_amount), 2) AS total_revenue
FROM gold_fact_sales;


-- =========================================================
-- 2. TOTAL ORDERS
-- =========================================================

SELECT
    COUNT(DISTINCT order_number) AS total_orders
FROM gold_fact_sales;


-- =========================================================
-- 3. TOTAL PURCHASING CUSTOMERS
-- =========================================================

SELECT
    COUNT(DISTINCT customer_key) AS purchasing_customers
FROM gold_fact_sales
WHERE customer_key IS NOT NULL;


-- =========================================================
-- 4. AVERAGE ORDER VALUE
-- =========================================================

SELECT
    ROUND(
        SUM(sales_amount) / COUNT(DISTINCT order_number),
        2
    ) AS average_order_value
FROM gold_fact_sales;


-- =========================================================
-- 5. TOTAL QUANTITY SOLD
-- =========================================================

SELECT
    SUM(quantity) AS total_quantity_sold
FROM gold_fact_sales;


-- =========================================================
-- 6. SALES PERFORMANCE BY COUNTRY
-- =========================================================

SELECT
    c.country,
    COUNT(DISTINCT f.order_number) AS total_orders,
    COUNT(DISTINCT f.customer_key) AS customers,
    SUM(f.sales_amount) AS total_revenue,
    ROUND(AVG(f.sales_amount), 2) AS average_sales
FROM gold_fact_sales f
JOIN gold_dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_revenue DESC;


-- =========================================================
-- 7. SALES PERFORMANCE BY PRODUCT CATEGORY
-- =========================================================

SELECT
    p.category,
    COUNT(DISTINCT f.order_number) AS total_orders,
    SUM(f.quantity) AS quantity_sold,
    SUM(f.sales_amount) AS total_revenue,
    ROUND(AVG(f.price), 2) AS average_price
FROM gold_fact_sales f
JOIN gold_dim_products p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;


-- =========================================================
-- 8. PRODUCT PERFORMANCE
-- =========================================================

SELECT
    p.product_number,
    p.product_name,
    p.category,
    p.product_line,
    COUNT(DISTINCT f.order_number) AS orders,
    COUNT(DISTINCT f.customer_key) AS customers,
    SUM(f.quantity) AS quantity_sold,
    SUM(f.sales_amount) AS revenue,
    ROUND(AVG(f.price), 2) AS average_price
FROM gold_fact_sales f
JOIN gold_dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.product_number,
    p.product_name,
    p.category,
    p.product_line
ORDER BY revenue DESC;


-- =========================================================
-- 9. TOP 10 PRODUCTS BY REVENUE
-- =========================================================

SELECT
    p.product_number,
    p.product_name,
    p.category,
    SUM(f.sales_amount) AS revenue
FROM gold_fact_sales f
JOIN gold_dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.product_number,
    p.product_name,
    p.category
ORDER BY revenue DESC
LIMIT 10;


-- =========================================================
-- 10. TOP 10 CUSTOMERS BY REVENUE
-- =========================================================

SELECT
    c.customer_number,
    c.first_name,
    c.last_name,
    c.country,
    COUNT(DISTINCT f.order_number) AS total_orders,
    SUM(f.sales_amount) AS total_revenue
FROM gold_fact_sales f
JOIN gold_dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_number,
    c.first_name,
    c.last_name,
    c.country
ORDER BY total_revenue DESC
LIMIT 10;


-- =========================================================
-- 11. CUSTOMER VALUE SEGMENTATION
-- =========================================================

SELECT
    c.customer_number,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue,
    CASE
        WHEN SUM(f.sales_amount) >= 10000 THEN 'High Value'
        WHEN SUM(f.sales_amount) >= 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM gold_fact_sales f
JOIN gold_dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_number,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;


-- =========================================================
-- 12. CUSTOMER SEGMENT DISTRIBUTION
-- =========================================================

SELECT
    customer_segment,
    COUNT(*) AS customer_count
FROM (
    SELECT
        c.customer_key,
        CASE
            WHEN SUM(f.sales_amount) >= 10000 THEN 'High Value'
            WHEN SUM(f.sales_amount) >= 5000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM gold_fact_sales f
    JOIN gold_dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
) AS customer_segments
GROUP BY customer_segment
ORDER BY customer_count DESC;


-- =========================================================
-- 13. ONE-TIME VS REPEAT CUSTOMERS
-- =========================================================

SELECT
    CASE
        WHEN order_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS customers,
    SUM(total_revenue) AS revenue
FROM (
    SELECT
        customer_key,
        COUNT(DISTINCT order_number) AS order_count,
        SUM(sales_amount) AS total_revenue
    FROM gold_fact_sales
    WHERE customer_key IS NOT NULL
    GROUP BY customer_key
) AS customer_summary
GROUP BY
    CASE
        WHEN order_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END
ORDER BY revenue DESC;


-- =========================================================
-- 14. CUSTOMER PURCHASE FREQUENCY
-- =========================================================

SELECT
    c.customer_number,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT f.order_number) AS order_count,
    SUM(f.quantity) AS quantity_purchased,
    SUM(f.sales_amount) AS total_revenue
FROM gold_fact_sales f
JOIN gold_dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_number,
    c.first_name,
    c.last_name
ORDER BY order_count DESC, total_revenue DESC;


-- =========================================================
-- 15. SALES BY PRODUCT LINE
-- =========================================================

SELECT
    p.product_line,
    COUNT(DISTINCT f.order_number) AS orders,
    SUM(f.quantity) AS quantity_sold,
    SUM(f.sales_amount) AS revenue,
    ROUND(AVG(f.price), 2) AS average_price
FROM gold_fact_sales f
JOIN gold_dim_products p
    ON f.product_key = p.product_key
GROUP BY p.product_line
ORDER BY revenue DESC;


-- =========================================================
-- 16. MONTHLY SALES TREND
-- =========================================================

SELECT
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,
    COUNT(DISTINCT order_number) AS orders,
    SUM(quantity) AS quantity_sold,
    SUM(sales_amount) AS revenue
FROM gold_fact_sales
WHERE order_date IS NOT NULL
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    sales_year,
    sales_month;


-- =========================================================
-- 17. SALES BY YEAR
-- =========================================================

SELECT
    YEAR(order_date) AS sales_year,
    COUNT(DISTINCT order_number) AS orders,
    COUNT(DISTINCT customer_key) AS customers,
    SUM(quantity) AS quantity_sold,
    SUM(sales_amount) AS revenue
FROM gold_fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY sales_year;


-- =========================================================
-- 18. PRODUCT CATEGORY CONTRIBUTION
-- =========================================================

SELECT
    p.category,
    SUM(f.sales_amount) AS category_revenue,
    ROUND(
        SUM(f.sales_amount) * 100 /
        (SELECT SUM(sales_amount) FROM gold_fact_sales),
        2
    ) AS revenue_percentage
FROM gold_fact_sales f
JOIN gold_dim_products p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY revenue_percentage DESC;


-- =========================================================
-- 19. HIGH-VALUE ORDERS
-- =========================================================

SELECT
    order_number,
    SUM(quantity) AS quantity,
    SUM(sales_amount) AS order_revenue,
    CASE
        WHEN SUM(sales_amount) >= 5000 THEN 'High Value Order'
        WHEN SUM(sales_amount) >= 2500 THEN 'Medium Value Order'
        ELSE 'Standard Order'
    END AS order_segment
FROM gold_fact_sales
GROUP BY order_number
ORDER BY order_revenue DESC;


-- =========================================================
-- 20. HIGHEST-REVENUE ORDERS
-- =========================================================

SELECT
    order_number,
    COUNT(DISTINCT product_key) AS products_in_order,
    SUM(quantity) AS quantity,
    SUM(sales_amount) AS revenue
FROM gold_fact_sales
GROUP BY order_number
ORDER BY revenue DESC
LIMIT 10;
