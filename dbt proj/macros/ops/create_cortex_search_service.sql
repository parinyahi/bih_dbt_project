{% macro create_cortex_search_service(service_name='CLINICAL_NOTE', schema_name='BRONZE', warehouse_name=None) %}
  {% set db = target.database %}
  {% set wh = warehouse_name or target.warehouse %}
  {% set sql = "CREATE OR REPLACE CORTEX SEARCH SERVICE " ~ db ~ "." ~ schema_name ~ "." ~ service_name ~ " \n" ~
    "ON CHUNK ATTRIBUTES CATEGORY \n" ~
    "WAREHOUSE = " ~ wh ~ " \n" ~
    "TARGET_LAG = '30 minute' \n" ~
    "AS (SELECT CHUNK, CHUNK_INDEX, RELATIVE_PATH, FILE_URL, CATEGORY FROM " ~ db ~ "." ~ schema_name ~ ".DOCS_CHUNKS_TABLE);" %}
  {% do run_query(sql) %}
{% endmacro %}
