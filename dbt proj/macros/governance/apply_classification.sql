{% macro apply_classification() %}
  {% if var('enable_governance_hooks', false) %}
    {% set db = target.database %}
    {% do run_query("CREATE SCHEMA IF NOT EXISTS " ~ db ~ ".GOVERNANCE") %}
    {% do run_query("CREATE OR REPLACE TAG " ~ db ~ ".GOVERNANCE.PII") %}
    {% do run_query("CREATE OR REPLACE SNOWFLAKE.DATA_PRIVACY.CLASSIFICATION_PROFILE " ~ db ~ ".GOVERNANCE.BIH_CLASSIFICATION_PROFILE({'minimum_object_age_for_classification_days':0,'maximum_classification_validity_days':30,'auto_tag':true,'classify_views':true})") %}
    {% do run_query("CALL " ~ db ~ ".GOVERNANCE.BIH_CLASSIFICATION_PROFILE!SET_TAG_MAP({'column_tag_map':[{'tag_name':'" ~ db ~ ".GOVERNANCE.PII','tag_value':'pii','semantic_categories':['NAME','PHONE_NUMBER','POSTAL_CODE','DATE_OF_BIRTH','CITY','EMAIL']} ]})") %}
    {% do run_query("ALTER DATABASE " ~ db ~ " SET CLASSIFICATION_PROFILE = '" ~ db ~ ".GOVERNANCE.BIH_CLASSIFICATION_PROFILE'") %}
  {% else %}
    {{ log('enable_governance_hooks is false; skipping apply_classification', info=True) }}
  {% endif %}
{% endmacro %}
