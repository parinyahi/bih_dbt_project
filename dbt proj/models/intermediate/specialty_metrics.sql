{{ config(materialized='table', schema='SILVER') }}

select
  SPECIALTY,
  count(distinct DOCTOR_ID) as NUM_DOCTORS,
  sum(TOTAL_CONSULTATIONS) as SPECIALTY_TOTAL_CONSULTS,
  sum(UNIQUE_PATIENTS) as SPECIALTY_UNIQUE_PATIENTS,
  round(avg(SUCCESS_RATE_PCT), 2) as AVG_SPECIALTY_SUCCESS_RATE_PCT,
  round(avg(NO_SHOW_RATE_PCT), 2) as AVG_SPECIALTY_NO_SHOW_RATE_PCT,
  round(avg(AVG_CONSULTS_PER_DAY), 2) as AVG_CONSULTS_PER_DAY_SPECIALTY
from {{ ref('doctor_performance') }}
group by 1
