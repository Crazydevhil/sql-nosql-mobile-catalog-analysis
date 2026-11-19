# Entity-Relationship (ER) Diagram
**Project:** SQL & NoSQL Mobile Catalog Analysis (NMIMS Mumbai)

This directory contains the complete structural data models for the 10-entity database.

---

## 1. Visual Diagram

![Mobile Catalog ER Diagram](er_diagram.png)

*The high-resolution diagram above is located at:* `docs/er_diagram/er_diagram.png`

---

## 2. Interactive / dbdiagram.io Code

We have provided the complete DBML schema in [`schema.dbml`](schema.dbml).

**How to use:**
1. Open [dbdiagram.io](https://dbdiagram.io) in your browser.
2. Paste the contents of `schema.dbml`.
3. You can interactively pan, zoom, rearrange tables, and export in SVG/PDF/PNG formats.

---

## 3. Schema Structure & Cardinality

The architecture follows **Third Normal Form (3NF)** with a centralized **Fact Table (`phone`)** surrounded by 8 dimension tables and 1 summary analytics table:

```mermaid
erDiagram
    BRAND ||--o{ PHONE : "manufactures (1:N)"
    PROCESSOR ||--o{ PHONE : "powers (1:N)"
    OS ||--o{ PHONE : "runs (1:N)"
    CONNECTIVITY ||--o{ PHONE : "supports (1:N)"
    BATTERY ||--o{ PHONE : "features (1:N)"
    SCREEN ||--o{ PHONE : "displays (1:N)"
    MEMORY ||--o{ PHONE : "equips (1:N)"
    CAMERA ||--o{ PHONE : "captures (1:N)"
    BRAND ||--o{ PRICE_ANALYSIS : "benchmarks (1:1)"
    PHONE ||--o{ PRICE_ANALYSIS : "aggregates into"

    BRAND {
        int brand_id PK
        varchar brand_name
    }
    PROCESSOR {
        int processor_id PK
        varchar processor_brand
        tinyint num_cores
        decimal processor_speed
    }
    OS {
        int os_id PK
        varchar os_name
    }
    CONNECTIVITY {
        int connectivity_id PK
        boolean has_5g
        boolean has_nfc
        boolean has_ir_blaster
    }
    BATTERY {
        int battery_id PK
        int battery_capacity
        boolean fast_charging_available
        decimal fast_charging
    }
    SCREEN {
        int screen_id PK
        decimal screen_size
        smallint refresh_rate
        smallint resolution_width
        smallint resolution_height
    }
    MEMORY {
        int memory_id PK
        smallint ram_capacity
        smallint internal_memory
        boolean extended_memory_available
        smallint extended_upto
    }
    CAMERA {
        int camera_id PK
        tinyint num_rear_cameras
        tinyint num_front_cameras
        decimal primary_camera_rear
        decimal primary_camera_front
    }
    PHONE {
        int phone_id PK
        varchar model
        decimal price
        decimal rating
        int brand_id FK
        int processor_id FK
        int os_id FK
        int connectivity_id FK
        int battery_id FK
        int screen_id FK
        int memory_id FK
        int camera_id FK
    }
    PRICE_ANALYSIS {
        int brand_id PK, FK
        varchar brand_name
        decimal avg_price
        decimal min_price
        decimal max_price
        int model_count
    }
```
