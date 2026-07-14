# Football Transfer Market Analytics & ETL Pipeline

An end-to-end data engineering and business intelligence project designed to ingest, cleanse, and model global football transfer market data. This project implements a robust two-tier database architecture (Staging → Production) in MySQL, fully automated data schema profiling via Python, and advanced T-SQL/analytical views designed to extract deep historical player valuation, transfer trends, and managerial performance insights.

---

## 📊 Project Architecture & Data Lifecycle

The system enforces a strict data lifecycle pipeline to maintain referential integrity, handle structural variations in raw data, and eliminate data corruption.

```text
[Raw CSVs (12 Files)] ──> [Python Data Profiler] ──> [Data Dictionary generated]
        │
        ▼ (LOAD DATA INFILE)
[Staging Database] ─────> [Data Cleansing & Transformation Layer]
                                       │
                                       ▼ (INSERT INTO ... SELECT)
                         [Production DB (Highly Constrained Star/Snowflake Schema)]
                                       │
                                       ▼
                         [Analytical Views & Explanatory Queries]
