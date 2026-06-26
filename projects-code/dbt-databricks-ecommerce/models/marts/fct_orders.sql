-- =============================================================================
-- fct_orders.sql | Gold Layer — Incremental Fact Table
-- =============================================================================
-- PURPOSE:
--   The central fact table of the warehouse. Joins all three staging models
--   to produce a single, enriched row per order — ready for analysis.
--
-- MATERIALIZATION: INCREMENTAL
--   Why incremental? In production, an orders table grows every day.
--   If we rebuilt this table from scratch on every dbt run, we'd reprocess
--   months or years of historical data — slow and expensive.
--
--   With is_incremental(), dbt adds a WHERE clause that only processes
--   orders newer than the latest order_date already in the table.
--   First run: full table build. Every run after: only new data. ⚡
--
-- GRAIN: One row per order_id
-- =============================================================================

{{
    config(
        materialized='incremental',
        unique_key='order_id'
    )
}}

with orders as (

    select * from {{ ref('stg_orders') }}

),

customers as (

    select * from {{ ref('stg_customers') }}

),

products as (

    select * from {{ ref('stg_products') }}

),

joined as (

    select
        -- Order identifiers
        o.order_id,
        o.customer_id,
        o.product_id,
        o.order_date,

        -- Order details
        o.quantity,
        o.unit_price,
        o.quantity * o.unit_price      as total_amount,
        o.status,
        o.payment_method,

        -- Customer attributes (denormalized for query convenience)
        c.full_name                    as customer_name,
        c.country                      as customer_country,

        -- Product attributes (denormalized for query convenience)
        p.product_name,
        p.category                     as product_category,
        p.brand

    from orders o
    left join customers c on o.customer_id = c.customer_id
    left join products  p on o.product_id  = p.product_id

)

-- ⚡ INCREMENTAL LOGIC
-- On the very first run, this block is skipped (full build).
-- On every subsequent run, dbt adds this WHERE clause automatically
-- to filter only NEW orders since the last run.
{% if is_incremental() %}

    select * from joined
    where order_date > (select max(order_date) from {{ this }})

{% else %}

    select * from joined

{% endif %}
