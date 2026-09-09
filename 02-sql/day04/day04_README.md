# Database Design & Data Warehouse — Day 4

## Project Overview
This project is part of my Data Engineering learning journey.
The goal of Day 4 was to design and build a small Star Schema in PostgreSQL, load it with data, and write analytics queries against it — including window functions.

## Technologies
* PostgreSQL
* DBeaver

## What I Built

### Star Schema
```
                    ┌──────────────┐
                    │ dim_customer │
                    └──────┬───────┘
                           │
┌──────────────┐     ┌─────▼──────┐     ┌──────────────┐
│  dim_product │────►│ fact_sales │◄────│   dim_date   │
└──────────────┘     └────────────┘     └──────────────┘
```

- `dim_customer`, `dim_product`, `dim_date` — dimension tables
- `fact_sales` — fact table, references all three dimensions via foreign keys
- `unit_price` / `total_amount` are stored on the fact table (not the product dimension), since prices change over time and a sale should reflect the price at the moment it happened
- `date_id` uses an integer format (`YYYYMMDD`) instead of a date type, for faster joins and smaller indexes

## Exercises

### 01 — Analytics queries
Revenue by city, revenue by category, revenue by month — practicing joining the fact table to each dimension.

### 02 — Window functions
- Found each customer's best month by revenue, using a CTE (aggregate first) + `RANK() OVER (PARTITION BY ... ORDER BY ...)`
- Found the best-selling product per category by quantity, same CTE + window function pattern

## What I Learned
* Why a star schema separates facts from dimensions
* Why fact tables store point-in-time values (like price) instead of relying on the dimension's current value
* The difference between `GROUP BY` (collapses rows into a summary) and `PARTITION BY` (keeps every row, adds a per-group value alongside it)
* Why aggregation (`SUM`) has to happen before ranking with a window function — otherwise the rank is based on a single row instead of the true total
* `WHERE` can't filter on a window function's alias (it runs before window functions are evaluated) — need to wrap the query and filter in the outer `SELECT`
* Joining 3+ tables at once, each with its own independent `ON` condition
* A common real-world bug: `GROUP BY month` alone silently merges different years' data together — needs `GROUP BY year, month` to be safe
