import pandas as pd
import os

RAW_CSV = r"g:\My Drive\MBA\Placement\Finals\CV\CV_Preparation\3_Academic_Projects\Project Files\SQL\data\raw\smartphones_cleaned_v6.csv"
OUT_SQL = r"g:\My Drive\MBA\Placement\Finals\CV\CV_Preparation\3_Academic_Projects\Project Files\SQL\sql\02_data_cleaning\data_cleaning.sql"

df = pd.read_csv(RAW_CSV)

def val(v):
    if pd.isna(v) or v is None or str(v).strip().lower() in ['nan', 'null', 'none']:
        return "NULL"
    s = str(v).strip().replace("'", "''")
    return f"'{s}'"

cols = [
    "brand_name", "model", "price", "rating", "has_5g", "has_nfc", "has_ir_blaster",
    "processor_brand", "num_cores", "processor_speed", "battery_capacity",
    "fast_charging_available", "fast_charging", "ram_capacity", "internal_memory",
    "screen_size", "refresh_rate", "num_rear_cameras", "num_front_cameras", "os",
    "primary_camera_rear", "primary_camera_front", "extended_memory_available",
    "extended_upto", "resolution_width", "resolution_height"
]

header = """-- ============================================================
-- FILE: 02_data_cleaning/data_cleaning.sql
-- PROJECT: SQL & NoSQL Mobile Catalog Analysis — NMIMS Mumbai
-- DESC: Production data quality audit, cleaning, transformation
--       and validation on the raw smartphone staging table.
--       Includes: Self-seeding raw data (980 rows), NULL audit,
--       COALESCE fills, CASE WHEN tiers, Dedup, and Outlier flags.
-- ============================================================

USE mobile_catalog;

-- Disable Safe Update Mode so UPDATE and DELETE statements execute smoothly
SET SQL_SAFE_UPDATES = 0;

-- ────────────────────────────────────────────────────────────
-- STEP 0: Create and Populate staging_phones Table
-- ────────────────────────────────────────────────────────────

DROP TABLE IF EXISTS staging_phones;

CREATE TABLE staging_phones (
    id                        INT AUTO_INCREMENT PRIMARY KEY,
    brand_name                VARCHAR(60),
    model                     VARCHAR(120),
    price                     VARCHAR(20),
    rating                    VARCHAR(10),
    has_5g                    VARCHAR(10),
    has_nfc                   VARCHAR(10),
    has_ir_blaster            VARCHAR(10),
    processor_brand           VARCHAR(60),
    num_cores                 VARCHAR(10),
    processor_speed           VARCHAR(10),
    battery_capacity          VARCHAR(10),
    fast_charging_available   VARCHAR(10),
    fast_charging             VARCHAR(10),
    ram_capacity              VARCHAR(10),
    internal_memory           VARCHAR(10),
    screen_size               VARCHAR(10),
    refresh_rate              VARCHAR(10),
    num_rear_cameras          VARCHAR(10),
    num_front_cameras         VARCHAR(10),
    os                        VARCHAR(40),
    primary_camera_rear       VARCHAR(10),
    primary_camera_front      VARCHAR(10),
    extended_memory_available VARCHAR(10),
    extended_upto             VARCHAR(10),
    resolution_width          VARCHAR(10),
    resolution_height         VARCHAR(10)
);

-- Seeding staging_phones with the 980 raw CSV records
INSERT INTO staging_phones (
""" + ", ".join(cols) + "\n) VALUES\n"

row_strings = []
for _, r in df.iterrows():
    vals = [val(r[c]) for c in cols]
    row_strings.append("  (" + ", ".join(vals) + ")")

insert_stmt = ",\n".join(row_strings) + ";\n\n"

