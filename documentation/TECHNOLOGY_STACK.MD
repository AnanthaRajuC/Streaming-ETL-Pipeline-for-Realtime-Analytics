## Technology Stack

This document provides a comprehensive overview of the technologies used in the Streaming ETL Pipeline for Real-time Analytics. It covers the core technologies, their roles, and how they integrate to enable real-time data streaming from MySQL to ClickHouse.

## Core Technology Categories

The system is built using a carefully selected stack of technologies organized into distinct functional categories, each serving specific roles in the streaming ETL pipeline.

<details open="open">
	<ul>
		<li><a href="#stream">Stream</a></li>
		<li><a href="#data">Data</a></li>
		<li><a href="#change-data-capture">Change Data Capture</a></li>
		<li><a href="#client---cli-ui">Client - CLI/UI</a></li>
	</ul>
</details>

### Streaming Platform Technologies

The streaming backbone consists of three core Apache Kafka ecosystem components that handle distributed event streaming, coordination, and schema management.

| Technology               | Version/Distribution   | Role                                                                 |
|--------------------------|------------------------|----------------------------------------------------------------------|
| Apache Kafka             | Open Source            | Distributed event streaming platform serving as the central message broker |
| Apache ZooKeeper         | Open Source            | Centralized coordination service for Kafka cluster management and configuration |
| Confluent Schema Registry| Confluent Distribution | Schema management service for Avro, JSON Schema, and Protobuf schemas |

**Kafka Configuration**

- Bootstrap servers accessible on ports `9092` (internal) and `29092` (external)
- Topics automatically created for database table changes`
- Supports both producer and consumer applications

**ZooKeeper Role**

- Maintains Kafka cluster metadata and configuration
- Handles leader election for Kafka partitions
- Provides distributed synchronization services

**Schema Registry Integration**

- Manages schema evolution for Kafka topics
- Ensures data compatibility across producers and consumers
- Accessible via REST API on port `8081`

### Data Storage Technologies

The pipeline uses specialized databases optimized for different workloads: transactional processing, stream processing, and analytical queries.

| Technology | Type                  | Purpose                                                              |
|------------|-----------------------|----------------------------------------------------------------------|
| MySQL      | RDBMS                 | Source operational database for transactional data                   |
| ksqlDB     | Stream Processing DB  | Real-time stream processing and enrichment on Kafka streams          |
| ClickHouse | OLAP Database         | Target analytical database optimized for real-time analytics         |

**MySQL as Source System**

- Serves as the operational database with transactional data
- Uses binary logging for change data capture
- Database name: `streaming_etl_db`
- Contains tables: `person`, `address`, `geo`

**ksqlDB Stream Processing**

- Purpose-built database for stream processing applications
- Performs real-time joins and data enrichment
- Creates materialized views of streaming data
- Accessible via **CLI** and **REST API** on port `8088`

**ClickHouse Analytics Storage**

- Columnar database optimized for analytical queries
- Receives enriched data from Kafka topics
- Supports high-throughput inserts and fast analytical queries

### Change Data Capture Technology

The system implements Change Data Capture (CDC) using Debezium to capture and stream database changes in real-time.

| Technology | Distribution         | Functionality                                                  |
|------------|----------------------|----------------------------------------------------------------|
| Debezium   | Red Hat/Confluent    | Streams database changes by reading transaction logs           |

**Debezium MySQL Connector**

- Captures row-level changes from MySQL binary logs
- Publishes change events to Kafka topics
- Supports multiple change event formats (JSON, Avro)
- Connector name: `streaming_ETL_pipeline_MySQL-connector`

**Change Event Topics**

- `dbserver.streaming_etl_db.person` - Person table changes
- `dbserver.streaming_etl_db.address` - Address table changes
- `dbserver.streaming_etl_db.geo` - Geo table changes

## Deployment and Orchestration Technologies

The entire system runs in a containerized environment using Docker and Docker Compose for orchestration and lifecycle management.

**Container Orchestration**

| Technology      | Role                  | Configuration                                               |
|-----------------|-----------------------|--------------------------------------------------------------|
| Docker          | Container Runtime     | Provides isolated runtime environments for each service      |
| Docker Compose  | Service Orchestration | Defines multi-container application stack                    |

**Service Deployment Structure**

- All services deployed as Docker containers
- Network: `streaming_etl_pipeline_mysql_webproxy`
- Persistent volumes for data storage
- Port mapping for external access

**Management Scripts**

The system includes automated deployment and lifecycle management scripts:

| Script         | Purpose           | Functionality                               |
|----------------|-------------------|---------------------------------------------|
| `deploy.sh`    | System Deployment | Starts all services via Docker Compose      |
| `terminate.sh` | System Shutdown   | Stops and removes all containers            |

## Development and Management Tools

The system provides multiple interfaces for development, monitoring, and management of the streaming pipeline.

**Web-Based Management Interfaces**

| Tool         | Access            | Purpose                                                |
|--------------|-------------------|--------------------------------------------------------|
| Kafka UI     | `localhost:9099`  | Apache Kafka cluster monitoring and topic management   |
| Debezium UI  | `localhost:8080`  | Interactive connector setup and operations             |

**Kafka UI Features**

- Topic browsing and message inspection
- Consumer group monitoring
- Cluster health and metrics
- Schema registry integration

**Debezium UI Capabilities**

- Connector configuration and deployment
- Real-time connector status monitoring
- Change event stream visualization

**Command-Line Interfaces**

| CLI Tool     | Access Method                              | Use Cases                          |
|--------------|--------------------------------------------|------------------------------------|
| ksqlDB CLI   | `docker exec` into `ksqldb-cli` container  | Stream processing query development|
| Docker CLI   | Host system                                | Container lifecycle management     |

**ksqlDB CLI Usage**

- Interactive SQL-like query interface
- Stream and table creation
- Real-time data transformation development
- Query result inspection

## Technology Integration Patterns

The system implements several key integration patterns that enable seamless data flow across technology boundaries:

**Schema Management Pattern**

- Confluent Schema Registry provides centralized schema management
- Ensures data compatibility across all pipeline stages
- Supports schema evolution without breaking existing consumers

**Event-Driven Architecture Pattern**

- Kafka serves as the central event bus
- All components communicate via event streaming
- Enables loose coupling and independent scaling

**Stream Processing Pattern**

- ksqlDB provides SQL-like interface for stream processing
- Real-time data enrichment through stream joins
- Materialized views for aggregated streaming data

**Change Data Capture Pattern**

- Debezium captures database changes at the transaction log level
- Near real-time change propagation to downstream systems
- Preserves complete change history and event ordering