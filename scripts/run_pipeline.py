import subprocess
import duckdb

print("=====Starting Kitchen Lads Pipeline=====")

# Step 1: Run Bronze Ingestion
print("Running Bronze Ingestion ...")
subprocess.run(["python", "scripts/ingest_bronze.py"], check=True)

# Step 2: Run dbt Seed & Transformations
print("Running dbt seeds...")
subprocess.run(["dbt", "seed"], cwd="dbt_project", check=True)

print("Running dbt transformations...")
subprocess.run(["dbt", "run"], cwd="dbt_project", check=True)

# Step 3: Run dbt Tests
print("Running dbt tests...")
subprocess.run(["dbt", "test"], cwd="dbt_project", check=True)

# Step 4: Comprehensive End-to-End Data Validation for ALL Marts
print("Running comprehensive post-pipeline data validation...")
db_path = "dbt_project/kitchen_lads_pipeline.duckdb"
con = duckdb.connect(db_path)

# List of all key tables/marts to check
marts_to_check = [
    "int_unified_orders",
    "gold_hourly_heatmaps",
    "gold_channel_profitability",
    "gold_menu_rankings"
]

for table in marts_to_check:
    row_count = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
    print(f"-> Validation Check [{table}]: {row_count} rows found.")
    assert row_count > 0, f"Validation Failed: {table} is empty!"

con.close()
print("=====Pipeline Completed Successfully!=====")