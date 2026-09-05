# Python Data Engineering — Day 1

## Project Overview

This project is part of my Data Engineering learning journey.

The goal of Day 1 was to practice Python for practical data engineering tasks, including working with CSV files, JSON data, APIs, Pandas, and basic data cleaning.

## Technologies

* Python 3.13
* Pandas
* Requests
* JSON
* CSV

## Exercises

### 01 — Python Basics

Basic Python exercises covering lists, dictionaries, loops, conditions, functions, and data aggregation.

### 02 — CSV & Pandas

Worked with CSV data using Pandas, including:

* Filtering
* Aggregation
* Grouping
* Sorting

### 03 — Data Cleaning

Practiced basic data-quality operations:

* Detecting missing values
* Handling missing values
* Detecting duplicates
* Removing duplicates

### 04 — API Mini Pipeline

Built a small API-to-CSV pipeline using JSONPlaceholder.

```text
API
 ↓
Requests
 ↓
JSON
 ↓
Pandas DataFrame
 ↓
Nested JSON extraction
 ↓
Clean DataFrame
 ↓
CSV
```

The pipeline extracts:

* User ID
* Name
* Email
* City
* Company name

and writes the cleaned dataset to `users_clean.csv`.

## How to Run

Activate the virtual environment:

```bash
source .venv/bin/activate
```

Install dependencies:

```bash
python -m pip install pandas requests
```

Run the mini pipeline:

```bash
python 04_mini_pipeline.py
```

The pipeline generates:

```text
users_clean.csv
```

## What I Learned

* Working with Python dictionaries and lists
* Reading and processing CSV files
* Using Pandas DataFrames
* Handling missing values and duplicates
* Consuming a REST API
* Parsing JSON responses
* Extracting data from nested JSON structures
* Building a simple data ingestion and transformation pipeline
* Working with Python virtual environments
