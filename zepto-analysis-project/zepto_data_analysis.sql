-- =========================================================
-- Zepto Inventory & Pricing Analysis (SQLite3)
-- Combined beginner-to-advanced script: no window functions or CTEs
-- Topics used: DDL/DML, aggregates, subqueries, views, joins, transactions
-- =========================================================

DROP TABLE IF EXISTS zepto;

CREATE TABLE zepto (
    sku_id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT,
    name TEXT NOT NULL,
    mrp REAL,
    discountPercent REAL,
    availableQuantity INTEGER,
    discountedSellingPrice REAL,
    weightInGms INTEGER,
    outOfStock INTEGER,  -- 0 = FALSE, 1 = TRUE
    quantity INTEGER
);

-- Staging table matches the nine columns in zepto_v2.csv exactly.
DROP TABLE IF EXISTS zepto_staging;
CREATE TABLE zepto_staging (
    category TEXT,
    name TEXT,
    mrp REAL,
    discountPercent REAL,
    availableQuantity INTEGER,
    discountedSellingPrice REAL,
    weightInGms INTEGER,
    outOfStock TEXT,
    quantity INTEGER
);

-- The following SQLite-shell commands work when this whole file is run with:
--   sqlite3 zepto.db < zepto_combined_sqlite_no_window.sql
.mode csv
.import --skip 1 zepto_v2.csv zepto_staging

-- Move the imported rows into the final table and convert TRUE/FALSE to 1/0.
INSERT INTO zepto (
    category, name, mrp, discountPercent, availableQuantity,
    discountedSellingPrice, weightInGms, outOfStock, quantity
)
SELECT category, name, mrp, discountPercent, availableQuantity,
       discountedSellingPrice, weightInGms,
       CASE WHEN UPPER(TRIM(outOfStock)) = 'TRUE' THEN 1 ELSE 0 END,
       quantity
FROM zepto_staging;

DROP TABLE zepto_staging;

-- =========================================================
-- 1. DATA EXPLORATION
-- =========================================================

SELECT COUNT(*) AS total_rows FROM zepto;

SELECT * FROM zepto
LIMIT 10;

SELECT * FROM zepto
WHERE name IS NULL OR category IS NULL OR mrp IS NULL
   OR discountPercent IS NULL OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL OR availableQuantity IS NULL
   OR outOfStock IS NULL OR quantity IS NULL;

SELECT DISTINCT category
FROM zepto
ORDER BY category;

SELECT outOfStock, COUNT(sku_id) AS product_count
FROM zepto
GROUP BY outOfStock;

SELECT name, COUNT(sku_id) AS number_of_skus
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY number_of_skus DESC;

-- =========================================================
-- 2. DATA CLEANING (run after checking the data)
-- =========================================================

SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

-- ACID example: make the cleaning changes as one transaction.
BEGIN TRANSACTION;

DELETE FROM zepto
WHERE mrp = 0;

-- Source prices are stored in paise; convert them to rupees.
UPDATE zepto
SET mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;

COMMIT;

SELECT mrp, discountedSellingPrice FROM zepto
LIMIT 10;

-- =========================================================
-- 3. DATA ANALYSIS
-- =========================================================

-- Q1. Top 10 best-value products by discount percentage
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- Q2. High-MRP products that are out of stock
SELECT DISTINCT name, mrp
FROM zepto
WHERE outOfStock = 1 AND mrp > 300
ORDER BY mrp DESC;

-- Q3. Estimated revenue per category
SELECT category,
       SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue;

