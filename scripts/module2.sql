-- =============================================================================
-- Module 2: Dynamic Tables
-- File: create-dt.sql (in Snowflake workspace)
-- Purpose: Create staging Dynamic Tables with light transformations
-- =============================================================================

-- select the account, warehouse, and database you are using
use role accountadmin;
use warehouse compute_wh;
use database analytics_db;

-- display what type of data and example data in the customers table. 
-- The goal here is to identify columns that we can perform light transformations like renaming columns and basic type casting
desc table raw_db.public.customers;
select * from raw_db.public.customers;

-- Dynamic Table for CUSTOMERS table with the transformations that we selected
create or replace dynamic table stg_customers_dt
    target_lag=downstream
    warehouse=compute_wh
    as select
        custid as customer_id,
        cname as customer_name,
        cast(spendlimit as float) as spend_limit
    from raw_db.public.customers;

-- display what type of data and example data in the orders table
desc table raw_db.public.orders;
select* from raw_db.public.orders;

-- create a dynamic table for orders table. Note the unpacking of the JSON. 
-- The following format is used COLUMN:”VAR_NAME”::TYPE_CASE as NEW_COL_NAME
create or replace dynamic table stg_orders_dt
   target_lag=downstream
   warehouse=compute_wh
   as select
       custid as customer_id,
       purchase:"prodid"::number(5) as product_id,
       purchase:"purchase_amount"::float(10) as order_price,
       purchase:"quantity"::number(5) as quantity,
       purchase:"purchase_date"::date as order_date
   from raw_db.public.orders;

-- query the new Dynamic Tables that you created. You should see the new columns.
select * from analytics_db.public.stg_customers_dt;
select * from analytics_db.public.stg_orders_dt;

-- display all Dynamic Tables created. Scroll right to find TARGET_LAG.
-- It should say DOWNSTREAM, meaning the tables refresh when downstream tables change.
-- You can also check "Catalog" in Snowsight to see the two new Dynamic Tables.
show dynamic tables;

