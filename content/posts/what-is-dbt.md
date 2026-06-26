---
title: "What is dbt and Why Do Companies Use It?"
date: 2026-06-26
draft: false
description: "A clear explanation of dbt (data build tool) — what it does, why it has become a standard in modern data engineering, and what makes it genuinely different from writing raw SQL."
tags: ["dbt", "Data Engineering", "SQL", "Analytics Engineering", "Data Transformation"]
---

If you have spent any time in data engineering recently, you have almost certainly heard of **dbt**. It is on almost every data job description, it is the centrepiece of the modern data stack, and yet a lot of people still cannot give a clear answer to the simple question: *"What does dbt actually do?"*

This post is that clear answer.

---

### The Problem dbt Solves

Before dbt, here is how data transformation typically worked:

A data team had raw data sitting in a data warehouse — messy, unvalidated, inconsistently formatted. They needed to turn it into clean, reliable tables that analysts and dashboards could query.

The solution was usually a collection of SQL scripts. Someone would write `transform_orders.sql`, `clean_customers.sql`, `build_revenue_summary.sql`, and so on. These scripts would be run in a specific order by a cron job, an orchestration tool, or sometimes manually.

This approach works — until it breaks. And it almost always breaks, because:

- **No one knows what order to run the scripts in.** When `revenue_summary.sql` depends on `clean_customers.sql`, which depends on `raw_orders`, you have to track dependencies in your head or in a document nobody reads.
- **There is no testing.** If a script produces wrong results, no one finds out until an analyst notices the numbers are wrong in a dashboard — sometimes weeks later.
- **There is no documentation.** What does `user_flag_3` mean? Nobody knows. The person who wrote it left.
- **Nothing is reusable.** The same `date_format()` logic is duplicated across fifteen files, and when the business logic changes, you have to find and update every one of them.

**dbt was built to fix all of this.**

---

### What dbt Is

dbt stands for **data build tool**. It is an open-source framework that brings software engineering best practices — version control, testing, modularity, documentation — to SQL-based data transformation.

The core idea is simple: **dbt lets you write SQL `SELECT` statements, and it handles the rest.**

You write this:

```sql
-- models/marts/revenue_summary.sql
select
    customer_id,
    sum(total_amount) as lifetime_value
from {{ ref('stg_orders') }}
where status = 'DELIVERED'
group by customer_id
```

dbt turns it into a table or view in your data warehouse. It figures out what order to build everything, handles the `CREATE TABLE` or `CREATE VIEW` statements, and tracks every dependency.

The `{{ ref('stg_orders') }}` call is the key. Instead of hard-coding a table name, you tell dbt to reference another model. dbt reads all those references, builds a dependency graph, and runs everything in the correct order — automatically.

---

### The Five Things That Make dbt Different

#### 1. Automatic Dependency Management

When you use `ref()` in dbt, it builds a **Directed Acyclic Graph (DAG)** of your entire warehouse. It knows that `fct_orders` depends on `stg_orders`, which depends on the raw source. It builds them in that order, every single time, without you thinking about it.

This is what the graph looks like when you run `dbt docs serve`:

> **Bronze (raw)** → **Silver (staging)** → **Gold (marts)**

You can add a new model, reference it from another, and dbt automatically slots it into the right position in the build order.

#### 2. Built-in Testing

dbt has a testing framework built in. You define tests in YAML files alongside your models:

```yaml
- name: order_id
  tests:
    - not_null
    - unique

- name: status
  tests:
    - accepted_values:
        values: ['DELIVERED', 'SHIPPED', 'CANCELLED']
```

Run `dbt test` and dbt queries your warehouse to verify every single one of those rules. If any test fails, you know immediately — before bad data reaches a dashboard or a business decision.

You can also write **custom tests** — any SQL query that returns zero rows when everything is correct.

#### 3. Auto-Generated Documentation

