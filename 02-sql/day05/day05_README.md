# PostgreSQL Query Optimization — Day 5

## Project Overview
This project is part of my Data Engineering learning journey.
The goal of Day 5 was to understand how PostgreSQL actually executes a query — reading execution plans, comparing scan types, and seeing how index design decisions play out on 100,000 rows of synthetic data.

## Technologies
* PostgreSQL
* DBeaver
* Python (`random`, `datetime` — synthetic data generation, no external libraries)

## What I Built

### Test setup
A 100,000-row `test_orders_large` table, generated with a small Python script (`generate_test_data.py`) using plain `random`/`datetime` — no `Faker` needed. `customer_id` was capped at 1,000 distinct values on purpose, so a single customer's orders make up roughly 0.1% of the table — a controlled, high-selectivity scenario, alongside broader ranges for lower-selectivity comparisons.

### Experiments (selectivity vs. scan type)

| Query | Rows matched | Plan chosen | Execution Time |
|---|---|---|---|
| `customer_id = 1` (no index) | 103 (~0.1%) | Seq Scan | 3.729 ms |
| `customer_id = 1` (indexed) | 103 (~0.1%) | Bitmap Heap Scan | 0.122 ms |
| `customer_id <= 500` | 50,005 (~50%) | Bitmap Heap Scan | 4.213 ms |
| `customer_id <= 900` | 90,093 (~90%) | Seq Scan | 5.110 ms |
| `order_id = 10000` (PK) | 1 | Index Scan | 0.026 ms |

### Composite index
Created `(customer_id, order_date)` and tested the **leftmost prefix rule**:
- `customer_id = ? AND order_date = ?` → index used efficiently
- `order_date = ?` alone → index **not** used, falls back to Seq Scan

## What I Learned
* `EXPLAIN` shows PostgreSQL's *estimated* plan; `EXPLAIN ANALYZE` actually runs the query and reports *real* timings (`actual time`, `Execution Time`) — cost units are not milliseconds, they're a relative planner estimate
* Having an index does not mean PostgreSQL will use it — the planner always picks whichever plan it estimates is cheapest
* Selectivity (what fraction of the table matches) is the main driver of the scan choice, but there's no fixed percentage threshold — it's a cost calculation, not a rule of thumb, as demonstrated by testing queries with approximately 0.1%, 50%, and 90% selectivity
* Bitmap Heap Scan sits between Seq Scan and Index Scan: it's what PostgreSQL picks when a meaningful-but-not-tiny number of rows match and they're scattered across the table
* Composite indexes follow a **leftmost prefix rule**: `(A, B)` serves `WHERE A = ...` and `WHERE A = ... AND B = ...`, but generally not `WHERE B = ...` alone
* Index column order should be designed around actual query patterns — not just "which column feels more important"
* `Rows Removed by Filter` in a Seq Scan plan is a direct, concrete way to see how much wasted work a missing index causes
