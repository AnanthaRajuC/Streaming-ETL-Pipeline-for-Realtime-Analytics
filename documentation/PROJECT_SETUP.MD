## Environment Deployment

This document covers the deployment of the containerized streaming ETL pipeline environment using Docker Compose orchestration and management scripts. It focuses on the automated and manual deployment processes, service verification, and environment teardown procedures.

## Deployment Architecture

The whole pipeline (MySQL, Kafka, Debezium, Schema Registry, ksqlDB, ClickHouse and both web UIs) is defined in `docker-compose.yaml`. Every image is pinned to a tested version, Kafka runs in KRaft mode (no ZooKeeper), and the services with healthchecks (MySQL, Kafka, Debezium Connect, ksqlDB, ClickHouse) gate the services that depend on them.

## Automated Deployment

The system provides the `deploy.sh` script for automated environment deployment with integrated service verification.

**Deploy Script Execution**

~~~bash
./deploy.sh
~~~

![deploy](images/deploy.png)

The automated deployment sequence performs the following operations:

| Step | Command                               | Purpose                                                   |
|------|---------------------------------------|-----------------------------------------------------------|
| 1    | `docker compose up -d --wait`         | Start all services and wait until they report healthy     |
| 2    | `docker compose ps`                   | Display running containers                                |
| 3    | -                                     | Print the service URLs and the next commands to run       |

On the first start, MySQL creates the `streaming_etl_db` schema, the `debezium` CDC user and the sample data, and ClickHouse creates the `KafkaEngine` database. See [Initial MySQL Preparation](INITIAL_MYSQL_PREPARATION.MD).

--- 

## Manual Deployment Process

For granular control or troubleshooting, the deployment can be performed manually using individual Docker Compose commands.

**Pre-deployment Validation**

Validate the Docker Compose configuration before deployment:

~~~bash
docker compose -f docker-compose.yaml config
~~~

**Image Preparation**

Pull all required Docker images before starting services:

~~~bash
docker compose -f docker-compose.yaml pull
~~~

## Service Startup

Start the services using Docker Compose:

~~~shell
docker compose -f docker-compose.yaml up -d --wait
~~~

Expected output shows the creation of the `streaming_etl_webproxy` network and the containers becoming healthy:

~~~shell
 Network streaming_etl_webproxy  Created
 Container mysql                 Healthy
 Container kafka                 Healthy
 Container clickhouse            Healthy
 Container debezium              Healthy
 Container ksqldb-server         Healthy
 ...
~~~

## Service Verification

**Container Status Check**

Verify all containers are running:

`docker compose ps`

![Docker Compose Up](images/09-docker-ps.png) 

**Important**: All components must show **"Up"** status. If any container exited, check its logs with `docker compose logs <service>` and re-run `docker compose up -d --wait`.

URL to access Kafka-UI console: **http://localhost:9099**  

![Kafka UI](images/04-kafka-topics-before-debezium.png) 

## ksqlDB CLI Access

Launch the ksqlDB CLI for stream processing operations:

~~~shell
docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
~~~

![ksqlDB CLI](images/10-ksql-db-initial.png) 

## Service Access Points

| Service       | URL / Address            | Container        | Purpose                    |
|---------------|--------------------------|------------------|----------------------------|
| Debezium UI   | http://localhost:8080    | `debezium-ui`    | Connector management       |
| Kafka UI      | http://localhost:9099    | `kafka-ui`       | Topic monitoring           |
| Connect API   | http://localhost:8083    | `debezium`       | Debezium connector REST API|
| ksqlDB Server | http://localhost:8088    | `ksqldb-server`  | Stream processing API      |
| ClickHouse    | http://localhost:8123    | `clickhouse`     | Analytics database (`default` / `root`) |
| MySQL         | localhost:3306           | `mysql`          | Source database (`admin` / `password`)  |

--- 

## Environment Teardown

**Automated Teardown**

Use the `terminate.sh` script to stop and remove every container and the network:

~~~bash
./terminate.sh
~~~

![terminate](images/terminate.png)

**Manual Teardown Process**

~~~shell
docker compose -f docker-compose.yaml down
~~~

Add `-v` to also delete the MySQL and ClickHouse data, so their init scripts run again on the next start:

~~~shell
docker compose -f docker-compose.yaml down -v
~~~

**State Preservation Option**

To preserve container state without removing containers, use:

~~~bash
docker compose stop
~~~

## Network and Port Configuration

**Docker Network**

The deployment creates a custom bridge network named `streaming_etl_webproxy` that enables inter-service communication using container hostnames (`mysql`, `kafka`, `debezium`, `ksqldb-server`, `clickhouse`, ...).

**Port Mapping Configuration**

| Service         | Internal Port | External Port | Protocol         |
|-----------------|---------------|---------------|------------------|
| mysql           | 3306          | 3306          | MySQL            |
| kafka           | 9092          | 9092          | PLAINTEXT (Docker network clients) |
| kafka           | 29092         | 29092         | PLAINTEXT_HOST (clients on the host, `localhost:29092`) |
| debezium        | 8083          | 8083          | HTTP             |
| schema-registry | 8081          | 8081          | HTTP             |
| ksqldb-server   | 8088          | 8088          | HTTP             |
| clickhouse      | 8123 / 9000   | 8123 / 9000   | HTTP / native    |
| debezium-ui     | 8080          | 8080          | HTTP             |
| kafka-ui        | 8080          | 9099          | HTTP             |

## Environment Variable Configuration

Key environment variables for service configuration:

- **MySQL**: `database.env` (`MYSQL_ROOT_PASSWORD`, `MYSQL_USER`, `MYSQL_PASSWORD`), `MYSQL_DATABASE`
- **Kafka**: `KAFKA_PROCESS_ROLES`, `KAFKA_CONTROLLER_QUORUM_VOTERS`, `KAFKA_LISTENERS`, `KAFKA_ADVERTISED_LISTENERS`
- **Debezium**: `BOOTSTRAP_SERVERS`, `CONFIG_STORAGE_TOPIC`, `OFFSET_STORAGE_TOPIC`, `STATUS_STORAGE_TOPIC`
- **ksqlDB**: `KSQL_BOOTSTRAP_SERVERS`, `KSQL_LISTENERS`
- **Schema Registry**: `SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS`
- **ClickHouse**: `CLICKHOUSE_USER`, `CLICKHOUSE_PASSWORD`
