USE DataWarehouse;


/* ============================================================
   GOLD LAYER ANALYSIS
   BUSINESS ANALYSIS QUESTIONS
   ============================================================ */


/* ============================================================
   1. What is the total revenue generated?
   ============================================================ */

SELECT
    SUM(sales_amount) AS total_revenue
FROM gold_fact_sales;


/* ============================================================
   2. How many orders have been placed?
   ============================================================ */

SELECT
    COUNT(DISTINCT order_number) AS total_orders
FROM gold_fact_sales;


/* ============================================================
   3. How many customers have made purchases?
   ============================================================ */

SELECT
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold_fact_sales;


/* ============================================================
   4. What is the average order value?
   ============================================================ */

SELECT
    ROUND(
        SUM(sales_amount) / COUNT(DISTINCT order_number),
        2
    ) AS average_order_value
FROM gold_fact_sales;


/* ============================================================
   5. What are the total sales by country?
   ============================================================ */

SELECT
    c.country,
    SUM(f.sales_amount) AS total_sales
FROM gold_fact_sales f
JOIN gold_dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_sales DESC;


/* ============================================================
   6. What are the total sales by product category?
   ============================================================ */

SELECT
    p.category,
    SUM(f.sales_amount) AS total_sales
FROM gold_fact_sales f
JOIN gold_dim_products p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_sales DESC;


/* ============================================================
   7. What are the top 10 products by total sales?
   ============================================================ */

SELECT
    p.product_number,
    p.product_name,
    SUM(f.sales_amount) AS total_sales
FROM gold_fact_sales f
JOIN gold_dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.product_number,
    p.product_name
ORDER BY total_sales DESC
LIMIT 10;


/* ============================================================
   8. What are the top 10 customers by total spending?
   ============================================================ */

SELECT
    c.customer_number,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_spending
FROM gold_fact_sales f
JOIN gold_dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_number,
    c.first_name,
    c.last_name
ORDER BY total_spending DESC
LIMIT 10;


/* ============================================================
   9. Which product lines generate the most sales?
   ============================================================ */

SELECT
    p.product_line,
    SUM(f.sales_amount) AS total_sales
FROM gold_fact_sales f
JOIN gold_dim_products p
    ON f.product_key = p.product_key
GROUP BY p.product_line
ORDER BY total_sales DESC;


/* ============================================================
   10. How many products are there in each category?
   ============================================================ */

SELECT
    category,
    COUNT(*) AS product_count
FROM gold_dim_products
GROUP BY category
ORDER BY product_count DESC;


/* ============================================================
   11. What is the total quantity sold by product category?
   ============================================================ */

SELECT
    p.category,
    SUM(f.quantity) AS total_quantity_sold
FROM gold_fact_sales f
JOIN gold_dim_products p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_quantity_sold DESC;


/* ============================================================
   12. What is the monthly sales trend?
   ============================================================ */

SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    SUM(sales_amount) AS total_sales
FROM gold_fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY sales_month;


/* ============================================================
   13. Which customers have placed more than one order?
   ============================================================ */

SELECT
    c.customer_number,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold_fact_sales f
JOIN gold_dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_number,
    c.first_name,
    c.last_name
HAVING COUNT(DISTINCT f.order_number) > 1
ORDER BY total_orders DESC;


/* ============================================================
   14. What is the average selling price by product line?
   ============================================================ */

SELECT
    p.product_line,
    ROUND(AVG(f.price), 2) AS average_price
FROM gold_fact_sales f
JOIN gold_dim_products p
    ON f.product_key = p.product_key
GROUP BY p.product_line
ORDER BY average_price DESC;


/* ============================================================
   15. Which orders generated the highest revenue?
   ============================================================ */

SELECT
    order_number,
    SUM(sales_amount) AS order_revenue,
    SUM(quantity) AS total_quantity
FROM gold_fact_sales
GROUP BY order_number
ORDER BY order_revenue DESC
LIMIT 10;
