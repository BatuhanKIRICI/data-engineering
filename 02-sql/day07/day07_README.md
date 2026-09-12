# Advanced SQL — Date/Time Functions & Business Analytics — Day 7

## Project Overview

This project is part of my Data Engineering learning journey. The goal of Day 7 was to work with date/time functions and use window functions to answer realistic business questions — month-over-month and day-over-day revenue change — while also cleaning up my understanding of when to use `GROUP BY` vs. `PARTITION BY` vs. `ORDER BY`.

## Technologies

- PostgreSQL

## What I Practiced

### Problems solved

- **Monthly revenue, grouped safely** — `date_trunc('month', ...)` instead of `extract(month from ...)`, so different years don't get merged together
- **Month-over-month change** — `LAG()` over a monthly aggregate, ordered by time (not by revenue)
- **Day-over-day change** — same pattern at daily grain, since the dataset only had one month of data to work with
- **Day-over-day % change** — chained CTEs: aggregate first, then apply `LAG()`, then compute the percentage in an outer query
- **Business challenge**: reproduce the full "revenue, previous day's revenue, % change" report end to end

### A mistake worth keeping in the file

An early attempt used `PARTITION BY trn_month` on an already-monthly aggregate. Since each month was already its own row, every partition ended up with exactly one row — so `LAG()` had nothing to look back to and returned `NULL` every time. Removing `PARTITION BY` entirely (since this is a single time series, not split by customer/category/etc.) fixed it.

## What I Learned

- `date_trunc()` rounds a timestamp down to a given precision (month/day/year); `extract()` pulls out a single numeric part. For grouping across years, `date_trunc` is the safe choice — `extract(month from ...)` alone would merge Sep-2025 and Sep-2026 into the same bucket.
- `GROUP BY` collapses rows into a summary (row count shrinks). `PARTITION BY` keeps every row and adds a per-group value alongside it (row count stays the same) — they solve different problems even though both involve "grouping."
- `PARTITION BY` only makes sense when a group can contain more than one row. Partitioning by a column that's already unique per row (like a monthly grain column after grouping) leaves nothing for `LAG`/`LEAD`/`RANK` to compare against.
- `ORDER BY` inside a window function isn't cosmetic — it defines what "previous," "next," or "rank 1" actually means. Ordering by the wrong column (e.g. by `revenue` instead of by time) doesn't just resort the output, it changes what `LAG()` returns.
- When a window calculation depends on an aggregate result, the aggregation and window calculation need to be separated into different query levels, such as CTEs or subqueries.
- A simple decision framework for turning a business question into SQL: will the row count shrink (`GROUP BY`) or stay the same (window function)? Do groups need to be evaluated independently (`PARTITION BY`)? Do words like "previous/next/highest/latest" appear (`LAG`/`LEAD`/`RANK`/`ROW_NUMBER`, with `ORDER BY` defining the direction)? Does the result build on an earlier calculation (`CTE`)?
