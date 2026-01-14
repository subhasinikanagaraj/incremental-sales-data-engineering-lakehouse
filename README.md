# incremental-sales-data-engineering-lakehouse
# CarSales Medallion Architecture — End‑to‑End Incremental Pipeline

This repository contains a complete data engineering pipeline for **CarSales** data, built using the **Medallion Architecture** (Bronze → Silver → Gold).  
The pipeline supports both **initial loads** and **incremental loads**, transforming raw CSV files into a fully modeled **star schema** stored as Delta tables.

---

## Architecture Overview

### **Source System**
- Raw CarSales data arrives as **CSV files**.
- Ingested via Azure Data Factory (ADF).

---

## Bronze Layer — Raw Parquet Files
- Converts raw CSV files into **Parquet** for efficient storage and schema consistency.
- No transformations applied.
- ADF uses a **SQL watermark table** to ingest only incremental rows from the source.

---

## Silver Layer — Cleaned/ Transformed Parquet Files
- Reads only incremental Bronze data using a **Silver watermark table** stored in Delta.
- Performs Data cleansing and transformation  
- Writes cleaned data back as **Parquet files** in the Silver container.

---

## Gold Layer — Delta Tables (Star Schema)
The Gold layer consumes only the incremental slice from Silver and builds a **star schema** using Delta tables.

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

### **1. Bronze Incremental Load**
- ADF reads SQL watermark using lookup activities.
- Extracts only new/updated rows.
- Writes Parquet files to Bronze.
- Updates SQL watermark.

### **2. Silver Incremental Load**
- Reads Silver watermark from Delta.
- Filters Bronze using Date_ID column (Date_ID > load_start_dt AND Date_ID <= load_end_dt)
- Writes cleaned/transformed Parquet files to Silver.
- Updates Silver watermark.

### **3. Gold Incremental Load**
- Reads Gold watermark.
- Filters Silver incremental slice.
- Updates dimensions using `MERGE`.
- Appends or merges fact data.
- Updates Gold watermark.

---

## Repository Structure

- SQL DB
- adf
- databricks

