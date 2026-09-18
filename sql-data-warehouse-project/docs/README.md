# SQL Data Warehouse Project

A hands-on SQL Data Warehouse built in **MySQL 8.4** from CRM and ERP CSV extracts, following a layered Bronze → Silver → Gold architecture.

## Architecture

```text
CRM / ERP CSV Files
        |
        v
+-------------------+
| Bronze             |
| Raw source data    |
+-------------------+
        |
        v
+-------------------+
| Silver             |
| Cleaned + standard|
|ized data           |
+-------------------+
        |
        v
+-------------------+
| Gold               |
| Dimensions + Fact  |
| (SQL Views)        |
+-------------------+
        |
        v
Business SQL Analysis
```

## Tech Stack

- MySQL Server 8.4
- MySQL Workbench
- SQL
- CSV
- Git / GitHub

## Project Structure

```text
sql-data-warehouse-project/
├── datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
├── scripts/
│   ├── bronze/
│   │   ├── ddl_bronze.sql
│   │   ├── proc_load_bronze.sql
│   │   └── quality_checks_bronze.sql
│   ├── silver/
│   │   ├── ddl_silver.sql
│   │   ├── proc_load_silver.sql
│   │   └── quality_checks_silver.sql
│   └── gold/
│       ├── ddl_gold.sql
│       ├── quality_checks_gold.sql
│       └── analysis.sql
├── docs/
└── tests/
```

## Layers

### Bronze
Stores the source extracts with minimal transformation.

Tables:
- `bronze_crm_cust_info`
- `bronze_crm_prd_info`
- `bronze_crm_sales_details`
- `bronze_erp_cust_az12`
- `bronze_erp_loc_a101`
- `bronze_erp_px_cat_g1v2`

### Silver
Cleans and standardizes the data.

Examples:
- trims names
- standardizes gender and marital status
- standardizes product lines
- removes ERP customer/location key formatting issues
- handles invalid dates
- deduplicates CRM customers
- validates/recalculates sales and price fields
- derives product end dates

### Gold
Business-ready SQL views:

- `gold_dim_customers`
- `gold_dim_products`
- `gold_fact_sales`

The model follows a star-schema pattern.

## Data Flow

```text
cust_info.csv --------> bronze_crm_cust_info --------> silver_crm_cust_info ----CUST_AZ12.csv --------> bronze_erp_cust_az12 --------> silver_erp_cust_az12 -----+--> gold_dim_customers
LOC_A101.csv ---------> bronze_erp_loc_a101 ---------> silver_erp_loc_a101 -------/

prd_info.csv ----------> bronze_crm_prd_info --------> silver_crm_prd_info ------PX_CAT_G1V2.csv -------> bronze_erp_px_cat_g1v2 -----> silver_erp_px_cat_g1v2 ----+--> gold_dim_products

sales_details.csv -----> bronze_crm_sales_details --> silver_crm_sales_details ---+
                                                                                  +--> gold_fact_sales
```

## Loading Data

The Bronze layer uses MySQL's `LOAD DATA LOCAL INFILE`.

Example:

```sql
LOAD DATA LOCAL INFILE '/path/to/file.csv'
INTO TABLE bronze_crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

On macOS, the MySQL CLI may need LOCAL INFILE enabled:

```bash
/usr/local/mysql/bin/mysql --local-infile=1 -u root -p
```

If Workbench does not permit local file loading, use the MySQL CLI or configure the client appropriately.

## Execution Order

Run scripts in this order:

1. `scripts/bronze/ddl_bronze.sql`
2. `scripts/bronze/proc_load_bronze.sql`
3. `scripts/bronze/quality_checks_bronze.sql`
4. `scripts/silver/ddl_silver.sql`
5. `scripts/silver/proc_load_silver.sql`
6. `scripts/silver/quality_checks_silver.sql`
7. `scripts/gold/ddl_gold.sql`
8. `scripts/gold/quality_checks_gold.sql`
9. `scripts/gold/analysis.sql`

> Gold is implemented with views, so there is no `proc_load_gold.sql`.

## Known Data Volumes

The completed project loaded:

| Layer | Object | Rows |
|---|---|---:|
| Bronze | CRM customer | 18,494 |
| Bronze | CRM product | 397 |
| Bronze | CRM sales | 60,398 |
| Bronze | ERP customer | 18,484 |
| Bronze | ERP location | 18,484 |
| Bronze | ERP category | 37 |
| Silver | CRM customer | 18,485 |
| Silver | CRM product | 397 |
| Silver | CRM sales | 60,398 |
| Silver | ERP customer | 18,484 |
| Silver | ERP location | 18,484 |
| Silver | ERP category | 37 |

The Silver CRM customer count is lower because duplicate `cst_id` records are reduced to the latest record.

## Gold Quality Checks

The completed Gold validation included:

- duplicate customer surrogate keys → 0 issues
- duplicate product surrogate keys → 0 issues
- fact-to-customer connectivity → 0 issues
- fact-to-product connectivity → 0 issues

## Business Analysis

`analysis.sql` covers:

- total revenue
- total orders
- purchasing customers
- average order value
- sales by country
- sales by category
- top products
- top customers
- sales by product line
- products by category
- quantity by category
- monthly sales trend
- repeat customers
- average selling price
- highest-revenue orders

## Documentation

The `docs/` directory contains architecture, requirements, implementation, catalog, naming, mapping, lineage, testing and business-analysis documentation.

## Important Design Choices

- One database: `DataWarehouse`
- Layer prefixes: `bronze_`, `silver_`, `gold_`
- Gold uses views
- Surrogate keys are generated in Gold
- Silver performs cleansing and standardization
- Source CSV structure is preserved as much as practical in Bronze
- MySQL syntax is used instead of SQL Server syntax

## Future Improvements

- incremental loading
- automated orchestration
- stronger automated tests
- indexing and performance tuning
- CI/CD
- BI dashboard
- cloud deployment
- data-quality monitoring
