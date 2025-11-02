{{ config(materialized='view', schema='GOLD') }}

select
  DOCTOR_ID,
  count(*) as total_consultations,
  sum(case when SEVERITY = 'High' then 1 else 0 end) as high_severity_cnt,
  sum(case when SEVERITY = 'Medium' then 1 else 0 end) as medium_severity_cnt,
  sum(case when SEVERITY = 'Low' then 1 else 0 end) as low_severity_cnt,
  min(CREATED_AT) as first_seen,
  max(CREATED_AT) as last_seen
from {{ ref('consultations_curated') }}
group by 1
