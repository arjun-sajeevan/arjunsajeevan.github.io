-- =============================================================================
-- dim_products.sql | Gold Layer — Product Dimension
-- =============================================================================
-- PURPOSE:
--   Product dimension table aggregated from the fct_orders fact table.
--   Answers questions like: "Which products generate the most revenue?",
--   "What is the best-selling product in each category?"
--
-- GRAIN: One row per product_id
-- =============================================================================

with fact as (

    select * from {{ ref('fct_orders') }}

),

products as (

    select * from {{ ref('stg_products') }}

),

-- Aggregate sales metrics per product from the fact table
sales_metrics as (

    select
        product_id,
        count(distinct order_id)                            as total_orders,
        sum(quantity)                                       as total_units_sold,
        round(sum(total_amount), 2)                         as total_revenue,
        round(avg(unit_price), 2)                           as avg_selling_price,

        -- Count only delivered orders — returned items don't count as sold
        sum(case when status = 'DELIVERED' then quantity else 0 end)
                                                            as confirmed_units_sold

    from fact
    group by product_id

),

final as (

    select
        p.product_id,
        p.product_name,
        p.category,
        p.brand,

        -- Sales metrics
        m.total_orders,
        m.total_units_sold,
        m.confirmed_units_sold,
        m.total_revenue,
        m.avg_selling_price

    from products p
    left join sales_metrics m on p.product_id = m.product_id

)

select * from final
