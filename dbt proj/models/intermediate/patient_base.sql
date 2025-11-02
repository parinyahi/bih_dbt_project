{{ config(materialized='table', schema='SILVER') }}

select
  hb.PATIENT_ID,
  hb.NAME,
  hb.AGE,
  hb.GENDER,
  hb.MEDICAL_CONDITION,
  hb.ADMISSION_TYPE,
  hb.DATE_OF_ADMISSION,
  hb.DISCHARGE_DATE,
  hb.BILLING_AMOUNT,
  hb.DOCTOR,
  hb.HOSPITAL,
  hb.INSURANCE_PROVIDER,
  datediff('day', hb.DATE_OF_ADMISSION, hb.DISCHARGE_DATE) as LENGTH_OF_STAY_DAYS
from {{ ref('healthcare_base') }} hb
where hb.MEDICAL_CONDITION in ('Cancer','Diabetes','Asthma','Hypertension')
