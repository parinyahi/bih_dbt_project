# BIHPOC dbt Project

## Prerequisites
- Python 3.10+
- Install dbt Snowflake adapter: `pip install dbt-snowflake==1.8.5`

## Configure profiles (Snowflake)
Create `~/.dbt/profiles.yml` or export `DBT_PROFILES_DIR` to a path containing your `profiles.yml`. See `profiles.example.yml` for a template.

## Install and validate
```bash
cd bihpoc_dbt_proj
dbt deps
dbt debug
dbt parse
```

## Build models
```bash
dbt build --select sources:+staging
dbt build --select intermediate+
dbt build --select marts.uc2.vw_doctor_perf_scorecard
```

## Governance operations
```bash
# Enable hooks in dbt_project.yml if desired
# vars:
#   enable_governance_hooks: true

dbt run-operation create_masking_policies
dbt run-operation create_row_access_policy
```

## Cortex search (optional)
If you have a stage like `@AZURE_PDF_SI`:
```bash
dbt run-operation create_pdf_ingest_objects --args '{"stage_name": "@AZURE_PDF_SI", "schema_name": "BRONZE"}'
dbt run-operation create_cortex_search_service --args '{"service_name": "CLINICAL_NOTE", "schema_name": "BRONZE"}'
```

## Git
```bash
git init -b main
git add .
git commit -m "Initial dbt project"
git remote add origin https://github.com/parinyahi/bih_dbt.git
# git push -u origin main  # requires GitHub credentials/token
```
