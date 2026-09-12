-- =========================================================
-- DAY 5 - POSTGRESQL QUERY OPTIMIZATION
-- =========================================================

-- Topics:
-- EXPLAIN
-- EXPLAIN ANALYZE
-- Sequential Scan
-- Index Scan
-- Bitmap Scan
-- Selectivity
-- Composite Index
-- Leftmost Prefix Rule


-- =========================================================
-- 1. TEST TABLE
-- =========================================================

create table test_orders_large (
    order_id int primary key,
    customer_id int,
    amount decimal(10,2),
    order_date date
);


-- Data was generated with:
-- generate_test_data.py
--
-- 100,000 rows were imported into this table.


-- =========================================================
-- 2. SEQUENTIAL SCAN
-- =========================================================

explain analyze
select *
from test_orders_large
where customer_id = 1;


-- Without an index PostgreSQL performs a Sequential Scan.
--
-- The database checks the table row by row.
--
-- Example:
-- Rows Removed by Filter: 99897


-- =========================================================
-- 3. INDEX ON CUSTOMER_ID
-- =========================================================

create index idx_test_orders_large_customer_id
on test_orders_large (customer_id);


-- =========================================================
-- 4. INDEX USAGE
-- =========================================================

explain analyze
select *
from test_orders_large
where customer_id = 1;


-- PostgreSQL may use a Bitmap Index Scan + Bitmap Heap Scan.
--
-- Important:
-- Creating an index does NOT guarantee that PostgreSQL
-- will use it.
--
-- The query planner chooses the cheapest execution plan.


-- =========================================================
-- 5. SELECTIVITY
-- =========================================================

-- Highly selective query:
-- approximately 0.1% of rows match

explain analyze
select *
from test_orders_large
where customer_id = 1;


-- Low-selectivity query:
-- approximately 50% of rows match

explain analyze
select *
from test_orders_large
where customer_id <= 500;


-- Very low selectivity:
-- approximately 90% of rows match

explain analyze
select *
from test_orders_large
where customer_id <= 900;


-- General rule:
--
-- High selectivity -> Index Scan / Bitmap Scan may be useful
-- Low selectivity  -> Sequential Scan may be cheaper
--
-- There is no fixed percentage threshold.
-- PostgreSQL decides based on estimated cost.


-- =========================================================
-- 6. PRIMARY KEY INDEX
-- =========================================================

explain analyze
select *
from test_orders_large
where order_id = 10000;


-- order_id is a PRIMARY KEY.
-- PostgreSQL automatically creates an index for the primary key.
--
-- Since only one row can match, an Index Scan is highly efficient.


-- =========================================================
-- 7. COMPOSITE INDEX
-- =========================================================

create index idx_test_orders_large_customer_date
on test_orders_large (customer_id, order_date);


-- This index is useful for queries filtering by:
--
-- customer_id
-- customer_id + order_date
--
-- Example:

explain analyze
select *
from test_orders_large
where customer_id = 1
  and order_date = '2025-06-15';


-- =========================================================
-- 8. LEFTMOST PREFIX RULE
-- =========================================================

-- The composite index is:
--
-- (customer_id, order_date)
--
-- Therefore this query can use the index efficiently:

select *
from test_orders_large
where customer_id = 1;


-- And this query can also use it:

select *
from test_orders_large
where customer_id = 1
  and order_date = '2025-06-15';


-- But a query filtering only by order_date generally
-- cannot efficiently use this composite index:

explain analyze
select *
from test_orders_large
where order_date = '2025-06-15';


-- Leftmost prefix rule:
--
-- (A, B, C)
--
-- Good for:
-- A
-- A + B
-- A + B + C
--
-- Generally not useful for:
-- B
-- C
-- B + C


-- =========================================================
-- 9. KEY TAKEAWAYS
-- =========================================================

-- 1. EXPLAIN shows the estimated execution plan.
--
-- 2. EXPLAIN ANALYZE executes the query and shows
--    actual execution statistics.
--
-- 3. Seq Scan reads the table sequentially.
--
-- 4. Index Scan uses an index to locate rows.
--
-- 5. Bitmap Scan can be useful when multiple rows match.
--
-- 6. Indexes are not automatically used.
--
-- 7. Selectivity strongly influences the planner's decision.
--
-- 8. Primary keys automatically have an index.
--
-- 9. Composite indexes depend on column order.
--
-- 10. Index design should be based on real query patterns.