{{ config(materialized='view', schema='BRONZE') }}

select
  ID,
  PATIENT_ID,
  DOCTOR_ID,
  CLINICAL_NOTES,
  CREATED_AT
from {{ source('bronze','MEDICAL_CONSULTATIONS') }}
