{{ config(materialized='table', schema='SILVER') }}

select
  dp.*,
  sm.NUM_DOCTORS as DOCTORS_IN_SPECIALTY,
  sm.SPECIALTY_TOTAL_CONSULTS,
  sm.SPECIALTY_UNIQUE_PATIENTS,
  sm.AVG_SPECIALTY_SUCCESS_RATE_PCT,
  sm.AVG_SPECIALTY_NO_SHOW_RATE_PCT,
  case when dp.SUCCESS_RATE_PCT >= sm.AVG_SPECIALTY_SUCCESS_RATE_PCT + 5 then 'TOP_PERFORMER'
       when dp.SUCCESS_RATE_PCT >= sm.AVG_SPECIALTY_SUCCESS_RATE_PCT then 'MEETS_STANDARD'
       else 'NEEDS_IMPROVEMENT' end as PERFORMANCE_TIER,
  case when dp.AVG_CONSULTS_PER_DAY >= 5 then 'HIGH_VOLUME'
       when dp.AVG_CONSULTS_PER_DAY >= 3 then 'STANDARD_VOLUME'
       else 'LOW_VOLUME' end as WORKLOAD_LEVEL
from {{ ref('doctor_performance') }} dp
left join {{ ref('specialty_metrics') }} sm on dp.SPECIALTY = sm.SPECIALTY
