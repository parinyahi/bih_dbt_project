{% macro create_masking_policies() %}
  {% if var('enable_governance_hooks', false) %}
    {% set governance_db = target.database %}
    {% set governance_schema = var('governance_schema', 'GOVERNANCE') %}
    {% do run_query("CREATE SCHEMA IF NOT EXISTS " ~ governance_db ~ "." ~ governance_schema) %}
    {% do run_query("CREATE OR REPLACE MASKING POLICY " ~ governance_db ~ "." ~ governance_schema ~ ".NAME_MASKING_POLICY AS (val STRING) RETURNS STRING -> CASE WHEN CURRENT_ROLE() LIKE 'ANALYST%' THEN '***MASKED***' ELSE val END;") %}
  {% else %}
    {{ log('enable_governance_hooks is false; skipping create_masking_policies', info=True) }}
  {% endif %}
{% endmacro %}
