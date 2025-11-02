{{ config(materialized='table', schema='SILVER') }}

with src as (
  select
    *,
    AI_COMPLETE(
      model => 'claude-4-sonnet',
      prompt => concat('From the clinical notes {0},extract symptom and categorise the severity into "High","Medium" and "Low" and short treatment', CLINICAL_NOTES),
      model_parameters => { 'temperature': 0, 'max_tokens': 4096 },
      response_format => { 'type':'json', 'schema':{'type':'object','properties':{'result':{'type':'object','properties':{
        'severity': {'type':'string'}, 'symptom': {'type':'string'}, 'treatment': {'type':'string'}
      }}}}}
    ) as severity_n_symptom
  from {{ ref('consultations_base') }}
)
select
  src.*,
  severity_n_symptom:result.severity::string as SEVERITY,
  severity_n_symptom:result.symptom::string as SYMPTOM,
  severity_n_symptom:result.treatment::string as TREATMENT
from src
