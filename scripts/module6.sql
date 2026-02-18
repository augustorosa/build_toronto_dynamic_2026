-- =============================================================================
-- Module 6: Snowflake Badge
-- Purpose: Set up the Autograder and run autograding scripts for your badge
-- Source: https://github.com/Snowflake-Labs/builder-workshops
-- =============================================================================

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- STEP 1: Set Up the Autograder
--
-- Open a NEW SQL Worksheet in Snowsight (the Snowflake account you used for
-- this workshop). Name it "autograder-setup.sql".
-- Copy everything between the BEGIN / END markers below and paste it in.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- ===== BEGIN: Autograder Setup Script =====

--!jinja
use role accountadmin;

-- Create the API integration that connects to the Snowflake grading service
create or replace api integration dora_api_integration
api_provider = aws_api_gateway
api_aws_role_arn = 'arn:aws:iam::321463406630:role/snowflakeLearnerAssumedRole'
enabled = true
api_allowed_prefixes = ('https://awy6hshxy4.execute-api.us-west-2.amazonaws.com/dev/edu_dora');

-- Create the utility database (if it doesn't exist) and switch to it
create database if not exists util_db;
use database util_db;
use schema public;

-- Create the grader function that sends your results to the grading service
create or replace external function util_db.public.grader(
step varchar
, passed boolean
, actual integer
, expected integer
, description varchar)
returns variant
api_integration = dora_api_integration
context_headers = (current_timestamp,current_account, current_statement, current_account_name)
as 'https://awy6hshxy4.execute-api.us-west-2.amazonaws.com/dev/edu_dora/grader'
;

-- Verify the grader is working (you should see a success message)
select grader(step, (actual = expected), actual, expected, description) as graded_results from (SELECT
'AUTO_GRADER_IS_WORKING' as step
,(select 123) as actual
,123 as expected
,'The Snowflake auto-grader has been successfully set up in your account!' as description
);

-- Create the greeting function (used to register you for the badge)
create or replace external function util_db.public.greeting(
email varchar
, firstname varchar
, middlename varchar
, lastname varchar)
returns variant
api_integration = dora_api_integration
context_headers = (current_timestamp, current_account, current_statement, current_account_name)
as 'https://awy6hshxy4.execute-api.us-west-2.amazonaws.com/dev/edu_dora/greeting'
;

-- ===== END: Autograder Setup Script =====


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- STEP 2: Register Your Name and Email
--
-- IMPORTANT: Fill in YOUR details in the greeting function below, then run it.
-- Read the naming guidelines carefully before running!
--
-- GUIDELINES:
--   - Use the SAME email you registered for the event with.
--   - Do NOT use all capital letters.
--   - Do NOT use all lowercase letters.
--   - Do NOT use CamelCase — put spaces between words in your name.
--   - You MUST include both a first and last name.
--   - Middle name is optional — use '' (empty string) if you don't have one.
--   - Do NOT use "null" in place of any value.
--   - Single-character names: add a trailing space (e.g., 'A ').
--   - Accented characters and non-English letters are allowed.
--
-- EXAMPLES:
--   No middle name:
--     select util_db.public.greeting('myemail@email.com', 'Snowflake', '', 'Bear');
--   With middle name:
--     select util_db.public.greeting('myemail@email.com', 'Snowflake', 'The', 'Bear');
--   Accented name:
--     select util_db.public.greeting('myemail@email.com', 'Snowflake', 'O''Brien', 'Bear');
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- >>> REPLACE the placeholders below with your actual info, then run this line:
-- Example: select util_db.public.greeting('mail@mail.com', 'Augusto', '', 'Rosa');

select util_db.public.greeting('YOUR_EMAIL', 'YOUR_FIRST_NAME', 'YOUR_MIDDLE_NAME_OR_EMPTY', 'YOUR_LAST_NAME');


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- STEP 3: Run the Autograding Scripts
--
-- After the autograder and greeting are set up:
--   1. Open a NEW SQL Worksheet in Snowsight. Name it "autograding.sql".
--   2. Copy the grading script below into the worksheet.
--   3. Run each statement ONE AT A TIME (do NOT use "Run All").
--   4. Each grader call returns a result — look for success messages.
--   5. After all statements pass, you will receive your badge via email
--      (allow up to 7 business days).
--
-- If a grading statement fails, go back and fix the corresponding module
-- before re-running.
--
-- Source: https://github.com/Snowflake-Labs/builder-workshops/blob/main/data-eng/ingestion-transformation-delivery.sql
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- ===== BEGIN: Autograding Script (Data Engineering) =====

use role accountadmin;
use database util_db;
use schema public;

select util_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from (SELECT
 'BWDT01' as step
 , (select count(*) from snowflake.information_schema.databases 
   where database_name in ('RAW_DB', 'ANALYTICS_DB')) as actual
 , 2 as expected
 ,'All databases was created successfully!' as description
);

select util_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from (SELECT
 'BWDT02' as step
 , (select count(*) from raw_db.information_schema.functions where function_name in ('GEN_CUST_INFO', 'GEN_PROD_INV', 'GEN_CUST_PURCHASE')) as actual
 , 3 as expected
 ,'Created 3 Python UDTF successfully!' as description
);

select util_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from (SELECT
 'BWDT03' as step
 , (select count(*) from raw_db.information_schema.tables where table_name in ('CUSTOMERS', 'PRODUCTS', 'ORDERS')) as actual
 , 3 as expected
 ,'All tables were created successfully with data!' as description
);

select util_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from (SELECT
 'BWDT04' as step
 , (select count(*) from analytics_db.information_schema.tables where table_name = 'STG_CUSTOMERS_DT') as actual
 , 1 as expected
 ,'First Dynamic Table were created successfully!' as description
);

select util_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from (SELECT
 'BWDT05' as step
 , (select count(*) from analytics_db.information_schema.tables where table_name = 'STG_ORDERS_DT') as actual
 , 1 as expected
 ,'Second Dynamic Table were created successfully!' as description
);

select util_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from (SELECT
 'BWDT06' as step
 , (select count(*) from analytics_db.information_schema.tables where table_name = 'FCT_CUSTOMER_ORDERS_DT') as actual
 , 1 as expected
 ,'Fact Dynamic Table were created successfully!' as description
);

select util_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from (SELECT
 'BWDT07' as step
 , (select count(*) from analytics_db.public.fct_customer_orders_dt where product_id is null) as actual
 , 0 as expected
 ,'Data quality was integrated successfully!' as description
);

SELECT 'You\'ve successfully completed Build 2025\'s DE lab!' as STATUS;

-- ===== END: Autograding Script (Data Engineering) =====
