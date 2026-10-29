import os
import duckdb

# Connect to the local DuckDB database
db_path = "dbt_project/kitchen_lads_pipeline.duckdb"
con = duckdb.connect(db_path)

print("Starting Bronze Layer Ingestion...")

# Map CSV files to target raw table names in DuckDB
raw_sources = {
    "raw_ubereats": "data/raw/ubereats_orders.csv",
    "raw_deliveroo": "data/raw/deliveroo_orders.csv",
    "raw_justeat": "data/raw/justeat_orders.csv",
    "raw_foodhub": "data/raw/foodhub_orders.csv"
}

for table_name, file_path in raw_sources.items():
    if os.path.exists(file_path):
        # Read CSV directly into a DuckDB table using auto-detected schema
        con.execute(f"CREATE OR REPLACE TABLE {table_name} AS SELECT * FROM read_csv_auto('{file_path}')")
        count = con.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
        print(f" Loaded '{table_name}' with {count} rows.")
    else:
        print(f" Warning: File not found at {file_path}")

con.close()
print("Bronze Ingestion Layer completed successfully!")