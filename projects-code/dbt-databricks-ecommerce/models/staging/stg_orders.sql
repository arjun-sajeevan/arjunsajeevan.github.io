-- =============================================================================
-- stg_orders.sql | Silver Layer
-- =============================================================================
-- PURPOSE:
--   Clean and standardize raw order data from the Bronze layer.
--   This is the first transformation step — we fix quality issues here
--   so that all downstream models (marts) work with clean, reliable data.
--
-- KEY TRANSFORMATIONS:
--   1. Filter rows with null order_id (unparseable records)
--   2. Deduplicate order_ids (keep the first occurrence by order_date)
--   3. Filter negative quantities (invalid records)
--   4. Standardize status to UPPERCASE for consistency
--   5. Convert unit_price_cents → unit_price using the cents_to_dollars macro
--   6. Cast order_date from string to date type
-- =============================================================================

with source as (

    select * from {{ source('ecommerce_bronze', 'raw_orders') }}

),

-- Step 1: Remove rows with null order_id — they are unidentifiable records
filtered as (

    select *
    from source
    where order_id is not null

),

-- Step 2: Deduplicate — in the raw source, order_id O001 appears twice.
-- We keep the row with the earliest order_date (first occurrence wins).
deduplicated as (

    select *
    from (
        select
            *,
            row_number() over (
                partition by order_id
                order by order_date asc
            ) as row_num
        from filtered
    )
    where row_num = 1

),

-- Step 3: Clean and rename columns into our standard naming convention
cleaned as (

    select
        order_id,
        customer_id,
        product_id,

        -- Cast string date to proper date type
        cast(order_date as date)                    as order_date,

        -- Filter out negative quantities in the next CTE.
        -- Keep here so we can reference it in the filter.
        cast(quantity as int)                       as quantity,

        -- Use our reusable macro to convert cents to dollars → round(unit_price_cents / 100.0, 2)
        {{ cents_to_dollars('unit_price_cents') }}  as unit_price,

        -- Standardize status to uppercase (fixes SHIPPED vs shipped inconsistency)
        upper(trim(status))                         as status,

        lower(trim(payment_method))                 as payment_method

    from deduplicated

),

-- Step 4: Remove negative quantity records (invalid orders)
final as (

    select *
    from cleaned
    where quantity > 0

)

select * from final
