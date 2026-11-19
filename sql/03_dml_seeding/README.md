# DML Seeding Pipeline — Mobile Catalog

This directory contains database seeding scripts for the normalized 3NF MySQL relational database `mobile_catalog`.

## Structure
- `01_dimensions_seeding.sql`: Truncates tables and populates lookup dimension tables (`brand`, `os`, `connectivity`, `processor`, `memory`, `camera`).
- `02_hardware_seeding.sql`: Seeds hardware specification dimension tables (`battery`, `screen`).
- `03_phone_catalog_seeding.sql`: Populates fact tables (`phone`) and aggregate market analytics (`price_analysis`).

## Full Automated Reseeding (980 Models)
To generate or re-run the complete monolithic `data_seeding.sql` covering all 980 models and 10 tables:

```bash
python etl/gen_seeding.py
```

This reads from `data/processed/*.csv`, escapes SQL strings, handles NULL values, ensures idempotency via reverse-dependency `TRUNCATE TABLE` statements, and writes the complete production seeding script.