You describe your models and columns in YAML. dbt turns those descriptions into a full documentation website — searchable, browsable, and always up to date because it is generated from the same code your warehouse is built from.

The documentation site also includes the **interactive lineage graph** — a visual map of every model and how they connect to each other. In one click, you can see every table that depends on a source, or every upstream dependency of a model.

This is something most data teams have never had before.

#### 4. Jinja Macros (Reusable SQL Logic)

dbt uses Jinja templating, which means you can write reusable functions in SQL. Instead of copying the same logic across ten models, you write it once as a macro:

```sql
-- macros/cents_to_dollars.sql
{% macro cents_to_dollars(column_name) %}
    round({{ column_name }} / 100.0, 2)
{% endmacro %}
```

Then use it anywhere:

```sql
{{ cents_to_dollars('unit_price_cents') }} as unit_price
```

If the logic ever changes, you update it in one place.

#### 5. Source Freshness Monitoring

dbt lets you declare your raw data sources and set freshness thresholds:

```yaml
sources:
  - name: raw_orders
    freshness:
      warn_after: {count: 24, period: hour}
      error_after: {count: 48, period: hour}
```

Running `dbt source freshness` checks whether those tables have been updated within the expected window. This is how data teams detect when an upstream data pipeline silently fails — before anyone notices the dashboards are stale.

---

### Why Companies Use dbt

dbt has become the standard transformation layer in the modern data stack because it solves problems that previously had no clean solution.

**It makes SQL maintainable.** Large warehouses with hundreds of tables become manageable because every model is a separate file, version-controlled in Git, with a clear name and purpose.

**It creates accountability.** Because everything is in Git, every change has an author, a date, and a commit message. You can see exactly when a business rule changed and who changed it.

**It closes the gap between analysts and engineers.** Analysts who know SQL can write dbt models. Engineers can review them in pull requests. The same workflow that software teams use for application code now works for data transformation.

**It enables CI/CD for data.** Because dbt projects are just files in a Git repository, you can run automated tests on every pull request. Bad SQL that would break a dashboard never makes it to production.

**It scales with the team.** A solo analyst can use dbt on a laptop. A team of fifty engineers at a large company can use the same tool on the same codebase — with the same conventions, the same documentation, the same tests.

---

### Where dbt Fits in the Stack

dbt is a **transformation** tool. It does not ingest data — it works on data that is already in your warehouse. The typical modern data stack looks like this:

| Layer | Tool examples | What it does |
|---|---|---|
| Ingestion | Fivetran, Airbyte, Kafka | Moves raw data into the warehouse |
| Storage | Snowflake, Databricks, BigQuery | Stores all the data |
| **Transformation** | **dbt** | **Cleans, tests, and structures the data** |
| Visualisation | Looker, Tableau, Power BI | Builds dashboards on the clean data |

dbt owns the transformation layer completely.

---

### The Two Versions of dbt

**dbt Core** is the open-source command-line tool. It is free and runs locally or in any environment you choose.

**dbt Cloud** is the managed platform — a browser-based IDE, a scheduler, CI/CD integration, and hosted documentation. It is a paid product aimed at teams who want those features without managing infrastructure.

For learning and for most projects, dbt Core is everything you need.

---

### The Bottom Line

dbt is not a revolutionary idea. Writing SQL against a warehouse and building tables has always been possible. What dbt adds is **structure, reliability, and professionalism** to a process that was previously held together by convention and discipline alone.

It is the difference between a pile of SQL scripts in a shared folder and an engineering-grade data warehouse with documented tables, tested data, tracked changes, and a visual map of how everything connects.

That is why companies use it. That is why it is worth learning.

---

*If you want to see dbt in action end-to-end — including a real Medallion Architecture built on Databricks with 50 passing tests and live analytics charts — check out the [dbt + Databricks E-Commerce Warehouse](/projects/dbt-databricks-ecommerce/) project on this site.*
