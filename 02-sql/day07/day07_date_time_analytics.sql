-- ============================================================
-- Day 7 — Advanced SQL: Date/Time Functions & Business Analytics
-- ============================================================

-- ------------------------------------------------------------
-- 1. QUICK LOOK AT THE DATA
-- ------------------------------------------------------------

select * from fact_sales;
select * from dim_date;

-- ------------------------------------------------------------
-- 2. date_trunc() vs extract() -- why date_trunc wins for grouping
-- ------------------------------------------------------------
-- extract(month from date) returns a plain number (e.g. 9),
-- which would silently merge Sep-2025 and Sep-2026 together.
-- date_trunc('month', date) returns a full timestamp rounded
-- down to the start of the month, keeping different years apart.

-- Monthly revenue, grouped safely with date_trunc:
select
    date_trunc('month', full_date) as trn_month,
    sum(total_amount) as revenue
from dim_date dd
join fact_sales fs on dd.date_id = fs.date_id
group by trn_month
order by trn_month;

-- ------------------------------------------------------------
-- 3. MoM growth attempt #1 -- the PARTITION BY mistake
-- ------------------------------------------------------------
-- Common mistake: partitioning by the same column being grouped
-- on (or by the group itself) leaves each partition with only
-- one row, so LAG() always returns NULL -- there's no "previous"
-- row left to find within a single-row partition.

with change_monthly as (
    select
        sum(total_amount) as revenue,
        date_trunc('month', full_date) as trn_month
    from dim_date dd
    join fact_sales fs on dd.date_id = fs.date_id
    group by trn_month
)
select
    lag(revenue) over (order by trn_month) as lg_month  -- fine here, no PARTITION BY
from change_monthly;

-- ------------------------------------------------------------
-- 4. MoM growth, done correctly (monthly grain)
-- ------------------------------------------------------------
-- No PARTITION BY needed: it's a single time series (whole
-- company revenue), not split by customer/category/etc.
-- ORDER BY must be the TIME column (trn_month), not revenue --
-- ordering by revenue would make "previous" mean "next lowest
-- value" instead of "previous calendar period".

with change_monthly as (
    select
        date_trunc('month', full_date) as trn_month,
        sum(total_amount) as revenue
    from dim_date dd
    join fact_sales fs on dd.date_id = fs.date_id
    group by trn_month
)
select
    revenue,
    trn_month,
    lag(revenue) over (order by trn_month asc) as month_prev
from change_monthly;

-- Only one month of data exists in this dataset, so month_prev
-- is NULL here -- correct, but not testable at month grain.

-- ------------------------------------------------------------
-- 5. Testing the same logic at daily grain (more data to work with)
-- ------------------------------------------------------------

with change_daily as (
    select
        date_trunc('day', full_date) as trn_day,
        sum(total_amount) as revenue
    from dim_date dd
    join fact_sales fs on dd.date_id = fs.date_id
    group by trn_day
)
select
    revenue,
    trn_day,
    lag(revenue) over (order by trn_day asc) as day_prev
from change_daily;

-- ------------------------------------------------------------
-- 6. Day-over-day % change
-- ------------------------------------------------------------
-- LAG needs the aggregated result as its input, so the
-- aggregation is completed in an earlier CTE before
-- applying the window function.
--
-- number - NULL = NULL, so the first day's change is correctly
-- NULL (no previous day exists), not 0.

with change_daily as (
    select
        date_trunc('day', full_date) as trn_day,
        sum(total_amount) as revenue
    from dim_date dd
    join fact_sales fs on dd.date_id = fs.date_id
    group by trn_day
),
with_previous as (
    select
        trn_day,
        revenue,
        lag(revenue) over (order by trn_day) as day_prev
    from change_daily
)
select
    trn_day,
    revenue,
    day_prev,
    round((revenue - day_prev) / day_prev * 100, 2) as percentage_daily
from with_previous;

-- ------------------------------------------------------------
-- 7. FINAL: Business Challenge
-- ------------------------------------------------------------
-- "Show each day's total revenue, its change vs. the previous
-- day, and the percentage change."
-- Same pattern as above, with column names matching the
-- requested output shape (trn_day, revenue, previous_revenue,
-- percentage_change).

with change_daily as (
    select
        date_trunc('day', full_date) as trn_day,
        sum(total_amount) as revenue
    from fact_sales fs
    join dim_date dd on fs.date_id = dd.date_id
    group by trn_day
),
previous_revenue as (
    select
        trn_day,
        revenue,
        lag(revenue) over (order by trn_day asc) as previous_revenue
    from change_daily
)
select
    trn_day,
    revenue,
    previous_revenue,
    round((revenue - previous_revenue) * 100 / previous_revenue, 2) as percentage_change
from previous_revenue;

-- ------------------------------------------------------------
-- 8. KEY TAKEAWAYS
-- ------------------------------------------------------------
-- 1. date_trunc() rounds a timestamp down to a given precision
--    (month/day/year); extract() pulls out a single numeric part.
--    For grouping across multiple years, date_trunc is safe;
--    extract(month...) alone silently merges different years.
-- 2. PARTITION BY splits rows into independent groups for a
--    window function. If every group ends up with exactly one
--    row (e.g. partitioning by the same column being grouped on),
--    LAG/LEAD/RANK have nothing to compare against and return NULL.
-- 3. GROUP BY collapses rows into a summary (row count shrinks).
--    PARTITION BY keeps every row and adds a per-group value
--    alongside it (row count stays the same).
-- 4. ORDER BY inside a window function isn't just cosmetic --
--    it defines what "previous"/"next"/"rank 1" actually means,
--    so the wrong ORDER BY produces a wrong (not just
--    differently-sorted) result.
-- 5. When a result depends on a value that itself needs
--    aggregating first (e.g. LAG on top of a SUM), chain two
--    CTEs: aggregate first, then apply the window function in
--    a second CTE on top of the first.
-- 6. Decision framework for translating a business ask into SQL:
--    - Will the row count shrink?              -> GROUP BY
--    - Rows stay, but need row-to-row compare?  -> window function
--    - Should groups be evaluated independently? -> PARTITION BY
--    - Words like "previous/next/latest/highest" -> LAG/LEAD/
--      ROW_NUMBER/RANK, and ORDER BY defines the direction
--    - Result builds on another calculation?    -> CTE