queries_section = """-- ────────────────────────────────────────────────────────────
-- STEP 1: NULL AUDIT — count NULLs and missing values per column
-- ────────────────────────────────────────────────────────────
-- Q-C1: Comprehensive NULL audit across key hardware and pricing metrics
SELECT
    'rating'               AS column_name, COUNT(*) AS missing_count FROM staging_phones WHERE rating IS NULL OR rating = ''
UNION ALL
SELECT 'fast_charging',        COUNT(*) FROM staging_phones WHERE fast_charging IS NULL OR fast_charging = ''
UNION ALL
SELECT 'extended_upto',        COUNT(*) FROM staging_phones WHERE extended_upto IS NULL OR extended_upto = ''
UNION ALL
SELECT 'processor_brand',      COUNT(*) FROM staging_phones WHERE processor_brand IS NULL OR processor_brand = ''
UNION ALL
SELECT 'processor_speed',      COUNT(*) FROM staging_phones WHERE processor_speed IS NULL OR processor_speed = ''
UNION ALL
SELECT 'battery_capacity',     COUNT(*) FROM staging_phones WHERE battery_capacity IS NULL OR battery_capacity = ''
UNION ALL
SELECT 'os',                   COUNT(*) FROM staging_phones WHERE os IS NULL OR os = ''
UNION ALL
SELECT 'primary_camera_front', COUNT(*) FROM staging_phones WHERE primary_camera_front IS NULL OR primary_camera_front = '';


-- ────────────────────────────────────────────────────────────
-- STEP 2: COALESCE — impute NULLs with business defaults
-- ────────────────────────────────────────────────────────────
-- Q-C2: Impute missing fast_charging as '0W', missing rating as 'Unrated',
--       and missing extended_upto as '0 GB'
SELECT
    brand_name,
    model,
    COALESCE(NULLIF(fast_charging, ''), '0') AS fast_charging_clean,
    COALESCE(NULLIF(rating, ''), 'Unrated')  AS rating_clean,
    COALESCE(NULLIF(extended_upto, ''), '0') AS extended_upto_clean
FROM staging_phones
WHERE fast_charging IS NULL OR fast_charging = ''
ORDER BY brand_name, model
LIMIT 20;

-- Q-C3: Impute missing ratings using the average rating of that specific brand
-- (Using Window Function: 100% compatible with MySQL 8.0 ONLY_FULL_GROUP_BY)
SELECT
    brand_name,
    model,
    rating AS raw_rating,
    COALESCE(
        NULLIF(rating, ''),
        CAST(ROUND(AVG(CAST(NULLIF(rating, '') AS DECIMAL(3,1))) OVER (PARTITION BY brand_name), 1) AS CHAR)
    ) AS rating_imputed
FROM staging_phones
ORDER BY brand_name, model
LIMIT 30;


-- ────────────────────────────────────────────────────────────
-- STEP 3: CASE WHEN — Market Segmentation & Price Tiering
-- ────────────────────────────────────────────────────────────
-- Q-C4: Segment every model into strategic price tiers
SELECT
    brand_name,
    model,
    CAST(NULLIF(price, '') AS DECIMAL(10,2)) AS price_inr,
    CASE
        WHEN CAST(NULLIF(price, '') AS DECIMAL(10,2)) < 10000                 THEN 'Budget (< 10k)'
        WHEN CAST(NULLIF(price, '') AS DECIMAL(10,2)) BETWEEN 10000 AND 29999 THEN 'Mid-Range (10k - 30k)'
        WHEN CAST(NULLIF(price, '') AS DECIMAL(10,2)) BETWEEN 30000 AND 59999 THEN 'Flagship (30k - 60k)'
        WHEN CAST(NULLIF(price, '') AS DECIMAL(10,2)) >= 60000                THEN 'Ultra-Premium (60k+)'
        ELSE 'Unpriced'
    END AS price_tier
FROM staging_phones
WHERE price IS NOT NULL AND price <> ''
ORDER BY price_inr ASC
LIMIT 30;

-- Q-C5: Aggregate distribution of smartphone catalog across price tiers
SELECT
    CASE
        WHEN CAST(NULLIF(price, '') AS DECIMAL(10,2)) < 10000                 THEN 'Budget (< 10k)'
        WHEN CAST(NULLIF(price, '') AS DECIMAL(10,2)) BETWEEN 10000 AND 29999 THEN 'Mid-Range (10k - 30k)'
        WHEN CAST(NULLIF(price, '') AS DECIMAL(10,2)) BETWEEN 30000 AND 59999 THEN 'Flagship (30k - 60k)'
        WHEN CAST(NULLIF(price, '') AS DECIMAL(10,2)) >= 60000                THEN 'Ultra-Premium (60k+)'
        ELSE 'Unpriced'
    END AS price_tier,
    COUNT(*) AS total_models,
    ROUND(AVG(CAST(NULLIF(price, '') AS DECIMAL(10,2))), 2) AS tier_avg_price
FROM staging_phones
WHERE price IS NOT NULL AND price <> ''
GROUP BY price_tier
ORDER BY total_models DESC;


-- ────────────────────────────────────────────────────────────
-- STEP 4: DEDUPLICATION
-- ────────────────────────────────────────────────────────────
-- Q-C6: Check for any duplicate brand + model entries
SELECT
    brand_name,
    model,
    COUNT(*) AS duplicate_count
FROM staging_phones
GROUP BY brand_name, model
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Q-C7: Deduplication query — retain the first entry and prune subsequent duplicates
DELETE s1
FROM staging_phones s1
INNER JOIN staging_phones s2
    ON  s1.brand_name = s2.brand_name
    AND s1.model      = s2.model
    AND s1.id         > s2.id;


-- ────────────────────────────────────────────────────────────
-- STEP 5: OUTLIER DETECTION (Z-Score Modeling)
-- ────────────────────────────────────────────────────────────
-- Q-C8: Flag pricing anomalies where phone price > 3 standard deviations from market mean
WITH price_statistics AS (
    SELECT
        AVG(CAST(NULLIF(price, '') AS DECIMAL(10,2)))    AS mean_price,
        STDDEV(CAST(NULLIF(price, '') AS DECIMAL(10,2))) AS std_price
    FROM staging_phones
    WHERE price IS NOT NULL AND price <> ''
)
SELECT
    s.brand_name,
    s.model,
    CAST(s.price AS DECIMAL(10,2)) AS price_inr,
    ROUND((CAST(s.price AS DECIMAL(10,2)) - ps.mean_price) / ps.std_price, 2) AS z_score,
    CASE
        WHEN (CAST(s.price AS DECIMAL(10,2)) - ps.mean_price) / ps.std_price > 3.0 THEN 'OUTLIER (Price Anomaly)'
        ELSE 'Normal Range'
    END AS status
FROM staging_phones s
    CROSS JOIN price_statistics ps
WHERE s.price IS NOT NULL AND s.price <> ''
ORDER BY z_score DESC
LIMIT 20;


-- ────────────────────────────────────────────────────────────
-- STEP 6: DATA INTEGRITY & TYPE CHECKS
-- ────────────────────────────────────────────────────────────
-- Q-C9: Verify refresh_rate contains only valid integers (Hz)
SELECT
    brand_name,
    model,
    refresh_rate
FROM staging_phones
WHERE refresh_rate NOT REGEXP '^[0-9]+$'
  AND refresh_rate IS NOT NULL
  AND refresh_rate <> '';

-- Q-C10: Verify ram_capacity contains only valid integer capacities (GB)
SELECT
    brand_name,
    model,
    ram_capacity
FROM staging_phones
WHERE ram_capacity NOT REGEXP '^[0-9]+$'
  AND ram_capacity IS NOT NULL
  AND ram_capacity <> '';

-- Re-enable Safe Update Mode
SET SQL_SAFE_UPDATES = 1;
"""

with open(OUT_SQL, "w", encoding="utf-8") as f:
    f.write(header + insert_stmt + queries_section)

print(f"Generated {OUT_SQL} successfully! Size: {os.path.getsize(OUT_SQL)/1024:.1f} KB")
