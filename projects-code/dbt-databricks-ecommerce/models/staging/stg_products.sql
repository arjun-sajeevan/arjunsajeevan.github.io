-- =============================================================================
-- stg_products.sql | Silver Layer
-- =============================================================================
-- PURPOSE:
--   Clean and standardize raw product data from the Bronze layer.
--
-- KEY TRANSFORMATIONS:
--   1. Standardize category casing with initcap()
--      (electronics → Electronics, ELECTRONICS → Electronics)
--   2. Trim whitespace from product_name
--   3. Trim whitespace from brand
-- =============================================================================

with source as (

    select * from {{ source('ecommerce_bronze', 'raw_products') }}

),

final as (

    select
        product_id,

        -- trim() removes accidental whitespace from product names
        trim(product_name)          as product_name,

        -- initcap() unifies all category casing variants to Title Case
        initcap(trim(category))     as category,

        trim(brand)                 as brand

    from source

)

select * from final
