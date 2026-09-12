-- day 2: sql fundamentals

-- 1. create orders table
create table orders (
    order_id int,
    customer varchar(50),
    country varchar(2),
    amount decimal(10,2)
);

-- 2. insert orders
insert into orders (order_id, customer, country, amount)
values
(101, 'Ali', 'DE', 120),
(102, 'Anna', 'DE', 80),
(103, 'John', 'US', 200),
(104, 'Ali', 'DE', 50),
(105, 'Maria', 'DE', 300),
(106, 'John', 'US', 100);


-- 3. create customers table
create table customers (
    customer_id int,
    customer varchar(50),
    city varchar(50)
);

-- 4. insert customers
insert into customers (customer_id, customer, city)
values
(1, 'Ali', 'Berlin'),
(2, 'Anna', 'Mainz'),
(3, 'John', 'New York'),
(4, 'Maria', 'Munich');


-- 5. where
select *
from orders
where country = 'DE';


-- 6. order by
select *
from orders
where country = 'DE'
order by amount desc;


-- 7. group by
select
    customer,
    sum(amount) as total_amount
from orders
group by customer;


-- 8. having
select
    customer,
    sum(amount) as total_amount
from orders
group by customer
having sum(amount) > 200;


-- 9. join
select
    o.order_id,
    o.customer,
    o.amount,
    c.city
from orders o
join customers c
    on o.customer = c.customer;


-- 10. join + group by
select
    city,
    sum(o.amount) as total_amount
from orders o
join customers c
    on o.customer = c.customer
group by c.city;


-- 11. case when
select
    order_id,
    amount,
    case
        when amount >= 200 then 'High'
        when amount >= 100 then 'Medium'
        else 'Low'
    end as category
from orders;


-- 12. cte
with total_customer as (
    select
        customer,
        sum(amount) as total_amount
    from orders
    group by customer
)
select
    customer,
    total_amount
from total_customer
where total_amount > 200;


-- 13. window function
select
    customer,
    amount,
    row_number() over (
        partition by customer
        order by amount desc
    ) as order_rank
from orders;


-- 14. final challenge
select
    city,
    sum(o.amount) as total_amount
from orders o
join customers c
    on o.customer = c.customer
group by c.city
having sum(o.amount) > 150
order by total_amount desc;