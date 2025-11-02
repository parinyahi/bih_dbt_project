{{ config(
  materialized='incremental',
  schema='SILVER',
  unique_key='ID',
  on_schema_change='sync_all_columns'
) }}

with base as (
  select
    ID,
    PATIENT_ID,
    DOCTOR_ID,
    CLINICAL_NOTES,
    CREATED_AT
  from {{ ref('consultations_base') }}
  {% if is_incremental() %}
    where CREATED_AT > (select coalesce(max(CREATED_AT), '1970-01-01'::timestamp) from {{ this }})
  {% endif %}
)
select
  b.ID,
  b.PATIENT_ID,
  b.DOCTOR_ID,
  b.CLINICAL_NOTES,
  b.CREATED_AT,
  case
    when length(b.CLINICAL_NOTES) >= 200 then 'High'
    when length(b.CLINICAL_NOTES) >= 60 then 'Medium'
    else 'Low'
  end as SEVERITY
from base b
