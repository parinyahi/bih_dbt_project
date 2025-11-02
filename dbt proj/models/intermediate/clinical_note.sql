{{ config(materialized='table', schema='SILVER') }}

with doc_extract as (
  select relative_path,
    AI_EXTRACT(
      file => to_file('{{ var("pdf_stage", "@AZURE_PDF_SI") }}/', relative_path),
      responseFormat => [
        'Patient Name','Patient DOB','Patient MRN','Patient ADMIT Date','Patient Gender','Docter Attending',
        'Patient Vital Signs','What is this document?','What is the Chief Complaint?','Summarize the Medication and History',
        'Phyical examination','Impression or dianosis','Plan and management']
    ) as doc_info
  from directory ({{ var("pdf_stage", "@AZURE_PDF_SI") }})
),
flatten as (
  select
    relative_path as FILE,
    doc_info:response:"What is this document?"::string as DOC_TYPE,
    doc_info:response:"Patient Name"::string as PATIENT_NAME,
    doc_info:response:"Patient MRN"::string as PATIENT_MRN,
    doc_info:response:"Patient Gender"::string as PATIENT_GENDER,
    doc_info:response:"Patient DOB"::date as PATIENT_DOB,
    doc_info:response:"Patient ADMIT Date"::date as ADMIT_DATE,
    doc_info:response:"Patient Vital Signs"::string as VITAL_SIGNS,
    doc_info:response:"Docter Attending"::string as DOCTOR,
    doc_info:response:"Impression or dianosis"::string as DIANOSIS,
    doc_info:response:"What is the Chief Complaint?"::string as CHIEF_COMPLAINT,
    doc_info:response:"Summarize the Medication and History"::varchar(100000) as MEDICAL_HISTORY,
    doc_info:response:"Plan and management"::string as PLAN_MANAGEMENT,
    doc_info:response:"Phyical examination" as PHYSICAL_EXAM
  from doc_extract
)
