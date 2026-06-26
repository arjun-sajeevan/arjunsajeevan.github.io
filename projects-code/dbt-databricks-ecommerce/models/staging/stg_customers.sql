-- =============================================================================
-- stg_customers.sql | Silver Layer
-- =============================================================================
-- PURPOSE:
--   Clean and deduplicate raw customer data from the Bronze layer.
--
-- KEY TRANSFORMATIONS:
--   1. Deduplicate customer_id (keep earliest signup_date — real signup)
--   2. Standardize country casing with initcap() (india → India)
--   3. Trim whitespace from first_name (raw source has "  Lena  ")
--   4. Derive full_name as a single column for convenience
--   5. Cast signup_date from string to date type
-- =============================================================================

with source as (

    select * from {{ source('ecommerce_bronze', 'raw_customers') }}

),

-- Deduplicate: customer C003 appears twice in the raw source.
-- We keep the row with the earliest signup_date (their real first record).
deduplicated as (

    select *
    from (
        select
            *,
            row_number() over (
                partition by customer_id
                order by signup_date asc
            ) as row_num
        from source
    )
    where row_num = 1

),

final as (

    select
        customer_id,

        -- trim() removes accidental leading/trailing whitespace
        trim(first_name)                        as first_name,
        trim(last_name)                         as last_name,

        -- Combine into a clean full name
        trim(first_name) || ' ' || trim(last_name) as full_name,

        lower(trim(email))                      as email,

        cast(signup_date as date)               as signup_date,

        -- initcap() standardizes casing: "india" → "India", "INDIA" → "India"
        initcap(trim(country))                  as country

    from deduplicated

)

select * from final
