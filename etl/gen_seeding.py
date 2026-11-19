import pandas as pd, os

OUT  = "sql/03_dml_seeding"
PROC = "data/processed"

def val(v):
    if v is None or (isinstance(v, float) and str(v) == "nan"):
        return "NULL"
    if isinstance(v, bool):
        return "1" if v else "0"
    if isinstance(v, (int, float)):
        return str(v)
    return "'" + str(v).replace("'", "''") + "'"

tables = ["brand","processor","os","connectivity","battery",
          "screen","memory","camera","phone","price_analysis"]

lines = [
    "USE mobile_catalog;\n",
    "SET FOREIGN_KEY_CHECKS=0;\n",
    "SET SQL_SAFE_UPDATES=0;\n\n",
    "-- Clean previous data before reseeding to prevent Duplicate Key 1062 errors\n"
]

for t in ["phone", "price_analysis", "camera", "memory", "screen", "battery", "connectivity", "os", "processor", "brand"]:
    lines.append(f"TRUNCATE TABLE `{t}`;\n")

lines.append("\n")

for t in tables:
    df = pd.read_csv(f"{PROC}/{t}.csv")
    df = df.where(pd.notnull(df), None)
    cols = ", ".join(df.columns)
    lines.append(f"-- {t}\n")
    lines.append(f"INSERT INTO {t} ({cols}) VALUES\n")
    rows = []
    for _, r in df.iterrows():
        row_vals = ", ".join(val(r[c]) for c in df.columns)
        rows.append(f"  ({row_vals})")
    lines.append(",\n".join(rows) + ";\n\n")

lines.append("SET FOREIGN_KEY_CHECKS=1;\n")

out_path = os.path.join(OUT, "data_seeding.sql")
with open(out_path, "w", encoding="utf-8") as f:
    f.writelines(lines)
