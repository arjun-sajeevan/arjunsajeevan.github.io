-- =============================================================================
-- generate_schema_name.sql | Custom Schema Macro
-- =============================================================================
-- PURPOSE:
--   By default, dbt generates schema names as: {target_schema}_{custom_schema}
--   e.g. ecommerce_silver_ecommerce_bronze — which is not what we want.
--
--   This macro overrides that behavior so dbt uses ONLY the custom schema name
--   exactly as declared in dbt_project.yml, giving us clean schema names:
--     - dev.ecommerce_bronze  (seeds)
--     - dev.ecommerce_silver  (staging models)
--     - dev.ecommerce_gold    (mart models)
--
--   This is the standard override pattern documented in the official dbt docs.
-- =============================================================================

{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
