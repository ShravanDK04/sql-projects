# SQLite Data Quality & Health Monitor

## Project Overview

A lightweight SQLite-based system for detecting, tracking, and reporting common data-quality problems in customer and order data.

## Why I Built This

I wanted to build a project around a real-world data problem instead of another basic CRUD application.

In real applications, data can contain missing values, invalid references, incorrect amounts, and unexpected values. The goal of this project is to use SQLite to identify those problems and provide a simple view of the health of the dataset.

The main question behind the project is:

"Can SQLite help identify whether a dataset is healthy and show exactly where the problems are?"

## What the Project Does

The system works with two main datasets:

- Customers
- Orders

It checks for problems such as:

- Missing customer names
- Missing customer emails
- Invalid email formats
- Negative order amounts
- Missing order dates
- Missing order amounts
- Invalid order statuses
- Orders linked to customers that do not exist

Detected problems are stored in a separate `data_quality_issues` table.

The project also generates:

- A summary of each quality check
- PASS / FAIL status
- Number of issues found
- Detailed problematic records
- An overall order data-quality score

## Database Design

The project contains three tables.

### customers

Stores customer information.

- `customer_id`
- `name`
- `email`

### orders

Stores customer orders.

- `order_id`
- `customer_id`
- `order_date`
- `amount`
- `status`

### data_quality_issues

Stores problems detected during quality checks.

- `issue_id`
- `table_name`
- `column_name`
- `issue_type`
- `record_id`
- `description`

The customer and order tables are related through `customer_id`. This relationship is also used to detect orders that reference customers that do not exist.

## Example

An order such as:

| order_id | customer_id | amount | status |
|----------|-------------|--------|--------|
| 7 | 99 | 800.00 | Completed |

may look valid, but customer `99` does not exist in the customer table.

The system identifies this as an invalid reference.

Another example is:

| order_id | amount |
|----------|--------|
| 6 | -500.00 |

This is identified as a negative order amount.

## SQLite / SQL Concepts Used

- Primary Keys
- Foreign-key relationships
- SELECT
- INSERT
- WHERE
- NULL handling
- JOIN
- LEFT JOIN
- Subqueries
- COUNT
- SUM
- GROUP BY
- CASE expressions
- UNION ALL
- Views
- Data validation
- Basic scoring

The project is intentionally focused on practical SQL and SQLite concepts rather than unnecessary advanced database features.

## Data Quality Report

The project creates a `data_quality_report` view that summarizes the checks.

Example:

| Check | Issues | Result |
|------|------:|--------|
| Customers - Missing Name | 1 | FAIL |
| Customers - Missing Email | 1 | FAIL |
| Customers - Invalid Email | 0 | PASS |
| Orders - Negative Amount | 1 | FAIL |
| Orders - Missing Amount | 1 | FAIL |
| Orders - Missing Date | 1 | FAIL |
| Orders - Invalid Status | 1 | FAIL |
| Orders - Invalid Customer | 1 | FAIL |

This makes it easier to understand the overall state of the data instead of looking at individual queries.

## Data Quality Score

The project also calculates a simple quality score based on problematic orders.

Example:

Total Orders: 10
Problematic Orders: 5
Quality Score: 50%

The score is intended as a simple project-level health indicator, not as a universal industry standard.

## What I Learned

This project helped me understand that database work is not only about storing and retrieving data.

I learned how SQL can be used to investigate the quality of the data itself.

Key areas I practiced:

- Relational table design
- Primary-key constraints
- Data validation
- NULL handling
- JOIN-based validation
- Aggregation
- SQL views
- Storing detected issues
- Building reusable quality checks

## Challenges I Faced

One of the challenges was getting comfortable with SQLite tooling and understanding the difference between the SQLite database file and the SQL used to interact with it.

I initially worked with SQLite through a VS Code extension. When the database started producing unexpected results, I investigated the problem using the SQLite command line and found that the database file was corrupted.

I recreated the database and moved the development workflow to DB Browser for SQLite.

I also encountered primary-key constraint errors after accidentally executing seed data more than once. This helped reinforce how primary keys prevent duplicate records.

These problems were useful because they made the project more than just writing queries. I had to understand what was happening in the database and troubleshoot it.

## Future Improvements

Possible improvements include:

- Adding more data-quality rules
- Supporting additional datasets
- Detecting duplicate records
- Adding indexes
- Using `EXPLAIN QUERY PLAN`
- Tracking quality scores over time
- Adding a simple application interface
- Allowing quality checks on new datasets

These are outside the current scope so the project stays focused on its core purpose.

## Tech Stack

- SQLite
- SQL
- DB Browser for SQLite

## Key Takeaway

The project started with a simple question:

"How can I use SQLite for something more useful than basic CRUD operations?"

The result is a small data-quality monitoring system that uses SQL to identify problems, store them, and turn the results into a readable health report.

The project helped me move from simply writing SQL queries to thinking about how databases can be used to solve real data problems.
