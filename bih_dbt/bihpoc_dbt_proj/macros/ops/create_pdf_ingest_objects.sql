{% macro create_pdf_ingest_objects(stage_name='@AZURE_PDF_SI', schema_name='BRONZE') %}
  {% set db = target.database %}
  {% set create_raw_text = "CREATE OR REPLACE TRANSIENT TABLE " ~ db ~ "." ~ schema_name ~ ".RAW_TEXT AS \n" ~
    "SELECT RELATIVE_PATH, SIZE, FILE_URL, BUILD_SCOPED_FILE_URL(" ~ stage_name ~ ", RELATIVE_PATH) AS SCOPED_FILE_URL, \n" ~
    "TO_VARCHAR(SNOWFLAKE.CORTEX.PARSE_DOCUMENT('" ~ stage_name ~ "', RELATIVE_PATH, {'mode':'LAYOUT'}):content) AS EXTRACTED_LAYOUT \n" ~
    "FROM DIRECTORY('" ~ stage_name ~ "');" %}
  {% do run_query(create_raw_text) %}

  {% set create_chunks_table = "CREATE OR REPLACE TABLE " ~ db ~ "." ~ schema_name ~ ".DOCS_CHUNKS_TABLE ( \n" ~
    "  RELATIVE_PATH VARCHAR, SIZE NUMBER, FILE_URL VARCHAR, SCOPED_FILE_URL VARCHAR, \n" ~
    "  CHUNK VARCHAR, CHUNK_INDEX INTEGER, CATEGORY VARCHAR\n" ~
    ");" %}
  {% do run_query(create_chunks_table) %}

  {% set insert_chunks = "INSERT INTO " ~ db ~ "." ~ schema_name ~ ".DOCS_CHUNKS_TABLE (RELATIVE_PATH,SIZE,FILE_URL,SCOPED_FILE_URL,CHUNK,CHUNK_INDEX,CATEGORY) \n" ~
    "SELECT RELATIVE_PATH, SIZE, FILE_URL, SCOPED_FILE_URL, c.VALUE::TEXT AS CHUNK, c.INDEX::INTEGER AS CHUNK_INDEX, \n" ~
    "REGEXP_REPLACE(RELATIVE_PATH, \\\.pdf$, '') AS CATEGORY \n" ~
    "FROM " ~ db ~ "." ~ schema_name ~ ".RAW_TEXT, LATERAL FLATTEN(input => SNOWFLAKE.CORTEX.SPLIT_TEXT_RECURSIVE_CHARACTER(EXTRACTED_LAYOUT,'markdown',1512,256,['\\n\\n','\\n',' ', '']));" %}
  {% do run_query(insert_chunks) %}
{% endmacro %}
