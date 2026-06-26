-- =============================================================================
-- assert_no_negative_quantity.sql | Custom Singular Test
-- =============================================================================
-- PURPOSE:
--   This is a custom dbt test. Unlike schema tests (which are declared in YAML),
--   singular tests are written as plain SQL. The rule is simple:
--
--   ✅ If this query returns 0 rows  → test PASSES
--   ❌ If this query returns any rows → test FAILS
--
-- WHAT WE'RE TESTING:
--   After stg_orders filters out negative quantities, there should be ZERO
--   orders remaining with quantity <= 0. This test verifies that filtering
--   logic is working correctly end-to-end.
--
-- HOW TO RUN:
--   dbt test --select assert_no_negative_quantity
-- =============================================================================

select
    order_id,
    quantity
from {{ ref('stg_orders') }}
where quantity <= 0
