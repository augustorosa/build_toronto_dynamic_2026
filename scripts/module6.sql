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

USE ROLE accountadmin;
USE WAREHOUSE compute_wh;
USE DATABASE tasty_bytes;

-- Test 1: TASTY_BYTES database exists
select util_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from (SELECT
 'BWITD01' as step
 ,(SELECT COUNT(*) FROM INFORMATION_SCHEMA.DATABASES WHERE DATABASE_NAME = 'TASTY_BYTES') as actual
 , 1 as expected
 ,'TASTY_BYTES database successfully created!' as description
);

-- Test 2: Country table loaded with 30 rows
select util_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from (SELECT
 'BWITD02' as step
 ,(SELECT COUNT(*) FROM tasty_bytes.raw_pos.country) as actual
 , 30 as expected
 ,'Data successfully copied into the country table!' as description
);

-- Test 3: WINDSPEED_HAMBURG view exists
select util_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from (SELECT
 'BWITD03' as step
 ,(SELECT COUNT(*) FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'WINDSPEED_HAMBURG' AND TABLE_SCHEMA = 'HARMONIZED' AND TABLE_CATALOG = 'TASTY_BYTES') as actual
 , 1 as expected
 ,'WINDSPEED_HAMBURG view successfully created and contains correct data!' as description
);

-- Test 4: fahrenheit_to_celsius and inch_to_millimeter UDFs exist
select util_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from (SELECT
 'BWITD04' as step
 ,(SELECT COUNT(*) FROM INFORMATION_SCHEMA.FUNCTIONS WHERE FUNCTION_NAME IN ('FAHRENHEIT_TO_CELSIUS', 'INCH_TO_MILLIMETER') AND FUNCTION_SCHEMA = 'ANALYTICS' AND FUNCTION_CATALOG = 'TASTY_BYTES') as actual
 , 2 as expected
 ,'fahrenheit_to_celsius and inch_to_millimeter UDFs successfully created!' as description
);

-- Test 5: WEATHER_HAMBURG view exists
select util_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from (SELECT
 'BWITD05' as step
 ,(SELECT COUNT(*) FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'WEATHER_HAMBURG' AND TABLE_SCHEMA = 'HARMONIZED' AND TABLE_CATALOG = 'TASTY_BYTES') as actual
 , 1 as expected
 ,'WEATHER_HAMBURG view successfully created and contains correct data!' as description
);

-- Test 6: HAMBURG_GERMANY_TRENDS Streamlit app exists
select util_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from (SELECT
 'BWITD06' as step
 ,(SELECT COUNT(*) FROM INFORMATION_SCHEMA.STREAMLITS WHERE STREAMLIT_TITLE = 'HAMBURG_GERMANY_TRENDS' AND STREAMLIT_CATALOG = 'TASTY_BYTES' AND STREAMLIT_SCHEMA = 'HARMONIZED') as actual
 , 1 as expected
 ,'HAMBURG_GERMANY_TRENDS Streamlit app created and run successfully!' as description
);

-- Final confirmation
SELECT 'Congratulations! You have successfully completed the Snowflake Northstar - Data Engineering workshop!' as STATUS;

-- ===== END: Autograding Script (Data Engineering) =====
