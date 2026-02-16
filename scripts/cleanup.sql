-- =============================================================================
-- Cleanup: Reset Snowflake Account to Zero
-- File: cleanup.sql (paste this into a Snowflake worksheet)
-- Purpose: Drop all objects created during the workshop (Modules 1–6)
--
-- WARNING: This script permanently deletes all workshop databases, tables,
--          dynamic tables, functions, the warehouse, and the API integration.
--          Run this ONLY after you have received your badge or no longer need
--          the workshop objects.
--
-- HOW TO USE:
--   1. Open a new SQL Worksheet in Snowsight. Name it "cleanup.sql".
--   2. Copy this entire script into the worksheet.
--   3. Run each section one at a time (top to bottom) to confirm each drop.
--   4. After running everything, your account will be back to its default state.
-- =============================================================================

use role accountadmin;

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 1. Drop Dynamic Tables (Module 2, 3, 4)
--    Drop in reverse dependency order: fact first, then staging.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

drop dynamic table if exists analytics_db.public.fct_customer_orders_dt;
drop dynamic table if exists analytics_db.public.stg_orders_dt;
drop dynamic table if exists analytics_db.public.stg_customers_dt;

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 2. Drop Tables (Module 1)
--    The three raw data tables created by the UDTFs.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

drop table if exists raw_db.public.customers;
drop table if exists raw_db.public.products;
drop table if exists raw_db.public.orders;

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 3. Drop Functions (Module 1)
--    The three Python UDTFs used to generate sample data.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

drop function if exists raw_db.public.gen_cust_info(number);
drop function if exists raw_db.public.gen_prod_inv(number);
drop function if exists raw_db.public.gen_cust_purchase(number, number);

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 4. Drop External Functions and API Integration (Module 6)
--    The autograder and greeting functions, plus the AWS API integration.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

drop function if exists util_db.public.grader(varchar, boolean, integer, integer, varchar);
drop function if exists util_db.public.greeting(varchar, varchar, varchar, varchar);
drop api integration if exists dora_api_integration;

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 5. Drop Databases (Modules 1 and 6)
--    This removes everything inside each database (schemas, tables, functions).
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

drop database if exists raw_db;
drop database if exists analytics_db;
drop database if exists util_db;

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Done! Your account has been reset.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

select 'Cleanup complete. All workshop objects have been removed.' as status;
