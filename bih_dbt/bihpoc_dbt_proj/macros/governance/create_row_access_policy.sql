{% macro create_row_access_policy() %}
  {% if var('enable_governance_hooks', false) %}
    {% set governance_db = target.database %}
    {% set governance_schema = var('governance_schema', 'GOVERNANCE') %}
    {% set sql = "CREATE OR REPLACE ROW ACCESS POLICY " ~ governance_db ~ "." ~ governance_schema ~ ".BIH_PATIENT_JOURNEY_POLICY AS (ADMISSION_TYPE_COL STRING) RETURNS BOOLEAN -> CASE WHEN CURRENT_ROLE() = 'BIH_ANALYST_2' THEN ADMISSION_TYPE_COL = 'Emergency' ELSE TRUE END;" %}
    {% do run_query(sql) %}
  {% else %}
    {{ log('enable_governance_hooks is false; skipping create_row_access_policy', info=True) }}
  {% endif %}
{% endmacro %}
