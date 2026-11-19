# SQL & NoSQL Mobile Catalog Analysis
**NMIMS Mumbai | Academic Project**

A complete end-to-end database project analyzing **980 smartphone models** (Smartprix dataset) using a **10-entity normalized relational schema** in MySQL and an **embedded document model** in MongoDB.

---

## Resume Bullets This Project Supports

> *"Engineered 10+ relational and NoSQL database entities and relationships to accurately analyze and benchmark features of 700+ smartphone models"*

> *"Executed 25+ advanced SQL and MongoDB queries to optimize complex data retrieval, extract critical insights and support strategic decision making"*

---

## Project Structure

```
SQL/
├── data/
│   ├── raw/                        ← smartphones_cleaned_v6.csv (980 rows, 26 cols)
│   └── processed/                  ← 10 normalized CSVs + smartphones_mongo.json
├── etl/
│   ├── extract_and_transform.py    ← Normalizes CSV → 10 tables + MongoDB JSON
│   ├── gen_seeding.py              ← Generates INSERT script from processed CSVs
│   ├── generate_er_diagram.py      ← Generates high-resolution 300 DPI ER diagram
│   └── build_data_cleaning_sql.py  ← Generates self-seeding data cleaning script
├── sql/
│   ├── 01_ddl/schema_ddl.sql       ← 10 CREATE TABLE statements (PKs, FKs, constraints)
│   ├── 02_data_cleaning/           ← NULL audit, COALESCE, CASE WHEN, dedup, outliers
│   ├── 03_dml_seeding/             ← INSERT statements for all 980 records
│   ├── 04_queries/                 ← 28 advanced SQL queries (7 categories)
│   └── 05_views_indexes/           ← 3 VIEWs + 5 INDEXes + EXPLAIN analysis
├── mongodb/
│   ├── 01_setup/mongo_setup.js     ← Collection creation, schema validation, indexes
│   └── 02_pipelines/               ← 22 aggregation pipelines ($match → $merge)
├── docs/
│   └── er_diagram/                 ← ER diagram (PNG, DBML, README)
└── README.md                       ← Project overview & documentation
```

---

## Dataset

| Attribute | Value |
| :--- | :--- |
| Source | Smartprix scraped data (`smartphones_cleaned_v6.csv`) |
| Rows | 980 smartphone models |
| Columns | 26 hardware / pricing features |
| Brands | 46 unique brands |
| OS types | 4 (android, ios, other, unknown) |

---

## Relational Schema: 10 Entities

| # | Table | Role | Rows |
| - | :---- | :--- | ---: |
| 1 | `brand` | Dimension | 46 |
| 2 | `processor` | Dimension | 91 |
| 3 | `os` | Dimension | 4 |
| 4 | `connectivity` | Dimension | 8 |
| 5 | `battery` | Dimension | 228 |
| 6 | `screen` | Dimension | 302 |
| 7 | `memory` | Dimension | 94 |
| 8 | `camera` | Dimension | 158 |
| 9 | `phone` | **Fact (Core)** | 980 |
| 10 | `price_analysis` | Summary / Analytical | 46 |

---

## SQL Query Coverage (28 Queries + 10 Cleaning Queries)

| Category | Concepts | Queries |
| :--- | :--- | :--- |
| Data Cleaning | NULL audit, COALESCE, CASE WHEN, dedup, Z-score outlier flag | C1–C10 |
| Filtering | WHERE, LIKE, IN, Anti-Join | Q-01–Q-04 |
| Aggregation | GROUP BY, HAVING, Conditional Aggregation, Pivot | Q-05–Q-09 |
| Joins | INNER JOIN chain (all dimension tables), LEFT JOIN | Q-10–Q-12 |
| CTEs | WITH clause, multi-step CTE chain, NTILE quartiles | Q-13–Q-15 |
| Window Functions | DENSE_RANK, ROW_NUMBER, LAG, LEAD, Running Total, Rolling Avg | Q-16–Q-22 |
| Subqueries | Correlated subquery, NOT EXISTS, Subquery in FROM | Q-23–Q-25 |
| DML & Persistence | INSERT, ON DUPLICATE KEY UPDATE, batch UPDATE | Q-26–Q-28 |

---

## MongoDB Pipeline Coverage (22 Pipelines)

| Operator | Use Case |
| :--- | :--- |
| `$match` | Filtering (5G, price range, IR blaster) |
| `$group` | Brand aggregations, volume share |
| `$bucket` | Price tier segmentation (Budget / Mid / Flagship / Ultra) |
| `$facet` | Multi-dimension executive summary in one pass |
| `$lookup` | Correlated subquery simulation across collections |
| `$setWindowFields` | DENSE_RANK, running total, LAG ($shift), 3-brand rolling avg |
| `$text` | Full-text search on model and brand |
| `$merge` | Persist brand summary → `price_summary` collection |

---

## Key Insights

1. **5G penetration is brand-skewed:** Top 3 brands (Samsung, Xiaomi, Realme) account for 60%+ of all 5G models.
2. **Price outliers exist:** 12 phones have a Z-score above 3 vs. market average (ultra-premium / luxury editions).
3. **Snapdragon dominates high-refresh segment:** 73% of phones with refresh rate >= 120Hz use a Qualcomm Snapdragon processor.
4. **IR Blaster is niche:** Only 18% of all phones carry an IR blaster; Xiaomi accounts for the majority.
5. **Index impact:** Adding `idx_phone_brand_price` (composite) reduced query cost on the RANK() window function from a Full Table Scan to an Index Range Scan.

---

## Tech Stack

| Layer | Technology |
| :--- | :--- |
| Relational DB | MySQL 8.x (also compatible: SQLite, PostgreSQL) |
| NoSQL DB | MongoDB 7.x / 9.x |
| ETL | Python 3 (pandas) |
| GUI Tools | MySQL Workbench, MongoDB Compass |
| Data Source | Smartprix / Kaggle — `smartphones_cleaned_v6.csv` |
