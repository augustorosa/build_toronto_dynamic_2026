-- =============================================================================
-- Module 4: Pipeline Monitoring
-- File: pipeline.sql (in Snowflake workspace)
-- Purpose: Monitor, adjust freshness, and enforce data quality on the pipeline
-- =============================================================================

-- select the account, warehouse, and database you are using
use role accountadmin;
use warehouse compute_wh;
use database analytics_db;

-- display all Dynamic Tables. Confirm TARGET_LAG is currently DOWNSTREAM.
show dynamic tables;

-- adjust the freshness (TARGET_LAG) for STG_ORDERS_DT to 5 minutes.
-- Any downstream tables will automatically adjust to this new cadence,
-- since they update whenever changes occur upstream.
alter dynamic table stg_orders_dt set target_lag = '5 minutes';

-- verify the altered Dynamic Table's new TARGET_LAG (should now say 5 minutes)
show dynamic tables;

-- monitor pipeline health: inspect the history of refreshes,
-- showing execution times, data changes, and potential errors.
-- This is your built-in observability tool in SQL.
select * from table(information_schema.dynamic_table_refresh_history());

-- query the Fact Dynamic Table and check for potential issues.
-- Look for null PRODUCT_ID values — this can happen if a customer
-- exists but hasn't made a purchase yet.
select * from analytics_db.public.fct_customer_orders_dt;

-- enforce data quality: recreate the Fact Dynamic Table to filter out null orders.
-- The WHERE clause removes rows where product_id is null.
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
        on c.customer_id = o.customer_id
    where o.product_id is not null;

-- verify data quality enforcement — null orders should be gone
select * from analytics_db.public.fct_customer_orders_dt;
