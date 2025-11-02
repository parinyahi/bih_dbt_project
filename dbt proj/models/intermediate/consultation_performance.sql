{{ config(materialized='table', schema='SILVER') }}

select
  cm.*,
  round(100.0 * SUCCESSFUL_CONSULTS / nullif(TOTAL_CONSULTATIONS, 0), 2) as CONSULTATION_SUCCESS_RATE_PCT,
  round(100.0 * NO_SHOWS / nullif(TOTAL_CONSULTATIONS, 0), 2) as NO_SHOW_RATE_PCT,
  datediff('day', FIRST_CONSULTATION_DATE, LAST_CONSULTATION_DATE) as CONSULTATION_SPAN_DAYS
from {{ ref('consultation_metrics') }} cm
