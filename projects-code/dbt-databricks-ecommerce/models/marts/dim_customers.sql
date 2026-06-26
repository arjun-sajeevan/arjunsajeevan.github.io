-- =============================================================================
-- dim_customers.sql | Gold Layer — Customer Dimension
-- =============================================================================
-- PURPOSE:
--   Customer dimension table aggregated from the fct_orders fact table.
--   Answers questions like: "Who are our most valuable customers?",
--   "When did each customer place their first and last order?"
--
-- GRAIN: One row per customer_id
-- =============================================================================

with fact as (

    select * from {{ ref('fct_orders') }}

),

customers as (

    select * from {{ ref('stg_customers') }}

),

-- Aggregate order metrics per customer from the fact table
order_metrics as (

    select
        customer_id,
        min(order_date)                                     as first_order_date,
        max(order_date)                                     as last_order_date,
        count(distinct order_id)                            as total_orders,
        sum(total_amount)                                   as lifetime_value,
        round(avg(total_amount), 2)                         as avg_order_value,

        -- Count only delivered orders as "completed"
        count(case when status = 'DELIVERED' then 1 end)    as completed_orders,

        -- Return rate — useful for product quality monitoring
        round(
            count(case when status = 'RETURNED' then 1 end) * 100.0
            / count(order_id),
            1
        )                                                   as return_rate_pct

    from fact
    group by customer_id

),

final as (

    select
        c.customer_id,
        c.full_name,
        c.email,
        c.country,
        c.signup_date,

        -- Order metrics
        m.first_order_date,
        m.last_order_date,
        m.total_orders,
        m.completed_orders,
        m.lifetime_value,
        m.avg_order_value,
        m.return_rate_pct

    from customers c
    left join order_metrics m on c.customer_id = m.customer_id

)

select * from final
