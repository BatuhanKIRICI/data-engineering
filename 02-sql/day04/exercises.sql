-- ============================================================
-- Day 4 — Database Design & Data Warehouse (Star Schema)
-- ============================================================

-- ------------------------------------------------------------
-- 1. SCHEMA: Dimension tables + Fact table
-- ------------------------------------------------------------

create table dim_customer (
    customer_id int primary key,
    customer_name varchar(100),
    city varchar(100),
    country varchar(100)
);

create table dim_product (
    product_id int primary key,
    product_name varchar(100),
    category varchar(100),
    brand varchar(100)
);

create table dim_date (
    date_id int primary key,      -- integer format (YYYYMMDD) chosen over date type
    full_date date,               -- for faster joins / smaller index size
    day int,
    month int,
    quarter int,
    year int
);

create table fact_sales (
    sale_id int primary key,
    customer_id int references dim_customer(customer_id),
    product_id int references dim_product(product_id),
    date_id int references dim_date(date_id),
    quantity int,
    unit_price decimal(10, 2),    -- kept here, not in dim_product:
    total_amount decimal(10, 2)   -- prices change over time, fact table
                                   -- should reflect price at time of sale
);

-- ------------------------------------------------------------
-- 2. SEED DATA
-- ------------------------------------------------------------

insert into dim_customer (customer_id, customer_name, city, country)
values
    (1, 'Ali', 'Berlin', 'Germany'),
    (2, 'Anna', 'Mainz', 'Germany'),
    (3, 'John', 'New York', 'USA'),
    (4, 'Maria', 'Munich', 'Germany');

insert into dim_product (product_id, product_name, category, brand)
values
    (1, 'Laptop', 'Electronics', 'Lenovo'),
    (2, 'Mouse', 'Electronics', 'Logitech'),
    (3, 'Keyboard', 'Electronics', 'Logitech'),
    (4, 'Monitor', 'Electronics', 'Dell'),
    (5, 'Office Chair', 'Furniture', 'IKEA');

insert into dim_date (date_id, full_date, day, month, quarter, year)
values
    (20260901, '2026-09-01', 1, 9, 3, 2026),
    (20260902, '2026-09-02', 2, 9, 3, 2026),
    (20260903, '2026-09-03', 3, 9, 3, 2026),
    (20260904, '2026-09-04', 4, 9, 3, 2026),
    (20260905, '2026-09-05', 5, 9, 3, 2026),
    (20260906, '2026-09-06', 6, 9, 3, 2026),
    (20260907, '2026-09-07', 7, 9, 3, 2026);

insert into fact_sales
    (sale_id, customer_id, product_id, date_id, quantity, unit_price, total_amount)
values
    (1, 1, 1, 20260907, 2, 800, 1600),
    (2, 2, 2, 20260907, 3, 50, 150),
    (3, 3, 4, 20260906, 1, 300, 300),
    (4, 1, 3, 20260905, 1, 100, 100),
    (5, 4, 5, 20260904, 2, 250, 500);

-- ------------------------------------------------------------
-- 3. QUICK CHECKS
-- ------------------------------------------------------------

select * from dim_customer;
select * from dim_product;
select * from dim_date order by full_date;
select * from fact_sales order by sale_id;

-- ------------------------------------------------------------
-- 4. ANALYTICS QUERIES — fact + dimension joins
-- ------------------------------------------------------------

-- Revenue by city
select
    city,
    sum(total_amount) as revenue
from fact_sales f
join dim_customer c on f.customer_id = c.customer_id
group by city
order by revenue desc;

-- Revenue by category
select
    category,
    sum(total_amount) as revenue
from dim_product dp
join fact_sales fs on dp.product_id = fs.product_id
group by category
order by revenue desc;

-- Revenue by month
-- NOTE: grouping by `month` alone is only safe here because all data
-- is from the same year. With multiple years, this must be
-- `group by year, month` — otherwise different years' same-month
-- revenue would be merged together.
select
    month,
    sum(total_amount) as monthly_revenue
from fact_sales fs
join dim_date dd on fs.date_id = dd.date_id
group by month;

-- ------------------------------------------------------------
-- 5. WINDOW FUNCTIONS — best month per customer
-- ------------------------------------------------------------

-- Step 1: aggregate first (CTE) — customer + month level totals
-- Step 2: rank each customer's months by revenue (window function,
--         does NOT collapse rows like GROUP BY would)
with monthly_total as (
    select
        customer_name,
        month,
        sum(total_amount) as monthly_revenue
    from fact_sales fs
    join dim_customer dc on fs.customer_id = dc.customer_id
    join dim_date dd on fs.date_id = dd.date_id
    group by customer_name, month
)
select
    customer_name,
    month,
    monthly_revenue,
    rank() over (
        partition by customer_name
        order by monthly_revenue desc
    ) as rnk
from monthly_total;

-- ------------------------------------------------------------
-- 6. WINDOW FUNCTIONS — best-selling product per category (by quantity)
-- ------------------------------------------------------------

-- Same pattern: aggregate (sum quantity) BEFORE ranking, otherwise
-- a product sold across multiple orders would be ranked on a single
-- order's quantity instead of its true total.
with quantitative_total as (
    select
        fs.product_id,
        product_name,
        category,
        sum(quantity) as total_quantity,
        rank() over (
            partition by category
            order by sum(quantity) desc
        ) as rnk
    from fact_sales fs
    join dim_product dp on fs.product_id = dp.product_id
    group by fs.product_id, dp.product_name, dp.category
)
select
    product_name,
    category,
    rnk,
    total_quantity
from quantitative_total
where rnk = 1;