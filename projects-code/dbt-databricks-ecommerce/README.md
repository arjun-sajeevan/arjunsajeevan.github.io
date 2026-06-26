# dbt + Databricks: E-Commerce Analytics Warehouse

A complete, end-to-end data engineering project using **dbt** and **Databricks Community Edition** to transform raw, messy e-commerce data into a clean, tested, and documented analytics warehouse.

**Tech Stack:** dbt · Databricks · Delta Lake · SQL · Jinja · hive_metastore

---

## What This Project Demonstrates

| Concept | Implementation |
|---|---|
| Medallion Architecture | Bronze (seeds) → Silver (staging) → Gold (marts) |
| dbt Lineage & DAG | Full `ref()` dependency graph auto-generated |
| Data Testing | 14+ schema tests + 1 custom singular test |
| Documentation | Every model and column documented in YAML |
| Incremental Models | `fct_orders` uses `is_incremental()` for efficiency |
| Reusable Macros | `cents_to_dollars()` Jinja macro |
| Source Freshness | Declared freshness thresholds on all sources |
| SQL Analytics | 3 Databricks SQL notebooks with built-in charts |

---

## Prerequisites

- [Databricks Community Edition account](https://community.cloud.databricks.com/) (free)
- Python 3.8+
- A running Databricks cluster (start one from the Compute tab)

---

## Step 1: Install dbt for Databricks

```bash
pip install dbt-databricks
```

Verify the install:
```bash
dbt --version
```

---

## Step 2: Configure Your Databricks Connection

### Find your cluster HTTP path
1. Go to **Databricks → Compute → your cluster**
2. Click **Advanced Options → JDBC/ODBC tab**
3. Copy the **HTTP Path** (looks like `/sql/protocolv1/o/...`)

### Generate a Personal Access Token
1. Go to **Settings (top right) → Developer → Access Tokens**
2. Click **Generate New Token**
3. Copy the token — you'll only see it once!

### Set up your dbt profile
```bash
# Copy the example profile to ~/.dbt/profiles.yml
cp profiles.yml.example ~/.dbt/profiles.yml
```

Edit `~/.dbt/profiles.yml` and replace the three placeholder values:
```yaml
host: <YOUR_DATABRICKS_HOST>
http_path: <YOUR_CLUSTER_HTTP_PATH>
token: <YOUR_PERSONAL_ACCESS_TOKEN>
```

> ⚠️ **Security:** Never commit your real `profiles.yml` to git. It contains your personal access token. The `.gitignore` in this repo already excludes it.

---

## Step 3: Install dbt Packages

```bash
dbt deps
```

This installs `dbt_utils` from the `packages.yml` file.

---

## Step 4: Test Your Connection

```bash
dbt debug
```

You should see:
```
All checks passed!
```

If you get an error, double-check your HTTP path and token in `~/.dbt/profiles.yml`.

---

## Step 5: Load the Raw Data (Bronze Layer)

```bash
dbt seed
```

This uploads the three CSV files in `seeds/` to Databricks as tables in the `ecommerce_bronze` schema:
- `hive_metastore.ecommerce_bronze.raw_orders` — 31 rows (with quality issues)
- `hive_metastore.ecommerce_bronze.raw_customers` — 11 rows (with duplicates)
- `hive_metastore.ecommerce_bronze.raw_products` — 8 rows (with casing issues)

---

## Step 6: Build All Models (Silver + Gold)

```bash
dbt run
```

dbt will build 7 models in dependency order:
```
1. stg_orders      (Silver — view)
2. stg_customers   (Silver — view)
3. stg_products    (Silver — view)
4. fct_orders      (Gold — incremental table)
5. dim_customers   (Gold — table)
6. dim_products    (Gold — table)
7. monthly_revenue (Gold — table)
```

---

## Step 7: Run All Tests

```bash
dbt test
```

Expected output:
```
Done. PASS=18 WARN=0 ERROR=0 SKIP=0 TOTAL=18
```

The tests include:
- `not_null` and `unique` tests on all primary keys
- `accepted_values` tests on status, payment_method, and category
- `relationships` tests (FK validation) on fct_orders
- 1 custom singular test: `assert_no_negative_quantity`

---

## Step 8: Check Source Freshness

```bash
dbt source freshness
```

In production, this command alerts you when upstream pipelines are delayed.

---

## Step 9: Generate & Explore the Documentation

```bash
dbt docs generate
dbt docs serve
```

Open your browser at [http://localhost:8080](http://localhost:8080) to explore:
- **Interactive DAG** — visualize the full dependency graph
- **Model documentation** — every model and column described
- **Test coverage** — see which columns are tested

---

## Step 10: Run SQL Analytics in Databricks

After `dbt run`, open the **Databricks SQL Editor** and run the queries in the `analytics/` folder:

| Notebook | What It Shows |
|---|---|
| `analytics/revenue_overview.sql` | Monthly revenue trend, payment method breakdown, KPI cards |
| `analytics/product_performance.sql` | Top products, category revenue share, monthly top category |
| `analytics/customer_insights.sql` | Top customers by LTV, orders by country, customer segments |

For each query, click **+ Add Visualization** to create bar charts, line charts, and pie charts directly in Databricks.

---

## Project Structure

```
├── seeds/                    # Bronze: raw CSV files with intentional quality issues
├── models/
│   ├── sources.yml           # Source declarations + freshness config
│   ├── staging/              # Silver: cleaned and typed views
│   └── marts/                # Gold: analytical tables and dimensions
├── macros/                   # Reusable Jinja macros
├── tests/                    # Custom singular tests
├── analytics/                # SQL queries for Databricks SQL Analytics
├── dbt_project.yml           # dbt project config
├── packages.yml              # Package dependencies
└── profiles.yml.example      # Connection template (copy to ~/.dbt/)
```

---

## dbt Commands Reference

| Command | What It Does |
|---|---|
| `dbt debug` | Test connection to Databricks |
| `dbt deps` | Install packages from packages.yml |
| `dbt seed` | Load CSVs into Databricks as raw tables |
| `dbt run` | Build all models |
| `dbt run --select staging` | Build only staging models |
| `dbt run --select fct_orders` | Build a single model |
| `dbt test` | Run all tests |
| `dbt test --select stg_orders` | Test a single model |
| `dbt docs generate` | Generate documentation site |
| `dbt docs serve` | Launch documentation locally |
| `dbt source freshness` | Check source data freshness |

---

## .gitignore

Add these to your `.gitignore` — never commit credentials or compiled output:
```
target/
dbt_packages/
logs/
profiles.yml
```
