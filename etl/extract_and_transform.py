"""
ETL Pipeline: smartphones_cleaned_v6.csv
-----------------------------------------
Downloads raw data, normalizes into 10 relational tables,
and also generates MongoDB-ready JSON for import.
"""

import pandas as pd
import json
import os

RAW_CSV = "data/raw/smartphones_cleaned_v6.csv"
OUT_DIR = "data/processed"
os.makedirs(OUT_DIR, exist_ok=True)

df = pd.read_csv(RAW_CSV)

num_cols = ["price","rating","processor_speed","num_cores","battery_capacity",
            "fast_charging","ram_capacity","internal_memory","screen_size",
            "refresh_rate","num_rear_cameras","num_front_cameras",
            "primary_camera_rear","primary_camera_front","extended_upto",
            "resolution_width","resolution_height"]
for col in num_cols:
    df[col] = pd.to_numeric(df[col], errors="coerce")

bool_cols = ["has_5g","has_nfc","has_ir_blaster","fast_charging_available","extended_memory_available"]
for col in bool_cols:
    df[col] = df[col].map({"True":True,"False":False,True:True,False:False,1:True,0:False}).fillna(False).astype(bool)

df["brand_name"]      = df["brand_name"].str.strip().str.lower().fillna("unknown")
df["model"]           = df["model"].str.strip()
df["processor_brand"] = df["processor_brand"].str.strip().str.lower().fillna("unknown")
df["os"]              = df["os"].str.strip().str.lower().fillna("unknown")

df = df.drop_duplicates(subset=["brand_name","model"]).reset_index(drop=True)
df["row_id"] = df.index + 1

# Dimensions
brand = df[["brand_name"]].drop_duplicates().reset_index(drop=True)
brand.insert(0, "brand_id", range(1, len(brand)+1))
brand.to_csv(f"{OUT_DIR}/brand.csv", index=False)

proc_cols = ["processor_brand","num_cores","processor_speed"]
processor = df[proc_cols].drop_duplicates().reset_index(drop=True)
processor.insert(0, "processor_id", range(1, len(processor)+1))
processor.to_csv(f"{OUT_DIR}/processor.csv", index=False)

os_dim = df[["os"]].rename(columns={"os":"os_name"}).drop_duplicates().reset_index(drop=True)
os_dim.insert(0, "os_id", range(1, len(os_dim)+1))
os_dim.to_csv(f"{OUT_DIR}/os.csv", index=False)

conn_cols = ["has_5g","has_nfc","has_ir_blaster"]
connectivity = df[conn_cols].drop_duplicates().reset_index(drop=True)
connectivity.insert(0, "connectivity_id", range(1, len(connectivity)+1))
connectivity.to_csv(f"{OUT_DIR}/connectivity.csv", index=False)

bat_cols = ["battery_capacity","fast_charging_available","fast_charging"]
battery = df[bat_cols].drop_duplicates().reset_index(drop=True)
battery.insert(0, "battery_id", range(1, len(battery)+1))
battery.to_csv(f"{OUT_DIR}/battery.csv", index=False)

scr_cols = ["screen_size","refresh_rate","resolution_width","resolution_height"]
screen = df[scr_cols].drop_duplicates().reset_index(drop=True)
screen.insert(0, "screen_id", range(1, len(screen)+1))
screen.to_csv(f"{OUT_DIR}/screen.csv", index=False)

mem_cols = ["ram_capacity","internal_memory","extended_memory_available","extended_upto"]
memory = df[mem_cols].drop_duplicates().reset_index(drop=True)
memory.insert(0, "memory_id", range(1, len(memory)+1))
memory.to_csv(f"{OUT_DIR}/memory.csv", index=False)

cam_cols = ["num_rear_cameras","num_front_cameras","primary_camera_rear","primary_camera_front"]
camera = df[cam_cols].drop_duplicates().reset_index(drop=True)
camera.insert(0, "camera_id", range(1, len(camera)+1))
camera.to_csv(f"{OUT_DIR}/camera.csv", index=False)

# Fact Table
df2 = df.merge(brand, on="brand_name") \
        .merge(processor, on=proc_cols) \
        .merge(os_dim.rename(columns={"os_name":"os"}), on="os") \
        .merge(connectivity, on=conn_cols) \
        .merge(battery, on=bat_cols) \
        .merge(screen, on=scr_cols) \
        .merge(memory, on=mem_cols) \
        .merge(camera, on=cam_cols)

phone = df2[["row_id","model","price","rating",
             "brand_id","processor_id","os_id","connectivity_id",
             "battery_id","screen_id","memory_id","camera_id"]].copy()
phone.rename(columns={"row_id":"phone_id"}, inplace=True)
phone.to_csv(f"{OUT_DIR}/phone.csv", index=False)

# Summary table
price_analysis = phone.merge(brand, on="brand_id").groupby(
    ["brand_id","brand_name"]
).agg(
    avg_price   = ("price","mean"),
    min_price   = ("price","min"),
    max_price   = ("price","max"),
    model_count = ("phone_id","count")
).reset_index()
price_analysis["avg_price"] = price_analysis["avg_price"].round(2)
price_analysis.to_csv(f"{OUT_DIR}/price_analysis.csv", index=False)
