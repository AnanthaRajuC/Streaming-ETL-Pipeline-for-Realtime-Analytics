## Overview

This document provides a high-level introduction to the Streaming ETL Pipeline repository, explaining its purpose, architecture, and key components. This system implements a real-time analytics pipeline that captures changes from MySQL databases and streams them to ClickHouse for analytical processing.

## Purpose and Scope

The Streaming ETL Pipeline is a containerized real-time data processing system designed to continuously capture database changes and replicate them for analytics. The system enables near real-time insights by streaming MySQL database modifications through a robust processing pipeline into ClickHouse, an analytical database optimized for OLAP workloads.

## Core Components

The system consists of several key components working together to provide real-time streaming ETL capabilities:

| Component             | Technology                 | Purpose                                                | Configuration                             |
|-----------------------|----------------------------|--------------------------------------------------------|-------------------------------------------|
| Source Database       | MySQL                      | Operational data store with CDC-enabled binary logging | `streaming_etl_db` database                |
| Change Data Capture   | Debezium                   | Captures MySQL changes and publishes to Kafka topics   | `streaming_ETL_pipeline_MySQL-connector`  |
| Message Broker        | Apache Kafka               | Distributed streaming platform for event processing    | Ports `9092`, `29092`                      |
| Coordination          | Apache ZooKeeper           | Cluster coordination for Kafka                         | Port `2181`                                |
| Schema Management     | Confluent Schema Registry  | Avro/JSON schema management for Kafka                  | Port `8081`                                |
| Stream Processing     | ksqlDB                     | Real-time stream processing and enrichment             | Port `8088`                                |
| Analytics Database    | ClickHouse                 | Columnar OLAP database for analytical queries          | External connection                        |
| Data Transformation   | dbt (Optional)             | SQL-based data modeling and transformation             | Post-processing layer                      |

## Deployment Architecture

The entire system is containerized and orchestrated using Docker Compose, with management scripts for lifecycle operations:

| Script/File           | Purpose                                             | Location        |
|-----------------------|-----------------------------------------------------|-----------------|
| `deploy.sh`           | Starts all services and initializes the pipeline    | Root directory  |
| `terminate.sh`        | Cleanly stops all services and removes containers   | Root directory  |
| `docker-compose.yaml` | Defines service orchestration and networking        | Root directory  |

The system uses a dedicated Docker network (`streaming_etl_pipeline_mysql_webproxy`) to enable inter-service communication while exposing specific ports for external access.