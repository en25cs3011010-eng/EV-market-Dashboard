"""Loads ev_market_clean.csv into MySQL (alternative to LOAD DATA).
Usage: pip install pandas sqlalchemy pymysql
Edit USER / PASSWORD / HOST below, run the CREATE TABLE part of schema_and_sql.sql first, then: python load_to_mysql.py"""
import pandas as pd
from sqlalchemy import create_engine
USER, PASSWORD, HOST, DB = "root", "your_password", "localhost", "ev_market"
engine = create_engine(f"mysql+pymysql://{USER}:{PASSWORD}@{HOST}/{DB}")
df = pd.read_csv("ev_market_clean.csv")
df.to_sql("ev_vehicles", engine, if_exists="append", index=False, chunksize=10000)
print(pd.read_sql("SELECT COUNT(*) AS rows_loaded FROM ev_vehicles", engine))
