## dbt Data Transformation

This document covers the optional integration of dbt (data build tool) with the streaming ETL pipeline for advanced data transformations and modeling. dbt provides SQL-based transformations on top of the ClickHouse analytics database, enabling sophisticated data modeling, testing, and documentation capabilities beyond the real-time stream processing performed by ksqlDB.

## Architecture Integration

dbt operates as an additional analytics layer on top of the existing streaming ETL pipeline, transforming data that has already been loaded into ClickHouse through the Kafka streaming process.

## Models and Tests

The models live in `rta/models/KafkaEngine/`:

| Model            | Materialization | Contents                                                                 |
|------------------|-----------------|--------------------------------------------------------------------------|
| `person_current` | view            | One row per person that still exists: `person_address_enriched FINAL WHERE IS_DELETED = 0` |
| `rta_initial`    | view            | Top 5 cities by number of people, from `person_current`                  |
| `rta_initial_2`  | table           | The same, materialized as a MergeTree table                              |

`person_current` reads the `KafkaEngine.person_address_enriched` ReplacingMergeTree table through `{{ source('KafkaEngine', 'person_address_enriched') }}` and collapses its versions with `FINAL` (see [ClickHouse](ClickHouse.MD)). No model reads the `person_address_enriched_queue` Kafka engine table: a `SELECT` on a Kafka engine table consumes the messages, so the materialized view would miss them (ClickHouse blocks such queries by default). People without an address are counted under the city `Unknown`.

`schema.yml` declares the source and adds tests that `dbt build` runs after the models: `P_ID` is unique and not null in `person_current`, each city appears once in the top-5 models, and a missing `CITY` raises a warning.

Run dbt from the `rta` folder against the ClickHouse container. `rta/profiles.yml` reads the ClickHouse login from the `CLICKHOUSE_USER` and `CLICKHOUSE_PASSWORD` environment variables, so load `.env` first:

~~~bash
pip install -r rta/requirements.txt
set -a; source .env; set +a
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

