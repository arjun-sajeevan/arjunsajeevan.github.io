-- =============================================================================
-- monthly_revenue.sql | Gold Layer — Executive Summary Table
-- =============================================================================
-- PURPOSE:
--   Monthly aggregated revenue summary. This is the "executive dashboard" table —
--   the final output that business stakeholders query directly in Databricks SQL.
--
--   It answers: "How is the business performing month-over-month?"
--
-- GRAIN: One row per calendar month
-- =============================================================================

with fact as (

    -- Only count delivered and shipped orders as revenue
    -- Cancelled and returned orders are excluded from revenue reporting
    select *
    from {{ ref('fct_orders') }}
    where status in ('DELIVERED', 'SHIPPED')

),

monthly_agg as (

    select
        -- Truncate order_date to the first day of the month for grouping
        date_trunc('month', order_date)             as month,

        count(distinct order_id)                    as order_count,
        count(distinct customer_id)                 as unique_customers,
        sum(quantity)                               as total_units_sold,
        round(sum(total_amount), 2)                 as total_revenue,
        round(avg(total_amount), 2)                 as avg_order_value,
        round(sum(total_amount) / count(distinct customer_id), 2)
                                                    as revenue_per_customer

    from fact
    group by date_trunc('month', order_date)

),

-- Find the top revenue category for each month
top_category_per_month as (

    select
        date_trunc('month', order_date)             as month,
        product_category,
        round(sum(total_amount), 2)                 as category_revenue,
        row_number() over (
            partition by date_trunc('month', order_date)
            order by sum(total_amount) desc
        )                                           as rank

    from fact
    group by date_trunc('month', order_date), product_category

),

top_category as (

    select month, product_category as top_category, category_revenue as top_category_revenue
    from top_category_per_month
    where rank = 1

),

final as (

    select
        m.month,
        m.order_count,
        m.unique_customers,
        m.total_units_sold,
        m.total_revenue,
        m.avg_order_value,
        m.revenue_per_customer,
        t.top_category,
        t.top_category_revenue

    from monthly_agg m
    left join top_category t on m.month = t.month
    order by m.month asc

)

select * from final
