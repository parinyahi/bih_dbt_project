{% macro create_masking_policies() %}
  {% if var('enable_governance_hooks', false) %}
    {% set governance_db = target.database %}
    {% set governance_schema = var('governance_schema', 'GOVERNANCE') %}
    {% set statements = [] %}

    {% do statements.append("CREATE OR REPLACE MASKING POLICY " ~ governance_db ~ "." ~ governance_schema ~ ".NAME_MASKING_POLICY AS (val STRING) RETURNS STRING -> CASE WHEN CURRENT_ROLE() IN ('BIH_ANALYST','BIH_ANALYST_2') THEN '***MASKED***' ELSE val END;") %}
    {% do statements.append("CREATE OR REPLACE MASKING POLICY " ~ governance_db ~ "." ~ governance_schema ~ ".MASK_PATIENT_ID_POLICY AS (val STRING) RETURNS STRING -> CASE WHEN CURRENT_ROLE() IN ('BIH_ANALYST','BIH_ANALYST_2') THEN SHA2(val, 256) ELSE val END;") %}
    {% do statements.append("CREATE OR REPLACE MASKING POLICY " ~ governance_db ~ "." ~ governance_schema ~ ".MASK_DOCTOR_ID_POLICY AS (val STRING) RETURNS STRING -> CASE WHEN CURRENT_ROLE() IN ('BIH_ANALYST','BIH_ANALYST_2') THEN SHA2(val, 256) ELSE val END;") %}

    {% for sql in statements %}
      {% do run_query(sql) %}
    {% endfor %}
  {% else %}
    {{ log('enable_governance_hooks is false; skipping create_masking_policies', info=True) }}
  {% endif %}
{% endmacro %}
