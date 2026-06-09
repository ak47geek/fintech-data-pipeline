import pandas as pd
import sqlite3

# --- Config ---
CSV_PATH = r"P:\Git_project\dataset\PS_20174392719_1491204439457_log.csv"  # change this to your actual path
DB_PATH  = r"P:\Git_project\fintech_pipline\fintech_pipeline.db"      # change this to your actual path

# --- Load only 1000 rows from CSV ---
df = pd.read_csv(CSV_PATH, nrows=1000)

print("CSV columns:", df.columns.tolist())
print("Shape:", df.shape)
print(df.head(3))

# --- Connect to SQLite ---
conn = sqlite3.connect(DB_PATH)

# --- Load into raw_transactions ---
df.to_sql(
    name="raw_transactions",
    con=conn,
    if_exists="append",   # append so existing table structure is kept
    index=False           # don't write pandas row numbers
)

conn.close()
print("Done — 1000 rows loaded successfully.")
