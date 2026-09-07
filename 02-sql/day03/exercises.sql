-- day 3: postgresql fundamentals
-- topics:
-- primary key
-- foreign key
-- constraints
-- indexes
-- explain
-- transactions


-- 1. primary key
-- customer_id uniquely identifies each customer.

create table test_customers (
    customer_id int primary key,
    customer_name varchar(50)
);


-- 2. foreign key
-- customer_id in test_orders references test_customers.

create table test_orders (
    order_id int primary key,
    customer_id int references test_customers(customer_id),
    amount decimal(10,2)
);


-- 3. constraints
-- examples:
-- not null
-- unique
-- check
-- default

-- example:
-- amount decimal(10,2) check (amount > 0)


-- 4. index
-- an index helps PostgreSQL find rows efficiently.

create index idx_test_orders_customer_id
on test_orders (customer_id);


-- 5. explain
-- PostgreSQL shows how it plans to execute a query.

explain
select *
from test_orders
where customer_id = 1;


-- 6. index scan
-- primary key index can be used to find a specific row.

explain
select *
from test_orders
where order_id = 10000;


-- 7. transaction: rollback
-- changes inside the transaction are reverted.

begin;

insert into test_orders (order_id, customer_id, amount)
values (20000, 1, 500);

rollback;


-- 8. transaction: commit
-- changes inside the transaction are permanently saved.

begin;

insert into test_orders (order_id, customer_id, amount)
values (20001, 1, 750);

commit;