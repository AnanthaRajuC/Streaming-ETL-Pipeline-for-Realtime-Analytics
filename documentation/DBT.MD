## dbt Data Transformation

This document covers the optional integration of dbt (data build tool) with the streaming ETL pipeline for advanced data transformations and modeling. dbt provides SQL-based transformations on top of the ClickHouse analytics database, enabling sophisticated data modeling, testing, and documentation capabilities beyond the real-time stream processing performed by ksqlDB.

## Architecture Integration

dbt operates as an additional analytics layer on top of the existing streaming ETL pipeline, transforming data that has already been loaded into ClickHouse through the Kafka streaming process.

## Models and Tests

The models in `rta/models/KafkaEngine/` read from the `KafkaEngine.person_address_enriched` MergeTree table through `{{ source('KafkaEngine', 'person_address_enriched') }}`. They never read the `person_address_enriched_queue` Kafka engine table: a `SELECT` on a Kafka engine table consumes the messages, so the materialized view would miss them (ClickHouse blocks such queries by default).

`schema.yml` declares the source and adds `not_null` and `unique` tests, which `dbt build` runs after the models.

Run dbt from the `rta` folder against the ClickHouse container:

~~~bash
pip install dbt-clickhouse
cd rta
dbt build --profiles-dir .
~~~

## Commands and Operations

**Core dbt Commands**

| Command                     | Purpose                                | Port/Output     |
|-----------------------------|----------------------------------------|-----------------|
| `dbt debug`                 | Validate connection and configuration  | Console output  |
| `dbt build`                 | Execute all models and tests           | Console output  |
| `dbt docs generate`         | Generate documentation                 | HTML files      |
| `dbt docs serve --port 8001`| Serve documentation web interface      | Port 8001       |

## Setup and Initialization

### Project Initialization Process

~~~bash
# Initialize a new DBT project named 'rta'
dbt init rta

# Enter the project directory
cd rta

# Create the DBT profiles configuration file
touch profiles.yml

# Verify that DBT can connect to your data warehouse
dbt debug

# Generate static documentation
dbt docs generate

# Serve documentation on port 8001
dbt docs serve --port 8001

# Create a new directory for Kafka-based models
cd models
mkdir KafkaEngine
cd KafkaEngine

# Add an initial model file
touch rta_initial.sql

# Return to the project root
cd ..
cd ..

# Build models and run tests
dbt build
~~~

