# How To Complete the Snowflake Dynamic Tables Workshop (Build Toronto 2026)

This guide walks you through building a data pipeline using Snowflake Dynamic Tables — from account setup to pipeline monitoring and AI exploration. Each module builds on the previous one, so complete them in order.

## Prerequisites

- Access to a computer with a stable internet connection
- A valid and accessible email address
- A modern web browser (Chrome, Firefox, Safari, or Edge)
- Permission to download and manage files on your device

---

## Module 1: Setting Up

**File:** `scripts/module1.sql`
**Snowflake Workspace Name:** `setup.sql`

### Purpose

Create your Snowflake trial account and set up the warehouse, databases, and sample data tables needed for the rest of the workshop.

### Part A: Sign Up for a Snowflake Trial Account

1. Visit [mlh.link/snowflake-de-trial](https://mlh.link/snowflake-de-trial).
2. Fill out all the information and select **"Personal learning and development"**.
3. On the next page, enter your personal details (company name and role can be fictional).
4. Choose the **Standard** edition (it includes all AI/ML features at $2/credit so your trial credits stretch further, but any edition works).
5. Verify your cloud provider and region are set to **AWS** and **US West (Oregon)**. If not, select them manually.
6. Complete the optional pages if desired.
7. Check your email and **activate your account**.
8. Set up your user credentials for your new Snowflake account.
9. Leave the Snowflake page open — you're ready to continue.

### Part B: Run the Setup Script

1. In Snowsight, go to **Projects** > **My Workspace**.
2. Click **"+ Add new"** and select **"SQL File"**. Name it `setup.sql`.
3. Open the GitHub repo at [mlh.link/snowflake-de-data](https://mlh.link/snowflake-de-data), copy the contents of `setup.sql`, and paste them into your workspace file. Alternatively, copy the contents from `scripts/module1.sql` in this repo.
4. Click **"Run All"** to execute the entire script.
5. You should see: **"Congratulations! Snowflake Data Engineering workshop setup has completed successfully!"**
6. Go back and run lines for previewing data (the `SELECT` statements near the bottom) to see the sample data in each table: **CUSTOMERS**, **PRODUCTS**, and **ORDERS**.
7. Verify by going to **Catalog** and checking for **RAW_DB > PUBLIC** — you should see three tables and three functions.

### Expected Results

| Object | Count |
|--------|-------|
| Tables (CUSTOMERS, PRODUCTS, ORDERS) | 3 |
| Functions (gen_cust_info, gen_prod_inv, gen_cust_purchase) | 3 |
| Customer records | 1,000 |
| Product records | 100 |
| Order records | 10,000 |

### Troubleshooting

- **"Run All" fails:** Make sure you are using the `ACCOUNTADMIN` role. Check the first line of the script.
- **Tables not appearing in Catalog:** Refresh the Catalog page. It may take a few seconds for new objects to appear.
- **UDTF errors:** Ensure your Snowflake edition supports Python UDTFs (Standard edition and above).

---

## Module 2: Dynamic Tables

**File:** `scripts/module2.sql`
**Snowflake Workspace Name:** `create-dt.sql`

### Purpose

Create staging Dynamic Tables that apply light transformations (column renaming, type casting, JSON unpacking) to the raw data.

### Steps

1. In Snowsight, click **"+ Add new"** > **"SQL File"**. Name it `create-dt.sql`.
2. Copy the contents of `scripts/module2.sql` into the file, or type the SQL manually.
3. Run the first three lines to set your role, warehouse, and database:
   ```sql
   use role accountadmin;
   use warehouse compute_wh;
   use database analytics_db;
   ```
4. Run the `DESC TABLE` and `SELECT *` for the **customers** table to inspect the raw data and identify transformation opportunities.
5. Run the `CREATE OR REPLACE DYNAMIC TABLE stg_customers_dt` statement. This renames columns (`custid` → `customer_id`, `cname` → `customer_name`) and casts `spendlimit` to float.
6. Run the `DESC TABLE` and `SELECT *` for the **orders** table. Notice the `purchase` column holds JSON data.
7. Run the `CREATE OR REPLACE DYNAMIC TABLE stg_orders_dt` statement. This unpacks JSON fields using the format `COLUMN:"VAR_NAME"::TYPE as NEW_COL_NAME`.
8. Query both new Dynamic Tables to verify the transformations:
   ```sql
   select * from analytics_db.public.stg_customers_dt;
   select * from analytics_db.public.stg_orders_dt;
   ```
9. Run `SHOW DYNAMIC TABLES;` — scroll right to find the **TARGET_LAG** column. It should say **DOWNSTREAM**, meaning these tables refresh when downstream tables change.
10. Optionally, go to **Catalog** to see the two new Dynamic Tables listed.

### Expected Results

- **stg_customers_dt** has columns: `customer_id`, `customer_name`, `spend_limit`
- **stg_orders_dt** has columns: `customer_id`, `product_id`, `order_price`, `quantity`, `order_date`
- Both tables show `TARGET_LAG = DOWNSTREAM`

### Troubleshooting

- **Dynamic Table not appearing:** Make sure you're connected to `analytics_db`. Dynamic Tables are created in the current database context.
- **JSON unpacking errors:** Ensure the column reference format is exact: `purchase:"prodid"::number(5)` (with double quotes around the JSON key).

---

## Module 3: Chaining Dynamic Tables

**File:** `scripts/module3.sql`
**Snowflake Workspace Name:** `chaining-dt.sql`

### Purpose

Create a Fact Dynamic Table by joining the upstream staging tables. Snowflake automatically discovers the dependency chain.

### Steps

1. Click **"+ Add new"** > **"SQL File"**. Name it `chaining-dt.sql`.
2. Copy the contents of `scripts/module3.sql` into the file.
3. Run the role/warehouse/database setup lines.
4. Query both staging tables to decide which columns to carry into the Fact Table:
   ```sql
   select * from analytics_db.public.stg_customers_dt;
   select * from analytics_db.public.stg_orders_dt;
   ```
5. Run the `CREATE OR REPLACE DYNAMIC TABLE fct_customer_orders_dt` statement. This joins `stg_customers_dt` and `stg_orders_dt` on `customer_id`. Snowflake automatically detects the upstream dependency — no manual configuration needed.
6. Query the new Fact Dynamic Table:
   ```sql
   select * from analytics_db.public.fct_customer_orders_dt;
   ```

### Visualize the Pipeline

7. Navigate to **Catalog** and under **Dynamic Table**, select **FCT_CUSTOMER_ORDERS_DT**.
8. Click **"Graph"**. You should see a visual DAG (Directed Acyclic Graph):
   **Raw Tables → Staging Dynamic Tables → Fact Dynamic Table**
   Use the **+** button to zoom out if needed.

### Expected Results

- **fct_customer_orders_dt** has columns: `customer_id`, `customer_name`, `product_id`, `order_price`, `quantity`, `order_date`
- The Graph view shows the full pipeline lineage

### Troubleshooting

- **Fact table is empty:** Ensure Module 2 was completed successfully and the staging tables have data.
- **Graph not showing:** Make sure you selected the correct Dynamic Table in the Catalog. Click the "Graph" tab (not "Data Preview").

---

## Module 4: Pipeline Monitoring

**File:** `scripts/module4.sql`
**Snowflake Workspace Name:** `pipeline.sql`

### Purpose

Monitor pipeline health, adjust refresh cadence, and enforce data quality rules on your Dynamic Tables.

### Steps

1. Click **"+ Add new"** > **"SQL File"**. Name it `pipeline.sql`.
2. Copy the contents of `scripts/module4.sql` into the file.
3. Run the role/warehouse/database setup lines.
4. Run `SHOW DYNAMIC TABLES;` to confirm all tables currently have `TARGET_LAG = DOWNSTREAM`.
5. Adjust the freshness for the orders staging table:
   ```sql
   alter dynamic table stg_orders_dt set target_lag = '5 minutes';
   ```
   Any downstream tables will automatically adjust since they refresh when upstream changes occur.
6. Run `SHOW DYNAMIC TABLES;` again to verify the new `TARGET_LAG` is **5 minutes** for `stg_orders_dt`.
7. Monitor pipeline health with the refresh history:
   ```sql
   select * from table(information_schema.dynamic_table_refresh_history());
   ```
   This shows execution times, data changes, and potential errors.
8. Query the Fact Dynamic Table and look for rows where `PRODUCT_ID` is null (this can happen if a customer exists but hasn't purchased anything):
   ```sql
   select * from analytics_db.public.fct_customer_orders_dt;
   ```
9. Enforce data quality by recreating the Fact Dynamic Table with a `WHERE` clause that filters out null orders. Run the second `CREATE OR REPLACE DYNAMIC TABLE fct_customer_orders_dt` statement (the one with `where o.product_id is not null`).
10. Query the Fact Table again to confirm null orders are removed.

### Pipeline Management in Snowsight

11. Navigate to **Catalog** and under **Dynamic Table**, select **FCT_CUSTOMER_ORDERS_DT**.
12. Click **"Refresh History"**. You should see a table showing when the Dynamic Table was refreshed and the status of each refresh.

### Expected Results

- `stg_orders_dt` TARGET_LAG changes from DOWNSTREAM to 5 MINUTES
- Refresh history shows recent pipeline executions
- After data quality enforcement, no rows with null `product_id` remain

### Troubleshooting

- **Refresh history is empty:** The table may not have been refreshed yet. Wait a few minutes and query again.
- **Null rows still showing:** Make sure you ran the updated `CREATE OR REPLACE` statement (with the `WHERE` clause), not the original from Module 3.

---

## Module 5: Snowflake Intelligence

**File:** `scripts/module5.sql` (instructions only — no SQL to execute)

### Purpose

Explore Snowflake's AI/ML capabilities using Cortex Playground to ask natural language questions about your data.

### Resources

- [Snowflake Intelligence Overview](https://docs.snowflake.com/en/user-guide/snowflake-intelligence)
- [Snowflake Cortex Agents](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
- [Snowflake Cortex Analyst](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
- [Snowflake Cortex Search](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search)
- [Understanding Snowflake Cortex](https://docs.snowflake.com/en/user-guide/snowflake-cortex/overview)
- [Tutorial: Getting Started with Snowflake Intelligence](https://docs.snowflake.com/en/user-guide/snowflake-intelligence/tutorials)

### Steps

1. In Snowsight, navigate to the **"AI/ML"** section.
2. Go to **"Studio"** to open the **Snowflake AI & ML Studio**.
3. Find **Cortex Playground** and click **"Try"**.

   > **Note:** Cortex Playground does not directly support Dynamic Tables. To use Dynamic Tables with AI, you would need to leverage Cortex Search and create a custom Agent — explore this further on your own if interested.

4. Click **"Connect your data"**.
5. Select **RAW_DB.PUBLIC.ORDERS** as your Data Source, then click **"Let's go"**.
6. Select **"PURCHASE"** as the column, then click **"Next"**.
7. Select **"CUSTID"** as the filter column, then click **"Done"**.
8. Pick any **CUSTID** to scope the AI to that customer's orders.
9. Ask the AI a question, such as: **"What is this purchase about?"**

### Expected Results

- The AI responds with a natural language summary of the selected customer's purchase data.

### Troubleshooting

- **Cortex Playground not available:** Ensure your Snowflake edition supports AI/ML features (Standard edition and above).
- **No data returned:** Verify the ORDERS table has data by running `select * from raw_db.public.orders limit 10;` in a worksheet.

---

## Module 6: Snowflake Badge

**File:** `scripts/module6.sql` (instructions only — no SQL to execute)

### Purpose

Earn your Snowflake workshop badge by setting up the Autograder and running the grading scripts.

### Steps

1. Follow the Autograder setup instructions at: [mlh.link/snowflake-autograder](https://mlh.link/snowflake-autograder)
2. After setup is complete, go to: [mlh.link/snowflake-autograding-scripts](https://mlh.link/snowflake-autograding-scripts)
3. Open the `snowflake-intelligence.sql` script.
4. Run the script **step by step** (not all at once) to complete the autograding process.

### Expected Results

- The autograder validates your workshop setup and awards you a badge upon successful completion.

### Troubleshooting

- **Autograder setup fails:** Double-check that all previous modules (1–5) have been completed successfully before running the grading scripts.
- **Grading script errors:** Run each statement one at a time to identify which step fails. Ensure the required tables and Dynamic Tables exist in the correct databases.

---

## File Summary

| File | Snowflake Workspace Name | Description |
|------|--------------------------|-------------|
| `scripts/module1.sql` | `setup.sql` | Account setup: warehouse, databases, UDTFs, sample tables |
| `scripts/module2.sql` | `create-dt.sql` | Staging Dynamic Tables with column renaming, casting, JSON unpacking |
| `scripts/module3.sql` | `chaining-dt.sql` | Fact Dynamic Table joining upstream staging tables |
| `scripts/module4.sql` | `pipeline.sql` | Pipeline monitoring, freshness tuning, data quality enforcement |
| `scripts/module5.sql` | *(UI-only)* | Snowflake Intelligence / Cortex Playground exploration |
| `scripts/module6.sql` | *(UI-only)* | Autograder setup and badge grading |

## Additional Information

- **Dynamic Tables** automatically refresh based on their `target_lag` setting. `DOWNSTREAM` means they refresh when a downstream consumer needs fresh data.
- **Pipeline lineage** can be visualized in the Catalog under any Dynamic Table's "Graph" tab.
- **Refresh History** (Catalog > Dynamic Table > Refresh History) provides built-in observability without any additional tooling.
- All workshop data is synthetic — generated by Python UDTFs using the Faker library.
