## Installation

This document covers the technical prerequisites, software dependencies, and installation procedures required to deploy and run the Streaming ETL Pipeline for Real-time Analytics system. It includes system requirements, dependency installation, and initial environment configuration necessary before proceeding with database preparation and environment deployment.

## System Requirements

The streaming ETL pipeline requires adequate system resources to support multiple containerized services running concurrently. The system operates as a distributed architecture with several resource-intensive components.

### Hardware Requirements

| Component | Minimum | Recommended | Purpose                                              |
|-----------|---------|-------------|------------------------------------------------------|
| RAM       | 8 GB    | 16 GB       | Multiple JVM-based services (Kafka, ksqlDB, Debezium)|
| CPU       | 4 cores | 8 cores     | Stream processing and CDC operations                 |
| Storage   | 20 GB   | 50 GB       | Container images, logs, and Kafka topics             |
| Network   | 1 Gbps  | 1 Gbps      | Inter-service communication                          |


### Software Dependencies

#### Core Dependencies

**Docker Platform**

~~~shell
# Verify Docker installation
docker --version
# Expected: Docker version 20.10.0 or higher

# Verify Docker Compose installation  
docker-compose --version
# Expected: docker-compose version 1.29.0 or higher
~~~

**Database Systems** 

~~~shell
# MySQL client for source database management
mysql --version
# Expected: mysql Ver 8.0.0 or higher
~~~

## Installation Steps

**Docker Installation**

Install Docker Engine following the official documentation for your operating system. Ensure the Docker daemon is running and accessible.

~~~shell
# Linux permission configuration (if needed)
sudo chmod 777 /var/run/docker.sock

# Verify Docker system resources
docker system info | grep Memory
~~~

## Optional Management Tools

Install database management clients for easier interaction with the system:

- **MySQL Workbench**: GUI client for MySQL database management
- **DBeaver Community**: Multi-database client supporting both MySQL and ClickHouse  

## Environment Configuration

### MySQL Configuration

The source MySQL database requires specific configuration for Change Data Capture (CDC) functionality. Configure the MySQL server with binary logging enabled.

**MySQL Server Configuration**

Create or modify the MySQL configuration file at */etc/mysql/mysql.conf.d/*

~~~txt
[mysqld]
server-id         = 223344
log_bin           = mysql-bin
expire_logs_days  = 1
binlog_format     = row
~~~

**Configuration Parameters**

| Parameter         | Value       | Purpose                                              |
|-------------------|-------------|------------------------------------------------------|
| `server-id`       | 223344      | Unique identifier for MySQL replication             |
| `log_bin`         | mysql-bin   | Enable binary logging for CDC                       |
| `expire_logs_days`| 1           | Log retention policy                                |
| `binlog_format`   | row         | Row-based replication format required by Debezium   |

## Installation Verification

**System Resource Check**

Verify adequate system resources are available:

~~~bash
# Check available memory
docker system info | grep Memory

# Check Docker daemon status
docker info

# Verify Docker Compose functionality
docker-compose version
~~~

**Network Connectivity Check**

Ensure Docker can create networks and containers can communicate:

~~~bash
# Test Docker network creation
docker network create test-network
docker network rm test-network

# Verify external database connectivity
mysql -h 172.17.0.1 -P 3306 -u root -p
~~~

**Configuration Verification**

Verify MySQL configuration is properly applied:

~~~sql
-- Connect to MySQL and verify binary logging
SHOW VARIABLES LIKE 'log_bin';
SHOW VARIABLES LIKE 'binlog_format';
SHOW VARIABLES LIKE 'server_id';
~~~