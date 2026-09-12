# Advanced SQL — Window Functions & Analytical Queries — Day 6

## Project Overview

This project is part of my Data Engineering learning journey. The goal of Day 6 was to move beyond basic aggregation and use window functions to solve common analytical problems that appear frequently in Data Engineering and analytics work.

## Technologies

- PostgreSQL

## What I Practiced

### Problems solved

- **Latest order per customer** — `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ... DESC)` + CTE filtering (`WHERE rn = 1`)
- **ROW_NUMBER vs RANK vs DENSE_RANK** — compared ranking behavior with tied values
- **Change vs previous order** — `LAG()`, ordered from oldest to newest
- **Change vs next order** — `LEAD()`, using the same ordering
- **Combined previous + next order** — `LAG()` and `LEAD()` together, partitioned by customer

### Ties experiment

Created a temporary table containing two orders with the same amount to observe the difference between the three ranking functions without modifying the original data:

| Value | ROW_NUMBER | RANK | DENSE_RANK |
|------:|-----------:|-----:|-----------:|
| 1600  | 1 | 1 | 1 |
| 500   | 2 | 2 | 2 |
| 500   | 3 | 2 | 2 |
| 300   | 4 | 4 | 3 |
| 150   | 5 | 5 | 4 |
| 100   | 6 | 6 | 5 |

## What I Learned

- `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()` produce the same sequence when there are no tied values. Their differences become visible when ties occur.
- `ROW_NUMBER()` always assigns a unique sequential number.
- `RANK()` assigns the same rank to tied values and skips subsequent positions.
- `DENSE_RANK()` assigns the same rank to tied values without skipping positions.
- `PARTITION BY` defines the groups within which a window function operates, while `ORDER BY` defines the ordering inside each group.
- `LAG()` returns a value from a previous row according to the window's `ORDER BY`. With `ASC`, this can represent the previous value chronologically; with `DESC`, the direction is reversed.
- `LEAD()` works in the opposite direction to `LAG()` and returns a value from a following row according to the window ordering.
- Arithmetic involving `NULL` results in `NULL`. For example, `1600 - NULL` returns `NULL`, which correctly represents that no previous order exists.
- A window function alias cannot be referenced directly in the `WHERE` clause of the same query level. A CTE or subquery can be used to calculate the window function first and filter it in an outer query.
- Exploratory or risky queries can be tested safely using a `CREATE TEMPORARY TABLE` copy instead of modifying the original table.
- CTEs can make analytical queries easier to read by calculating window-function results once and reusing them in an outer query.
