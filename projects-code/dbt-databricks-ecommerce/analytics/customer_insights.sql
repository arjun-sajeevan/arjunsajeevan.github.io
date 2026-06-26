-- =============================================================================
-- customer_insights.sql | Databricks SQL Analytics Notebook
-- =============================================================================
-- Run this query in your Databricks SQL editor after completing dbt run.
-- =============================================================================

-- QUERY 1: Top Customers by Lifetime Value
-- Visualization: Horizontal Bar Chart | X-axis: lifetime_value | Y-axis: full_name
-- ---------------------------------------------------------
SELECT
    full_name,
    country,
    total_orders,
    completed_orders,
    lifetime_value,
    avg_order_value,
    return_rate_pct
FROM dev.ecommerce_gold.dim_customers
WHERE lifetime_value IS NOT NULL
ORDER BY lifetime_value DESC
LIMIT 10;


-- QUERY 2: Orders by Country
-- Visualization: Bar Chart | X-axis: country | Y-axis: total_orders
-- ---------------------------------------------------------
SELECT
    customer_country                            AS country,
    COUNT(DISTINCT order_id)                    AS total_orders,
    COUNT(DISTINCT customer_id)                 AS unique_customers,
    ROUND(SUM(total_amount), 2)                 AS total_revenue
FROM dev.ecommerce_gold.fct_orders
WHERE status IN ('DELIVERED', 'SHIPPED')
GROUP BY customer_country
ORDER BY total_revenue DESC;


-- QUERY 3: Customer Retention Indicator
-- Customers with more than 1 order are "repeat customers"
-- Visualization: Pie Chart | Single / Repeat customers
-- ---------------------------------------------------------
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-Time Customers'
        WHEN total_orders BETWEEN 2 AND 3 THEN 'Returning Customers'
        ELSE 'Loyal Customers (4+ orders)'
    END                                         AS customer_segment,
    COUNT(customer_id)                          AS customer_count
FROM dev.ecommerce_gold.dim_customers
WHERE total_orders IS NOT NULL
GROUP BY
    CASE
        WHEN total_orders = 1 THEN 'One-Time Customers'
        WHEN total_orders BETWEEN 2 AND 3 THEN 'Returning Customers'
        ELSE 'Loyal Customers (4+ orders)'
    END;
