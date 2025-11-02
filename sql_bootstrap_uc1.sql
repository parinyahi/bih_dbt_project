-- UC1 Bootstrap: Snowflake-managed Iceberg on Azure (DEV only)

use role ACCOUNTADMIN;

-- 1) Core security & compute
create role if not exists BIH_DATA_ENGINEER;

create warehouse if not exists BIH_DE_WH
  warehouse_size = 'XSMALL'
  warehouse_type = 'STANDARD'
  auto_suspend = 60
  auto_resume = true
  initially_suspended = true
  comment = 'Dev engineering warehouse for BIH PoC';

grant usage on warehouse BIH_DE_WH to role BIH_DATA_ENGINEER;

-- 2) Database + schema
create database if not exists BIHPOC comment = 'BIH PoC database';
grant usage on database BIHPOC to role BIH_DATA_ENGINEER;

create schema if not exists BIHPOC.BRONZE comment = 'Landing layer for UC1 (Iceberg)';
grant usage on schema BIHPOC.BRONZE to role BIH_DATA_ENGINEER;
grant create table, create stage on schema BIHPOC.BRONZE to role BIH_DATA_ENGINEER;

use warehouse BIH_DE_WH;
use database BIHPOC;
use schema BRONZE;

-- 3) External volume (DEV only)
create or replace external volume BIH_IBG_DEV_AZUREEXVOL
  storage_locations = (
    (
      name = 'azure-exvol-southeast-asia_dev'
      storage_provider = 'AZURE'
      storage_base_url = 'azure://dlssnowpocbihdev.blob.core.windows.net/iceberg/'
      azure_tenant_id = '9c21bf6f-39b9-4076-94e0-3f72bcf282a9'
    )
  )
  allow_writes = true
  comment = 'External volume for Snowflake-managed Iceberg tables (DEV)';

-- Retrieve storage principals to grant in Azure, if needed:
desc external volume BIH_IBG_DEV_AZUREEXVOL;

-- Delegate ownership to engineering role
grant ownership on external volume BIH_IBG_DEV_AZUREEXVOL to role BIH_DATA_ENGINEER revoke current grants;

-- 4) UC1 Iceberg tables (DEV only)
-- Healthcare master (example)
create or replace iceberg table HEALTHCARE
  catalog = 'SNOWFLAKE'
  external_volume = 'BIH_IBG_DEV_AZUREEXVOL'
  base_location = 'table/healthcare'
(
  PATIENT_ID string,
  NAME string,
  AGE int,
  GENDER string,
  BLOOD_TYPE string,
  MEDICAL_CONDITION string,
  DATE_OF_ADMISSION date,
  DOCTOR string,
  HOSPITAL string,
  INSURANCE_PROVIDER string,
  BILLING_AMOUNT number(18, 2),
  ROOM_NUMBER int,
  ADMISSION_TYPE string,
  DISCHARGE_DATE date,
  MEDICATION string,
  TEST_RESULTS string
);

-- Medical consultations fact (example)
create or replace iceberg table MEDICAL_CONSULTATIONS
  catalog = 'SNOWFLAKE'
  external_volume = 'BIH_IBG_DEV_AZUREEXVOL'
  base_location = 'table/medical_consultations'
(
  CONSULT_ID string,
  PATIENT_ID string,
  DOCTOR_ID string,
  SPECIALTY_TYPE string,
  SPECIALTY string,
  CONSULT_DATE_TIME timestamp_ntz,
  CONSULT_TYPE string,
  CONSULT_STATUS string,
  DIAGNOSIS string,
  CLINICAL_NOTES string
);

-- 5) Final grants on created objects (optional hardening)
grant select on all tables in schema BIHPOC.BRONZE to role BIH_DATA_ENGINEER;
grant select on future tables in schema BIHPOC.BRONZE to role BIH_DATA_ENGINEER;

-- End UC1 bootstrap