-- Q4. Products where MRP > 500 but discount < 10%
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5. Top 5 categories by average discount
SELECT category,
       ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6. Price per gram for products at least 100g
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
       ROUND(discountedSellingPrice * 1.0 / weightInGms, 2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- Q7. Classify products by weight
SELECT DISTINCT name, weightInGms,
       CASE WHEN weightInGms < 1000 THEN 'Low'
            WHEN weightInGms < 5000 THEN 'Medium'
            ELSE 'Bulk'
       END AS weight_category
FROM zepto;

-- Q8. Total inventory weight per category
SELECT category,
       SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;

-- =========================================================
-- 4. ADVANCED ANALYSIS WITHOUT WINDOW FUNCTIONS
-- =========================================================

-- Q9. Rank each product by discount within its category.
-- Equal discounts receive the same rank; later ranks can have gaps.
SELECT z.category, z.name, z.discountPercent,
       1 + (
           SELECT COUNT(*)
           FROM zepto z2
           WHERE z2.category = z.category
             AND z2.discountPercent > z.discountPercent
       ) AS discount_rank
FROM zepto z
ORDER BY z.category, discount_rank, z.name;

-- Q10. Top 3 distinct discount levels in every category.
SELECT z.category, z.name, z.discountPercent
FROM zepto z
WHERE (
    SELECT COUNT(DISTINCT z2.discountPercent)
    FROM zepto z2
    WHERE z2.category = z.category
      AND z2.discountPercent > z.discountPercent
) < 3
ORDER BY z.category, z.discountPercent DESC, z.name;

-- Q11. Second-highest distinct selling price in every category.
SELECT z.category, z.name, z.discountedSellingPrice
FROM zepto z
WHERE 1 = (
    SELECT COUNT(DISTINCT z2.discountedSellingPrice)
    FROM zepto z2
    WHERE z2.category = z.category
      AND z2.discountedSellingPrice > z.discountedSellingPrice
)
ORDER BY z.category, z.name;

-- View used by Q12 and Q13: category-level estimated revenue.
DROP VIEW IF EXISTS category_revenue;
CREATE VIEW category_revenue AS
SELECT category,
       SUM(discountedSellingPrice * availableQuantity) AS revenue
FROM zepto
GROUP BY category;

-- Q12. Each category's percentage contribution to total revenue.
SELECT category, revenue,
       ROUND(revenue * 100.0 / (SELECT SUM(revenue) FROM category_revenue), 2)
           AS pct_of_total_revenue
FROM category_revenue
ORDER BY revenue DESC;

-- Q13. Running revenue total by category, highest revenue first.
-- A self-join replaces the usual running-total window function.
SELECT current.category,
       current.revenue,
       SUM(previous.revenue) AS running_total,
       ROUND(SUM(previous.revenue) * 100.0 /
             (SELECT SUM(revenue) FROM category_revenue), 2) AS cumulative_pct
FROM category_revenue AS current
JOIN category_revenue AS previous
  ON previous.revenue > current.revenue
     OR (previous.revenue = current.revenue AND previous.category <= current.category)
GROUP BY current.category, current.revenue
ORDER BY current.revenue DESC, current.category;

-- Q14. Products priced above their category average.
SELECT z.category, z.name, z.discountedSellingPrice
FROM zepto z
WHERE z.discountedSellingPrice > (
    SELECT AVG(z2.discountedSellingPrice)
    FROM zepto z2
    WHERE z2.category = z.category
)
ORDER BY z.category, z.discountedSellingPrice DESC;

-- Q15. Categories where more than 25% of SKUs are out of stock.
SELECT category,
       COUNT(*) AS total_skus,
       SUM(outOfStock) AS out_of_stock_skus,
       ROUND(SUM(outOfStock) * 100.0 / COUNT(*), 2) AS out_of_stock_pct
FROM zepto
GROUP BY category
HAVING SUM(outOfStock) * 100.0 / COUNT(*) > 25
ORDER BY out_of_stock_pct DESC;

-- Q16. Estimated revenue at risk from out-of-stock products.
SELECT category,
       COUNT(*) AS out_of_stock_products,
       SUM(discountedSellingPrice * availableQuantity) AS estimated_lost_revenue
FROM zepto
WHERE outOfStock = 1
GROUP BY category
ORDER BY estimated_lost_revenue DESC;

-- Q17. Compare smallest and largest packs for repeated product names.
SELECT name,
       MIN(weightInGms) AS smallest_pack_g,
       MAX(weightInGms) AS largest_pack_g,
       ROUND(MAX(discountedSellingPrice * 1.0 / weightInGms)
             - MIN(discountedSellingPrice * 1.0 / weightInGms), 4)
           AS price_per_gram_spread
FROM zepto
WHERE weightInGms > 0
GROUP BY name
HAVING COUNT(*) > 1
   AND MAX(discountedSellingPrice * 1.0 / weightInGms)
       > MIN(discountedSellingPrice * 1.0 / weightInGms)
ORDER BY price_per_gram_spread DESC;
