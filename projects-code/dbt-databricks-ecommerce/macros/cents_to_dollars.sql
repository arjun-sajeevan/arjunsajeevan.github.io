{% macro cents_to_dollars(column_name) %}
    round({{ column_name }} / 100.0, 2)
{% endmacro %}

{# =============================================================================
   cents_to_dollars | Reusable Jinja Macro
   =============================================================================

   PURPOSE:
     Convert an integer price column stored in cents to a decimal dollar value.
     Writing this as a macro means we define the logic ONCE and reference it
     everywhere. If the formula ever changes (e.g. different rounding rules),
     we fix it in one place — not across 10 different SQL files.

   USAGE:
     {{ cents_to_dollars('unit_price_cents') }}

   EXPANDS TO:
     round(unit_price_cents / 100.0, 2)

   EXAMPLE:
     Input:  unit_price_cents = 4999
     Output: unit_price        = 49.99

   WHY 100.0 (not 100)?
     In SQL, dividing an integer by an integer performs INTEGER division.
     4999 / 100 = 49  (wrong — we lose the cents!)
     4999 / 100.0 = 49.99  (correct — forces float division)

   ============================================================================= #}
