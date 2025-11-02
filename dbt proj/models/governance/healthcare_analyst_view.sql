{% set hooks = [] %}
{% if var('enable_governance_hooks', false) %}
  {% do hooks.append("ALTER VIEW {{ this }} ADD ROW ACCESS POLICY " ~ target.database ~ "." ~ var('governance_schema','GOVERNANCE') ~ ".BIH_PATIENT_JOURNEY_POLICY ON (ADMISSION_TYPE)") %}
{% endif %}

{{ config(materialized='view', schema='SILVER', post_hook=hooks) }}

select 
    PATIENT_ID,
    NAME,
    AGE,
    GENDER,
    BLOOD_TYPE,
    MEDICAL_CONDITION,
    DATE_OF_ADMISSION,
    DOCTOR,
    HOSPITAL,
    INSURANCE_PROVIDER,
    BILLING_AMOUNT,
    ROOM_NUMBER,
    ADMISSION_TYPE,
    DISCHARGE_DATE,
    MEDICATION,
    TEST_RESULTS
from {{ ref('healthcare_base') }}
