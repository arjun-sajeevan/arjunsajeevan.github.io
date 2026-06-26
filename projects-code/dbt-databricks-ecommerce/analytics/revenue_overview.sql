-- =============================================================================
-- revenue_overview.sql | Databricks SQL Analytics Notebook
-- =============================================================================
-- Run this query in your Databricks SQL editor after completing dbt run.
-- Select "Bar Chart" or "Line Chart" in the visualization panel.
-- =============================================================================

-- QUERY 1: Monthly Revenue Trend
-- Visualization: Line Chart | X-axis: month | Y-axis: total_revenue
-- ---------------------------------------------------------
SELECT
    date_format(month, 'MMM yyyy')  AS month_label,
    total_revenue,
    order_count,
    avg_order_value,
    unique_customers
FROM dev.ecommerce_gold.monthly_revenue
ORDER BY month ASC;


-- QUERY 2: Revenue by Payment Method
-- Visualization: Bar Chart | X-axis: payment_method | Y-axis: total_revenue
-- ---------------------------------------------------------
SELECT
    payment_method,
    COUNT(DISTINCT order_id)        AS total_orders,
    ROUND(SUM(total_amount), 2)     AS total_revenue
FROM dev.ecommerce_gold.fct_orders
WHERE status IN ('DELIVERED', 'SHIPPED')
GROUP BY payment_method
ORDER BY total_revenue DESC;


-- QUERY 3: KPI Summary (Single Row — use as KPI Card)
-- ---------------------------------------------------------
SELECT
    COUNT(DISTINCT order_id)                        AS total_orders,
    COUNT(DISTINCT customer_id)                     AS total_customers,
    ROUND(SUM(total_amount), 2)                     AS total_revenue,
    ROUND(AVG(total_amount), 2)                     AS avg_order_value
FROM dev.ecommerce_gold.fct_orders
WHERE status IN ('DELIVERED', 'SHIPPED');
