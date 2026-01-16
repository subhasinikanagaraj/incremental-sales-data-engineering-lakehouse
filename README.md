# CarSales Medallion Architecture — End‑to‑End Data Engineering Incremental Pipeline

This repository contains a complete data engineering pipeline for **CarSales** data, built using the **Medallion Architecture** (Bronze → Silver → Gold).  
The pipeline supports both **initial loads** and **incremental loads**, transforming raw CSV files into a fully modeled **star schema** stored as Delta tables.

---

## Architecture Overview

### **Source System**
- Raw CarSales data arrives as **CSV files** in GitHub.
- Ingested via Azure Data Factory (ADF) to Azure SQL DB.

---

## Bronze Layer — Raw Parquet Files
- Converts raw CSV files into **Parquet** for efficient storage and schema consistency using Azure Data Factory.
- No transformations applied.
- ADF uses a **SQL watermark table** to ingest only incremental rows from the source.

---

## Silver Layer — Cleaned/ Transformed Parquet Files
- Reads only incremental Bronze data using a **Silver watermark table** stored in Delta using Databricks.
- Performs Data cleansing and transformation  
- Writes cleaned data back as **Parquet files** in the Silver container.

---

## Gold Layer — Delta Tables (Star Schema)
The Gold layer consumes only the incremental slice from Silver and builds a **star schema** using Delta tables in Databricks.

### **Dimensions**
Build **SCD-Type 1** dimensions
- `dim_model`  
- `dim_dealer`  
- `dim_date`  
- `dim_branch` 

### **Fact Table**
- `fact_sales`

---

## Incremental Load Strategy

### **1. GitHub → SQLDB Incremental File Load **
- ADF retrieves file list from GitHub.
- Reads SQL watermark table containing previously loaded filenames.
- Identifies new files using a Filter activity.
- Loads only new files into Azure SQL (src_car_sales).
- Inserts processed filenames into the watermark table.
  **Repo: AzureSQLDB/, adf/**

### **2. Bronze Incremental Load**
- ADF reads SQL watermark using lookup activities.
- Extracts only new/updated rows.
- Writes Parquet files to Bronze.
- Updates SQL watermark.
- Data is written in append mode, with each incremental batch stored as a new Parquet file.
  **Repo: adf/**

### **3. Silver Incremental Load**
- Reads Silver watermark from Delta.
- Filters Bronze using Date_ID range
- Writes cleaned/transformed Parquet files to Silver.
- Updates Silver watermark.
- Silver writes use append mode to load only the incremental slice.
  **Repo: databricks/**

### **4. Gold Incremental Load**
- Reads Gold watermark.
- Filters Silver incremental slice.
- Updates dimensions using `MERGE`.
- Appends or merges fact data.
- Updates Gold watermark.
   **Repo: databricks/**
  
---
## Data Pipeline Flowchart

GitHub (Raw CSV Files)
          │
          ▼
   File‑Level CDC
 (load only new files)
          │
          ▼
Azure SQL (Source Table)
          │
          ▼
   Row‑Level CDC
(load only new/updated rows)
          │
          ▼
──────── Bronze Layer ────────
 Raw Parquet (Append Only)
          │
          ▼
 Incremental Slice
(using Silver watermark)
          │
          ▼
──────── Silver Layer ─────────
 Cleaned/Transformed Parquet
 Append or Partition Overwrite
          │
          ▼
 Incremental Slice
(using Gold watermark)
          │
          ▼
──────── Gold Layer ───────────
 Delta Tables (Star Schema)
 - SCD1 Dimensions (MERGE)
 - fact_sales (MERGE)


## Repository Structure

- AzureSQLDB
- adf
- databricks

