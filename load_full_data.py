import pandas as pd
from sqlalchemy import create_engine
import time

# --- Config ---
CSV_PATH = r"P:\Git_project\dataset\PS_20174392719_1491204439457_log.csv"
DB_PATH  = r"P:\Git_project\fintech_pipline\fintech_pipeline.db"

CHUNK_SIZE = 50000

# --- Setup ---
engine = create_engine(f"sqlite:///{DB_PATH}")
start_time = time.time()

rows_loaded   = 0
rows_rejected = 0
chunk_number  = 0

print("Starting full data load...")
print("-" * 40)

# --- Chunked load ---
try:
    for chunk in pd.read_csv(CSV_PATH, chunksize=CHUNK_SIZE):

        chunk_number += 1

        # Basic cleaning
        chunk = chunk.dropna(subset=["type", "amount"])   # drop critical nulls
        chunk["amount"] = pd.to_numeric(chunk["amount"], errors="coerce")
        chunk = chunk[chunk["amount"] > 0]                # remove zero/negative amounts

        # Load chunk into DB
        chunk.to_sql(
            name="raw_transactions",
            con=engine,
            if_exists="append",
            index=False
        )

        rows_loaded += len(chunk)
        print(f"Chunk {chunk_number} loaded — {rows_loaded:,} rows so far")

    # --- Log the successful run ---
    duration = round(time.time() - start_time, 2)

    log = pd.DataFrame([{
        "rows_loaded"   : rows_loaded,
        "rows_rejected" : rows_rejected,
        "status"        : "SUCCESS",
        "duration_secs" : duration,
        "notes"         : f"Full CSV load — {chunk_number} chunks processed"
    }])

    log.to_sql(
        name="ingestion_logs",
        con=engine,
        if_exists="append",
        index=False
    )

    print("-" * 40)
    print(f"DONE — {rows_loaded:,} rows loaded in {duration}s")
    print(f"Logged to ingestion_logs")

except Exception as e:
    duration = round(time.time() - start_time, 2)

    # Log the failure
    log = pd.DataFrame([{
        "rows_loaded"   : rows_loaded,
        "rows_rejected" : rows_rejected,
        "status"        : "FAILED",
        "duration_secs" : duration,
        "notes"         : f"Error: {str(e)}"
    }])

    log.to_sql(
        name="ingestion_logs",
        con=engine,
        if_exists="append",
        index=False
    )

    print(f"FAILED at chunk {chunk_number}: {e}")
