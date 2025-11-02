{{ config(materialized='table', schema='SILVER') }}

select
  mc.DOCTOR_ID,
  mc.SPECIALTY_TYPE,
  mc.SPECIALTY,
  count(distinct mc.CONSULT_ID) as TOTAL_CONSULTATIONS,
  count(distinct mc.PATIENT_ID) as UNIQUE_PATIENTS,
  count(distinct mc.CONSULT_DATE_TIME::date) as ACTIVE_DAYS,
  count(distinct hb.MEDICAL_CONDITION) as UNIQUE_CONDITIONS_TREATED,
  sum(case when mc.CONSULT_TYPE = 'walk-in' then 1 else 0 end) as WALK_IN_CONSULTS,
  sum(case when mc.CONSULT_TYPE = 'appointment' then 1 else 0 end) as SCHEDULED_CONSULTS,
  sum(case when mc.CONSULT_STATUS = 'success' then 1 else 0 end) as SUCCESSFUL_CONSULTS,
  sum(case when mc.CONSULT_STATUS = 'noshow' then 1 else 0 end) as PATIENT_NO_SHOWS,
  sum(case when mc.CONSULT_STATUS = 'booked' then 1 else 0 end) as PENDING_CONSULTS,
  min(mc.CONSULT_DATE_TIME) as FIRST_CONSULTATION,
  max(mc.CONSULT_DATE_TIME) as LAST_CONSULTATION
from {{ ref('consultations_base') }} mc
left join {{ ref('healthcare_base') }} hb on mc.PATIENT_ID = hb.PATIENT_ID
group by 1,2,3
