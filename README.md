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
### 1. The Raw Ingestion & Profiling Layer (`Column_Mapping.ipynb`)
* **Automated Data Profiling:** A specialized Python script using `Pandas` and `openpyxl` that scans all 12 inbound CSV files dynamically. 
* **Anomaly Mitigation:** Automatically maps primary keys (PK) and foreign keys (FK) while proactively correcting the **Python "Float-ID Anomaly"** (where missing values force integer columns to cast as floats, e.g., mapping `14.0` back to `14` and string `NaN` to SQL `NULL`).
* **Data Dictionary Blueprint:** Generates an enterprise-grade Excel data dictionary defining strict target types and data cleaning logic.

### 2. The Consolidated Database Engine (`setup_database.sql`)
To streamline deployment, all SQL steps have been compiled into a single, cohesive database transaction script executing:
* **The Staging Schema:** Creates an isolated database `staging_transfermarkt` to handle raw multi-format CSV files. Uses native, high-throughput `LOAD DATA INFILE` routines coupled with regular expressions (`REGEXP_REPLACE`) and logical `SET` adjustments to safely convert inconsistent dates and drop corrupted rows.
* **The Production Relational Schema:** Establishes `production_transfermarket` containing 12 heavily normalized tables bound tightly by explicit `PRIMARY KEY` and `FOREIGN KEY` constraints (players, games, clubs, appearances, lineups, transfers, etc.).
* **Migration & Type-Casting Pipeline:** Safe down-casting migrations that move data from Staging to Production, converting raw text representations to logical formats like `TINYINT(1)` boolean flags for attributes such as team captaincy.

---

## 🎯 Key Analytical & Strategic Insights

Once data normalization was completed in production, advanced analytical queries and database views were established to uncover high-value performance vectors:

* **Player Valuation Metrics (`v_player_career_profiles`):** Created a comprehensive view consolidating player parameters across appearances. Modeled advanced sports metrics including **minutes per goal** and **goal contributions per 90 minutes** for players exceeding a 500-minute baseline footprint.
* **Management Intelligence:** Aggregated manager records tracking games managed against total victories to isolate comprehensive **overall, home, and away win percentages** (filtering out lower-tier frequencies with `HAVING total_games_managed >= 20`).
* **Financial Analytics:** Evaluated economic premiums by tracking the delta between actual `transfer_fee` values against standard `market_value_in_eur` to isolate top overpaid market spikes and identify heavy spending clubs by season.

---

## 🛠️ Tech Stack & Capabilities

* **Database Engine:** MySQL Server 8.0
* **Programming Languages:** SQL (DDL, DML, Stored Views, Aggregations), Python 3.14 (Pandas, OpenPyXL, OS automation)
* **Development Environments:** Jupyter Notebook, MySQL Workbench
* **Database Concepts:** ETL Pipeline Design, Data Staging, Constraints Calibration, Schema Integrity, Transaction Footprint Validation

---

## 🚀 How to Replicate This Pipeline

1. **Clone the Repository:**
   ```bash
   git clone [https://github.com/yourusername/football-market-db.git](https://github.com/yourusername/football-market-db.git)
   cd football-market-db
