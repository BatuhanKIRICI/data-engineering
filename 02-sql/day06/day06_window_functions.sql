-- ============================================================
-- Day 6 — Advanced SQL: Window Functions & Analytical Queries
-- ============================================================

-- ------------------------------------------------------------
-- 1. ROW_NUMBER() — "latest order per customer" pattern
-- ------------------------------------------------------------
-- Classic pattern: pick the top/most-recent row per group.
-- A window function's alias can't be used directly in WHERE
-- (it's evaluated after WHERE runs), so the ranked query is
-- wrapped in a CTE and filtered from the outside.

with ranked_orders as (
    select
        customer_id,
        date_id,
        total_amount,
        row_number() over (
            partition by customer_id
            order by date_id desc  -- newest date first -> rn=1 is the latest order
        ) as rn
    from fact_sales
)
select *
from ranked_orders
where rn = 1;

-- ------------------------------------------------------------
-- 2. ROW_NUMBER() vs RANK() — behavior on ties
-- ------------------------------------------------------------
-- With no PARTITION BY, the whole table is treated as a single
-- group. With all-distinct amounts, ROW_NUMBER and RANK give
-- identical results -- the difference only shows up on ties.

select
    customer_id,
    total_amount,
    row_number() over (order by total_amount desc) as rn,
    rank() over (order by total_amount desc) as rnk
from fact_sales;

-- Controlled experiment: force a tie using a temporary table
-- (kept separate so the real fact_sales table isn't touched).

create temporary table rank_test as
select * from fact_sales;

insert into rank_test
    (sale_id, customer_id, product_id, date_id, quantity, unit_price, total_amount)
values
    (6, 2, 1, 20260907, 1, 500, 500);  -- duplicate amount (500) on purpose

select
    customer_id,
    total_amount,
    row_number() over (order by total_amount desc) as rn,
    rank() over (order by total_amount desc) as rnk,
    dense_rank() over (order by total_amount desc) as dense_rnk
from rank_test;

-- Result with a tie at 500:
-- ROW_NUMBER: 1, 2, 3, 4, 5, 6      (never repeats)
-- RANK:       1, 2, 2, 4, 5, 6      (ties share a rank, next rank is skipped)
-- DENSE_RANK: 1, 2, 2, 3, 4, 5      (ties share a rank, nothing is skipped)

-- ------------------------------------------------------------
-- 3. LAG() — compare each order to the PREVIOUS one
-- ------------------------------------------------------------
-- ASC is used here because we want "previous" to mean
-- the previous order chronologically (oldest -> newest).

with with_previous as (
    select
        customer_id,
        total_amount,
        lag(total_amount) over (
            partition by customer_id
            order by date_id asc
        ) as previous_amount
    from fact_sales
)
select
    customer_id,
    total_amount,
    previous_amount,
    (total_amount - previous_amount) as change
from with_previous;

-- Note: any_number - NULL = NULL (not the number itself).
-- A customer's first order has no "previous" order, so both
-- previous_amount and change are correctly NULL, not 0.

-- ------------------------------------------------------------
-- 4. LEAD() — compare each order to the NEXT one
-- ------------------------------------------------------------
-- Mirror image of LAG: same ORDER BY direction, but now the
-- LAST order per customer is the one that ends up NULL
-- (no "next" order exists yet).

with next_orders as (
    select
        customer_id,
        date_id,
        total_amount,
        lead(total_amount) over (
            partition by customer_id
            order by date_id asc
        ) as next_amount
    from fact_sales
)
select
    customer_id,
    date_id,
    total_amount,
    next_amount,
    (next_amount - total_amount) as change_to_next
from next_orders;

-- ------------------------------------------------------------
-- 5. FINAL: LAG + LEAD together, per customer
-- ------------------------------------------------------------
-- Combines everything above: previous AND next order amount,
-- side by side, in one query.

with with_next_and_prev as (
    select
        customer_id,
        date_id,
        total_amount,
        lag(total_amount) over (
            partition by customer_id
            order by date_id asc
        ) as previous_amount,
        lead(total_amount) over (
            partition by customer_id
            order by date_id asc
        ) as next_amount
    from fact_sales
)
select
    customer_id,
    date_id,
    total_amount,
    previous_amount,
    next_amount
from with_next_and_prev;

-- ------------------------------------------------------------
-- 6. KEY TAKEAWAYS
-- ------------------------------------------------------------
-- 1. ROW_NUMBER / RANK / DENSE_RANK only differ from each
--    other when there are tied values to rank.
-- 2. RANK leaves gaps after a tie (1,2,2,4); DENSE_RANK
--    doesn't (1,2,2,3).
-- 3. LAG looks backward, LEAD looks forward.
--    ORDER BY defines what "previous"/"next" means.
--    PARTITION BY is used when the calculation should restart
--    independently for each group, such as each customer.
-- 4. NULL propagates through arithmetic: number - NULL = NULL,
--    which is the correct (not zero) result for "no previous
--    order exists yet."
-- 5. A window function's output can't be filtered in WHERE
--    directly -- wrap it in a CTE and filter in the outer query.
