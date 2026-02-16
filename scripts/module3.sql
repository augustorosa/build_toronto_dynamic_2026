-- =============================================================================
-- Module 3: Chaining Dynamic Tables
-- File: chaining-dt.sql (in Snowflake workspace)
-- Purpose: Create a Fact Dynamic Table by joining upstream staging tables
-- =============================================================================

-- select the account, warehouse, and database you are using
use role accountadmin;
use warehouse compute_wh;
use database analytics_db;

-- check the values in each staging Dynamic Table to decide what columns
-- you want to carry over into the Fact Table
select * from analytics_db.public.stg_customers_dt;
select * from analytics_db.public.stg_orders_dt;

-- create a Fact Dynamic Table for customer orders.
-- Takes customer_id and customer_name from STG_CUSTOMERS_DT,
-- and product_id, order_price, quantity, order_date from STG_ORDERS_DT.
-- Snowflake automatically discovers the dependency by referencing upstream tables by name.
create or replace dynamic table fct_customer_orders_dt
    target_lag=downstream
    warehouse=compute_wh
    as select
        c.customer_id,
        c.customer_name,
        o.product_id,
        o.order_price,
        o.quantity,
        o.order_date
    from stg_customers_dt c
    left join stg_orders_dt o
        on c.customer_id = o.customer_id;

-- query the new Fact Dynamic Table
select * from analytics_db.public.fct_customer_orders_dt;
