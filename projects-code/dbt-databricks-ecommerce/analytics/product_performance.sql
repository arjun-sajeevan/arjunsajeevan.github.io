-- =============================================================================
-- product_performance.sql | Databricks SQL Analytics Notebook
-- =============================================================================
-- Run this query in your Databricks SQL editor after completing dbt run.
-- =============================================================================

-- QUERY 1: Top Products by Revenue
-- Visualization: Horizontal Bar Chart | X-axis: total_revenue | Y-axis: product_name
-- ---------------------------------------------------------
SELECT
    product_name,
    category,
    brand,
    total_units_sold,
    confirmed_units_sold,
    total_revenue
FROM dev.ecommerce_gold.dim_products
ORDER BY total_revenue DESC
LIMIT 10;


-- QUERY 2: Revenue Share by Category
-- Visualization: Pie Chart | Slice: category | Value: category_revenue
-- ---------------------------------------------------------
SELECT
    product_category                            AS category,
    ROUND(SUM(total_amount), 2)                 AS category_revenue,
    COUNT(DISTINCT order_id)                    AS order_count,
    SUM(quantity)                               AS units_sold
FROM dev.ecommerce_gold.fct_orders
WHERE status IN ('DELIVERED', 'SHIPPED')
GROUP BY product_category
ORDER BY category_revenue DESC;


-- QUERY 3: Top Category Per Month
-- Visualization: Bar Chart (stacked or grouped) | X-axis: month | Color: top_category
-- ---------------------------------------------------------
SELECT
    date_format(month, 'MMM yyyy')  AS month_label,
    top_category,
    top_category_revenue
FROM dev.ecommerce_gold.monthly_revenue
ORDER BY month ASC;
