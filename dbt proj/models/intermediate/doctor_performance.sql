{{ config(materialized='table', schema='SILVER') }}

select
  *,
  round(100.0 * SUCCESSFUL_CONSULTS / nullif(TOTAL_CONSULTATIONS, 0), 2) as SUCCESS_RATE_PCT,
  round(100.0 * PATIENT_NO_SHOWS / nullif(TOTAL_CONSULTATIONS, 0), 2) as NO_SHOW_RATE_PCT,
  round(TOTAL_CONSULTATIONS / nullif(ACTIVE_DAYS, 0), 2) as AVG_CONSULTS_PER_DAY,
  round(UNIQUE_PATIENTS / nullif(TOTAL_CONSULTATIONS, 0), 2) as REPEAT_PATIENT_RATIO,
  datediff('day', FIRST_CONSULTATION, LAST_CONSULTATION) as SERVICE_SPAN_DAYS
from {{ ref('doctor_consultations') }}
