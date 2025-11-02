{{ config(materialized='table', schema='SILVER') }}

select
  mc.PATIENT_ID,
  count(distinct mc.CONSULT_ID) as TOTAL_CONSULTATIONS,
  count(distinct mc.DOCTOR_ID) as UNIQUE_DOCTORS,
  count(distinct mc.SPECIALTY) as SPECIALTIES_INVOLVED,
  min(mc.CONSULT_DATE_TIME) as FIRST_CONSULTATION_DATE,
  max(mc.CONSULT_DATE_TIME) as LAST_CONSULTATION_DATE,
  sum(case when mc.CONSULT_STATUS = 'success' then 1 else 0 end) as SUCCESSFUL_CONSULTS,
  sum(case when mc.CONSULT_STATUS = 'noshow' then 1 else 0 end) as NO_SHOWS,
  sum(case when mc.CONSULT_TYPE = 'walk-in' then 1 else 0 end) as WALK_IN_CONSULTS,
  sum(case when mc.CONSULT_TYPE = 'appointment' then 1 else 0 end) as SCHEDULED_CONSULTS,
  listagg(distinct mc.SPECIALTY, ', ') within group (order by mc.SPECIALTY) as CONSULTATION_SPECIALTIES
from {{ ref('consultations_base') }} mc
group by 1
