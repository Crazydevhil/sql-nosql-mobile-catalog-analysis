# Raw Dataset Information — Smartphone Catalog

## Source
- **Dataset Name**: Smartphones Cleaned Dataset
- **Format**: CSV (`smartphones_cleaned_v6.csv`)
- **Total Records**: 980 smartphone models
- **Total Features**: 26 attributes (Pricing, Ratings, SoC, Screen specs, Battery, Camera configurations, OS, Memory)
- **Source Platform**: Kaggle / NMIMS Mumbai Academic Project Repository

## Schema Dictionary (26 Features)
| Column Name | Data Type | Description |
|---|---|---|
| `brand_name` | VARCHAR | Primary manufacturer / brand |
| `model` | VARCHAR | Model marketing name |
| `price` | NUMERIC | Retail price in Indian Rupees (INR) |
| `rating` | NUMERIC | Expert / aggregate consumer rating (0-100) |
| `has_5g` | BOOLEAN | 5G cellular network support |
| `has_nfc` | BOOLEAN | Near Field Communication support |
| `has_ir_blaster` | BOOLEAN | Infrared transmitter presence |
| `processor_brand` | VARCHAR | SoC manufacturer (Snapdragon, Exynos, Bionic, etc.) |
| `num_cores` | NUMERIC | CPU core count |
| `processor_speed` | NUMERIC | Max CPU clock speed (GHz) |
| `battery_capacity` | NUMERIC | Battery capacity (mAh) |
| `fast_charging_available` | BOOLEAN | Fast charging hardware flag |
| `fast_charging` | NUMERIC | Fast charging speed (Watts) |
| `ram_capacity` | NUMERIC | System RAM (GB) |
| `internal_memory` | NUMERIC | Internal flash storage (GB) |
| `screen_size` | NUMERIC | Diagonal display dimension (inches) |
| `refresh_rate` | NUMERIC | Screen refresh rate (Hz) |
| `num_rear_cameras` | NUMERIC | Rear camera sensor count |
| `num_front_cameras` | NUMERIC | Selfie camera sensor count |
| `os` | VARCHAR | Operating System platform (Android, iOS, etc.) |
| `primary_camera_rear` | NUMERIC | Main rear sensor resolution (MP) |
| `primary_camera_front` | NUMERIC | Primary front camera resolution (MP) |
| `extended_memory_available` | BOOLEAN | MicroSD / expansion slot flag |
| `extended_upto` | NUMERIC | Maximum expandable storage limit (GB) |
| `resolution_width` | NUMERIC | Display horizontal pixel resolution |
| `resolution_height` | NUMERIC | Display vertical pixel resolution |

## Automated Processing
To transform this raw dataset into 3NF normalized relational tables and MongoDB JSON documents:
```bash
python etl/extract_and_transform.py
```
